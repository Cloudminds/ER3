/**
    What    : Fetches Opportunity Record Which Is created Today , RecordType is EyeReturn 
              Stage Name is Closed Won and Ready to Traffic value is False and is not processed in Batch run.          
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Feb 2016
**/

global class ReadyToTrafficBatchable implements Database.Batchable<SObject>, Database.Stateful{  
    
    public String query; 
    global ReadyToTrafficBatchable (String query){
        this.query = query;
        if (this.query == null) {
                string strq='Select Name,Id,Primary_Display_Sales_Rep__r.First_Name__c,Primary_Display_Sales_Rep__r.email__c ,Secondary_Display_Sales_Rep__r.First_Name__c,Secondary_Display_Sales_Rep__r.email__c,Jira_Key__c,Jira_EDT_URL__c from Opportunity where RecordType.Name=\'eyeDemand\' AND Ready_To_Traffic__c = True AND CreatedDate = TODAY AND StageName = \'Closed Won\'';
                this.query = strq;
               
        }
    }  
    
    global ReadyToTrafficBatchable() {
        this.query ='Select Name,Id,Primary_Display_Sales_Rep__r.First_Name__c,Primary_Display_Sales_Rep__r.email__c ,Secondary_Display_Sales_Rep__r.First_Name__c,Secondary_Display_Sales_Rep__r.email__c,Jira_Key__c,Jira_EDT_URL__c from Opportunity where RecordType.Name=\'eyeDemand\' AND Ready_To_Traffic__c = True AND CreatedDate = TODAY AND StageName = \'Closed Won\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){   
         return Database.getQueryLocator(query); 
    }  
    
    global void execute(Database.BatchableContext bc, List<SObject> batch){
        Map<String, Map<id,Opportunity>> mapOpp= new Map<String, Map<id,Opportunity>>();
        Map<String,String> mapEmailFirstName = new  Map<String,String> ();
        Boolean AddNewMapPrimary ;
        Boolean AddNewMapSecondary ;
        for(Opportunity opp: (List<Opportunity>) batch)
         {
             AddNewMapPrimary = false;
             AddNewMapSecondary = false;
             if(mapOpp.size() > 0 ) {
                if( !String.isBlank(opp.Primary_Display_Sales_Rep__r.email__c) && mapOpp.containskey(opp.Primary_Display_Sales_Rep__r.email__c) ){
                    Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(mapOpp.get(opp.Primary_Display_Sales_Rep__r.email__c));
                    mapOpportunity.put(opp.id,opp);   
                    mapOpp.put(Opp.Primary_Display_Sales_Rep__r.email__c,mapOpportunity);  
                    mapEmailFirstName.put( opp.Primary_Display_Sales_Rep__r.email__c,opp.Primary_Display_Sales_Rep__r.First_Name__c);                
                 } 
                 else 
                 {
                     if ( !String.isBlank(opp.Primary_Display_Sales_Rep__r.email__c) && !mapOpp.containskey(opp.Primary_Display_Sales_Rep__r.email__c) ) {
                        AddNewMapPrimary = true;
                     }
                     
                 }
                 if( opp.Primary_Display_Sales_Rep__c !=  opp.Secondary_Display_Sales_Rep__c) {
                        if( !String.isBlank(opp.Secondary_Display_Sales_Rep__r.email__c) && mapOpp.containskey(opp.Secondary_Display_Sales_Rep__r.email__c) ){
                         Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(mapOpp.get(opp.Secondary_Display_Sales_Rep__r.email__c));
                         mapOpportunity.put(opp.id,opp); 
                         mapOpp.put(opp.Secondary_Display_Sales_Rep__r.email__c,mapOpportunity);
                         mapEmailFirstName.put( opp.Secondary_Display_Sales_Rep__r.email__c,opp.Secondary_Display_Sales_Rep__r.First_Name__c);                 
                      }
                     else {
                         if ( !String.isBlank(opp.Secondary_Display_Sales_Rep__r.email__c)  && !mapOpp.containskey(opp.Secondary_Display_Sales_Rep__r.email__c))  {
                             AddNewMapSecondary = true;
                         }
                     }
                 }
             }
             else {
                  AddNewMapPrimary = true ;
                  if ( opp.Primary_Display_Sales_Rep__r.email__c !=  opp.Secondary_Display_Sales_Rep__r.email__c ) {
                      AddNewMapSecondary = true ;
                  }
             }
             If ( AddNewMapPrimary == true ) {
                  
                  Map< id,opportunity> mapOpportunity =  new Map< id,opportunity>();  
                  mapOpportunity.put(opp.id,opp); 
                  mapEmailFirstName.put( opp.Primary_Display_Sales_Rep__r.email__c,opp.Primary_Display_Sales_Rep__r.First_Name__c);
                  if ( !String.isBlank(opp.Primary_Display_Sales_Rep__r.email__c) ) { 
                      mapOpp.put(opp.Primary_Display_Sales_Rep__r.email__c,mapOpportunity);
                      mapEmailFirstName.put( opp.Primary_Display_Sales_Rep__r.email__c,opp.Primary_Display_Sales_Rep__r.First_Name__c);
                  }
                  if ( AddNewMapSecondary== true && !String.isBlank(opp.Secondary_Display_Sales_Rep__r.email__c)) { 
                      mapOpp.put(opp.Secondary_Display_Sales_Rep__r.email__c,mapOpportunity);
                      mapEmailFirstName.put( opp.Secondary_Display_Sales_Rep__r.email__c,opp.Secondary_Display_Sales_Rep__r.First_Name__c);
                  }
             } 
         }
         
         Datetime myDatetime = Datetime.now();
         String myDatetimeStr = myDatetime.format('yyyy MMM dd');
         string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();         
         string sHeader = '<html><body>';
         String sContent='<br>As on '+myDatetimeStr+' here is a summary of all the \'Closed Won\' opportunities that are \'Ready to Traffic\': <br><br>';
         String sTable = '<table  width=\"90%\" style=\"border:5px solid black\" border = \"1\" ><tr BGCOLOR=\"#652020\" ' 
                            + ' style=\"font-weight:bold\">';
         String sFooter = '</table> <br> This is an automated email from Salesforce. Kindly do not reply.<</body></html>';
         if (sHeader  !=Null)
         sTable = sTable +'<td><b>Name</b> </td><td><b>Jira Key (EDT)</b> </td><td><b>Jira Key (EDT) URL </b></td></tr>';
        
        List<Email_Alert__c> lstOppEmail = new List<Email_Alert__c>();

        for ( String emailId : mapOpp.keySet()) {
            String FirstName = mapEmailFirstName.size()>0?mapEmailFirstName.get(emailId ):null;  
            String sPersonalised='<Br> Hi '+FirstName +'<br>';  
            String sEmailBody='';
            for (Opportunity o : mapOpp.get(emailId).values()) {
                string sOppName = '<a href="'+sBaseURL + '/' +o.ID + '">'+ o.Name +'</a>';
                String sJiraURL=''; 
                String sJiraKey = o.Jira_Key__c!=null?o.Jira_Key__c:'';
                if ( !String.isBlank(o.Jira_EDT_URL__c ))
                    sJiraURL= o.Jira_EDT_URL__c;
                sEmailBody = sEmailBody + '<tr><td>' + sOppName + '</td><td> ' + sJiraKey+ '</td><td>' + sJiraURL+ '</td></tr>' ;
                
            }
            sEmailBody =sHeader  + sPersonalised+sContent+ sTable +sEmailBody + sFooter ;
            Email_Alert__c oppEmail = new Email_Alert__c(Email__c = emailId,Email_Body__c = sEmailBody,Is_Sent__c = false,Type__c = 'Ready to Traffic');
            lstOppEmail.add(oppEmail) ;
        }
         
        If (lstOppEmail.size() > 0)  
                insert lstOppEmail;   
            
              
            
     }       
     global void finish(Database.BatchableContext bc){
     	//Database.executeBatch(new EmailReadyToTrafficBatchable(), 10);
    }
}