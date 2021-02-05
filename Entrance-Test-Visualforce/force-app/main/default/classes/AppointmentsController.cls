public class AppointmentsController {
    // Query string
    public String query;
    public String workingHoursQuery;
    
    // Additions to queries   
    public String doctorsQuery;
    public String workingHours;
    
    // Total records query
    public String totalRecordsNumber;
    
    // Sort by field
    public String sortOrder {get;set;}
    // Sort order
    private String ascOrDesc;
    
    // Picklist options
    public String selectedDocName {get;set;}
    public String selectedPatientName {get;set;}
    
    /*** Tried to realize Appointment Date field in different ways, no result ***/
    
    // Date search
    public Datetime dat {get;set;}
    public Date dateName {get;set;}
    public String dateNameQuery;
    public Appointment__c dateNameApp {get;set;}
    
    public Date searchDate {get;set;}
    
    public String dateQuery;
    
    /*** ---------- ***/
    
    // Duration search
    public Integer searchDuration {get;set;}
    public String durationQuery;
    
    // Pagination
    private Integer counter = 0;
    private Integer listSize = 10;
    public Integer totalSize {get;set;}
    
    /*** ---------- Init ---------- ***/
    
    public AppointmentsController() {
        // Initialization properties
        this.sortOrder = 'Doctor__r.Name';
        this.ascOrDesc = ' ASC ';
        this.doctorsQuery = '';
        this.durationQuery = '';
        this.searchDuration = null;
    }
    
    /*** ---------- ***/
    
    /*** ---------- Picklists ---------- ***/
    
    // Adding options to DOCTOR picklist
    public List<SelectOption> getSelectedDoc() {
        List<SelectOption> doctors = new List<SelectOption>();
        doctors.add(new SelectOption('','-All-'));
        for (Doctor__c doctor : [SELECT Id, Name FROM Doctor__c ORDER BY Name ASC]) {
            doctors.add(new SelectOption(doctor.Name, doctor.Name));
        }
        return doctors;
    }
    
    // Adding options to PATIENT picklist
    public List<SelectOption> getSelectedPatient() {
        List<SelectOption> patients = new List<SelectOption>();
        patients.add(new SelectOption('','-All-'));
        for (Patient__c patient : [SELECT Id, Name FROM Patient__c ORDER BY Name ASC]) {
            patients.add(new SelectOption(patient.Name, patient.Name));
        }
        return patients;
    }
	
    /*** ---------- ***/
    
    /*** ---------- Main ---------- ***/
    
    // Table results
    public List<Appointment__c> getApps() {
        // Getting DOCTOR and PATIENT picklist value
        if (selectedDocName == null && selectedPatientName == null) {
            this.doctorsQuery = '';
            this.durationQuery = '';
        } else {
            this.doctorsQuery = 'WHERE (' + 
                (selectedDocName != null ? 'Doctor__r.Name = ' + '\'' + selectedDocName + '\'' : '') + 
                (selectedDocName != null && selectedPatientName != null ? ' AND ' : '') + 
        		(selectedPatientName != null ? 'Patient__r.Name = ' + '\'' + selectedPatientName + '\'' : '') + 
                ') ';
        }
        
        system.debug(selectedDocName);
        
        if (searchDuration == 0 || searchDuration == null) {
            this.durationQuery = '';
            this.searchDuration = null;
        } else {
            this.durationQuery = (selectedDocName == null && selectedPatientName == null 
                                  ? 'WHERE (Duration_in_minutes__c = ' + searchDuration + ') ' 
                                  : 'AND (Duration_in_minutes__c = ' + searchDuration + ') '
                                 );
        }
        
        if (searchDate == null) {
            this.dateQuery = '';
            this.searchDate = null;
        } else {
            //Datetime.newInstance(searchDate);
            
            Datetime lowerComparisonDate = searchDate;
            Datetime upperComparisonDate = searchDate.addDays(1);
            
            String formattedLower = lowerComparisonDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            String formattedUpper = upperComparisonDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            
            this.dateQuery = (selectedDocName == null && selectedPatientName == null 
                              ? 'WHERE (Appointment_Date__c < ' + formattedUpper + ' AND Appointment_Date__c >= ' + formattedLower + ') ' 
                              : 'AND (Appointment_Date__c < ' + formattedUpper + 'AND Appointment_Date__c >= ' + formattedLower + ') '
                             );
        }
        
        // Customizing main query 
        query = 'SELECT Id, Doctor__r.Name, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c, Patient__r.Name, Appointment_Date__c, Duration_in_minutes__c  ' +
            	'FROM Appointment__c ' + 
            	doctorsQuery + 
            	dateQuery + 
            	durationQuery + 
            	'ORDER BY ' + sortOrder + ascOrDesc + 'NULLS LAST ' + 
            	'LIMIT :listSize OFFSET :counter';
        
        // Returning main query results
        List<Appointment__c> results = Database.query(query);
        
        // Pagination total pages variable
        totalRecordsNumber = 'SELECT Count() ' + 'FROM Appointment__c ' + doctorsQuery + durationQuery;
        this.totalSize = Database.countQuery(totalRecordsNumber);

        return results;
    }
    
    // Working hours section results
    public List<Doctor__c> getHours() {
        if (selectedDocName == null) {
            /* List<Doctor__c> hours = new List<Doctor__c>();
             * 
             * tried making fields' labels visible, but without its' values (failed :( )
             * if null, then it this section isn't displayed at all
             */ 
            this.workingHours = '';
            return null;
        } else { // It isn't neccessary to write "else" here, but to make code more readable, I'd like to leave it as is 
            this.workingHours = 'WHERE Doctor__c.Name = ' + '\'' + selectedDocName + '\'';
        }
        
        // Customizing hours query
        workingHoursQuery = 'SELECT Id, Name, Working_Hours_Start__c, Working_Hours_End__c ' + 
            				'FROM Doctor__c ' + 
            				workingHours;
        
        // Returnin hours query results
        List<Doctor__c> hours = Database.query(workingHoursQuery);
        return hours;
    }
    
    // Field order
    public void sortByField() {
        if (ascOrDesc == ' ASC ') {
            ascOrDesc = ' DESC ';
        } else {
            ascOrDesc = ' ASC ';
        }
    }

	/*** ---------- ***/
    
    /*** ---------- Clear fields buttons ---------- ***/
    
    public PageReference resetSearchDoc() {
        counter = 0;
        this.selectedDocName = null;
        return null;
    }
    
    public PageReference resetSearchPatient() {
        counter = 0;
        this.selectedPatientName = null;
        return null;
    }
    
    public PageReference resetSearchAppointmentByDuration() {
        counter = 0;
        this.searchDuration = null;
        return null;
    }
    
    public PageReference resetSearchAppointmentByDate() {
        counter = 0;
        this.searchDate = null;
        return null;
    }
    
    /*** ---------- ***/
    
    /*** ---------- PAGINATION ---------- ***/
    
    // First Page
    public PageReference Beginning() { 
    	counter = 0;
      	return null;
    }

    // Previous Page
   	public PageReference Previous() {
      	counter -= listSize;
      	return null;
   	}

    // Next Page
   	public PageReference Next() { 
      	counter += listSize;
      	return null;
   	}

 	// Last Page
   	public PageReference End() { 
      	counter = totalSize - math.mod(totalSize, listSize);
      	return null;
   	}

   	// Disable first and previous buttons
    public Boolean getDisableBeginningPrevious() {
      	if (counter > 0) return false;
        else return true;
   	}

   	// Disable next and last buttons
    public Boolean getDisableNextEnd() {
      	if (counter + listSize < totalSize) return false; else return true;
   	}

    // Current page
   	public Integer getPageNumber() {
      	return counter/listSize + 1;
   	}
    
    // Pages counter
   	public Integer getTotalPages() {
      	if (math.mod(totalSize, listSize) > 0) {
         	return totalSize/listSize + 1;
      	} else {
         	return (totalSize/listSize);
      	}
   	}
    
    /*** ---------- ***/
}