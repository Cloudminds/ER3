/**
    What    : Schedular Class to schedule the BatchOpportunityEmailUpdate Batch Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
global class ScheduleBatchOpportunityEmailUpdate  implements Schedulable 
{
    public static String sched = '0 0 23 1/1 * ? *'; 

    global static String schedulecls()
    {
        ScheduleBatchOpportunityEmailUpdate SC = new ScheduleBatchOpportunityEmailUpdate (); 
        return System.schedule('My batch Job', sched, SC);
    }

    global void execute(SchedulableContext sc) 
    {
        BatchOpportunityEmailUpdate b1 = new BatchOpportunityEmailUpdate();
        ID batchprocessid = Database.executeBatch(b1,50);           
    }
    
}