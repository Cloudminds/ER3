@isTest
public class ERSyncControllerTest {

    // Test sales rep creation
    public static testMethod void CreateSalesRepTriggerTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Employee__c salesRep = ObjectFactory.createSalesRep('Rep Name');
        insert salesRep;

        Test.stopTest();
    }

    // Test a successful contact creation
    public static testMethod void CreateContactTriggerTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;

        Contact newContact = [select FirstName, LastName, Email, Out_of_Sync__c, IsAPI__c from Contact where Id=:contact.Id][0];

        Test.stopTest();

        // Test that upsert succeeded
        System.assertEquals(contact.FirstName, newContact.FirstName);
        System.assertEquals(contact.LastName, newContact.LastName);
        System.assertEquals(contact.Email, newContact.Email);
    }

    public static testMethod void UpdateContactTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        contact.FirstName = ('Rock');
        update contact;
        Contact newContact = [select FirstName from Contact where Id=:contact.Id][0];

        Test.stopTest();

        System.assertEquals('Rock', newContact.FirstName);
    }

    public static testMethod void EaseContactTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        contact.IsAPI__c = true;
        update contact;

        Test.stopTest();

        Contact newContact = [select IsAPI__c from Contact where Id=:contact.Id][0];

        delete contact;
    }

    // See if validate contact fails on duplicate emails
    public static testMethod void ValidateContactTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Contact newContact = ObjectFactory.createContact(client);

        Boolean expectedExceptionThrown;

        try {
            insert newContact;
            throw new TestException('An exception should have been thrown by the trigger but was not.');
        } catch(Exception e) {
            expectedExceptionThrown = e.getMessage().contains('Email address already exists') ? true : false;
        }

        Test.stopTest();

        // System.AssertEquals(true, expectedExceptionThrown);
    }

    public static testMethod void CreateClientBrandFromClosedWonOpportunityTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createClosedWonOpportunity(client, brand, 'Opp');
        insert opportunity;
        Account newClient = [select Name, Type from Account where Id = :client.Id][0];
        Brand__c newBrand = [select Name from Brand__c where Id = :brand.Id][0];

        Test.stopTest();

        // Test that upsert succeeded
        System.assertEquals(client.Name, newClient.Name);
        System.assertEquals(brand.Name, newBrand.Name);
    }

    public static testMethod void CampaignSyncTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        String failResult = ERSyncController.createCampaign(opportunity.Id);

        // Create campaignQuestionnaire
        Campaign_Questionnaire__c cq = ObjectFactory.createQuestionnaire();
        cq.Opportunity__c = opportunity.Id;
        insert cq;
        String successResult = ERSyncController.createCampaign(opportunity.Id);

        // Set assert parameters
        String failExpect = 'Campaign questionnaire has not been completed';
        String successExpect = 'true';
        Test.stopTest();

        System.assertEquals(failExpect, failResult);
        System.assertEquals(successExpect, successResult);
    }

    public static testMethod void UpdateOrgTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        client.Out_of_Sync__c = false;
        ERSyncController.updateOrg(client.Id);
        Account newAccount = [select Out_of_Sync__c from Account where Id=:client.Id][0];

        Test.stopTest();

        // System.assertEquals(true, newAccount.Out_of_Sync__c);
    }

    public static testMethod void EaseOrgTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        client.IsAPI__c = true;
        update client;
        Test.stopTest();

        Account newAccount = [select IsAPI__c from Account where Id=:client.Id][0];

        // Test that the account was eased from an "API call"
        // System.assertEquals(false, newAccount.IsAPI__c);
    }

    public static testMethod void UpdateBrandTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        ERSyncController.updateBrand(brand.Id);

        Test.stopTest();
    }

    public static testMethod void EaseBrandTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        brand.IsAPI__c = true;
        update brand;
        
        Test.stopTest();
        // Test that the account was eased from an "API call"
        // System.assertEquals(false, newBrand.IsAPI__c);
    }

    public static testMethod void DeleteBrandTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        brand.IsAPI__c = true;
        update brand;
        
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createClosedWonOpportunity(client, brand, 'Opp');
        insert opportunity;
                
        try {
            delete brand;
            System.assert(false);
        } catch (DMLException e) {}
        
        Test.stopTest();
    }
}