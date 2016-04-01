public class ReportOpportunityForecastBySalesRep {
    public List<Opportunity> opportunities { get; set; }
    public List<ForecastData> forecastByRep { get; set; }
    public List<ForecastData> forecastByRepTable { get; set; }
    private Transient Map<Id, Decimal> salesRepToManagedAmtMap { get; set; }
    private Transient Map<Id, Decimal> salesRepToSelfServeAmtMap { get; set; }
    private Transient Map<Id, String> salesRepIdToNameMap { get; set; }
    private Date today { get; set; }
    private Integer todayYear { get; set; }
    private Integer todayMonth { get; set; }
    public String label { get; set; }
    
    public class ForecastData implements Comparable{
        public String employee { get; set; }
        public Decimal totalSpend { get; set; }
        public Decimal managedAmount { get; set; }
        public Decimal selfServeAmount { get; set; }
     
        public ForecastData(String employee, Decimal managedAmount, Decimal selfServeAmount) {
            this.employee = employee;
            this.managedAmount = managedAmount.setscale(2);
            this.selfServeAmount = selfServeAmount.setscale(2);
            this.totalSpend = (managedAmount + selfServeAmount).setScale(2);
        }

        public Integer compareTo(Object compareTo) {
            ForecastData other = (ForecastData) compareTo;
            if (this.totalSpend > other.totalSpend)
              return -1;
            else if (this.totalSpend == other.totalSpend)
              return 0;
            return 1;
        }
    }

    // Constructor
    public ReportOpportunityForecastBySalesRep() {
        recalculateForecast();
    }

    // Recalculate forecast based on changed start date
    private void recalculateForecast() {
        initFields();
        populateHistoricalMonthSpends();
        calculateRemainingBudgets();
        createForecastData();
    }

    // Initialize fields
    private void initFields() {
        label = 'TOTAL FORECAST';
        today = Date.today();
        todayYear = today.year();
        todayMonth = today.month();

    }

    // Set historical month spends
    private void populateHistoricalMonthSpends() {
        List <Month_Spend__c> monthSpendList = [SELECT Amount__c, Opportunity__r.Self_Serve__c, Opportunity__r.OwnerId, Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName 
            FROM Month_Spend__c 
            WHERE Year__c =:todayYear
        ];
        
        salesRepIdToNameMap = new Map<Id, String>();
        salesRepToManagedAmtMap = new Map<Id, Decimal>();
        salesRepToSelfServeAmtMap = new Map<Id, Decimal>();

        for(Month_Spend__c ms: monthSpendList) {
            // Populate opportunity owners with their ids, names
            if (!salesRepIdToNameMap.containsKey(ms.Opportunity__r.OwnerId)) {
                salesRepIdToNameMap.put(ms.Opportunity__r.OwnerId, ms.Opportunity__r.Owner.FirstName + ' ' + ms.Opportunity__r.Owner.LastName.substring(0,1).toUpperCase() + '.');
            }
            
            if(ms.Opportunity__r.Self_Serve__c){
                if (salesRepIdToNameMap.containsKey(ms.Opportunity__r.OwnerId)){
                    Decimal existingSelfServeAmt = salesRepToSelfServeAmtMap.get(ms.Opportunity__r.OwnerId) == null ? 0.0 : salesRepToSelfServeAmtMap.get(ms.Opportunity__r.OwnerId);
                    salesRepToSelfServeAmtMap.put(ms.Opportunity__r.OwnerId, existingSelfServeAmt + ms.Amount__c);
                }
            } else {
                if (salesRepIdToNameMap.containsKey(ms.Opportunity__r.OwnerId)){
                    Decimal existingManagedAmt = salesRepToManagedAmtMap.get(ms.Opportunity__r.OwnerId) == null ? 0.0 : salesRepToManagedAmtMap.get(ms.Opportunity__r.OwnerId);
                    salesRepToManagedAmtMap.put(ms.Opportunity__r.OwnerId, existingManagedAmt + ms.Amount__c);
                }
            }
        }    
    }

    // Calculate remaining budget for each Closed Won Opportunity
    private void calculateRemainingBudgets() {
        Date startOfMonth = Date.newInstance(todayYear, todayMonth, 1);
        Date endOfYear = Date.newInstance(todayYear, 12, 31);
        opportunities = [SELECT OwnerId, Owner.FirstName, Owner.LastName, Amount, Total_Spend_MTD__c, Campaign_Start_Date__c, Campaign_End_Date__c, Self_Serve__c FROM Opportunity 
            WHERE StageName = 'Closed Won'
            AND RecordType.Name = 'eyeDemand' 
            AND Campaign_End_Date__c >= :startOfMonth
            AND Campaign_End_Date__c <= :endOfYear
            AND Campaign_Start_Date__c <= :endOfYear
        ];

        for(Opportunity opportunity: opportunities) {
            Date startDate = opportunity.Campaign_Start_Date__c > today ? opportunity.Campaign_Start_Date__c : today;
            Date endDate = opportunity.Campaign_End_Date__c;
            Date forecastEndDate = opportunity.Campaign_End_Date__c < endOfYear ? opportunity.Campaign_End_Date__c : endOfYear;

            // Add Forecasted Spend
            Decimal totalAmount = opportunity.Amount;

            // Get spent amount
            Decimal totalMonthSpendToDate = opportunity.Total_Spend_MTD__c != null ? opportunity.Total_Spend_MTD__c : 0.0;

            // Remaining budget is total amount - ALL spent
            Decimal remainingBudget = totalAmount == null ? 0.0 :(totalAmount - totalMonthSpendToDate);
            Integer remainingDays = startDate.daysBetween(endDate) + 1;          

            if(remainingBudget > 0) {
                Decimal dailyBudget =(remainingDays>= 1 ?(remainingBudget / remainingDays) : 0);
                // Get month to month budget
                Decimal forecastedBudget = splitBudget(dailyBudget, startDate, forecastEndDate);
                
                if(opportunity.Self_Serve__c) {
                    if (salesRepIdToNameMap.containsKey(opportunity.OwnerId)){
                        Decimal existingSelfServeAmt = salesRepToSelfServeAmtMap.get(opportunity.OwnerId) == null ? 0.0 : salesRepToSelfServeAmtMap.get(opportunity.OwnerId);
                        salesRepToSelfServeAmtMap.put(opportunity.OwnerId, existingSelfServeAmt + forecastedBudget);
                    }
                } else {
                    if (salesRepIdToNameMap.containsKey(opportunity.OwnerId)){
                        Decimal existingManagedAmt = salesRepToManagedAmtMap.get(opportunity.OwnerId) == null ? 0.0 : salesRepToManagedAmtMap.get(opportunity.OwnerId);
                        salesRepToManagedAmtMap.put(opportunity.OwnerId, existingManagedAmt + forecastedBudget);
                    } else {
                        salesRepIdToNameMap.put(opportunity.OwnerId, opportunity.Owner.FirstName + ' ' + opportunity.Owner.LastName.substring(0,1).toUpperCase() + '.');
                        salesRepToManagedAmtMap.put(opportunity.OwnerId, remainingBudget);
                    }
                }
            }
        }
    }

    // Split an Opportunity's budget into a list by month
    private Decimal splitBudget(Decimal dailyBudget, Date startDate, Date endDate) {
        Decimal forecastedBudget = 0.0;
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
            forecastedBudget += monthBudget;
        }
        return forecastedBudget;
    }

    private void createForecastData() {
        forecastByRep = new List<ForecastData>();
        forecastByRepTable = new List<ForecastData>();
        Decimal managedTotal = 0.0;
        Decimal selfServeTotal = 0.0;
        Decimal total = 0.0;
        
        for (Id id : salesRepIdToNameMap.keySet()){
            Decimal managedAmt = salesRepToManagedAmtMap.get(id) == null ? 0.0 : salesRepToManagedAmtMap.get(id);
            Decimal selfServeAmt = salesRepToSelfServeAmtMap.get(id) == null ? 0.0 : salesRepToSelfServeAmtMap.get(id);
            forecastByRep.add(new ForecastData(salesRepIdToNameMap.get(id), managedAmt/1000.0, selfServeAmt/1000.0));
            forecastByRepTable.add(new ForecastData(salesRepIdToNameMap.get(id), managedAmt, selfServeAmt));
            // Calculate totals
            managedTotal += managedAmt;  
            selfServeTotal += selfServeAmt;
        }
        
        forecastByRep.sort();
        forecastByRepTable.sort();
        //forecastByRepTable = forecastByRep.clone();
        forecastByRepTable.add(new ForecastData(label, managedTotal, selfServeTotal));
    }
}