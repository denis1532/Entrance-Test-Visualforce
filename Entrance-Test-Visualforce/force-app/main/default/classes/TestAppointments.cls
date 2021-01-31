@isTest
private class TestAppointments {
	
    static testmethod void testAppointmentsController() {
        
        AppointmentsController appntCont = new AppointmentsController();
        
        /*** ***/
        List<Appointment__c> apnt = appntCont.getApps();
        appntCont.sortOrder = 'Name';
        appntCont.sortByField();
        appntCont.sortOrder = 'Doctor__r.Name';
        appntCont.sortByField();
        
        // New doctor
        Datetime curDateTime = Datetime.now();
        Time curTime = curDateTime.time();
        Time futureTime = curTime.addMinutes(50);
        
        Doctor__c NewDoctor = new Doctor__c();
        NewDoctor.Name = 'Test';
        NewDoctor.Working_Hours_Start__c = curTime;
        NewDoctor.Working_Hours_End__c = futureTime;
        Insert NewDoctor;
        system.debug(NewDoctor);
        
        // New patient
        Patient__c NewPatient = new Patient__c();
        NewPatient.Name = 'Test';
        Insert NewPatient;
        system.debug(NewPatient);
        
        // Doctor picklist
        List<SelectOption> selOptsDoctor = appntCont.getSelectedDoc();
        
        // Patient picklist
        List<SelectOption> selOptsPatient = appntCont.getSelectedPatient();
        
        // Working hours values
        List<Doctor__c> hoursList = appntCont.getHours();
        
        /*** PAGINATION ***/
        
        List<Doctor__c> doctorsListPagination = [SELECT Id FROM Doctor__c];
        List<Patient__c> patientsListPagination = [SELECT Id FROM Patient__c];
        
        // Test pagination
        List<Appointment__c> appntList = new List<Appointment__c>();
        Datetime testAppntDate = Datetime.now();
        
        for (Integer i = 0; i < 15; i++) {
            appntList.add(new Appointment__c(Name = 'Test ' + i,
                                             Appointment_Date__c = testAppntDate.addMinutes(i),
                                             Duration_in_minutes__c = i,
                                             Doctor__c = doctorsListPagination[0].Id,
                                             Patient__c = patientsListPagination[0].Id
                                             ));
        }
        insert appntList;
        
        // Test getTotalPages
        appntCont.getApps();
        System.assertEquals(2, appntCont.getTotalPages());
        
        // Test getPageNumber method
        System.assertEquals(1, appntCont.getPageNumber());
        
        // Test Next method
        appntCont.Next();
        System.assertEquals(2, appntCont.getPageNumber());

        // Test Previous method
        appntCont.Previous();
        System.assertEquals(1, appntCont.getPageNumber());
        
        // Test End method
        appntCont.End();
        System.assertEquals(2, appntCont.getPageNumber());
        
        // Test getDisableNextEnd method
        System.assertEquals(true, appntCont.getDisableNextEnd());
        
        // Test Beginning method
        appntCont.Beginning();
        System.assertEquals(1, appntCont.getPageNumber());
                
        // Test getDisableBeginningPrevious method
        System.assertEquals(true, appntCont.getDisableBeginningPrevious()); 
   
    }
    
}