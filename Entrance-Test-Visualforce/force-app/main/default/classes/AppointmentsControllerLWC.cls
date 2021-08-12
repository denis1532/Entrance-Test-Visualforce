public with sharing class AppointmentsControllerLWC {

    @AuraEnabled(cacheable=true)
    public static List<Doctor__c> getDoctors() {
        List<Doctor__c> doctors = [SELECT Id, Name, Working_Hours_Start__c, Working_Hours_End__c
                                   FROM Doctor__c
                                   ORDER BY Name
                                   LIMIT 50000];

        return doctors;
    }

}
