global class SchedulableForecastReport implements Schedulable {
    global static final String emailRecipients = (String) Cobwebs_Settings__c.getInstance().sfalert_email_recipients__c;
    public static String CRON_EXP = '0 0 8 ? * 4 *';
    
    global static String scheduleIt() {
        return System.schedule('Deliver Weekly Forecasting Report', CRON_EXP, new SchedulableForecastReport());
    }
        
    global void execute(SchedulableContext ctx) {
        List<EmailTemplate> forecastEmailTemplate = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name=: 'Weekly Spend Forecast Report'];
        List<User> marketingAdminUser = [SELECT Id FROM User WHERE Profile.Name in ('Marketing User (Admin)') LIMIT 1];
        //List<Contact> marketingAdminUser = [SELECT Id FROM Contact WHERE Name in ('Salesforce Team') LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (forecastEmailTemplate !=null && forecastEmailTemplate.size() > 0) {            
            if (!marketingAdminUser.isEmpty()){
                mail.setTemplateId(forecastEmailTemplate[0].Id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(marketingAdminUser[0].Id);
                mail.setCcAddresses(new String[]{'sfalerts@eyereturn.com','arobitaille@eyereturn.com'});
                mail.setSenderDisplayName('eyeReturn Salesforce Team');
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}