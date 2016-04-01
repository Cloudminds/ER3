global class ERSyncController {
    public static boolean accountLock = false;
    public static boolean brandLock = false;
    public static boolean contactLock = false;
    public static boolean campaignLock = false;
    public static boolean salesRepLock = false;

    /***********************************/
    /* CREATE METHODS                  */
    /***********************************/

    webService static Boolean createOrg(String id) {
        try {
            System.debug('Create Org ER sync method called');
            upsertOrg(id);
            CobwebsHttpCallout.getRequest('create', 'org', id);
            return true;
        } finally {
            accountLock = false;
        }
    }

    webService static Boolean createBrand(String id) {
        try {
            System.debug('Create Brand ER sync method called');
            upsertBrand(id);
            CobwebsHttpCallout.getRequest('create', 'brand', id);
            return true;
        } finally {
            brandLock = false;
        }
    }

    public static void createContact(string id) {
        try {
            System.debug('Create Contact ER sync method called');
            upsertContact(id);
            CobwebsHttpCallout.getRequest('create', 'contact', id);
        } finally {
            contactLock = false;
        }
    }

    public static void createSalesRep(string id) {
        System.debug('Create Sales Rep ER sync method called');
        // If there is no previous reference to eyereturnFinance Id
        List<Employee__c> salesRepList = [select eyereturnFinance_Id__c from Employee__c where Id = :id];
        // Sales_Rep__c salesRep = [select eyereturnFinance_Id__c from Sales_Rep__c where Id = :id];
        if (salesRepList.size() == 0 || salesRepList[0].eyereturnFinance_Id__c == null || salesRepList[0].eyereturnFinance_Id__c == 0) {
            CobwebsHttpCallout.getRequest('create', 'salesrep', id);
        }
    }

    webService static String createCampaign(String id) {
        try {
            System.debug('Create Campaign ER sync method called');
            // Verify Campaign Questionnaire exists
            if (!campaignQuestionnaireExists(id)) {
                return 'Campaign questionnaire has not been completed';
            }
            CobwebsHttpCallout.getRequest('create', 'campaign', id);
            return 'true';
        } finally {
            campaignLock = false;
        }
    }

    webService static String createJiraIssue(String objectType, String recordId) {
        try {
            System.debug('Create JIRA issue method called');
            CobwebsHttpCallout.getJiraRequest('create', objectType, recordId);
            return 'true';
        } finally {
            campaignLock = false;
        }
    }

    private static boolean campaignQuestionnaireExists(String id) {
        List<Campaign_Questionnaire__c> questionnaires = [select Id from Campaign_Questionnaire__c where Opportunity__c = :id];
        return questionnaires.size() > 0;
    }

    /***********************************/
    /* UPDATE METHODS                  */
    /***********************************/

    webService static Boolean updateOrg(String id) {
        try {
            System.debug('Update Org ER sync method called');
            upsertOrg(id);
            CobwebsHttpCallout.getRequest('update', 'org', id);
            return true;
        } finally {
            accountLock = false;
        }
    }

    webService static Boolean updateBrand(String id) {
        try {
            System.debug('Update Brand ER sync method called');
            upsertBrand(id);
            CobwebsHttpCallout.getRequest('update', 'brand', id);
            return true;
        } finally {
            brandLock = false;
        }
    }

    public static void updateContact(string id) {
        try {
            System.debug('Update Contact ER sync method called');
            upsertContact(id);
            CobwebsHttpCallout.getRequest('update', 'contact', id);
        } finally {
            contactLock = false;
        }
    }

    public static void updateCampaign(string id) {
        System.debug('Update Campaign ER sync method called');
        CobwebsHttpCallout.getRequest('update', 'campaign', id);
    }

    /***********************************/
    /* NOTIFICATION METHODS            */
    /***********************************/

    public static void emailNewCampaignQuestionnaire(string id) {
        System.debug('Email Campaign Questionnaire create ER sync method called');
        String traffickerRecipients = (String) Cobwebs_Settings__c.getInstance().campaign_questionnaire_traffickers__c;
        Campaign_Questionnaire__c campaignQuestionnaire = [select Id, Opportunity__c, Budget_Priority__c, Campaign_s_Main_Goal__c, Campaign_Goal__c, Geotarget__c, Campaign_Extension__c, Flights__c, Ad_formats__c, Facebook__c, Facebook_Followup__c, Site_re_targeting__c, Site_re_targeting_Followup__c, Search_re_targeting__c, Search_re_targeting_Followup__c, Behavioural_Targeting__c, comScore__c, Custom_Integrations__c, Custom_Integrations_Followup__c, Deal_ID__c, Deal_ID_Followup__c, eyeVerify__c, Geo_fencing__c, Geo_fencing_Followup__c, Geo_fencing_Followup_2__c, Geo_fencing_Followup_3__c, Multiple_Creatives__c, Notes__c, Third_Party__c, Web_Mobile__c, File_Path__c, Site_re_targeting_Followup_2__c, Whitelist_Or_Verticals__c from Campaign_Questionnaire__c where Id = :id][0];
        Opportunity opportunity = [select Id, SF_IOID__c, Name from Opportunity where Id = :campaignQuestionnaire.Opportunity__c][0];
        String subject = 'NEW Campaign Questionnaire for ' + opportunity.Name + ' SF_IOID ' + opportunity.SF_IOID__c;
        String body = getCampaignQuestionnaireInfo(campaignQuestionnaire);
        CobwebsHttpCallout.sendEmail(traffickerRecipients, subject, body);
    }

    public static void emailUpdateCampaignQuestionnaire(string id) {
        System.debug('Email Campaign Questionnaire update ER sync method called');
        String traffickerRecipients = (String) Cobwebs_Settings__c.getInstance().campaign_questionnaire_traffickers__c;
        Campaign_Questionnaire__c campaignQuestionnaire = [select Id, Opportunity__c, Budget_Priority__c, Campaign_s_Main_Goal__c, Campaign_Goal__c, Geotarget__c, Campaign_Extension__c, Flights__c, Ad_formats__c, Facebook__c, Facebook_Followup__c, Site_re_targeting__c, Site_re_targeting_Followup__c, Search_re_targeting__c, Search_re_targeting_Followup__c, Behavioural_Targeting__c, comScore__c, Custom_Integrations__c, Custom_Integrations_Followup__c, Deal_ID__c, Deal_ID_Followup__c, eyeVerify__c, Geo_fencing__c, Geo_fencing_Followup__c, Geo_fencing_Followup_2__c, Geo_fencing_Followup_3__c, Multiple_Creatives__c, Notes__c, Third_Party__c, Web_Mobile__c, File_Path__c, Site_re_targeting_Followup_2__c, Whitelist_Or_Verticals__c from Campaign_Questionnaire__c where Id = :id][0];
        Opportunity opportunity = [select Id, SF_IOID__c, Name from Opportunity where Id = :campaignQuestionnaire.Opportunity__c][0];
        String subject = 'UPDATED Campaign Questionnaire for ' + opportunity.Name + ' SF_IOID ' + opportunity.SF_IOID__c;
        String body = getCampaignQuestionnaireInfo(campaignQuestionnaire);
        CobwebsHttpCallout.sendEmail(traffickerRecipients, subject, body);
    }

    /***********************************/
    /* HELPER METHODS                  */
    /***********************************/

    public static void closedWonCampaign(String id) {
        System.debug('Closed Won Campaign ER sync method called');
        CobwebsHttpCallout.getRequest('closed', 'campaign', id);
    }

    public static void easeOrg(String id) {
        System.debug('Easing Org - call from DB');
        Account account = [select IsAPI__c from Account where Id=:id][0];
        account.IsAPI__c = false;
        upsert(account);
        accountLock = false;
    }

    public static void easeBrand(String id) {
        System.debug('Easing Brand - call from DB');
        Brand__c brand = [select IsAPI__c from Brand__c where Id=:id][0];
        brand.IsAPI__c = false;
        upsert(brand);
        brandLock = false;
    }

    public static void easeContact(string id) {
        System.debug('Easing Contact - call from DB');
        Contact contact = [select IsAPI__c from Contact where Id=:id][0];
        contact.IsAPI__c = false;
        upsert(contact);
        contactLock = false;
    }

    public static void deleteContact(string id) {
        System.debug('Delete Contact ER sync method called');
        CobwebsHttpCallout.getRequest('delete', 'contact', id);
    }

    public static String getCampaignQuestionnaireInfo(Campaign_Questionnaire__c campaignQuestionnaire) {
        String body = '';
        body += '1) Budget: Which is higher priority for the client?\n';
        body += campaignQuestionnaire.Budget_Priority__c;
        body += '\n\n';
        body += '2) Campaign Goal: What is the campaign\'s main goal?\n';
        body += campaignQuestionnaire.Campaign_s_Main_Goal__c;
        body += '\n\n';
        body += '3) Is the campaign 3rd party ad served?\n';
        body += campaignQuestionnaire.Third_Party__c;
        body += '\n\n';
        body += '4) Campaign Goal: Is the campaign optimization goal flexible? i.e Will client be happy with results as long as the campaign is showing improvement towards the goal?\n';
        body += campaignQuestionnaire.Campaign_Goal__c;
        body += '\n\n';
        body += '5) Geotarget: Is the client flexible about geo-target locations? i.e. Can we open the geo-target area if the campaign is not hitting optimization goal or spend goal?\n';
        body += campaignQuestionnaire.Geotarget__c;
        body += '\n\n';
        body += '6) Campaign Extension: Can the campaign be extended if needed?\n';
        body += campaignQuestionnaire.Campaign_Extension__c;
        body += '\n\n';
        body += '7) Flights: If the campaign has flights, can the unused budget from one flight be shifted to the next flight?\n';
        body += campaignQuestionnaire.Flights__c;
        body += '\n\n';
        body += '8) Ad formats: Can the client provide or create other ad formats if the certain ones are not working for the campaign?\n';
        body += campaignQuestionnaire.Ad_formats__c;
        body += '\n\n';
        body += '9) Creatives: If there are multiple creative messages, are they to be rotated on one tag?\n';
        body += campaignQuestionnaire.Multiple_Creatives__c;
        body += '\n\n';
        body += '10) Standard Banners: Can we serve standard banners to Web Mobile?\n';
        body += campaignQuestionnaire.Web_Mobile__c;
        body += '\n\n';
        body += '11) Facebook: If this is a Facebook News Feed campaign, then has the client added eyeDemand as an advertiser/admin on their Facebook page? (See file: "FBX Slides - Newsfeed - Specs and Process Manual" for info)\n';
        body += campaignQuestionnaire.Facebook_Followup__c;
        body += '\n\n';
        body += '12) Site re-targeting: Does the campaign have site re-targeting?\n';
        body += campaignQuestionnaire.Site_re_targeting__c;
        body += '\n\n';
        body += '12 a) Site re-targeting: Have we received site pages for re-targeting?\n';
        body += campaignQuestionnaire.Site_re_targeting_Followup__c;
        body += '\n\n';
        body += '12 b) Site re-targeting: Has the site already been tagged from a previous campaign?\n';
        body += campaignQuestionnaire.Site_re_targeting_Followup_2__c;
        body += '\n\n';
        body += '13) (Canada only) Search re-targeting: Does the campaign have search re-targeting?\n';
        body += campaignQuestionnaire.Search_re_targeting__c;
        body += '\n\n';
        body += '13 a) Search re-targeting: Have we received the search keywords?\n';
        body += campaignQuestionnaire.Search_re_targeting_Followup__c;
        body += '\n\n';
        body += '14) Behavioural Targeting: Is the client flexible about bSeg targeting? Can we target alikes?\n';
        body += campaignQuestionnaire.Behavioural_Targeting__c;
        body += '\n\n';
        body += '15) Whitelist/Verticals: If the campaign is running off a whitelist or verticals, can we add to the domain list if the campaign is not hitting the optimization goal or spending goals?\n';
        body += campaignQuestionnaire.Whitelist_Or_Verticals__c;
        body += '\n\n';
        body += '16) Geo-fencing: Does the campaign have geo-fencing?\n';
        body += campaignQuestionnaire.Geo_fencing__c;
        body += '\n\n';
        body += '16 a) Is the Geo-fence Worksheet completed?\n';
        body += campaignQuestionnaire.Geo_fencing_Followup__c;
        body += '\n\n';
        body += '16 b) Have they provided the latitude + longitudes and radius to geo-fence by?\n';
        body += campaignQuestionnaire.Geo_fencing_Followup_2__c;
        body += '\n\n';
        body += '16 c) If there is little inventory available, is the client ok with expanding outside the geo-fenced area (increasing the radius, or targeting the entire city)?\n';
        body += campaignQuestionnaire.Geo_fencing_Followup_3__c;
        body += '\n\n';
        body += '17) Deal ID: Is the campaign running with Deal ID(s)?\n';
        body += campaignQuestionnaire.Deal_ID__c;
        body += '\n\n';
        body += '17 a) Have we received all the assets and information required to run the campaign (IDs, publishers/sellers, floor prices, etc.)?\n';
        body += campaignQuestionnaire.Deal_ID_Followup__c;
        body += '\n\n';
        body += '18) Custom Integrations: Are there any custom integrations involved (weather, gas, new, stock prices, social media integrations)?\n';
        body += campaignQuestionnaire.Custom_Integrations__c;
        body += '\n\n';
        body += '18 a) Have analysts and tech been made aware of the campaign and testing to make sure we can successfully integrate into the necessary sources?\n';
        body += campaignQuestionnaire.Custom_Integrations_Followup__c;
        body += '\n\n';
        body += '19) comScore: Will comScore be layered onto the campaign?\n';
        body += campaignQuestionnaire.comScore__c;
        body += '\n\n';
        body += '20) eyeVerify: Will eyeVerify be layered onto the campaign?\n';
        body += campaignQuestionnaire.eyeVerify__c;
        body += '\n\n';
        body += '21) Notes:\n';
        body += campaignQuestionnaire.Notes__c;
        body += '\n\n';
        body += '22) File path:\n';
        body += campaignQuestionnaire.File_Path__c;
        body += '\n\n';
        return body;
    }

    /***********************************/
    /* VALIDATION METHODS              */
    /***********************************/

    public static void validateContact(Contact currentContact) {
        System.debug('Validate Contact method called');
        string email = currentContact.email;
        Contact[] contacts = [select Id from Contact where Email=:email];
        for (Contact contact : contacts) {
            if (contact.Id != currentContact.Id) {
                System.debug('Failed to validate Contact: Email address already exists');
                currentContact.addError('Email address already exists');
            }
        }
    }

    public static void validateBrand(Brand__c currentBrand) {
        System.debug('ERSyncController: validateBrand called');
        string name = currentBrand.name;
        Brand__c[] brands = [select Id from Brand__c where Name = :name];
        for (Brand__c brand : brands) {
            if (brand.Id != currentBrand.Id) {
                System.debug ('Failed to validate Brand: Name already exists');
                currentBrand.addError('Name already exists');
            }
        }
    }

    /***********************************/
    /* UPSERT METHODS                  */
    /***********************************/

    public static void upsertOrg(string id) {
        System.debug('Upserting account ' + id);
        List<Account> accountQuery = [select Name, Out_of_Sync__c from Account where Id=:id]; 
        if(accountQuery != null && accountQuery.size() > 0){
            Account account = accountQuery[0];
            account.Out_of_Sync__c = true;
            upsert(account);
        }
    }

    public static void upsertBrand(string id) {
        System.debug('Upserting brand ' + id);
    }

    private static void upsertContact(string id) {
        System.debug('Upserting contact ' + id);
        Contact contact = [select Name, Out_of_Sync__c from Contact where Id=:id][0];
        contact.Out_of_Sync__c = true;
        upsert(contact);
    }

    /***********************************/
    /* BATCH SYNC METHODS              */
    /***********************************/

    public static void saveFailedRecord(String action, String type, String id) {
        System.debug('Sync\'ing failed for record: ' + id);

        List<Unprocessed_Record__c> urList = Database.query('SELECT Id FROM Unprocessed_Record__c WHERE Record_Id__c = \'' + id + '\' AND Processed__c = false');

        if(urList.isEmpty()){
            Unprocessed_Record__c unprocRec = new Unprocessed_Record__c(
               Object_Type__c = type.toUpperCase(),
               Processed__c = false,
               Record_Id__c = id,
               Action__c = action.toUpperCase(),
               Timestamp__c = Datetime.now()
            );
            insert(unprocRec);
        }else{
            for(Unprocessed_Record__c rec : urList){
                rec.Timestamp__c = Datetime.now();
                rec.Action__c = action.toUpperCase();
                rec.Processed__c = true;
            }
            update(urList);
        }
    }

    public static void updateFailedRecord(String action, String type, String id) {
        System.debug('Updating failed record to successful: ' + id);

        List<Unprocessed_Record__c> urList = Database.query('SELECT Id FROM Unprocessed_Record__c WHERE Record_Id__c = \'' + id + '\' AND Last_Status__c = \'Failed\'');

        if(!urList.isEmpty()){
            for(Unprocessed_Record__c rec : urList){
                rec.Timestamp__c = Datetime.now();
                rec.Action__c = action.toUpperCase();
                rec.Last_Status__c = 'Success';
            }
            update(urList);
        }
    }
}