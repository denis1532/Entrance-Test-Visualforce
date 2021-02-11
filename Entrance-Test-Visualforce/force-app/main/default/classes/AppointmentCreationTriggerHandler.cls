public with sharing class AppointmentCreationTriggerHandler {
    
    /* Trigger that restricts appointment creation
     * if a doctor already has an appointment
     * on that date and on that time (plus appointment duration)
     */
    public void OnBeforeInsertCheckDate (List<Appointment__c> record) {
    
        Set<Id> docIds = new Set<Id>();
        
        for (Appointment__c newAppointment : record) {
            if (newAppointment.Doctor__c != null) {
                docIds.add(newAppointment.Doctor__c);
            }
        }
        
        List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c
                                             FROM Appointment__c
                                             WHERE Doctor__r.Id IN :docIds];
        
        // If appointments don't exist, then trigger turns off
        if(appointments.size() == 0) {
            return;
        }
        
        for (Appointment__c newAppointment : record) {
            Datetime newAppointmentDate = newAppointment.Appointment_Date__c;
            
            for (Appointment__c existingAppointment : appointments) {
                Integer existingAppointmentDuration = (Integer) existingAppointment.Duration_in_minutes__c;
                Datetime existingAppointmentDate = existingAppointment.Appointment_Date__c;
                
                if (newAppointmentDate >= existingAppointmentDate && 
                    newAppointmentDate <= existingAppointmentDate.addMinutes(existingAppointmentDuration)) {
                        record[0].addError('Appointment for this doctor on this time already exists. ' + 
                                           'Please, choose another time.');
                }
            }
        }
    }
    
    /* Trigger restrict appointment creation
     * if appointment time is out of doctor's working hours
     * or appointment duration is higher than doctor's workday end
     */
    public void OnBeforeInsertCheckWorkingHours (List<Appointment__c> record) {
        
        Set<Id> docIds = new Set<Id>();
        
        for (Appointment__c newAppointment : record) {
            if (newAppointment.Doctor__c != null) {
                docIds.add(newAppointment.Doctor__c);
            }
        }
        
        List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c
                                             FROM Appointment__c
                                             WHERE Doctor__r.Id IN :docIds];
        
        // If appointments don't exist, then trigger turns off
        if(appointments.size() == 0) {
            return;
        }
        
        for (Appointment__c newAppointment : record) {
            Time newAppointmentTime = newAppointment.Appointment_Date__c.time();
            Integer newAppointmentDuration = (Integer) newAppointment.Duration_in_minutes__c;
            
            for (Appointment__c existingAppointment : appointments) {
                Integer existingAppointmentDuration = (Integer) existingAppointment.Duration_in_minutes__c;
                Time workingHoursStart = existingAppointment.Doctor__r.Working_Hours_Start__c;
                Time workingHoursEnd = existingAppointment.Doctor__r.Working_Hours_End__c;
                
                if (newAppointmentTime < workingHoursStart || 
                    newAppointmentTime.addMinutes(newAppointmentDuration) >= workingHoursEnd ) {
                        record[0].addError('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' + 
                                           'Please, choose another time.');
                }
            }
        }
    }
}