// Trigger to send email notification on:
// 1) Closed Won
// 2) No campaign lock
// 3) Not previously sync'd
// 4) Client account Credit App Approval = true 
trigger OpportunitySync on Opportunity (before update, after insert, after update) {
    System.debug('Campaign trigger called.');
    Boolean accountSync = (Boolean) Cobwebs_Settings__c.getInstance().account_sync__c;
    Boolean brandSync = (Boolean) Cobwebs_Settings__c.getInstance().brand_sync__c;
    Boolean opportunitySync = (Boolean) Cobwebs_Settings__c.getInstance().opportunity_sync__c;
    Opportunity newOpp;
    Opportunity oldOpp;

    Map<String, Id> recordTypeMap = new Map<String, Id>();
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' ORDER BY Name]) {
        recordTypeMap.put(rt.Name,rt.Id); 
    } 

    if (Trigger.isAfter) {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            newOpp = Trigger.new[i];
            if (newOpp.Self_Serve__c == FALSE) {
                // Create Client and Brand if not already synced on Closed Won
                if ((Trigger.isInsert && newOpp.StageName == 'Closed Won') || (Trigger.isUpdate && Trigger.old[i].StageName != newOpp.StageName && newOpp.StageName == 'Closed Won')) {
                    if (((accountSync && brandSync) || Test.isRunningTest()) && !ERSyncController.accountLock && !ERSyncController.brandLock) {
                        ERSyncController.closedWonCampaign(newOpp.Id);
                    }
                }
                
                // Create Jira ticket if stage = 'RFP/Proposal'
                if (Trigger.isInsert && newOpp.StageName == 'RFP/Proposal'){
                    ERSyncController.createJiraIssue('opportunity', newOpp.Id);
                }
            }
        }
    }
    
    // Update Ready to Traffic checkbox if skeleton campaign and jira ticket is created.
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp: Trigger.new) {
            if (opp.Initial_Sync__c && opp.Jira_Key__c != null){
                if (!opp.Ready_To_Traffic__c) {
                    opp.Ready_To_Traffic__c = TRUE;
                }            
            }
        }
    }
}