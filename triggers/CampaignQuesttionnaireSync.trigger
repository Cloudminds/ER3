trigger CampaignQuesttionnaireSync on Campaign_Questionnaire__c (after insert, after update) {
    Boolean campaignQuestionnaireSync = (Boolean) Cobwebs_Settings__c.getInstance().campaign_questionnaire_sync__c;

    if (Trigger.isAfter && (campaignQuestionnaireSync || Test.isRunningTest())) {
        for (Campaign_Questionnaire__c record : Trigger.new) {
            if (Trigger.isInsert) {
                System.debug('Entered Campaign Questionnaire trigger insert');
                ERSyncController.emailNewCampaignQuestionnaire(record.Id);
            } else if (Trigger.isUpdate) {
                System.debug('Entered Campaign Questionnaire trigger update');
                ERSyncController.emailUpdateCampaignQuestionnaire(record.Id);
            }
        }
    }
}