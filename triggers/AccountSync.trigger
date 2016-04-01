trigger AccountSync on Account (before insert, after insert, after update) {
    Boolean accountSync = (Boolean) Cobwebs_Settings__c.getInstance().account_sync__c;

    // If legal name is blank, set it the same as the account name.
    if (Trigger.isBefore) {
        for(Account record:Trigger.new) {
            if (record.Legal_Name__c == '' || record.Legal_Name__c == null) {
                record.Legal_Name__c = record.Name;
            }
        }
    }

    // If updating
    else if (Trigger.isAfter && Trigger.isUpdate) {
        if (accountSync || Test.isRunningTest()) {
            System.debug('Entered Account trigger update.');
            for (Account record:Trigger.new) {
                // If via API call, allow even if there's a lock.
                if (record.IsAPI__c) {
                    System.debug('Account update triggered via API');
                    ERSyncController.accountLock = true;
                    ERSyncController.easeOrg(record.Id);
                } else if (!ERSyncController.accountLock && record.Org_ID__c != null) {
                    ERSyncController.accountLock = true;
                    ERSyncController.updateOrg(record.Id);
                } else if (ERSyncController.accountLock) {
                    System.debug('Account update was locked.');
                }
            }
        }
    }
    
    /*
    // Update analyst on Opportunity if changed on Account
    if (Trigger.isUpdate) {
        Set <Id> accountList = new Set <Id> ();
        for (Account accs: Trigger.new)
            accountList.add(accs.Id);
    
        List <Opportunity> oppsList = [SELECT Id, Opportunity_Analyst__c FROM Opportunity WHERE AccountId in : accountList];
        List <Opportunity> oppsToUpdate = new List<Opportunity>();
        if (!oppsList.isEmpty()) {    
            for (Account newAccs: Trigger.new) {
                for (Opportunity opp : oppsList){
                    if (newAccs.Analyst__c != null){
                        if (!newAccs.Analyst__c.equals(opp.Opportunity_Analyst__c)){
                            opp.Opportunity_Analyst__c = newAccs.Analyst__c;
                            oppsToUpdate.add(opp);
                        }
                    }
                }
            }
        }
        if (!oppsToUpdate.isEmpty())
            update oppsToUpdate;
    }*/
}