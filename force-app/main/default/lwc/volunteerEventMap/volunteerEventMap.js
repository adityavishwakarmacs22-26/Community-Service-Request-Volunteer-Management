import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = [
    'Volunteer_Event__c.Event_Name__c',
    'Volunteer_Event__c.Event_Location__c'
];

export default class VolunteerEventMap extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    eventRecord;

    get eventData() {
        return this.eventRecord && this.eventRecord.data;
    }

    get eventName() {
        return this.eventData ? this.eventData.fields.Event_Name__c.value : '';
    }

    get eventLocation() {
        return this.eventData ? this.eventData.fields.Event_Location__c.value : '';
    }

    get mapUrl() {
        if (this.eventLocation) {
            const encodedLocation = encodeURIComponent(this.eventLocation);
            return `https://www.google.com/maps/embed/v1/place?key=YOUR_API_KEY&q=${encodedLocation}`;
        }
        return '';
    }

    openRegistrationModal() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Volunteer_Dashboard'
            }
        });
    }

    handleRegistrationComplete(event) {
        // Handle registration completion
        const eventId = event.detail.eventId;
        // Refresh data or show success message
        this.dispatchEvent(new CustomEvent('registered', {
            detail: { eventId: eventId }
        }));
    }
}
