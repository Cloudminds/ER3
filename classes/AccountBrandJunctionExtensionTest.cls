@isTest
private class AccountBrandJunctionExtensionTest {

    private static AccountBrandJunctionExtension initPage(Account_Brand_Junction__c abj) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(abj);
        Test.setCurrentPageReference(Page.Account_Brand_Junction_Custom);
        return new AccountBrandJunctionExtension(standardController);
    }

    private static AccountBrandJunctionExtension initPageWithSaveURL(Account_Brand_Junction__c abj, String saveURL) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(abj);
        PageReference pageRef = Page.Account_Brand_Junction_Custom;
        pageRef.getParameters().put('saveURL', saveURL);
        Test.setCurrentPageReference(pageRef);
        return new AccountBrandJunctionExtension(standardController);
    }

    static testMethod void newABJSaveTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        upsert(account);
        upsert(brand);
        AccountBrandJunctionExtension pageController = initPage(abj);
        pageController.abj.Account__c = account.Id;
        pageController.abj.Brand__c = brand.Id;
        pageController.save();
        Test.stopTest();

        // System.assertEquals(expectUrl, resultUrl);
    }

    static testMethod void newABJWithSaveURLTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        upsert(account);
        upsert(brand);
        AccountBrandJunctionExtension pageControllerAccount = initPageWithSaveURL(abj, account.Id);
        AccountBrandJunctionExtension pageControllerBrand = initPageWithSaveURL(abj, brand.Id);
        Test.stopTest();

        System.assertEquals(account.Id, pageControllerAccount.abj.Account__c);
        System.assertEquals(brand.Id, pageControllerBrand.abj.Brand__c);
    }

    static testMethod void existingABJ() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        ObjectFactory.createDefaultSalesRep();
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        upsert(account);
        upsert(brand);
        abj.Account__c = account.Id;
        abj.Brand__c = brand.Id;
        upsert(abj);
        AccountBrandJunctionExtension pageController = initPage(abj);
        Test.stopTest();

        System.assertEquals(account.Id, pageController.abj.Account__c);
        System.assertEquals(brand.Id, pageController.abj.Brand__c);
    }

    static testMethod void duplicateABJ() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        ObjectFactory.createDefaultSalesRep();
        // Create first abj
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        upsert(account);
        upsert(brand);
        abj.Account__c = account.Id;
        abj.Brand__c = brand.Id;
        upsert(abj);

        // Create duplicate abj
        Account_Brand_Junction__c abjDuplicate = new Account_Brand_Junction__c();
        AccountBrandJunctionExtension pageController = initPage(abjDuplicate);
        pageController.abj.Account__c = account.Id;
        pageController.abj.Brand__c = brand.Id;

        PageReference saveResult;
        saveResult = pageController.save();
        Test.stopTest();

        System.assertEquals(null, saveResult);
    }
}