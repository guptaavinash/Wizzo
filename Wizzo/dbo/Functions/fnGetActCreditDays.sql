



CREATE function [dbo].[fnGetActCreditDays](@CreditPeriodType tinyint,@Date date,@CreditDays smallint)
returns smallint
as
begin
	Declare @ActCreditDays smallint
	if @CreditPeriodType=1
	begin
		set @ActCreditDays= @CreditDays
	end
	else if @CreditPeriodType=2
	begin
		set @ActCreditDays=   (7-datepart(dw,@Date))+@CreditDays
	end
	else if @CreditPeriodType=3  and day(@Date)<=15
	begin
		--if day(@Date)<=15
		set @ActCreditDays=   (15-day(@Date)) +@CreditDays
		--else if day(@Date)>15
		--set @ActCreditDays=   (Day(DateAdd(dd,-1,DateAdd(mm,1,convert(datetime,convert(varchar(6),@Date,112)+'01'))))-day(@Date)) +@CreditDays
	end
	else if @CreditPeriodType=4 or (@CreditPeriodType=3  and day(@Date)>15)
	begin
		set @ActCreditDays=   (Day(DateAdd(dd,-1,DateAdd(mm,1,convert(datetime,convert(varchar(6),@Date,112)+'01'))))-day(@Date)) +@CreditDays
	end
	ELSE 
	begin
	set @ActCreditDays=   0
	end
	return @ActCreditDays
	
end 

