({
    /* getData : function(cmp, doctorId, patientId, appointmentDate, duration, pageNumber, pageSize) {
        var action = cmp.get('c.getAppointments');

console.log('Page Number: ' + cmp.get("v.pageNumber"));

        if (doctorId && typeof doctorId !== "undefined") {
            action.setParam("selectedDoctor", doctorId);
        }

        if (patientId && typeof patientId !== "undefined") {
            action.setParam("selectedPatient", patientId);
        }

        if (appointmentDate && typeof appointmentDate !== "undefined") {
            action.setParam("selectedDate", appointmentDate);
        }

        if (duration && typeof duration !== "undefined") {
            action.setParam("selectedDuration", duration);
        }

        var pageNumber = cmp.get("v.pageNumber");
        if(pageNumber) {
            action.setParam("pageNumber", pageNumber);
        }

        var pageSize = cmp.find("pageSize").get("v.value");
        if(pageSize) {
            action.setParam("pageSize", pageSize);
        }

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var resultData = response.getReturnValue();

                for (var i = 0; i < resultData.length; i++) {
                    var row = resultData[i];

                    row.viewLink = '/' + row.Id;
                    row.tooltip = row.Name;

                    if (row.Doctor__c) {
                        row.DoctorName = row.Doctor__r.Name;
                    }

                    if (row.Patient__c) {
                        row.PatientName = row.Patient__r.Name;
                    }
                }

                cmp.set('v.data', resultData);

console.log('resultData.length: ' + resultData.length);
console.log('Page Size: ' + pageSize);
console.log('Math.ceil: ' + Math.ceil(resultData.length / pageSize));

                cmp.set("v.totalPages", Math.ceil(resultData.length / pageSize));
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        }));

        $A.enqueueAction(action);
    }, */

    getData : function(cmp, doctorId, patientId, appointmentDate, duration) {
        var action = cmp.get('c.getAppointments');

        if (doctorId && typeof doctorId !== "undefined") {
            action.setParam("selectedDoctor", doctorId);

            cmp.set('v.workingHoursEmpty', true);
        } else {
            cmp.set('v.workingHoursEmpty', false);
        }

        if (patientId && typeof patientId !== "undefined") {
            action.setParam("selectedPatient", patientId);
        }

        if (appointmentDate && typeof appointmentDate !== "undefined") {
            action.setParam("selectedDate", appointmentDate);
        }

        if (duration && typeof duration !== "undefined") {
            action.setParam("selectedDuration", duration);
        }

        var currentPage = cmp.get("v.pageNumber");
        if(currentPage) {
            action.setParam("pageNumber", currentPage);
        }

        var currentPageSize = cmp.get("v.selectedPageSize");
        if(currentPageSize) {
            action.setParam("pageSize", currentPageSize);
        }

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var resultData = response.getReturnValue();

                for (var i = 0; i < resultData.appointments.length; i++) {
                    var row = resultData.appointments[i];

                    row.viewLink = '/' + row.Id;
                    row.tooltip = row.Name;

                    if (row.Doctor__c) {
                        row.DoctorName = row.Doctor__r.Name;
                    }

                    if (row.Patient__c) {
                        row.PatientName = row.Patient__r.Name;
                    }
                }

                cmp.set('v.data', resultData.appointments);

                if (resultData.appointments.length > 0) {
                    cmp.set('v.displayData', true);
                } else if (resultData.appointments.length == 0) {
                    cmp.set('v.displayData', false);
                }

                cmp.set("v.contactList", resultData.contactList);
                cmp.set("v.totalRecords", resultData.totalRecords);
                cmp.set("v.recordStart", resultData.recordStart);
                cmp.set("v.recordEnd", resultData.recordEnd);
                cmp.set("v.totalPages", Math.ceil(resultData.totalRecords / currentPageSize));

                cmp.set("v.dataSize", resultData.appointments.length);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        }));

        $A.enqueueAction(action);
    },

    getDoctors : function(cmp) {
        var action = cmp.get('c.getDoctors');

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var doctors = response.getReturnValue();

                var options = [{ "label": "All", "value": "" }];

                for (var i = 0; i < doctors.length; i++) {
                    var option = {
                        "label": doctors[i].Name,
                        "value": doctors[i].Id
                    };
                    options.push(option);
                };

                cmp.set('v.doctors', options);
            }
        }));
        $A.enqueueAction(action);
    },

    getPatients : function(cmp) {
        var action = cmp.get('c.getPatients');

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var patients = response.getReturnValue();

                var options = [{ "label": "All", "value": "" }];

                for (var i = 0; i < patients.length; i++) {
                    var option = {
                        "label": patients[i].Name,
                        "value": patients[i].Id
                    };
                    options.push(option);
                };


                cmp.set('v.patients', options);
            }
        }));

        $A.enqueueAction(action);
    },

    formatAMPM : function(date) {
        var hours = date.getUTCHours();
        var minutes = date.getUTCMinutes();

        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;

        minutes = minutes < 10 ? '0' + minutes : minutes;

        var timeString = hours + ':' + minutes + ' ' + ampm;
        return timeString;
    },

    getWorkingHours : function(cmp) {
        var action = cmp.get('c.getWorkingHours');

        var doctorId = cmp.get('v.selectedDoctor');

        if (doctorId && typeof doctorId !== "undefined") {
            action.setParam("selectedDoctor", doctorId);

            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();

                if (state === 'SUCCESS') {
                    var workingHours = response.getReturnValue();

                    var unixTimeStart = workingHours[0].Working_Hours_Start__c;
                    var unixTimeEnd = workingHours[0].Working_Hours_End__c;

console.log('Start UNIX: ' + unixTimeStart);
console.log('End UNIX: ' + unixTimeEnd);

                    var dateStart = new Date(unixTimeStart);
                    var dateEnd = new Date(unixTimeEnd);

                    /* var hourStart = dateStart.getUTCHours();
                    var minuteStart = dateStart.getUTCMinutes();

                    var hourEnd = dateEnd.getUTCHours();
                    var minuteEnd = dateEnd.getUTCMinutes();

                    var ampmStart = hourStart >= 12 ? 'PM' : 'AM';
                    hourStart = hourStart % 12;
                    hourStart = hourStart ? hourStart : 12;

                    var ampmEnd = End >= 12 ? 'PM' : 'AM';
                    hourEnd = hourEnd % 12;
                    hourEnd = hourEnd ? hourEnd : 12; */

                    var workdayStart = this.formatAMPM(dateStart);
                    var workdayEnd = this.formatAMPM(dateEnd);

                    cmp.set('v.workdayStart', workdayStart);
                    cmp.set('v.workdayEnd', workdayEnd);
                }
            }));

            $A.enqueueAction(action);
        }
    },

    getToday : function(cmp) {
        var today = new Date();

        var todayLocalized = $A.localizationService.formatDateTimeUTC(today, "YYYY-MM-DD\'T\'HH:mm:ss.SSS\'Z\'");

        cmp.find('appointmentDate').set('v.value', todayLocalized);

        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
    },

    updateData : function(cmp) {
        var doctorId = cmp.find('doctorId').get('v.value');
        var patientId = cmp.find('patientId').get('v.value');
        var appointmentDate = cmp.find('appointmentDate').get('v.value');
        var duration = cmp.find('duration').get('v.value');

        this.getData(cmp, doctorId, patientId, appointmentDate, duration);
    },

    doctorChanged : function (cmp) {
        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
        this.getWorkingHours(cmp);
    },

    patientChanged : function (cmp) {
        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
    },

    appointmentDateChanged : function (cmp) {
        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
    },

    durationChanged : function (cmp) {
        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
    },

    saveNewAppointment : function (cmp, event) {
        var doctorId = cmp.find('doctorId').get('v.value');
        var patientId = cmp.find('patientId').get('v.value');
        var appointmentDate = cmp.find('appointmentDate').get('v.value');
        var duration = cmp.find('duration').get('v.value');


        if (!doctorId || !patientId || !appointmentDate || !duration) {
            this.showToastWarningSave(cmp, event);
        } else {
            var action = cmp.get('c.saveAppointment');

            action.setParams({
                selectedDoctor: doctorId,
                selectedPatient: patientId,
                selectedDate: appointmentDate,
                selectedDuration: duration
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var newAppointment = response.getReturnValue();

                    this.updateData(cmp);
                    this.showToastSuccessfulSave(cmp, event, newAppointment);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            })
            $A.enqueueAction(action);

            this.updateData(cmp);
        }
    },

    deleteRecordAction : function (cmp, event) {
        //var recordId = event.getParam("row").Id;
        var actionName = event.getParam("action").name;
        var record = event.getParams().row;

        if (actionName === "Delete") {
            this.showConfirmDialog(cmp);
        }
    },

    deleteRecord : function (cmp, event) {
        /* var confirmed = cmp.get("v.allowedDeletion");
console.log(confirmed);

        if(confirmed) {
            var action = cmp.get('c.deleteAppointment');

            action.setParams({
                //appointmentToDelete: JSON.stringify(record)
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.updateData(cmp);
                    this.showToastSuccessfulDelete(cmp, event, record);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            })
            $A.enqueueAction(action);
        } */

        var action = cmp.get('c.deleteAppointment');

        action.setParams({
            //appointmentToDelete: JSON.stringify(record)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.updateData(cmp);
                this.showToastSuccessfulDelete(cmp, event, record);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        })
        $A.enqueueAction(action);

        cmp.set("v.allowedDelition", false);
    },

    doctorSelectCleared : function (cmp) {
        cmp.find('doctorId').set('v.value', '');
        this.updateData(cmp);
        this.getWorkingHours(cmp);
    },

    patientSelectCleared : function (cmp, event) {
        cmp.find('patientId').set('v.value', '');
        this.updateData(cmp);
    },

    appointmentDateCleared : function(cmp, event) {
        cmp.find('appointmentDate').set('v.value', '');
        this.updateData(cmp);
    },

    durationCleared : function (cmp, event) {
        cmp.find('duration').set('v.value', '');
        this.updateData(cmp);
    },

    showConfirmDialog : function (cmp) {
        cmp.set('v.showConfirmDialog', true);
    },

    hideConfirmDialog : function (cmp, event) {
        cmp.set("v.showConfirmDialog", false);
    },

    confirmDialogYes : function (cmp, event, helper) {
        cmp.set("v.allowedDelition", true);
        cmp.set('v.showConfirmDialog', false);
    },

    pagesizeChanged : function (cmp, event) {
        cmp.set("v.pageNumber", 1);

        this.updateData(cmp);
    },

    showToastSuccessfulSave : function(cmp, event, record) {
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            title : 'Success!',
            message: 'The record has been saved successfully!',
            messageTemplate: 'New appointment has been created! See it {0}!',
            messageTemplateData: [{ url: '/' + record.Id, label: 'here' }],
            duration: '5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },

    showToastWarningSave : function(cmp, event) {
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            title : 'Warning!',
            message: 'Please, fill in all the fields before saving an appointment!',
            key: 'info_alt',
            type: 'warning',
            mode: 'dismissable',
            duration: '7000',
        });
        toastEvent.fire();
    },

    // Toast Event накладывается сверху на другой Toast Event только тогда,
    // когда в их сообщении находится разный текст
    showToastSuccessfulDelete : function(cmp, event, record) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success!',
            message: 'The record has been deleted successfully!',
            messageTemplate: 'Appointment {0} has been deleted!',
            messageTemplateData: ['"' + record.Name + '"'],
            duration: '5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    }
});

