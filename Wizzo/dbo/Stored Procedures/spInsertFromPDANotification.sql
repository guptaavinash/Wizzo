


CREATE PROCEDURE [dbo].[spInsertFromPDANotification]  -- This will be called in  spForPDAGetRouteList to check the registration in mstr table if not exist           

@PDACode VARCHAR(50),                

@strDate DateTime,               

@AppVersionID INT,              

@RegistrationID Varchar(300)              

AS              

DECLARE @Date DATETIME, @DefaultRouteID INT, @ChannelID VARCHAR(100)  ,@ApplicationTypeId INT              

Select @Date = @strDate          

                

DECLARE @DeviceID INT, @ApplicationType INT,@GCMApplicationAutoID INT,@chkIMEIExistOrNot INT     



	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber OR PDA_IMEI_Sec=@IMENumber



	SELECT @ApplicationTypeId=ApplicationType 

	FROM tblVersionMstr WHERE  VersionID= @AppVersionID



	SELECT @GCMApplicationAutoID= GCMApplicationAutoID FROM [tbl_GCMApplicationRegistration_Mstr]  WHERE  tbl_GCMApplicationRegistration_Mstr.GCMApplicationType=@ApplicationTypeId

		

	Set @chkIMEIExistOrNot= (select Count(PDACode) from tbl_PDAGCM_Mstr where PDACode=@PDACode AND AppVersionID=@AppVersionID)          

	--PRINT '@chkIMEIExistOrNot'          

	--PRINT @chkIMEIExistOrNot          

               

	if(@chkIMEIExistOrNot=0)                

	 BEGIN                    

		INSERT INTO  tbl_PDAGCM_Mstr (PDACode,RegistrationID,GCMApplicationAutoID,AppVersionID) values(@DeviceID,@RegistrationID,@GCMApplicationAutoID,@AppVersionID)                   

	 END                  

	ELSE              

	 BEGIN              

		UPDATE tbl_PDAGCM_Mstr SET RegistrationID=@RegistrationID, GCMApplicationAutoID=@GCMApplicationAutoID,AppVersionID=@AppVersionID WHERE PDACode=@DeviceID  AND AppVersionID=@AppVersionID             

	 END   



      

              

                     

  

