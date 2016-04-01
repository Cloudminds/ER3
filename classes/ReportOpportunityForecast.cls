public class ReportOpportunityForecast {
    public List<Opportunity> opportunities { get; set; }
    public transient List<Opportunity> pastOpportunities { get; set; }
    public transient List<Opportunity> cpOpportunities { get; set; }
    public transient List<ForecastData> forecastCA { get; set; }
    public transient List<ForecastData> forecastUS { get; set; }
    public transient List<ForecastData> forecastCATable { get; set; }
    public transient List<ForecastData> forecastUSTable { get; set; }
    public transient Map<Id, List<Month_Spend__c>> opportunityIdToMonthSpendMap { get; set; }
    public Opportunity forecastStartDate { get; set; }
    private Decimal forecastCATotal { get; set; }
    private Decimal forecastUSTotal { get; set; }
    private Decimal forecastCASelfServeTotal { get; set; }
    private Decimal forecastUSSelfServeTotal { get; set; }
    private Decimal forecastCAActualTotal { get; set; } 
    private Decimal forecastCASelfServeActualTotal  { get; set; } 
    private Decimal forecastUSActualTotal { get; set; } 
    private Decimal forecastUSSelfServeActualTotal { get; set; } 
    private Decimal forecastCACreativeTotal { get; set; }
    private Decimal forecastUSCreativeTotal { get; set; }
    private List<Decimal> ytdBudgetCA { get; set; }
    private List<Decimal> ytdBudgetUS { get; set; }
    private List<Decimal> ytdBudgetSelfServeCA { get; set; }
    private List<Decimal> ytdBudgetSelfServeUS { get; set; }
    private List<Decimal> ytdBudgetCreativeCA { get; set; }
    private List<Decimal> ytdBudgetCreativeUS { get; set; }
    private List<Decimal> ytdActualBudgetCA { get; set; }
    private List<Decimal> ytdActualBudgetUS { get; set; }
    private List<Decimal> ytdActualBudgetSelfServeCA { get; set; }
    private List<Decimal> ytdActualBudgetSelfServeUS { get; set; }
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
    public Date today { get; set; }
    public Integer todayYear { get; set; }
    public Integer todayMonth { get; set; }
    public Boolean isCumulativeView { get; set; }
    private Decimal cumulativeSumToDateManagedCA { get; set; }
    private Decimal cumulativeSumToDateSelfServeCA { get; set; }
    private Decimal cumulativeSumToDateManagedUS { get; set; }
    private Decimal cumulativeSumToDateSelfServeUS { get; set; }

    public class ForecastData {
        public String month { get; set; }
        public Decimal managedAmount { get; set; }
        public Decimal selfServeAmount { get; set; }
        public Decimal creativeAmount { get; set; }
        public Decimal actualSumToDateManaged { get; set; }
        public Decimal actualSumToDateSelfServe { get; set; }
        public Decimal forecastedMonthlyTotal { get; set; }
        public Decimal actualMonthlyTotal { get; set; }
        public String type { get; set; }
        public ForecastData(String month, Decimal managedAmount, Decimal selfServeAmount, Decimal creativeAmount, Decimal actualSumToDateManaged, Decimal actualSumToDateSelfServe, String type) {
            this.month = month;
            this.managedAmount = managedAmount;
            this.selfServeAmount = selfServeAmount;
            this.creativeAmount = creativeAmount;
            this.actualSumToDateManaged = actualSumToDateManaged;
            this.actualSumToDateSelfServe = actualSumToDateSelfServe;
            this.forecastedMonthlyTotal = managedAmount + selfServeAmount + creativeAmount;
            this.actualMonthlyTotal = actualSumToDateManaged + actualSumToDateSelfServe + creativeAmount;
            this.type = type;
        }
       
    }
    private static Map<String, Integer> monthsMap = new Map<String, Integer>{
        'January'  => 1,
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

    // Constructor
    public ReportOpportunityForecast() {
        forecastStartDate = new Opportunity(
            Campaign_Start_Date__c = Date.today(),
            Campaign_End_Date__c = Date.today()
        );
        isCumulativeView = FALSE;
        recalculateForecast();
    }

    // Recalculate forecast based on changed start date
    public void recalculateForecast() {
        initFields();
        // Historical
        populateHistoricalMonthSpends();

        // Forecasted
        getOpportunities();
        calculateRemainingBudgets();

        // Creative
        getCreativeOpportunities();
        addCreativeOpportunities();

        // Populate Data
        createForecastData();
    }

    // Initialize fields
    private void initFields() {
        today = forecastStartDate.Campaign_Start_Date__c;
        todayYear = today.year();
        todayMonth = today.month();
        ytdBudgetCA = new List <Decimal>();
        ytdBudgetUS = new List <Decimal>();
        ytdBudgetSelfServeCA = new List <Decimal>();
        ytdBudgetSelfServeUS = new List <Decimal>();
        ytdBudgetCreativeCA = new List <Decimal>();
        ytdBudgetCreativeUS = new List <Decimal>();
        ytdActualBudgetCA = new List <Decimal>();
        ytdActualBudgetUS = new List <Decimal>();
        ytdActualBudgetSelfServeCA = new List <Decimal>();
        ytdActualBudgetSelfServeUS = new List <Decimal>();
        for(Integer i = 0; i <12; i++) {
            ytdBudgetCA.add(0);
            ytdBudgetUS.add(0);
            ytdBudgetSelfServeCA.add(0);
            ytdBudgetSelfServeUS.add(0);
            ytdBudgetCreativeCA.add(0);
            ytdBudgetCreativeUS.add(0);
            ytdActualBudgetCA.add(0);
            ytdActualBudgetUS.add(0);
            ytdActualBudgetSelfServeCA.add(0);
            ytdActualBudgetSelfServeUS.add(0);
        }
        forecastCATotal = 0;
        forecastUSTotal = 0;
        forecastCASelfServeTotal = 0;
        forecastUSSelfServeTotal = 0;
        forecastCACreativeTotal = 0;
        forecastUSCreativeTotal = 0;
        forecastCAActualTotal = 0;
        forecastUSActualTotal = 0;
        forecastCASelfServeActualTotal = 0;
        forecastUSSelfServeActualTotal = 0;
        cumulativeSumToDateManagedCA = 0;
        cumulativeSumToDateSelfServeCA = 0;
        cumulativeSumToDateManagedUS = 0;
        cumulativeSumToDateSelfServeUS = 0;
        opportunityIdToMonthSpendMap = new Map <Id, List <Month_Spend__c>>();
    }

    // Set historical month spends
    @TestVisible
    private void populateHistoricalMonthSpends() {
        Date startOfMonth = Date.newInstance(todayYear, todayMonth, 1);
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        List <Month_Spend__c> monthSpendList = [SELECT Name, Amount__c, Month__c, Year__c, Opportunity__c, Opportunity__r.Region__c, Opportunity__r.Self_Serve__c FROM Month_Spend__c WHERE Year__c =:todayYear ORDER BY Opportunity__c ASC];
        for(Month_Spend__c ms: monthSpendList) {
            if (isCumulativeView){
                if(monthsMap.get(ms.Month__c) <= todayMonth) {
                    if(ms.Opportunity__r.Region__c == 'Canada') {
                        if(ms.Opportunity__r.Self_Serve__c)
                            ytdBudgetSelfServeCA[todayMonth - 1] += ms.Amount__c;
                        else
                            ytdBudgetCA[todayMonth - 1] += ms.Amount__c;
                    }
                    if(ms.Opportunity__r.Region__c == 'United States') {
                        if(ms.Opportunity__r.Self_Serve__c)
                            ytdBudgetSelfServeUS[todayMonth - 1] += ms.Amount__c;
                        else
                            ytdBudgetUS[todayMonth - 1] += ms.Amount__c;
                    }
                }

                for(Integer i = todayMonth; i <13; i++) {
                    ytdActualBudgetCA[i - 1] = ytdBudgetCA[todayMonth - 1];
                    ytdActualBudgetUS[i - 1] = ytdBudgetUS[todayMonth - 1];
                    ytdActualBudgetSelfServeCA[i - 1] = ytdBudgetSelfServeCA[todayMonth - 1];
                    ytdActualBudgetSelfServeUS[i - 1] = ytdBudgetSelfServeUS[todayMonth - 1];
                }
            } else {
                if(ms.Opportunity__r.Region__c == 'Canada') {
                    if(ms.Opportunity__r.Self_Serve__c) {
                        ytdBudgetSelfServeCA[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                        ytdActualBudgetSelfServeCA[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                    }
                    else {
                        ytdBudgetCA[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                        ytdActualBudgetCA[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                    }
                }
                if(ms.Opportunity__r.Region__c == 'United States') {
                    if(ms.Opportunity__r.Self_Serve__c) {
                        ytdBudgetSelfServeUS[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                        ytdActualBudgetSelfServeUS[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                    }
                    else {
                        ytdBudgetUS[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                        ytdActualBudgetUS[monthsMap.get(ms.Month__c) - 1] += ms.Amount__c;
                    }
                }
            }
        }
    }

    // Get Opportunities that are Closed Won and haven't ended
    @TestVisible
    private void getOpportunities() {
        Date startOfMonth = Date.newInstance(todayYear, todayMonth, 1);
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        opportunities = [SELECT Name, Amount, Booked_Amount_eyeControl__c, Region__c, Total_Spend_MTD__c, Campaign_Start_Date__c, Campaign_End_Date__c, Self_Serve__c, RecordType.Name FROM Opportunity WHERE StageName in ('Closed Won', 'Paused') AND RecordType.Name = 'eyeDemand' AND Campaign_End_Date__c >=:startOfMonth AND Campaign_End_Date__c <=:endOfYear AND Campaign_Start_Date__c <=:endOfYear 
        ];
    }

    // Calculate remaining budget for each Closed Won Opportunity
    @TestVisible
    private void calculateRemainingBudgets() {
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        for(Opportunity opportunity: opportunities) {
    
            // Add Forecasted Spend
            // If start date is before today, use today as start date
            Date startDate = opportunity.Campaign_Start_Date__c > today ? opportunity.Campaign_Start_Date__c : today;
            Date endDate = opportunity.Campaign_End_Date__c;
            Date forecastEndDate = opportunity.Campaign_End_Date__c < endOfYear ? opportunity.Campaign_End_Date__c : endOfYear;
            Integer startMonth = startDate.month();

            //************ WE ARE USING total amount only for the time being since an ioid can have multiple campaigns. only takes the latest saved changes from one campaign
            // If no booked amount, use total amount
            // Boolean bookedAmountIsEmpty = opportunity.Booked_Amount_eyeControl__c == null || opportunity.Booked_Amount_eyeControl__c == 0;
            // Decimal totalAmount = bookedAmountIsEmpty ? opportunity.Amount : opportunity.Booked_Amount_eyeControl__c;
            Decimal totalAmount = opportunity.Amount;

            // Get spent amount
            Decimal totalMonthSpendToDate = opportunity.Total_Spend_MTD__c != null ? opportunity.Total_Spend_MTD__c : 0;

            // Remaining budget is total amount - ALL spent
            Decimal remainingBudget = totalAmount == null ? 0 :(totalAmount - totalMonthSpendToDate);
            Integer remainingDays = startDate.daysBetween(endDate) + 1;          

            if(remainingBudget > 0) {
                Decimal dailyBudget =(remainingDays>= 1 ?(remainingBudget / remainingDays) : 0);
                // Get month to month budget
                List <Decimal> budgetForecast = splitBudget(dailyBudget, startDate, forecastEndDate);
                if(budgetForecast.size()> 0) {
                    for(Integer i = startMonth; (i < 13) && (i <= forecastEndDate.month()); i++) {
                        if(opportunity.Region__c == 'Canada') {
                            if(!opportunity.Self_Serve__c) {
                                ytdBudgetCA[i - 1] += budgetForecast[i - startMonth];
                            } else {
                                ytdBudgetSelfServeCA[i - 1] += budgetForecast[i - startMonth];
                            }
                        }
                        if(opportunity.Region__c == 'United States') {
                            if(!opportunity.Self_Serve__c)
                                ytdBudgetUS[i - 1] += budgetForecast[i - startMonth];
                            else
                                ytdBudgetSelfServeUS[i - 1] += budgetForecast[i - startMonth];
                        }
                    }
                }
            }
        }
    }

    // Split an Opportunity's budget into a list by month
    @TestVisible
    private List <Decimal> splitBudget(Decimal dailyBudget, Date startDate, Date endDate) {
        List <Decimal> budgetForecast = new List <Decimal>();

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
        return budgetForecast;
    }

    // Get Creative Opportunities that are Closed Won in the future
    @TestVisible
    private void getCreativeOpportunities() {
        cpOpportunities = [SELECT Name, Amount, Region__c, CloseDate, RecordType.Name FROM Opportunity WHERE(StageName = 'Closed Won'
                OR StageName = 'Ready To Bill') AND Recordtype.Name = 'Creative Production'
            AND CloseDate = THIS_YEAR
        ];
    }

    // Calculate remaining budget for each Closed Won Opportunity
    @TestVisible
    private void addCreativeOpportunities() {
        for(Opportunity opportunity: cpOpportunities) {
            if (!isCumulativeView){
                Integer index = opportunity.CloseDate.month() - 1;
                if(opportunity.Region__c == 'Canada')
                    ytdBudgetCreativeCA[index] += opportunity.Amount;
                if(opportunity.Region__c == 'United States')
                    ytdBudgetCreativeUS[index] += opportunity.Amount;
            }else{
                if(opportunity.Region__c == 'Canada')
                    ytdBudgetCreativeCA[todayMonth -1] += opportunity.Amount;
                if(opportunity.Region__c == 'United States')
                    ytdBudgetCreativeUS[todayMonth -1] += opportunity.Amount;
            }
        }
    }

    @TestVisible
    private void createForecastData() {
        forecastCA = new List <ForecastData>();
        forecastUS = new List <ForecastData>();
        forecastCATable = new List <ForecastData>();
        forecastUSTable = new List <ForecastData>();
        
        // Set actual budget for the current month to add on to forecasted amount for future months
        if (isCumulativeView) {
            for(Integer i = todayMonth+1; i <13; i++) {
                cumulativeSumToDateManagedCA = ytdBudgetCA[i - 2];
                cumulativeSumToDateSelfServeCA = ytdBudgetSelfServeCA[i - 2];
                cumulativeSumToDateManagedUS = ytdBudgetUS[i - 2];
                cumulativeSumToDateSelfServeUS = ytdBudgetSelfServeUS[i - 2];

                ytdBudgetCA[i - 1] += cumulativeSumToDateManagedCA;
                ytdBudgetSelfServeCA[i - 1] += cumulativeSumToDateSelfServeCA;
                ytdBudgetUS[i - 1] += cumulativeSumToDateManagedUS;
                ytdBudgetSelfServeUS[i - 1] += cumulativeSumToDateSelfServeUS;
            }
        } else
            todayMonth = 1;

        for(Integer i = todayMonth - 1; i <12; i++) {
            //CA
            forecastCA.add(new ForecastData(months[i], (ytdBudgetCA[i]/1000.0).setScale(2), (ytdBudgetSelfServeCA[i]/1000.0).setScale(2), (ytdBudgetCreativeCA[i]/1000.0).setScale(2), (ytdActualBudgetCA[i]/1000.0).setScale(2), (ytdActualBudgetSelfServeCA[i]/1000.0).setScale(2), 'monthly'));
            forecastCATable.add(new ForecastData(months[i], ytdBudgetCA[i], ytdBudgetSelfServeCA[i], ytdBudgetCreativeCA[i], ytdActualBudgetCA[i], ytdActualBudgetSelfServeCA[i], 'monthly'));
            forecastCATotal += ytdBudgetCA[i];
            forecastCASelfServeTotal += ytdBudgetSelfServeCA[i];
            forecastCAActualTotal += ytdActualBudgetCA[i];
            forecastCASelfServeActualTotal += ytdActualBudgetSelfServeCA[i];
            forecastCACreativeTotal += ytdBudgetCreativeCA[i];

            //US
            forecastUS.add(new ForecastData(months[i], (ytdBudgetUS[i]/1000.0).setScale(2), (ytdBudgetSelfServeUS[i]/1000.0).setScale(2), (ytdBudgetCreativeUS[i]/1000.0).setScale(2), (ytdActualBudgetUS[i]/1000.0).setScale(2), (ytdActualBudgetSelfServeUS[i]/1000.0).setScale(2), 'monthly'));
            forecastUSTable.add(new ForecastData(months[i], ytdBudgetUS[i], ytdBudgetSelfServeUS[i], ytdBudgetCreativeUS[i], ytdActualBudgetUS[i], ytdActualBudgetSelfServeUS[i], 'monthly'));
            forecastUSTotal += ytdBudgetUS[i];
            forecastUSSelfServeTotal += ytdBudgetSelfServeUS[i];
            forecastUSActualTotal += ytdActualBudgetUS[i];
            forecastUSSelfServeActualTotal += ytdActualBudgetSelfServeUS[i];
            forecastUSCreativeTotal += ytdBudgetCreativeUS[i];
        }

        if(!isCumulativeView){
            forecastCATable.add(new ForecastData('TOTAL', forecastCATotal, forecastCASelfServeTotal, forecastCACreativeTotal, forecastCAActualTotal, forecastCASelfServeActualTotal, 'total'));
            forecastUSTable.add(new ForecastData('TOTAL', forecastUSTotal, forecastUSSelfServeTotal, forecastUSCreativeTotal, forecastUSActualTotal, forecastUSSelfServeActualTotal, 'total'));
        }
    }
}