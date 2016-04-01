@isTest
public class ReportOpportunitySalesRepWonAmountTest {

    // Init the page controller
    private static ReportOpportunitySalesRepWonAmount initPage() {
        return new ReportOpportunitySalesRepWonAmount();
    }

    // Test Primary only AND Primary + Secondary
    private static testMethod void initTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        // Create 3 opportunities with different sales reps and see the list in order
        Employee__c salesRep1 = ObjectFactory.createSalesRep('S1');
        Employee__c salesRep2 = ObjectFactory.createSalesRep('S2', 2, 5002);
        Employee__c salesRep3 = ObjectFactory.createSalesRep('S3', 3, 5003);
        Employee__c salesRep4 = ObjectFactory.createSalesRep('S4', 4, 5004);
        insert salesRep1;
        insert salesRep2;
        insert salesRep3;
        insert salesRep4;

        Account client = ObjectFactory.createCAClient('C1');
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
        Opportunity opportunity7 = ObjectFactory.createClosedWonOpportunity(client, brand, 'O7');
        opportunity1.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity1.Primary_Mobile_Sales_Rep__c = salesRep1.Id;
        opportunity1.Display_Budget__c = 1100;
        opportunity1.Display_Budget_Change__c = 'Decrease';
        opportunity1.Display_Budget_Change_Amount__c = 100;
        opportunity1.Mobile_Budget__c = 1000;
        opportunity2.Primary_Display_Sales_Rep__c = salesRep1.Id;
        opportunity2.Primary_Mobile_Sales_Rep__c = salesRep1.Id;
        opportunity2.Display_Budget__c = 1000;
        opportunity2.Mobile_Budget__c = 1000;
        opportunity3.Primary_Display_Sales_Rep__c = salesRep2.Id;
        opportunity3.Primary_Mobile_Sales_Rep__c = salesRep2.Id;
        opportunity3.Display_Budget__c = 1000;
        opportunity3.Mobile_Budget__c = 1000;
        opportunity4.Primary_Display_Sales_Rep__c = salesRep2.Id;
        opportunity4.Primary_Mobile_Sales_Rep__c = salesRep2.Id;
        opportunity4.Display_Budget__c = 1000;
        opportunity4.Mobile_Budget__c = 1000;
        opportunity4.Mobile_Budget_Change__c = 'Decrease';
        opportunity4.Mobile_Budget_Change_Amount__c = 500;
        opportunity5.Primary_Display_Sales_Rep__c = salesRep3.Id;
        opportunity5.Primary_Mobile_Sales_Rep__c = salesRep3.Id;
        opportunity5.Display_Budget__c = 1000;
        opportunity6.Primary_Display_Sales_Rep__c = salesRep3.Id;
        opportunity6.Primary_Mobile_Sales_Rep__c = salesRep3.Id;
        opportunity6.Display_Budget__c = 1000;
        opportunity6.Mobile_Budget__c = 1000;
        opportunity7.Primary_Display_Sales_Rep__c = salesRep3.Id;
        opportunity7.Secondary_Display_Sales_Rep__c = salesRep4.Id;
        opportunity7.Display_Budget__c = 1000;
        insert opportunity1;
        insert opportunity2;
        // insert opportunity3;
        // insert opportunity4;
        // insert opportunity5;
        // insert opportunity6;
        // insert opportunity7;
        ReportOpportunitySalesRepWonAmount pageController = initPage();

        // Set assert parameters
        Test.stopTest();

        // Assert
        // System.assertEquals(4000, pageController.tableData[0].amount);
        // System.assertEquals(salesRep1.Name, pageController.tableData[0].name);
        // System.assertEquals(3500, pageController.tableData[1].amount);
        // System.assertEquals(salesRep2.Name, pageController.tableData[1].name);
        // System.assertEquals(3500, pageController.tableData[2].amount);
        // System.assertEquals(salesRep3.Name, pageController.tableData[2].name);
        // System.assertEquals(500, pageController.tableData[3].amount);
        // System.assertEquals(salesRep4.Name, pageController.tableData[3].name);
    }
}