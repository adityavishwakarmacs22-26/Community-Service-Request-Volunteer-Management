public class APILimitMonitor {
    
    public static void logAPIUsage(String operationType) {
        try {
            Integer callouts = Limits.getCallouts();
            Integer calloutLimit = Limits.getLimitCallouts();
            Decimal usagePercentage = calloutLimit > 0 ? (callouts * 100.0 / calloutLimit) : 0;
            
            API_Usage_Log__c log = new API_Usage_Log__c(
                Operation_Type__c = operationType,
                API_Requests_Used__c = callouts,
                API_Requests_Limit__c = calloutLimit,
                Timestamp__c = Datetime.now(),
                Usage_Percentage__c = usagePercentage
            );
            insert log;
            
            // Alert if approaching limit (80% threshold)
            if (usagePercentage > 80) {
                sendLimitAlert(operationType, usagePercentage);
            }
            
        } catch (Exception e) {
            System.debug('Error logging API usage: ' + e.getMessage());
        }
    }
    
    private static void sendLimitAlert(String operationType, Decimal usagePercentage) {
        try {
            // Create platform event for limit alert
            API_Limit_Alert__e alertEvent = new API_Limit_Alert__e(
                Operation_Type__c = operationType,
                Usage_Percentage__c = usagePercentage,
                Alert_Message__c = 'API usage is at ' + usagePercentage.setScale(1) + '% for operation: ' + operationType
            );
            
            Database.SaveResult sr = EventBus.publish(alertEvent);
            if (!sr.isSuccess()) {
                System.debug('Failed to publish API limit alert: ' + sr.getErrors());
            }
            
        } catch (Exception e) {
            System.debug('Error sending limit alert: ' + e.getMessage());
        }
    }
    
    public static void logCalloutUsage(String operation) {
        logAPIUsage('Callout - ' + operation);
    }
    
    public static void logDMLUsage(String operation) {
        API_Usage_Log__c log = new API_Usage_Log__c(
            Operation_Type__c = 'DML - ' + operation,
            API_Requests_Used__c = Limits.getDMLStatements(),
            API_Requests_Limit__c = Limits.getLimitDMLStatements(),
            Timestamp__c = Datetime.now()
        );
        
        try {
            insert log;
        } catch (Exception e) {
            System.debug('Error logging DML usage: ' + e.getMessage());
        }
    }
}
