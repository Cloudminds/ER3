@isTest
public class LeadConvertExtensionTest {

    // Init a temporary lead
    private static Lead initTempLead() {
        Lead lead = new Lead();
        lead.Company = 'ABC Company';
        lead.FirstName = 'Wayne';
        lead.LastName = 'Gretzky';
        lead.Phone = '123-456-7890';
        lead.Fax = '987-654-3210';
        lead.Street = '1 Hacker Way';
        lead.City = 'Silicon Valley';
        lead.CountryCode = 'CA';
        lead.PostalCode = 'M1M1M1';
        lead.StateCode = 'ON';
        return lead;
    }

    // Init a new account
    private static Account initTempAccount(String name) {
        Account account = new Account();
        account.Type = 'Client';
        account.Name = name;
        return account;
    }

    // Init the page controller
    private static LeadConvertExtension initPage(Lead lead) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(lead);
        PageReference pageRef = Page.Lead_Convert_Custom;
        pageRef.getParameters().put('id', lead.Id);
        Test.setCurrentPageReference(pageRef);
        return new LeadConvertExtension(standardController);
    }

    // Test data pre-population
    public static testMethod void leadConvertCreateTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Lead tempLead = initTempLead();
        insert tempLead;
        LeadConvertExtension pageController = initPage(tempLead);

        Test.stopTest();

        // Test Account
        System.assertEquals(tempLead.Phone, pageController.account.Phone);
        System.assertEquals(tempLead.Fax, pageController.account.Fax);
        System.assertEquals(tempLead.Street, pageController.account.BillingStreet);
        System.assertEquals(tempLead.City, pageController.account.BillingCity);
        System.assertEquals(tempLead.CountryCode, pageController.account.BillingCountryCode);
        System.assertEquals(tempLead.PostalCode, pageController.account.BillingPostalCode);
        System.assertEquals(tempLead.State, pageController.account.BillingState);

        // Test Contact
        System.assertEquals(tempLead.FirstName, pageController.contact.FirstName);
        System.assertEquals(tempLead.LastName, pageController.contact.LastName);
        System.assertEquals(tempLead.Email, pageController.contact.Email);
        System.assertEquals(tempLead.Phone, pageController.contact.Phone);
        System.assertEquals(tempLead.Fax, pageController.contact.Fax);
        System.assertEquals(tempLead.Street, pageController.contact.MailingStreet);
        System.assertEquals(tempLead.City, pageController.contact.MailingCity);
        System.assertEquals(tempLead.Country, pageController.contact.MailingCountry);
        System.assertEquals(tempLead.PostalCode, pageController.contact.MailingPostalCode);
        System.assertEquals(tempLead.State, pageController.contact.MailingState);
    }

    public static testMethod void SaveSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Lead tempLead = initTempLead();
        insert tempLead;
        LeadConvertExtension pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(pageController.account)).view().getUrl();
        String resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    public static testMethod void SaveContactOnlySuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Lead tempLead = initTempLead();
        Account tempAccount = initTempAccount('Client Account');
        insert tempLead;
        insert tempAccount;
        LeadConvertExtension pageController = initPage(tempLead);
        pageController.createAccount = false;
        pageController.contact.AccountId = tempAccount.Id;
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(pageController.contact)).view().getUrl();
        String resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    public static testMethod void SaveContactOnlyDuplicateAccountTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Lead tempLead = initTempLead();
        Account tempAccount = initTempAccount('ABC Company');
        insert tempLead;
        insert tempAccount;
        LeadConvertExtension pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(pageController.contact)).view().getUrl();
        String resultUrl = tempPage.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    public static testMethod void CancelTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Lead tempLead = initTempLead();
        insert tempLead;
        LeadConvertExtension pageController = initPage(tempLead);
        System.PageReference tempPage = pageController.cancel();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(tempLead)).view().getUrl();
        String resultUrl = tempPage.getUrl();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }
}