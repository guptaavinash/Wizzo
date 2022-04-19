-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-Feb-2018
-- Description:	
-- =============================================
-- exec [SpManageSalesVanMapping] @VanID=3,@VanNodetype=260,@SalesNodeID=6,@SalesNodeType=130,@flgMap=1,@LoginID=1136
CREATE PROCEDURE [dbo].[SpManageSalesVanMapping] 
	@VanID INT,
	@VanNodetype SMALLINT,
	@SalesNodeID INT,
	@SalesNodetype SMALLINT,
	@flgMap TINYINT, ---0=Unmapped,1=Mapped
	@LoginID INT
AS
BEGIN
	DECLARE @flgUpdated TINYINT=0
	IF @VanID>0
	BEGIN
		IF @flgMap=0
		BEGIN
			UPDATE SV SET Todate=DATEADD(d,-1,GETDATE()),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblSalesHierVanMapping SV WHERE VanID=@VanID AND VanNodeType=@VanNodetype AND SV.SalesNodeID=@SalesNodeID AND SV.SalesNodetype=@SalesNodetype
			and getdate() between fromdate and Todate
			SET @flgUpdated=1
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM tblSalesHierVanMapping WHERE VanID=@VanID AND GETDATE() BETWEEN Fromdate AND ToDate)
			BEGIN
				SET @flgUpdated=0
			END
			ELSE
			BEGIN
				--- Remove the old van mapping
				UPDATE SV SET Todate=DATEADD(d,-1,GETDATE()),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblSalesHierVanMapping SV WHERE SV.SalesNodeID=@SalesNodeID AND SV.SalesNodetype=@SalesNodetype and getdate() between fromdate and Todate

				INSERT INTO tblSalesHierVanMapping(SalesNodeID,SalesNodetype,VanID,VanNodeType,Fromdate,Todate,LoginIDIns,TimestampIns)
				SELECT @SalesNodeID,@SalesNodetype,@VanID,@VanNodetype,GETDATE(),'31-dec-2049',@LoginID,GETDATE()
				SET @flgUpdated=1
			END

			--UPDATE SV SET Todate=DATEADD(d,-1,GETDATE()),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblSalesHierVanMapping SV WHERE SV.SalesNodeID=@SalesNodeID AND SV.SalesNodetype=@SalesNodetype
		END
	END

	SELECT @flgUpdated flgUpdated
END
