

CREATE proc [dbo].[spDataLoadDaySummaryAPIData]
as
begin
RETURN;
--;with ashcte as (
--select *,ROW_NUMBER() over(partition by esmerpid order by esmerpid, convert(datetime,date) desc) as rown from tmpDaySummaryAPI where ESMRank='ESM')
--select * into #daysummary from ashcte where rown=1
if OBJECT_ID('tempdb..#ERPId') is not null
begin
drop table #ERPId
end
--select ESMErpId,Type,Reason,0 AS NodeId,0 as NodeType,0 as SENodeId,0 as SENodeType into #ERPId from #daysummary where ESMRank='ESM' AND Type in('Leave','Advance Leave','Absent')

--SELECT FieldUserErpId AS ESMErpId,Type,Reason,0 AS NodeId,0 as NodeType,0 as ASMAreaNodeId,0 as ASMAreaNodeType into #ERPId  FROM [dbo].[tmpAttendanceLiveAPI] where type in('Absent','Leave','Advanced Leave') AND FIELDUSERRANK='ESM'-- AND CONVERT(DATE,DATE)=CONVERT(DATE,GETDATE()) 

SELECT distinct SOareaCode AS ESMErpId,0 AS NodeId,0 as NodeType,0 as ASMAreaNodeId,0 as ASMAreaNodeType into #ERPId  FROM [dbo].vwSalesHierarchy 
--where type in('Absent','Leave','Advanced Leave') AND FIELDUSERRANK='ESM'-- AND CONVERT(DATE,DATE)=CONVERT(DATE,GETDATE()) 


Declare @currdate datetime=Getdate()
--if convert(time,@currdate)<convert(time,'10:30')
--begin
--delete #ERPId where Type='Absent'
--end
--else 
--begin
--print 'b'
--end

--DELETE A from #ERPId A LEFT JOIN tmpPlannedCallsData B ON A.ESMErpId=B.[SO ERP ]
--WHERE B.[SO ERP ] IS NULL



UPDATE A SET NodeId=b.NodeId,NodeType=b.NodeType FROM #ERPId A JOIN tblMstrPerson b on A.ESMErpId=b.Code
where b.NodeType=220

select * into #vwSalesHierarchy from vwSalesHierarchy
update B set ASMAreaNodeId=c.ASMAreaNodeId,ASMAreaNodeType=c.ASMAreaNodeType from  #ERPId b 
join #vwSalesHierarchy c on c.SONodeid=b.NodeId
and c.SONodeType=b.NodeType

delete #ERPId where ASMAreaNodeId=0
--select * from #ERPId


declare @SENodeId int,
@SENodeType int,
@Attendance [Attendance] ,
@LoginId int,
@SubmitDate date
--select * from #ERPId
--select * from @Attendance
Declare @i int=1,@cnt int=0
if OBJECT_ID('tempdb..#SEList') is not null
begin
	drop table #SEList
end
select distinct IDENTITY(INT,1,1) AS ident, ASMAreaNodeId,ASMAreaNodeType into #SEList from #ERPId

set @cnt=@@ROWCOUNT
while @i<=@cnt
begin

select @SENodeId=ASMAreaNodeId,@SENodeType=ASMAreaNodeType FROM #SEList where ident=@i

Delete @Attendance 

insert into @Attendance 
select distinct a.SONodeId,a.SONodeType,a.RouteNodeId,a.RouteNodeType,a.VisitDate,1 from tblRouteCalendar a join #ERPId b on a.SONodeId=b.NodeId
and a.SONodeType=b.NodeType
where a.VisitDate=CONVERT(date,@currdate) and b.ASMAreaNodeId=@SENodeId and b.ASMAreaNodeType=@SENodeType

--select 1,* from @Attendance

--SELECT @SENodeId,@SENodeType
insert into @Attendance 
select distinct a.SONodeId,a.SONodeType,b.RouteNodeId,b.RouteNodeType,b.VisitDate,0 from (select distinct NodeId as  SONodeId,NodeType as SONodeType from #ERPId where ASMAreaNodeId=@SENodeId and ASMAreaNodeType=@SENodeType) a join tblAttendanceDet b on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
join tblAttendanceMstr c on c.AttenId=b.AttendId
where c.AttenDate=CONVERT(date,@currdate) and ISNULL(b.loginidupd,b.LoginIdIns)=0 
and not exists(select * from @Attendance z where z.SONodeId=a.SONodeId
and z.SONodeType=a.SONodeType)

--select 2,* from @Attendance

Delete a from @Attendance a join tblAttendanceDet b on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
join tblAttendanceMstr c on c.AttenId=b.AttendId
where c.AttenDate=CONVERT(date,@currdate) and ISNULL(b.loginidupd,b.LoginIdIns)<>0 



--select 3,* from @Attendance
if (select COUNT(*) from @Attendance)>0
begin
	EXEC [spSubmitSOAttendance] @SENodeId,@SENodeType,@Attendance,0,@currdate
end
set @i=@i+1
end
end


--select * from tblStoreMaster where ContactNo like '%blank%'

--select * from tmpRawDataRouteAPI a join tmpRetailerMasterAPI b on a.ShopErpId=b.OutletErpId join tmpDaySummaryAPI c on c.ESMErpId=a.SOERPID



--select distinct SOERPID from tmpRawDataRouteAPI a join tmpRetailerMasterAPI b on a.ShopErpId=b.OutletErpId
