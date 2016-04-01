public with sharing class ReportSalesQuotaVsClosed {
  public Employee__c salesRep {get;set;}
  public Decimal salesActual {get;set;}
  public Decimal salesQuota {get;set;}
  public String quarter {get;set;}
  public String loggedInUserId {get;set;}
  public String THIS_YEAR {get; set;}

  public ReportSalesQuotaVsClosed(){
  	loggedInUserId = UserInfo.getUserId();
  	try{
	    salesRep = [SELECT Id, Name FROM Employee__c WHERE Related_To__c =: loggedInUserId LIMIT 1];
	    DateTime d = datetime.now();
	    THIS_YEAR = d.format('YYYY');
	    salesActual = getSalesActual(loggedInUserId);
	    salesQuota = getSalesQuota(loggedInUserId);
    }catch(Exception e){
      System.debug('ERROR:' + e);
    }
  }

  public Decimal getSalesActual(String loggedInUserId){
    try{
      salesActual = 0.0;
      if(salesRep != null){
        List<Opportunity> opportunitiesOwned = [SELECT Display_Budget__c, Mobile_Budget__c, Primary_Display_Sales_Rep__c, Primary_Mobile_Sales_Rep__c, Secondary_Display_Sales_Rep__c, Secondary_Mobile_Sales_Rep__c FROM Opportunity WHERE CloseDate = THIS_FISCAL_QUARTER AND StageName = 'Closed Won'];

        for(Opportunity o : opportunitiesOwned){
          if(o.Primary_Display_Sales_Rep__c == salesRep.Id && o.Secondary_Display_Sales_Rep__c== salesRep.Id)
            salesActual += (o.Display_Budget__c != null ? o.Display_Budget__c / 2 : 0);
          else if(o.Primary_Display_Sales_Rep__c == salesRep.Id || o.Secondary_Display_Sales_Rep__c== salesRep.Id)
            salesActual += (o.Display_Budget__c != null ? o.Display_Budget__c : 0);
          
          if(o.Primary_Mobile_Sales_Rep__c == salesRep.Id && o.Secondary_Mobile_Sales_Rep__c == salesRep.Id)
            salesActual += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c / 2 : 0);
          else if(o.Primary_Mobile_Sales_Rep__c == salesRep.Id || o.Secondary_Mobile_Sales_Rep__c == salesRep.Id)
            salesActual += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c : 0);
        }
      }
    }catch(Exception e){
      System.debug('ERROR:' + e);
    }
    return salesActual;
  }

  public Decimal getSalesQuota(String loggedInUserId){
    try{
      salesQuota = 0.0;
      if(salesRep != null){
        List<Sales_Quota__c> quotasOwned = [SELECT Q1_Quota__c, Q2_Quota__c, Q3_Quota__c, Q4_Quota__c FROM Sales_Quota__c WHERE Year__c =: THIS_YEAR AND Employee__c =: salesRep.Id];

        quarter = 'Q' + (((System.Today().Month()-1)/3)+1);
        String qtrFilter = quarter + '_Quota__c';
        if(!quotasOwned.isEmpty()){
          for(Sales_Quota__c sq : quotasOwned)
            salesQuota += (Decimal)sq.get(qtrFilter);
        }
      }
    }catch(Exception e){
      System.debug('ERROR:' + e);
    }
    return salesQuota;
  }
}