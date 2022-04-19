-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpSalesReport_SheetName] 

AS
BEGIN
 Select CONVERT(VARCHAR(100),'Secondary Report') as SheetName, CONVERT(VARCHAR(100),'1') as ColFix,2 as RowFix,1 as MailId,1 AS Ordr INTO #Sheets
	UNION
	Select CONVERT(VARCHAR(100),'PJP Adhirance Report') as SheetName, CONVERT(VARCHAR(100),'1') as ColFix,2 as RowFix,1 as MailId ,2 AS Ordr
	UNION
	Select CONVERT(VARCHAR(100),'Attendance Report') as SheetName, CONVERT(VARCHAR(100),'1') as ColFix,2 as RowFix,1 as MailId,3 AS Ordr 
		UNION
	Select CONVERT(VARCHAR(100),'Brand Visibility Report') as SheetName, CONVERT(VARCHAR(100),'1') as ColFix,2 as RowFix,1 as MailId,4 AS Ordr 
		UNION
	Select CONVERT(VARCHAR(100),'Distributor Stock Report') as SheetName, CONVERT(VARCHAR(100),'1') as ColFix,2 as RowFix,1 as MailId,5 AS Ordr 
	
	SELECT SheetName,ColFix,RowFix,MailId FROM #Sheets ORDER BY Ordr
	DECLARE @strColumnIndexForGrouping VARCHAR(50)=''
	SELECT @strColumnIndexForGrouping='0,1,2,3'
	SELECT @strColumnIndexForGrouping AS strColumnIndexForGrouping


END
