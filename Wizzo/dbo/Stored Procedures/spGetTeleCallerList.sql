
CREATE proc [dbo].[spGetTeleCallerList]
as

select b.UserName,b.Password,TeleCallerName,STUFF((SELECT ',' + CAST(p1.Language AS VARCHAR)
                     
         FROM tblLanguageMaster p1 join tblTelecallerLanguageMapping p2
         on p1.LngID=p2.LanguageId
         WHERE A.TeleCallerId = p2.TeleCallerId
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')  as Language from tblTeleCallerMstr a join tblSecUser b on a.TeleCallerId=b.NodeID
and a.NodeType=b.NodeType
