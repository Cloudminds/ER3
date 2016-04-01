/**
    What    : Email Alert record is created related to type Change In Value of Email Alert Object.
                   Creates the Email Message body.     .       
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/

global class EmailAlertUpdateBatchable implements Database.Batchable<SObject>, Database.Stateful{
    public String query;  
    public Set<Id> idsProcessed = new Set<Id>(); 
    public Map<string,Id> mUserIds = new Map<string,Id>();
    Datetime myDatetime = Datetime.now();
    String myDatetimeStr = myDatetime.format('yyyy MMM dd');        
    public EmailAlertUpdateBatchable (){}  

    global Database.QueryLocator start(Database.BatchableContext bc)
    {           
        return Database.getQueryLocator('SELECT Id, Email__c, Email_Body__c, Type__c, Is_Sent__c, Additional_Info__c FROM Email_Alert__c WHERE Is_Sent__c=FALSE and Type__c=\'Change In Value\'');  
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> batch) 
    { 
        List<Email_Alert__c> lel = new List<Email_Alert__c>();
        for(Email_Alert__c l : (List<Email_Alert__c>) batch)
        {
            lel.add(l);
        } 
        
        System.Debug('lel='+lel);
        
        // Fire the email notification one by one....
        for(Email_Alert__c ea : lel)
        {
               if(ea.Email__c!=null && ea.Email_Body__c!='' && ea.Is_Sent__c == FALSE && String.isNotBlank(String.valueOf(ea.Email_Body__c)))
               { 
                   System.debug('ea id '+ea.id);
                    blastEmailAlert(ea.Email__c, ea.Email_Body__c, ea.Additional_Info__c);
                    idsProcessed.add(ea.Id);
               }    
        }      
    }
    
    // blast the notification to the user

    public void blastEmailAlert(string strEmail, string strRows, string fbdnm)
    {
        if (string.IsNotBlank(strRows)){
        
            System.debug('blastEmailAlert######');
            Datetime myDatetime = Datetime.now();
            String myDatetimeStr = myDatetime.format('yyyy MMM dd');
            
            string strGreetings='<p>Hi ' + ',</p><p><br/>Here is a summary of the Opportunity Changes as of '+string.valueof(system.today())+'</p>';
                    
            Email_Settings__c cu=Email_Settings__c.getinstance();
            String su =cu.Email_Ids__c;                     
            String[] emailRecipient = su.split(',');         
              
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            mail.setToAddresses(emailRecipient);
            mail.setSenderDisplayName('Salesforce');
            
            mail.setSubject('Opportunity changes as of '+ myDatetimeStr);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            string strFooter = '<br/><br/>This is an auto generated notification from Salesforce. Kindly do not reply.<br/>';
            mail.setHtmlBody(strGreetings + strRows + strFooter);
            
            if(!Test.isRunningTest())
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }
        }               
    }
  
     global void finish(Database.BatchableContext bc)
     { 
        List<Email_Alert__c> listProcessed = [SELECT 
                                                    Id, Is_Sent__c 
                                                FROM 
                                                    Email_Alert__c 
                                                WHERE 
                                                    Id in:idsProcessed];
            for(Email_Alert__c iE : listProcessed)
            {
                iE.Is_Sent__c = TRUE;
            }
            if(listProcessed.size()>0)
            { 
                update listProcessed; 
            }
     }
}