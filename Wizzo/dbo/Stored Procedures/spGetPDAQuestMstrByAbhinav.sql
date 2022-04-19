  
      
  -- [spGetPDAQuestMstr]2 ,'352801088236109'    
Create PROCEDURE [dbo].[spGetPDAQuestMstrByAbhinav] --1         
@ApplicationID int    ,  
@PDACode VARCHAR(50)        
AS          
BEGIN  
--DECLARE @DeviceID INT        

 --SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINo OR PDA_IMEI_Sec=@IMEINo 
-- PRINT '@DeviceID=' + CAST(@DeviceID AS VARCHAR) 
 


 DECLARE @ChannelID INT,@ChannelNodeType SMALLINT ,@PersonNodeID INT,@PersonType SMALLINT
 SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

 PRINT '@@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)
 PRINT '@@PersonType=' + CAST(@PersonType AS VARCHAR) 



  SELECT @ChannelID=SM.ChannelID,@ChannelNodeType=O.NodeType,@PersonNodeID=P.PersonNodeID,@PersonType=P.PersonType
  FROM tblSalesPersonMapping P   

  --INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonNodeID AND M.PersonType=P.PersonType         

  --INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID  

  INNER JOIN tblSalesHierChannelMapping SM ON SM.SalesStructureNodID=P.NodeID AND SM.SalesStructureNodType=P.NodeType  

  INNER JOIN tblMstrChannel O ON O.ChannelID=SM.ChannelID        

 WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType     

 AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))   

  PRINT '@PersonType=' + CAST(@PersonType AS VARCHAR)
  PRINT '@@ChannelID=' + CAST(@ChannelID AS VARCHAR)

  IF @PersonType=210
  BEGIN
	Select P.QuestID,ISNULL(QuestCode,'0') QuestCode,QuestDesc,QuestType,AnsControlType,AsnControlInputTypeID,ISNULL(AnsControlIntputTypeMinLength,0) AnsControlIntputTypeMinLength,ISNULL(AnsControlInputTypeMaxLength,0) AnsControlInputTypeMaxLength,ISNULL(AnswerHint,'N/A') AnswerHint,ISNULL(AnsMustRequiredFlg,0) AnsMustRequiredFlg,ISNULL(QuestBundleFlg,0) QuestBundleFlg,P.ApplicationTypeID,Sequence,M.flgNewStore,M.flgStoreValidation ,M.flgDSMVisitFeedback,M.flgStoreVisitFeedback,M.flgDSMOverAllFeedback
	
	from tblDynamic_PDAQuestMstr P INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=P.QuestID
	Where ActiveQuest=1 AND M.ApplicationTypeID=@ApplicationID  Order By Sequence ASC 

	SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,P.QuestID ,'0-' + CAST(ISNULL(@ChannelID,0) AS VARCHAR) + '-' + CAST(ISNULL(@ChannelNodeType,0) AS VARCHAR)  OptionID,  
CASE ISNULL(@ChannelID,0) WHEN 0 THEN 0 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 2 END SectionCount, M.flgNewStore,M.flgStoreValidation   
 FROM         tblDynamic_PDAQuestMstr P INNER JOIN            
                       [dbo].[tblDynamic_PDAQuestGrpMapping] ON P.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID
					  INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=P.QuestID
					   Where P.ActiveQuest=1   and  P.QuestID=1   AND M.ApplicationTypeID =@ApplicationID
  END
  ELSE
  BEGIN
	PRINT 'ASDD'
	Select P.QuestID,ISNULL(QuestCode,'0') QuestCode,QuestDesc,QuestType,AnsControlType,AsnControlInputTypeID,ISNULL(AnsControlIntputTypeMinLength,0) AnsControlIntputTypeMinLength,ISNULL(AnsControlInputTypeMaxLength,0) AnsControlInputTypeMaxLength,ISNULL(AnswerHint,'N/A') AnswerHint,ISNULL(AnsMustRequiredFlg,0) AnsMustRequiredFlg,ISNULL(QuestBundleFlg,0) QuestBundleFlg,P.ApplicationTypeID,Sequence from tblDynamic_PDAQuestMstr P
	INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=P.QuestID
	Where ActiveQuest=1 AND M.ApplicationTypeID =@ApplicationID  Order By Sequence ASC 

	SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,tblDynamic_PDAQuestMstr.QuestID ,'0-' + CAST(ISNULL(@ChannelID,0) AS VARCHAR) + '-' + CAST(ISNULL(@ChannelNodeType,0) AS VARCHAR)  OptionID,  
CASE ISNULL(@ChannelID,0) WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 3 WHEN 3 THEN 2 END SectionCount   
 

FROM         tblDynamic_PDAQuestMstr INNER JOIN            

                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON tblDynamic_PDAQuestMstr.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID 
					  INNER JOIN tblDynamic_ApplicationQuestMappingMstr M ON M.QuestID=tblDynamic_PDAQuestMstr.QuestID
					  Where tblDynamic_PDAQuestMstr.ActiveQuest=1   and  tblDynamic_PDAQuestMstr.QuestID=1   AND M.ApplicationTypeID =@ApplicationID 
  END
           

        
----Select * from tblDynamic_PDAQuestMstr Where ActiveQuest=1  Order By Sequence ASC        
  
----SELECT     [tblDynamic_PDAQuestGrpMapping].GrpQuestID,tblDynamic_PDAQuestMstr.QuestID  
                     
----FROM         tblDynamic_PDAQuestMstr INNER JOIN          
----                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON tblDynamic_PDAQuestMstr.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID Where tblDynamic_PDAQuestMstr.ActiveQuest=1   and  tblDynamic_PDAQuestMstr.QuestID=1  --This is for trade Chanel for which office offline store will show products     
                        
SELECT  ROW_NUMBER() OVER(ORDER BY tblDynamic_PDAQuestMstr.QuestID) AS ID, [tblDynamic_PDAQuestGrpMapping].GrpQuestID,tblDynamic_PDAQuestMstr.QuestID , tblDynamic_PDAQuestMstr.QuestDesc
                     
FROM         tblDynamic_PDAQuestMstr INNER JOIN          
                      [dbo].[tblDynamic_PDAQuestGrpMapping] ON tblDynamic_PDAQuestMstr.QuestID=[tblDynamic_PDAQuestGrpMapping].QuestID Where tblDynamic_PDAQuestMstr.ActiveQuest=1   and  tblDynamic_PDAQuestMstr.QuestID IN  (8,2,3,4,6)--- (3,7,1,4,5,8,9)	    --Store Name Question             
           
  
   
   --Delete  FROM [tblDynamic_PDAQuestGrpMapping] where QuestId=6 And (GRPQuestID =107 OR GRPQuestID=117)

  -- SELECT *  FROM [tblDynamic_PDAQuestGrpMapping] where QuestId=6 And SectionNo in (2,3)
END          
