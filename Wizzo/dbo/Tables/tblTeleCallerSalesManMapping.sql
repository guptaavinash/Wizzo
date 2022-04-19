CREATE TABLE [dbo].[tblTeleCallerSalesManMapping] (
    [SoNodeId]     INT      NOT NULL,
    [SoNodeType]   INT      NOT NULL,
    [TCNodeId]     INT      NOT NULL,
    [TCNodeType]   INT      NOT NULL,
    [FromDate]     DATE     NOT NULL,
    [ToDate]       DATE     NOT NULL,
    [LoginIdIns]   INT      NOT NULL,
    [TimeStampIns] DATETIME NOT NULL,
    [LoginIdUpd]   INT      NULL,
    [TimeStampUpd] DATETIME NULL
);

