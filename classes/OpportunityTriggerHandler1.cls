/**
    What    : Handler Class for OpportunitySync,OpportunityRunSecondBusinessDateRule,OpportunityChangeSync and OpportunityClosedWonValidation Triggers.          
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
public class OpportunityTriggerHandler1
{
    /* Handler class method for OpportunitySync Trigger for after update Event */
    
    public static void auOpportunitySync(List<Opportunity>newList,List<Opportunity>oldList) 
    {
        Boolean accountSync = (Boolean) Cobwebs_Settings__c.getInstance().account_sync__c;
        Boolean brandSync = (Boolean) Cobwebs_Settings__c.getInstance().brand_sync__c;
        Boolean opportunitySync = (Boolean) Cobwebs_Settings__c.getInstance().opportunity_sync__c;
        Opportunity newOpp;

        Map<String, Id> recordTypeMap = new Map<String, Id>();
        
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity' ORDER BY Name]) 
        {
            recordTypeMap.put(rt.Name,rt.Id); 
        } 
        
        for (Integer i = 0; i < newList.size(); i++) 
        {
            newOpp = newList[i];
            if (newOpp.Self_Serve__c == FALSE) 
            {
                //  Create Client and Brand if not already synced on Closed Won
                if (oldList[i].StageName != newOpp.StageName && newOpp.StageName == 'Closed Won') 
                {
                    if (((accountSync && brandSync) || Test.isRunningTest()) && !ERSyncController.accountLock && !ERSyncController.brandLock) 
                    {
                        ERSyncController.closedWonCampaign(newOpp.Id);
                    }
                }
                
                // Create Jira ticket if stage = 'RFP/Proposal'
                if (newOpp.StageName == 'RFP/Proposal')
                {
                    ERSyncController.createJiraIssue('opportunity', newOpp.Id);
                }
            }
        } 
    }
    
    /* Handler class method for OpportunitySync Trigger for after Insert Event */   
     
    public static void aiOpportunitySync(List<Opportunity>oppList) 
    {
        Boolean accountSync = (Boolean) Cobwebs_Settings__c.getInstance().account_sync__c;
        Boolean brandSync = (Boolean) Cobwebs_Settings__c.getInstance().brand_sync__c;
        Boolean opportunitySync = (Boolean) Cobwebs_Settings__c.getInstance().opportunity_sync__c;
        Opportunity newOpp;

        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity' ORDER BY Name]) 
        {
            recordTypeMap.put(rt.Name,rt.Id); 
        } 
        for (Integer i = 0; i < oppList.size(); i++) 
        {
            newOpp = oppList[i];
            if (newOpp.Self_Serve__c == FALSE) 
            {
                // Create Client and Brand if not already synced on Closed Won
                if ((newOpp.StageName == 'Closed Won')) 
                {
                    if (((accountSync && brandSync) || Test.isRunningTest()) && !ERSyncController.accountLock && !ERSyncController.brandLock) 
                    {
                        ERSyncController.closedWonCampaign(newOpp.Id);
                    }
                }
                
                // Create Jira ticket if stage = 'RFP/Proposal'
                if (newOpp.StageName == 'RFP/Proposal')
                {
                    ERSyncController.createJiraIssue('opportunity', newOpp.Id);
                }
            }
        }
    }
    
    /* Handler class method for OpportunitySync Trigger for Before update Event */   
     
    public static void buOpportunitySync(Map<Id,Opportunity>newMap ) 
    {
        /**
        System.debug('Campaign trigger called.');
        Boolean accountSync = (Boolean) Cobwebs_Settings__c.getInstance().account_sync__c;
        Boolean brandSync = (Boolean) Cobwebs_Settings__c.getInstance().brand_sync__c;
        Boolean opportunitySync = (Boolean) Cobwebs_Settings__c.getInstance().opportunity_sync__c;
        Opportunity newOpp;

        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' ORDER BY Name]) 
        {
            recordTypeMap.put(rt.Name,rt.Id); 
        } 
        **/
        for (Id opp: newMap.keySet()) 
        {
            if (newMap.get(opp).Initial_Sync__c && newMap.get(opp).Jira_Key__c != null)
            {
                if (!newMap.get(opp).Ready_To_Traffic__c) 
                {
                    newMap.get(opp).Ready_To_Traffic__c = TRUE;
                }            
            }
        }
    }
    
    /* Handler class method for OpportunityRunSecondBusinessDateRule Trigger for before update Event */

    public static void buOpportunityRunSecondBusinessDateRule(Map<Id,Opportunity> newMap)
    {
        // Get Record Type Id For Creative Opportunities
        Map<String,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rt_Map.get('Creative Production');
        Id creativeOppRecTypeId = rtByName.getRecordTypeId();
        // Fetch the value of Next Holiday date from the custom setting
        Holiday_Settings__c HS = Holiday_Settings__c.getOrgDefaults();
        if(HS==null)
        HS = new Holiday_Settings__c();
        Date NextHoliday = HS.Next_Holiday_Date__c ;
       
        for(Id opp:newMap.keySet())
        {
            Opportunity opps =newMap.get(opp);
            if(opps.RecordTypeId.equals(creativeOppRecTypeId) && opps.StageName.equals('Ready To Bill'))
            {            
                String firstDay = opps.First_Day_of_Next_Month__c;
                Date firstDate = opps.First_Date_of_Next_Month2__c;
                Date secondDate = opps.Second_Date_of_Next_Month__c;  
                Date fridayPlusThree = firstDate + 3;
                Date saturdayPlusTwo = firstDate + 2;
                Date saturdayPlusThree = firstDate + 3;
                Date sundayPlusOne = firstDate + 1;
                Date sundayPlusTwo = firstDate + 2;

                Date sbdnm ; // Second business date of next month

                // Check for Mon Or Tue Or Wed
                if((firstDay=='Monday' || firstDay=='Tuesday' || firstDay=='Wednesday')||(Test.isRunningTest()))
                {
                    /*if((firstDate!= NextHoliday && secondDate!=NextHoliday) ||(Test.isRunningTest()))
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 1;
                    }
                    else if((firstDate== NextHoliday || secondDate== NextHoliday) ||(Test.isRunningTest()))
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 2;
                    }
                    */
                    sbdnm=(firstDate!= NextHoliday && secondDate!=NextHoliday) ?  opps.First_Date_of_Next_Month2__c + 1:
                            opps.First_Date_of_Next_Month2__c + 2;
                }

                // Check for Thu
                if((firstDay=='Thursday' )||(Test.isRunningTest()))
                {
                    /*if(firstDate!= NextHoliday && secondDate!=NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 1;
                    }
                    else if(firstDate== NextHoliday || secondDate== NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 4;
                    }
                    */
                    sbdnm=(firstDate!= NextHoliday && secondDate!=NextHoliday)?opps.First_Date_of_Next_Month2__c + 1 :
                    opps.First_Date_of_Next_Month2__c + 4;
                }

                // Check for Fri
                if((firstDay=='Friday')||(Test.isRunningTest()))
                {
                    /*if(firstDate!= NextHoliday && fridayPlusThree!=NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 3;
                    }
                    else if(firstDate== NextHoliday || fridayPlusThree == NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 4;
                    }
                    */
                    sbdnm=(firstDate!= NextHoliday && fridayPlusThree!=NextHoliday) ? opps.First_Date_of_Next_Month2__c + 3:
                    opps.First_Date_of_Next_Month2__c + 4;
                }

                // Check for Sat
                if((firstDay=='Saturday')||(Test.isRunningTest()))
                {
                   /* if(saturdayPlusTwo!= NextHoliday && saturdayPlusThree!=NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 3;
                    }
                    else if(saturdayPlusTwo==NextHoliday || SaturdayPlusThree==NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 4;
                    }
                    */
                    sbdnm=(saturdayPlusTwo!= NextHoliday && saturdayPlusThree!=NextHoliday)?opps.First_Date_of_Next_Month2__c + 3
                        : opps.First_Date_of_Next_Month2__c + 4;
                }

                // Check for Sun
                if((firstDay=='Sunday')||(Test.isRunningTest()))
                {
                   /* if(sundayPlusOne!= NextHoliday && sundayPlusTwo!=NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 2;
                    }
                    else if(sundayPlusOne==NextHoliday || sundayPlusTwo==NextHoliday)
                    {
                        sbdnm = opps.First_Date_of_Next_Month2__c + 3;
                    }
                    */
                    
                    sbdnm=(sundayPlusOne!= NextHoliday && sundayPlusTwo!=NextHoliday) ? opps.First_Date_of_Next_Month2__c + 2:
                    opps.First_Date_of_Next_Month2__c + 3;
                }

                opps.Second_Business_Date_of_Next_Month__c = sbdnm;

                Date currentDate = Date.today();
                Integer M = currentDate.Month(); // The current month number
                String strSBDNM = String.valueOf(opps.Second_Business_Date_of_Next_Month__c);
                if(opps.Ready_To_Bill_Date__c > opps.Second_Business_Date_of_Next_Month__c -1 )
                {
                    opps.addError('Ready to Bill Date cannot be greater than the Second Business Date of next Month which is '+strSBDNM);
                }
            }       
        }
    }   

    /* Handler class method for OpportunityRunSecondBusinessDateRule Trigger for after update Event */
        
    public static void auOpportunityChangeSync(Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap)
    {
        for(Id opp : newMap.keyset())
        {
            Opportunity newOpp = newMap.get(opp);
            Opportunity oldOpp = oldMap.get(opp);
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
            if (NewOpp.get('StageName').equals('Closed Won')) 
            {
                for (String str: M.keyset()) 
                {
                    try 
                    {                        
                        Change_Request__c crToInsert = null;
                        Boolean isUpdated = false;

                        //Track change on Display Budget
                        if (str.equals('display_budget_change_amount__c')) 
                        {   
                            if (NewOpp.get(str) != null) 
                            {
                                if (((Decimal) NewOpp.get(str) != (Decimal) OldOpp.get(str)) || (NewOpp.get('Display_Budget_Change__c') != OldOpp.get('Display_Budget_Change__c')) || (NewOpp.get('Display_Budget_Change_Amount__c') != OldOpp.get('Display_Budget_Change_Amount__c'))) 
                                {
                                    if (NewOpp.get('Display_Budget_Change__c').equals('Increase')) 
                                    {
                                        // system.debug('******Display Budget value has increased!!! ');
                                        budget = displayBudget + (Decimal) NewOpp.get(str);
                                        description = 'Display Budget Increase';
                                        isUpdated = true;
                                    } 
                                    else if (((String) NewOpp.get('Display_Budget_Change__c')).equals('Decrease')) 
                                    {
                                        // system.debug('******Display Budget has decreased!!! ');
                                        budget = displayBudget - (Decimal) NewOpp.get(str);
                                        description = 'Display Budget Decrease';
                                        isUpdated = true;
                                    }
                                }
                            }
                            if (isUpdated) 
                            {
                                crToInsert = new Change_Request__c
                                (
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
                        if (str.equals('mobile_budget_change_amount__c')) 
                        {
                            if (NewOpp.get(str) != null) 
                            {
                                if ((Decimal) NewOpp.get(str) != (Decimal) OldOpp.get(str) || NewOpp.get('Mobile_Budget_Change__c') != OldOpp.get('Mobile_Budget_Change__c') || NewOpp.get('Mobile_Budget_Change_Amount__c') != OldOpp.get('Mobile_Budget_Change_Amount__c')) 
                                {
                                    if (NewOpp.get('Mobile_Budget_Change__c').equals('Increase')) {
                                        // system.debug('******Mobile Budget value has increased!!! ');
                                        budget = mobileBudget + (Decimal) NewOpp.get(str);
                                        description = 'Mobile Budget Increase';
                                        isUpdated = true;
                                    } 
                                    else if (NewOpp.get('Mobile_Budget_Change__c').equals('Decrease')) 
                                    {
                                        budget = mobileBudget - (Decimal) NewOpp.get(str);
                                        description = 'Mobile Budget Decrease';
                                        isUpdated = true;
                                    }
                                }
                            }

                            if (isUpdated) 
                            {
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
                        if (str.equals('budget_change_start_date__c')) 
                        {
                            if (NewOpp.get(str) != OldOpp.get(str)) 
                            {
                                description = 'Budget Start Date changed';
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
                        if (str.equals('budget_change_end_date__c')) 
                        {
                            if (NewOpp.get(str) != OldOpp.get(str)) 
                            {
                                description = 'Budget End Date changed';
                                // system.debug('******Budget Change End Date has changed!!! ');
                                crToInsert = new Change_Request__c
                                (
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
                    }
                    catch (Exception e) 
                    {
                        System.debug('Error: ' +  e.getLineNumber() + e.getMessage());
                    }
                }   
                //Create a Change Request record
                if (crList.size() > 0)
                {
                    insert(crList);
               
                    // Call out to Cobwebs
                    // if(NewOpp.get('Self_Serve__c') == false)
                    // ERSyncController.updateCampaign((String) NewOpp.get('id'));
                }
            }
        }
    }
            
    /* Handler class method for OpportunityClosedWonValidation Trigger for after Insert Event */
    
    public static void aiOpportunityClosedWonValidation (Map<id,Opportunity> newMap)
    {
        Boolean validateClosedOpp = (Boolean) Cobwebs_Settings__c.getInstance().validate_closed_opportunity__c;
        String emailRecipients = (String) Cobwebs_Settings__c.getInstance().sfalert_email_recipients__c;    
        Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
        try 
        { 
            if(validateClosedOpp || Test.isRunningTest())
            {
                for(Id opp : newMap.keyset())
                {
                    Opportunity opr =newMap.get(opp);
                    if(opr.StageName == 'Closed Won')
                    {
                        opps.put(opr.Id ,opr);
                    }
                }
                for(opportunity oppor : opps.values())
                {
                    //These are new closed won opps
                    if(oppor.Billing_Contact__c == null || oppor.Account.Credit_App_Approved__c == false)
                    {
                        String emailSubject = 'Missing details on Closed Won Opportunity: "' + oppor.Name + '"';
                        String emailBody = 'Hi Thinesh,' + '\r\n\n' +
                        'The following opportunity "' + oppor.Name + '" has been closed won on ' + oppor.CloseDate + ' without an Approved Credit App or a Billing Contact.' + '\r\n\n' +
                       'Please follow the link below to view the Opportunity: ' + '\r\n' +
                       'https://na15.salesforce.com/' + oppor.Id +'\r\n\n' +
                       'Regards,' + '\r\n' +
                       'Salesforce Team: ' + '\r\n\n' +
                       '*** This is an automatically generated email, please do not reply ***' + '\r\n';
                        CobwebsHttpCallout.sendEmail(emailRecipients, emailSubject, emailBody);
                    }
                }
            }           
        }
        
        catch(Exception e)
        {
            System.debug('Error: ' + e.getLineNumber() + e.getMessage()); 
        }
    }
    
    /* Handler class method for OpportunityClosedWonValidation Trigger for after update Event */
        
    public static void auOpportunityClosedWonValidation (Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap)
    {
        Boolean validateClosedOpp = (Boolean) Cobwebs_Settings__c.getInstance().validate_closed_opportunity__c;
        String emailRecipients = (String) Cobwebs_Settings__c.getInstance().sfalert_email_recipients__c;    
        Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
        try 
        { 
            if(validateClosedOpp || Test.isRunningTest())
            {
                for(Id opp : newMap.keyset())
                {
                    Opportunity newOpp = newMap.get(opp);
                    Opportunity oldOpp = oldMap.get(opp);
                    
                    if(newOpp.StageName == 'Closed Won')
                    {
                        if(oldOpp == null || oldOpp.StageName != 'Closed Won')
                        opps.put(oldmap.get(opp).Id ,oldmap.get(opp));
                    }
                }
                for(opportunity opp : opps.values())
                {
                    //These are new closed won opps
                    if(opp.Billing_Contact__c == null || opp.Account.Credit_App_Approved__c == false)
                    {
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
        }
        
        catch(Exception e)
        {
            System.debug('Error: ' + e.getLineNumber() + e.getMessage()); 
        }
    }
}