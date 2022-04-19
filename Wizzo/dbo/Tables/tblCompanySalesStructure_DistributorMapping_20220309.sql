CREATE TABLE [dbo].[tblCompanySalesStructure_DistributorMapping_20220309] (
    [DHNodeID]     INT           NOT NULL,
    [DHNodeType]   INT           NOT NULL,
    [SHNodeID]     INT           NOT NULL,
    [SHNodeType]   INT           NOT NULL,
    [TimestampIns] SMALLDATETIME NULL,
    [LoginIDIns]   INT           NULL,
    [FromDate]     DATE          NOT NULL,
    [ToDate]       DATE          NOT NULL,
    [flgSup]       TINYINT       NULL
);

