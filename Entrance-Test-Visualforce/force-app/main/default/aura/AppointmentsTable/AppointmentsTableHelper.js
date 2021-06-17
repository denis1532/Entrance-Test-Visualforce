({
    
    // реализовать апдейт даты
    // если доктор или пациент не выбран - вызывать стандартную
    // если выбраны - прописать кастомную логику
    
    getData : function(cmp, doctorId, patientId, appointmentDate, duration, pageNumber, pageSize) {
        var action = cmp.get('c.getAppointments');
        
        console.log('Page Number: ' + cmp.get("v.pageNumber"));
        
        if (doctorId && typeof doctorId !== "undefined") {
            action.setParam("selectedDoctor", doctorId);
        }
        
        if (patientId && typeof patientId !== "undefined") {
            action.setParam("selectedPatient", patientId);
        }
        
        if (appointmentDate && typeof appointmentDate !== "undefined") {
            // решить проблему с преобразованием в datetime
            // нужно как-то получать не строку чистую, а сразу красивую дату
            
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
                    
                    /*if (row.Appointment_Date__c) {
                        row.FormattedDate = $A.localizationService.formatDate(row.Appointment_Date__c, "MMM dd yyyy, hh:mm:ss a");
                    }*/
                }
                
                cmp.set('v.data', resultData);
                //cmp.set("v.totalPages", Math.ceil(resultData.length / pageSize));
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
                
                cmp.set('v.doctors', doctors);
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
                
                cmp.set('v.patients', patients);
            }
        }));
        
        $A.enqueueAction(action);
    },
    
    getToday : function(cmp) {
        var today = $A.localizationService.formatDateTime(new Date(), "YYYY-MM-DD\'T\'HH:mm:ss.SSSZ");
        
        cmp.set('v.datetime', today);
        
        // 1. ПОЛУЧАТЬ СРАЗУ UTC-ФОРМАТ
        // 2. КОНВЕРТИРОВАТЬ СРАЗУ В НОРМАЛЬНЫЙ ISO (ЗАГУГЛИТЬ)
    },
    
    updateData : function(cmp) {
        var doctorId = cmp.find('doctorId').get('v.value');
        var patientId = cmp.find('patientId').get('v.value');
        var appointmentDate = cmp.find('appointmentDate').get('v.value');
        var duration = cmp.find('duration').get('v.value');
        var test = cmp.find('doctorIdTest').get('v.value');
        console.log('Combobox value: ' + test);
        
        /*var dt = new Date();
        var ndt = $A.localizationService.formatDateTime(new Date(dt.getFullYear(), dt.getMonth(), dt.getDate()), "YYYY-MM-DD\'T\'HH:mm:ss.SSSZ");
        var ndt2 = $A.localizationService.formatDateTime(new Date(dt.getFullYear(), dt.getMonth(), dt.getDate()+1), "YYYY-MM-DD\'T\'HH:mm:ss.SSSZ");
        console.log(dt);
        console.log(ndt);
        console.log(ndt2);*/
        
        this.getData(cmp, doctorId, patientId, appointmentDate, duration);
    },
    
    doctorChanged : function (cmp, event) {
        //var doctorId = cmp.find('doctorId').get('v.value');
        
        this.updateData(cmp);
    },
    
    patientChanged : function (cmp, event) {
        //var patientId = cmp.find('patientId').get('v.value');
        
        this.updateData(cmp);
    },
    
    appointmentDateChanged : function (cmp, event) {
        this.updateData(cmp);
    },
    
    durationChanged : function (cmp, event) {
        this.updateData(cmp);
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
        var confirmed = cmp.get("v.allowedDeletion");
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
        }
        
        cmp.set("v.allowedDelition", false);
    },
        
    /*var paramStr = JSON.stringify(event.getParams(), null, 4); 
    console.log(paramStr);*/
    
    showConfirmDialog : function (cmp, event, helper) {
        cmp.set('v.showConfirmDialog', true);
    },
    
    hideConfirmDialog : function (cmp, event, helper) {
        cmp.set("v.showConfirmDialog", false);
    },

    confirmDialogYes : function (cmp, event, helper) {
        cmp.set("v.allowedDelition", true);
        cmp.set('v.showConfirmDialog', false);
    },
    
    doctorSelectCleared : function (cmp, event) {
        cmp.find('doctorId').set('v.value', '');
        this.updateData(cmp);
    },
    
    patientSelectCleared : function (cmp, event) {
        cmp.find('patientId').set('v.value', '');
        this.updateData(cmp);
    },
    
    durationCleared : function (cmp, event) {
        cmp.find('duration').set('v.value', '');
        this.updateData(cmp);
    },
    
    pagesizeChanged : function (cmp, event) {
        this.updateData(cmp);
    },
    
    // Toast Event накладывается сверху на другой Toast Event только тогда,
    // когда в их сообщении находится разный текст
    showToastSuccessfulDelete : function(cmp, event, record) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success!',
            message: 'The record has been deleted successfully!',
            messageTemplate: 'Appointment {0} has been deleted! See it {1}!',
            messageTemplateData: ['"' + record.Name + '"', { url: '/' + record.Id, label: 'here' }],
            duration:' 5000',
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