trigger AccountRatecardCheckDateOverlap on Ratecard_Account__c(before insert) {
    Set < Id > ratecardAccountId = new Set < Id > ();
    for (Ratecard_Account__c rateAccNew: Trigger.new)
        ratecardAccountId.add(rateAccNew.Account__c);

    List < Ratecard_Account__c > rateAccQueryList = [select Id, Activation_Date__c, Expiration_Date__c, Account__c, Title__c FROM Ratecard_Account__c WHERE Account__c in : ratecardAccountId];
    if (!rateAccQueryList.isEmpty()) {
        for (Ratecard_Account__c rateAccNew: Trigger.new) {
            for (Ratecard_Account__c rateAccExisting: rateAccQueryList) {
                if(rateAccExisting.Account__c == rateAccNew.Account__c){
                    if (rateAccNew.Activation_Date__c >= rateAccExisting.Activation_Date__c && rateAccNew.Activation_Date__c <= rateAccExisting.Expiration_Date__c)
                        rateAccNew.addError('The Activation Date overlaps with an existing ratecard (' + rateAccExisting.Title__c + '). Activation Date must be greater than the Expiration Date.');
                    else if (rateAccNew.Expiration_Date__c >= rateAccExisting.Activation_Date__c && rateAccNew.Expiration_Date__c <= rateAccExisting.Expiration_Date__c)
                        rateAccNew.addError('The Expiration Date overlaps with an existing ratecard (' + rateAccExisting.Title__c + '). Expiration Date must be greater than the current Expiration Date.');
                    else if (rateAccNew.Activation_Date__c <= rateAccExisting.Activation_Date__c && rateAccNew.Expiration_Date__c >= rateAccExisting.Expiration_Date__c)
                        rateAccNew.addError('The Actication and Expiration Date overlaps with an existing ratecard (' + rateAccExisting.Title__c + '). Please review the dates.');
                }
            }
        }
    }
}