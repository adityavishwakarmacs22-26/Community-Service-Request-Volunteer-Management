@isTest
public class PlatformEventTest {
    @isTest
    static void testVolunteerRegistrationEvent() {
        // Create test event
        Volunteer_Event__c event = new Volunteer_Event__c(
            Event_Name__c = 'Test Event',
            Event_Date__c = Date.today().addDays(30),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = 10
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

@isTest
private class VolunteerRegistrationControllerTest {
    @isTest
    static void testGetAvailableEventsWithNoEvents() {
        // Test when no events exist
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(0, events.size(), 'Should return empty list when no events exist');
    }
    
    @isTest
    static void testGetAvailableEventsWithPastEvents() {
        // Test filtering out past events
        Volunteer_Event__c pastEvent = new Volunteer_Event__c(
            Event_Name__c = 'Past Event',
            Event_Date__c = Date.today().addDays(-1),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = 10
        );
        insert pastEvent;
        
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(0, events.size(), 'Should not return past events');
    }
    
    @isTest
    static void testGetAvailableEventsWithUnapprovedEvents() {
        // Test filtering out unapproved events
        Volunteer_Event__c unapprovedEvent = new Volunteer_Event__c(
            Event_Name__c = 'Unapproved Event',
            Event_Date__c = Date.today().addDays(1),
            Event_Status__c = 'Pending',
            Max_Volunteers__c = 10
        );
        insert unapprovedEvent;
        
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(0, events.size(), 'Should not return unapproved events');
    }
    
    @isTest
    static void testGetAvailableEventsWithFullEvents() {
        // Test filtering out full events
        Volunteer_Event__c fullEvent = new Volunteer_Event__c(
            Event_Name__c = 'Full Event',
            Event_Date__c = Date.today().addDays(1),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = 5,
            Current_Volunteers__c = 5
        );
        insert fullEvent;
        
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(0, events.size(), 'Should not return full events');
    }
    
    @isTest
    static void testGetAvailableEventsWithNullMaxVolunteers() {
        // Test events with null max volunteers (unlimited)
        Volunteer_Event__c unlimitedEvent = new Volunteer_Event__c(
            Event_Name__c = 'Unlimited Event',
            Event_Date__c = Date.today().addDays(1),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = null,
            Current_Volunteers__c = 5
        );
        insert unlimitedEvent;
        
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(1, events.size(), 'Should return events with null max volunteers');
    }
    
    @isTest
    static void testGetAvailableEventsOrdering() {
        // Test proper ordering by date
        Volunteer_Event__c event1 = new Volunteer_Event__c(
            Event_Name__c = 'Event 1',
            Event_Date__c = Date.today().addDays(5),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = 10
        );
        Volunteer_Event__c event2 = new Volunteer_Event__c(
            Event_Name__c = 'Event 2',
            Event_Date__c = Date.today().addDays(2),
            Event_Status__c = 'Approved',
            Max_Volunteers__c = 10
        );
        insert new List<Volunteer_Event__c>{event1, event2};
        
        List<Volunteer_Event__c> events = VolunteerRegistrationController.getAvailableEvents();
        System.assertEquals(2, events.size(), 'Should return both events');
        System.assertEquals('Event 2', events[0].Event_Name__c, 'Should be ordered by date ascending');
        System.assertEquals('Event 1', events[1].Event_Name__c, 'Should be ordered by date ascending');
    }
}
}
