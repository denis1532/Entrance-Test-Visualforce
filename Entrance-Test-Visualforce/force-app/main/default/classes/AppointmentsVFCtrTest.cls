@isTest
private class AppointmentsVFCtrTest {

    @TestSetup
    static void testData() {
        /*** New doctor ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);

        Doctor__c NewDoctor1 = AppointmentsTestDataMethods.createTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Doctor__c NewDoctor2 = AppointmentsTestDataMethods.createTestDoctor(2, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor1;
        Insert NewDoctor2;

        /*** New patient ***/
        Patient__c NewPatient1 = AppointmentsTestDataMethods.createTestPatient(1);
        Patient__c NewPatient2 = AppointmentsTestDataMethods.createTestPatient(2);
        Insert NewPatient1;
        Insert NewPatient2;

        /*** New appointment1 with correct time for doctor1 and patient1 ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);

        Appointment__c TestAppointment1 = AppointmentsTestDataMethods.createTestAppointment(1, newCorrectDatetime1, 15, NewDoctor1, NewPatient1);
        insert TestAppointment1;

        /*** New appointment2 with correct time for doctor1 and patient2 ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);

        Appointment__c TestAppointment2 = AppointmentsTestDataMethods.createTestAppointment(2, newCorrectDatetime2, 40, NewDoctor1, NewPatient2);
        insert TestAppointment2;

        /*** New appointment3 with correct time for doctor2 and patient1 ***/
        Datetime newCorrectDatetime3 = Datetime.newInstance(2021, 02, 03, 10, 00, 00);

        Appointment__c TestAppointment3 = AppointmentsTestDataMethods.createTestAppointment(3, newCorrectDatetime3, 15, NewDoctor2, NewPatient1);
        insert TestAppointment3;

        /*** New appointment4 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime4 = Datetime.newInstance(2021, 02, 03, 10, 30, 00);

        Appointment__c TestAppointment4 = AppointmentsTestDataMethods.createTestAppointment(4, newCorrectDatetime4, 15, NewDoctor2, NewPatient2);
        insert TestAppointment4;

        /*** New appointment5 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime5 = Datetime.newInstance(2021, 02, 03, 11, 00, 00);

        Appointment__c TestAppointment5 = AppointmentsTestDataMethods.createTestAppointment(5, newCorrectDatetime5, 40, NewDoctor2, NewPatient2);
        insert TestAppointment5;
    }

    /*** ---------- Test custom controller ---------- ***/
    @isTest
    static void testAppointmentsVFCtr() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();

        System.assertEquals(2, Database.query(AppointmentsTestDataMethods.doctorsAssertion).size());

        System.assertEquals(2, Database.query(AppointmentsTestDataMethods.patientsAssertion).size());

        /*** ---------- Test getting appointments ---------- ***/
        System.assertEquals(5, Database.query(AppointmentsTestDataMethods.appointmentsAssertion).size());
    }

