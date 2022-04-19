

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 15-JUn-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpSentWhatAppMessage] 
	@CustomerMobNo BIGINT,
	@CustomerNodeID INT,
	@CustomerNodeType INT,
	@CustomerName VARCHAR(200),
	@Type TINYINT,  --1=Registration Confirmation,2=Suggested Order,3=Order Confirmation
	@OrderID VARCHAR(20)=0, -- Only for type=3
	@LngID INT=1,
	@ComplaintID VARCHAR(20)=0,
	@DlvryDate date='01-Jun-2010'
AS
BEGIN
	IF @CustomerNodeID=0
	BEGIN
		SET @CustomerName='Guest'
		SELECT @CustomerNodeID=StoreID,@CustomerNodeType=90 FROM tblOutletContactDet OC WHERE MobNo=@CustomerMobNo OR alternatewhatsappNo=@CustomerMobNo
		SELECT @CustomerName=ISNULL(FName,'Guest') FROM tblOutletContactDet SM WHERE StoreID=@CustomerNodeID 
	END
	IF ISNULL(@CustomerName,'')=''
	BEGIN
		SELECT @CustomerName=ISNULL(FName,'Guest') FROM tblOutletContactDet SM WHERE StoreID=@CustomerNodeID 
	END
	DECLARE @Text VARCHAR(4000)
	--SELECT @CustomerName
	IF @Type=1
	BEGIN
		DECLARE @RegID VARCHAR(20)='REG'
		SELECT @RegID=RegistrationID FROM tblWhatsAppAPI_RegisteredCustomer WHERE CustomerNodeID=@CustomerNodeID
		--SELECT @Text='Dear *' + @CustomerName + '*, Welcome to LT Foods. You have now successfully registered for the WhatsApp online ordering system for Daawat Rice’. Your registered ID is:' + @RegID + '. Please Type *ORDER* to place the Order Please Type *ISSUE* to raise any Issue And follow instructions on screen'
		--SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka Swagat hai. Aapne ab Daawat WhatsApp Online Order System mein Safaltapurvak register kar liya hai. Aapka Registration ID hai:*' + @RegID + '*.Order dene ke liye kripya *ORDER* Type karein Kisi Issue yaa Mudde ko bataane ke liye *ISSUE* Type karein Aur screen par diye gaye nirdeshon ka palan karein'
		SELECT @Text='Dear *' + @CustomerName + '*, Raj Traders mein aapka swagat hai. Aapne ab Raj Traders WhatsApp Online System mein safaltapurvak register kar liya hai. Aapka Registration ID hai: *' + @RegID + '*.'


	END
	--ELSE IF @Type=2 OR @Type=4  --- Suggested Order / User asked for Order
	--BEGIN
	--	DECLARE @Link VARCHAR(500)='http://www.ltace.com/ltace_dev/PDA/frmOrderPunching_Customer.aspx?strParam=' + CAST(ISNULL(@CustomerNodeID,0) AS VARCHAR)
	--	--SELECT @Text='Dear *' + @CustomerName + '*, Welcome to LT Foods. Kindly click on the link to view suggested stock order. You can order products & view price & Qty. Click on submit order button for order confirmation. ' + @Link + '.'
	--	--SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka Swagat hai. Kripya Sujhaaye gaye stock Order, ko dekhne ke liye Link par click karein. Aap Daawat ke Products Order kar sakte hain, Unka Mulya avam Matra jaan sakte hain. Order ka pushtikaran karne ke liye SUBMIT ORDER ka button click karein. ' + @Link + '.'
	--	SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka swagat hai. Kripya sujhaaye gaye stock order ko dekhne ke liye link par tap kijiye. Aap Daawat ke products order kar sakte hain, unka mulya aur matra jaan sakte hain. Order ka pushtikaran karne ke liye SUBMIT ORDER ka button tap kijiye. ' + @Link + '.'
	--END
	--ELSE IF  @Type=3  --- Order Revert on RTAS
	--BEGIN
	--	--SELECT @Text='Dear *' + @CustomerName + '*, Welcome to LT Foods. Thank you for placing the Order for *Daawat Rice*. Your Order ID is *' + @OrderID + '*. This will be delivered to you by your distributor.'
	--	SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka swagat hai. Daawat Products ka order dene ke liye dhanyawaad. Aapka order ID hai *' + @OrderID + '*. Yeh order aapko aapke distributor ke dwaara ' + CAST(@DlvryDate AS VARCHAR) + ' deliver kiya jaayega'
	--END
	--ELSE IF  @Type=7  --- Order Revert on MTAS
	--BEGIN
	--	--SELECT @Text='Dear *' + @CustomerName + '*, Welcome to LT Foods. Thank you for placing the Order for *Daawat Rice*. Your Order ID is *' + @OrderID + '*. This will be delivered to you by your distributor.'
	--	SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka swaagat hai. Salesman ko *Daawat Products* ka order dene ke liye dhanyawaad.Aapka order ID hai *' + @OrderID + '* Yeh order aapko aapke distributor ke dwaara ' + CAST(@DlvryDate AS VARCHAR) + ' tak deliver kiya jaayega'
	--END
	ELSE IF  @Type=5 --- ISSUE
	BEGIN
		DECLARE @IssueLink VARCHAR(500)='http://www.astixsolutions.com/Hell_Issue/IssueManagement.aspx?mobile=' + CAST(@CustomerMobNo AS VARCHAR(15))
		--SELECT @Text='Dear *' + @CustomerName + '*, Welcome to LT Foods. We are sorry that you had to face problem. Kindly click on the link to register your complaint. We will try to solve the same as early as possible. ' + @IssueLink + '.'
		--SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka Swaagat hai। Humein khed hai ki aapko Samasya ka saamna karna padha. Kripya apni Shikaayat register karne ke liye diye gaye Link ko click karein। Hum jaldi se jaldi ise hal karne ki koshish karenge' + @IssueLink + '.'
		SELECT @Text='Dear *' + @CustomerName + '*, Hell Energy mein aapka swaagat hai. Hamein khed hai ki aapko samasya kaa saamna karna pada. Kripya apni shikaayat register karne ke liye neeche diye gaye Link par tap kijiye. Ham jaldi se jaldi ise hal karne ki koshish karenge ' + @IssueLink + '.'
	END
	ELSE IF  @Type=6 --- ISSUE Revert
	BEGIN
		--DECLARE @ComplaintID INT=0
		--SELECT @Text='Dear *' + @CustomerName + '*, welcome to LT Foods. Your complaint ID is *' + CAST(@ComplaintID AS VARCHAR) + '*. We will try to solve the same at earliest. Thanks you for your time.'
		--SELECT @Text='Dear *' + @CustomerName + '*, LT Foods mein aapka Swaagat hai, Aapki complain ID hai *' + CAST(@ComplaintID AS VARCHAR) + '*.Hum Jaldi se jaldi ise  hal karne ki koshish karenge. Samay dene ke liye dhanyawaad'
		SELECT @Text='Dear *' + @CustomerName + '*, Hell Energy mein aapka swaagat hai. Aapki shikaayat ID hai *' + CAST(@ComplaintID AS VARCHAR) + '*. Hum Jaldi se jaldi ise hal karne ki koshish karenge. Appka samay dene ke liye dhanyawaad'
	END

	DECLARE @ID INT
	INSERT INTO tblWhatsAppAPI_OutgoingMessages(CustomerMobNo,CustomerNodeID,CustomerNodeType,Text,Type,TimestampIns)
	SELECT @CustomerMobNo,@CustomerNodeID,@CustomerNodeType,@Text,@Type,GETDATE()

	SELECT @ID=SCOPE_IDENTITY()

	SELECT ID,CustomerMobNo,Text FROM tblWhatsAppAPI_OutgoingMessages WHERE ISNULL(flgmessageSent,0)=0 AND CustomerMobNo=@CustomerMobNo AND Type=@Type AND ID=@ID
END
