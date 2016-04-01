@isTest
public class SchedulableMonthSpendUpdateTest {
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

    public static testMethod void updateMonthSpendTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        initMonthMap();

        // Month spend attributes
        Date today = Date.today();
        Integer currentMonth = today.month();
        String currentMonthString = monthMap.get(currentMonth);
        Integer currentYear = today.year();
        Integer prevMonth = Math.mod(today.month() - 1, 13);
        String prevMonthString = monthMap.get(prevMonth);
        Integer prevYear = prevMonth == 12 ? currentYear - 1 : currentYear;

        // Opportunity attributes
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createClosedWonOpportunity(client, brand, 'Opportunity');
        insert opportunity;

        // Create month spends
        Month_Spend__c monthSpend1 = ObjectFactory.createMonthSpendWithDate(opportunity, 1000, currentMonthString, currentYear);
        Month_Spend__c monthSpend2 = ObjectFactory.createMonthSpendWithDate(opportunity, 2000, prevMonthString, prevYear);
        monthSpend1.Current_Month__c = false;
        monthSpend2.Current_Month__c = true;
        insert monthSpend1;
        insert monthSpend2;
        String monthSpendId1 = monthSpend1.Id;
        String monthSpendId2 = monthSpend2.Id;

        SchedulableMonthSpendUpdate schedulableMonthSpendUpdate = new SchedulableMonthSpendUpdate();
        SchedulableContext sc;
        schedulableMonthSpendUpdate.execute(sc);

        Test.stopTest();

        Month_Spend__c monthSpendPost1 = [select Current_Month__c from Month_Spend__c where Id = :monthSpendId1][0];
        Month_Spend__c monthSpendPost2 = [select Current_Month__c from Month_Spend__c where Id = :monthSpendId2][0];

        System.assertEquals(true, monthSpendPost1.Current_Month__c);
        System.assertEquals(false, monthSpendPost2.Current_Month__c);
    }
}