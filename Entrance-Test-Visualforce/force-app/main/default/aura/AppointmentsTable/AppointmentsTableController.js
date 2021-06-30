({
    init : function (cmp, event, helper) {
        var timezone = $A.get("$Locale.timezone");

        cmp.set('v.columns', [
            { label: 'Action', fieldName: 'viewLink', type: 'url', typeAttributes: {
                label: 'View',
                tooltip: { fieldName: 'tooltip' },
                target: '_self' }
            },
            { label: 'Doctor\'s Name', fieldName: 'DoctorName', type: 'text' },
            { label: 'Patient\'s Name', fieldName: 'PatientName', type: 'text' },
            { label: 'Date', fieldName: 'Appointment_Date__c', type: 'date', typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true,
                timeZoneName: 'short',
                timeZone: timezone }
            },
            { label: 'Duration', fieldName: 'Duration_in_minutes__c', type: 'number' },
            { type: 'button', typeAttributes: {
                iconName: 'utility:delete',
                label: 'Delete',
                name: 'Delete',
                variant: 'destructive' }
            }
        ]);

        var sizes = [
            { "label": "10", "value": "10" },
            { "label": "15", "value": "15" },
            { "label": "20", "value": "20" },
        ];

        cmp.set("v.pageSize", sizes);


        helper.getDoctors(cmp);
        helper.getPatients(cmp);
        helper.getData(cmp);
    },

    handleSaveAppointment : function (cmp, event, helper) {
        helper.saveNewAppointment(cmp, event, helper);
    },

    handleRowAction : function (cmp, event, helper) {
        helper.deleteRecordAction(cmp, event, helper);
    },

    handleHideDialog : function (cmp, event, helper) {
        helper.hideConfirmDialog(cmp, helper);
    },

    handleConfirmDialogYes : function (cmp, event, helper) {
        helper.confirmDialogYes(cmp);
        helper.hideConfirmDialog(cmp);
    },

    onDoctorChange : function (cmp, event, helper) {
        helper.doctorChanged(cmp);
    },

    onPatientChange : function (cmp, event, helper) {
        helper.patientChanged(cmp);
    },

    onAppointmentDateChange : function (cmp, event, helper) {
        helper.appointmentDateChanged(cmp);
    },

    onDurationChange : function (cmp, event, helper) {
        helper.durationChanged(cmp);
    },

    onPagesizeChange : function (cmp, event, helper) {
        helper.pagesizeChanged(cmp);
    },

    clearDoctorSelect : function (cmp, event, helper) {
        helper.doctorSelectCleared(cmp);
    },

    clearPatientSelect : function (cmp, event, helper) {
        helper.patientSelectCleared (cmp);
    },

    clearAppointmentDate : function (cmp, event, helper) {
        helper.appointmentDateCleared(cmp);
    },

    setToday : function (cmp, event, helper) {
        helper.getToday(cmp);
    },

    clearDuration : function (cmp, event, helper) {
        helper.durationCleared (cmp);
    },

    handleNext : function (cmp, event, helper) {
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber + 1);
        helper.updateData(cmp);
    },

    handlePrev : function (cmp, event, helper) {
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber - 1);
        helper.updateData(cmp);
    },
});
