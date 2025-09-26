import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableEvents from '@salesforce/apex/VolunteerRegistrationController.getAvailableEvents';
import registerVolunteer from '@salesforce/apex/VolunteerRegistrationController.registerVolunteer';

export default class VolunteerRegistrationModal extends LightningElement {
    selectedEventId = '';
    participantName = '';
    participantEmail = '';
    eventOptions = [];
    isRegistering = false;
    showSpinner = false;

    @wire(getAvailableEvents)
    wiredEvents({ error, data }) {
        if (data) {
            this.eventOptions = data.map(event => ({
                label: event.Event_Name__c,
                value: event.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to load events', 'error');
        }
    }

    handleEventChange(event) {
        this.selectedEventId = event.detail.value;
    }

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        
        if (field === 'participantName') {
            this.participantName = value;
        } else if (field === 'participantEmail') {
            this.participantEmail = value;
        }
    }

    handleRegister() {
        if (this.validateInputs()) {
            this.isRegistering = true;
            this.showSpinner = true;

            registerVolunteer({
                eventId: this.selectedEventId,
                participantName: this.participantName,
                participantEmail: this.participantEmail
            })
            .then(result => {
                this.showToast('Success', 'Registration completed successfully!', 'success');
                
                // Dispatch custom event
                const registrationEvent = new CustomEvent('registered', {
                    detail: { 
                        eventId: this.selectedEventId,
                        participationId: result
                    }
                });
                this.dispatchEvent(registrationEvent);
                
                // Reset form
                this.resetForm();
            })
            .catch(error => {
                this.showToast('Error', 'Registration failed: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isRegistering = false;
                this.showSpinner = false;
            });
        }
    }

    handleCancel() {
        this.resetForm();
    }

    validateInputs() {
        if (!this.selectedEventId || !this.participantName || !this.participantEmail) {
            this.showToast('Error', 'Please fill in all required fields', 'error');
            return false;
        }
        return true;
    }

    resetForm() {
        this.selectedEventId = '';
        this.participantName = '';
        this.participantEmail = '';
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
