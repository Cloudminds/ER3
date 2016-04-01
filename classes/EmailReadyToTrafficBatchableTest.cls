/**
    What    : Test class for  Apex Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/

@isTest
public class EmailReadyToTrafficBatchableTest
{
    static testmethod void test() 
    {
        Test.startTest();
        
        Email_Alert__c oe = new   Email_Alert__c(email__c='test@abc.com',Email_Body__c='testing',Type__c='Ready to Traffic',Is_Sent__c=false);     
        Insert oe;
        Email_Alert__c oe1 = new   Email_Alert__c(Email_Body__c='testing',Type__c='Ready to Traffic',Is_Sent__c=false);     
        Insert oe1;
        
        EmailReadyToTrafficBatchable  bObj = new EmailReadyToTrafficBatchable ();
        Database.executeBatch(bObj,1);
            
        String query ;
        EmailReadyToTrafficBatchable  bObj2 = new EmailReadyToTrafficBatchable (query);
        Database.executeBatch(bObj,1);
        
        Test.stopTest();
    }
}