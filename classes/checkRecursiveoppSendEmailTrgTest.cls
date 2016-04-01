/**
    What    : Test Class for checkRecursiveoppSendEmailTrg Apex Class
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest
public class checkRecursiveoppSendEmailTrgTest{

    public static testMethod void testcheck() 
    {
        test.startTest();
        boolean run = false;
        checkRecursiveoppSendEmailTrg.run =true;
        checkRecursiveoppSendEmailTrg.runOnce();
        test.stopTest();   
    }
    public static testMethod void testcheck2() 
    {
        test.startTest();
        boolean run = true;
        checkRecursiveoppSendEmailTrg.run =false;
        checkRecursiveoppSendEmailTrg.runOnce();        
        test.stopTest();   
    }

}