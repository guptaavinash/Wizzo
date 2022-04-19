


--spSecUserLogin 'tc-db001','12345','ss','ss','ss','ss'
CREATE  PROCEDURE [dbo].[spSecUserLoginByIMEI] 

	--CREATED BY AK on 15-Jan-06
	--Login Process for user - refer login process flow chart (to be made as on 15-Jan)

	@UserName varChar(50),
	@UserPwd varChar(50),
	@SessionIdNw varChar(100),
	@IPAddress varChar(16),
	@BrwsrVer varChar(20),
	@ScrRsltn varChar(10)

AS

	DECLARE @UserID INT
	DECLARE @UserNodeID INT
	DECLARE @UserNodeType INT
	DECLARE @ActiveStatus TINYINT
	DECLARE @UserFullName varChar(200)
	DECLARE @curLogin CURSOR
	DECLARE @LoginId INT
	DECLARE @LoginIdLoop INT
	DECLARE @SessionIDOld varChar(100)
	DECLARE @PrvIPAddress varChar(16) --Used  in the loop to get the previous IP address
	DECLARE @rtrnIPAddress varChar(16) --Last not including Curent is returned for display
	DECLARE @FlgIPAddress TINYINT
	DECLARE @SameUser TINYINT --0=default - not known; 1=Same User; 2=Different User (By matchine sessionID)
	DECLARE @LoginRslt TINYINT --1=Invalid UserId/Pwd, 2=Duplicate User - @rtrnIPAddress Will come; 3=successful login - create ticket
	DECLARE @RoleId varchar(20)
	DECLARE @flgPasswordChange TINYINT
	Declare @CurrentLastActiveTimeInMin int=0
	Declare @flgReleasingForTesting tinyint=0
	SET @flgPasswordChange=0
	SET @UserID=0
	SET @SameUser=0
	SET @FlgIPAddress=0
	DECLARE @TokenNo VARCHAR(500)
	SET @TokenNo=''
	DECLARE @flgAgreementsigned INT
	set @flgAgreementsigned=0
	DECLARE @IsFiveStarApplicable INT
	SET @IsFiveStarApplicable=1
	--OPEN SYMMETRIC KEY System_password DECRYPTION BY CERTIFICATE Certificate_Password WITH PASSWORD = '2Si3987PnghxJ#KL95234AixST';
	SELECT     @UserID=UserID, @UserNodeID=NodeID, @UserNodeType=NodeType, @ActiveStatus=Active,@IsFiveStarApplicable=IsFiveStarApplicable, @RoleId = RoleId,@flgPasswordChange=PwdStatus,@UserFullName=UserFullName,@CurrentLastActiveTimeInMin=case when CurrentActiveTime is not null then 
	datediff(minute,CurrentActiveTime,GETDATE()) else 10 end,@flgReleasingForTesting=flgReleasingForTesting FROM  tblSecUser WHERE     (UserName = @UserName) AND ([Password]= @UserPwd) AND Active=1
	
	-- CLOSE SYMMETRIC KEY System_password;
	IF @UserID>0
		BEGIN
			
			--	if @RoleId = 3
			--begin
			--	if @CurrentLastActiveTimeInMin<=2
			--	begin
			--		select @CurrentLastActiveTimeInMin as CurrentLastActiveTimeInMin
			--	return 
			--	end
			--	else
			--	begin
			--		select 10 as CurrentLastActiveTimeInMin where 1<>1
			--	end
			--end
			--else
			--	begin
			--		select 10 as CurrentLastActiveTimeInMin where 1<>1
			--	end

			--Code to get the user name to come here
			--SET @UserFullName='Test User'
			SET @curLogin=CURSOR FOR
			SELECT     LoginID, SessionID, IPAddress FROM tblSecUserLogin WHERE (UserID = @UserID) AND (IsSessionEnd = 0) ORDER BY LOGINID DESC
			OPEN @curLogin
			FETCH NEXT FROM @curLogin INTO @LoginIdLoop, @SessionIDOld, @PrvIPAddress
			WHILE @@FETCH_STATUS=0
				BEGIN
					IF @SessionIDOld=@SessionIDNw
						BEGIN 
							PRINT '@SessionIDOld=@SessionIDNw'
							SET @SameUser=1
							SET  @LoginRslt=3
							SET @LoginId=@LoginIdLoop
							DELETE FROM tblSecActiveSessions WHERE UserId=@UserID AND SessionID<>@SessionIDNw
							IF NOT EXISTS (SELECT RowID FROM tblSecActiveSessions WHERE UserId=@UserID AND SessionID=@SessionIDNw)
								BEGIN
									INSERT INTO   tblSecActiveSessions (SessionID, UserID) VALUES(@SessionIDNw, @UserID)
								END
						END
					ELSE
						BEGIN
							IF @SameUser=1
								BEGIN
									UPDATE tblSecUserLogin SET IsSessionEnd=1, Logouttime=GETDATE(), LogOutSrc=2 WHERE LoginID=@LoginID
									DELETE FROM tblSecActiveSessions WHERE SessionID=@SessionIDOld
								END
							IF @FlgIPAddress=0
								BEGIN
									SET @rtrnIPAddress=@PrvIPAddress
									SET @FlgIPAddress=1
								END
						END
					IF @SameUser=0
						BEGIN
							SET @SameUser=2
							SET @LoginRslt=2
						END
				FETCH NEXT FROM @curLogin INTO @LoginIdLoop, @SessionIDOld, @PrvIPAddress
				END
			IF @SameUser=0 --This means that there were no old records for user id in login table so a newentry can now be made
				BEGIN
					DELETE FROM tblSecActiveSessions WHERE UserId=@UserID
					INSERT INTO tblSecUserLogin  (UserID, SessionID, IPAddress, IEVersion, ScrRsltn,LoginTime)  VALUES     (@UserID, @SessionIDNw, @IPAddress,  @BrwsrVer, @ScrRsltn,GETDATE())
					SET @LoginId=@@IDENTITY
					SET @LoginRslt=3
					UPDATE tblsecuser set PwdStatus=1,CurrentActiveTime=GETDATE() where userid=@UserID
				END
		END
	ELSE
		BEGIN
		--select 10 as CurrentLastActiveTimeInMin where 1<>1
			SET @LoginRslt=1
		END
		DECLARE @dATE DATE=GETDATE(),@FYID int=0
