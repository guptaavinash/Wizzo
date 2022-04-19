﻿


CREATE proc [dbo].[spGetReasonMstr] --1
@flgOrderCancel TINYINT=0
as

IF @flgOrderCancel=0
SELECT        ReasonCodeID, 
--STRCT_CODE, REASNCODE_LVL1, REASNCODE_LVL1NAME, REASNCODE_LVL2, REASNCODE_LVL2NAME, REASNCODE_LVL3, REASNCODE_LVL3NAME, REASNCODE_LVL4, 
--                         REASNCODE_LVL4NAME, 
						 REASNCODE_LVL1NAME, REASNCODE_LVL2NAME,REASNFOR,REASNCODE_LVL2NAME AS REASONDESCR
FROM            tblCFRReasonCodeMstr
order by REASNFOR,REASNCODE_LVL1NAME,REASNCODE_LVL2NAME
ELSE
SELECT        ReasonCodeID, 
--STRCT_CODE, REASNCODE_LVL1, REASNCODE_LVL1NAME, REASNCODE_LVL2, REASNCODE_LVL2NAME, REASNCODE_LVL3, REASNCODE_LVL3NAME, REASNCODE_LVL4, 
--                         REASNCODE_LVL4NAME, 
						 REASNCODE_LVL1NAME, REASNCODE_LVL2NAME,REASNFOR,REASNCODE_LVL2NAME AS REASONDESCR
FROM            tblCFRReasonCodeMstr WHERE flgOrderCancel=1
order by reasonCodeID ,REASNCODE_LVL2NAME



