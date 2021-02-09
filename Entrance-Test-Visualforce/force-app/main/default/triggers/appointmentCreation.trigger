trigger appointmentCreation on Appointment__c (before insert) {
    /*** Trigger, working with only one record ***/
    
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
    
    /*** Trigger, working with several records ***/
    /*for (Appointment__c newAppointment : Trigger.new) {
        
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
    }*/
    
    /*** Trigger that meets limits conditions ***/
    Set<Id> docIds = new Set<Id>();
    
    for (Appointment__c newAppointment : Trigger.new) {
        if (newAppointment.Doctor__c != null) {
        	docIds.add(newAppointment.Doctor__c);
        }
    }
    
    List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c
                                         FROM Appointment__c
                                         WHERE Doctor__r.Id IN :docIds];
	
    // If appointments don't exist, then trigger turns off
    if(appointments.size() == 0) {
        return;
    }
    
    for (Appointment__c newAppointment : Trigger.new) {
        Datetime newAppointmentDate = newAppointment.Appointment_Date__c;
        
        for (Appointment__c existingAppointment : appointments) {
            Integer existingAppointmentDuration = (Integer) existingAppointment.Duration_in_minutes__c;
            Datetime existingAppointmentDate = existingAppointment.Appointment_Date__c;
            
            if (newAppointmentDate >= existingAppointmentDate && 
                newAppointmentDate <= existingAppointmentDate.addMinutes(existingAppointmentDuration)) {
                    Trigger.new[0].addError('Appointment for this doctor on this time already exists. ' + 
                                            'Please, choose another time.');
			}
        }
    }
    
    /*for (Appointment__c appointment : Trigger.new) {
        Datetime newAppointmentDate = appointment.Appointment_Date__c;
        
        system.debug('8' + newAppointmentDate);
        
        Decimal existingAppointmentDuration = existingDurationMap.get(appointment.Duration_in_minutes__c);
        
        system.debug('8-1 ' + existingAppointmentDuration);
        
        Integer formatted = existingAppointmentDuration.intValue();
        
        system.debug('9 (existing app duration) ' + formatted);

        Datetime existingAppointmentDate = existingDateMap.get(appointment.Appointment_Date__c);
        
        system.debug('10' + existingAppointmentDate);
        
        if (newAppointmentDate >= existingAppointmentDate && 
            newAppointmentDate <= existingAppointmentDate.addMinutes(formatted)) {
                Trigger.new[0].addError('Appointment for this doctor on this time already exists. ' + 
                                        'Please, choose another time.');
		}
    }
    
    system.debug('KONEЦ');*/
}