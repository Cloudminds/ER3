/**
    What    : Email Alert record is created related to type Change In Value of Email Alert Object.
              Creates the Email Message body.     .       
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Feb 2016
**/

global class EmailReadyToTrafficBatchable implements Database.Batchable<SObject>, Database.Stateful{
    public String query;  
    List<Opportunity>opp = new List<Opportunity>();
    public Set<Id> idsProcessed = new Set<Id>(); 
    public Map<string,Id> mUserIds = new Map<string,Id>();
    Datetime myDatetime = Datetime.now();
    String myDatetimeStr = myDatetime.format('yyyy MMM dd');        
    public EmailReadyToTrafficBatchable (String query){
		this.query = query;
        if (this.query == null) {
                string strq='SELECT Id, Email__c, Email_Body__c, Type__c, Is_Sent__c FROM Email_Alert__c WHERE Is_Sent___c=FALSE and Type__c=\'Ready to Traffic\' and Email__c!=null';
                this.query = strq;
                
        }
	}  
	
     public EmailReadyToTrafficBatchable (){
        this.query ='SELECT Id, Email__c, Email_Body__c, Type__c, Is_Sent__c FROM Email_Alert__c WHERE Is_Sent__c=FALSE and Type__c=\'Ready to Traffic\' and Email__c!=null';
	} 
    Public boolean isNullStr(String s) {
		if (String.isBlank(s) || s == null )
			return true;
		else 
			return false;
		
	}

    global Database.QueryLocator start(Database.BatchableContext bc)
    {           
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> batch) 
    { 
        
        // Fire the email notification one by one....
        List<Email_Alert__c> ListEmailAlert = new List<Email_Alert__c>();
        for(Email_Alert__c oe : (List<Email_Alert__c>) batch)
        {
               if( !isNullStr(oe.Email__c) && !isNullStr(oe.Email_Body__c) && oe.Is_Sent__c == FALSE  && !isNullStr(oe.Email_Body__c))
               {
                    blastEmailAlert(oe.Email__c, oe.Email_Body__c,oe.Type__c,oe.Is_Sent__c);
                   	oe.Is_Sent__c = True;
                   	ListEmailAlert.add(oe);
               }
        }
        update ListEmailAlert;
    }
    
    // blast the notification to the user

    public void blastEmailAlert(string sEmail, string sEmailBody, string sType,Boolean bSent )
    {
        Datetime myDatetime = Datetime.now();
        String myDatetimeStr = myDatetime.format('yyyy MMM dd');
		if (!isNullStr(sEmail)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            String[] toAddresses = new String[] {sEmail};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce');
            mail.setSubject('Ready to Traffic Opportunities as of '+ myDatetimeStr);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(sEmailBody);
            
            if(!Test.isRunningTest())
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }
        }               
    }
  
     global void finish(Database.BatchableContext bc){}
}