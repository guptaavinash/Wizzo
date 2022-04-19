CREATE TABLE [dbo].[tblRetailerSKUKWiseTarget] (
    [StoreId]       INT             NOT NULL,
    [SkuNodeId]     INT             NOT NULL,
    [SkuNodeType]   INT             NOT NULL,
    [MonthVal]      INT             NOT NULL,
    [YearVal]       INT             NOT NULL,
    [TargetValue]   NUMERIC (18, 6) NOT NULL,
    [FileSetIdIns]  BIGINT          DEFAULT ((0)) NOT NULL,
    [TimeStampIns]  DATETIME        DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd]  BIGINT          NULL,
    [TimeStampUpd]  DATETIME        NULL,
    [MonthlyTarget] NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblRetailerSKUKWiseTarget] PRIMARY KEY CLUSTERED ([StoreId] ASC, [SkuNodeId] ASC, [SkuNodeType] ASC, [MonthVal] ASC, [YearVal] ASC)
);

