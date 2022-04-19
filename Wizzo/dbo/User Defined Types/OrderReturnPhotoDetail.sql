CREATE TYPE [dbo].[OrderReturnPhotoDetail] AS TABLE (
    [PrdID]          INT           NOT NULL,
    [PhotoName]      VARCHAR (100) NOT NULL,
    [flgDelete]      BIT           NULL,
    [PhotoClickedOn] DATETIME      NULL);

