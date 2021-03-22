public class AppointmentsController {
    // Query string
    public String query;
    public String workingHoursQuery;

    // Additions to queries
    public String doctorsAndPatientsQuery;
    public String workingHours;
    public String dateQuery;
    public String durationQuery;

    // Total records query
    public String totalRecordsNumber;

    // Sort by field
    public String sortOrder {get;set;}
    // Sort order
    private String ascOrDesc;

    // Picklist options
    public String selectedDoctorId {get;set;}
    public String selectedPatientId {get;set;}

    // Date search
    public Datetime searchDateTime {get;set;}
    // Comparison for date query
    Date conversedDate;
    Datetime lowerComparisonDate;
    Datetime upperComparisonDate;
    String formattedLower;
    String formattedUpper;

    // Duration search
    public Integer searchDuration {get;set;}

    // Pagination
    private Integer counter;
    private Integer listSize;
    public Integer totalSize {get;set;}

    // Add New Appointment
    public Appointment__c NewAppointment {get;set;}

    /*** ---------- Init ---------- ***/
    public AppointmentsController() {
        // Initialization properties
        this.sortOrder = 'Doctor__r.Name';
        this.ascOrDesc = ' ASC ';
        this.counter = 0;
        this.listSize = 10;
        this.NewAppointment = new Appointment__c();
    }

    /*** ---------- Picklists ---------- ***/

    // Adding options to DOCTOR picklist
    public List<SelectOption> getSelectedDoctor() {
        List<SelectOption> doctors = new List<SelectOption>();
        doctors.add(new SelectOption('','-All-'));
        for (Doctor__c doctor : [SELECT Id, Name FROM Doctor__c ORDER BY Name ASC]) {
            doctors.add(new SelectOption(doctor.Id, doctor.Name));
        }

        return doctors;
    }

    // Adding options to PATIENT picklist
    public List<SelectOption> getSelectedPatient() {
        List<SelectOption> patients = new List<SelectOption>();
        patients.add(new SelectOption('','-All-'));
        for (Patient__c patient : [SELECT Id, Name FROM Patient__c ORDER BY Name ASC]) {
            patients.add(new SelectOption(patient.Id, patient.Name));
        }

        return patients;
    }

    /*** ---------- Main ---------- ***/
    /*** Table results ***/
    public List<Appointment__c> getAppointments() {
        // Getting DOCTOR and PATIENT picklist value
        if (selectedDoctorId == null && selectedPatientId == null) {
            this.doctorsAndPatientsQuery = '';

            this.NewAppointment.Doctor__c = null;
            this.NewAppointment.Patient__c = null;
        } else {
            this.NewAppointment.Doctor__c = selectedDoctorId;
            this.NewAppointment.Patient__c = selectedPatientId;

            this.doctorsAndPatientsQuery = 'WHERE (' +
                (selectedDoctorId != null ? 'Doctor__r.Id = ' + '\'' + selectedDoctorId + '\'' : '') +
                (selectedDoctorId != null && selectedPatientId != null ? ' AND ' : '') +
        		(selectedPatientId != null ? 'Patient__r.Id = ' + '\'' + selectedPatientId + '\'' : '') +
                ') ';
        }

        // Setting date query
        if (searchDateTime == null) {
            this.dateQuery = '';

            this.NewAppointment.Appointment_Date__c = null;
            this.searchDateTime = null;
        } else {
            this.NewAppointment.Appointment_Date__c = searchDateTime;

            conversedDate = Date.newInstance(searchDateTime.year(), searchDateTime.month(), searchDateTime.day());

            lowerComparisonDate = conversedDate;
            upperComparisonDate = conversedDate.addDays(1);

            // Formatting to ISO date value to enable comparison in query
            formattedLower = lowerComparisonDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            formattedUpper = upperComparisonDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

            this.dateQuery = (selectedDoctorId == null && selectedPatientId == null
                              ? 'WHERE (Appointment_Date__c >= ' + formattedLower + ' AND Appointment_Date__c < ' + formattedUpper + ') '
                              : 'AND (Appointment_Date__c >= ' + formattedLower + ' AND Appointment_Date__c < ' + formattedUpper + ') '
                             );
        }

        // Setting duration query
        if (searchDuration == 0 || searchDuration == null) {
            this.durationQuery = '';

            this.NewAppointment.Duration_in_minutes__c = null;
            this.searchDuration = null;
        } else {
            this.NewAppointment.Duration_in_minutes__c = searchDuration;

            this.durationQuery = (selectedDoctorId == null && selectedPatientId == null && searchDateTime == null
                                  ? 'WHERE (Duration_in_minutes__c = ' + searchDuration + ') '
                                  : 'AND (Duration_in_minutes__c = ' + searchDuration + ') '
                                 );
        }

        // Customizing main query
        query = 'SELECT Id, Doctor__r.Name, Doctor__r.Working_Hours_Start__c, Doctor__r.Working_Hours_End__c, Patient__r.Name, Appointment_Date__c, Duration_in_minutes__c  ' +
            	'FROM Appointment__c ' +
            	doctorsAndPatientsQuery +
            	dateQuery +
            	durationQuery +
            	'ORDER BY ' + sortOrder + ascOrDesc + 'NULLS LAST ' +
            	'LIMIT :listSize OFFSET :counter';

        List<Appointment__c> results = Database.query(query);

        // Pagination total pages variable
        totalRecordsNumber = 'SELECT Count() ' +
            				 'FROM Appointment__c ' +
            				 doctorsAndPatientsQuery +
            				 dateQuery +
            				 durationQuery;
        this.totalSize = Database.countQuery(totalRecordsNumber);

        return results;
    }

    /***  Working hours section results ***/
    public List<Doctor__c> getHours() {
        if (selectedDoctorId == null) {
            this.workingHoursQuery = '';

            return null;
        } else {
            this.workingHours = 'WHERE Doctor__c.Id = ' + '\'' + selectedDoctorId + '\'';
        }

        // Customizing hours query
        workingHoursQuery = 'SELECT Id, Name, Working_Hours_Start__c, Working_Hours_End__c ' +
            				'FROM Doctor__c ' +
            				workingHours;

        // Returnin hours query results
        List<Doctor__c> hours = Database.query(workingHoursQuery);
        return hours;
    }

    /*** Field order ***/
    public void sortByField() {
        if (ascOrDesc == ' ASC ') {
            ascOrDesc = ' DESC ';
        } else {
            ascOrDesc = ' ASC ';
        }
    }

    /*** ---------- New Appointment ---------- ***/

    // Add New Appointment
    public PageReference saveNewAppointment() {
        try {
            insert NewAppointment;
            this.NewAppointment = new Appointment__c();
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    /*** ---------- Clear fields buttons ---------- ***/

    // Reset doctor's picklist
    public PageReference resetSearchAppointmentsByDoctor() {
        counter = 0;
        this.selectedDoctorId = null;
        return null;
    }

    // Reset patient's picklist
    public PageReference resetSearchAppointmentsByPatient() {
        counter = 0;
        this.selectedPatientId = null;
        return null;
    }

    // Reset date field
    public PageReference resetSearchAppointmentByDate() {
        counter = 0;
        this.searchDateTime = null;
        return null;
    }

    // Reset duration field
    public PageReference resetSearchAppointmentByDuration() {
        counter = 0;
        this.searchDuration = null;
        return null;
    }

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
}
