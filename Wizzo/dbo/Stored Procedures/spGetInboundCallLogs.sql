-- [spGetInboundCallLogs] 'tc-db001'
CREATE Procedure [dbo].[spGetInboundCallLogs]
@agentId varchar(50)
AS
select top 1 InboundNo,ucid,agentId into #tblGetInboundCalls from [tblInboundCalls] where agentId=@agentId and CallTime>=DATEADD(ss,-10,getdate()) and flgCallAttend=0

UPDate [tblInboundCalls] SET flgCallAttend=1  where agentId=@agentId and flgCallAttend=0

select InboundNo,ucid,agentId FROM #tblGetInboundCalls
