trigger appointmentCreation on Appointment__c (before insert) {
    /*Datetime newAppointmentDate = Trigger.new[0].Appointment_Date__c;
    
    List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c
                                         FROM Appointment__c
                                         WHERE Doctor__r.Id = :Trigger.new[0].Doctor__c];
    
    for (Appointment__c appointment : appointments) {
        Integer existingAppointmentDuration = (Integer) appointment.Duration_in_minutes__c;
		Datetime existingAppointmentDate = appointment.Appointment_Date__c;
        
		if (newAppointmentDate >= existingAppointmentDate && 
            newAppointmentDate <= existingAppointmentDate.addMinutes(existingAppointmentDuration)) {
            Trigger.new[0].addError('Appointment for this doctor on this time already exists. ' + 
                                    'Please, choose another time.');
        }
	}*/
    
    for (Appointment__c newAppointment : Trigger.new) {
        
        Datetime newAppointmentDate = newAppointment.Appointment_Date__c;
        
        List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c
                                             FROM Appointment__c
                                             WHERE Doctor__r.Id = :newAppointment.Doctor__c];
        
        for (Appointment__c appointment : appointments) {
            Integer existingAppointmentDuration = (Integer) appointment.Duration_in_minutes__c;
            Datetime existingAppointmentDate = appointment.Appointment_Date__c;
            
            if (newAppointmentDate >= existingAppointmentDate && 
                newAppointmentDate <= existingAppointmentDate.addMinutes(existingAppointmentDuration)) {
                    Trigger.new[0].addError('Appointment for this doctor on this time already exists. ' + 
                                            'Please, choose another time.');
			}
        }
    }
}