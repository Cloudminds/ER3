/**
    What    : Test Class for MasterOpportunityTrigger1 Trigger on Opportunity.    
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest

public class MasterOpportunityTrigger1Test
{
    static testMethod void TestMasterOpportunity1()
    {
            test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
            Map<String, Id>tMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name 
                                    FROM 
                                        RecordType WHERE SObjectType = 'Opportunity' 
                                    ORDER BY Name LIMIT 1]) 
            {
                tMap .put(rt.Name,rt.Id);
            }
                    
            Campaign  cam= new Campaign();
            cam.Name = 'Test';
            cam.Type='Internet';
            insert cam;
            
            ERSyncController ers = new ERSyncController();
            
            Opportunity newOpp=new Opportunity();
            newOpp.name='testopp';
            newOpp.StageName='Closed Won';
            newOpp.CloseDate = Date.today()+10;
            newOpp.Campaign_Start_Date__c=Date.today();
            newOpp.Campaign_End_Date__c=Date.today()+7;
            newOpp.Display_Budget__c =55;
            newOpp.LeadSource='Web';    
            newOpp.CampaignId=cam.id;
            newOpp.Initial_Sync__c =true;
            newOpp.Ready_To_Traffic__c =true;
            newOpp.Jira_Key__c='testKey';
            insert newOpp;
            
            test.stopTest();
    }
    static testMethod void TestbuOpportunity2()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        User uRec =[select id,name from user where profile.name='System Administrator' and isactive=true Limit 1];
        System.runAs(uRec)
        {
            Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
            insert cTest;
    
            Lead ltest=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Initial Call Made');
            insert ltest;
            
            Campaign  cam= new Campaign();
            cam.Name = 'Test';
            cam.Type='Internet';
            insert cam;
            
            ERSyncController ers = new ERSyncController();
            
            Opportunity newOpp=new Opportunity();
            newOpp.name='testopp';
            newOpp.StageName='Customer Won';
            newOpp.CloseDate = Date.today()+10;
            newOpp.Campaign_Start_Date__c=Date.today();
            newOpp.Campaign_End_Date__c=Date.today()+7;
            newOpp.Display_Budget__c =55;
 
            newOpp.CampaignId=ctest.id;
            newOpp.Initial_Sync__c =true;
            newOpp.Ready_To_Traffic__c =true;
            newOpp.Jira_Key__c='testKey';
            
            insert newOpp;
            
            ERSyncController obj = new ERSyncController();
            ERSyncController.closedWonCampaign(newOpp.Id);
            
            Opportunity oldOpp =new Opportunity();
            
            Opportunity opp1 =[SELECT
                                    Name,Id,StageName,CloseDate,CampaignId 
                                FROM
                                     Opportunity 
                                 WHERE Id=: newOpp.Id ];
            update opp1;           
            
            Opportunity o = new Opportunity();
            o.Name = 'Test Opp';
            o.StageName = 'NO Contact Made';
            o.CloseDate = Date.today();
            Database.SaveResult sr = Database.insert(o);
            String oppId = opp1.id;
            update o;
            
            Holiday_Settings__c hsc = new Holiday_Settings__c();
            hsc.Name='TestName';
            insert hsc;
            
            Date NextHoliday = hsc.Next_Holiday_Date__c ;            
            Opportunity[] o_query = [SELECT Id,Name FROM Opportunity WHERE Id=: newOpp.Id];


        }
    }   

    
    
}