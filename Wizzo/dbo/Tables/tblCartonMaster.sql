CREATE TABLE [dbo].[tblCartonMaster] (
    [CartonID]         INT              IDENTITY (1, 1) NOT NULL,
    [StoreID]          INT              NULL,
    [OrderID]          INT              NULL,
    [CartonCode]       VARCHAR (200)    NULL,
    [CategoryID]       INT              NULL,
    [UOMType]          VARCHAR (50)     NULL,
    [NoOfCarton]       INT              NULL,
    [TotalExpectedQty] INT              NULL,
    [TotalActualQty]   INT              NULL,
    [CartonDiscount]   NUMERIC (22, 18) NULL,
    [FileSetID]        INT              NULL,
    CONSTRAINT [PK_tblCartonMaster] PRIMARY KEY CLUSTERED ([CartonID] ASC)
);

