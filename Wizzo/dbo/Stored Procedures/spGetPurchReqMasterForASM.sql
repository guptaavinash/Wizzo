Create proc [dbo].[spGetPurchReqMasterForASM]
AS
Select -1,'All' as Status
union all
Select POProcessStatusId,asmstatus from tblMstrPurchaseReqProcessStatus where POProcessStatusId in(0,1,4)
