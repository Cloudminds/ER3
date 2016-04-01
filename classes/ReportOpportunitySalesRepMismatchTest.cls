@isTest
public class ReportOpportunitySalesRepMismatchTest {

    // Init the page controller
    private static ReportOpportunitySalesRepMismatch initPage() {
        Test.setCurrentPageReference(Page.Report_Opportunity_Sales_Rep_Mismatch);
        return new ReportOpportunitySalesRepMismatch();
    }

    public static testMethod void PositiveMismatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        Employee__c salesRep1 = ObjectFactory.createSalesRep('Rep1');
        Employee__c salesRep2 = ObjectFactory.createSalesRep('Rep2', 2, 5002);
        insert salesRep1;
        insert salesRep2;
        Account client =  ObjectFactory.createCAClient('Client');
        client.eyedemand_Sales_Rep__c = salesRep1.Id;
        client.Adserving_Sales_Rep__c = salesRep1.Id;
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opp');
        opportunity.Primary_Display_Sales_Rep__c = salesRep2.Id;
        opportunity.Primary_Mobile_Sales_Rep__c = salesRep2.Id;
        insert opportunity;
        ReportOpportunitySalesRepMismatch pageController = initPage();


        // Set assert parameters
        Integer expect = 1;
        Integer result = pageController.mismatchData.size();
        Test.stopTest();

        // Assert
        System.assertEquals(expect, result);
    }
}