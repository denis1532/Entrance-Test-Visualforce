@isTest
private class TestAppointments {
    
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
    
    
    
    /*** ---------- Test trigger appointmentCreation ---------- ***/
    static testmethod void testTriggerCreation() {
        
        /*** ---------- New doctor ---------- ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = TestAppointments.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
		Patient__c NewPatient = TestAppointments.CreateTestPatient(1); 
        Insert NewPatient;
        System.assertEquals(1, [SELECT Id FROM Patient__c].size());        
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c TestAppointment1 = TestAppointments.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment2 = TestAppointments.CreateTestAppointment(2, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for already existing appointment ---------- ***/
        // Setting new appointment datetime
        Datetime newIncorrectDatetime = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment3 = TestAppointments.CreateTestAppointment(3, newIncorrectDatetime, 10, NewDoctor, NewPatient);
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
    
    
    
    /*** ---------- Test trigger appointmentCreationWithHours ---------- ***/
    static testmethod void testTriggerCreationWorkingHours() {
        
        /*** ---------- New doctor ---------- ***/        
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor = TestAppointments.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New patient ---------- ***/
        Patient__c NewPatient = TestAppointments.CreateTestPatient(1);
        Insert NewPatient;
        System.assertEquals(1, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c TestAppointment1 = TestAppointments.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment2 = TestAppointments.CreateTestAppointment(1, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- New appointment with incorrect time for doctor's working hours ---------- ***/
        Datetime newIncorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 14, 00, 00);
        
        Appointment__c TestAppointment3 = TestAppointments.CreateTestAppointment(1, newIncorrectDatetime1, 10, NewDoctor, NewPatient);
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
    
    
    
    /*** ---------- Test custom controller ---------- ***/
    static testmethod void testAppointmentsController() {
        AppointmentsController TestAppointmentsController = new AppointmentsController();
        
        /*** New doctor ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);
        
        Doctor__c NewDoctor1 = TestAppointments.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Doctor__c NewDoctor2 = TestAppointments.CreateTestDoctor(2, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor1;
        Insert NewDoctor2;
        System.assertEquals(2, [SELECT Id FROM Doctor__c].size());
        
        /*** ---------- Test doctors select options ---------- ***/
        List<SelectOption> selectedDoctorOptions = TestAppointmentsController.getSelectedDoctor();
        System.assertEquals(selectedDoctorOptions.get(0).getLabel(), '-All-');
        System.assertEquals(selectedDoctorOptions.get(1).getLabel(), 'Test Doctor 1');
        
        /*** New patient ***/
        Patient__c NewPatient1 = TestAppointments.CreateTestPatient(1);
        Patient__c NewPatient2 = TestAppointments.CreateTestPatient(2);
        Insert NewPatient1;
        Insert NewPatient2;
        System.assertEquals(2, [SELECT Id FROM Patient__c].size());
        
        /*** ---------- Test patients select options ---------- ***/
        List<SelectOption> selectedPatientOptions = TestAppointmentsController.getSelectedPatient();
        System.assertEquals(selectedPatientOptions.get(0).getLabel(), '-All-');
        System.assertEquals(selectedPatientOptions.get(1).getLabel(), 'Test Patient 1');
        
        /*** New appointment1 with correct time for doctor1 and patient1 ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        
        Appointment__c TestAppointment1 = TestAppointments.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor1, NewPatient1);
        insert TestAppointment1;
        System.assertEquals(1, [SELECT Id FROM Appointment__c].size());
        
        /*** New appointment2 with correct time for doctor1 and patient2 ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);
        
        Appointment__c TestAppointment2 = TestAppointments.CreateTestAppointment(2, newCorrectDatetime2, 40, NewDoctor1, NewPatient2);
        insert TestAppointment2;
        System.assertEquals(2, [SELECT Id FROM Appointment__c].size());
        
        /*** New appointment3 with correct time for doctor2 and patient1 ***/
        Datetime newCorrectDatetime3 = Datetime.newInstance(2021, 02, 03, 10, 00, 00);
        
        Appointment__c TestAppointment3 = TestAppointments.CreateTestAppointment(3, newCorrectDatetime3, 15, NewDoctor2, NewPatient1);
        insert TestAppointment3;
        System.assertEquals(3, [SELECT Id FROM Appointment__c].size());
        
        /*** New appointment4 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime4 = Datetime.newInstance(2021, 02, 03, 10, 30, 00);
        
        Appointment__c TestAppointment4 = TestAppointments.CreateTestAppointment(4, newCorrectDatetime4, 15, NewDoctor2, NewPatient2);
        insert TestAppointment4;
        System.assertEquals(4, [SELECT Id FROM Appointment__c].size());
        
        /*** New appointment5 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime5 = Datetime.newInstance(2021, 02, 03, 11, 00, 00);
        
        Appointment__c TestAppointment5 = TestAppointments.CreateTestAppointment(5, newCorrectDatetime5, 40, NewDoctor2, NewPatient2);
        insert TestAppointment5;
        System.assertEquals(5, [SELECT Id FROM Appointment__c].size());
        
        /*** ---------- Test getAppointments method ---------- ***/
        List<Appointment__c> TestAppointmentsList = TestAppointmentsController.getAppointments();

        System.assertEquals(5, TestAppointmentsList.size());
        System.assertEquals(5, TestAppointmentsController.totalSize);
        TestAppointmentsController.sortOrder = 'Doctor__r.Name';
        TestAppointmentsController.sortByField();
        TestAppointmentsController.sortOrder = 'Patient__r.Name';
        TestAppointmentsController.sortByField();
		
        /*** ---------- Test main queries ONE BY ONE ---------- ***/
        
        /*** ||||| Test getHours method with empty doctor ||||| ***/
        List<Doctor__c> TestHours = TestAppointmentsController.getHours();
        System.assertEquals(null, TestHours);
        
        /*** Set doctor for search ***/
        TestAppointmentsController.selectedDoctorName = selectedDoctorOptions.get(1).getLabel();
        TestAppointmentsController.getSelectedDoctor();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
        /*** ||||| Test getHours method with selected doctor ||||| ***/
        TestHours = TestAppointmentsController.getHours();
        System.assertNotEquals(null, TestHours);
        // It could be done this was either,
        // but the previous one is more understandable in this situation
        System.assertEquals(1, TestHours.size());
        
        // Reset doctors picklist
        TestAppointmentsController.resetSearchAppointmentsByDoctor();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());
                
        /*** Set patient for search ***/
        TestAppointmentsController.selectedPatientName = selectedPatientOptions.get(1).getLabel();
        TestAppointmentsController.getSelectedPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
		// Reset patients picklist
        TestAppointmentsController.resetSearchAppointmentsByPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());
        
        /*** Set date for search ***/
        // Format existing test datetime to date format for search
        Date formattedTestDate1 = date.newInstance(newCorrectDatetime1.year(), newCorrectDatetime1.month(), newCorrectDatetime1.day());
        
        TestAppointmentsController.searchDate = formattedTestDate1;
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
        // Reset date search
        TestAppointmentsController.resetSearchAppointmentByDate();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());
        
        /*** Set duration for search ***/
        TestAppointmentsController.searchDuration = 15;
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());
        
