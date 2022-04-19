CREATE TABLE [dbo].[tblPrdMstrTransactionUOMConfig] (
    [PrdId]               INT     NOT NULL,
    [UOMID]               INT     NOT NULL,
    [flgDistOrder]        TINYINT NOT NULL,
    [flgDistInv]          TINYINT NOT NULL,
    [flgStoreCheck]       TINYINT NOT NULL,
    [flgRetailUnit]       TINYINT NOT NULL,
    [flgTransactionData]  TINYINT NOT NULL,
    [flgDistributorCheck] TINYINT NULL
);

