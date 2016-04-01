@isTest
public class ReportOpportunityForecastTest {

    // Init the page controller
    private static ReportOpportunityForecast initPage(ReportOpportunityForecast pageController) {
        Test.setCurrentPageReference(Page.Report_Opportunity_Forecast_CA);
        return pageController;
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
        Opportunity tempOpportunityOne = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 1');
        Opportunity tempOpportunityTwo = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 2');
        Opportunity tempOpportunityThree = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 3');
        Opportunity tempOpportunityFour = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 4');
        Date today = Date.today();
        Date endOfYear  = Date.newInstance (today.year(), 12, 31);
        tempOpportunityOne.Campaign_Start_Date__c = today;
        tempOpportunityOne.Campaign_End_Date__c = endOfYear;
        tempOpportunityOne.Amount = 25000;
        tempOpportunityOne.Region__c = 'Canada';
        tempOpportunityTwo.Campaign_Start_Date__c = today;
        tempOpportunityTwo.Campaign_End_Date__c = endOfYear;
        tempOpportunityTwo.Amount = 25000;
        tempOpportunityOne.Region__c = 'Canada';
        tempOpportunityThree.Campaign_Start_Date__c = today;
        tempOpportunityThree.Campaign_End_Date__c = endOfYear;
        tempOpportunityThree.Amount = 25000;
        tempOpportunityThree.Region__c = 'United States';
        tempOpportunityThree.Self_Serve__c = TRUE;
        insert tempOpportunityOne;
        insert tempOpportunityTwo;
        insert tempOpportunityThree;
        Month_Spend__c monthSpendOne = ObjectFactory.createMonthSpend(tempOpportunityOne, 10000);
        Month_Spend__c monthSpendTwo = ObjectFactory.createMonthSpend(tempOpportunityTwo, 10000);
        Month_Spend__c monthSpendThree = ObjectFactory.createMonthSpend(tempOpportunityThree, 10000);
        monthSpendOne.Year__c = today.year();
        monthSpendOne.Month__c = 'March';
        monthSpendTwo.Year__c = today.year();
        monthSpendOne.Month__c = 'April';
        monthSpendThree.Year__c = today.year();
        monthSpendOne.Month__c = 'May';
        insert monthSpendOne;
        insert monthSpendTwo;
        insert monthSpendThree;
        ReportOpportunityForecast pageController = new ReportOpportunityForecast();
        initPage(pageController);

        pageController.isCumulativeView = TRUE;
        pageController.populateHistoricalMonthSpends();
        pageController.addCreativeOpportunities();
        pageController.createForecastData();
        // Set assert parameters
        Test.stopTest();
        Decimal expectTotalAmount = 45000;
        Decimal resultTotalAmount = 0;

        // Assert
        for (ReportOpportunityForecast.ForecastData forecastData : pageController.forecastCA)
            resultTotalAmount += forecastData.managedAmount;
        // System.assertEquals(expectTotalAmount, resultTotalAmount.setScale(0));
    }
}