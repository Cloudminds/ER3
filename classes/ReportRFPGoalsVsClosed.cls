public with sharing class ReportRFPGoalsVsClosed{
    public String loggedInUserId {get;set;}
    public List<Employee__c> salesRep {get;set;}
    public List<Sales_Quota__c> quotasOwned {get; set;}
    public Integer THIS_YEAR {get;set;}
    public String THIS_YEAR_STRING {get;set;}
    public static final Double WIN_RATE_US = 0.3;
    public static final Double WIN_RATE_CANADA = 0.75;
    public ReportRFPGoalsVsClosed(){
    	loggedInUserId = UserInfo.getUserId();
    }
    
    public List<RFPGoalData> getRfpDataWithQuarterNames() {
        DateTime today = datetime.now();
        THIS_YEAR = Integer.valueOf(today.format('YYYY'));
        THIS_YEAR_STRING = today.format('YYYY');
        
        salesRep = [SELECT Id, Name, Region__c FROM Employee__c WHERE Related_To__c =: loggedInUserId LIMIT 1];
        List<RFPGoalData> rfpData = new List<RFPGoalData>();
        Decimal[] salesActualArray = new List<Decimal>{0.0,0.0,0.0,0.0};

        if(!salesRep.isEmpty()){
	        String salesRepRegion = salesRep[0].Region__c;
	        quotasOwned = [SELECT Q1_Quota__c, Q2_Quota__c, Q3_Quota__c, Q4_Quota__c FROM Sales_Quota__c WHERE Year__c =: THIS_YEAR_STRING AND Employee__c =: salesRep[0].Id LIMIT 1];
	        Decimal[] rfpGoalArray = new List<Decimal>{0.0,0.0,0.0,0.0};
	        if(!quotasOwned.isEmpty()){
	            Double winRate = 0.0;
	            if(salesRepRegion != null){
		            if(salesRepRegion.equals('US'))
		                winRate = WIN_RATE_US;
		            else if(salesRepRegion.equals('Canada'))
		                winRate = WIN_RATE_CANADA;
	            }
	            for(Integer i = 1; i<=rfpGoalArray.size(); i++)
	                rfpGoalArray[i-1] = winRate*(Decimal)quotasOwned[0].get('Q'+i+'_Quota__c');
	        }
	        
	        List<Opportunity> closedOppsThisYear = [SELECT Display_Budget__c, Mobile_Budget__c, Primary_Display_Sales_Rep__c, Primary_Mobile_Sales_Rep__c, 
	                                    Secondary_Display_Sales_Rep__c, Secondary_Mobile_Sales_Rep__c, CloseDate 
	                                    FROM Opportunity WHERE stageName='Closed Won' AND CALENDAR_YEAR(CloseDate) =: THIS_YEAR];
	        
            for (Opportunity o : closedOppsThisYear){
                Integer quarter = ((o.CloseDate.Month()-1)/3)+1;
                
                if(o.Primary_Display_Sales_Rep__c == salesRep[0].Id && o.Secondary_Display_Sales_Rep__c == salesRep[0].Id)
                    salesActualArray[quarter-1] += (o.Display_Budget__c != null ? o.Display_Budget__c / 2 : 0);
                else if(o.Primary_Display_Sales_Rep__c == salesRep[0].Id || o.Secondary_Display_Sales_Rep__c== salesRep[0].Id)
                    salesActualArray[quarter-1] += (o.Display_Budget__c != null ? o.Display_Budget__c : 0);
                if(o.Primary_Mobile_Sales_Rep__c == salesRep[0].Id && o.Secondary_Mobile_Sales_Rep__c == salesRep[0].Id)
                    salesActualArray[quarter-1] += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c / 2 : 0);
                else if(o.Primary_Mobile_Sales_Rep__c == salesRep[0].Id || o.Secondary_Mobile_Sales_Rep__c == salesRep[0].Id)
                    salesActualArray[quarter-1] += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c : 0);
            }
            
            for (Integer i=1; i<=salesActualArray.size(); i++){
                RFPGoalData opp = new RFPGoalData('Q'+i, rfpGoalArray[i-1], salesActualArray[i-1]);     
                rfpData.add(opp);
            }
        }
        return rfpData;
    }
    
    public class RFPGoalData
    {
        public String quarter { get; set; }
        public Decimal rfpGoal { get; set; }
        public Decimal quarterlyRev { get; set; }

        public RFPGoalData(String qtr, Decimal rfpTargetGoal, Decimal rev)
        {
            quarter = qtr;
            rfpGoal = rfpTargetGoal;
            quarterlyRev = rev;
        }
    }
}