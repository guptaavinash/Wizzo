CREATE TABLE [dbo].[tblMstrStoreSegment] (
    [StoreSegmentationID] INT          IDENTITY (1, 1) NOT NULL,
    [StoreSegment]        VARCHAR (10) NULL,
    [NodeType]            SMALLINT     CONSTRAINT [DF_tblMstrStoreSegment_NodeType] DEFAULT ((410)) NOT NULL
);