--SELECT @FYID=FYID from tblFinancialYear where @dATE between FYStartDate and FYEndDate 

SELECT @TokenNo= C.FCMTokenNo
	FROM tblTCPDA_UserMapMaster A INNER JOIN tblTCPDAMaster B ON A.TCPDAId=B.TCPDAId 
	INNER JOIN [dbo].[tblTCEmpMstr] C ON A.TCEmpID=C.EmpId
	inner join tblTeleCallerEmpMapping D ON C.EmpId=D.EmpId
	WHERE (@dATE BETWEEN A.DateFrom AND A.DateTo) and (@dATE BETWEEN D.FromDate AND D.ToDate) and D.Nodeid=@UserNodeID

	

DECLARE @SiteNodeID int,@flgDRCPUploadType tinyint=2
set @SiteNodeID=@UserNodeID

--IF(@UserNodeType=140)
--BEGIN
--select @SiteNodeID=SiteNodeId,@flgDRCPUploadType=flgDRCPUploadType from vwSalesHierarchy where BranchCode=@UserName
--END
--else IF(@UserNodeType=130)
--BEGIN
--select @flgDRCPUploadType=flgDRCPUploadType from tblCompanySalesStructureDBR where NodeID=@UserNodeID
--end
--5,17,28,26,14,27,32
IF @SiteNodeID in (0) and @UserNodeType in(140,130)
	BEGIN
	  --if @SiteNodeID in (5)
	  --BEGIN
	  --set @flgAgreementsigned=2
	  --END
	  --ELSE
	  --BEGIN
	   set @flgAgreementsigned=1
	  --END
	END
	
Declare @TCDailyId int=0,@StatusId int=0,@currdate date=GETDATE()

	select @TCDailyId=TCDAilyId,@StatusId=StatusId from tblTeleCallerDailyMstr where TCNodeId=@UserNodeID and TCNodeType=@UserNodeType and CallDate=@currdate
SELECT @UserId AS UserId, @LoginRslt AS LoginResult, @LoginID AS LoginID, @SameUser AS SameUser, @rtrnIPAddress AS IPAddress, @UserNodeID As NodeID, @UserNodeType As NodeType, @RoleId As RoleId,@flgPasswordChange AS flgPasswordChange,@FYID AS FYID,1  as IsDistributor,'' AS EmailId,1 as IsDirectExecute,@UserName as UserName,@UserFullName as UserFullName,@TokenNo as TokenNo, @flgAgreementsigned As flgAgreementsigned,@flgDRCPUploadType as flgDRCPUploadType,@IsFiveStarApplicable AS IsFiveStarApplicable, 0 as IsLuckyDraw,@flgReleasingForTesting as flgReleasingForTesting,@TCDailyId as TCDailyId,case when @StatusId=4 then 1 else 0 end as IsCloseCallForTheDay




--select * From tblPDAmaster
