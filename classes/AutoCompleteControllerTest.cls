@isTest
private class AutoCompleteControllerTest {

    static testMethod void AccountSearchTest() {
        //create some test account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 10 ; i++) {
            accountList.add(new Account(Name = 'Test' + i));
        }
        //insert test records
        insert accountList;
        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(accountList.get(0));
        AutoCompleteController acc = new AutoCompleteController();
        AutoCompleteController accWithParam = new AutoCompleteController(standardController);
        acc.searchTerm = 'Test0';
        accWithParam.searchTerm = 'Test1';
        AutoCompleteController.searchAccount('Test0');
        AutoCompleteController.searchAccount('Test1');

        Test.stopTest();
    }

    static testMethod void BrandSearchTest() {
        //create some test account
        List<Brand__c> brandList = new List<Brand__c>();
        for(Integer i =0 ; i < 10 ; i++) {
            brandList.add(new Brand__c(Name = 'Test' + i));
        }
        //insert test records
        insert brandList;
        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(brandList.get(0));
        AutoCompleteController acc = new AutoCompleteController();
        AutoCompleteController accWithParam = new AutoCompleteController(standardController);
        acc.searchTerm = 'Test0';
        accWithParam.searchTerm = 'Test1';
        AutoCompleteController.searchBrand('Test0');
        AutoCompleteController.searchBrand('Test1');

        Test.stopTest();
    }
}