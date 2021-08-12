import { LightningElement, api, track, wire } from 'lwc';
import getDoctors from '@salesforce/apex/AppointmentsControllerLWC.getDoctors';

export default class AppointmentsTableLWC extends LightningElement {
    @track doctors = [{ label: 'All', value: 'All' }];
    @track selectedDoctor = this.doctors[0].value;

    @wire(getDoctors)
    wiredDoctors({ error, data }) {
        if (data) {
            let paramStr1 = JSON.stringify(this.doctors, null, 4);
            console.log('Docs before: ' + paramStr1);

            for (var doctor in data) {
                this.doctors.push({
                    label: data[doctor].Name,
                    value: data[doctor].Id
                })
            }

            /* data.forEach(r => {
                this.doctors.push({
                    label: r.Name,
                    value: r.Id
                })
            }) */

            let paramStr2 = JSON.stringify(this.doctors, null, 4);
            console.log('Docs after: ' + paramStr2);

        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
}

/* var paramStr = JSON.stringify(event.getParams(), null, 4);
console.log(paramStr); */