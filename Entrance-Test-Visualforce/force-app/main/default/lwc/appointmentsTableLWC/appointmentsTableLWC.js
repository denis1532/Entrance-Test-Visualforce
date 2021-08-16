import { LightningElement, api, track, wire } from 'lwc';
import utils from 'c/utils';
import timeZone from '@salesforce/i18n/timeZone';
import getDoctors from '@salesforce/apex/AppointmentsControllerLWC.getDoctors';
import getWorkingHours from '@salesforce/apex/AppointmentsControllerLWC.getWorkingHours';
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

    @track doctors = '';
    @track patients = '';
    @track selectedDoctor = '';
    @track selectedPatient = '';
    @track datetime = '';
    @track duration = '';

    @track pageNumber = 1;
    @track totalRecords = '';
    @track recordStart = '';
    @track recordEnd = '';
    @track totalPages = '';
    @track totalPages = '';

    @track disabledNextButton;
    @track disabledPrevButton;

    @track startingRecordNumber;
    @track endingRecordNumber;

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

    @wire(getAppointments, {selectedDoctor: '$selectedDoctor', selectedPatient: '$selectedPatient', selectedDatetime: '$datetime', selectedDuration: '$duration', pageNumber: '$pageNumber', pageSize: '$selectedPagesize'})
    wiredAppointments({ error, data }) {
        if (data) {
            let tempRecordsList = [];

            if (data.appointments.length > 0) {
                this.displayData = true;
            } else {
                this.displayData = false;
            }

            this.totalRecords = data.totalRecords;
            this.recordStart = data.recordStart;
            this.recordEnd = data.recordEnd;
            this.totalPages = Math.ceil(data.totalRecords / this.selectedPagesize);

            this.startingRecordNumber = (this.pageNumber - 1) * this.selectedPagesize;
            this.endingRecordNumber = (this.pageNumber - 1) * this.selectedPagesize + data.appointments.length;

            if (this.pageNumber == this.totalPages) {
                this.disabledNextButton = true;
            } else {
                this.disabledNextButton = false;
            }

            if (this.pageNumber == 1) {
                this.disabledPrevButton = true;
            } else {
                this.disabledPrevButton = false;
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

    onSetToday() {
        let today = new Date();

        this.datetime = today.toISOString();

        // this.pageNumber = 1;
    }

    onDoctorChange(event) {
        this.selectedDoctor = event.target.value;

        this.pageNumber = 1;
    }

    onPatientChange(event) {
        this.selectedPatient = event.target.value;

        this.pageNumber = 1;
    }

    onAppointmentDatetimeChange(event) {
        this.datetime = event.target.value;

        this.pageNumber = 1;
    }

    onDurationChange(event) {
        this.duration = event.target.value;

        this.pageNumber = 1;
    }

    onPagesizeChange(event) {
        this.selectedPagesize = event.target.value;

        this.pageNumber = 1;
    }

    onDoctorClear() {
        this.selectedDoctor = '';

        this.pageNumber = 1;
    }

    onPatientClear() {
        this.selectedPatient = '';

        this.pageNumber = 1;
    }

    onAppointmentDatetimeClear() {
        this.datetime = '';

        this.pageNumber = 1;
    }

    onDurationClear() {
        this.duration = null;

        this.pageNumber = 1;
    }

    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let record = event.detail.row;

        if (actionName === 'Delete') {
            console.log('Delete action');
        }
    }

    handleClickNext() {
        this.pageNumber = this.pageNumber + 1;
    }

    handleClickPrev() {
        this.pageNumber = this.pageNumber - 1;
    }

}

/* var paramStr = JSON.stringify(event.getParams(), null, 4);
console.log(paramStr); */