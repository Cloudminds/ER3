trigger SalesRepSync on Sales_Rep__c (after insert) {
    Boolean salesRepSync = (Boolean) Cobwebs_Settings__c.getInstance().sales_rep_sync__c;

    // If inserting
    if (salesRepSync || Test.isRunningTest()) {
      if (Trigger.isAfter && Trigger.isInsert) {
          System.debug('Entered Sales Rep trigger insert');
          for (Sales_Rep__c record : Trigger.new) {
              ERSyncController.createSalesRep(record.Id);
          }
      }
    }
}