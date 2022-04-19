
--[spGetSalesOrderDate] 8,150
CREATE PROC [dbo].[spGetSalesOrderDate]
@SalesNodeId int,
@SalesNodeType int
as
begin

CREATE TABLE #Orders(OrderDate Date,OrderDateTxt VARCHAR(20))
IF ISNULL(@SalesNodeType,0)=0
BEGIN
	INSERT INTO #Orders(OrderDate,OrderDateTxt)
	select distinct top 14  OrderDate,format(OrderDate,'dd-MMM-yyyy') as OrderDateTxt from tblordermaster 
	order by 1 desc
END
ELSE
BEGIN
	INSERT INTO #Orders(OrderDate,OrderDateTxt)
	select distinct top 14  OrderDate,format(OrderDate,'dd-MMM-yyyy') as OrderDateTxt from tblordermaster where salesnodeid=@salesnodeid and salesnodetype=@salesnodetype
	order by 1 desc
END



if not exists(select * from #Orders)
begin
insert into #Orders values(getdate(),format(getdate(),'dd-MMM-yyyy'))
end
select * from #Orders
end
