@isTest
private class testTest {
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
        
        /*** New Doctor for loop ***/
        // Setting doctor's working hours
        Time newWorkingHoursStart = Time.newInstance(01, 00, 00, 000);
        Time newWorkingHoursEnd = Time.newInstance(23, 00, 00, 000);
        
        Doctor__c NewDoctorForLoop = testTest.CreateTestDoctor(1, newWorkingHoursStart, newWorkingHoursEnd);
        insert NewDoctorForLoop;
        
        /*** New Patient for loop ***/
        Patient__c NewPatientForLoop = testTest.CreateTestPatient(1);
        insert NewPatientForLoop;      
        
        /*** New Appointment to make list not null in trigger ***/
        Datetime newCorrectDatetime = Datetime.newInstance(2021, 02, 02, 05, 00, 00);
        Appointment__c TestAppointment = testTest.CreateTestAppointment(1, newCorrectDatetime, 5, NewDoctorForLoop, NewPatientForLoop);
        insert TestAppointment;
        
        /*** New list of Appointments to test limits ***/
        List<Appointment__c> newList = new List<Appointment__c>();
        
        for (Integer i = 0; i < 101; i++) {
            Datetime newCorrectDatetimeLoop = Datetime.newInstance(2021, 02, 02, 01, 01+i*2, 00);
            Appointment__c TestAppointmentLoop = testTest.CreateTestAppointment(i, newCorrectDatetimeLoop, 1, NewDoctorForLoop, NewPatientForLoop);
            //insert TestAppointmentLoop;
            newList.add(TestAppointmentLoop);
        }
        
        insert newList;
                
        /*Doctor__c d1 = new Doctor__c();
        d1.Name = 'Test Doctor 1';
        d1.Working_Hours_Start__c = newWorkingHoursStart;
        d1.Working_Hours_End__c = newWorkingHoursEnd;
        
        Doctor__c d2 = new Doctor__c();
        d2.Name = 'Test Doctor 2';
        d2.Working_Hours_Start__c = newWorkingHoursStart;
        d2.Working_Hours_End__c = newWorkingHoursEnd;
        
        insert new List<Doctor__c> {d1, d2};
        
		Datetime newCorrectDatetime1 = Datetime.newInstance(2021, 02, 02, 01, 00, 00);
        Datetime newCorrectDatetime2 = Datetime.newInstance(2021, 02, 02, 02, 00, 00);
        
        Appointment__c a1 = testTest.CreateTestAppointment(1, newCorrectDatetime1, 1, d1, NewPatientForLoop);
        Appointment__c a2 = testTest.CreateTestAppointment(2, newCorrectDatetime2, 1, d2, NewPatientForLoop);
        
        insert new List<Appointment__c> {a1, a2};*/
    }
}