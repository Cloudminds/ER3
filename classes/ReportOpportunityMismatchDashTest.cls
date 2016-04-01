@isTest
private class ReportOpportunityMismatchDashTest {
    // Init the page controller
    private static ReportOpportunitySalesRepMismatchDash initPage() {
        Test.setCurrentPageReference(Page.Report_Opportunity_Sales_Rep_Mismatch_D);
        return new ReportOpportunitySalesRepMismatchDash();
    }
    
    static testMethod void mismatchDashTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        
        Account client =  ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opp');
        insert opportunity;
         
        ReportOpportunitySalesRepMismatchDash pageController = initPage();
         
        // Set assert parameters
        pageController.getOpportunities();
        Test.stopTest();
    }
}