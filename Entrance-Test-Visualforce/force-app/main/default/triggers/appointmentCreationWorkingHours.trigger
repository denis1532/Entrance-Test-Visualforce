trigger appointmentCreationWorkingHours on Appointment__c (before insert) {
    /*Time newAppointmentTime = Trigger.new[0].Appointment_Date__c.time();
    
    Integer newAppointmentDuration = (Integer) Trigger.new[0].Duration_in_minutes__c;
    
    List<Appointment__c> appointments = [SELECT Doctor__r.Id, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c, Duration_in_minutes__c
                                         FROM Appointment__c
                                         WHERE Doctor__r.Id = :Trigger.new[0].Doctor__c];
    
    for (Appointment__c appointment : appointments) {
        Integer existingAppointmentDuration = (Integer) appointment.Duration_in_minutes__c;
        Time workingHoursStart = appointment.Doctor__r.Working_Hours_Start__c;
        Time workingHoursEnd = appointment.Doctor__r.Working_Hours_End__c;
        
        if (newAppointmentTime < workingHoursStart || 
            newAppointmentTime.addMinutes(newAppointmentDuration) > workingHoursEnd ) {
                Trigger.new[0].addError('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' + 
                                        'Please, choose another time.');
        }
	}*/
    
    for (Appointment__c newAppointment : Trigger.new) {
    	
        Time newAppointmentTime = newAppointment.Appointment_Date__c.time();
    
        Integer newAppointmentDuration = (Integer) newAppointment.Duration_in_minutes__c;
        
        List<Appointment__c> appointments = [SELECT Doctor__r.Id, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c, Duration_in_minutes__c
                                             FROM Appointment__c
                                             WHERE Doctor__r.Id = :newAppointment.Doctor__c];
        
        for (Appointment__c appointment : appointments) {
            Integer existingAppointmentDuration = (Integer) appointment.Duration_in_minutes__c;
            Time workingHoursStart = appointment.Doctor__r.Working_Hours_Start__c;
            Time workingHoursEnd = appointment.Doctor__r.Working_Hours_End__c;
            
            if (newAppointmentTime < workingHoursStart || 
                newAppointmentTime.addMinutes(newAppointmentDuration) > workingHoursEnd ) {
                    Trigger.new[0].addError('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' + 
                                            'Please, choose another time.');
                }
        }
    }
}