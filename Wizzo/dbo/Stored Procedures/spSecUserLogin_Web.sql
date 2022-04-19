
--spSecUserLogin 'astix','AX1234','ss','ss','ss','ss'
CREATE  PROCEDURE [dbo].[spSecUserLogin_Web] 

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
	SET @flgPasswordChange=0
	SET @UserID=0
	SET @SameUser=0
	SET @FlgIPAddress=0
	DECLARE @PersonName VARCHAR(200)


	SELECT     @UserID=UserID, @UserNodeID=NodeID, @UserNodeType=NodeType, @ActiveStatus=Active, @RoleId = RoleId,@flgPasswordChange=PwdStatus FROM  tblSecUser WHERE     (UserName = @UserName) AND ([Password] = @UserPwd) AND Active=1
	
	IF @RoleId in(1,5,7) -- Admin
		SELECT @PersonName=@UserName
	ELSE
		SELECT @PersonName=ISNULL(Descr,'NA') FROM tblMstrPerson WHERE NodeID=@UserNodeID AND NodeType=@UserNodeType
	
	IF @UserID>0
		BEGIN
			--Code to get the user name to come here
			SET @UserFullName='Test User'
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
									UPDATE tblSecUserLogin SET IsSessionEnd=1, Logouttime=GetDate(), LogOutSrc=2 WHERE LoginID=@LoginID
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
					INSERT INTO tblSecUserLogin  (UserID, SessionID, IPAddress, IEVersion, ScrRsltn)  VALUES     (@UserID, @SessionIDNw, @IPAddress,  @BrwsrVer, @ScrRsltn)
					SET @LoginId=@@IDENTITY
					SET @LoginRslt=3
					UPDATE tblsecuser set PwdStatus=1 where userid=@UserID
				END
		END
	ELSE
		BEGIN
			SET @LoginRslt=1
		END
		DECLARE @FYID int,@DistNodeType int

		select @DistNodeType=NodeType from tblPMstNodeTypes where DetTable='tblDBRSalesStructureDBR'

DECLARE @dATE DATE=GETDATE()
SELECT @FYID=FYID from tblFinancialYear where @dATE between FYStartDate and FYEndDate 


;with ashcte as(
SELECT      DHNodeId as   DBRNodeID, convert(int,DHNodeType) as DBRNodeType, SHNodeID, convert(int,SHNodeType) as SHNodeType
FROM            tblCompanySalesStructure_DistributorMapping
WHERE        (DHNodeID = @UserNodeID) AND (DHNodeType = @UserNodeType)
and @dATE between FromDate and ToDate
union all
SELECT        B.PNodeID, B.PNodeType as DHNodeType, SHNodeID, convert(int,SHNodeType) as SHNodeType
FROM            tblCompanySalesStructure_DistributorMapping A join tblCompanySalesStructureHierarchy B
ON A.DHNodeId=B.NodeId and A.DHNodeType=B.NodeType
WHERE        (B.PNodeID = @UserNodeID) AND (B.PNodeType = @UserNodeType)
and @dATE between FromDate and ToDate
UNION ALL
select b.DBRNodeID,b.DBRNodeType,a.PnodeId,a.PNodeType from tblCompanySalesStructureHierarchy A join ashcte B
ON B.SHNodeId=A.NodeId
and B.SHNodeType=A.NodeType WHERE isnull(a.PnodeId,0)<>0 )
select DISTINCT A.*,B.Level INTO #Hirchy from ashcte A join tblPMstNodeTypes B on A.SHNodeType=B.NodeType where HierTypeId=2


Declare @EmailId varchar(500)=''
select @EmailId=@EmailId+ISNULL(PersonEmailID,'')+',' from #Hirchy A join tblsalespersonmapping B on A.SHNodeID=B.NodeId and A.SHNodeType=B.NodeType
and @dATE between B.fromdate and B.todate
join tblMstrPerson C on B.PersonNodeId=C.NodeId and b.PersonType=c.NodeType
WHERE ISNULL(PersonEmailID,'')<>''

--if @EmailId<>''
--set @EmailId=@EmailId+'operations@tjuk.in,f.dev@tjuk.in'
--else
set @EmailId='varun@astixsolutions.com,ashwani@astixsolutions.com'


SELECT @UserId AS UserId, @LoginRslt AS LoginResult, @LoginID AS LoginID, @SameUser AS SameUser, @rtrnIPAddress AS IPAddress, @UserNodeID As NodeID, @UserNodeType As NodeType, @RoleId As RoleId,@flgPasswordChange AS flgPasswordChange,@FYID AS FYID,case when @DistNodeType=@UserNodeType then 1 else 0 end as IsDistributor,@EmailId AS EmailId,1 as IsDirectExecute,@PersonName AS PersonName,@FYID as FYID

----SELECT      Descr AS DBName,  DlvryWeeklyOffDay, flgHasSFAOrders, flgDirectOrder, flgSFABackupOrder, flgSampleOrder, flgComplementaryOrder, flgOrderFromSupplier, flgSingleVehicleOperation, flgWillGenerateInvOnlyAfterPicklist, 
----                         flgWillGenerateInvOnlyBeforePicklist, flgOrderInvoicingDirectProcessing, flgAssumeInvoicedQtyIsDelivered, flgWillManageGSTRecon, flgWillManageAccRecvbls, flgBatchWiseTrns, flgAllowOthrCmpPrds,flgOperationalLevel,
----						 (select count(*) from [dbo].[tblDBRLocalTaxInfo] where Dbrnodeid=@UserNodeID and DbrNodeType=@UserNodeType) as flgCessApplicable
----FROM            tblDBRSalesStructureDBR
----WHERE        (NodeID = @UserNodeID) AND (NodeType = @UserNodeType)
----select HolidayDate,HolidayDescr,flgMarketVisit,flgDlvry from [dbo].[tblDistributorHolidayMstr] where HolidayDate between DateAdd(dd,-10,Getdate()) and DateAdd(dd,180,Getdate()) and DistNodeId=@UserNodeID and DistNodeType=@UserNodeType



--if @UserNodeType=150
--exec spUpdateStoreAccountStatus_Current @UserNodeID,@UserNodeType




