

CREATE proc [dbo].[spGetSOERPIds]
as
--select DISTINCT ESMErpId fROM tmpDaySummaryAPI WHERE ESMRank='ESM' AND Type IN('LEAVE','Absent','Advanced Leave')
--and not exists(select * from tblmstrperson p join tblroutecalendar r on r.sonodeid=p.NodeID and r.SONodeType=p.NodeType where ESMErpId=p.Code and r.visitdate=convert(date,getdate())
--) 
SELECT SOareaCode AS ESMErpId   FROM [dbo].vwSalesHierarchy a join tblMstrPerson p on a.SONodeid=p.NodeID where  isnull(p.flgSFAUser,0)<>1 and isnull(p.flgActive,0)=1 


--and SOareaCode in('EMP00975','OEMP00140')
--not exists(select * from tblmstrperson p join tblroutecalendar r on r.sonodeid=p.NodeID and r.SONodeType=p.NodeType where SOareaCode=p.Code and r.visitdate=convert(date,getdate())) 
--) 


