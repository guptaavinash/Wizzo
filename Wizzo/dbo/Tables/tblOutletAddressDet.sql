CREATE TABLE [dbo].[tblOutletAddressDet] (
    [OutAddID]      INT            IDENTITY (1, 1) NOT NULL,
    [OutAddTypeID]  INT            NOT NULL,
    [StoreID]       INT            NOT NULL,
    [StoreAddress1] VARCHAR (2000) NULL,
    [StoreAddress2] VARCHAR (2000) NULL,
    [Landmark]      VARCHAR (500)  NULL,
    [CityID]        VARCHAR (50)   NULL,
    [City]          VARCHAR (200)  NULL,
    [Pincode]       VARCHAR (50)   NULL,
    [State]         VARCHAR (50)   NULL,
    [BillCompany1]  VARCHAR (200)  NULL,
    [BillCompany2]  VARCHAR (200)  NULL,
    [ContactPerson] VARCHAR (100)  NULL,
    [ContactNo]     VARCHAR (50)   NULL,
    [StateID]       INT            NULL,
    [LocationID]    INT            NULL,
    CONSTRAINT [PK_tblOutletAddressDet] PRIMARY KEY NONCLUSTERED ([OutAddID] ASC),
    CONSTRAINT [FK_tblOutletAddressDet_tblStoreMaster] FOREIGN KEY ([StoreID]) REFERENCES [dbo].[tblStoreMaster] ([StoreID]) ON DELETE CASCADE ON UPDATE CASCADE
);

