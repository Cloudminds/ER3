/*
What    : This master trigger calls methods in the OpportunityTriggerHandler class, depending on the trigger event invoked
Who     : Vishal Khanna
When    : Dec 2015
Which   : Version 1.0
*/
trigger MasterOpportunityTrigger on Opportunity (after insert,before insert,before update,after update) {
    OpportunityTriggerHandler opportunityTriggerHandler = new OpportunityTriggerHandler(Trigger.New, Trigger.Old,Trigger.newmap, Trigger.oldmap);
    
    Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults(); 
    if(ts.Run_Opportunity_Trigger__c==true){
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                //handle bulk in helper class
                opportunityTriggerHandler.HandleBeforeInsert(Trigger.New,Trigger.newmap, Trigger.oldmap);
            }
            
            if(trigger.isUpdate)
            {
                opportunityTriggerHandler.HandleBeforeUpdate(Trigger.New, Trigger.Old, Trigger.newmap, Trigger.oldmap);
            }
        }
        
        else if (Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                opportunityTriggerHandler.HandleAfterInsert(Trigger.New, Trigger.Old, Trigger.newmap, Trigger.oldmap);
            }
            else if(trigger.isUpdate)
            {
                opportunityTriggerHandler.HandleAfterUpdate(Trigger.New, Trigger.Old, Trigger.newmap, Trigger.oldmap);
            }
        } 
            
    } 


}