global class ReportOpportunitySalesRepWonAmount {
    public Transient List<Opportunity> opportunities { get; set; }
    public Date today { get; set; }
    public Date sevenDays { get; set; }
    public Integer todayYear { get; set; }
    public Map<String, Decimal> salesRepMap { get; set; }
    public List<TableData> tableData { get; set; }
    global class TableData implements Comparable {
        public String name { get; set; }
        public Decimal amount { get; set; }
        public TableData(String name, Decimal amount) {
            this.name = name;
            this.amount = amount;
        }
        global Integer compareTo(Object compareTo) {
            if (this.amount > ((TableData) compareTo).amount)
                return -1;
            else if (this.amount < ((TableData) compareTo).amount)
                return 1;
            return 0;
        }
    }

    public ReportOpportunitySalesRepWonAmount() {
        today = Date.today();
        sevenDays = today.addDays(-7);
        todayYear = today.year();
        salesRepMap = new Map<String, Decimal>();
        tableData = new List<TableData>();
        initSalesRepMap();
        getOpportunities();
        calculateBudgets();
        createTableData();
    }

    private void initSalesRepMap() {
        for (Employee__c salesRep : [select Id from Employee__c where Sales_Rep__c = true]) {
            salesRepMap.put(salesRep.Id, 0);
        }
    }

    private void getOpportunities() {
        // Get Opportunities that are Closed within the past 7 days
        opportunities = [select Primary_Display_Sales_Rep__c, Primary_Mobile_Sales_Rep__c, Secondary_Display_Sales_Rep__c, Secondary_Mobile_Sales_Rep__c, Primary_Display_Sales_Rep__r.Name, Primary_Mobile_Sales_Rep__r.Name, Secondary_Display_Sales_Rep__r.Name, Secondary_Mobile_Sales_Rep__r.Name, Display_Budget__c, Mobile_Budget__c, Display_Budget_Change__c, Mobile_Budget_Change__c, Display_Budget_Change_Amount__c, Mobile_Budget_Change_Amount__c from Opportunity where StageName = 'Closed Won' AND CloseDate <= :today AND CloseDate >= :sevenDays];
    }

    private void calculateBudgets() {
        // Calculate remaining budget for each Closed Won Opportunity
        for (Opportunity opportunity : opportunities) {
            Decimal displayBudget = opportunity.Display_Budget__c != null ? opportunity.Display_Budget__c : 0;
            Decimal displayBudgetChange = 0;
            Decimal mobileBudget = opportunity.Mobile_Budget__c != null ? opportunity.Mobile_Budget__c : 0;
            Decimal mobileBudgetChange = 0;
            // Calculate display budget change
            if (opportunity.Display_Budget_Change__c != null && opportunity.Display_Budget_Change_Amount__c != null)
                displayBudgetChange = (opportunity.Display_Budget_Change__c == 'Increase' ? 1 : -1) * opportunity.Display_Budget_Change_Amount__c;
            // Calculate mobile budget change
            if (opportunity.Mobile_Budget_Change__c != null && opportunity.Mobile_Budget_Change_Amount__c != null)
                mobileBudgetChange = (opportunity.Mobile_Budget_Change__c == 'Increase' ? 1 : -1) * opportunity.Mobile_Budget_Change_Amount__c;
            // Add display
            if (opportunity.Primary_Display_Sales_Rep__c != null && opportunity.Primary_Display_Sales_Rep__r.Name != '-UNASSIGNED-' && (displayBudget + displayBudgetChange > 0)) {
                String displayRep = opportunity.Primary_Display_Sales_Rep__c;
                // If secondary display sales rep exists
                if (opportunity.Secondary_Display_Sales_Rep__c != null && opportunity.Secondary_Display_Sales_Rep__r.Name != '-UNASSIGNED-') {
                    String secondaryDisplayRep = opportunity.Secondary_Display_Sales_Rep__c;
                    salesRepMap.put(displayRep, salesRepMap.get(displayRep) + (displayBudget + displayBudgetChange) / 2);
                    salesRepMap.put(secondaryDisplayRep, salesRepMap.get(secondaryDisplayRep) + (displayBudget + displayBudgetChange) / 2);
                } else {
                    salesRepMap.put(displayRep, salesRepMap.get(displayRep) + displayBudget + displayBudgetChange);
                }
            }
            // Add mobile
            if (opportunity.Primary_Mobile_Sales_Rep__c != null && opportunity.Primary_Mobile_Sales_Rep__r.Name != '-UNASSIGNED-' && (mobileBudget + mobileBudgetChange > 0)) {
                String mobileRep = opportunity.Primary_Mobile_Sales_Rep__c;
                // If secondary mobile sales rep exists
                if (opportunity.Secondary_Mobile_Sales_Rep__c != null && opportunity.Secondary_Mobile_Sales_Rep__r.Name != '-UNASSIGNED-') {
                    String secondaryMobileRep = opportunity.Secondary_Mobile_Sales_Rep__c;
                    salesRepMap.put(mobileRep, salesRepMap.get(mobileRep) + (mobileBudget + mobileBudgetChange) / 2);
                    salesRepMap.put(secondaryMobileRep, salesRepMap.get(secondaryMobileRep) + (mobileBudget + mobileBudgetChange) / 2);
                } else {
                    salesRepMap.put(mobileRep, salesRepMap.get(mobileRep) + mobileBudget + mobileBudgetChange);
                }
            }
        }
    }

    private void createTableData() {
        tableData = new List<TableData>();
        for (String salesRepId : salesRepMap.keySet()) {
            String salesRepName = [select Name from Employee__c where Id = :salesRepId][0].Name;
            tableData.add(new TableData(salesRepName, salesRepMap.get(salesRepId)));
        }
        tableData.sort();
    }
}