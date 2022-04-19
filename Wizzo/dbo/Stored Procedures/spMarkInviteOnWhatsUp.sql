
--[spMarkInviteOnWhatsUp]1,'',9810378902,1,'24X7SMS','MsgID:020220ebee174f94a6d393411728bd2b:91981037890:202006261514356438:success'
CREATE proc [dbo].[spMarkInviteOnWhatsUp]
@StoreId int,
@Link varchar(1000),
@WhatsappNumber bigint,
@flgMsgSent tinyint, --1=Msg Sent,2=Not Sent
@Provider varchar(50),
@MsgReturnString varchar(500)
AS
BEGIN
	DECLARE @SenderID VARCHAR(6)
	SELECT @SenderID='AXTSFA'
	--SELECT items from dbo.split('MsgID:020220ebee174f94a6d393411728bd2b:919650826982:202006261514356438:success',':')
	IF @flgMsgSent=1
	BEGIN
		DECLARE @FlgStatus TINYINT
		DECLARE @StatusCode varchar(500)
		DECLARE @MessageId VARCHAR(200)
		

		----IF @Provider='SMSIDEA'
		----BEGIN
		----	IF @MsgReturnString LIKE '%Message_Id%'
		----	BEGIN
		----		SELECT @MessageId=LTRIM(RTRIm(SUBSTRING(@MsgReturnString, PATINDEX('%:%',@MsgReturnString) + 1 , LEN(@MsgReturnString))))
		----		SELECT @StatusCode='Success'
		----		SELECT @FlgStatus=1
		----	END
		----	ELSE
		----	BEGIN
		----		SELECT @FlgStatus=2
		----		SELECT @StatusCode=@MsgReturnString
		----	END

		----	SELECT @SenderID='LTFACE'
		----END
		----ELSE
		IF @Provider='24X7SMS'
		BEGIN
			--SELECT 1
			CREATE TABLE #tmp(Id INT IDENTITY(1,1),Descr VARCHAR(200))

			INSERT INTO #tmp(Descr)
			SELECT items from dbo.split(@MsgReturnString,':')

			--SELECT * FROM #tmp

			IF @MsgReturnString LIKE '%' + CAST(@WhatsappNumber AS VARCHAR) + '%'
			--IF EXISTS(SELECT 1 FROM #tmp WHERE Id=3 AND Descr=RIGHT('91' + CAST(@WhatsappNumber AS VARCHAR),12))
			BEGIN
				--SELECT 2
				
				SELECT @MessageId=Descr FROM #tmp WHERE Id=2
				SELECT @StatusCode='Success'
				SELECT @FlgStatus=1
			END
			ELSE
			BEGIN
				SELECT @FlgStatus=2
				SELECT @StatusCode=@MsgReturnString
			END
			SELECT @SenderID='AXTSFA'
		END

----		INSERT INTO SmsDB..tblOutGoingMsgDetails(SMSTo,Msg,AppType,ServiceProvider,NodeId,NodeType,FlgStatus,FailureMsg,SendTime,MessageID,SenderID,IsRecdPicked,ServiceName, SMSFrom)
----		SELECT @WhatsappNumber SMSTo,
----'Dear Retailer '+StoreName+', LT Foods mein aapka Swagat hai. Kripya Is Sandesh ke Link par Register karein taaki ‘Daawat Products’ ke apne stock ko Mobile ke dwara order kar sake.		'+@Link AS Msg,103 AppType,@Provider ServiceProvider,StoreId,90 AS NodeType,@FlgStatus FlgStatus,@StatusCode FailureMsg,GETDATE() SendTime,@MessageId MessageID, @SenderID SenderID,1 AS IsRecdPicked,'TEMPLATE_BASED' AS ServiceName,'API' AS SMSFrom FROM tblStoreMaster WHERE StoreID=@StoreId

--		INSERT INTO SmsDB..tblOutGoingMsgDetails(SMSTo,Msg,AppType,ServiceProvider,FlgStatus,FailureMsg,SendTime,MessageID,IsRecdPicked,ServiceName, SMSFrom)
--		SELECT @WhatsappNumber SMSTo,
--'Dear Retailer '+StoreName+', LT Foods mein aapka Swagat hai. Kripya Is Sandesh ke Link par Register karein taaki ‘Daawat Products’ ke apne stock ko Mobile ke dwara order kar sake.		'+@Link AS Msg,103 AppType,@Provider ServiceProvider,@FlgStatus FlgStatus,@StatusCode FailureMsg,GETDATE() SendTime,@MessageId MessageID,1 AS IsRecdPicked,'TEMPLATE_BASED' AS ServiceName,'API' AS SMSFrom FROM tblStoreMaster WHERE StoreID=@StoreId

		INSERT INTO SmsDB..tblOutGoingMsgDetails(SMSTo,Msg,AppType,ServiceProvider,FlgStatus,FailureMsg,SendTime,MessageID,IsRecdPicked,ServiceName, SMSFrom,SenderId)
		SELECT @WhatsappNumber SMSTo,
'Dear Retailer '+StoreName+', welcome to Raj Traders WhatsApp system, please click on below link to Register and get latest Product Information and Offer.    '+@Link AS Msg,120 AppType,@Provider ServiceProvider,@FlgStatus FlgStatus,@StatusCode FailureMsg,GETDATE() SendTime,@MessageId MessageID,1 AS IsRecdPicked,'TEMPLATE_BASED' AS ServiceName,'API' AS SMSFrom,@SenderID FROM tblStoreMaster WHERE StoreID=@StoreId


		UPDATE tblStoreMaster SET InviteOnWhatsUpTimeStamp=getdate(),flgInviteonWhatsUp=1  WHERE storeid=@StoreId and ISNULL(flgInviteOnWhatsUp,0)=0 and @flgMsgSent=1
	END
	

	IF @flgMsgSent=2
	BEGIN
		INSERT INTO SmsDB..tblOutGoingMsgDetails(SMSTo,Msg,AppType,ServiceProvider,ServiceName,SenderId)
		SELECT @WhatsappNumber,
'Dear Retailer '+StoreName+', welcome to Raj Traders WhatsApp system, please click on below link to Register and get latest Product Information and Offer.		'+@Link AS Msg,120,@Provider,'TEMPLATE_BASED',@SenderID FROM tblStoreMaster WHERE StoreID=@StoreId
	END
END

