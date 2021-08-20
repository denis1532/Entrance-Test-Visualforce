@isTest
public class AppointmentsAuraCtrTest {

    @TestSetup
    static void testData() {
        /*** New doctor ***/
        // Setting doctor's working hours
        String timeStart = '09:00:00.000Z';
        String timeEnd = '15:00:00.000Z';

        Time newWorkingHoursStart = (Time)JSON.deserialize('"' + timeStart + '"', Time.class);
        Time newWorkingHoursEnd = (Time)JSON.deserialize('"' + timeEnd + '"', Time.class);

        Doctor__c NewDoctor1 = AppointmentsTestDataMethods.createTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Doctor__c NewDoctor2 = AppointmentsTestDataMethods.createTestDoctor(2, newWorkingHoursStart, newWorkingHoursEnd);
        insert NewDoctor1;
        insert NewDoctor2;

        /*** New patient ***/
        Patient__c NewPatient1 = AppointmentsTestDataMethods.createTestPatient(1);
        Patient__c NewPatient2 = AppointmentsTestDataMethods.createTestPatient(2);
        insert NewPatient1;
        insert NewPatient2;

        /*** New appointment1 with correct time for doctor1 and patient1 ***/
        String dt1 = '2021-02-02T10:00:00.000Z';
        Datetime newCorrectDatetime1 = (Datetime)JSON.deserialize('"' + dt1 + '"', DateTime.class);

        Appointment__c TestAppointment1 = AppointmentsTestDataMethods.createTestAppointment(1, newCorrectDatetime1, 15, NewDoctor1, NewPatient1);
        insert TestAppointment1;

        /*** New appointment2 with correct time for doctor1 and patient2 ***/
        String dt2 = '2021-02-02T11:00:00.000Z';
        Datetime newCorrectDatetime2 = (Datetime)JSON.deserialize('"' + dt2 + '"', DateTime.class);

        Appointment__c TestAppointment2 = AppointmentsTestDataMethods.createTestAppointment(2, newCorrectDatetime2, 40, NewDoctor1, NewPatient2);
        insert TestAppointment2;

        /*** New appointment3 with correct time for doctor2 and patient1 ***/
        String dt3 = '2021-02-03T10:00:00.000Z';
        Datetime newCorrectDatetime3 = (Datetime)JSON.deserialize('"' + dt3 + '"', DateTime.class);

        Appointment__c TestAppointment3 = AppointmentsTestDataMethods.createTestAppointment(3, newCorrectDatetime3, 15, NewDoctor2, NewPatient1);
        insert TestAppointment3;

        /*** New appointment4 with correct time for doctor2 and patient2 ***/
        String dt4 = '2021-02-03T10:30:00.000Z';
        Datetime newCorrectDatetime4 = (Datetime)JSON.deserialize('"' + dt4 + '"', DateTime.class);

        Appointment__c TestAppointment4 = AppointmentsTestDataMethods.createTestAppointment(4, newCorrectDatetime4, 15, NewDoctor2, NewPatient2);
        insert TestAppointment4;

        /*** New appointment5 with correct time for doctor2 and patient2 ***/
        String dt5 = '2021-02-03T11:00:00.000Z';
        Datetime newCorrectDatetime5 = (Datetime)JSON.deserialize('"' + dt5 + '"', DateTime.class);

        Appointment__c TestAppointment5 = AppointmentsTestDataMethods.createTestAppointment(5, newCorrectDatetime5, 40, NewDoctor2, NewPatient2);
        insert TestAppointment5;
    }

    public static AppointmentsAuraCtr.AppointmentsDatatableWrapper testWrapper = new AppointmentsAuraCtr.AppointmentsDatatableWrapper();

    public static String selectedDoctor = '';
    public static String selectedPatient = '';
    public static String selectedDatetime = '';
    public static String selectedDuration = '';

    public static Integer pageNumber = 1;
    public static Integer pageSize = 10;

    /*** ---------- Test controller ---------- ***/
    @isTest
    static void testGeneratedData() {
        AppointmentsAuraCtr TestAppointmentsAuraCtr = new AppointmentsAuraCtr();

        System.assertEquals(2, Database.query(AppointmentsTestDataMethods.doctorsAssertion).size());

        System.assertEquals(2, Database.query(AppointmentsTestDataMethods.patientsAssertion).size());

        System.assertEquals(5, Database.query(AppointmentsTestDataMethods.appointmentsAssertion).size());
    }

