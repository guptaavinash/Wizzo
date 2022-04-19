

--[spGetRunningQueryResult]97
CREATE proc [dbo].[spGetRunningQueryResult]
@session_id INT=0
as
BEGIN
SELECT db_name(database_id),*
FROM sys.dm_exec_requests requests
CROSS APPLY sys.dm_exec_sql_text (requests.plan_handle) details
WHERE requests.session_id > 50
ORDER BY total_elapsed_time DESC


SELECT SUBSTRING(detail.text, 
requests.statement_start_offset / 2, 
(requests.statement_end_offset - requests.statement_start_offset) / 2)
FROM sys.dm_exec_requests requests
CROSS APPLY sys.dm_exec_sql_text (requests.plan_handle) detail
WHERE requests.session_id =@session_id
END
