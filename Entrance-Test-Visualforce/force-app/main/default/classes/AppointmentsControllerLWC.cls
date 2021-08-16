public with sharing class AppointmentsControllerLWC {

    private class AppointmentsDatatableWrapper {
        @AuraEnabled
        public Integer pageSize { get; set; }

        @AuraEnabled
        public Integer pageNumber { get; set; }

        @AuraEnabled
        public Integer totalRecords { get; set; }

        @AuraEnabled
        public Integer recordStart { get; set; }

        @AuraEnabled
        public Integer recordEnd { get; set; }

        @AuraEnabled
        public List<Appointment__c> appointments { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Doctor__c> getDoctors() {
        List<Doctor__c> doctors = [SELECT Id, Name, Working_Hours_Start__c, Working_Hours_End__c
                                   FROM Doctor__c
                                   ORDER BY Name
                                   LIMIT 50000];

        return doctors;
    }

    @AuraEnabled(cacheable=true)
    public static List<Patient__c> getPatients() {
        List<Patient__c> patients = [SELECT Id, Name
                                     FROM Patient__c
                                     ORDER BY Name
                                     LIMIT 50000];

        return patients;
    }

    @AuraEnabled(cacheable=true)
    public static AppointmentsDatatableWrapper getAppointments(String selectedDoctor, String selectedPatient, String selectedDatetime, String selectedDuration, Integer pageNumber, Integer pageSize) {
        String condition = generateConditionString(selectedDoctor, selectedPatient, selectedDatetime, selectedDuration);
        String countQuery = generateCountQuery(condition);
        String query = generateQuery(condition);

        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = Database.countQuery(countQuery);

        AppointmentsDatatableWrapper appointmentWrapper =  new AppointmentsDatatableWrapper();
        appointmentWrapper.pageSize = pageSize;
        appointmentWrapper.pageNumber = pageNumber;
        appointmentWrapper.recordStart = offset + 1;
        appointmentWrapper.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        appointmentWrapper.totalRecords = totalRecords;

        query += ' LIMIT ' + pageSize;
        query += ' OFFSET ' + offset;

// System.debug(query);

        appointmentWrapper.appointments = Database.query(query);

        return appointmentWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<Doctor__c> getWorkingHours(String selectedDoctor) {
        String query = generateWorkingHoursQuery(selectedDoctor);

        List<Doctor__c> workingHours = Database.query(query);

        return workingHours;
    }

    private static String generateConditionString(String selectedDoctor, String selectedPatient, String selectedDatetime, String selectedDuration) {
        String conditionString = '';

        String firstFilter = firstFilter(selectedDoctor, selectedPatient);
        String secondFilter = secondFilter(selectedDatetime);
        String thirdFilter = thirdFilter(selectedDuration);

        if (!String.isEmpty(firstFilter)) {
            conditionString = '(' + firstFilter + ')';
        }

        if (!String.isEmpty(secondFilter)) {
            conditionString = '(' + secondFilter + ')';
        }

        if (!String.isEmpty(thirdFilter)) {
            conditionString = '(' + thirdFilter + ')';
        }

        if (!String.isEmpty(firstFilter) && !String.isEmpty(secondFilter)) {
            conditionString = '(' + firstFilter + ') AND (' + secondFilter + ')';
        }

        if (!String.isEmpty(firstFilter) && !String.isEmpty(thirdFilter)) {
            conditionString = '(' + firstFilter + ') AND (' + thirdFilter + ')';
        }

        if (!String.isEmpty(firstFilter) && !String.isEmpty(secondFilter) && !String.isEmpty(thirdFilter)) {
            conditionString = '(' + firstFilter + ') AND (' + secondFilter + ') AND (' + thirdFilter + ')';
        }

        return conditionString;
    }

    private static String firstFilter(String selectedDoctor, String selectedPatient) {
        string firstFilter = '';

        string doctorFilter = '';
        string patientFilter = '';

        if (!String.isEmpty(selectedDoctor)) {
            doctorFilter = 'Doctor__r.Id=' + '\'' + selectedDoctor + '\'';
            firstFilter = doctorFilter;
        }

        if (!String.isEmpty(selectedPatient)) {
            patientFilter = 'Patient__r.Id=' + '\'' + selectedPatient + '\'';
            firstFilter = patientFilter;
        }

        if (!String.isEmpty(doctorFilter) && !String.isEmpty(patientFilter)) {
            firstFilter = doctorFilter;
            firstFilter += ' AND ';
            firstFilter += patientFilter;
        }

        return firstFilter;
    }

    private static String secondFilter(String selectedDatetime) {
System.debug('Initial: ' + selectedDatetime);

        string secondFilter = '';

        if(!String.isEmpty(selectedDatetime)) {
            Datetime deserializedDatetime = (Datetime)JSON.deserialize('"' + selectedDatetime + '"', DateTime.class);

System.debug('Deserialized: ' + deserializedDatetime);
System.debug('Deserialized .day(): ' + deserializedDatetime.dayGmt());

            Integer year = deserializedDatetime.year();
            Integer month = deserializedDatetime.month();
            Integer day = deserializedDatetime.day();
            Integer dayGmt = deserializedDatetime.dayGmt();

            Datetime lowerDatetime = Date.newInstance(year, month, dayGmt);

            //
/* String aaa = UserInfo.getTimeZone().getID();

Datetime newDt1 = (Datetime)JSON.deserialize('"' + lowerDatetime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', aaa) + '"', Datetime.class);
System.debug('New: ' + newDt1);

Integer year1 = newDt1.year();
Integer month1 = newDt1.month();
Integer day1 = newDt1.day();
Integer dayGmt1 = newDt1.dayGmt();

Datetime lowerDt1 = Date.newInstance(year1, month1, dayGmt1);
Datetime higherDt1 = lowerDt1.addDays(1);

String formattedL = JSON.serialize(lowerDt1).remove('"');

System.debug(formattedL);

String formattedH = JSON.serialize(higherDt1).remove('"');

System.debug(formattedH); */
            //

            Datetime higherDatetime = lowerDatetime.addDays(1);
System.debug('Higher (+1 day): ' + higherDatetime);

            String formattedLower = JSON.serialize(lowerDatetime).remove('"');
            String formattedHigher = JSON.serialize(higherDatetime).remove('"');

            secondFilter = 'Appointment_Date__c >= ' + formattedLower + ' AND Appointment_Date__c < ' + formattedHigher;

            // почему Datetime dt = (Datetime)JSON.deserialize(selectedDatetime, DateTime.class); возвращает 2021-01-01 00:00:00
            // а Datetime dt = (Datetime)JSON.deserialize('"' + selectedDatetime + '"', DateTime.class); возвращает нормальную дату и время
        }

System.debug(secondFilter);

        return secondFilter;
    }

    private static String thirdFilter(String selectedDuration) {
        String thirdFilter = '';

        if(!String.isEmpty(selectedDuration)) {
            thirdFilter = ' Duration_in_minutes__c=' + selectedDuration;
        }

        return thirdFilter;
    }

    private static String generateQuery(String condition) {
        String generatedQuery = 'SELECT Id, Name, Doctor__r.Name, Patient__r.Name, Appointment_Date__c, Duration_in_minutes__c ';
        generatedQuery += 'FROM Appointment__c ';

        if (condition != '') {
            generatedQuery += ' WHERE ';
            generatedQuery += condition;
        }

        generatedQuery += ' ORDER BY Doctor__r.Name';

        return generatedQuery;
    }

    private static String generateCountQuery(String condition) {
        String generatedCountQuery = 'SELECT COUNT() ';
        generatedCountQuery += 'FROM Appointment__c ';

        if (condition != '') {
            generatedCountQuery += ' WHERE ';
            generatedCountQuery += condition;
        }

        return generatedCountQuery;
    }

    private static String generateWorkingHoursQuery(String selectedDoctor) {
        String generatedWorkingHoursQuery = 'SELECT Working_Hours_Start__c, Working_Hours_End__c ';
        generatedWorkingHoursQuery += 'FROM Doctor__c ';
        generatedWorkingHoursQuery += ' WHERE Doctor__c.Id=\'' + selectedDoctor + '\'';

        return generatedWorkingHoursQuery;
    }

}