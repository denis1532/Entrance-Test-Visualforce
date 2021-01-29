public class AppointmentsController {
    
    // Sort by field
    public String sortByField {get;set;}
    // Sort order
    private String ascOrDesc;
    // Pop-up
    public Boolean displayAppPopup{get;set;}
    public Boolean displayDocPopup{get;set;}
    // Picklist options
    public String selectedDocName {get;set;}
    public String selectedPatientName {get;set;}
    
    public String docQuery;
        
    public AppointmentsController() {
        // Initialization properties
        this.sortByField = 'Doctor__r.Name';
        this.ascOrDesc = ' ASC ';
        this.docQuery = '';
    }
    
    public List<SelectOption> getSelectedDoc() {
        List<SelectOption> docs = new List<SelectOption>();
        docs.add(new SelectOption('','-All-'));
        for (Doctor__c d : [SELECT Id, Name FROM Doctor__c]) {
            docs.add(new SelectOption(d.Name, d.Name));
        }
        return docs;
    }
    
    public String getSelectedDocName(){
        return selectedDocName;
    }
    
    public void setSelectedDocName(){
        this.selectedDocName = selectedDocName;
    }
    
    public List<SelectOption> getSelectedPatient() {
        List<SelectOption> patients = new List<SelectOption>();
        patients.add(new SelectOption('','-All-'));
        for (Patient__c p : [SELECT Id, Name FROM Patient__c]) {
            patients.add(new SelectOption(p.Name, p.Name));
        }
        return patients;
    }
        
    public List<Appointment__c> getApps() {
        // Solution with ternary operator
        if (selectedDocName == null && selectedPatientName == null) {
        	this.docQuery = '';
        } else {
            this.docQuery = 'WHERE ' + 
                (selectedDocName != null ? 'Doctor__r.Name = ' + '\'' + selectedDocName + '\'' : '') + 
                (selectedDocName != null && selectedPatientName != null ? ' AND ' : '') + 
        		(selectedPatientName != null ? 'Patient__r.Name = ' + '\'' + selectedPatientName + '\'' : '');
        }
        
        // Solution with several if, else if
		/*
        if (selectedDocName == null && selectedPatientName == null) {
        	this.docQuery = '';
        } else if (selectedDocName != null && selectedPatientName == null) {
            this.docQuery = 'WHERE Doctor__r.Name = ' + '\'' + selectedDocName + '\'';
        } else if (selectedDocName == null && selectedPatientName != null) {
			this.docQuery = 'WHERE Patient__r.Name = ' + '\'' + selectedPatientName + '\'';         
        } else {
            this.docQuery = 'WHERE Doctor__r.Name = ' + '\'' + selectedDocName + '\'' + ' AND Patient__r.Name = ' + '\'' + selectedPatientName + '\'';
        }*/
        
        List<Appointment__c> results = Database.query('SELECT Id, Doctor__r.Name, Patient__r.Name, Appointment_Date__c, Duration_in_minutes__c  ' +
                                                      'FROM Appointment__c ' + docQuery +
                                                      'ORDER BY ' + sortByField + ascOrDesc);
        return results;
    }
    
    // Field order
    public void sortOrder() {
        if (ascOrDesc == ' ASC ') {
            ascOrDesc = ' DESC ';
        } else {
            ascOrDesc = ' ASC ';
        }
    }
    
    // POP-UP

    // Show pop-up
    public void showAppPopup() { 
    	displayAppPopup = true; 
    }
    
    public void showDocPopup() { 
    	displayDocPopup = true; 
    }
    
	// Hide pop-up window
  	public void closeAppPopup() { 
        displayAppPopup = false; 
    }
    
    public void closeDocPopup() { 
        displayDocPopup = false; 
    }
}