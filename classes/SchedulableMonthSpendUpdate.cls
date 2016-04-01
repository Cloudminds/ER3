global class SchedulableMonthSpendUpdate implements Schedulable {
    public static String CRON_EXP = '0 0 3 ? * *';

    global static String scheduleIt() {
        return System.schedule('Current Month Spend Update', CRON_EXP, new SchedulableMonthSpendUpdate());
    }

    global void execute(SchedulableContext sc) {
        Map<Integer,String> monthMap = new Map<Integer,String>();
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
        String currentMonth = monthMap.get(Date.today().month());
        Integer currentYear = Date.today().year();

        List<Month_Spend__c> monthSpends = [select Current_Month__c from Month_Spend__c where Current_Month__c = true];
        for (Month_Spend__c monthSpend : monthSpends) {
            monthSpend.Current_Month__c = false;
        }
        update monthSpends;

        monthSpends = [select Current_Month__c from Month_Spend__c where Month__c = :currentMonth and Year__c = :currentYear];
        for (Month_Spend__c monthSpend : monthSpends) {
            monthSpend.Current_Month__c = true;
        }
        update monthSpends;
    }
}