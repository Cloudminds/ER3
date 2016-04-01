@isTest
public class ReportOpportunitySalesRepWonRatioTest {

    // Init the page controller
    private static ReportOpportunitySalesRepWonRatio initPage() {
        return new ReportOpportunitySalesRepWonRatio();
    }

    private static testMethod void initTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        // Create 3 opportunities with different sales reps and see the list in order
        Employee__c salesRep1 = ObjectFactory.createSalesRep('S1');
        Employee__c salesRep2 = ObjectFactory.createSalesRep('S2', 2, 5002);
        Employee__c salesRep3 = ObjectFactory.createSalesRep('S3', 3, 5003);
        insert salesRep1;
        insert salesRep2;
        insert salesRep3;

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;

        Opportunity opportunity1 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O1');
        Opportunity opportunity2 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O2');
        Opportunity opportunity3 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O3');
        Opportunity opportunity4 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O4');
        Opportunity opportunity5 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O5');
        Opportunity opportunity6 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O6');
        opportunity1.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity1.Primary_Mobile_Sales_Rep__c = salesRep1.Id;
        opportunity1.StageName = 'Closed Won';
        opportunity2.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity2.Primary_Mobile_Sales_Rep__c = salesRep2.Id;
        opportunity2.StageName = 'Closed Won';
        opportunity3.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity3.Primary_Mobile_Sales_Rep__c = salesRep2.Id;
        opportunity3.StageName = 'Closed Lost';
        opportunity4.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity4.Primary_Mobile_Sales_Rep__c = salesRep3.Id;
        opportunity4.StageName = 'Closed Won';
        opportunity5.Primary_Display_Sales_Rep__c = salesRep3.Id;
        opportunity5.Primary_Mobile_Sales_Rep__c = salesRep3.Id;
        opportunity5.StageName = 'Closed Won';
        opportunity6.Primary_Display_Sales_Rep__c = salesRep3.Id;
        opportunity6.Primary_Mobile_Sales_Rep__c = salesRep3.Id;
        opportunity6.StageName = 'Closed Won';
        insert opportunity1;
        insert opportunity2;
        // insert opportunity3;
        // insert opportunity4;
        // insert opportunity5;
        // insert opportunity6;
        ReportOpportunitySalesRepWonRatio pageController = initPage();

        // Set assert parameters
        Test.stopTest();

        // Assert
        // System.assertEquals(100, pageController.tableData[0].ratio);
        // System.assertEquals(75, pageController.tableData[1].ratio);
        // System.assertEquals(50, pageController.tableData[2].ratio);
    }
}