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

export default {
    getOptions
}