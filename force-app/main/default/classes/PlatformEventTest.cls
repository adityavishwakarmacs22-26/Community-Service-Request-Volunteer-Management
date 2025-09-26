@isTest
public class PlatformEventTest {
    @isTest
    static void testVolunteerRegistrationEvent() {
        // Create test event
        Volunteer_Event__c event = new Volunteer_Event__c(
            Event_Name__c = 'Test Event',
            Event_Date__c = Date.today().addDays(30),
            Event_Status__c = 'Approved'
        );
        insert event;
        
        Test.startTest();
        
        // Test registration with platform event
        Id participationId = VolunteerRegistrationController.registerVolunteer(
            event.Id, 
            'Test User'
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, participationId);
    }
}
