public class AppointmentsControllerAura {

    public class AppointmentsDatatableWrapper {
        @AuraEnabled
        public Integer pageSize { get;set; }
        @AuraEnabled
        public Integer pageNumber { get;set; }
        @AuraEnabled
        public Integer totalRecords { get;set; }
        @AuraEnabled
        public Integer recordStart { get;set; }
        @AuraEnabled
        public Integer recordEnd { get;set; }
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

        List<Appointment__c> appointments = Database.query(query);

        return appointments;
    }

    @AuraEnabled
    public static void deleteAppointment(String appointmentToDelete) {
        Appointment__c appointment = (Appointment__c)JSON.deserialize(appointmentToDelete, Appointment__c.class);

        delete appointment;
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

    private static String secondFilter(String selectedDate) {
        string secondFilter = '';

        if(!String.isEmpty(selectedDate)) {
            Datetime deserializedDatetime = (Datetime)JSON.deserialize('"' + selectedDate + '"', DateTime.class);

            Datetime lowerDatetime = Date.newInstance(deserializedDatetime.year(), deserializedDatetime.month(), deserializedDatetime.day());
            Datetime higherDatetime = lowerDatetime.addDays(1);

                                                                                    // lowerDatetime = 2021-06-17 00:00:00
            String test1 = lowerDatetime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');    // 2021-06-16T17:00:00.000-0700
            String test2 = lowerDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); // 2021-06-17T00:00:00.000+0000
            String test3 = JSON.serialize(lowerDatetime);                           // "2021-06-17T00:00:00.000Z"

            String formattedLower = JSON.serialize(lowerDatetime).remove('"');
            String formattedHigher = JSON.serialize(higherDatetime).remove('"');

            secondFilter = ' Appointment_Date__c >= ' + formattedLower + ' AND Appointment_Date__c < ' + formattedHigher;

            // почему Datetime dt = (Datetime)JSON.deserialize(selectedDate, DateTime.class); возвращает 2021-01-01 00:00:00
            // а Datetime dt = (Datetime)JSON.deserialize('"' + selectedDate + '"', DateTime.class); возвращает нормальную дату и время
        }

        return secondFilter;
    }

    private static String thirdFilter(String selectedDuration) {
        String thirdFilter = '';

        if(!String.isEmpty(selectedDuration)) {
            thirdFilter = ' Duration_in_minutes__c=' + selectedDuration;
        }

        return thirdFilter;
    }

    private static String generateConditionString(String selectedDoctor, String selectedPatient, String selectedDate, String selectedDuration) {
        String conditionString = '';

        String firstFilter = firstFilter(selectedDoctor, selectedPatient);
        String secondFilter = secondFilter(selectedDate);
        String thirdFilter = thirdFilter(selectedDuration);

        if(!String.isEmpty(firstFilter)) {
            conditionString = '(' + firstFilter + ')';
        }

        if(!String.isEmpty(secondFilter)) {
            conditionString = '(' + secondFilter + ')';
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
