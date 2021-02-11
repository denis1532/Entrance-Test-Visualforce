@isTest
private class AppointmentCreationTriggerTest {

    /*** ---------- Functions for doctor, patient and appointment creation ---------- ***/
    private static Doctor__c CreateTestDoctor(Integer num, Time workingHoursStart, Time workingHoursEnd) {

        Doctor__c TestDoctor = new Doctor__c();
        TestDoctor.Name = 'Test Doctor ' + num;
        TestDoctor.Working_Hours_Start__c = workingHoursStart;
        TestDoctor.Working_Hours_End__c = workingHoursEnd;
        
        return TestDoctor;
    }
    
    private static Patient__c CreateTestPatient(Integer num) {
        Patient__c TestPatient = new Patient__c();
        TestPatient.Name = 'Test Patient ' + num;
        
        return TestPatient;
    }
    
    private static Appointment__c CreateTestAppointment(Integer num, Datetime dtime, Integer duration, Doctor__c doctor, Patient__c patient) {
        Appointment__c TestAppointment = new Appointment__c();
        TestAppointment.Name = 'Test Appointment ' + num;
        TestAppointment.Appointment_Date__c = dtime;
        TestAppointment.Duration_in_minutes__c = duration;
        TestAppointment.Doctor__c = doctor.Id;
        TestAppointment.Patient__c = patient.Id;
        
        return TestAppointment;
    }
	    
    
    
    /*** ---------- Test CheckDate ---------- ***/
    static testmethod void testTriggerCheckDate() {
        
        /*** ---------- New doctor ---------- ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = AppointmentCreationTriggerTest.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
		Patient__c NewPatient = AppointmentCreationTriggerTest.CreateTestPatient(1); 
        Insert NewPatient;
        System.assertEquals(1, [SELECT Id FROM Patient__c].size());        
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c TestAppointment1 = AppointmentCreationTriggerTest.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment2 = AppointmentCreationTriggerTest.CreateTestAppointment(2, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for already existing appointment ---------- ***/
        // Setting new appointment datetime
        Datetime newIncorrectDatetime = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment3 = AppointmentCreationTriggerTest.CreateTestAppointment(3, newIncorrectDatetime, 10, NewDoctor, NewPatient);
        try {
            insert TestAppointment3;
        }
        catch (Exception e) {
            Boolean expectedCustomExceptionThrown = e.getMessage().contains('Appointment for this doctor on this time already exists. ' + 
                                                                            'Please, choose another time.') ? true : false;
            System.assertEquals(true, expectedCustomExceptionThrown);
            
            Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.assertEquals(true, expectedExceptionThrown);
        }
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
    }
    
    
    
    /*** ---------- Test CheckWorkingHours ---------- ***/
    static testmethod void testTriggerCheckWorkingHours() {
        
        /*** ---------- New doctor ---------- ***/        
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = AppointmentCreationTriggerTest.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
        Patient__c NewPatient = AppointmentCreationTriggerTest.CreateTestPatient(1);
        Insert NewPatient;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c TestAppointment1 = AppointmentCreationTriggerTest.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment2 = AppointmentCreationTriggerTest.CreateTestAppointment(1, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for doctor's working hours ---------- ***/
        Datetime newIncorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 14, 00, 00);
        
        Appointment__c TestAppointment3 = AppointmentCreationTriggerTest.CreateTestAppointment(1, newIncorrectDatetime1, 10, NewDoctor, NewPatient);
        try {
            insert TestAppointment3;
        }
        catch (Exception e) {
            Boolean expectedCustomExceptionThrown = e.getMessage().contains('This doctor is not working on chosen time or your appointment time is more than doctor\'s workday end. ' + 
                                                                            'Please, choose another time.') ? true : false;
            System.assertEquals(true, expectedCustomExceptionThrown);
            
            Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.assertEquals(true, expectedExceptionThrown);
            
        }
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
    }
}