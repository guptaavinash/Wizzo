


CREATE FUNCTION [dbo].[fnGetPersonList](@PDACode varchar(50))
RETURNS @SalesPersonList TABLE (SalesPersonNodeId int,SalesPersonNodetype int,SalesNodeId int,SalesNodetype int)
begin

insert into @SalesPersonList
SELECT      distinct  tblPDACodeMapping.PersonID, tblSalesPersonMapping.PersonType, tblSalesPersonMapping.NodeID, tblSalesPersonMapping.NodeType 
FROM            
tblPDACodeMapping LEFT OUTER JOIN tblSalesPersonMapping ON tblPDACodeMapping.PersonID = tblSalesPersonMapping.PersonNodeID 
and
Convert(date,getdate()) between tblSalesPersonMapping.FromDate and tblSalesPersonMapping.ToDate
WHERE       PDACode=@PDACode

IF NOT EXISTS (SELECT 1 FROM @SalesPersonList)
insert into @SalesPersonList
SELECT      distinct  tblPDACodeMapping_History.PersonID, tblSalesPersonMapping.PersonType, tblSalesPersonMapping.NodeID, tblSalesPersonMapping.NodeType 
FROM            
tblPDACodeMapping_History LEFT OUTER JOIN tblSalesPersonMapping ON tblPDACodeMapping_History.PersonID = tblSalesPersonMapping.PersonNodeID 
and
Convert(date,getdate()) between tblSalesPersonMapping.FromDate and tblSalesPersonMapping.ToDate
WHERE       PDACode=@PDACode



return
end
