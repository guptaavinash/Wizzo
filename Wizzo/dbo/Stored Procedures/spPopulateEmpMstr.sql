

CREATE proc [dbo].[spPopulateEmpMstr]
@EmpId int,
@EmpName varchar(100),
@ContactNo	varchar(50),
@EmailId	varchar(50),
@Address varchar(500),
@EmergencyContactNo varchar(50)=null,
@DOB date=null,
@flgActive bit,
@TASSiteNodeId int=1,
@TASSiteNodeType int=160,
@LoginId int
as
begin


Declare @Curr_Date datetime
set @Curr_Date=dbo.fnGetCurrentDateTime()

MERGE tblEmpMstr EmpMstr USING (select @EmpId as EmpId,@EmpName as EmpName, @TASSiteNodeId as TASSiteNodeId
 ,@TASSiteNodeType as TASSiteNodeType,@ContactNo as ContactNo,@Address as Address,@EmailId as EmailId,@EmergencyContactNo as EmergencyContactNo,
 @DOB AS DOB) as EmpMstrSrc
  
ON  EmpMstr.EmpId = EmpMstrSrc.EmpId  
WHEN MATCHED THEN  
  UPDATE  
  SET EmpMstr.EmpName = EmpMstrSrc.EmpName  ,
 EmpMstr.ContactNo = EmpMstrSrc.ContactNo  ,
  EmpMstr.EmailId = EmpMstrSrc.EmailId  ,
  EmpMstr.EmgencyContactNo = EmpMstrSrc.EmergencyContactNo  ,
  
   EmpMstr.DOB = EmpMstrSrc.DOB  ,
 EmpMstr.LoginIDUpd = @LoginId,  
 EmpMstr.TimeStampUpd = @Curr_Date  
WHEN NOT MATCHED BY TARGET THEN  
  INSERT (EmpName,ContactNo,EmailId, EmgencyContactNo,TASSiteNodeId,TASSiteNodeType,
		LoginIDIns, TimestampIns,DOB,Address)  
  VALUES (EmpMstrSrc.EmpName,EmpMstrSrc.ContactNo,EmpMstrSrc.EmailId, EmpMstrSrc.EmergencyContactNo,EmpMstrSrc.TASSiteNodeId,EmpMstrSrc.TASSiteNodeType,
  @LoginId,@Curr_Date,EmpMstrSrc.DOB ,EmpMstrSrc.Address);

  if @EmpId=0
  set @EmpId=SCOPE_IDENTITY()

  select @EmpId as EmpId

end
