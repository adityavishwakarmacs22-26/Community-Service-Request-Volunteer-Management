public with sharing class VolunteerRegistrationController {
    
    @AuraEnabled(cacheable=true)
    public static List<Volunteer_Event__c> getAvailableEvents() {
        try {
            List<Volunteer_Event__c> events = Database.query(
                'SELECT Id, Event_Name__c, Event_Date__c, Event_Location__c, ' +
                'Max_Volunteers__c, Current_Volunteers__c FROM Volunteer_Event__c ' +
                'WHERE Status__c = \'Approved\' AND Event_Date__c >= TODAY AND ' +
                '(Current_Volunteers__c < Max_Volunteers__c OR Max_Volunteers__c = null) ' +
                'ORDER BY Event_Date__c ASC LIMIT 50'
            );
            return events;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch events: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id registerVolunteer(Id eventId, String participantName) {
        try {
            // Check if already registered
            List<Volunteer_Participation__c> existingParticipation = Database.query(
                'SELECT Id FROM Volunteer_Participation__c ' +
                'WHERE Event__c = :eventId ' +
                'LIMIT 1 '
            );
            
            if (!existingParticipation.isEmpty()) {
                throw new AuraHandledException('You are already registered for this event.');
            }
            
            // Get event details for platform event
            Volunteer_Event__c event = [
                SELECT Id, Event_Name__c 
                FROM Volunteer_Event__c 
                WHERE Id = :eventId 
                LIMIT 1
            ];
            
            // Insert participation record
            Volunteer_Participation__c vp = new Volunteer_Participation__c(
                Event__c = eventId,
                Name = participantName,
                Attendance_Status__c = 'Registered'
            );
            insert vp;
            
            // Publish platform event
            Volunteer_Registration__e regEvent = new Volunteer_Registration__e(
                Event_Id__c = eventId,
                Registration_Type__c = 'New',
                Event_Name__c = event.Event_Name__c
            );
            
            Database.SaveResult sr = EventBus.publish(regEvent);
            if (sr.isSuccess()) {
                System.debug('Platform event published successfully');
            } else {
                System.debug('Platform event publish failed: ' + sr.getErrors());
            }
            
            return vp.Id;
            
        } catch (DmlException e) {
            throw new AuraHandledException('Registration failed: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Registration failed: ' + e.getMessage());
        }
    }
}
