@isTest
public class TestDataFactory {
	public static Doctor__c CreateTestDoctor(Integer num, Time workingHoursStart, Time workingHoursEnd) {

        Doctor__c TestDoctor = new Doctor__c();
        TestDoctor.Name = 'Test Doctor ' + num;
        TestDoctor.Working_Hours_Start__c = workingHoursStart;
        TestDoctor.Working_Hours_End__c = workingHoursEnd;

        return TestDoctor;
    }

    public static Patient__c CreateTestPatient(Integer num) {
        Patient__c TestPatient = new Patient__c();
        TestPatient.Name = 'Test Patient ' + num;

        return TestPatient;
    }

    public static Appointment__c CreateTestAppointment(Integer num, Datetime dtime, Integer duration, Doctor__c doctor, Patient__c patient) {
        Appointment__c TestAppointment = new Appointment__c();
        TestAppointment.Name = 'Test Appointment ' + num;
        TestAppointment.Appointment_Date__c = dtime;
        TestAppointment.Duration_in_minutes__c = duration;
        TestAppointment.Doctor__c = doctor.Id;
        TestAppointment.Patient__c = patient.Id;

        return TestAppointment;
    }

    public static String doctorsAssertion = 'SELECT Id FROM Doctor__c';
    public static String patientsAssertion = 'SELECT Id FROM Doctor__c';
    public static String appointmentsAssertion = 'SELECT Id FROM Appointment__c';
}
