public virtual class ReportOpportunitySalesRepMismatch {
    public List<Opportunity> opportunities { get; set; }
    public List<Opportunity> mismatchOpportunities { get; set; }
    public List<MismatchData> mismatchData { get; set; }
    public Date today { get; set; }
    public Integer todayYear { get; set; }
    public Boolean isDashboardView {get; set;}
	public static Map<String, Id> recordTypeMap {get; set;}{
		recordTypeMap = new Map<String, Id>();
		for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' ORDER BY Name]) {
		    recordTypeMap.put(rt.Name,rt.Id);
		}		
	}
	
    public class MismatchData {
        public String opportunityName { get; set; }
        public String opportunityType { get; set; }
        public String accountName { get; set; }
        public String accountSalesRep { get; set; }
        public String opportunitySalesRepDisplay { get; set; }
        public String opportunitySalesRepMobile { get; set; }
        public MismatchData(Opportunity opportunity, Account account, String accountSalesRep) {
            this.opportunityName = opportunity.Name;
            this.opportunityType = opportunity.RecordType.Name;
            this.accountName = account.Name;

            this.accountSalesRep = accountSalesRep;

            if (opportunity.Primary_Display_Sales_Rep__c == null)
                this.opportunitySalesRepDisplay = 'NULL';
            else
                this.opportunitySalesRepDisplay = opportunity.Primary_Display_Sales_Rep__r.Name;

            if (opportunity.Primary_Mobile_Sales_Rep__c == null)
                this.opportunitySalesRepMobile = 'NULL';
            else
                this.opportunitySalesRepMobile = opportunity.Primary_Mobile_Sales_Rep__r.Name;
        }
    }

    public ReportOpportunitySalesRepMismatch() {
        today = Date.today();
        todayYear = today.year();
        mismatchOpportunities = new List<Opportunity>();
        isDashboardView = false;
        getOpportunities();
        getMismatches();
        createData();
    }

    protected virtual void getOpportunities() {
        opportunities = [select
            AccountId,
            Name,
            Type,
            RecordType.Name,
            RecordTypeId,
            Primary_Display_Sales_Rep__r.Name,
            Primary_Mobile_Sales_Rep__r.Name,
            Account.Name,
            Account.Adserving_Sales_Rep__r.Name,
            Account.eyedemand_Sales_Rep__r.Name
        from Opportunity];
    }

    private void getMismatches() {
        for (Opportunity opportunity : opportunities) {
            if (opportunity.RecordType.Name == 'eyeDemand' && opportunity.Account.eyedemand_Sales_Rep__c != null && (opportunity.Primary_Display_Sales_Rep__c != opportunity.Account.eyedemand_Sales_Rep__c || opportunity.Primary_Mobile_Sales_Rep__c != opportunity.Account.eyedemand_Sales_Rep__c))
                mismatchOpportunities.add(opportunity);
            else if (opportunity.RecordType.Name == 'Adserving' && opportunity.Account.Adserving_Sales_Rep__c != null && (opportunity.Primary_Display_Sales_Rep__c != opportunity.Account.Adserving_Sales_Rep__c || opportunity.Primary_Mobile_Sales_Rep__c != opportunity.Account.Adserving_Sales_Rep__c))
                mismatchOpportunities.add(opportunity);
        }
    }

    private void createData() {
        mismatchData = new List<MismatchData>();
        for (Opportunity mismatchOpportunity : mismatchOpportunities) {
            String accountSalesRep;
            if (mismatchOpportunity.RecordType.Name == 'Adserving') {
                accountSalesRep = mismatchOpportunity.account.Adserving_Sales_Rep__r.Name;
            }
            else if (mismatchOpportunity.RecordType.Name == 'eyeDemand') {
                accountSalesRep = mismatchOpportunity.account.eyedemand_Sales_Rep__r.Name;
            }
            if (accountSalesRep != null)
                mismatchData.add(new MismatchData(mismatchOpportunity, mismatchOpportunity.Account, accountSalesRep));
        }
    }
}