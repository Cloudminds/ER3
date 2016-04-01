@isTest
public with sharing class ReportSalesQuotaVsClosedTest {
    public static testMethod void ReportSalesQuotaVsClosedTest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
		
        User testUser = testRunAs();

        Employee__c salesRep = ObjectFactory.createSalesRep('Test User');
        insert salesRep;

        Sales_Quota__c sQuota = new Sales_Quota__c(
            Q1_Quota__c = 1000,
            Q2_Quota__c = 2000,
            Q3_Quota__c = 3000,
            Q4_Quota__c = 4000,
            Employee__c = salesRep.Id
        );
        insert sQuota;

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = ObjectFactory.createClosedWonOpportunity(client, brand, 'Test' + i);
            opp.CloseDate = Date.Today();
            opportunitiesList.add(opp);
        }
        insert opportunitiesList;
        
        ReportSalesQuotaVsClosed salesQuotaRpt = new ReportSalesQuotaVsClosed();
        salesQuotaRpt.getsalesActual(testUser.Id);
        Test.stopTest();
    }

    public static testMethod User testRunAs() {
        Profile p = [select id from profile where name = 'Standard User'];
        User testUser = new User(alias = 'test', email = 'test@eyereturn.com',
            emailencodingkey = 'UTF-8', lastname = 'test', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'test@eyereturn.com');
        insert testUser;

        System.runAs(testUser) {
            // The following code runs as user 'testUser'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
        return testUser;
    }
}