






CREATE view [dbo].[vwSalesHierarchy]
as
SELECT      
H1.PHierId AS ZnHierId, Zn.NodeID AS ZnNodeId, Zn.NodeType AS ZnNodeType,Zn.Code as ZoneCode, Zn.Descr AS Zone, H1.HierID AS RegHierId, Reg.NodeID AS RegNodeId, Reg.NodeType AS RegNodeType,Reg.Code as RegCode, Reg.Descr AS Region, 
                         H2.HierID AS ASMAreaHierId, Aa.NodeID AS ASMAreaNodeId, Aa.NodeType AS ASMAreaNodeType, Aa.Descr AS ASMArea,Aa.Code as ASMAreaCode
						
						 --, Aa.NodeID AS ASMAreaNodeId, Aa.NodeType AS ASMAreaNodeType,Aa.Code as ASMareaCode, 
       --                  Aa.Descr AS ASMArea 
						 --, H4.HierID AS SEAreaHierId, SE.NodeID AS SEAreaNodeId, SE.NodeType AS SEAreaNodeType,SE.Code as SEareaCode, 
       --                  SE.Descr AS SEArea
	   , 
						 
						 H3.HierID AS SOAreaHierId, SO.NodeID AS SOAreaNodeId, SO.NodeType AS SOAreaNodeType,SO.UnqCode as SOareaCode, SO.Descr AS SOArea
						 --, H6.HierID AS DBHierId, db.NodeID AS DbNodeId, db.NodeType AS DBNodeType, 
       --                  db.DistributorCode, db.Descr AS DBName
						 , ZSM.Code as ZSMCode, ZSM.Descr as ZSMName
						 , RSM.Code as RSMCode, RSM.Descr as RSMName
						 --, BrM.Code as BrCode, BrM.Descr as BrName
						 , Isnull(ASMN.Code,'Vacant') as ASMCode, Isnull(ASMN.Descr,'Vacant') as ASMName
						 --, TSE.Code as SECode, TSE.Descr as SEName
						  , TSO.Code as SOCode, TSO.Descr as SOName,TSO.NodeId AS SONodeid,TSO.NodeType as SONodeType

						 --SELECT * FROM tblCompanySalesStructureHierarchy
						 --SELECT *
FROM          
                         tblCompanySalesStructureMgnrLvl0 AS Zn INNER JOIN
                         tblCompanySalesStructureHierarchy AS H1 ON Zn.NodeID = H1.PNodeID AND Zn.NodeType = H1.PNodeType INNER JOIN
                         tblCompanySalesStructureMgnrLvl1 AS Reg ON H1.NodeID = Reg.NodeID AND H1.NodeType = Reg.NodeType INNER JOIN
                         tblCompanySalesStructureHierarchy AS H2 ON H1.HierID = H2.PHierId INNER JOIN
                         tblCompanySalesStructureMgnrLvl2 AS Aa ON H2.NodeID = Aa.NodeID AND H2.NodeType = Aa.NodeType INNER JOIN
                         tblCompanySalesStructureHierarchy AS H3 ON H2.HierID = H3.PHierId INNER JOIN
						 tblCompanySalesStructureSprvsnLvl1 AS SO ON H3.NodeID = SO.NodeID AND H3.NodeType = SO.NodeType 
						 left JOIN 
                         tblSalesPersonMapping AS ZnMap
						  INNER JOIN
						  tblMstrPerson AS ZSM  ON ZSM.NodeID = ZnMap.PersonNodeID
						 ON ZnMap.NodeID=Zn.NodeID and ZnMap.NodeType=Zn.NodeType
						 AND (convert(date,getdate()) between ZnMap.FromDate  AND ZnMap.ToDate )
						
						  left JOIN 
                         tblSalesPersonMapping AS RSMMap
						 INNER JOIN
						  tblMstrPerson AS RSM  ON RSM.NodeID = RSMMap.PersonNodeID
						 ON RSMMap.NodeID=Reg.NodeID and (convert(date,getdate()) between RSMMap.FromDate  AND RSMMap.ToDate )

AND RSMMap.NodeType=Reg.NodeType
						 

						 -- 						  INNER JOIN 
       --                  tblSalesPersonMapping AS ZnMap ON ZnMap.NodeID=Zn.NodeID and ZnMap.NodeType=Zn.NodeType
						 --INNER JOIN
						 -- tblMstrPerson AS ZnM  ON ZnM.NodeID = ZnMap.PersonNodeID

						   left JOIN 
                         tblSalesPersonMapping AS ASMMap 
						  INNER JOIN
						  tblMstrPerson AS ASMN  ON ASMN.NodeID = ASMMap.PersonNodeID
						 ON ASMMap.NodeID=Aa.NodeID and ASMMap.NodeType=Aa.NodeType
AND
						   (convert(date,getdate()) between ASMMap.FromDate  AND ASMMap.ToDate )


						
						 --  INNER JOIN 
       --                  tblSalesPersonMapping AS SEMap ON SEMap.NodeID=SE.NodeID and SEMap.NodeType=SE.NodeType
						 --INNER JOIN
						 -- tblMstrPerson AS TSE  ON TSE.NodeID = SEMap.PersonNodeID
						    INNER JOIN 
                         tblSalesPersonMapping AS SoMap ON SOMap.NodeID=SO.NodeID and SOMap.NodeType=SO.NodeType
						 INNER JOIN
						  tblMstrPerson AS TSO  ON TSO.NodeID = SOMap.PersonNodeID

WHERE       
 (convert(date,getdate()) between SOMap.FromDate  AND SOMap.ToDate )
