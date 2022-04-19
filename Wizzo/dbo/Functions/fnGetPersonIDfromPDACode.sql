

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetPersonIDfromPDACode] 
(
	@PDACode VARCHAR(50)
)
RETURNS @Person TABLE
(
	PersonID INT,
	PersonType SMALLINT
)
AS
BEGIN
	DECLARE @asOf DATETIMEOFFSET = GETDATE() AT TIME ZONE 'UTC' 
	DECLARE @PersonID INT

	INSERT INTO @Person
	SELECT P.NodeID,P.NodeType FROM tblMstrPerson P INNER JOIN tblPDACodeMapping U ON U.PersonID=P.NodeID WHERE U.PDACode=@PDACode AND flgActive=1
	UNION
	SELECT P.NodeID,P.NodeType FROM tblMstrPerson P INNER JOIN tblPDACodeMapping_History U ON U.PersonID=P.NodeID WHERE U.PDACode=@PDACode AND flgActive=1

	


	RETURN 
END
