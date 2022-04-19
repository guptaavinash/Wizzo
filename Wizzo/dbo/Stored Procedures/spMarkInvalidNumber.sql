--select * from tblTeleCallerListForDay where Date='10-Aug-2021' and IsValidContactNo=1 and ContactNo like  '%,%'

CREATE proc [dbo].[spMarkInvalidNumber]
as
begin
Declare @currdate date=dbo.fnGetCurrentDateTime()

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and Len(isnull(ContactNo,''))<7 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and left(ContactNo,1) not in('1','0','2','6','7','8','9') and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate --and ContactNo like '%0000000000%'
and len(ContactNo)<20 and IsValidContactNo=1 and isnumeric(ContactNo)=0


Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate --and ContactNo like '%0000000000%'
and len(ContactNo)<20 and IsValidContactNo=1 and ContactNo like  '%,%'


Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%0000000000%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%1111111111%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%2222222222%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%3333333333%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%4444444444%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%5555555555%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%6666666666%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%7777777777%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%8888888888%'
and len(ContactNo)<20 and IsValidContactNo=1

Update a set IsValidContactNo=0 from tblTeleCallerListForDay a where Date=@currdate and ContactNo like '%9999999999%'
and len(ContactNo)<20 and IsValidContactNo=1

end


