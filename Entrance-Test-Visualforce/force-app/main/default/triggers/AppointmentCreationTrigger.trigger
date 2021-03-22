trigger AppointmentCreationTrigger on Appointment__c (before insert) {
    AppointmentCreationTriggerHandler handler = new AppointmentCreationTriggerHandler();

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            handler.OnBeforeInsertCheck(Trigger.new);
        }
    }
}
