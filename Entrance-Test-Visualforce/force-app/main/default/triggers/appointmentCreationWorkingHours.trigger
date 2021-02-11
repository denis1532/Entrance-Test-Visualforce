trigger appointmentCreationWorkingHours on Appointment__c (before insert) {
    /* Trigger restrict appointment creation
     * if appointment time is out of doctor's working hours
     * or appointment duration is higher than doctor's workday end
     */
    Set<Id> docIds = new Set<Id>();
    
    for (Appointment__c newAppointment : Trigger.new) {
        if (newAppointment.Doctor__c != null) {
        	docIds.add(newAppointment.Doctor__c);
        }
    }
    
    List<Appointment__c> appointments = [SELECT Doctor__r.Id, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c, Duration_in_minutes__c
                                         FROM Appointment__c
                                         WHERE Doctor__r.Id IN :docIds];
	
    // If appointments don't exist, then trigger turns off
    if(appointments.size() == 0) {
        return;
    }
    
    for (Appointment__c newAppointment : Trigger.new) {
        Time newAppointmentTime = newAppointment.Appointment_Date__c.time();
        Integer newAppointmentDuration = (Integer) newAppointment.Duration_in_minutes__c;
        
        for (Appointment__c existingAppointment : appointments) {
            Integer existingAppointmentDuration = (Integer) existingAppointment.Duration_in_minutes__c;
            Time workingHoursStart = existingAppointment.Doctor__r.Working_Hours_Start__c;
            Time workingHoursEnd = existingAppointment.Doctor__r.Working_Hours_End__c;
            
            if (newAppointmentTime < workingHoursStart || 
                newAppointmentTime.addMinutes(newAppointmentDuration) > workingHoursEnd ) {
                    Trigger.new[0].addError('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' + 
                                            'Please, choose another time.');
			}
        }
    }
}