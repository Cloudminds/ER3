trigger ContactSync on Contact (before insert, after insert, before update, after update, before delete) {
    Boolean contactSync = (Boolean) Cobwebs_Settings__c.getInstance().contact_sync__c;

    // Before inserting or updating, make sure email doesn't already exist
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Contact record : Trigger.new) {
            ERSyncController.validateContact(record);
        }
    }

    if (contactSync || Test.isRunningTest()) {
        // If inserting
        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('Entered Contact trigger insert.');
            for (Contact record : Trigger.new) {
                ERSyncController.contactLock = true;
                ERSyncController.createContact(record.Id);
                ERSyncController.contactLock = false;
            }
        }
        // If updating
        else if (Trigger.isAfter && Trigger.isUpdate) {
            System.debug('Entered Contact trigger update.');
            for (Contact record : Trigger.new) {
                // If via API call, allow even if there's a lock.
                if (record.IsAPI__C) {
                    ERSyncController.contactLock = true;
                    ERSyncController.easeContact(record.Id);
                } else if (!ERSyncController.contactLock) {
                    ERSyncController.contactLock = true;
                    ERSyncController.updateContact(record.Id);
                    ERSyncController.contactLock = false;
                } else if (ERSyncController.contactLock) {
                    System.debug('Contact update was locked.');
                }
            }
        }
        // If deleting
        else if (Trigger.isDelete) {
            ERSyncController.contactLock = true;
            for (Contact record : Trigger.old) {
                if (record.Contact_ID__c != null)
                    ERSyncController.deleteContact(record.Contact_ID__c.toPlainString());
            }
        }
    }
}