// Trigger to send email notification on Closed Won Opportunities when:
//1) Billing Contact is empty
//2) Missing Approved Credit App
trigger OpportunityClosedWonValidation on Opportunity (after insert, after update) {
    Boolean validateClosedOpp = (Boolean) Cobwebs_Settings__c.getInstance().validate_closed_opportunity__c;
    String emailRecipients = (String) Cobwebs_Settings__c.getInstance().sfalert_email_recipients__c;
    
    Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
    try { 
        if(validateClosedOpp || Test.isRunningTest()){
            for(Opportunity opp : Trigger.new){
                if(opp.StageName == 'Closed Won'){
                     if(trigger.oldmap == null || trigger.oldmap.get(opp.Id).StageName != 'Closed Won')
                        opps.put(opp.Id,opp);
                }
            }
            for(opportunity opp : opps.values()){
                //These are new closed won opps
                if(opp.Billing_Contact__c == null || opp.Account.Credit_App_Approved__c == false){
                    String emailSubject = 'Missing details on Closed Won Opportunity: "' + opp.Name + '"';
                    String emailBody = 'Hi Thinesh,' + '\r\n\n' +
                       'The following opportunity "' + opp.Name + '" has been closed won on ' + opp.CloseDate + ' without an Approved Credit App or a Billing Contact.' + '\r\n\n' +
                       'Please follow the link below to view the Opportunity: ' + '\r\n' +
                       'https://na15.salesforce.com/' + opp.Id +'\r\n\n' +
                       'Regards,' + '\r\n' +
                       'Salesforce Team: ' + '\r\n\n' +
                       '*** This is an automatically generated email, please do not reply ***' + '\r\n';
                    CobwebsHttpCallout.sendEmail(emailRecipients, emailSubject, emailBody);
                }
            }
        }
    }catch(Exception e){
        System.debug('Error: ' + e); 
    }
}