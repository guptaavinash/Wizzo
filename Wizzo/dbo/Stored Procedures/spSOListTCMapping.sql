CREATE proc [dbo].[spSOListTCMapping]
@ASMAreaNodeId int,
@ASMAreaNodeType int
as
begin

select distinct A.SOAreaId AS  SoNodeId,A.SOAreaNodeType AS  SoNodeType,SOArea+isnull(' ['+SO+']','') AS [SO Area] ,b.TCNodeId,b.TCNodeType,t.TeleCallerCode from VwCompanyDSRFullDetail a left join tblTeleCallerSalesManMapping b 
inner join tblTeleCallerMstr t on t.TeleCallerId=b.TCNodeId
on a.SOAreaId=b.SoNodeId
and a.SOAreaNodeType=b.SoNodeType and GETDATE() between b.FromDate and b.ToDate where ASMAreaId=@ASMAreaNodeId and ASMAreaNodeType=@ASMAreaNodeType

end
