import { LightningElement } from 'lwc';

// export default class Utils extends LightningElement { }

/* export function getOptions(data) {
    let options = [{ label: 'All', value: 'All' }];

    for (var option in data) {
        options.push({
            label: data[option].Name,
            value: data[option].Id
        })
    }

    return options;
} */

export const getOptions = (data) => {
    let options = [{ label: 'All', value: '' }];

    for (var option in data) {
        options.push({
            label: data[option].Name,
            value: data[option].Id
        })
    }

    return options;
}

export const formatAMPM = (date) => {
    let hours = date.getUTCHours();
    let minutes = date.getUTCMinutes();

    let ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours ? hours : 12;

    minutes = minutes < 10 ? '0' + minutes : minutes;

    let timeString = hours + ':' + minutes + ' ' + ampm;

    return timeString;
}

export default {
    getOptions,
    formatAMPM
}