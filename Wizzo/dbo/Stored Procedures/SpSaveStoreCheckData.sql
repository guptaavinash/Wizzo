CREATE PROCEDURE [dbo].[SpSaveStoreCheckData] 
	@PDA_IMEI VARCHAR(100),
	@tblStoreCheckData udt_RawStoreCheckData READONLY
	
AS
BEGIN
	SELECT 'AA hi gaya'
	SELECT * FROM @tblStoreCheckData
	IF EXISTS (SELECT 1 FROM @tblStoreCheckData)
	BEGIN	
		DELETE A FROM tblVisitStock A INNER JOIN @tblStoreCheckData S ON S.VisitID=A.VisitID
		--SELECT VisitID,[ProductID],[StockQty] FROM @tblStoreCheckData
		INSERT INTO tblVisitStock(VisitID,ProductID,Qty,StockDate)
		SELECT VisitID,[ProductID],[StockQty],GETDATE() FROM @tblStoreCheckData
	END
	
END
