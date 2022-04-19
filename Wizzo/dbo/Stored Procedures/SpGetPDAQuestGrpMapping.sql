

-- =============================================      
-- Author:  <Author,,Name>      
-- Create date: <Create Date,,>      
-- Description: <Description,,>      
-- =============================================      
-- exec SpGetPDAQuestGrpMapping @ApplicationID=8,@IMEINo='352801088236109'
CREATE PROCEDURE [dbo].[SpGetPDAQuestGrpMapping] --1      
 @ApplicationID int ,
@PDACode VARCHAR(50)        
AS      
BEGIN   
--DECLARE @DeviceID INT        

 --SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINo OR PDA_IMEI_Sec=@IMEINo 
 --PRINT '@DeviceID=' + CAST(@DeviceID AS VARCHAR)       

 DECLARE @ChannelID INT,@ChannelNodeType SMALLINT ,@PersonNodeID INT,@PersonType SMALLINT

  SELECT @ChannelID=ChannelID,@ChannelNodeType=O.NodeType,@PersonNodeID=P.PersonNodeID,@PersonType=P.PersonType
  FROM tblSalesPersonMapping P   

 -- INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonNodeID AND M.PersonType=P.PersonType         

  --INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID  

  INNER JOIN tblSalesHierChannelMapping SM ON SM.SalesStructureNodID=P.NodeID AND SM.SalesStructureNodType=P.NodeType  

  INNER JOIN tblOutletChannelmaster O ON O.OutChannelID=SM.ChannelID        

 WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType         

 AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))   

  PRINT '@PersonType=' + CAST(@PersonType AS VARCHAR)
  PRINT '@@ChannelID=' + CAST(@ChannelID AS VARCHAR)
  

  IF @PersonType=210
  BEGIN    
 SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,P.QuestID, [tblDynamic_PDAQuestGrpMapping].GrpID , [tblDynamic_PDAQuestGrpMapping].GrpNodeID,      
 [tblDynamic_PDAQuestGrpMapping].GrpDesc,[tblDynamic_PDAQuestGrpMapping].SectionNo ,   ISNULL([tblDynamic_PDAQuestGrpMapping].GrpCopyID,0) GrpCopyID,ISNULL([tblDynamic_PDAQuestGrpMapping].QuestCopyID,0) QuestCopyID,
                 ISNULL([tblDynamic_PDAQuestGrpMapping].Sequence,0) Sequence, M.flgNewStore,M.flgStoreValidation
FROM         tblDynamic_PDAQuestMstr P INNER JOIN      
                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON P.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID 
					  INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=P.QuestID
					  Where P.ActiveQuest=1 AND [tblDynamic_PDAQuestGrpMapping].ActiveGrpQuest=1 AND M.ApplicationTypeID=@ApplicationID
					  order by [tblDynamic_PDAQuestGrpMapping].SectionNo,  [tblDynamic_PDAQuestGrpMapping].Sequence  
	END 
	ELSE
	BEGIN
		 SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,P.QuestID, [tblDynamic_PDAQuestGrpMapping].GrpID , [tblDynamic_PDAQuestGrpMapping].GrpNodeID,      
 [tblDynamic_PDAQuestGrpMapping].GrpDesc,[tblDynamic_PDAQuestGrpMapping].SectionNo ,    ISNULL([tblDynamic_PDAQuestGrpMapping].GrpCopyID,0) GrpCopyID,ISNULL([tblDynamic_PDAQuestGrpMapping].QuestCopyID,0) QuestCopyID,
                 ISNULL([tblDynamic_PDAQuestGrpMapping].Sequence,0) Sequence, flgNewStore,flgStoreValidation
FROM         tblDynamic_PDAQuestMstr P INNER JOIN      
                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON P.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID 
					  INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=P.QuestID
					  Where P.ActiveQuest=1 AND [tblDynamic_PDAQuestGrpMapping].ActiveGrpQuest=1 AND M.ApplicationTypeID =@ApplicationID
					  order by [tblDynamic_PDAQuestGrpMapping].SectionNo,  [tblDynamic_PDAQuestGrpMapping].Sequence  
	END 
END 
   
---- SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,tblDynamic_PDAQuestMstr.QuestID, [tblDynamic_PDAQuestGrpMapping].GrpID , [tblDynamic_PDAQuestGrpMapping].GrpNodeID,      
---- [tblDynamic_PDAQuestGrpMapping].GrpDesc,[tblDynamic_PDAQuestGrpMapping].SectionNo ,   [tblDynamic_PDAQuestGrpMapping].GrpCopyID,[tblDynamic_PDAQuestGrpMapping].QuestCopyID,
----                 [tblDynamic_PDAQuestGrpMapping].Sequence
----FROM         tblDynamic_PDAQuestMstr INNER JOIN      
----                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON tblDynamic_PDAQuestMstr.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID Where tblDynamic_PDAQuestMstr.ActiveQuest=1 AND [tblDynamic_PDAQuestGrpMapping].ActiveGrpQuest=1
----					  order by [tblDynamic_PDAQuestGrpMapping].SectionNo,  [tblDynamic_PDAQuestGrpMapping].Sequence   
---END 


