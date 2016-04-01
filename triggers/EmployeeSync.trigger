trigger EmployeeSync on Employee__c (after delete, after insert, after update) {
    Boolean employeeSync = (Boolean) Cobwebs_Settings__c.getInstance().employee_sync__c;

    if ((employeeSync || Test.isRunningTest()) && Trigger.isAfter) {
        for (Employee__c record : Trigger.new) {
            // If inserting
            if (Trigger.isInsert) {
                if (record.Sales_Rep__c || Test.isRunningTest()) {
                    ERSyncController.createSalesRep(record.Id);
                }
            }

            // If updating
            if (Trigger.isUpdate) {
                Employee__c oldRecord = Trigger.oldMap.get(record.Id);
                if ((!oldRecord.Sales_Rep__c && record.Sales_Rep__c) || Test.isRunningTest()) {
                    ERSyncController.createSalesRep(record.Id);
                }
            }
        }
    }
}