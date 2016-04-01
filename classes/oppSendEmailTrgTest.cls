/*
    What    : Test Class for oppSendEmailTrg Trigger on Opportunity
    Who     : Vishal Khanna
    When    : Jan 2016
    Which   : Version 1.0
*/

@isTest

public  class oppSendEmailTrgTest{
    static testMethod  void TestOppTriMethod2()
    {            
        test.startTest();
        
        Campaign cTest=new Campaign(name='Test Campagin',type='Internet');
        insert cTest;  
        
        User u=[select id from user where profile.name ='System Administrator' and isactive=true Limit 1];

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User uNew = new User(Alias = 'standt', Email='standarduser@xyz.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@xyz.com');
        
        System.runAs(uNew ) 
        {       
                RecordType rt = [select id,Name,DeveloperName from RecordType where SobjectType='Opportunity' Limit 1];
                
                Opportunity opp=new Opportunity();
                opp.name='testopp';
                opp.CloseDate = Date.today()+10;
                opp.Campaign_Start_Date__c=Date.today();
                opp.Campaign_End_Date__c=Date.today()+7;
                opp.Display_Budget__c =55;
                opp.LeadSource='Web';    
                opp.CampaignId=ctest.id;
                opp.Initial_Sync__c =true;
                opp.Ready_To_Traffic__c =true;
                opp.Jira_Key__c='testKey';
                opp.Reason__c= 'Perfomance';
                opp.Reason_Comment__c ='TestComment';
                opp.Description='TestDesc';
                opp.stageName='Cancelled';
                opp.Display_Budget_Change__c ='Increase';
               
                Insert opp; 
                
                opp.StageName='Paused' ;
                update opp;
                
                Change_Request__c chngeReqList = new Change_Request__c();
                chngeReqList.Name='TestNameReq';
                chngeReqList.Changed_From__c='Closed Won';
                chngeReqList.Changed_To__c='Paused';
                chngeReqList.Description__c='testdescription';
                chngeReqList.Key__c='testKey';
                chngeReqList.Object_ID__c='006123456789321';
                chngeReqList.Object_Type__c='Opportunity';
                chngeReqList.Is_Process__c = True;
                chngeReqList.Opportunity__c =opp.Id;
                Insert chngeReqList;  
        }
        
     Test.stopTest();   
    }
     static testMethod  void TestOppTriMethod1()
    {            
        test.startTest();
        
        Email_Settings__c cu= new Email_Settings__c();
        cu.Email_Ids__c='test@test.com';
        cu.Name='TestCU'; 
        insert cu;
        
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        
        Campaign cmp = new Campaign();
        cmp.Name ='TestCamp';
        insert cmp;
                
        Opportunity opp=new Opportunity();
        opp.name='testopp';
        opp.AccountId =client.Id;
        opp.StageName='Ready To Bill';
        opp.CloseDate = Date.today()+10;
        opp.Campaign_Start_Date__c=Date.today();
        opp.Campaign_End_Date__c=Date.today()+37;
        opp.Display_Budget__c =550000;
        opp.LeadSource='Web';    
        opp.Initial_Sync__c =true;
        opp.Ready_To_Traffic__c =true;
        opp.Jira_Key__c='testKey';
        opp.Reason_Comment__c='TestComment';
        opp.Reason__c='Performance';
        opp.Description='Test Description';
        opp.StageName = 'Paused';
        opp.campaignId = cmp.Id;

        insert opp;
        
        Change_Request__c chngeReqList = new Change_Request__c();
        chngeReqList.Name='TestNameReq';
        chngeReqList.Changed_From__c='Restfrom';
        chngeReqList.Changed_To__c='testto';
        chngeReqList.Description__c='testdescription';
        chngeReqList.Key__c='testKey';
        chngeReqList.Object_ID__c='006123456789321';
        chngeReqList.Object_Type__c='Opportunity';
        chngeReqList.Is_Process__c = False;
        chngeReqList.Opportunity__c =opp.Id;
        Insert chngeReqList;        
        
        chngeReqList.Is_Process__c =True;
        update chngeReqList;
        
        opp.StageName='Paused';
        update opp;
    
        opp.StageName='Cancelled';
        update opp;
                                            
        Opportunity op1= [SELECT Name ,adServing_Campaign_Budget__c , Reason_Comment__c , StageName,
                                    Reason__c , CampaignId , LastModifiedDate , Description , OwnerId,
                                    Brand__c , Primary_Display_Sales_Rep__c , Primary_Mobile_Sales_Rep__c , 
                                    Account_Managers__c , Opportunity_Analyst__c , Display_Budget_Change__c , AccountId                                     
                            FROM
                                    Opportunity
                            WHERE 
                                    Id =:opp.Id LIMIT 1];
        
        test.stopTest();
    }
 }