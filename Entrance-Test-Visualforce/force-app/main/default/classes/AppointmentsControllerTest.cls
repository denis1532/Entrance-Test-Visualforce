@isTest
private class AppointmentsControllerTest {

    /*** ---------- Test custom controller ---------- ***/
    @isTest
    static void testAppointmentsController() {
        AppointmentsController TestAppointmentsController = new AppointmentsController();

        /*** New doctor ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(09, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(12, 00, 00, 000);

        Doctor__c NewDoctor1 = TestDataFactory.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        Doctor__c NewDoctor2 = TestDataFactory.CreateTestDoctor(2, newWorkingHoursStart, newWorkingHoursEnd);
        Insert NewDoctor1;
        Insert NewDoctor2;
        System.assertEquals(2, Database.query(TestDataFactory.doctorsAssertion).size());

        /*** ---------- Test doctors select options ---------- ***/
        List<SelectOption> selectedDoctorOptions = TestAppointmentsController.getSelectedDoctor();
        System.assertEquals(selectedDoctorOptions.get(0).getLabel(), '-All-');
        System.assertEquals(selectedDoctorOptions.get(1).getLabel(), 'Test Doctor 1');

        /*** New patient ***/
        Patient__c NewPatient1 = TestDataFactory.CreateTestPatient(1);
        Patient__c NewPatient2 = TestDataFactory.CreateTestPatient(2);
        Insert NewPatient1;
        Insert NewPatient2;
        System.assertEquals(2, Database.query(TestDataFactory.patientsAssertion).size());

        /*** ---------- Test patients select options ---------- ***/
        List<SelectOption> selectedPatientOptions = TestAppointmentsController.getSelectedPatient();
        System.assertEquals(selectedPatientOptions.get(0).getLabel(), '-All-');
        System.assertEquals(selectedPatientOptions.get(1).getLabel(), 'Test Patient 1');

        /*** New appointment1 with correct time for doctor1 and patient1 ***/
        Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 10, 00, 00);

        Appointment__c TestAppointment1 = TestDataFactory.CreateTestAppointment(1, newCorrectDatetime1, 15, NewDoctor1, NewPatient1);
        insert TestAppointment1;
        System.assertEquals(1, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** New appointment2 with correct time for doctor1 and patient2 ***/
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 11, 00, 00);

        Appointment__c TestAppointment2 = TestDataFactory.CreateTestAppointment(2, newCorrectDatetime2, 40, NewDoctor1, NewPatient2);
        insert TestAppointment2;
        System.assertEquals(2, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** New appointment3 with correct time for doctor2 and patient1 ***/
        Datetime newCorrectDatetime3 = Datetime.newInstance(2021, 02, 03, 10, 00, 00);

        Appointment__c TestAppointment3 = TestDataFactory.CreateTestAppointment(3, newCorrectDatetime3, 15, NewDoctor2, NewPatient1);
        insert TestAppointment3;
        System.assertEquals(3, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** New appointment4 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime4 = Datetime.newInstance(2021, 02, 03, 10, 30, 00);

        Appointment__c TestAppointment4 = TestDataFactory.CreateTestAppointment(4, newCorrectDatetime4, 15, NewDoctor2, NewPatient2);
        insert TestAppointment4;
        System.assertEquals(4, Database.query(TestDataFactory.appointmentsAssertion).size());

        /*** New appointment5 with correct time for doctor2 and patient2 ***/
        Datetime newCorrectDatetime5 = Datetime.newInstance(2021, 02, 03, 11, 00, 00);

        Appointment__c TestAppointment5 = TestDataFactory.CreateTestAppointment(5, newCorrectDatetime5, 40, NewDoctor2, NewPatient2);
        insert TestAppointment5;
        System.assertEquals(5, Database.query(TestDataFactory.appointmentsAssertion).size());

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
        TestAppointmentsController.selectedDoctorId = selectedDoctorOptions.get(1).getValue();
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
        TestAppointmentsController.selectedPatientId = selectedPatientOptions.get(1).getValue();
        TestAppointmentsController.getSelectedPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

		// Reset patients picklist
        TestAppointmentsController.resetSearchAppointmentsByPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(5, TestAppointmentsList.size());

        /*** Set date for search ***/
        // Format existing test datetime to date format for search
        // *** Date formattedTestDate1 = date.newInstance(newCorrectDatetime1.year(), newCorrectDatetime1.month(), newCorrectDatetime1.day());

        TestAppointmentsController.searchDateTime = newCorrectDatetime1;
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
        TestAppointmentsController.selectedDoctorId = selectedDoctorOptions.get(2).getValue();
        TestAppointmentsController.getSelectedDoctor();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(3, TestAppointmentsList.size());

        /*** Set patient for search ***/
        TestAppointmentsController.selectedPatientId = selectedPatientOptions.get(2).getValue();
        TestAppointmentsController.getSelectedPatient();
        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(2, TestAppointmentsList.size());

        /*** Set date for search ***/
        // Format existing test datetime to date format for search
        // *** Date formattedTestDate2 = date.newInstance(newCorrectDatetime3.year(), newCorrectDatetime3.month(), newCorrectDatetime3.day());

        TestAppointmentsController.searchDateTime = newCorrectDatetime3;
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

        Doctor__c NewDoctorForLoop = TestDataFactory.CreateTestDoctor(3, newWorkingHoursStartLoop, newWorkingHoursEndLoop);
        insert NewDoctorForLoop;
        System.assertEquals(3, Database.query(TestDataFactory.doctorsAssertion).size());

        /*** New Patient for loop ***/
        Patient__c NewPatientForLoop = TestDataFactory.CreateTestPatient(3);
        insert NewPatientForLoop;
        System.assertEquals(3, Database.query(TestDataFactory.patientsAssertion).size());

        // Create additional appointments to fulfill else method conditionals
        for (Integer i = 0; i < 5; i++) {
            Datetime newCorrectDatetimeLoop = Datetime.newInstance(2021, 02, 02, 01, 00+i*2, 00);
            Appointment__c TestAppointmentLoop = TestDataFactory.CreateTestAppointment(i, newCorrectDatetimeLoop, 1, NewDoctorForLoop, NewPatientForLoop);
            insert TestAppointmentLoop;
        }

        TestAppointmentsList = TestAppointmentsController.getAppointments();
        System.assertEquals(10, Database.query(TestDataFactory.appointmentsAssertion).size());

        System.assertEquals(1, TestAppointmentsController.getTotalPages());
    }
}
