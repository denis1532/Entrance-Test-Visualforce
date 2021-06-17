({
    init : function (cmp, event, helper) {
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
                timeZone: 'UTC' }
            }, // FIX DATETIME DIFFERENCES
            { label: 'Duration', fieldName: 'Duration_in_minutes__c', type: 'number' },
            { type: 'button', typeAttributes: {
                iconName: 'utility:delete',
                label: 'Delete',
                name: 'Delete',
                variant: 'destructive' }
            }
        ]);

        helper.getDoctors(cmp);
        helper.getPatients(cmp);
        helper.getData(cmp);
        helper.getToday(cmp);
        helper.setPagesize(cmp);
    },

    /*getSelectedRow : function (cmp, event, helper) {
        var selectedRow = event.getParam("selectedRow");
        cmp.set("v.selectedRow", selectedRow);
    },*/

    handleRowAction : function (cmp, event, helper) {
        helper.deleteRecordAction(cmp, event, helper);
    },

    handleHideDialog : function (cmp, event, helper) {
        helper.hideConfirmDialog(cmp, event, helper);
    },

    /*handleConfirmDialogYes : function (cmp, event, helper) {
        console.log('--- EVENT 1 ---');

        helper.hideConfirmDialog(cmp, event, helper);
    },*/

    onDoctorChange : function (cmp, event, helper) {
        helper.doctorChanged(cmp, event);
    },

    onPatientChange : function (cmp, event, helper) {
        helper.patientChanged(cmp, event);
    },

    onAppointmentDateChange : function (cmp, event, helper) {
        helper.appointmentDateChanged(cmp, event);
    },

    onDurationChange : function (cmp, event, helper) {
        helper.durationChanged(cmp, event);
    },

    onPagesizeChange : function (cmp, event, helper) {
        helper.pagesizeChanged(cmp, event);
    },

    clearDoctorSelect : function (cmp, event, helper) {
        helper.doctorSelectCleared(cmp, event);
    },

    clearPatientSelect : function (cmp, event, helper) {
        helper.patientSelectCleared (cmp, event);
    },

    clearDuration : function (cmp, event, helper) {
        helper.durationCleared (cmp, event);
    },

    handleNext : function (cmp, event, helper) {
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber + 1);
        helper.getData(cmp);
    },

    handlePrev : function (cmp, event, helper) {
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber - 1);
        helper.getData(cmp);
    },

    showWaiting : function(cmp){
        //console.log('Show Waiting');
    },

    hideWaiting : function(cmp){
        //console.log('Hide Waiting');
    },

    handleFocus : function(cmp){

    },

    handleBlur : function(cmp){

    }
});
