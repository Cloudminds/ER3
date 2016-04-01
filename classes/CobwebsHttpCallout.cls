global class CobwebsHttpCallout {
    private static final String endpointUrl = (String) Cobwebs_Settings__c.getInstance().url__c;
    private static final String user = (String) Cobwebs_Settings__c.getInstance().user__c;
    private static final String pass = (String) Cobwebs_Settings__c.getInstance().password__c;
    private static final String sfAlertDispName = (String) Cobwebs_Settings__c.getInstance().sfalert_email_display_name__c;
    private static String adminEmail = 'ekim@eyereturn.com';

    @future (callout=true)
    public static void getRequest(String action, String objectType, String objectId) {
        System.debug('Entered get request: ' + objectType + ' - ' + action);
        Blob headerValue = Blob.valueof(user + ':' + pass);
        HttpRequest request = new HttpRequest();
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('X-ORGID', '5');
        request.setHeader('X-STAFF', 'true');
        request.setMethod('GET');
        request.setEndpoint(endpointUrl + objectType + '/' + action + '/' + objectId);
        System.debug('Set endpoint to ' + endpointUrl + objectType + '/' + action + '/' + objectId);
        Http http = new Http();

        HTTPResponse response = http.send(request);
        if (response.getStatusCode() >= 300) {
            System.debug(response.getBody());
            System.debug('Request was not processed');
            String emailSubject = 'SF CREATE/UPDATE ERROR: ' + objectType + ' ' + action;
            String emailBody = 'Cobwebs Error Code: ' + response.getStatusCode() + '\r\n' +
                               'Object: ' + objectType + '\r\n' +
                               'Action: ' + action + '\r\n' +
                               'Object ID: ' + objectId + '\r\n';
            CobwebsHttpCallout.sendEmail(adminEmail, emailSubject, emailBody);
            ERSyncController.saveFailedRecord(action, objectType, objectId);
        } else {
            System.debug('HTTP Request successfully sent.');
        }
        System.debug(response.getBody());
    }

    @future (callout=true)
    public static void getJiraRequest(String action, String objectType, String objectId) {
        System.debug('Entered get request: ' + objectType + ' - ' + action);
        Blob headerValue = Blob.valueof(user + ':' + pass);
        HttpRequest request = new HttpRequest();
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('X-ORGID', '5');
        request.setHeader('X-STAFF', 'true');
        request.setMethod('GET');
        request.setEndpoint(endpointUrl + 'jira/' + action + '/' + objectType + '/' + objectId);
        System.debug('Set endpoint to ' + endpointUrl + 'jira/' + action + '/' + objectType + '/' + objectId);
        Http http = new Http();

        HTTPResponse response = http.send(request);
        if (response.getStatusCode() >= 300) {
            System.debug(response.getBody());
            System.debug('Request was not processed');
            String emailSubject = 'JIRA CREATE/UPDATE ERROR: ' + objectType + ' ' + action;
            String emailBody = 'Cobwebs Error Code: ' + response.getStatusCode() + '\r\n' +
                               'Object: ' + objectType + '\r\n' +
                               'Action: ' + action + '\r\n' +
                               'Object ID: ' + objectId + '\r\n';
            CobwebsHttpCallout.sendEmail(adminEmail, emailSubject, emailBody);
            ERSyncController.saveFailedRecord(action, objectType, objectId);
        } else {
            System.debug('HTTP Request successfully sent.');
        }
        System.debug(response.getBody());
    }

    public static void sendEmail(String userEmail, String subject, String body) {
        Messaging.SingleEmailMessage mailHandler = new Messaging.SingleEmailMessage();
        if(userEmail != null){
	        String[] emailRecipient = userEmail.split(',', -1);
	        mailHandler.setToAddresses(emailRecipient);
	        mailHandler.setReplyTo('noreply@eyereturn.com');
	        mailHandler.setSubject(subject);
	        mailHandler.setPlainTextBody(body);
	        //Assign Org Wide Email Address and specify Sender
	        try{
	        	OrgWideEmailAddress orgId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =:sfAlertDispName];
	        	if(orgId != null){
	        		mailHandler.setOrgWideEmailAddressId(OrgId.Id); 
	        	}
	        }catch(Exception e){
	        	System.debug('ERROR: ' + e);
	        }        
	        Messaging.sendEmail(new Messaging.Email[] { mailHandler });
        }
    }
}