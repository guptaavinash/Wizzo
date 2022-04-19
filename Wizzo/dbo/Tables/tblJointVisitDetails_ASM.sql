CREATE TABLE [dbo].[tblJointVisitDetails_ASM] (
    [JointVisitId]         INT           NOT NULL,
    [JointVisitCode]       VARCHAR (100) NOT NULL,
    [FellowPersonNodeId]   INT           NULL,
    [FellowPersonNodeType] SMALLINT      NULL,
    CONSTRAINT [FK_tblJointVisitDetails_ASM_tblJointVisitMaster_ASM] FOREIGN KEY ([JointVisitId]) REFERENCES [dbo].[tblJointVisitMaster_ASM] ([JointVisitId]) ON DELETE CASCADE ON UPDATE CASCADE
);

