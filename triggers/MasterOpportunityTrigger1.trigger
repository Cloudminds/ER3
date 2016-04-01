/*
    What    : This master trigger calls methods in the OpportunityTriggerHandler1 class, depending on the trigger event invoked
    Who     : Vishal Khanna
    When    : Jan 2016
    Which   : Version 1.0
*/
trigger MasterOpportunityTrigger1 on Opportunity (before insert,after insert,before update,after update) 
{
    if (Trigger_Settings__c.getOrgDefaults().Run_Opportunity_Trigger__c== false ) 
    {
            return;
    }
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            OpportunityTriggerHandler1.buOpportunitySync(trigger.newMap);
            OpportunityTriggerHandler1.buOpportunityRunSecondBusinessDateRule(trigger.newMap);            
        }
    }
    else
    {
        if(trigger.isInsert)
        {
            OpportunityTriggerHandler1.aiOpportunitySync(trigger.new);
            OpportunityTriggerHandler1.aiOpportunityClosedWonValidation(trigger.newMap); 
        }
        if(trigger.isUpdate)
        {
            OpportunityTriggerHandler1.auOpportunitySync(trigger.new,trigger.old);
            OpportunityTriggerHandler1.auOpportunityClosedWonValidation(trigger.newMap,trigger.oldMap); 
            OpportunityTriggerHandler1.auOpportunityChangeSync(trigger.newMap,trigger.oldMap);
        }
    }
}