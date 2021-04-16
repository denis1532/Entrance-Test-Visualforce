trigger AppointmentCreationTrigger on Appointment__c (before insert) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            AppointmentCreationTriggerHandler.OnBeforeInsertCheck(Trigger.new);
        }
    }
}
