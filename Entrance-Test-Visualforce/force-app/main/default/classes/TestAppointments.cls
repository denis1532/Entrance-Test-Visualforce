@isTest
private class TestAppointments {
    
    static testmethod void testTriggerCreation() {
        
        /*** ---------- New doctor ---------- ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = new Doctor__c();
        NewDoctor.Name = 'Test Doctor';
        NewDoctor.Working_Hours_Start__c = newWorkingHoursStart;
        NewDoctor.Working_Hours_End__c = newWorkingHoursEnd;
        Insert NewDoctor;
        System.AssertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
        Patient__c NewPatient = new Patient__c();
        NewPatient.Name = 'Test Patient';
        Insert NewPatient;
        System.AssertEquals(1, [SELECT Id FROM Patient__c].size());
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c NewAppointmentCorrect1 = new Appointment__c();
        NewAppointmentCorrect1.Name = 'Test Appointment With Correct Time';
        NewAppointmentCorrect1.Appointment_Date__c = newCorrectDatetime1;
        NewAppointmentCorrect1.Duration_in_minutes__c = 15;
        NewAppointmentCorrect1.Doctor__c = NewDoctor.Id;
        NewAppointmentCorrect1.Patient__c = NewPatient.Id;
        insert NewAppointmentCorrect1;
        System.AssertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c NewAppointmentCorrect2 = new Appointment__c();
        NewAppointmentCorrect2.Name = 'Test Appointment With Correct Time';
        NewAppointmentCorrect2.Appointment_Date__c = newCorrectDatetime2;
        NewAppointmentCorrect2.Duration_in_minutes__c = 30;
        NewAppointmentCorrect2.Doctor__c = NewDoctor.Id;
        NewAppointmentCorrect2.Patient__c = NewPatient.Id;
        insert NewAppointmentCorrect2;
        System.AssertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for already existing appointment ---------- ***/
        // Setting new appointment datetime
        Datetime newIncorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c NewAppointmentIncorrect1 = new Appointment__c();
        NewAppointmentIncorrect1.Name = 'Test Appointment With Correct Time';
        NewAppointmentIncorrect1.Appointment_Date__c = newIncorrectDatetime1;
        NewAppointmentIncorrect1.Duration_in_minutes__c = 10;
        NewAppointmentIncorrect1.Doctor__c = NewDoctor.Id;
        NewAppointmentIncorrect1.Patient__c = NewPatient.Id;
        try {
            insert NewAppointmentIncorrect1;
        }
        catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('My Error Message') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        System.AssertEquals(2, [SELECT Id FROM Appointment__c].size());
    }
    
    static testmethod void testTriggerCreationWorkingHours() {
        
        /*** ---------- New doctor ---------- ***/        
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = new Doctor__c();
        NewDoctor.Name = 'Test Doctor';
        NewDoctor.Working_Hours_Start__c = newWorkingHoursStart;
        NewDoctor.Working_Hours_End__c = newWorkingHoursEnd;
        Insert NewDoctor;
        System.AssertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
        Patient__c NewPatient = new Patient__c();
        NewPatient.Name = 'Test Patient';
        Insert NewPatient;
        System.AssertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c NewAppointmentCorrect1 = new Appointment__c();
        NewAppointmentCorrect1.Name = 'Test Appointment With Correct Time';
        NewAppointmentCorrect1.Appointment_Date__c = newCorrectDatetime1;
        NewAppointmentCorrect1.Duration_in_minutes__c = 15;
        NewAppointmentCorrect1.Doctor__c = NewDoctor.Id;
        NewAppointmentCorrect1.Patient__c = NewPatient.Id;
        insert NewAppointmentCorrect1;
        System.AssertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c NewAppointmentCorrect2 = new Appointment__c();
        NewAppointmentCorrect2.Name = 'Test Appointment With Correct Time';
        NewAppointmentCorrect2.Appointment_Date__c = newCorrectDatetime2;
        NewAppointmentCorrect2.Duration_in_minutes__c = 30;
        NewAppointmentCorrect2.Doctor__c = NewDoctor.Id;
        NewAppointmentCorrect2.Patient__c = NewPatient.Id;
        insert NewAppointmentCorrect2;
        System.AssertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for doctor's working hours ---------- ***/
        Datetime newIncorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 14, 00, 00);
        
        Appointment__c NewAppointmentIncorrect1 = new Appointment__c();
        NewAppointmentIncorrect1.Name = 'Test Appointment With Correct Time';
        NewAppointmentIncorrect1.Appointment_Date__c = newIncorrectDatetime1;
        NewAppointmentIncorrect1.Duration_in_minutes__c = 10;
        NewAppointmentIncorrect1.Doctor__c = NewDoctor.Id;
        NewAppointmentIncorrect1.Patient__c = NewPatient.Id;
        try {
            insert NewAppointmentIncorrect1;
        }
        catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('My Error Message') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        System.AssertEquals(2, [SELECT Id FROM Appointment__c].size());
    }
    	
    static testmethod void testAppointmentsController() {
        
        /*** ---------- Test custom controller ---------- ***/
        AppointmentsController AppointmentsController = new AppointmentsController();
        
        /*** ---------- Test doctors select options ---------- ***/
        
        /*** New doctor ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = new Doctor__c();
        NewDoctor.Name = 'Test Doctor';
        NewDoctor.Working_Hours_Start__c = newWorkingHoursStart;
        NewDoctor.Working_Hours_End__c = newWorkingHoursEnd;
        Insert NewDoctor;
        System.AssertEquals(1, [SELECT Id FROM Doctor__c].size());
        /*** ***/
        
        List<SelectOption> selectedDoctorOptions = AppointmentsController.getSelectedDoctor();
        System.AssertEquals(selectedDoctorOptions.get(0).getLabel(), '-All-');
        System.AssertEquals(selectedDoctorOptions.get(1).getLabel(), 'Test Doctor');
        
        /*** ---------- Test patients select options ---------- ***/
        
        /*** New patient ***/
        Patient__c NewPatient = new Patient__c();
        NewPatient.Name = 'Test Patient';
        Insert NewPatient;
        System.AssertEquals(1, [SELECT Id FROM Patient__c].size());
        /*** ***/
        
        List<SelectOption> selectedPatientOptions = AppointmentsController.getSelectedPatient();
        System.AssertEquals(selectedPatientOptions.get(0).getLabel(), '-All-');
        System.AssertEquals(selectedDoctorOptions.get(0).getLabel(), 'Test Patient');
    }
    
}