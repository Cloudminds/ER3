@isTest
public class ReportOpportunityRFPForecastTest {

    // Init the page controller
    private static ReportOpportunityRFPForecast initPage() {
        Test.setCurrentPageReference(Page.Report_Opportunity_RFP_Forecast_CA);
        return new ReportOpportunityRFPForecast();
    }

    private static testMethod void initTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        // Create all objects for test
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity tempOpportunityOne = ObjectFactory.createRFPOpportunity(client, brand, 'Temp Opportunity 1');
        Opportunity tempOpportunityTwo = ObjectFactory.createRFPOpportunity(client, brand, 'Temp Opportunity 2');
        Opportunity tempOpportunityThree = ObjectFactory.createRFPOpportunity(client, brand, 'Temp Opportunity 3');
        Opportunity tempOpportunityFour = ObjectFactory.createRFPOpportunity(client, brand, 'Temp Opportunity 4');
        
        Date today = Date.today();
        Date endOfYear  = Date.newInstance (today.year(), 12, 31);
        
        Id edRecordTypeId = [SELECT Id From RecordType Where SobjectType = 'Opportunity' and Name = 'eyeDemand' LIMIT 1].Id;
        tempOpportunityOne.CloseDate = today;
        tempOpportunityOne.Amount = 25000;
        tempOpportunityOne.Display_Budget__c = 24000;
        tempOpportunityOne.Mobile_Budget__c = 1000;
        tempOpportunityOne.Region__c = 'Canada';
        tempOpportunityOne.RecordTypeId = edRecordTypeId;

        tempOpportunityTwo.CloseDate = Date.newInstance(today.year() - 1, 12, 17);
        tempOpportunityTwo.Amount = 26000;
        tempOpportunityTwo.Display_Budget__c = 25000;
        tempOpportunityTwo.Mobile_Budget__c = 1000;
        tempOpportunityTwo.Region__c = 'Canada';
        tempOpportunityTwo.RecordTypeId = edRecordTypeId;

        tempOpportunityThree.CloseDate = Date.newInstance(today.year() + 1, 2, 17);
        tempOpportunityThree.Amount = 26000;
        tempOpportunityThree.Display_Budget__c = 25000;
        tempOpportunityThree.Mobile_Budget__c = 1000;
        tempOpportunityThree.Region__c = 'United States';
        tempOpportunityThree.RecordTypeId = edRecordTypeId;

        insert tempOpportunityOne;
        insert tempOpportunityTwo;
        insert tempOpportunityThree;

        ReportOpportunityRFPForecast pageController = initPage();
        pageController.startDate = Date.newInstance(2013, 12, 17);
        pageController.endDate = Date.newInstance(2014, 12, 17);
        pageController.todayYear = 2014;
        
        tempOpportunityFour.CloseDate = Date.newInstance(2013, 12, 17);
        tempOpportunityFour.Display_Budget__c = 24000;
        tempOpportunityFour.Mobile_Budget__c = 1000;
        tempOpportunityFour.Amount = 25000;
        tempOpportunityFour.Region__c = 'Canada';
        tempOpportunityFour.RecordTypeId = edRecordTypeId;
        insert tempOpportunityFour;
        
        Opportunity tempOpportunityFive = tempOpportunityFour.clone();
        tempOpportunityFive.Region__c = 'United States';
        insert tempOpportunityFive;

        pageController.getOpportunities();
        pageController.generatePipeline();
        pageController.createForecastData();

        pageController.todayYear = 2013;
        pageController.generatePipeline();
        // Set assert parameters
        Test.stopTest();
        Decimal expectTotalAmount = 100000;
        Decimal resultTotalAmount = 0;

        // Assert
        for (ReportOpportunityRFPForecast.ForecastData forecastData : pageController.forecastCA)
            resultTotalAmount += forecastData.displayAmount;
        //System.assertEquals(expectTotalAmount, resultTotalAmount.setScale(0));
    }
}