
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-Apr-2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetChannelMstr] 
	
AS
BEGIN
	SELECT OutChannelID NodeID,ChannelName Descr FROM [dbo].[tblOutletChannelmaster]
	
END




