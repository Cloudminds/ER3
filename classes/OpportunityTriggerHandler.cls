/*
    What         : Handler class for MasterOpportunityTrigger
    Who          : Vishal Khanna, Paul Saini
    When         : Jan 2016
    ----------     Function Name Short Description :
*/
    public class OpportunityTriggerHandler {
        private static boolean run = true;
        private List<Opportunity> newOpportunities=new List<Opportunity>();
        private List<Opportunity> oldOpportunities=new List<Opportunity>();
        private Map<Id, Opportunity> mapNewOpps = new Map<Id, Opportunity>();
        private Map<Id, Opportunity> mapOldOpps = new Map<Id, Opportunity>();
        
        public OpportunityTriggerHandler (List<Opportunity> newOpportunities, List<Opportunity> oldOpportunities, Map<Id, Opportunity> mapNewOpps, Map<Id, Opportunity> mapOldAccs )
        {
            this.newOpportunities = newOpportunities;
            this.oldOpportunities = oldOpportunities;
            this.mapNewOpps = mapNewOpps;
            this.mapOldOpps = mapOldOpps;
        } 
        
        public void HandleBeforeInsert(List<Opportunity> oppsNew,Map<Id, Opportunity> mn, Map<Id, Opportunity> mo)
        {
             this.newOpportunities=oppsNew;
             this.mapNewOpps = mn;
             this.mapOldOpps = mo;
             
        }
        
        public void HandleBeforeUpdate(List<Opportunity> oppsNew, List<Opportunity> oppsOld, Map<Id, Opportunity> mn, Map<Id, Opportunity> mo)
        {
            this.newOpportunities = oppsNew;
            this.oldOpportunities = oppsOld;
            this.mapNewOpps = mn;
            this.mapOldOpps = mo;

            //functionName(oppsNew, mo, mn);
        }
        
        public void HandleAfterInsert(List<Opportunity> oppsNew, List<Opportunity> oppsOld, Map<Id, Opportunity> mn, Map<Id, Opportunity> mo)
        {
            this.newOpportunities = oppsNew;
            this.oldOpportunities = oppsOld;
            this.mapNewOpps = mn;
            this.mapOldOpps = mo;
        }
        
        
        public void HandleAfterUpdate(List<Opportunity> oppsNew, List<Opportunity> oppsOld, Map<Id, Opportunity> mn, Map<Id, Opportunity> mo)
        {
            this.newOpportunities = oppsNew;
            this.oldOpportunities = oppsOld;
            this.mapNewOpps = mn;
            this.mapOldOpps = mo;
        }
        
        public static boolean runOnce(){
            if(run){
                run=false;
                return true;
            }
            else{
                return run;
            }
        }

        public void OpportunityChangeSync(List<Opportunity> lstOppsNew, List<Opportunity> lstOppsOld, Map<Id, Opportunity> mo, Map<Id, Opportunity> mn)
        {
            for (Opportunity opp: mn.values()) {
              //Create an old and new map so that we can compare values
              Opportunity oldOpp = mo.get(opp.ID);
              Opportunity newOpp = mn.get(opp.ID);
  
              Opportunity OppObject = new Opportunity(); 
        
              // This takes all available fields from the required object.
              Schema.SObjectType objType = OppObject.getSObjectType();
              Map < String, Schema.SObjectField > M = Schema.SObjectType.Opportunity.fields.getMap();

              Decimal budget;
              Date startDate;
              Date endDate;
              Decimal displayBudget = (Decimal) NewOpp.get('Display_Budget__c');
              Decimal mobileBudget = (Decimal) NewOpp.get('Mobile_Budget__c');
              List < Change_Request__c > crList = new List < Change_Request__c > ();
              String description;

              //Only check for Closed Won Opportunities
              if (NewOpp.get('StageName').equals('Closed Won')) {
              for (String str: M.keyset()) {
                try {
                    System.debug('Field name: ' + str + '. New value: ' + NewOpp.get(str) + '. Old value: ' + OldOpp.get(str));

                    Change_Request__c crToInsert = null;
                    Boolean isUpdated = false;

                    //Track change on Display Budget
                    if (str.equals('display_budget_change_amount__c')) {
                        if (NewOpp.get(str) != null) {
                            if (((Decimal) NewOpp.get(str) != (Decimal) OldOpp.get(str)) || (NewOpp.get('Display_Budget_Change__c') != OldOpp.get('Display_Budget_Change__c')) || (NewOpp.get('Display_Budget_Change_Amount__c') != OldOpp.get('Display_Budget_Change_Amount__c'))) {
                                if (NewOpp.get('Display_Budget_Change__c').equals('Increase')) {
                                    system.debug('******Display Budget value has increased!!! ');
                                    budget = displayBudget + (Decimal) NewOpp.get(str);
                                    description = 'Display Budget Increase';
                                    isUpdated = true;
                                } else if (((String) NewOpp.get('Display_Budget_Change__c')).equals('Decrease')) {
                                    system.debug('******Display Budget has decreased!!! ');
                                    budget = displayBudget - (Decimal) NewOpp.get(str);
                                    description = 'Display Budget Decrease';
                                    isUpdated = true;
                                }
                            }
                        }

                        if (isUpdated) {
                            crToInsert = new Change_Request__c(
                                Key__c = 'Total Display Budget',
                                Value__c = String.valueOf(budget),
                                Object_ID__c = (String) NewOpp.get('id'),
                                Opportunity__c = (String) NewOpp.get('id'),
                                Object_Type__c = 'Opportunity',
                                Timestamp__c = DateTime.Now(),
                                Changed_From__c = (OldOpp.get(str) != null ? ((Decimal) OldOpp.get(str)).format() : null),
                                Changed_To__c = (NewOpp.get(str) != null ? ((Decimal) NewOpp.get(str)).format() : null),
                                Description__c = description
                            );
                            crList.add(crToInsert);
                            isUpdated = false;
                        }
                    }

                    //Track change on Mobile Budget
                    if (str.equals('mobile_budget_change_amount__c')) {
                        if (NewOpp.get(str) != null) {
                            if ((Decimal) NewOpp.get(str) != (Decimal) OldOpp.get(str) || NewOpp.get('Mobile_Budget_Change__c') != OldOpp.get('Mobile_Budget_Change__c') || NewOpp.get('Mobile_Budget_Change_Amount__c') != OldOpp.get('Mobile_Budget_Change_Amount__c')) {
                                if (NewOpp.get('Mobile_Budget_Change__c').equals('Increase')) {
                                    system.debug('******Mobile Budget value has increased!!! ');
                                    budget = mobileBudget + (Decimal) NewOpp.get(str);
                                    description = 'Mobile Budget Increase';
                                    isUpdated = true;
                                } else if (NewOpp.get('Mobile_Budget_Change__c').equals('Decrease')) {
                                    system.debug('******Mobile Budget has decreased!!! ');
                                    budget = mobileBudget - (Decimal) NewOpp.get(str);
                                    description = 'Mobile Budget Decrease';
                                    isUpdated = true;
                                }
                            }
                        }

                        if (isUpdated) {
                            crToInsert = new Change_Request__c(
                                Key__c = 'Total Mobile Budget',
                                Value__c = String.valueOf(budget),
                                Object_ID__c = (String) NewOpp.get('id'),
                                Opportunity__c = (String) NewOpp.get('id'),
                                Object_Type__c = 'Opportunity',
                                Timestamp__c = DateTime.Now(),
                                Changed_From__c = (OldOpp.get(str) != null ? ((Decimal) OldOpp.get(str)).format() : null),
                                Changed_To__c = (NewOpp.get(str) != null ? ((Decimal) NewOpp.get(str)).format() : null),
                                Description__c = description
                            );
                            crList.add(crToInsert);
                            isUpdated = false;
                        }
                    }

                    //Track change on Budget Change Start Date
                    if (str.equals('budget_change_start_date__c')) {
                        if (NewOpp.get(str) != OldOpp.get(str)) {
                            description = 'Budget Start Date changed';
                            system.debug('******Budget Change Start Date has changed!!! ');
                            crToInsert = new Change_Request__c(
                                Key__c = 'Budget Change Start Date',
                                Value__c = String.valueOf(NewOpp.get(str)),
                                Object_ID__c = (String) NewOpp.get('id'),
                                Opportunity__c = (String) NewOpp.get('id'),
                                Object_Type__c = 'Opportunity',
                                Timestamp__c = DateTime.Now(),
                                Changed_From__c = (OldOpp.get(str) != null ? ((Date) OldOpp.get(str)).format() : null),
                                Changed_To__c = (NewOpp.get(str) != null ? ((Date) NewOpp.get(str)).format() : null),
                                Description__c = description
                            );
                            crList.add(crToInsert);
                        }
                    }

                    //Track change on Budget Change End Date
                    if (str.equals('budget_change_end_date__c')) {
                        if (NewOpp.get(str) != OldOpp.get(str)) {
                            description = 'Budget End Date changed';
                            system.debug('******Budget Change End Date has changed!!! ');
                            crToInsert = new Change_Request__c(
                                Key__c = 'Budget Change End Date',
                                Value__c = String.valueOf(NewOpp.get(str)),
                                Object_ID__c = (String) NewOpp.get('id'),
                                Opportunity__c = (String) NewOpp.get('id'),
                                Object_Type__c = 'Opportunity',
                                Timestamp__c = DateTime.Now(),
                                Changed_From__c = (OldOpp.get(str) != null ? ((Date) OldOpp.get(str)).format() : null),
                                Changed_To__c = (NewOpp.get(str) != null ? ((Date) NewOpp.get(str)).format() : null),
                                Description__c = description
                            );
                            crList.add(crToInsert);
                        }
                    }

                } catch (Exception e) {
                    System.debug('Error: ' + e);
                }
            }

            //Create a Change Request record
            if (crList.size() > 0) {
                insert(crList);

                //Call out to Cobwebs
                //if(NewOpp.get('Self_Serve__c') == false)
                //    ERSyncController.updateCampaign((String) NewOpp.get('id'));
            }
        }
    }
            
        
        
       }


}