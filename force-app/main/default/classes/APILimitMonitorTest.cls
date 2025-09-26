@isTest
public class APILimitMonitorTest {
    @isTest
    static void testAPIUsageLogging() {
        Test.startTest();
        APILimitMonitor.logAPIUsage('Test Operation');
        Test.stopTest();
        
        List<API_Usage_Log__c> logs = [SELECT Id FROM API_Usage_Log__c];
        System.assertEquals(1, logs.size());
    }
}
