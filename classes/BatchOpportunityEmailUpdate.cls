/**
    What    : Fetches Change Request Record Which Is created Today and is not processed in Batch run.          
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
global class BatchOpportunityEmailUpdate implements Database.Batchable<SObject>, Database.Stateful{
    
    Private String query;         
    Map<String, String> mapAdditionalInfo = new Map<String, String>();  
    List<Change_Request__c > lopps = new List<Change_Request__c >();
    Set<Id> sId =new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext bc){           
           return Database.getQueryLocator('SELECT Id,Name,Opportunity__c,Object_ID__c,Object_Type__c,Changed_From__c,Changed_To__c,Is_Process__c FROM Change_Request__c WHERE CreatedDate = TODAY AND Is_Process__c=False');       
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> batch){    

         // Fetch unique emails that need to be sent the email notification
         for(Change_Request__c op: (List<Change_Request__c >) batch)
         {
            op.Is_Process__c =True;        
            sId.add(op.Id);
         }
        update lopps;
        System.debug('########lopps'+lopps);
    }
    
    global void finish(Database.BatchableContext bc){    
        
         List<Change_Request__c>cse = [SELECT Name, Id, Opportunity__c,Opportunity__r.Name,Object_ID__c,Object_Type__c,Changed_From__c,Changed_To__c,Is_Process__c FROM Change_Request__c Where Id In:sId];
         For (Change_Request__c cs :cse){
         cs.Is_Process__c =True;
         }
         if (cse.size()>0)
         {
             update cse;
         }
         Email_Settings__c cu=Email_Settings__c.getinstance();
         String su =cu.Email_Ids__c;
         String[] emailRecipient = su.split(',');
         string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
         
         // Loop through each email and build the email body
         Map<string, string> mapEmailAndBody = new Map<string, string>();
         // for (String sEmail : emailRecipient) {
            string sHeader = '<html><body><table  width=\"90%\" style=\"border:5px solid black\" border = \"1\" ><tr BGCOLOR=\"#652020\" ' 
                                + ' style=\"font-weight:bold\">';
            sHeader  = sHeader  +'<td><b>URL</b> </td><td><b>Name</b> </td><td><b>Changed To</b> </td><td><b>Changed From </b></td></tr>';
            String sEmailBody='';
            for(Change_Request__c o : cse){
                string sURL = sBaseURL + '/' + (string)o.Opportunity__c;
                string sLink = '<a href=\''+ sURL + '\''  + '>Click</a>';
                sEmailBody = sEmailBody + '<tr><td>' + sURL + '</td><td> ' + o.Opportunity__r.Name+ '</td><td>' + o.Changed_From__c + '</td><td>' + o.Changed_To__c + '</td></tr>' ;
            } 
            if(sEmailBody!='') 
            {
                sEmailBody =sHeader  + sEmailBody + '</table></body></html>';
                //mapEmailAndBody.put(emailRecipient[1], sEmailBody);
                mapEmailAndBody.put(su, sEmailBody);
            }
            
            
        // } 
         
         // Insert Email and Email Body in Email_Alert__c
   
         List<Email_Alert__c> lel = new List<Email_Alert__c>();
         for(String se : mapEmailAndBody.keyset()){
  
         Email_Alert__c e = new Email_Alert__c(
               Email__c = se,
               Email_Body__c = mapEmailAndBody.get(se),
               Is_Sent__c = false,
               Type__c = 'Change In Value',
               Additional_Info__c =mapAdditionalInfo.get(se)
            );
            lel.add(e);
         }         
         if(lel.size()>0 ){
            insert lel;            
         }       
         
         Database.executeBatch(new EmailAlertUpdateBatchable(), 10);
    }
    
}