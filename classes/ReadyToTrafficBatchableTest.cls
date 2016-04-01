@isTest
public class ReadyToTrafficBatchableTest
{
    static testmethod void test1() 
    {
        profile p = [select id from Profile limit 1];
        User u1 = new User(FirstName = 'David',LastName  = 'Liu',
                           Email     = 'dvdkliu+sfdc99@gmail.com',
                           Username  = 'sfdc-dreamer@gmail.com',
                           Alias     = 'fatty2',
                           TimeZoneSidKey    = 'America/Denver',
                           LocaleSidKey      = 'en_US',
                           EmailEncodingKey  = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           profileid=p.id);
        insert u1;
        User u2 = new User(FirstName = 'David',LastName  = 'Liu',
                           Email     = 'dvdkliu+sfdc929@gmail.com',
                           Username  = 'sfdc-dreamer2@gmail.com',
                           Alias     = 'fatty2',
                           TimeZoneSidKey    = 'America/Denver',
                           LocaleSidKey      = 'en_US',
                           EmailEncodingKey  = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           profileid=p.id);
        insert u2;
        User u3 = new User(FirstName = 'David',LastName  = 'Liu',
                           Email     = 'dvdkliu+sfdc993@gmail.com',
                           Username  = 'sfdc-dreamer3@gmail.com',
                           Alias     = 'fatty3',
                           TimeZoneSidKey    = 'America/Denver',
                           LocaleSidKey      = 'en_US',
                           EmailEncodingKey  = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           profileid=p.id);
        insert u3;
        User u4 = new User(FirstName = 'David',LastName  = 'Liu',
                           Email     = 'dvdkliu+sfdc994@gmail.com',
                           Username  = 'sfdc-dreamer4@gmail.com',
                           Alias     = 'fatty4',
                           TimeZoneSidKey    = 'America/Denver',
                           LocaleSidKey      = 'en_US',
                           EmailEncodingKey  = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           profileid=p.id);
        insert u4;
        Employee__c emp1 = new Employee__c(Name='TestName1',First_Name__c='Test',Last_Name__c='Name1',Related_To__c=u1.ID);
        Insert emp1;
        Employee__c emp2 = new Employee__c(Name='TestName2',First_Name__c='Test',Last_Name__c='Name2',Related_To__c=u2.Id);
        Insert emp2;
        Employee__c emp3 = new Employee__c(Name='TestName3',First_Name__c='Test',Last_Name__c='Name3',Related_To__c=u3.ID);
        Insert emp3;
        Employee__c emp4 = new Employee__c(Name='TestName4',First_Name__c='Test',Last_Name__c='Name4',Related_To__c=u4.ID);
        Insert emp4;
        
        Test.startTest();         
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        RecordType rt = [select id,Name,SobjectType,DeveloperName from RecordType where SobjectType='Opportunity' and Name ='eyeDemand' LIMIT 1]; 
        
        Opportunity opp=new Opportunity();
        opp.name='testopp1';
        opp.RecordTypeId=rt.Id;
        opp.StageName='Closed Won';
        opp.CloseDate = Date.today()+10;
        opp.Ready_To_Traffic__c =true;
        opp.Jira_Key__c='testKey';
        opp.Jira_Key_AM__c ='TestKeyAM';
        opp.Primary_Display_Sales_Rep__c = emp1.id;
        opp.Secondary_Display_Sales_Rep__c = emp2.ID;
        Insert Opp;
        
        Opportunity opp2=new Opportunity();
        opp2.name='testopp2';
        opp2.RecordTypeId=rt.Id;
        opp2.StageName='Closed Won';
        opp2.CloseDate = Date.today()+10;
        opp2.Ready_To_Traffic__c =true;
        opp2.Jira_Key__c='testKey2';
        opp2.Jira_Key_AM__c ='TestKeyAM2';
        opp2.Primary_Display_Sales_Rep__c = emp2.id;
        opp2.Secondary_Display_Sales_Rep__c = emp3.ID;
        Insert Opp2 ;
        Opportunity opp3=new Opportunity();
        opp3.name='testopp3';
        opp3.RecordTypeId=rt.Id;
        opp3.StageName='Closed Won';
        opp3.CloseDate = Date.today()+10;
        opp3.Ready_To_Traffic__c =true;
        opp3.Jira_Key__c='testKey3';
        opp3.Jira_Key_AM__c ='TestKeyAM3';
        opp3.Primary_Display_Sales_Rep__c = emp4.id;
        opp3.Secondary_Display_Sales_Rep__c = emp1.ID;
        Insert Opp3 ;
        
        ReadyToTrafficBatchable bObj = new ReadyToTrafficBatchable();
        Database.executeBatch(bObj,10);
        
        String Query;
        ReadyToTrafficBatchable bObj2 = new ReadyToTrafficBatchable(Query);
        Database.executeBatch(bObj2,10);

        Test.stopTest();
    }  
}