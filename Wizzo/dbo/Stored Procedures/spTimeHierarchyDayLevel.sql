



CREATE PROCEDURE [dbo].[spTimeHierarchyDayLevel]
AS
select distinct convert(varchar(50),Yearval) as HireId,convert(varchar(50),Yearval) as HireId_Org,convert(varchar(50),Yearval) as Descr,convert(varchar(50),Null) as PHireId,convert(varchar(50),Null) as PHireId_Org,convert(varchar(50),Yearval) as NodeID,4 as NodeType,4 as LstLevel  into #tmpTimeHier FROM [dbo].tblOlapTimeHierarchy_Day
union all
select distinct convert(varchar(50),RptMonthYear) as HireId,convert(varchar(50),RptMonthYear) as HireId_Org,[Month] as Descr,convert(varchar(50),Yearval) as PHireId,convert(varchar(50),Yearval) as PHireId_Org,convert(varchar(50),RptMonthYear) as NodeID,3 as NodeType,3 as LstLevel  FROM [dbo].tblOlapTimeHierarchy_Day 
union all
select distinct CAST(DATEPART(yyyy,WeekEnding) AS VARCHAR(4)) + RIGHT('0'+convert(nvarchar(2), DATEPART(mm, WeekEnding)),2) + RIGHT('0'+convert(nvarchar(2), DATEPART(dd, WeekEnding)),2) as HireId,convert(varchar(50),WeekEnding,106)+'-Week' as HireId_Org,strWeekEnding as Descr,convert(varchar(50),MAX(RptMonthYear)) as PHireId,convert(varchar(50),MAX(RptMonthYear)) as PHireId_Org,convert(varchar(50),WeekEnding,112) as NodeID,2 as NodeType,2 as LstLevel  FROM [dbo].tblOlapTimeHierarchy_Day GROUP BY WeekEnding,strWeekEnding
union all
select distinct CONVERT(VARCHAR(8),[Date],112) as HireId,convert(varchar(50),[Date],106) as HireId_Org,strDate as Descr,CONVERT(VARCHAR(8),WeekEnding,112) as PHireId,CONVERT(VARCHAR(50),WeekEnding,106)+'-Week' as PHireId_Org,convert(varchar(50),[Date],112) as NodeID,1 as NodeType,1 as LstLevel  
FROM [dbo].tblOlapTimeHierarchy_Day

select distinct A.* from #tmpTimeHier A 



