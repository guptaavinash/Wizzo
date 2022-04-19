


Create proc spPopulateTeleCallerDeviceCallLogDetail
@TeleCallingId int,
@StoreId int,
@PhoneNumber varchar(100),
@PartyName varchar(200),
@CallDuration int,
@CallTypeId smallint,
@CallTypeDescr varchar(500),
@CallStartDateTime datetime,
@CallEndDateTime datetime,
@SimSlot varchar(50),
@SimDefaultNumber varchar(50),
@CarrierName varchar(50),
@PDACode varchar(50),
@Sstat varchar(50),
@DialingFrequency tinyint
as
begin

insert into tblTeleCallerDeviceCallLogDetail(TeleCallingId, StoreId, PhoneNumber, PartyName, CallDuration, CallTypeId, CallTypeDescr, CallStartDateTime, CallEndDateTime, SimSlot, SimDefaultNumber, CarrierName, PDACode, Sstat, 
                         DialingFrequency)

values(@TeleCallingId, @StoreId, @PhoneNumber, @PartyName, @CallDuration, @CallTypeId, @CallTypeDescr, @CallStartDateTime, @CallEndDateTime, @SimSlot, @SimDefaultNumber, @CarrierName, @PDACode, @Sstat, 
                         @DialingFrequency)

end