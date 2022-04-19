
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05Jan2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetRequestforOrdersOnMail] 
	
AS
BEGIN
	SELECT RequestID,PDACode,DataDate,EMailID,P.Descr AS PersonName FROM tblOrderSendOnMailRequest R INNER JOIN tblMstrPerson P ON P.NodeID=R.PersonNodeID AND P.NodeType=R.PersonNodeType WHERE ISNULL(flgSendStatus,0)=0 AND datadate<>'1900-01-01'
END
