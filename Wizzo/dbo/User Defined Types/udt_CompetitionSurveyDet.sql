CREATE TYPE [dbo].[udt_CompetitionSurveyDet] AS TABLE (
    [CompetitionProductID] INT        NOT NULL,
    [PriceToRetailerPerKG] FLOAT (53) NULL,
    [PriceToConsumerPerKG] FLOAT (53) NULL);

