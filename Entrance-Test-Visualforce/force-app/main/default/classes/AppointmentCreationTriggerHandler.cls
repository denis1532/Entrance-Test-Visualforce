public with sharing class AppointmentCreationTriggerHandler {

    public void OnBeforeInsertCheck (List<Appointment__c> record) {
        Set<Id> docIds = new Set<Id>();
        Map<Id, Datetime> doctorWithDateMap = new Map<Id, Datetime>();
        Map<Id, Integer> doctorWithDuration = new Map<Id, Integer>();
        Map<Id, Time> doctorAppointmentTime = new Map<Id, Time>();

        for (Appointment__c newAppointment : record) {
            if (newAppointment.Doctor__c != null) {
                docIds.add(newAppointment.Doctor__c);
            }

            Datetime newAppointmentDate = newAppointment.Appointment_Date__c;
            doctorWithDateMap.put(newAppointment.Doctor__c, newAppointmentDate);

            Integer newAppointmentDuration = (Integer) newAppointment.Duration_in_minutes__c;
            doctorWithDuration.put(newAppointment.Doctor__c, newAppointmentDuration);

            Time newAppointmentTime = newAppointment.Appointment_Date__c.time();
            doctorAppointmentTime.put(newAppointment.Doctor__c, newAppointmentTime);
        }

        List<Appointment__c> appointments = [SELECT Doctor__r.Id, Appointment_Date__c, Duration_in_minutes__c, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c
                                             FROM Appointment__c
                                             WHERE Doctor__r.Id IN :docIds];

        for (Appointment__c existingAppointment : appointments) {
            Integer existingAppointmentDuration = (Integer) existingAppointment.Duration_in_minutes__c;
            Datetime existingAppointmentDate = existingAppointment.Appointment_Date__c;

            Time workingHoursStart = existingAppointment.Doctor__r.Working_Hours_Start__c;
            Time workingHoursEnd = existingAppointment.Doctor__r.Working_Hours_End__c;

            Id docId = existingappointment.Doctor__r.Id;

            if (doctorWithDateMap.get(docId) >= existingAppointmentDate &&
                doctorWithDateMap.get(docId) <= existingAppointmentDate.addMinutes(existingAppointmentDuration)) {
                    record[0].addError('Appointment for this doctor on this time already exists. ' +
                                       'Please, choose another time.');
			} else if (doctorAppointmentTime.get(docId) < workingHoursStart ||
                       doctorAppointmentTime.get(docId).addMinutes(doctorWithDuration.get(docId)) >= workingHoursEnd ) {
                           record[0].addError('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' +
                                              'Please, choose another time.');
			}
        }
    }

}
