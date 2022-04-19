-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

-- [spPDAGetInvoiceCaption] '28-Aug-2018','863408031291603',0,0,0,0,0

CREATE PROCEDURE [dbo].[spPDAGetInvoiceCaption]

	   @Date DAte,

	   @PDA_IMEI VARCHAR(20),

	   @RouteID INT,

	   @RouteNodeType SMALLINT,

	   @flgAllRoutesData INT,

	   @CoverageAreaNodeID INT,

	   @coverageAreaNodeType SMALLINT



AS

BEGIN

	DECLARE @SalesmanNodeID INT,@SalesmanNodeType SMALLINT,@PDAID INT

	DECLARE @VanID INT,@VanNodeType SMALLINT

	DECLARE @VanIntialInvoiceCaption AS Varchar(5)

	DECLARE @VanIntialInvoiceIds AS Int

	DECLARE @InvSuffix VARCHAR(20)




	SELECT  @SalesmanNodeID=SP.PersonNodeID,@SalesmanNodeType=SP.PersonType,@PDAID=tblPDAMaster.PDAID  FROM         tblPDAMaster INNER JOIN

	tblPDA_UserMapMaster UM ON tblPDAMaster.PDAID = UM.PDAID INNER JOIN

	tblSalesPersonMapping SP ON UM.PersonID = SP.PersonNodeID AND 

	UM.PersonType = SP.PersonType

	WHERE     (tblPDAMaster.PDA_IMEI = @PDA_IMEI OR tblPDAMaster.PDA_IMEI_Sec=@PDA_IMEI) AND 

	(GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND (GETDATE() BETWEEN UM.DateFrom AND UM.DateTo) ORDER BY NodeType desc


	PRINT '@SalesmanNodeID='+ CAST(@SalesmanNodeID AS VARCHAR)
	PRINT '@@SalesmanNodeType='+ CAST(@SalesmanNodeType AS VARCHAR)
	DECLARE @InitialTag VARCHAR(10)

	--SELECT @VanID=VanID,@VanNodeType=260,@InitialTag=V.VanUniqueID FROM [dbo].tblVanStockMaster INNER JOIN tblVanMstr V ON V.NodeID=VanID AND V.NodeType=260 WHERE SalesManNodeID=@SalesmanNodeID AND SalesmanNodetype=@SalesmanNodeType AND CAST(TransDate AS DATE)<=@Date

	SELECT @VanID=VanID,@VanNodeType=260,@InitialTag=V.VanUniqueID FROM dbo.fnGetLastPersonAssignedBasedOnPDACode(@PDA_IMEI,@Date) F INNER JOIN tblVanMstr V ON V.NodeID=F.VanID

	PRINT '@VanID=' + CAST(@VanID AS VARCHAR)

	DECLARE @FYID INT
	SELECT @FYID=FYID FROM tblfinancialyear WHERE @Date BETWEEN FYStartDate AND FYEndDate

	IF NOT EXISTS(SELECT 1 FROM tblMstrSequenceForTrnTable_Direct T WHERE SalesNodeID=@VanID AND SalesNodetype=@VanNodeType AND tablename='tblInvMaster' AND InitialTag='I')
	BEGIN
		insert into tblMstrSequenceForTrnTable_Direct values('tblInvMaster','InvCode','I',@FYID,@VanID,@VanNodeType,'I',4,1000)
	END

	SELECT @VanIntialInvoiceCaption=V.VanUniqueID,@VanIntialInvoiceIds=LastGenNum + 1,@InvSuffix=CAST(FYID-1 AS VARCHAR) + '-' + CAST(FYID AS VARCHAR) FROM tblMstrSequenceForTrnTable_Direct T RIGHT OUTER JOIN tblVanMstr V ON V.NodeID=T.SalesNodeID AND V.NodeType=T.SalesNodetype WHERE T.SalesNodeID=@VanID AND T.SalesNodetype=@VanNodeType AND tablename='tblInvMaster' AND InitialTag='I'



	--SET @VanIntialInvoiceCaption=NULL

	SELECT @VanIntialInvoiceCaption InvPrefix,ISNULL(@VanIntialInvoiceIds,1001) VanIntialInvoiceIds,@InvSuffix AS InvSuffix

END

--SELECT * FROM tblMstrSequenceForTrnTable

--Select * from tblOrderMaster
--SELECT * FROM tblInvMaster




