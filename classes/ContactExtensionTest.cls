@isTest
public class ContactExtensionTest {

    // Init the page controller
    private static ContactExtension initPage(Contact contact) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(contact);
        Test.setCurrentPageReference(Page.Contact_Custom);
        return new ContactExtension(standardController);
    }

    // Fail with missing fields
    public static testMethod void SaveFailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ContactExtension pageController;
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact tempContact = ObjectFactory.createContact(client);
        pageController = initPage(tempContact);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(tempContact)).view().getUrl();
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
        ContactExtension pageController;
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact tempContact = ObjectFactory.createContact(client);
        upsert(tempContact);
        pageController = initPage(tempContact);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(tempContact)).view().getUrl();
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
        ContactExtension pageController;
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact tempContact = ObjectFactory.createContact(client);
        upsert(tempContact);
        pageController = initPage(tempContact);
        System.PageReference tempPage = pageController.saveNew();

        // Set assert parameters
        String expectUrl = (new PageReference('/' + ('' + pageController.contact.get('Id')).subString(0, 3) + '/e?')).getUrl();
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
        ContactExtension pageController;
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact tempContact = ObjectFactory.createContact(client);
        upsert(tempContact);
        pageController = initPage(tempContact);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        Test.stopTest();
        String resultUrl = pageController.cancel().getUrl();
        String expectUrl = (new ApexPages.StandardController(tempContact)).view().getUrl();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    // Validation test
    public static testMethod void ValidationTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create objects for test
        ContactExtension pageController;
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact tempContact1 = ObjectFactory.createContact(client);
        Contact tempContact2 = ObjectFactory.createContact(client);
        pageController = initPage(tempContact1);
        //pageController.validateContactEmail();
        pageController.save();

        pageController = initPage(tempContact2);
        pageController.save();        
        //pageController.validateContactEmail();

        // Set assert parameters
        Test.stopTest();
    }
}