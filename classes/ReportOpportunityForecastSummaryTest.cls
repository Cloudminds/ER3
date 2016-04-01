@isTest
public class ReportOpportunityForecastSummaryTest {

    private static Map<Integer,String> monthMap;

    private static void initMonthMap() {
        monthMap = new Map<Integer,String>();
        monthMap.put(1, 'January');
        monthMap.put(2, 'February');
        monthMap.put(3, 'March');
        monthMap.put(4, 'April');
        monthMap.put(5, 'May');
        monthMap.put(6, 'June');
        monthMap.put(7, 'July');
        monthMap.put(8, 'August');
        monthMap.put(9, 'September');
        monthMap.put(10, 'October');
        monthMap.put(11, 'November');
        monthMap.put(12, 'December');
    }

    // Init the page controller
    private static ReportOpportunityForecastSummary initPage() {
        Test.setCurrentPageReference(Page.Report_Opportunity_Forecast_Summary);
        return new ReportOpportunityForecastSummary();
    }

    // Test a successful contact creation
    public static testMethod void CreatePageTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        initMonthMap();

        Date today = Date.today();
        Date endOfYear  = Date.newInstance (today.year(), 12, 31);
        Integer currentMonth = today.month();
        String currentMonthString = monthMap.get(currentMonth);
        Integer currentYear = today.year();
        Integer prevMonth = Math.mod(today.month() - 1, 13);
        String prevMonthString = monthMap.get(prevMonth);
        Integer prevYear = prevMonth == 12 ? currentYear - 1 : currentYear;

        ObjectFactory.createDefaultSalesRep();
        // Create all objects for test
        RecordType rt = [select Id, Name from RecordType where SobjectType='Opportunity' and Name='eyeDemand' Limit 1];

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
        tempOpportunityOne.Campaign_Start_Date__c = today;
        tempOpportunityOne.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityOne.Amount = 25000;
        tempOpportunityOne.RecordTypeId = rt.Id;
        tempOpportunityTwo.Campaign_Start_Date__c = today;
        tempOpportunityTwo.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityTwo.Amount = 25000;
        tempOpportunityTwo.RecordTypeId = rt.Id;
        tempOpportunityThree.Campaign_Start_Date__c = today;
        tempOpportunityThree.Campaign_End_Date__c = today.addDays(15);
        tempOpportunityThree.Amount = 25000;
        tempOpportunityThree.RecordTypeId = rt.Id;
        insert tempOpportunityOne;
        insert tempOpportunityTwo;
        insert tempOpportunityThree;
        Month_Spend__c monthSpendOne = ObjectFactory.createMonthSpend(tempOpportunityOne, 10000);
        Month_Spend__c monthSpendTwo = ObjectFactory.createMonthSpend(tempOpportunityTwo, 10000);
        Month_Spend__c monthSpendThree = ObjectFactory.createMonthSpend(tempOpportunityThree, 10000);
        monthSpendOne.Year__c = today.year();
        monthSpendOne.Month__c = monthMap.get(today.month());
        monthSpendTwo.Year__c = today.year();
        monthSpendOne.Month__c = monthMap.get(today.month());
        monthSpendThree.Year__c = today.year();
        monthSpendOne.Month__c = monthMap.get(today.month()-1);
        insert monthSpendOne;
        insert monthSpendTwo;
        insert monthSpendThree;
        
        ReportOpportunityForecastSummary controller = initPage();
        controller.recalculateForecast();

        Test.stopTest();
    }
}