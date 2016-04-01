/**
    What    : Email Alert record is created related to type Change In Value of Email Alert Object.
                  Creates the Email Message body.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Nov 2015
**/

global class EmailAlertBatchable implements Database.Batchable<SObject>, Database.Stateful{
    private String query;  
    private Set<Id> idsProcessed = new Set<Id>(); // IDs in Intraday_Email__c for which emails have been fired
    private Map<string,string> mFirstNames = new Map<string,string>();
    private Map<string,Id> mUserIds = new Map<string,Id>();
     
    global EmailAlertBatchable (String query){
        this.query = query;
        if (this.query == null) {
                string strq='Select Id, Email__c, Email_Body__c, Type__c, Is_Sent__c, Additional_Info__c from Email_Alert__c where Is_Sent__c=FALSE and Type__c=\'Ready To Bill Alert\'';
                this.query = strq;
                setFirstNames(); // Fetch firstname from User object and put in email body
        }
    }  
    
    global Database.QueryLocator start(Database.BatchableContext bc){           
            return Database.getQueryLocator(query);        
    }
    
    global void setFirstNames(){
          List<Email_Alert__c> iEmails = [Select Id, Email__c from Email_Alert__c where Is_Sent__c=false];
          Set<String> sEmails = new Set<String>();
          for(Email_Alert__c ie:iEmails){
            sEmails.add(ie.Email__c);    
          }
          System.Debug('sEmails='+sEmails);
          for(User u:[Select Id, Email, FirstName, LastName from User where Email in:sEmails]){
            if(!mFirstNames.containsKey(u.Email)){
              mFirstNames.put(u.Email,u.FirstName);
           }   
           if(!mUserIds.containsKey(u.Id)){
              mUserIds.put(u.Email,u.Id);
           }   
          }
          System.Debug('mFirstNames='+mFirstNames);
          System.Debug('mUserIds='+mUserIds);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> batch) 
    { 
        List<Email_Alert__c> lel = new List<Email_Alert__c>();
        for(Email_Alert__c l : (List<Email_Alert__c>) batch){
                lel.add(l);
        } 
        System.Debug('lel='+lel);
        
        // Fire the email notification one by one....
        for(Email_Alert__c ea : lel){
               if(ea.Email__c!=null && ea.Email_Body__c!='' && ea.Is_Sent__c == FALSE){ 
                 blastEmailAlert(ea.Email__c, ea.Email_Body__c, ea.Additional_Info__c);
                 idsProcessed.add(ea.Id);
               }    
        }
        
        
    }
    
    // blast the notification to the user
    public void blastEmailAlert(string strEmail, string strRows, string fbdnm){
        System.Debug('strEmail called by blast='+strEmail);
        System.Debug('strRows called by blast='+strRows);
        string strGreetings='<p>Hi ' + mFirstNames.get(strEmail) + ',</p><p><br/>According to our records, the following creative opportunities have not been marked as <b>Ready to Bill</b> in Salesforce for this billing cycle.</p><br/>';
        strGreetings = strGreetings + '<p>The end of the current billing cycle is: ' + fbdnm  +  '. Please update the status as soon as possible.</p><br/>';                       
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        List<string> ccAddresses= new List<String>{
        'sfalerts@eyereturn.com',
        'smacdonald@eyereturn.com'};
        
        if(mUserIds.get(strEmail)!=null){
                            mail.saveAsActivity = false;
                            mail.setTargetObjectId(mUserIds.get(strEmail)); // Use this function to avoid Email governor limits

        }
        
        // mail.setReplyTo('');
        mail.setSenderDisplayName('Salesforce');
        
        mail.setSubject('Friendly Reminder: Creative Production Opportunities Waiting To Be Billed');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        string strFooter = '<br/><br/>*** This is an automatically generated email, please do not reply ***<br/>';
        mail.setHtmlBody(strGreetings + strRows + strFooter);
        mail.setCcAddresses(ccAddresses);
        // List<String> bccAddress = new List<String>();            
        // bccAddress.add('');            
        // mail.setBccAddresses(bccAddress);    
        
        if(!Test.isRunningTest()){
            if(mUserIds.get(strEmail)!=Null)
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); // <---- and finally blast the mail..:):)..Yay!
            }
        }
               
    }
    
     global void finish(Database.BatchableContext bc){ 
        List<Email_Alert__c> listProcessed = [Select Id, Is_Sent__c from Email_Alert__c where Id in:idsProcessed];
            for(Email_Alert__c iE : listProcessed){
                iE.Is_Sent__c = TRUE;
            }
            if(listProcessed.size()>0){ update listProcessed; }
     } 
    
}