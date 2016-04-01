trigger BrandSync on Brand__c (before insert, before update, after insert, after update) {
    Boolean brandSync = (Boolean) Cobwebs_Settings__c.getInstance().brand_sync__c;

    // Before inserting or updating, make sure name is unique
    if (Trigger.isBefore) {
        for (Brand__c record : Trigger.new) {
            ERSyncController.validateBrand(record);
        }
    }

    else if (Trigger.isAfter && Trigger.isUpdate) {
        if (brandSync || Test.isRunningTest()) {
            System.debug('Entered Brand trigger update');
            for (Brand__c record : Trigger.new) {
                if (record.IsAPI__c) {
                    System.debug('Brand update triggered via API');
                    ERSyncController.brandLock = true;
                    ERSyncController.easeBrand(record.Id);
                } else if (!ERSyncController.brandLock && record.Brand_ID__c != null) {
                    ERSyncController.brandLock = true;
                    ERSyncController.updateBrand(record.Id);
                } else if (ERSyncController.brandLock) {
                    System.debug('Brand update was locked');
                }
            }
        }
    }
}