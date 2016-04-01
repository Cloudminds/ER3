@isTest
public class ReportOpportunityForecastBySalesRepTest {

    // Init the page controller
    private static ReportOpportunityForecastBySalesRep initPage() {
        Test.setCurrentPageReference(Page.Report_Opportunity_Forecast_By_Rep);
        return new ReportOpportunityForecastBySalesRep();
    }

    private static testMethod void initTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        RecordType rt = [select Id, Name from RecordType where SobjectType='Opportunity' and Name='eyeDemand' Limit 1];
        User user = [Select Id from User where Id=: UserInfo.getUserId()];

        // Create all objects for test
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Employee__c salesRep1 = ObjectFactory.createSalesRep('Rep1');
        insert salesRep1;
        Opportunity tempOpportunityOne = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 1');
        Opportunity tempOpportunityTwo = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 2');
        Opportunity tempOpportunityThree = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 3');
        Opportunity tempOpportunityFour = ObjectFactory.createClosedWonOpportunity(client, brand, 'Temp Opportunity 4');
        Date today = Date.today();
        Date endOfYear  = Date.newInstance (today.year(), 12, 31);
        tempOpportunityOne.Campaign_Start_Date__c = today;
        tempOpportunityOne.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityOne.Amount = 25000;
        tempOpportunityOne.RecordTypeId = rt.Id;
        tempOpportunityOne.OwnerId = user.Id;
        tempOpportunityOne.Self_Serve__c = TRUE;
        tempOpportunityTwo.Campaign_Start_Date__c = today;
        tempOpportunityTwo.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityTwo.Amount = 25000;
        tempOpportunityTwo.RecordTypeId = rt.Id;
        tempOpportunityTwo.OwnerId = user.Id;
        tempOpportunityThree.Campaign_Start_Date__c = today;
        tempOpportunityThree.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityThree.Amount = 25000;
        tempOpportunityThree.RecordTypeId = rt.Id;
        tempOpportunityThree.OwnerId = user.Id;
        insert tempOpportunityOne;
        insert tempOpportunityTwo;
        insert tempOpportunityThree;
        Month_Spend__c monthSpendOne = ObjectFactory.createMonthSpend(tempOpportunityOne, 10000);
        Month_Spend__c monthSpendTwo = ObjectFactory.createMonthSpend(tempOpportunityTwo, 10000);
        Month_Spend__c monthSpendThree = ObjectFactory.createMonthSpend(tempOpportunityThree, 10000);
        insert monthSpendOne;
        insert monthSpendTwo;
        insert monthSpendThree;
        
        ReportOpportunityForecastBySalesRep pageController = initPage();
		ReportOpportunityForecastBySalesRep.ForecastData fData = new ReportOpportunityForecastBySalesRep.ForecastData(salesRep1.Name, 50.0, 50.0);
		pageController.forecastByRepTable = new List<ReportOpportunityForecastBySalesRep.ForecastData>();
		pageController.forecastByRepTable.add(fData);
		
        // Set assert parameters
        Test.stopTest();
        Decimal expectTotalAmount = 45000;
        Decimal resultTotalAmount = 0;

        // Assert
        for (ReportOpportunityForecastBySalesRep.ForecastData forecastData : pageController.forecastByRepTable)
            resultTotalAmount += forecastData.totalSpend;
        // System.assertEquals(expectTotalAmount, resultTotalAmount.setScale(0));
    }
}