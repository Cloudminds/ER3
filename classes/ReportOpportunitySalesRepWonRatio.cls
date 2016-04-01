global class ReportOpportunitySalesRepWonRatio {
    public Transient List<Opportunity> opportunities { get; set; }
    public Map<String, Integer> salesRepWon { get; set; }
    public Map<String, Integer> salesRepClosed { get; set; }
    public List<TableData> tableData { get; set; }
    global class TableData implements Comparable {
        public String name { get; set; }
        public Decimal ratio { get; set; }
        public TableData(String name, Decimal ratio) {
            this.name = name;
            this.ratio = ratio;
        }
        global Integer compareTo(Object compareTo) {
            if (this.ratio > ((TableData) compareTo).ratio)
                return -1;
            else if (this.ratio < ((TableData) compareTo).ratio)
                return 1;
            return 0;
        }
    }

    public ReportOpportunitySalesRepWonRatio() {
        salesRepWon = new Map<String, Integer>();
        salesRepClosed = new Map<String, Integer>();
        tableData = new List<TableData>();
        initSalesRepMaps();
        getOpportunities();
        calculateRatios();
        createTableData();
    }

    private void initSalesRepMaps() {
        for (Employee__c salesRep : [select Id from Employee__c where Sales_Rep__c = true]) {
            salesRepWon.put(salesRep.Id, 0);
            salesRepClosed.put(salesRep.Id, 0);
        }
    }

    private void getOpportunities() {
        // Get All Opportunities
        opportunities = [select Primary_Display_Sales_Rep__c, Primary_Display_Sales_Rep__r.Name, Primary_Mobile_Sales_Rep__c, Primary_Mobile_Sales_Rep__r.Name, StageName, Name from Opportunity WHERE RecordType.Name = 'eyeDemand'];
    }

    private void calculateRatios() {
        // Calculate remaining budget for each Closed Won Opportunity
        for (Opportunity opportunity : opportunities) {
            // Get Sales Reps
            String salesRepDisplay = opportunity.Primary_Display_Sales_Rep__c;
            String salesRepMobile = opportunity.Primary_Mobile_Sales_Rep__c;

            // Add display sales rep
            if (salesRepDisplay != null && salesRepClosed.get(salesRepDisplay) >= 0) {
                salesRepClosed.put(salesRepDisplay, (salesRepClosed.get(salesRepDisplay)) + 1);
                
                if (opportunity.StageName == 'Closed Won') {
                    salesRepWon.put(salesRepDisplay, salesRepWon.get(salesRepDisplay) + 1);
                }
            }
            // Add mobile sales rep if different from display
            if (salesRepMobile != null && salesRepDisplay != null && salesRepClosed.get(salesRepMobile) >= 0 && salesRepDisplay != salesRepMobile ) {
                salesRepClosed.put(salesRepMobile, salesRepClosed.get(salesRepMobile) + 1);
                if (opportunity.StageName == 'Closed Won') {
                    salesRepWon.put(salesRepMobile, salesRepWon.get(salesRepMobile) + 1);
                }
            }
        }
    }

    private void createTableData() {
        tableData = new List<TableData>();
        for (String salesRepId : salesRepClosed.keySet()) {
            if (salesRepId != null) {
                String salesRepName = [select Name from Employee__c where Id = :salesRepId LIMIT 1][0].Name;
                Decimal won = salesRepWon.get(salesRepId);
                Decimal total = salesRepClosed.get(salesRepId);
                if (total != 0)
                    tableData.add(new TableData(salesRepName, ((won / total) * 100).round()));
            }
        }
        tableData.sort();
    }
}