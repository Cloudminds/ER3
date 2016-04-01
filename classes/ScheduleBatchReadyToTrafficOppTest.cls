/**
    What    : Test Class of ScheduleBatchReadyToTrafficOpportunity Apex Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest
public class ScheduleBatchReadyToTrafficOppTest
{
    public static testMethod void testSchedule() 
    {
        Test.startTest();
        ScheduleBatchReadyToTrafficOpportunity sch = new ScheduleBatchReadyToTrafficOpportunity ();
        Id job_id = System.schedule('test',  '0 0 23 1/1 * ? *', sch);
        System.assertNotEquals(null, job_id);
        Test.stopTest();
    }
}