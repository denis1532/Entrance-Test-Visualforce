import { LightningElement, api, track, wire } from 'lwc';
import utils from 'c/utils';
import timeZone from '@salesforce/i18n/timeZone';
import getDoctors from '@salesforce/apex/AppointmentsControllerLWC.getDoctors';
import getWorkingHours from '@salesforce/apex/AppointmentsControllerLWC.getDoctors';
import getPatients from '@salesforce/apex/AppointmentsControllerLWC.getPatients';
import getAppointments from '@salesforce/apex/AppointmentsControllerLWC.getAppointments';

const TIME_ZONE = timeZone;

const COLUMNS = [
    { label: 'Action', fieldName: 'viewLink', type: 'url', typeAttributes: {
        label: 'View',
        tooltip: { fieldName: 'tooltip' },
        target: '_self' }
    },
    { label: 'Doctor\'s Name', fieldName: 'doctorName', type: 'text' },
    { label: 'Patient\'s Name', fieldName: 'patientName', type: 'text' },
    { label: 'Date', fieldName: 'Appointment_Date__c', type: 'date', typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
        timeZoneName: 'short',
        timeZone: TIME_ZONE }
    },
    { label: 'Duration', fieldName: 'Duration_in_minutes__c', type: 'number' },
    { type: 'button', typeAttributes: {
        iconName: 'utility:delete',
        label: 'Delete',
        name: 'Delete',
        variant: 'destructive' }
    }
];

const PAGE_SIZES = [
    { 'label': '10', 'value': '10' },
    { 'label': '15', 'value': '15' },
    { 'label': '20', 'value': '20' }
]

export default class AppointmentsTableLWC extends LightningElement {
    columns = COLUMNS;

    pageSizes = PAGE_SIZES;
    @track selectedPagesize = this.pageSizes[0].value;

    @track doctors;
    @track patients;
    @track selectedDoctor;
    @track selectedPatient;

    @track appointments;

    @track displayWorkingHours = false;

    @track displayData;

    @wire(getDoctors)
    wiredDoctors({ error, data }) {
        if (data) {
            /* let paramStr1 = JSON.stringify(this.doctors, null, 4);
            console.log('Docs before: ' + paramStr1);

            for (var doctor in data) {
                this.doctors.push({
                    label: data[doctor].Name,
                    value: data[doctor].Id
                })
            }

            data.forEach(r => {
                this.doctors.push({
                    label: r.Name,
                    value: r.Id
                })
            })

            let paramStr2 = JSON.stringify(this.doctors, null, 4);
            console.log('Docs after: ' + paramStr2); */
            let doctorOptions = utils.getOptions(data);

            this.doctors = doctorOptions;
            this.selectedDoctor = this.doctors[0].value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    /* @wire(getWorkingHours,  {selectedDoctor: '$selectedDoctor'})
    wiredWorkinghours({ error, data }) {
        if(data) {

        }
    } */

    @wire(getPatients)
    wiredPatients({ error, data }) {
        if (data) {
            let patientOptions = utils.getOptions(data);

            this.patients = patientOptions;
            this.selectedPatient = this.patients[0].value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    @wire(getAppointments, {selectedDoctor: '$selectedDoctor', selectedPatient: '$selectedPatient', pageSize: '$selectedPagesize'})
    wiredAppointments({ error, data }) {
        if (data) {
            let tempRecordsList = [];

            if (data.appointments.length > 0) {
                this.displayData = true;
            } else {
                this.displayData = false;
            }

            data.appointments.forEach(row => {
                let tempRow = Object.assign({}, row);

                tempRow.viewLink = '/' + row.Id;
                tempRow.tooltip = row.Name;
                tempRow.doctorName = row.Doctor__r.Name;
                tempRow.patientName = row.Patient__r.Name;

                tempRecordsList.push(tempRow);
            });

            this.appointments = tempRecordsList;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    onDoctorChange(event) {
        this.selectedDoctor = event.target.value;
    }

    onPatientChange(event) {
        this.selectedPatient = event.target.value;
    }

    onPagesizeChange(event) {
        this.selectedPagesize = event.target.value;
    }

    onDoctorClear() {
        this.selectedDoctor = '';
    }

    onPatientClear() {
        this.selectedPatient = '';
    }

}

/* var paramStr = JSON.stringify(event.getParams(), null, 4);
console.log(paramStr); */