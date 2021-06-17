public class AppointmentsControllerAura {

    public class AppointmentsDatatableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Contact> contactList {get;set;}
    }
    
    @AuraEnabled
    public static List<Doctor__c> getDoctors() {
        List<Doctor__c> doctors = [SELECT Id, Name FROM Doctor__c ORDER BY Name LIMIT 50000];
        return doctors;
    }
    
    @AuraEnabled
    public static List<Patient__c> getPatients() {
        List<Patient__c> patients = [SELECT Id, Name FROM Patient__c ORDER BY Name LIMIT 50000];
        return patients;
    }
    
    @AuraEnabled
    public static List<Appointment__c> getAppointments(String selectedDoctor, String selectedPatient, String selectedDate, String selectedDuration, Integer pageNumber, Integer pageSize) {
        String condition = generateConditionString(selectedDoctor, selectedPatient, selectedDate, selectedDuration);
        String query = generateQuery(condition, pageNumber, pageSize);
        
        system.debug('Date: ' + selectedDate);
        if(!String.isEmpty(selectedDate)) {
            //Datetime dt = Datetime.parse(selectedDate);
            //system.debug('Converted from String to Datetime: ' + dt);
            //Datetime dtn = Datetime.newInstanceGmt(dt.day(), dt.month(), dt.day());
            //system.debug('New Instance: ' + dt);
        }
        
        List<Appointment__c> appointments = Database.query(query);

        return appointments;
    }
    
    @AuraEnabled
    public static void deleteAppointment(String appointmentToDelete) {       
        Appointment__c carp = (Appointment__c)JSON.deserialize(appointmentToDelete, Appointment__c.class);
        
        delete carp;
    }
    
    private static String firstFilter(String selectedDoctor, String selectedPatient) {
        string firstFilter = '';
        
        string doctorFilter = '';
        string patientFilter = '';
        
        if (!String.isEmpty(selectedDoctor)) {
            doctorFilter = ' Doctor__r.Id=' + '\'' + selectedDoctor + '\'';
            firstFilter = doctorFilter;
        }
        
        if (!String.isEmpty(selectedPatient)) {
            patientFilter = ' Patient__r.Id=' + '\'' + selectedPatient + '\'';
            firstFilter = patientFilter;
        }
        
        if (!String.isEmpty(doctorFilter) && !String.isEmpty(patientFilter)) {
            firstFilter = doctorFilter;
            firstFilter += ' AND ';
            firstFilter += patientFilter;
        }
        
        return firstFilter;
    }
    
    private static String thirdFilter(String selectedDuration) {
        String thirdFilter = '';
        
        if(!String.isEmpty(selectedDuration)) {
            thirdFilter = '  Duration_in_minutes__c=' + selectedDuration;
        }
        
        return thirdFilter;
    }
    
    private static String generateConditionString(String selectedDoctor, String selectedPatient, String selectedDate, String selectedDuration) {
        String conditionString = '';
        
        String firstFilter = firstFilter(selectedDoctor, selectedPatient);
        String thirdFilter = thirdFilter(selectedDuration);
        
        if(!String.isEmpty(firstFilter)) {
            conditionString = '(' + firstFilter + ')';
        }
        
        if(!String.isEmpty(thirdFilter)) {
            conditionString = '(' + thirdFilter + ')';
        }
        
        if(!String.isEmpty(firstFilter) && !String.isEmpty(thirdFilter)) {
            conditionString = firstFilter + ' AND ' + thirdFilter;
        }
        
        system.debug(conditionString);
        
        return conditionString;
    }
    
    private static String generateQuery(String condition, Integer pageNumber, Integer pageSize) {
        Integer offset = (pageNumber - 1) * pageSize;

        Integer totalRecords = [SELECT COUNT() FROM Contact];
        Integer recordEnd = pageSize * pageNumber;
        
        AppointmentsDatatableWrapper appntDT =  new AppointmentsDatatableWrapper();  
        appntDT.pageSize = pageSize;
        appntDT.pageNumber = pageNumber;
        appntDT.recordStart = offset + 1;
        appntDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        appntDT.totalRecords = totalRecords;
        
        String generatedQuery = 'SELECT Id, Name, Doctor__r.Name, Patient__r.Name, Appointment_Date__c, Duration_in_minutes__c ';
        generatedQuery += 'FROM Appointment__c ';
        
        if (condition != '') {
            generatedQuery += ' WHERE ';
            generatedQuery += condition;
        }
        
        generatedQuery += ' ORDER BY Name';
        generatedQuery += ' LIMIT ' + pageSize;
        generatedQuery += ' OFFSET ' + offset;
        
        return generatedQuery;
    }
}