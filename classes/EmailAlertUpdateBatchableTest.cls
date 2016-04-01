/**
    What    : Test class for EmailAlertUpdateBatchable Apex Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/

@isTest
public class EmailAlertUpdateBatchableTest
{
    static testmethod void test() 
    {
            Test.startTest();         
            Email_Settings__c esec=new Email_Settings__c ();
            esec.Name='TestName';
            esec.Email_Ids__c='Test@testing.com';
            insert esec;
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Ready To Bill';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp;       
            
            Id oppId= opp.Id;
            
            Change_Request__c cQ=new Change_Request__c();
            cQ.Name='TestChange';
            cQ.Changed_From__c='testFrom';
            cQ.Changed_To__c='TestTo';
            cQ.Description__c='testDescription';
            cQ.JIRA_Key__c='testKey';
            cQ.Object_ID__c='00612121212121121';
            cQ.Object_Type__c='Opportunity';
            cQ.Key__c='testKey';
            cQ.Opportunity__c=oppId;
            cQ.Type__c='TestType';
            insert cQ;    
            
            List<Change_Request__c>iReq=[SELECT Id,Opportunity__c  FROM Change_Request__c WHERE Opportunity__c=:opp.Id AND CreatedDate = TODAY];     
            List<Email_Alert__c>eAl = [SELECT Id, Email__c, Email_Body__c, Type__c, Is_Sent__c, Additional_Info__c FROM Email_Alert__c WHERE Is_Sent__c=FALSE and Type__c='Change In Value']; 
            
            Database.executeBatch(new EmailAlertUpdateBatchable(), 5); 
            
            BatchOpportunityEmailUpdate  bObj = new BatchOpportunityEmailUpdate ();
            Database.executeBatch(bObj,1); 
        
            
    }
}