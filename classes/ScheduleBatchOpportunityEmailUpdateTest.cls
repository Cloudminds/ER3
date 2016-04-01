/**
    What    : Test Class of ScheduleBatchOpportunityEmailUpdate Apex Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
@isTest
public class ScheduleBatchOpportunityEmailUpdateTest  
{
    public static testMethod void testSchedule1() 
    {
        Test.startTest();
        ScheduleBatchOpportunityEmailUpdate sch = new ScheduleBatchOpportunityEmailUpdate ();
        ScheduleBatchOpportunityEmailUpdate.schedulecls();
        Id job_id = System.schedule('test',  '0 0 23 1/1 * ? *', sch);
        System.assertNotEquals(null, job_id);
        Test.stopTest();
    }
}