    @isTest
    static void testGetAppointmentsMethod() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        System.assertEquals(5, TestAppointmentsList.size());
        System.assertEquals(5, TestAppointmentsVFCtr.totalSize);
        TestAppointmentsVFCtr.sortOrder = 'Doctor__r.Name';
        TestAppointmentsVFCtr.sortByField();
        TestAppointmentsVFCtr.sortOrder = 'Patient__r.Name';
        TestAppointmentsVFCtr.sortByField();
    }

    @isTest
    static void testSelectors() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

         /*** ---------- Test doctors select options ---------- ***/
        List<SelectOption> selectedDoctorOptions = TestAppointmentsVFCtr.getSelectedDoctor();
        System.assertEquals(selectedDoctorOptions.get(0).getLabel(), '--All--');
        System.assertEquals(selectedDoctorOptions.get(1).getLabel(), 'Test Doctor 1');

        /*** ---------- Test patients select options ---------- ***/
        List<SelectOption> selectedPatientOptions = TestAppointmentsVFCtr.getSelectedPatient();
        System.assertEquals(selectedPatientOptions.get(0).getLabel(), '--All--');
        System.assertEquals(selectedPatientOptions.get(1).getLabel(), 'Test Patient 1');
    }

    @isTest
    static void testGetHoursMethod() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        /*** ||||| Test getHours method with empty doctor ||||| ***/
        List<Doctor__c> TestHours = TestAppointmentsVFCtr.getHours();
        System.assertEquals(null, TestHours);

        /*** ||||| Test getHours method with selected doctor ||||| ***/
        /*** Set doctor for search ***/
        TestAppointmentsVFCtr.selectedDoctorId = TestAppointmentsVFCtr.getSelectedDoctor().get(1).getValue();
        TestAppointmentsVFCtr.getSelectedDoctor();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

        TestHours = TestAppointmentsVFCtr.getHours();
        System.assertEquals(1, TestHours.size());
    }

    @isTest
    static void testResetButtons() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        /*** Set doctor for search ***/
        TestAppointmentsVFCtr.selectedDoctorId = TestAppointmentsVFCtr.getSelectedDoctor().get(2).getValue();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());

        // Reset doctors picklist
        TestAppointmentsVFCtr.resetSearchAppointmentsByDoctor();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        /*** Set patient for search ***/
        TestAppointmentsVFCtr.selectedPatientId = TestAppointmentsVFCtr.getSelectedPatient().get(1).getValue();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

		// Reset patients picklist
        TestAppointmentsVFCtr.resetSearchAppointmentsByPatient();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        /*** Set date for search ***/
        TestAppointmentsVFCtr.searchDateTime = Datetime.newInstance(2021, 02, 02, 10, 00, 00);
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

        // Reset date search
        TestAppointmentsVFCtr.resetSearchAppointmentByDate();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        /*** Set duration for search ***/
        TestAppointmentsVFCtr.searchDuration = 15;
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());

        // Reset duration search
        TestAppointmentsVFCtr.resetSearchAppointmentByDuration();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());
    }

    @isTest
    static void testTotalQuery() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        /*** ---------- Test main queries IN TOTAL ---------- ***/
        /*** Set doctor for search ***/
        TestAppointmentsVFCtr.selectedDoctorId = TestAppointmentsVFCtr.getSelectedDoctor().get(2).getValue();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());

        /*** Set patient for search ***/
        TestAppointmentsVFCtr.selectedPatientId = TestAppointmentsVFCtr.getSelectedPatient().get(2).getValue();
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

        /*** Set date for search ***/
        TestAppointmentsVFCtr.searchDateTime = Datetime.newInstance(2021, 02, 03, 10, 00, 00);
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

        /*** Set duration for search ***/
        TestAppointmentsVFCtr.searchDuration = 40;
        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(1, TestAppointmentsList.size());
    }

    @isTest
    static void testSaveNewAppointment() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();

        System.debug(TestAppointmentsVFCtr.NewAppointment);

        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        TestAppointmentsVFCtr.selectedDoctorId = TestAppointmentsVFCtr.getSelectedDoctor().get(2).getValue();
        TestAppointmentsVFCtr.selectedPatientId = TestAppointmentsVFCtr.getSelectedPatient().get(2).getValue();
        TestAppointmentsVFCtr.searchDateTime = Datetime.newInstance(2021, 02, 05, 10, 00, 00);
        TestAppointmentsVFCtr.searchDuration = 15;

        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        TestAppointmentsVFCtr.saveNewAppointment();

        List<Appointment__c> TestAppointmentsListAfterSave = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(1, TestAppointmentsListAfterSave.size());

        // Test catch exception in saveNewAppointment
        TestAppointmentsVFCtr.saveNewAppointment();
    }

    @isTest
    static void testDeleteAppointment() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();

        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        TestAppointmentsVFCtr.selectedAppointmentId = '';
        System.currentPageReference().getParameters().put('AppointmentId', TestAppointmentsList.get(0).Id);
        TestAppointmentsVFCtr.deleteSelectedAppointment();

        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(4, TestAppointmentsList.size());
    }

    @isTest
    static void testPagination() {
        AppointmentsVFCtr TestAppointmentsVFCtr = new AppointmentsVFCtr();
        List<Appointment__c> TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();

        // Test Beginning method
        TestAppointmentsVFCtr.beginning();
        System.assertEquals(1, TestAppointmentsVFCtr.getPageNumber());

        // Test Previous method
        TestAppointmentsVFCtr.previous();
        System.assertEquals(0, TestAppointmentsVFCtr.getPageNumber());

        // Test Next method
        TestAppointmentsVFCtr.next();
        System.assertEquals(1, TestAppointmentsVFCtr.getPageNumber());

        // Test Last method
        TestAppointmentsVFCtr.end();
        System.assertEquals(1, TestAppointmentsVFCtr.getPageNumber());

        // Test disabled first and previous buttons
        System.assertEquals(true, TestAppointmentsVFCtr.getDisableBeginningPrevious());

        // Test disabled next and last buttons
        System.assertEquals(true, TestAppointmentsVFCtr.getDisableNextEnd());

        // Test getPageNumber method
        System.assertEquals(1, TestAppointmentsVFCtr.getPageNumber());

        // Test getTotalPages method
        System.assertEquals(1, TestAppointmentsVFCtr.getTotalPages());

        // Test getTotalPages with "else"

        /*** New Doctor for loop ***/
        // Setting doctor's working hours
        Time newWorkingHoursStartLoop = Time.newInstance(01, 00, 00, 000);
        Time newWorkingHoursEndLoop = Time.newInstance(23, 00, 00, 000);

        Doctor__c NewDoctorForLoop = AppointmentsTestDataMethods.CreateTestDoctor(3, newWorkingHoursStartLoop, newWorkingHoursEndLoop);
        insert NewDoctorForLoop;
        System.assertEquals(3, Database.query(AppointmentsTestDataMethods.doctorsAssertion).size());

        /*** New Patient for loop ***/
        Patient__c NewPatientForLoop = AppointmentsTestDataMethods.CreateTestPatient(3);
        insert NewPatientForLoop;
        System.assertEquals(3, Database.query(AppointmentsTestDataMethods.patientsAssertion).size());

        // Create additional appointments to fulfill else method conditionals
        for (Integer i = 0; i < 5; i++) {
            Datetime newCorrectDatetimeLoop = Datetime.newInstance(2021, 02, 02, 01, 00+i*2, 00);
            Appointment__c TestAppointmentLoop = AppointmentsTestDataMethods.createTestAppointment(i, newCorrectDatetimeLoop, 1, NewDoctorForLoop, NewPatientForLoop);
            insert TestAppointmentLoop;
        }

        TestAppointmentsList = TestAppointmentsVFCtr.getAppointments();
        System.assertEquals(10, Database.query(AppointmentsTestDataMethods.appointmentsAssertion).size());

        System.assertEquals(1, TestAppointmentsVFCtr.getTotalPages());
    }

}
