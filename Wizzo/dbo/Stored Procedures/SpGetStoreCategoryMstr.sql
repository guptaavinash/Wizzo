
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 
-- Description:	
-- =============================================
--[SpGetStoreCategoryMstr] 1
CREATE PROCEDURE [dbo].[SpGetStoreCategoryMstr] 
@ChannelId INT=1
AS
BEGIN
	
	SELECT StoreSegmentationID NodeID,StoreSegment StoreCategory ,NodeType
	FROM tblMstrStoreSegment
	--WHERE IsActive=1
	
END

