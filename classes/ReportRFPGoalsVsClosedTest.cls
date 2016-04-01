@isTest
public with sharing class ReportRFPGoalsVsClosedTest {
    public static testMethod void ReportRFPGoalsVsClosedTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        
        User testUser = testRunAs();
        Employee__c salesRep = new Employee__c(
            Name = 'Test User',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Related_To__c = testUser.Id
        );
        insert salesRep;

        List <Employee__c> employees = new List<Employee__c>();
        employees.add(salesRep);
        Sales_Quota__c sQuota = new Sales_Quota__c(
            Q1_Quota__c = 1000,
            Q2_Quota__c = 2000,
            Q3_Quota__c = 3000,
            Q4_Quota__c = 4000,
            Employee__c = salesRep.Id
        );
        insert sQuota;
        List <Sales_Quota__c> quotas = new List<Sales_Quota__c>();
        quotas.add(sQuota);

        Account testAcc = ObjectFactory.createCAClient('testAcc');
        insert testAcc;
        Brand__c testBrand = ObjectFactory.createBrand('testBrand');
        insert testBrand;
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity testOpp = ObjectFactory.createClosedWonOpportunity(testAcc, testBrand, 'Test');
        testOpp.CloseDate = Date.Today();
        opportunitiesList.add(testOpp);
        insert opportunitiesList;

        ReportRFPGoalsVsClosed rfpGoalRpt = new ReportRFPGoalsVsClosed();
        rfpGoalRpt.loggedInUserId = testUser.Id;
        rfpGoalRpt.salesRep = employees;
        rfpGoalRpt.quotasOwned = quotas;
        rfpGoalRpt.getRfpDataWithQuarterNames();
        Test.stopTest();
    }

    public static testMethod User testRunAs() {
        Profile p = [select id from profile where name = 'Marketing User (TOR)'];
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