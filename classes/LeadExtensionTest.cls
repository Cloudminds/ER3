@isTest
public class LeadExtensionTest {
    // Init a new Lead Source
    private static Lead_Source__c initTempLeadSource(String name) {
        Lead_Source__c leadSource = new Lead_Source__c();
        leadSource.Name = name;
        return leadSource;
    }

    // Init a new Lead
    private static Lead initTempLead(Lead_Source__c leadSource) {
        Lead lead = new Lead();
        lead.OwnerId = UserInfo.getUserId();
        lead.Company = 'ABC Company';
        lead.FirstName = 'Firstname';
        lead.LastName = 'Lastname';
        lead.Title = 'Title';
        lead.Status = 'Open';
        lead.Country = 'Canada';
        lead.Lead_Source__c = leadSource.Id;
        return lead;
    }

    // Init the page controller
    private static LeadExtension initPage(Lead lead) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(lead);
        Test.setCurrentPageReference(Page.Lead_Custom);
        return new LeadExtension(standardController);
    }

    // Fail with missing fields
    public static testMethod void SaveFailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        LeadExtension pageController;
        Lead_Source__c tempLeadSource = initTempLeadSource('Lead Source Name');
        insert tempLeadSource;
        Lead tempLead = initTempLead(tempLeadSource);
        pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(tempLead)).view().getUrl();
        String resultUrl = null;
        if (tempPage != null)
            resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    // Save with proper fields
    public static testMethod void SaveSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        LeadExtension pageController;
        Lead_Source__c tempLeadSource = initTempLeadSource('Lead Source Name');
        insert tempLeadSource;
        Lead tempLead = initTempLead(tempLeadSource);
        insert tempLead;
        pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(tempLead)).view().getUrl();
        String resultUrl = '';
        resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    // Save and new with proper fields
    public static testMethod void SaveAndNewSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        LeadExtension pageController;
        Lead_Source__c tempLeadSource = initTempLeadSource('Lead Source Name');
        insert tempLeadSource;
        Lead tempLead = initTempLead(tempLeadSource);
        insert tempLead;
        pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.saveNew();

        // Set assert parameters
        String expectUrl = (new PageReference('/' + ('' + pageController.lead.get('Id')).subString(0, 3) + '/e?')).getUrl();
        String resultUrl = '';
        resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    // Cancel
    public static testMethod void CancelTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        LeadExtension pageController;
        Lead_Source__c tempLeadSource = initTempLeadSource('Lead Source Name');
        insert tempLeadSource;
        Lead tempLead = initTempLead(tempLeadSource);
        insert tempLead;
        pageController = initPage(tempLead);

        // Set assert parameters
        String resultUrl = pageController.cancel().getUrl();
        String expectUrl = (new ApexPages.StandardController(tempLead)).view().getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }
}