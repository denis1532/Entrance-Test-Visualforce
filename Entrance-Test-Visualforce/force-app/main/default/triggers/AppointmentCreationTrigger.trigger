trigger AppointmentCreationTrigger on Appointment__c (before insert) {
    AppointmentCreationTriggerHandler handler = new AppointmentCreationTriggerHandler();
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            handler.OnBeforeInsertCheckDate(Trigger.new);
            handler.OnBeforeInsertCheckWorkingHours(Trigger.new);
        }
    }
}