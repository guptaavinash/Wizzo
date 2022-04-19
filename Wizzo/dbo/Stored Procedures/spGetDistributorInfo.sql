
-- [spGetDistributorInfo] 1,150
CREATE proc [dbo].[spGetDistributorInfo]
@NodeId int,
@NodeType int

as
begin
IF @NodeId=0 AND @NodeType=0
BEGIN
	SELECT        NodeID ,Descr, DistributorCode, DlvryWeeklyOffDay, OfficeWeeklyOffDay, Address1, Address2, PinCode, PhoneNo, FSSAINo, GSTNo, CSTTinNo, DLNo, InvoiceTermCondition, City, StateId, CountryId, Email,NodeType,
	BankAcNo,BankId,IFSCCode,MicrCode,BankAdd
FROM            tblDBRSalesStructureDBR
END
ELSE
BEGIN
	SELECT        NodeID,Descr, DistributorCode, DlvryWeeklyOffDay, OfficeWeeklyOffDay, Address1, Address2, PinCode, PhoneNo, FSSAINo, GSTNo, CSTTinNo, DLNo, InvoiceTermCondition, City, StateId, CountryId, Email,NodeType,
	BankAcNo,BankId,IFSCCode,MicrCode,BankAdd
FROM            tblDBRSalesStructureDBR
WHERE        (NodeID = @NodeId) AND (NodeType = @NodeType)

SELECT        DBRDefaultPaymentStageMappingId, DBRNodeId, DBRNodeType, PymtStageId, Percentage, CreditDays, [dbo].[fncSetAmtFormat]( CreditLimit) as CreditLimit, FromDate, ToDate, PrdNodeId, PrdNodeType, InvoiceSettlementType, CreditPeriodType, 
                         GracePeriodinDays
FROM            tblDBRDefaultPaymentStageMap
WHERE        (DBRNodeId = @NodeId) AND (DBRNodeType = @NodeType) AND (CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate)
select * from [dbo].[tblDBRDefaultPaymentModeMap] where DBRNodeId=@NodeId and DBRNodeType=@NodeType
and DBRDefaultPaymentStageMappingId in(select DBRDefaultPaymentStageMappingId from [dbo].[tblDBRDefaultPaymentStageMap] where DBRNodeId=@NodeId and DBRNodeType=@NodeType and convert(date,getdate()) between FromDate and ToDate)

	SELECT * from [dbo].[tblMstrSettlementMode] 
	SELECT * from tblmstrpaymentstage where pymtstageid>1
	SELECT A.PymtStageId,B.items as PymtModeId from tblmstrpaymentstage A cross apply dbo.split(A.PymtModeId,',') as B
select '1' as CreditPeriodTypeId,'Daily' as CreditPeriodType,1 as InvSettlementId
	union all
	select '2' as CreditPeriodTypeId,'Weekly(Mon-Sun)' as CreditPeriodType,2 as InvSettlementId
	union all
	select '3' as CreditPeriodTypeId,'Half Monthly(1-15,16-31)' as CreditPeriodType,2 as InvSettlementId
	union all
	select '4' as CreditPeriodTypeId,'Monthly(1-31)' as CreditPeriodType,2 as InvSettlementId
	select '1' as InvSettlementId,'Bill To Bill Settlement' as InvSettlementType
	union all
	select '2' as InvSettlementId,'Period Settlement' as InvSettlementType

	select * from  tblmstrbank
END

end




