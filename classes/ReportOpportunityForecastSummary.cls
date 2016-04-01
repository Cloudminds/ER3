global class ReportOpportunityForecastSummary {
    public Transient List<Opportunity> opportunities { get; set; }
    public Transient Map<Id, Opportunity> opportunitiesMap { get; set; }
    public Transient List<String> headers { get; set; }
    private Transient Map<Id, Decimal> opportunityIdToSpendAmtMap { get; set; }
    public List<Decimal> monthTotalCA { get; set; }
    public List<Decimal> monthTotalUS { get; set; }
    private List<String> months { get {
        months = new List<String>();
        months.add('Jan');
        months.add('Feb');
        months.add('Mar');
        months.add('Apr');
        months.add('May');
        months.add('Jun');
        months.add('Jul');
        months.add('Aug');
        months.add('Sep');
        months.add('Oct');
        months.add('Nov');
        months.add('Dec');
        return months;
    } set; }
    private static Map<String, Integer> monthsMap = new Map<String, Integer>{
        'January' => 1,
        'February' => 2,
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12
    };
    public Date today { get; set; }
    public Integer todayMonth { get; set; }
    public Integer todayYear { get; set; }
    public class ForecastData {
        public String month { get; set; }
        public Decimal amount { get; set; }
        public ForecastData(String month, Decimal amount) {
            this.month = month;
            this.amount = amount;
        }
    }
    public Transient List<TableData> opportunityForecastCA { get; set; }
    public Transient List<TableData> opportunityForecastUS { get; set; }
    global class TableData implements Comparable {
        public String name { get; set; }
        public String id { get; set; }
        public Date startDate { get; set; }
        public String sf_ioid { get; set; }
        public List<ForecastData> forecast { get; set; }
        public TableData() {
            forecast = new List<ForecastData>();
        }
        global Integer compareTo(Object compareTo) {
            TableData compareToObject = (TableData) compareTo;
            Integer returnValue = 0;
            if (startDate == null && compareToObject.startDate == null)
                returnValue = 0;
            else if (startDate == null)
                returnValue = 1;
            else if (compareToObject.startDate == null)
                returnValue = -1;
            else if (compareToObject.startDate > startDate)
                returnValue = -1;
            else if (compareToObject.startDate < startDate)
                returnValue = 1;
            return returnValue;
        }
    }

    public ReportOpportunityForecastSummary() {
        recalculateForecast();
    }
            
    // Recalculate forecast based on changed start date
    public void recalculateForecast() {
        today = Date.today();
        todayMonth = today.month();
        todayYear = today.year();
        opportunityForecastCA = new List<TableData>();
        opportunityForecastUS = new List<TableData>();
        opportunityIdToSpendAmtMap = new Map<Id, Decimal>();
        monthTotalCA = new List<Decimal>();
        monthTotalUS = new List<Decimal>();
       
        headers = new List<String>();
        for (Integer i = 0; i < 12; i++) {
            monthTotalCA.add(0);
            monthTotalUS.add(0);
            if (i >= today.month() - 1) {
                headers.add(months[i]);
            }
        }
        headers.add('Forecast Total');

        getOpportunities();
        populateHistoricalMonthSpends();
        calculateRemainingBudgets();
        opportunityForecastCA.sort();
        opportunityForecastUS.sort();
    }

    // Get Opportunities that are Closed Won and haven't ended
    private void getOpportunities() {
        Date startOfMonth = Date.newInstance(todayYear, todayMonth, 1);
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        opportunities = [SELECT Name, Amount, Region__c, Total_Spend_MTD__c, Campaign_Start_Date__c, Campaign_End_Date__c, SF_IOID__c, Self_Serve__c, RecordType.Name FROM Opportunity WHERE StageName = 'Closed Won' AND RecordType.Name = 'eyeDemand' AND Campaign_End_Date__c >=:startOfMonth AND Campaign_End_Date__c <=:endOfYear AND Campaign_Start_Date__c <=:endOfYear
        ];
        opportunitiesMap = new Map<Id, Opportunity>(opportunities);
    }

    // Set historical month spends
    private void populateHistoricalMonthSpends() {
        List <Month_Spend__c> monthSpendList = [SELECT Name, Amount__c, Month__c, Year__c, Opportunity__c FROM Month_Spend__c WHERE Year__c =:todayYear AND Spend_Date__c = THIS_MONTH ORDER BY CreatedDate ASC];
        for(Month_Spend__c ms: monthSpendList) {
            Opportunity opportunity = opportunitiesMap.get(ms.Opportunity__c);
            
            // Create Map from opportunityForecast List
            opportunityIdToSpendAmtMap.put(ms.Opportunity__c, ms.Amount__c);
        }
    }
    
    // Calculate remaining budget for each Closed Won Opportunity
    private void calculateRemainingBudgets() {
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        Decimal spendTotalAllOppsCA = 0.0;
        Decimal spendTotalAllOppsUS = 0.0;
        for (Opportunity opportunity : opportunities) {
            Decimal spendTotal = 0.0;
            Date startDate = opportunity.Campaign_Start_Date__c > today ? opportunity.Campaign_Start_Date__c : today;
            Date endDate = opportunity.Campaign_End_Date__c;
            Date forecastEndDate = opportunity.Campaign_End_Date__c < endOfYear ? opportunity.Campaign_End_Date__c : endOfYear;
            Integer startMonth = startDate.month();
            String region = opportunity.Region__c;

            // If no booked
            Decimal totalAmount = opportunity.Amount;
            Decimal totalMonthSpendToDate = opportunity.Total_Spend_MTD__c != null ? opportunity.Total_Spend_MTD__c : 0;

            Decimal remainingBudget = totalAmount == null ? 0 :(totalAmount - totalMonthSpendToDate);
            Integer remainingDays = startDate.daysBetween(endDate) + 1;
            
            if (remainingBudget > 0) {
                Decimal dailyBudget =(remainingDays>= 1 ?(remainingBudget / remainingDays) : 0);
                List<Decimal> budgetForecast = splitBudget(dailyBudget, startDate, forecastEndDate, opportunity.Region__c);
                if (budgetForecast.size() > 0) {
                    TableData tableData = new TableData();
                    tableData.name = opportunity.Name;
                    tableData.id = opportunity.Id;
                    tableData.startDate = opportunity.Campaign_Start_Date__c;
                    tableData.sf_ioid = opportunity.SF_IOID__c;
                    for (Integer i = today.month(); i < 13; i++) {
                        Decimal historicalSpend = 0.0;
                        Decimal monthTotal = 0.0;
                        ForecastData forecastData = new ForecastData(months[i - 1], budgetForecast[i - today.month()].setScale(2));

                        if (i == todayMonth) {
                            if (opportunityIdToSpendAmtMap.containsKey(opportunity.Id)){
                                historicalSpend = opportunityIdToSpendAmtMap.get(opportunity.Id);
                                forecastData.amount += historicalSpend.setScale(2);
                            }
                        }
                        tableData.forecast.add(forecastData);
                        spendTotal += forecastData.amount;
                        monthTotal = forecastData.amount;
                        if (region == 'Canada') monthTotalCA[i - 1] += monthTotal;
                        if (region == 'United States') monthTotalUS[i - 1] += monthTotal;
                    }
                    tableData.forecast.add(new ForecastData('Forecast Total', spendTotal.setScale(2)));
                    if (region == 'Canada') {
                    	opportunityForecastCA.add(tableData);
                    	spendTotalAllOppsCA += spendTotal;
                    }
                    if (region == 'United States') {
                    	opportunityForecastUS.add(tableData);
                    	spendTotalAllOppsUS += spendTotal;
                    }
                }
            }
        }
        TableData tableDataCA = new TableData();
        tableDataCA.name = 'CANADIAN MONTH TO MONTH TOTALS:';
        tableDataCA.id = '';
        tableDataCA.startDate = endOfYear;
        tableDataCA.sf_ioid = '';
        TableData tableDataUS = new TableData();
        tableDataUS.name = 'US MONTH TO MONTH TOTALS:';
        tableDataUS.id = '';
        tableDataUS.startDate = endOfYear;
        tableDataUS.sf_ioid = '';
        for (Integer i = Date.today().month() - 1; i < 12; i++) {
            ForecastData forecastDataCA = new ForecastData(months[i], monthTotalCA[i].setScale(2));
            ForecastData forecastDataUS = new ForecastData(months[i], monthTotalUS[i].setScale(2));
            tableDataCA.forecast.add(forecastDataCA);
            tableDataUS.forecast.add(forecastDataUS);
        }
        ForecastData forecastDataCA = new ForecastData('Forecast Total', spendTotalAllOppsCA.setScale(2));
        tableDataCA.forecast.add(forecastDataCA);
        ForecastData forecastDataUS = new ForecastData('Forecast Total', spendTotalAllOppsUS.setScale(2));
        tableDataUS.forecast.add(forecastDataUS);
        
        opportunityForecastCA.add(tableDataCA);
        opportunityForecastUS.add(tableDataUS);
    }
 
    // Split an Opportunity's budget into a list by month
    private List <Decimal> splitBudget(Decimal dailyBudget, Date startDate, Date endDate, String region) {
        List <Decimal> budgetForecast = new List <Decimal>();
        
        // Pad with 0's for campaigns that haven't started
        if (startDate.month() > todayMonth){
            for (Integer i = todayMonth; i < startDate.month(); i++) {
                budgetForecast.add(0.00);
            }    
        }
        for(Integer currentMonth = startDate.month(); currentMonth <= endDate.month(); currentMonth++) {
            Integer startDay = 1;
            Integer endDay = Date.daysInMonth(startDate.year(), currentMonth);
            Decimal monthBudget = 0;
            Integer daysInMonth = 0;
            if(currentMonth == startDate.month())
                startDay = startDate.day();
            if(currentMonth == endDate.month())
                endDay = endDate.day();

            if(endDay >= startDay) {
                daysInMonth = endDay - startDay + 1;
                monthBudget =(daysInMonth * dailyBudget).setScale(2);
            }
            budgetForecast.add(monthBudget);
        }

        // Pad with 0's for campaigns that have ended before last month of year
        for (Integer i = endDate.month(); i < 12; i++) {
            budgetForecast.add(0.00);
        }
        return budgetForecast;
    }
}