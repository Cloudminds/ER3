@isTest
public class CobwebsHttpCalloutTest {
	
    public static testMethod void httpSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        CobwebsHttpCallout.getRequest('action', 'object', 'objectId');
        Test.stopTest();
    }

    public static testMethod void httpFailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockFailImpl());
        CobwebsHttpCallout.getRequest('action', 'object', 'objectId');
        Test.stopTest();
    }
}