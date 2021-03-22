@isTest
private class AppointmentCreationTriggerTest {

    /*** ---------- Test CheckDate ---------- ***/
    @isTest
    static void testTriggerCheckDate() {

        /*** ---------- New doctor ---------- ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);

        Doctor__c NewDoctor = TestDataFactory.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, Database.query(TestDataFactory.doctorsAssertion).size());

        /*** ---------- New patient ---------- ***/
		Patient__c NewPatient = TestDataFactory.CreateTestPatient(1);
        Insert NewPatient;
        System.assertEquals(1, Database.query(TestDataFactory.patientsAssertion).size());

        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);

        Appointment__c TestAppointment1 = TestDataFactory.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        // Setting new appointment datetime
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);

        Appointment__c TestAppointment2 = TestDataFactory.CreateTestAppointment(2, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** ---------- New appointment with incorrect time for already existing appointment ---------- ***/
        // Setting new appointment datetime
        Datetime newIncorrectDatetime = Datetime.newInstance(2021, 02, 02, 11, 00, 00);

        Appointment__c TestAppointment3 = TestDataFactory.CreateTestAppointment(3, newIncorrectDatetime, 10, NewDoctor, NewPatient);
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
        System.assertEquals(2, Database.query(TestDataFactory.appointmentsAssertion).size());
    }



    /*** ---------- Test CheckWorkingHours ---------- ***/
    @isTest
    static void testTriggerCheckWorkingHours() {

        /*** ---------- New doctor ---------- ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);

        Doctor__c NewDoctor = TestDataFactory.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor;
        System.assertEquals(1, Database.query(TestDataFactory.doctorsAssertion).size());

        /*** ---------- New patient ---------- ***/
        Patient__c NewPatient = TestDataFactory.CreateTestPatient(1);
        Insert NewPatient;
        System.assertEquals(1, Database.query(TestDataFactory.doctorsAssertion).size());

        /*** ---------- New appointment1 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);

        Appointment__c TestAppointment1 = TestDataFactory.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor, NewPatient);
        insert TestAppointment1;
        System.assertEquals(1, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** ---------- New appointment2 with correct time for doctor ---------- ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);

        Appointment__c TestAppointment2 = TestDataFactory.CreateTestAppointment(1, newCorrectDatetime2, 30, NewDoctor, NewPatient);
        insert TestAppointment2;
        System.assertEquals(2, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** ---------- New appointment with incorrect time for doctor's working hours ---------- ***/
        Datetime newIncorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 14, 00, 00);

        Appointment__c TestAppointment3 = TestDataFactory.CreateTestAppointment(1, newIncorrectDatetime1, 10, NewDoctor, NewPatient);
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
        System.assertEquals(2, Database.query(TestDataFactory.appointmentsAssertion).size());
    }
}
