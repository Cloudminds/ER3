trigger CheckBrandBeforeDeleteTrigger on Brand__c (before delete) {
    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Brand__c, Name FROM Opportunity WHERE Brand__c IN :trigger.oldMap.KeySet() ORDER BY Name ASC]);
    
    if(!opportunities.isEmpty()){
        String affectedOppNames = '';
        for(Brand__c br: trigger.old){
            for(Opportunity affectedOpps : opportunities.values())
                affectedOppNames += affectedOpps.Name + ', ';
            
            affectedOppNames = affectedOppNames.subString(0,affectedOppNames.length()-2);
            br.addError('You are not permitted to delete a brand that is used by the following opportunities: ' + affectedOppNames);
        }
    }
}