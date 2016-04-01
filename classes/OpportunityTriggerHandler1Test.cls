/**
    What    : Test class for OpportunityTriggerHandler1 Apex Class .
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest

public class OpportunityTriggerHandler1Test
{

    static testMethod void auOpportunitySync()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());  
       
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
            
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1;  
                          
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Ready To Bill';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp;
            
            opp.StageName='Closed Won';
            update opp;
            
            opp.StageName='RFP/Proposal';
            update opp;
            
            Test.stopTest();
        }
    }
    
    
    static testMethod void TestbuOpportunityRunSecondBusinessDateRule()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());  
       
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
            
        System.runAs(uNew ) 
        {   
            
            Map<String,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
            Id creativeOppRecTypeId =  rt_Map.get('Creative Production').getRecordTypeId();
                    
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1;  
                          
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.recordtypeId=creativeOppRecTypeId;
            opp.StageName='RFP/Proposal';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp;
            
            opp.StageName='Ready To Bill';
            update opp;
            
            opp.StageName='RFP/Proposal';
            update opp;
            
            Test.stopTest();
        }
            
    }
    static testMethod void TestbuOppRunSecondBusinessDateRuleOther()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());  
       
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
            
        System.runAs(uNew ) 
        {   
            
            Map<String,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
            Id creativeOppRecTypeId =  rt_Map.get('Creative Production').getRecordTypeId();
                    
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1;  
                          
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.recordtypeId=creativeOppRecTypeId;
            opp.StageName='RFP/Proposal';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp;
            try
            {
                opp.StageName='Ready To Bill';
                opp.Ready_To_Bill_Date__c=date.newInstance(System.today().year(),12,31);
                update opp;
            }
            catch(Exception e)
            {
            }
            
            Test.stopTest();
        }
            
    }
    static testMethod void TestbuOpportunitySync()
    {
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());  
            User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
             
            Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
            insert cTest;            
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
            
            System.runAs(uNew ) 
            {   
                List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
                
                Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
                cs.Name='Testing';
                cs.account_sync__c =True;
                cs.brand_sync__c=True;
                cs.opportunity_sync__c=False;
                cs1.add(cs); 
                insert cs1;  
                              
                Opportunity opp=new Opportunity();
                opp.name='testopp';
                opp.StageName='Ready To Bill';
                opp.CloseDate = Date.today()+10;
                opp.Campaign_Start_Date__c=Date.today();
                opp.Campaign_End_Date__c=Date.today()+7;
                opp.Display_Budget__c =55;
                opp.LeadSource='Web';    
                opp.CampaignId=ctest.id;
                opp.Initial_Sync__c =true;
                opp.Jira_Key__c='testKey';
                insert opp;
                
                opp.Ready_To_Traffic__c =false;
                update opp;
                /*
                Opportunity opp1=new Opportunity();
                opp1.name='testopp';
                opp1.StageName='RFP/Proposal';
                opp1.CloseDate = Date.today()+10;
                opp1.Campaign_Start_Date__c=Date.today();
                opp1.Campaign_End_Date__c=Date.today()+7;
                opp1.Display_Budget__c =55;
                opp1.LeadSource='Web';    
                opp1.CampaignId=ctest.id;
                opp1.Initial_Sync__c =False;
                opp1.Ready_To_Traffic__c =False;
                opp1.Billing_Contact__c = null;

                insert opp1;
                
                Opportunity opp2=new Opportunity();
                opp2.name='testopp';
                opp2.StageName='Ready To Bill';
                opp2.CloseDate = Date.today()+10;
                opp2.Campaign_Start_Date__c=Date.today();
                opp2.Campaign_End_Date__c=Date.today()+7;
                opp2.Display_Budget__c =55;
                opp2.LeadSource='Web';    
                opp2.CampaignId=ctest.id;
                opp2.Initial_Sync__c =False;
                opp2.Ready_To_Traffic__c =False;
                opp2.Billing_Contact__c = null;

                insert opp2;
                
                Decimal budget;
                Date startDate;
                Date endDate;
                Decimal displayBudget = (Decimal) opp2.Display_Budget__c;
                Decimal mobileBudget = (Decimal) opp2.Mobile_Budget__c;
                
                List<Change_Request__c>lcr = new List<Change_Request__c>();
                
                string Description = 'description';
                
                Change_Request__c cr = new Change_Request__c();
                cr.Key__c='TestKey';
                cr.Object_ID__c =opp.Id;
                cr.Value__c='TestValue';
                cr.Opportunity__c = opp.Id;
                cr.Object_Type__c = 'Opportunity';
                cr.Timestamp__c = DateTime.Now();
                cr.Description__c = Description ;
                lcr.add(cr);
                Insert lcr;
                */
            }
            test.stopTest();

    }
    static testMethod void TestbuOpportunitySync1()
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
            List<Opportunity> listCPOpps = [Select 
                                                Id, StageName, First_Date_of_Next_Month__c, Ready_To_Bill_Date__c, 
                                                First_Day_of_Next_Month__c, Second_Date_of_Next_Month__c, 
                                                Second_Business_Date_of_Next_Month__c, RecordType.Name 
                                            from Opportunity where RecordType.Name='Creative Production'];
            
            Opportunity[] o_query = [SELECT Id,Name FROM Opportunity WHERE Id=: newOpp.Id];


        }
    }   
    static testMethod void TestauOpportunity3()
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
            newOpp.Ready_To_Bill_Date__c=Date.today()+7;
            newOpp.Second_Business_Date_of_Next_Month__c=Date.today();
            newOpp.Jira_Key__c='testKey';
            insert newOpp;
    }    
    static testMethod void TestauOpportunity4()
    {
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());  
            User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
             
            Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
            insert cTest;            
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
            
            System.runAs(uNew ) 
            {   
                List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
                
                Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
                cs.Name='Testing';
                cs.account_sync__c =True;
                cs.brand_sync__c=True;
                cs.opportunity_sync__c=False;
                cs1.add(cs); 
                insert cs1;  
                              
                RecordType rt = [select id,Name,DeveloperName from RecordType where SobjectType='Opportunity' Limit 1];
                Map<Id,Opportunity>oMap = new Map<Id, Opportunity>();
                for (Opportunity op : [SELECT Id, Name 
                                    FROM 
                                        Opportunity 
                                    LIMIT 1]) 
                {
                    oMap.put(op.Id,op);
                }
                
                Opportunity opp=new Opportunity();
                opp.name='testopp';
                opp.StageName='Ready To Bill';
                opp.CloseDate = Date.today()+10;
                opp.Campaign_Start_Date__c=Date.today();
                opp.Campaign_End_Date__c=Date.today()+7;
                opp.Display_Budget__c =55;
                opp.LeadSource='Web';    
                // opp.RecordType.Name =rt.Id;
                opp.CampaignId=ctest.id;
                opp.Initial_Sync__c =true;
                opp.Ready_To_Traffic__c =true;
                opp.Jira_Key__c='testKey';
                
                insert opp;
                
                Change_Request__c cReq = new Change_Request__c();
                cReq.Name='Change Request';
                cReq.Key__c='TestKey';
                cReq.Value__c='TestVal';
                cReq.Opportunity__c =opp.Id;
                cReq.Object_ID__c='TestobjId';
                insert cReq;

              
                List<Opportunity>oppl=[SELECT Name,Id FROM Opportunity WHERE Id=:opp.Id];
                update oppl;
        }  
    } 
    
    static testMethod void TestauOpportunityChangeSync()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());     
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
         
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;            
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1; 
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Closed Won';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp; 
            
            opp.display_budget_change_amount__c=1500000;
            opp.Display_Budget_Change__c='Increase';
            update opp;
            
            opp.display_budget_change_amount__c=1;
            opp.Display_Budget_Change__c='Descrese';
            update opp;
        }
    }
    
    static testMethod void TestauOpportunityChangeSyncdecrease()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());     
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
         
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;            
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1; 
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Closed Won';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Display_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp; 
            
            opp.display_budget_change_amount__c=1;
            opp.Display_Budget_Change__c='Decrease';
            update opp;
        }
    }
    
    static testMethod void TestauOpportunityChangeSyncMdecrease()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());     
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
         
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;            
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1; 
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Closed Won';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Mobile_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            insert opp; 
            
            opp.mobile_budget_change_amount__c=1;
            opp.Mobile_Budget_Change__c='Decrease';
            update opp;
        }
    }
    
    static testMethod void TestauOpportunityChangeSyncMIncrease()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());     
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
         
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;            
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1; 
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Closed Won';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Mobile_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            opp.budget_change_end_date__c=Date.today();
            insert opp; 
            opp.budget_change_end_date__c=Date.today()+1;
            opp.mobile_budget_change_amount__c=100000;
            opp.Mobile_Budget_Change__c='Increase';
            update opp;
        }
    }
    
    static testMethod void TestauOpportunityChangeSyncIncrease()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());     
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];
         
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;            
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {   
            List<Cobwebs_Settings__c> cs1 = new List<Cobwebs_Settings__c>();
            
            Cobwebs_Settings__c cs = new Cobwebs_Settings__c();
            cs.Name='Testing';
            cs.account_sync__c =True;
            cs.brand_sync__c=True;
            cs.opportunity_sync__c=False;
            cs1.add(cs); 
            insert cs1; 
            
            Opportunity opp=new Opportunity();
            opp.name='testopp';
            opp.StageName='Closed Won';
            opp.CloseDate = Date.today()+10;
            opp.Campaign_Start_Date__c=Date.today();
            opp.Campaign_End_Date__c=Date.today()+7;
            opp.Mobile_Budget__c =55;
            opp.LeadSource='Web';    
            opp.CampaignId=ctest.id;
            opp.Initial_Sync__c =true;
            opp.Ready_To_Traffic__c =true;
            opp.Jira_Key__c='testKey';
            opp.budget_change_start_date__c=Date.today();
            insert opp; 
            opp.budget_change_start_date__c=Date.today()+1;
            opp.mobile_budget_change_amount__c=100000;
            opp.Mobile_Budget_Change__c='Increase';
            update opp;
        }
    }
}