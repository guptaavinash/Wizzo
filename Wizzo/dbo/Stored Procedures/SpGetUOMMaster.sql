-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetUOMMaster] 
	
AS
BEGIN
	SELECT BUOMID,BUOMName,CASE BUOMName WHEN 'PKT' THEN 1 ELSE 0 END flgRetailUnit FROM tblPrdMstrBUOMMaster
	SELECT SKUID NodeID,NodeType,BaseUOMID,PackUOMID,RelConversionUnits,flgVanLoading,SqNo FROM [dbo].[tblPrdMstrPackingUnits_ConversionUnits] WHERE flgDistInvoice=1 order by 1,sqno
END
