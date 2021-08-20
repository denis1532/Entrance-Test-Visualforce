trigger AppointmentTrigger on Appointment__c (before insert) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AppointmentTriggerHandler.OnBeforeInsertCheck(Trigger.new);
        }
    }

}