import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import utils from 'c/utils';
import timeZone from '@salesforce/i18n/timeZone';
import getDoctors from '@salesforce/apex/AppointmentsLWCCtr.getDoctors';
import getWorkingHours from '@salesforce/apex/AppointmentsLWCCtr.getWorkingHours';
import getPatients from '@salesforce/apex/AppointmentsLWCCtr.getPatients';
import getAppointments from '@salesforce/apex/AppointmentsLWCCtr.getAppointments';
import saveAppointment from '@salesforce/apex/AppointmentsLWCCtr.saveAppointment';
import deleteAppointment from '@salesforce/apex/AppointmentsLWCCtr.deleteAppointment';

const TIME_ZONE = timeZone;

const COLUMNS = [
    { label: 'Action', fieldName: 'viewLink', type: 'url', typeAttributes: {
        label: 'View',
        tooltip: { fieldName: 'tooltip' },
        target: '_self' }
    },
    { label: 'Doctor\'s Name', fieldName: 'doctorName', type: 'text', sortable: 'true' },
    { label: 'Patient\'s Name', fieldName: 'patientName', type: 'text', sortable: 'true' },
    { label: 'Date', fieldName: 'Appointment_Date__c', type: 'date', sortable: 'true', typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
        timeZoneName: 'short',
        timeZone: TIME_ZONE }
    },
    { label: 'Duration', fieldName: 'Duration_in_minutes__c', type: 'number', sortable: 'true' },
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
    selectedPagesize = this.pageSizes[0].value;

    @track doctors = '';
    @track patients = '';
    selectedDoctor = '';
    selectedPatient = '';
    datetime = '';
    duration = '';

    pageNumber = 1;
    totalRecords = '';
    recordStart = '';
    recordEnd = '';
    totalPages = '';

    defaultSortDirection = 'asc';
    sortedDirection;
    sortedBy;

    @track appointments;
    wiredAppointmentsData;

    displayWorkingHours = false;
    workingHoursStart;
    workingHoursEnd;

    displayData;

    appointmentToDelete;
    appointmentToDeleteLink;
    showConfirmDialog = false;

    disabledNextButton;
    disabledPrevButton;

    startingRecordNumber;
    endingRecordNumber;

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

    @wire(getPatients)
    wiredPatients(result) {
        if (result.data) {
            let patientOptions = utils.getOptions(result.data);

            this.patients = patientOptions;
            this.selectedPatient = this.patients[0].value;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    @wire(getAppointments, {selectedDoctor: '$selectedDoctor', selectedPatient: '$selectedPatient', selectedDatetime: '$datetime', selectedDuration: '$duration', pageNumber: '$pageNumber', pageSize: '$selectedPagesize'})
    wiredAppointments(result) {
        this.wiredAppointmentsData = result;

        if (result.data) {
            let tempRecordsList = [];

            if (result.data.appointments.length > 0) {
                this.displayData = true;
            } else {
                this.displayData = false;
            }

            this.totalRecords = result.data.totalRecords;
            this.recordStart = result.data.recordStart;
            this.recordEnd = result.data.recordEnd;
            this.totalPages = Math.ceil(result.data.totalRecords / this.selectedPagesize);

            this.startingRecordNumber = (this.pageNumber - 1) * this.selectedPagesize;
            this.endingRecordNumber = (this.pageNumber - 1) * this.selectedPagesize + result.data.appointments.length;

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

            result.data.appointments.forEach(row => {
                let tempRow = Object.assign({}, row);

                tempRow.viewLink = '/' + row.Id;
                tempRow.tooltip = row.Name;
                tempRow.doctorName = row.Doctor__r.Name;
                tempRow.patientName = row.Patient__r.Name;

                tempRecordsList.push(tempRow);
            });

            this.appointments = tempRecordsList;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    onSetToday() {
        let today = new Date();

        this.datetime = today.toISOString();

        this.pageNumber = 1;
    }

    onDoctorChange(event) {
        this.selectedDoctor = event.target.value;

        this.pageNumber = 1;

        this.getDoctorWorkingHours();
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

        this.displayWorkingHours = false;
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
        this.duration = '';

        this.pageNumber = 1;
    }

    getDoctorWorkingHours() {
        if (this.selectedDoctor && typeof this.selectedDoctor !== "undefined") {
            this.displayWorkingHours = true;
            getWorkingHours({
                selectedDoctor: this.selectedDoctor
            })
            .then(result => {
                let unixTimeStart = result[0].Working_Hours_Start__c;
                let unixTimeEnd = result[0].Working_Hours_End__c;

                let dateStart = new Date(unixTimeStart);
                let dateEnd = new Date(unixTimeEnd);

                this.workingHoursStart = utils.formatAMPM(dateStart);
                this.workingHoursEnd = utils.formatAMPM(dateEnd);
            })
        } else {
            this.displayWorkingHours = false;
        }
    }

    handleSaveAppointment() {
        if (!this.selectedDoctor || !this.selectedPatient || !this.datetime || !this.duration) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Warning!',
                    message: 'Please, fill in all the fields before creating an appointment!',
                    variant: 'warning',
                    mode: 'dismissable'
                }),
            );
        } else {
            saveAppointment({
                selectedDoctor: this.selectedDoctor,
                selectedPatient: this.selectedPatient,
                selectedDate: this.datetime,
                selectedDuration: this.duration
            })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success!',
                        message: 'New appointment has been created! See it {0}!',
                        messageData: [{ url: '/' + result.Id, label: 'here' }],
                        variant: 'success',
                        mode: 'pester'
                    })
                );
                return refreshApex(this.wiredAppointmentsData);
            })
            .catch(error => {
                this.error = error;

                error.body.pageErrors.forEach(pageError => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating an appointment',
                            message: pageError.message,
                            variant: 'error'
                        }),
                    )
                })
                console.log(error);
            })
        }
    }

    handleDeleteAppointment() {
        deleteAppointment({
            appointmentToDelete: JSON.stringify(this.appointmentToDelete)
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success!',
                    message: 'Appointment {0} has been deleted!',
                    messageData: ['"' + this.appointmentToDelete.Name + '"'],
                    variant: 'success',
                    mode: 'pester'
                })
            );

            this.appointmentToDelete = '';
            this.appointmentToDeleteLink = '';

            return refreshApex(this.wiredAppointmentsData);
        })
        .catch(error => {
            console.log(error);
        })
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection)
    }

    sortData(fieldName, direction) {
        let parsedData = JSON.parse(JSON.stringify(this.appointments));

        let keyValue = (a) => {
            return a[fieldName]
        };

        let isReverse = direction === 'asc' ? 1 : -1;

        parsedData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x))
        });

        this.appointments = parsedData;
    }

    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let record = event.detail.row;

        if (actionName === 'Delete') {
            this.appointmentToDelete = record;
            this.appointmentToDeleteLink = '/' + record.Id;
            this.showConfirmDialog = true;
        }
    }

    handleHideDialog() {
        this.showConfirmDialog = false;

        this.appointmentToDelete = '';
        this.appointmentToDeleteLink = '';
    }

    handleDialogYes() {
        this.handleDeleteAppointment();

        this.showConfirmDialog = false;
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