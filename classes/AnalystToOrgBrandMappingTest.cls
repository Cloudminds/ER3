@isTest
public class AnalystToOrgBrandMappingTest {

    // Init the page controller
    private static AnalystToOrgBrandMapping initPage(Account account) {
        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        Test.setCurrentPageReference(Page.Analyst_To_Org_Brand_Mapping);
        return new AnalystToOrgBrandMapping(standardController);
    }

    // Save with proper fields
    public static testMethod void SaveSuccessTest() {
        Test.startTest();

        // Create all objects for test
        Account account;
        AnalystToOrgBrandMapping pageController;
        account = ObjectFactory.createCAClient('Client');
        Brand__c brand = ObjectFactory.createBrand('testBrand');
        insert brand;
        insert account;
        Account_Brand_Junction__c accBrandJunction = ObjectFactory.createAccountBrandJunction(account, brand); 
        insert accBrandJunction;
        pageController = initPage(account);
        pageController.isAccountBrand = true;       
        pageController.getBrandOptions();
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        //String expectUrl = (new ApexPages.StandardController(account)).view().getUrl();
        //String resultUrl = '';
        //resultUrl = tempPage.getUrl();
        //Test.stopTest();
        // Assert
        //System.assertEquals(expectUrl, resultUrl);
    }
}