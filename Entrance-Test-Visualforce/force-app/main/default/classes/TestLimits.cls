@isTest
private class TestLimits {

    /* @isTest
    static void testTriggerWithLoop() {
        // New doctor for loop
        // Setting doctor's working hours
        String timeStart = '01:00:00.000Z';
        String timeEnd = '23:00:00.000Z';

        Time newWorkingHoursStart = (Time)JSON.deserialize('"' + timeStart + '"', Time.class);
        Time newWorkingHoursEnd = (Time)JSON.deserialize('"' + timeEnd + '"', Time.class);

        Doctor__c newDoctorForLoop = AppointmentsTestDataMethods.createTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        insert newDoctorForLoop;

        // New patient for loop
        Patient__c newPatientForLoop = AppointmentsTestDataMethods.createTestPatient(1);
        insert newPatientForLoop;

        // New appointment to make list not null in trigger
        String dt1 = '2021-02-02T05:00:00.000Z';
        Datetime newCorrectDatetime = (Datetime)JSON.deserialize('"' + dt1 + '"', DateTime.class);

        Appointment__c TestAppointment = AppointmentsTestDataMethods.createTestAppointment(1, newCorrectDatetime, 5, newDoctorForLoop, newPatientForLoop);
        insert TestAppointment;

        // New list of appointments to test limits
        List<Appointment__c> newList = new List<Appointment__c>();

        for (Integer i = 0; i < 250; i++) {
            Datetime newCorrectDatetimeLoop = Datetime.newInstance(2021, 02, 02+i, 01, 01+i*2, 00);
            Appointment__c TestAppointmentLoop = AppointmentsTestDataMethods.createTestAppointment(i, newCorrectDatetimeLoop, 1, newDoctorForLoop, newPatientForLoop);
            //insert TestAppointmentLoop;
            newList.add(TestAppointmentLoop);
        }

        insert newList;
    }

    // construction with
    // insert new List<> {}
    @isTest
    static void testTriggerWithLists() {
        String timeStart = '01:00:00.000Z';
        String timeEnd = '23:00:00.000Z';

        Time newWorkingHoursStart = (Time)JSON.deserialize('"' + timeStart + '"', Time.class);
        Time newWorkingHoursEnd = (Time)JSON.deserialize('"' + timeEnd + '"', Time.class);

        Doctor__c d1 = new Doctor__c();
        d1.Name = 'Test Doctor 1';
        d1.Working_Hours_Start__c = newWorkingHoursStart;
        d1.Working_Hours_End__c = newWorkingHoursEnd;

        Doctor__c d2 = new Doctor__c();
        d2.Name = 'Test Doctor 2';
        d2.Working_Hours_Start__c = newWorkingHoursStart;
        d2.Working_Hours_End__c = newWorkingHoursEnd;

        insert new List<Doctor__c> {d1, d2};

        Patient__c NewPatientForLoop = AppointmentsTestDataMethods.createTestPatient(1);
        insert NewPatientForLoop;

		Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 01, 00, 00);
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 02, 00, 00);

        Appointment__c a1 = AppointmentsTestDataMethods.createTestAppointment(1, newCorrectDatetime1, 1, d1, newPatientForLoop);
        Appointment__c a2 = AppointmentsTestDataMethods.createTestAppointment(2, newCorrectDatetime2, 1, d2, newPatientForLoop);

        insert new List<Appointment__c> {a1, a2};
    } */

}