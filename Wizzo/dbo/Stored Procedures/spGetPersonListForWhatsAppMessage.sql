CREATE proc spGetPersonListForWhatsAppMessage
as
begin

if OBJECT_ID('tempdb..#ESMERPIds') is not null
begin
	drop table #ESMERPIds
end
select distinct p.NodeID,p.NodeType,ESMErpId,SelectedRoute,p.PersonPhone  from tmpDaySummaryAPI a join tblMstrPerson p on a.ESMErpId=p.Code where Type='Retailing' and ESMRank='ESM' AND ESMErpId IS NOT NULL
and SelectedRoute is not null and p.NodeType=220 and p.flgWhatsAppReg=1
end