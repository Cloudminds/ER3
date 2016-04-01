/**
    What    : Schedular Class to schedule the ReadyToTrafficBatchable Batch Class.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
global class ScheduleBatchReadyToTrafficOpportunity implements Schedulable {
   global void execute(SchedulableContext sc) {
      ReadyToTrafficBatchable rtb = new ReadyToTrafficBatchable(); 
       ID batchprocessid =database.executebatch(rtb);
   }
}