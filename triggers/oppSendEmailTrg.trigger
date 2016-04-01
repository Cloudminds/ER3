/*
    What    : Trigger to inserting values to Change Request object as per condition. 
    Who     : Vishal Khanna
    When    : Jan 2016
    Which   : Version 1.0
*/
trigger oppSendEmailTrg on Opportunity (  after Update) 
{
     try
     {  
       
        List<Change_Request__c> chngeReqList = new List<Change_Request__c>();    
       /* List<Opportunity> oppList = [SELECT Id, 
                                            Name , adServing_Campaign_Budget__c , Reason_Comment__c , 
                                            Reason__c , CampaignId , LastModifiedDate , Description , OwnerId,
                                            Brand__c , Primary_Display_Sales_Rep__c , Primary_Mobile_Sales_Rep__c , 
                                            Account_Managers__c , Opportunity_Analyst__c , Display_Budget_Change__c , AccountId , 
                                            StageName
                                        FROM
                                            Opportunity 
                                        WHERE
                                            ID IN :Trigger.newMap.keySet() ];      
                                                                   
        System.debug('#####oppList#####' +oppList);*/

         
        Change_Request__c chngeReqObj = new Change_Request__c();
         boolean isrun=checkRecursiveoppSendEmailTrg.runOnce();
         System.debug('##checkRecursiveoppSendEmailTrg.runOnce()'+isrun);
         
        if((isrun && trigger.isUpdate==True) || test.isRunningTest())
        {
            for(Opportunity oppTemp: trigger.new)
            { 
                System.debug('#######Trigger.oldMap.get(oppTemp.Id).StageName'+Trigger.oldMap.get(oppTemp.Id).StageName);
                
                if(  oppTemp.StageName!=Trigger.oldMap.get(oppTemp.Id).StageName)
                {
                    if((oppTemp.Display_Budget_Change__c == 'Increase' || oppTemp.Display_Budget_Change__c == 'Decrease' || oppTemp.StageName == 'Cancelled' || oppTemp.StageName == 'Paused' ) )
                    {
                        if((oppTemp.Reason_Comment__c != null || oppTemp.Reason_Comment__c != Trigger.oldMap.get(oppTemp.Id).Reason_Comment__c) && oppTemp.Reason__c != null)
                        {                          
                            chngeReqObj.Description__c = oppTemp.Description;
                            chngeReqObj.Object_ID__c = oppTemp.Id;
                            chngeReqObj.Object_Type__C = oppTemp.Id.getSObjectType().getDescribe().getName();
                            chngeReqObj.Opportunity__c = oppTemp.Id;
                            chngeReqObj.TimeStamp__c = oppTemp.LastModifiedDate;
                            chngeReqObj.Value__c = oppTemp.Reason_Comment__c;
                            chngeReqObj.Key__c = 'Test';    // This is for test because this required field on detail page
                            chngeReqObj.Changed_From__c=Trigger.oldMap.get(oppTemp.Id).StageName;
                            chngeReqObj.Changed_To__c=oppTemp.stageName;
                           
                            chngeReqList.add(chngeReqObj); 
                                                     
                        }
                    }
                }
            }
            if(chngeReqList.size()>0)
            {                
                Insert chngeReqList;
            }   
        }
     }
    
    catch(Exception e)
    {
        ApexPages.addMessages(e);
        System.debug('An exception has occured - ' + e.getMessage() + ' - ' + e.getLineNumber());
    } 
}