@isTest
public class AccountExtensionTest {

    // Init the page controller
    private static AccountExtension initPage(Account account) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        Test.setCurrentPageReference(Page.Account_Custom);
        return new AccountExtension(standardController);
    }

    // Test Sales Reps are created when there is no default Sales Rep
    public static testMethod void NoDefaultSalesTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        Account account = new Account();
        AccountExtension pageController;
        pageController = initPage(account);

        String selectedAdServingRep = '--NONE--';
        String selectedEyeDemandRep = '--NONE--';
        Test.stopTest();

        System.assertEquals(null, pageController.unassignedRep);
        System.assertEquals(selectedAdServingRep, pageController.selectedAdServingRep);
        System.assertEquals(selectedEyeDemandRep, pageController.selectedEyeDemandRep);
    }

    // Fail with missing fields
    public static testMethod void SaveFailMissingFieldsTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account existingAccount;
        Account account;
        AccountExtension pageController;
        existingAccount = ObjectFactory.createCAClient('Client');
        account = ObjectFactory.createCAClient('Client');
        upsert(existingAccount);
        pageController = initPage(account);
        System.PageReference tempPageSave = pageController.save();
        System.PageReference tempPageSaveNew = pageController.saveNew();

        // Set assert parameters
        String expectSaveUrl = null;
        String resultSaveUrl = null;
        String expectSaveNewUrl = null;
        String resultSaveNewUrl = null;
        if (tempPageSave != null)
            resultSaveUrl = tempPageSave.getUrl();
        if (tempPageSaveNew != null)
            resultSaveNewUrl = tempPageSaveNew.getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectSaveUrl, resultSaveUrl);
        System.assertEquals(expectSaveNewUrl, resultSaveNewUrl);
    }

    // Save with proper fields
    public static testMethod void SaveFailDuplicateNameTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account account = ObjectFactory.createCAClient('Client');
        insert account;
        Account accountFail = ObjectFactory.createCAClient('Client');
        AccountExtension pageController;
        pageController = initPage(accountFail);

        // Set assert parameters
        pageController.validateAccountName();
        System.PageReference expectPage = null;
        System.PageReference saveResultPage = pageController.save();
        System.PageReference saveNewResultPage = pageController.saveNew();
        Test.stopTest();

        // Assert
        System.assertEquals(expectPage, saveResultPage);
        System.assertEquals(expectPage, saveNewResultPage);
    }

    // Save with proper fields
    public static testMethod void SaveSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account account;
        AccountExtension pageController;
        account = ObjectFactory.createCAClient('Client');
        Employee__c salesRep = ObjectFactory.createSalesRep('Firstname Lastname');
        insert salesRep;
        account.Adserving_Sales_Rep__c = salesRep.Id;
        account.eyedemand_Sales_Rep__c = salesRep.Id;
        insert account;
        pageController = initPage(account);
        pageController.validateAccountName();
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = (new ApexPages.StandardController(account)).view().getUrl();
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
        ObjectFactory.createDefaultSalesRep();
        Account account;
        AccountExtension pageController;
        account = ObjectFactory.createCAClient('Client');
        Employee__c salesRep = ObjectFactory.createSalesRep('Firstname Lastname');
        insert salesRep;
        account.Adserving_Sales_Rep__c = salesRep.Id;
        account.eyedemand_Sales_Rep__c = salesRep.Id;
        insert account;
        pageController = initPage(account);
        System.PageReference tempPage = pageController.saveNew();

        // Set assert parameters
        String expectUrl = (new PageReference('/' + ('' + pageController.account.get('Id')).subString(0, 3) + '/e?')).getUrl();
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
        ObjectFactory.createDefaultSalesRep();
        Account account;
        AccountExtension pageController;
        account = ObjectFactory.createCAClient('Client');
        insert account;
        pageController = initPage(account);
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String resultUrl = pageController.cancel().getUrl();
        String expectUrl = (new ApexPages.StandardController(account)).view().getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }
}