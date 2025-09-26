public class ExternalEmailService {
    
    @future(callout=true)
    public static void sendWelcomeEmail(String participantEmail, String eventName) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Volunteer_Email_Service/send');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000); // 2 minutes timeout
            
            Map<String, Object> emailData = new Map<String, Object>{
                'to' => participantEmail,
                'subject' => 'Welcome to ' + eventName,
                'body' => 'Thank you for registering for ' + eventName + '! We look forward to seeing you at the event.',
                'from' => 'noreply@volunteer.org'
            };
            
            req.setBody(JSON.serialize(emailData));
            
            Http h = new Http();
            HttpResponse res = h.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('Email sent successfully to: ' + participantEmail);
                // Log successful email
                logEmailActivity(participantEmail, eventName, 'SUCCESS', 'Email sent successfully');
            } else {
                System.debug('Email send failed: ' + res.getBody());
                // Log failed email
                logEmailActivity(participantEmail, eventName, 'FAILED', res.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Exception in sendWelcomeEmail: ' + e.getMessage());
            logEmailActivity(participantEmail, eventName, 'ERROR', e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void sendEventReminder(String participantEmail, String eventName, Date eventDate) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Volunteer_Email_Service/send');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            String eventDateStr = eventDate.format();
            Map<String, Object> emailData = new Map<String, Object>{
                'to' => participantEmail,
                'subject' => 'Reminder: ' + eventName + ' is tomorrow!',
                'body' => 'This is a friendly reminder that you are registered for ' + eventName + ' on ' + eventDateStr + '. We look forward to seeing you there!',
                'from' => 'noreply@volunteer.org'
            };
            
            req.setBody(JSON.serialize(emailData));
            
            Http h = new Http();
            HttpResponse res = h.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('Reminder email sent successfully to: ' + participantEmail);
                logEmailActivity(participantEmail, eventName, 'SUCCESS', 'Reminder email sent');
            } else {
                System.debug('Reminder email send failed: ' + res.getBody());
                logEmailActivity(participantEmail, eventName, 'FAILED', res.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Exception in sendEventReminder: ' + e.getMessage());
            logEmailActivity(participantEmail, eventName, 'ERROR', e.getMessage());
        }
    }
    
    private static void logEmailActivity(String email, String eventName, String status, String details) {
        try {
            Email_Activity_Log__c log = new Email_Activity_Log__c(
                Recipient_Email__c = email,
                Event_Name__c = eventName,
                Status__c = status,
                Details__c = details,
                Sent_DateTime__c = Datetime.now()
            );
            insert log;
        } catch (Exception e) {
            System.debug('Failed to log email activity: ' + e.getMessage());
        }
    }

    @future(callout=true)
    public static void sendWelcomeEmailWithMonitoring(String participantEmail, String eventName) {
        // Log API usage before callout
        APILimitMonitor.logCalloutUsage('External Email Service');
        
        // Call the existing method
        sendWelcomeEmail(participantEmail, eventName);
    }
}
