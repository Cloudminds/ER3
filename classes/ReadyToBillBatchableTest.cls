@isTest
public class ReadyToBillBatchableTest {
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
        
        Test.startTest();         
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());
        RecordType rt = [select id,Name,SobjectType,DeveloperName from RecordType where SobjectType='Opportunity' and Name ='Creative Production' LIMIT 1]; 
        
        Opportunity opp=new Opportunity();
        opp.name='testopp1';
        opp.RecordTypeId=rt.Id;
        opp.StageName='Closed Won';
        opp.CloseDate = Date.today()+10;
        opp.OwnerID = u1.Id;
        opp.Second_Business_Date_of_Next_Month__c = Date.today()+29;
        opp.Ready_To_Bill_Date__c = Date.Today();
        Insert Opp;
        
        //ReadyToBillBatchable bObj = new ReadyToBillBatchable();
        //Database.executeBatch(bObj,10);
        
        String Query;
        ReadyToBillBatchable bObj2 = new ReadyToBillBatchable(Query);
        Database.executeBatch(bObj2,10);

        Test.stopTest();
    }  
}