        // Reset duration search
        TestAppointmentsController.resetSearchAppointmentByDuration();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());
        
        /*** ---------- Test main queries IN TOTAL ---------- ***/
        /*** Set doctor for search ***/
        TestAppointmentsController.selectedDoctorName = selectedDoctorOptions.get(2).getLabel();
        TestAppointmentsController.getSelectedDoctor();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());
                
        /*** Set patient for search ***/
        TestAppointmentsController.selectedPatientName = selectedPatientOptions.get(2).getLabel();
        TestAppointmentsController.getSelectedPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
        /*** Set date for search ***/
        // Format existing test datetime to date format for search
        Date formattedTestDate2 = date.newInstance(newCorrectDatetime3.year(), newCorrectDatetime3.month(), newCorrectDatetime3.day());
        
        TestAppointmentsController.searchDate = formattedTestDate2;
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
        /*** Set duration for search ***/
        TestAppointmentsController.searchDuration = 40;
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(1, TestAppointmentsList.size());
        
        // Reset doctors picklist
        TestAppointmentsController.resetSearchAppointmentsByDoctor();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(1, TestAppointmentsList.size());
        
        // Reset patients picklist
        TestAppointmentsController.resetSearchAppointmentsByPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(1, TestAppointmentsList.size());
        
        // Reset date search
        TestAppointmentsController.resetSearchAppointmentByDate();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());
        
        // Reset duration search
        TestAppointmentsController.resetSearchAppointmentByDuration();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        /*** ---------- Test pagination ---------- ***/
        
        // Test Beginning method
        TestAppointmentsController.Beginning();
        System.assertEquals(1, TestAppointmentsController.getPageNumber());
        
        // Test Previous method
        TestAppointmentsController.Previous();
        System.assertEquals(0, TestAppointmentsController.getPageNumber());

        // Test Next method
        TestAppointmentsController.Next();
        System.assertEquals(1, TestAppointmentsController.getPageNumber());
        
        // Test Last method
        TestAppointmentsController.End();
        System.assertEquals(1, TestAppointmentsController.getPageNumber());
        
        // Test disabled first and previous buttons
        System.assertEquals(true, TestAppointmentsController.getDisableBeginningPrevious());
        
        // Test disabled next and last buttons
        System.assertEquals(true, TestAppointmentsController.getDisableNextEnd());
        
        // Test getPageNumber method
        System.assertEquals(1, TestAppointmentsController.getPageNumber());
        
        // Test getTotalPages method
        System.assertEquals(1, TestAppointmentsController.getTotalPages());
        
        // Test getTotalPages with "else"
        
        /*** New Doctor for loop ***/
        // Setting doctor's working hours
        Time newWorkingHoursStartLoop = Time.newInstance(01, 00, 00, 000);
        Time newWorkingHoursEndLoop = Time.newInstance(23, 00, 00, 000);
        
        Doctor__c NewDoctorForLoop = TestAppointments.CreateTestDoctor(3, newWorkingHoursStartLoop, newWorkingHoursEndLoop);
        insert NewDoctorForLoop;
        System.assertEquals(3, [SELECT Id FROM Doctor__c].size());
        
        /*** New Patient for loop ***/
        Patient__c NewPatientForLoop = TestAppointments.CreateTestPatient(3);
        insert NewPatientForLoop;
        System.assertEquals(3, [SELECT Id FROM Patient__c].size());
        
        // Create additional appointments to fulfill else method conditionals
        for (Integer i = 0; i < 5; i++) {
            Datetime newCorrectDatetimeLoop = Datetime.newInstance(2021, 02, 02, 01, 00+i*2, 00);
            Appointment__c TestAppointmentLoop = TestAppointments.CreateTestAppointment(i, newCorrectDatetimeLoop, 1, NewDoctorForLoop, NewPatientForLoop);
            insert TestAppointmentLoop;
        }
        
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(10, [SELECT Id FROM Appointment__c].size());
        
        System.assertEquals(1, TestAppointmentsController.getTotalPages());
    }
}