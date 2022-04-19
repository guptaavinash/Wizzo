
CREATE   FUNCTION [dbo].[ConvertFirstLetterinCapital](@Text VARCHAR(5000)) 
RETURNS VARCHAR(5000) AS 
BEGIN
DECLARE @Index INT;
DECLARE @FirstChar CHAR(1);
DECLARE @LastChar CHAR(1);
DECLARE @String VARCHAR(5000);
SET @String = LOWER(@Text);
SET @Index = 1;
WHILE @Index <= LEN(@Text)
BEGIN
    SET @FirstChar = SUBSTRING(@Text, @Index, 1);
    SET @LastChar = CASE
                        WHEN @Index = 1
                        THEN ' '
                        ELSE SUBSTRING(@Text, @Index - 1, 1)
                    END;
    IF @LastChar IN(' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(', '#', '*', '$', '@')
        BEGIN
            IF @FirstChar != ''''
                OR UPPER(@FirstChar) != 'S'
                SET @String = STUFF(@String, @Index, 1, UPPER(@FirstChar));
    END;
    SET @Index = @Index + 1;
END;
RETURN @String;
END;
