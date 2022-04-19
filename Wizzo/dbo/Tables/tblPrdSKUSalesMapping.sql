CREATE TABLE [dbo].[tblPrdSKUSalesMapping] (
    [SKUNodeId]                        INT              NOT NULL,
    [SKUNodeType]                      INT              NOT NULL,
    [SalesNodeType]                    SMALLINT         NULL,
    [PrcLocationId1]                   INT              NOT NULL,
    [TaxLocationId1]                   INT              NULL,
    [PrcLocationId]                    INT              NULL,
    [TaxLocationId]                    INT              NULL,
    [UOMID]                            INT              NOT NULL,
    [BusinessSegmentId]                TINYINT          NULL,
    [MRP]                              [dbo].[Amount]   NULL,
    [RetMarginPer]                     DECIMAL (18, 10) NULL,
    [Tax]                              DECIMAL (18, 2)  NULL,
    [StandardRate]                     DECIMAL (18, 10) NULL,
    [StandardRateBeforeTax]            AS               ([StandardRate]/((1)+[Tax]/(100))),
    [StandardTax]                      AS               (([StandardRate]/((1)+[Tax]/(100)))*([TAx]/(100))),
    [FromDate]                         DATE             NOT NULL,
    [ToDate]                           DATE             NOT NULL,
    [DistributorMarginPer]             DECIMAL (18, 10) NULL,
    [DistributorStandardRate]          DECIMAL (18, 10) NULL,
    [DistributorStandardRateBeforeTax] AS               ([DistributorStandardRate]/((1)+[Tax]/(100)))
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPrdSKUSalesMapping]
    ON [dbo].[tblPrdSKUSalesMapping]([PrcLocationId] ASC, [UOMID] ASC, [FromDate] DESC, [ToDate] DESC);


GO
CREATE NONCLUSTERED INDEX [indx_tblPrdSKUSalesMapping_Frodate_todate]
    ON [dbo].[tblPrdSKUSalesMapping]([FromDate] ASC, [ToDate] ASC)
    INCLUDE([SKUNodeId], [SKUNodeType], [PrcLocationId], [UOMID], [MRP], [RetMarginPer], [Tax], [StandardRate], [StandardRateBeforeTax], [StandardTax]);

