/**
What    : Fetches opportunities of rec type 'Creative Productions', the ones that are ready to bill
          The owners of these opportunities are sent an email alert to notify them that an opportunity is to be set as Ready to Bill
Who     : Vishal Khanna
Which   : Version 1.0
When    : Nov 2015

 */
global class ReadyToBillBatchable implements Database.Batchable<SObject>, Database.Stateful{
    private String query;       
    map<String, String> mapAdditionalInfo = new Map<String, String>();    
    global ReadyToBillBatchable(String query){
        this.query = query;
        if (this.query == null) {
                string strq='Select Id, Name, CloseDate, OwnerId, Owner.Email, Second_Business_Date_of_Next_Month__c, First_Date_of_Current_Month__c, Owner.FirstName, Owner.Name, RecordTypeId, RecordType.Name, Ready_To_Bill_Date__c, StageName ' ;
                strq = strq + ' from Opportunity where RecordType.Name=\'Creative Production\' AND Ready_To_Bill_Date__c <> NULL AND' ;
                strq = strq + ' StageName <> \'Closed Lost\'   AND (StageName <> \'Billed\' or stagename <> \'Ready to Bill\')   ';
                //strq = strq + '  AND CloseDate <=';
                this.query = strq;
        }   
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){           
            return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> batch){
         List<Opportunity> lopps = new List<Opportunity>();
         Set<String> setUniqueEmails = new Set<String>();
         
         // Fetch unique emails that need to be sent the email notification
         for(Opportunity op: (List<Opportunity>) batch){
         if(op.CloseDate >= op.First_Date_of_Current_Month__c && op.CloseDate < op.Second_Business_Date_of_Next_Month__c){   
            setUniqueEmails.add(op.Owner.Email);
            lopps.add(op);
          }
         }
         string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
         // Loop through each email and build the email body
         map<string, string> mapEmailAndBody = new map<string, string>();
         for (String sEmail : setUniqueEmails) {
            string sHeader = '<html><body><table  width=\"100%\" style=\"border:1px solid black\" ><tr BGCOLOR=\"#bfefff\" ' 
                                + ' style=\"font-weight:bold\">';
            string sEmailBody = '<td><b>URL</b> </td><td><b>Name</b> </td><td><b>Stage</b> </td><td><b>Close Date </b></td></tr>';
            for(Opportunity o : lopps){
                string sURL = sBaseURL + '/' + (string)o.Id;
                string sLink = '<a href=\''+ sURL + '\''  + '>Click</a>';
                // string strCloseDate = (string)o.CloseDate;
                // strCloseDate = strCloseDate.substring(0,10);
                sEmailBody = sEmailBody + '<tr><td>' + sURL + '</td><td> ' + o.Name + '</td><td>' + o.StageName + '</td><td>' + date.valueOf(o.CloseDate) + '</td></tr>' ;
                if(!mapAdditionalInfo.containsKey(sEmail)){
                    date fbdnm = o.Second_Business_Date_of_Next_Month__c - 1; // Value to be displayed in Email
                    mapAdditionalInfo.put(sEmail, fbdnm.format());
                } 
            }
            sEmailBody = sEmailBody + '</table></body></html>';
            mapEmailAndBody.put(sEmail, sEmailBody);
            
         } 
         
         // Insert Email and Email Body in Email_Alert__c
         List<Email_Alert__c> lel = new List<Email_Alert__c>(); //
         for(String se : mapEmailAndBody.keyset()){
            Email_Alert__c e = new Email_Alert__c(
               Email__c = se,
               Email_Body__c = mapEmailAndBody.get(se),
               Is_Sent__c = false,
               Type__c = 'Ready To Bill Alert',
               Additional_Info__c =mapAdditionalInfo.get(se)
            );
            lel.add(e);
         }
         if(lel.size()>0){
            insert lel; //
         }
         
    }
    
    global void finish(Database.BatchableContext bc){
        //Database.executeBatch(new EmailAlertBatchable(null), 10);
    }
    
}