@isTest
private class BrandExtensionTest {

    private static BrandExtension initPage(Brand__c brand) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(brand);
        Test.setCurrentPageReference(Page.Brand_Custom);
        return new BrandExtension(standardController);
    }

    static testMethod void newBrandSaveTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert account;
        BrandExtension pageController = initPage(brand);
        pageController.oppShell.AccountId = account.Id;
        System.PageReference tempPageSave = pageController.save();
        System.PageReference tempPageSaveNew = pageController.saveNew();
        String expectUrl = (new ApexPages.StandardController(pageController.brand)).view().getUrl();
        String resultUrl = null;
        if (tempPageSave != null)
            resultUrl = tempPageSave.getUrl();
        Test.stopTest();

        System.assertEquals(expectUrl, resultUrl);
    }

    static testMethod void editBrandSaveTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert account;
        insert brand;
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        abj.Name = 'Temp Name';
        abj.Account__c = account.Id;
        abj.Brand__c = brand.Id;
        BrandExtension pageController = initPage(brand);
        pageController.oppShell.AccountId = account.Id;
        System.PageReference tempPageSave = pageController.save();
        Test.stopTest();
    }


}