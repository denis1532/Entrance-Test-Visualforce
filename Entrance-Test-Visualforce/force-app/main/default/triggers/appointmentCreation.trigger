trigger appointmentCreation on Appointment__c (before insert) {
    /* Trigger that restricts appointment creation
     * if a doctor already has an appointment
     * on that date and on that time (plus appointment duration)
     */ 
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
}