/*
 * https://blog.sujeshram.com/2017/06/update-delete-record-from-datatable-listview-lightning.html
 * https://salesforce.stackexchange.com/questions/214092/how-to-delete-datatable-row-and-corresponding-record
 * https://sfdcmonkey.com/2017/08/09/add-delete-rows-dynamic/
 * https://winsurtech.com/blog/lightning-datatable-jump-issue-on-row-actions/
 * https://www.infallibletechie.com/2018/04/lightningdatatable-with-buttons-in.html
 * https://developer.salesforce.com/forums/?id=9062I000000XpZkQAK
 * https://developer.salesforce.com/forums/?id=9062I000000IFnHQAW
 * https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/controllers_server_apex_pass_data.htm
 * https://salesforce.stackexchange.com/questions/195065/not-able-to-pass-lead-id-from-lightning-helper-to-apex-controller
 * https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_data_binding.htm
 */

/*
var paramStr = JSON.stringify(event.getParams(), null, 4);
console.log(paramStr);
*/

/*
var dt = new Date();
var ndt = $A.localizationService.formatDateTime(new Date(dt.getFullYear(), dt.getMonth(), dt.getDate()), "YYYY-MM-DD\'T\'HH:mm:ss.SSSZ");
var ndt2 = $A.localizationService.formatDateTime(new Date(dt.getFullYear(), dt.getMonth(), dt.getDate()+1), "YYYY-MM-DD\'T\'HH:mm:ss.SSSZ");
console.log(dt);
console.log(ndt);
console.log(ndt2);
*/
