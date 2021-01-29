trigger appointmentCreation on Appointment__c (before insert) {
    /*for (Appointment__c a : [SELECT Doctor__r.Name, Appointment_Date__c
                             FROM Appointment__c
                             WHERE Doctor__r.Name
                             IN :Trigger.new]) {
		Trigger.new.get(a.Doctor__r.Name).addError(
            'Cannot create an appointment. The doctor already has and appointment for this time.');
	}*/
    for (Appointment__C a : [SELECT Doctor__r.Name
                             FROM Appointment__c
                             WHERE Name='Hyppocrate']) {
    	System.debug('a');                             
	}
}

// Создать Apex Trigger, запрещающий создание записи Appointment,
// если у доктора уже есть Appointment на это же время
// 
// Appointment__c.Doctor__c уже есть Appointment__c.Appointment_Date__c