    /*** ---------- Test getDoctors method ---------- ***/
    @isTest
    static void testGetDoctorsMethodAAA() {
        List<Doctor__c> testDoctorsList = AppointmentsAuraCtr.getDoctors();

        System.assertEquals(2, testDoctorsList.size());
    }

    /*** ---------- Test getPatients method ---------- ***/
    @isTest
    static void testGetPatientsMethod() {
        List<Patient__c> testPatientsList = AppointmentsAuraCtr.getPatients();

        System.assertEquals(2, testPatientsList.size());
    }

    /*** ---------- Test getWorkingHours method ---------- ***/
    @isTest
    static void testGetWorkingHoursMethod() {
        selectedDoctor = AppointmentsAuraCtr.getDoctors().get(0).Id;

        List<Doctor__c> testWorkingHoursList = AppointmentsAuraCtr.getWorkingHours(selectedDoctor);

        Time hoursStart = testWorkingHoursList.get(0).Working_Hours_Start__c;
        Time hoursEnd = testWorkingHoursList.get(0).Working_Hours_End__c;

        System.assertEquals('09:00:00.000Z', String.valueOf(hoursStart));
        System.assertEquals('15:00:00.000Z', String.valueOf(hoursEnd));
    }

    /*** ---------- Test getAppointments method variations and wrapper class ---------- ***/
    @isTest
    static void testGetAppointmentsMehodWithoutClauses() {
        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(5, testWrapper.appointments.size());
    }

    @isTest
    static void testGetAppointmentsMehodWithSelectedDoctor() {
        selectedDoctor = AppointmentsAuraCtr.getDoctors().get(0).Id;

        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(2, testWrapper.appointments.size());
    }

    @isTest
    static void testGetAppointmentsMehodWithSelectedPatient() {
        selectedPatient = AppointmentsAuraCtr.getPatients().get(1).Id;

        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(3, testWrapper.appointments.size());
    }

    @isTest
    static void testGetAppointmentsMehodWithSelectedDate() {
        String testDatetime = '2021-02-02T15:28:26.048Z';

        selectedDatetime = testDatetime;

        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(2, testWrapper.appointments.size());
    }

    @isTest
    static void testGetAppointmentsMehodWithSelectedDuration() {
        selectedDuration = '15';

        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(3, testWrapper.appointments.size());
    }

    @isTest
    static void testGetAppointmentsMehodWithAllClauses() {
        String testDatetime = '2021-02-02T15:28:26.048Z';

        selectedDoctor = AppointmentsAuraCtr.getDoctors().get(0).Id;
        selectedPatient = AppointmentsAuraCtr.getPatients().get(1).Id;
        selectedDatetime = testDatetime;
        selectedDuration = '40';

        testWrapper = AppointmentsAuraCtr.getAppointments(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration, pageNumber, pageSize);

        System.assertEquals(1, testWrapper.appointments.size());
    }

    /*** ---------- Test saveAppointment method ---------- ***/
    @isTest
    static void testSaveAppointmentMehod() {
        String testDatetime = '2021-02-02T09:00:00.000Z';

        selectedDoctor = AppointmentsAuraCtr.getDoctors().get(0).Id;
        selectedPatient = AppointmentsAuraCtr.getPatients().get(1).Id;
        selectedDatetime = testDatetime;
        selectedDuration = '5';

        AppointmentsAuraCtr.saveAppointment(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration);

        System.assertEquals(6, Database.query(AppointmentsTestDataMethods.appointmentsAssertion).size());
    }

    /*** ---------- Test deleteAppointment method ---------- ***/
    @isTest
    static void testDeleteAppointmentMehod() {
        Appointment__c appointmentToDelete = [SELECT Id FROM Appointment__c LIMIT 1].get(0);

        String serializedAppointmentToDelete = JSON.serialize(appointmentToDelete);

        AppointmentsAuraCtr.deleteAppointment(serializedAppointmentToDelete);

        System.assertEquals(4, Database.query(AppointmentsTestDataMethods.appointmentsAssertion).size());
    }

}