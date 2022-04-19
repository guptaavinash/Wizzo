      
 -- [sp_GetPDAMsgList] '352801088236109','1.0'    
CREATE PROCEDURE [dbo].[sp_GetPDAMsgList]  -- SP Made For Web Service to return Top 10 Records to PDA            
@PDACode VARCHAR(50) ,                
@AppVersionNo VARCHAR(10)              
AS              

DECLARE @PDAGCMAutoID INT,@AppVersionID INT, @ChannelID VARCHAR(100)       
      
      
--  SELECT     @ChannelID =    tblChannelMstr.NodeId      
--FROM            tblPDAMaster INNER JOIN      
--                         tblPDA_UserMapMaster ON tblPDAMaster.PDAID = tblPDA_UserMapMaster.PDAID INNER JOIN      
--                         tblSalesHierChannelMapping ON tblPDA_UserMapMaster.PersonID = tblSalesHierChannelMapping.SalesStructureNodID AND       
--                         tblPDA_UserMapMaster.PersonType = tblSalesHierChannelMapping.SalesStructureNodType INNER JOIN      
--                         tblChannelMstr ON tblSalesHierChannelMapping.ChannelID = tblChannelMstr.NodeId      
--WHERE tblPDAMaster.PDA_IMEI = @IMENumber      
  
SELECT     @ChannelID = tblVersionDownloadStatusMstr.ApplicationType FROM tblVersionDownloadStatusMstr WHERE tblVersionDownloadStatusMstr.PDACode = @PDACode    
      PRINT @ChannelID        
--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber              
--PRINT @DeviceID   
SELECT  @PDAGCMAutoID=PDAGCMAutoID FROM  tbl_PDAGCM_Mstr WHERE PDACode=@PDACode      
        PRINT @PDAGCMAutoID   
SELECT @AppVersionID = VersionID FROM tblVersionMstr WHERE CAST(VersionSerialNo AS FLOAT)= CAST(@AppVersionNo AS FLOAT)  AND tblVersionMstr.ApplicationType=@ChannelID     
PRINT @AppVersionID        
BEGIN              
  --SELECT TOP(10) PDAGCM_MsgID AS MsgServerID, PDAGCM_Msg AS NotificationMessage, convert(varchar(11),PDAGCM_MsgSendingTime, 109) + right(convert(varchar(32),PDAGCM_MsgSendingTime,100),8) AS MsgSendingTime        
  -- FROM tbl_PDAGCM_MsgMstr       
  --WHERE PDAGCMAutoID=@PDAGCMAutoID AND AppVersionID=@AppVersionID ORDER BY PDAGCM_MsgID --DESC        
        
        DECLARE @cntMsg int
        SELECT @cntMsg=COUNT(*) from tbl_PDAGCM_MsgMstr
        PRINT @cntMsg
        IF @cntMsg>9
				select PDAGCM_MsgID AS MsgServerID, PDAGCM_Msg AS NotificationMessage, convert(varchar(11),PDAGCM_MsgSendingTime, 109) + right(convert(varchar			(32),PDAGCM_MsgSendingTime,100),8) AS MsgSendingTime  from tbl_PDAGCM_MsgMstr where PDAGCM_MsgID not in       
				(select top((select COUNT(*) from tbl_PDAGCM_MsgMstr ) -10 )PDAGCM_MsgID from tbl_PDAGCM_MsgMstr) AND PDAGCMAutoID=@PDAGCMAutoID AND						AppVersionID=@AppVersionID
		ELSE
					select PDAGCM_MsgID AS MsgServerID, PDAGCM_Msg AS NotificationMessage, convert(varchar(11),PDAGCM_MsgSendingTime, 109) + right(convert							(varchar(32),PDAGCM_MsgSendingTime,100),8) AS MsgSendingTime  from tbl_PDAGCM_MsgMstr where  PDAGCMAutoID=@PDAGCMAutoID AND AppVersionID=@AppVersionID
            
END         

