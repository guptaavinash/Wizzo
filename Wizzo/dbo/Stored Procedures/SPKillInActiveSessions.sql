
-- SPKillInActiveSessions '1'
create procEDURE [dbo].[SPKillInActiveSessions]
@LoginStr VARCHAR(500)
AS
BEGIN
	DECLARE @LoginId INT
	
	WHILE PATINDEX('%^%',@LoginStr)>=0
		BEGIN
			IF LEN(@LoginStr)=0
				BEGIN
					BREAK
				END
			
			IF PATINDEX('%^%',@LoginStr)=0
				BEGIN
					SET @LoginId=CAST(@LoginStr AS INTEGER)
					SET @LoginStr=''
					PRINT ' @LoginId --> ' + CAST(@LoginId AS VARCHAR(20))
				END
			ELSE
				BEGIN
					SET @LoginId=CAST(SUBSTRING(@LoginStr,1,PATINDEX('%^%',@LoginStr)-1) AS INTEGER)
					SET @LoginStr=SUBSTRING(@LoginStr,PATINDEX('%^%',@LoginStr)+1,LEN(@LoginStr))
					PRINT ' @LoginId --> ' + CAST(@LoginId AS VARCHAR(20))
				END
			
			UPDATE tblSecUserLogin
			SET Logouttime=dbo.fnGetCurrentDateTime()
			WHERE LoginId=@LoginId
			update tblSecUser set CurrentActiveTime=null where userid=(select top 1 Userid from tblSecUserLogin where loginid=@LoginId)
		END
END
