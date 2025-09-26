trigger VolunteerRegistrationEventTrigger on Volunteer_Registration__e (after insert) {
    for (Volunteer_Registration__e event : Trigger.new) {
        // Call external email service with monitoring
        ExternalEmailService.sendWelcomeEmailWithMonitoring(
            event.Participant_Email__c,
            event.Event_Name__c
        );
        
        System.debug('Processing registration event with monitoring for: ' + 
                    event.Participant_Email__c);
    }
}
