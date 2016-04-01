/**
    What    : Test Class for EmailAlertBatchable Apex class  .       
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest
public class EmailAlertBatchableTest
{
    static testmethod void test() 
    {
        Test.startTest();
        
        string strq='Select Id, Email__c, Email_Body__c, Type__c, Is_Sent__c, Additional_Info__c from Email_Alert__c where Is_Sent__c=FALSE and Type__c=\'Ready To Bill Alert\'';
        Email_Alert__c [] mailA = new List<Email_Alert__c >();
        for (Integer i=0;i<10;i++) 
        {
               Email_Alert__c  email = new Email_Alert__c (
               Name='TestAlert' + i,
               Email__c='abc@test.com',
               Email_Body__c='TestBody',
               Type__c='Ready To Bill Alert',
               Is_Sent__c =FALSE,
               Additional_Info__c ='TestAdditional'
               );
               mailA .add(email);
        }
        insert mailA ;
        
        EmailAlertBatchable eab1 = new EmailAlertBatchable(null);
        
        EmailAlertBatchable eab = new EmailAlertBatchable(strq);
        eab.blastEmailAlert('Test1','Test2','Test3');
        Database.executeBatch(eab);
        Test.stopTest();

        
    }
    static testmethod void test1() 
    {
        Test.startTest();      

            string strq1='Select Id, Email__c, Email_Body__c, Type__c, Is_Sent__c, Additional_Info__c from Email_Alert__c';
            Map<string,string> mFirstNames = new Map<string,string>();
            Email_Alert__c  email1 = new Email_Alert__c (
            Name='TestAlert1',
            Email__c='abc1@test.com',
            Email_Body__c='TestBody',
            Type__c='Ready To Bill Alert',
            Is_Sent__c =FALSE,
            Additional_Info__c ='TestAdditional'
            );        
            insert email1 ;
            
            List<Email_Alert__c> iEmails = [SELECT Id, Email__c FROM Email_Alert__c WHERE Is_Sent__c=false];        

            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(
            Alias = 'testu',
            Email = 'test@testing.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId =p.Id,
            UserName='test@unitingambition.com'
            );
            INSERT u;
            User usr =[Select Id, Email, FirstName, LastName from User WHERE Id=:u.Id];
            mFirstNames.put(u.Email,u.FirstName);
            System.runAs(u)
            {
                EmailAlertBatchable eab = new EmailAlertBatchable(strq1);
                eab.setFirstNames();
                Database.executeBatch(eab);
            }
        Test.stopTest();
    }
}