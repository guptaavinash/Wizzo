CREATE TABLE [dbo].[tblSchemeCalculationTypeMstr] (
    [SchemeCalculationTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [SchemeCalculationType]   VARCHAR (100) NOT NULL,
    [flgActive]               TINYINT       DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([SchemeCalculationTypeID] ASC)
);

