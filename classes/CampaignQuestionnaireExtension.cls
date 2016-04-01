public class CampaignQuestionnaireExtension {
    private ApexPages.StandardController m_sc;
    private String id = (String) ApexPages.currentPage().getParameters().get('id');
    private String opportunityId = (String) ApexPages.currentPage().getParameters().get('opportunityId');
    private String retUrl = (String) ApexPages.currentPage().getParameters().get('retUrl');
    private Boolean legit = true;
    public Opportunity opportunity { get; set; }
    public Campaign_Questionnaire__c questionnaire { get; set; }
    public List<SelectOption> budgetSelectOptions { get; set; }
    public List<SelectOption> booleanSelectOptions { get; set; }
    public List<SelectOption> campaignGoalSelectOptions { get; set; }
    public List<SelectOption> pacingSelectOptions { get; set; }
    public String campaignPriorityCheckbox {get; set;}
    public String campaignPriority { get; set; }
    public String budgetPriority { get; set; }
    public String campaignMainGoal {get; set; }
    public String thirdParty { get; set; }
    public String billingImpressions { get; set; }
    public String billingFixedCPMs { get; set; }
    public String pacingOptions { get; set; }
    public String campaignGoal { get; set; }
    public String geotarget { get; set; }
    public String campaignExtension { get; set; }
    public String flights { get; set; }
    public String adFormats { get; set; }
    public String facebookFollowup { get; set; }
    public String siteRetargeting { get; set; }
    public String siteRetargetingFollowup1 { get; set; }
    public String siteRetargetingFollowup2 { get; set; }
    public String searchRetargeting { get; set; }
    public String searchRetargetingFollowup { get; set; }
    public String behaviouralTargeting { get; set; }
    public String comScore { get; set; }
    public String customIntegrations { get; set; }
    public String customIntegrationsFollowup { get; set; }
    public String dealID { get; set; }
    public String dealIDFollowup { get; set; }
    public String eyeVerify { get; set; }
    public String whitelistOrVerticals { get; set; }
    public String geofencing { get; set; }
    public String geofencingFollowup1 { get; set; }
    public String geofencingFollowup2 { get; set; }
    public String geofencingFollowup3 { get; set; }
    public String multipleCreatives { get; set; }
    public String notes { get; set; }
    public String webMobile { get; set; }
    public String filePath { get; set; }

    public CampaignQuestionnaireExtension(ApexPages.StandardController stdController) {

        m_sc = stdController;
        budgetSelectOptions = new List<SelectOption>();
        booleanSelectOptions = new List<SelectOption>();
        campaignGoalSelectOptions = new List<SelectOption>();
        pacingSelectOptions = new List<SelectOption>();
        setSelectOptions();
        if (id != null) {
            questionnaire = [select Opportunity__c, Opportunity__r.StageName, To_be_Submitted__c, Campaign_Priority_Checkbox__c, Campaign_Priority__c, Budget_Priority__c, Campaign_s_Main_Goal__c, Third_Party__c, Billing_Impression_Nmbers__c, Billing_Fixed_CPMs__c, Pacing_Spend_vs_Impressions__c, Campaign_Goal__c, Geotarget__c, Campaign_Extension__c, Flights__c, Ad_formats__c, Facebook_Followup__c, Site_re_targeting__c, Site_re_targeting_Followup__c, Site_re_targeting_Followup_2__c, Search_re_targeting__c, Search_re_targeting_Followup__c, Behavioural_Targeting__c, comScore__c, Custom_Integrations__c, Custom_Integrations_Followup__c, Deal_ID__c, Deal_ID_Followup__c, eyeVerify__c, Whitelist_Or_Verticals__c, Geo_fencing__c, Geo_fencing_Followup__c, Geo_fencing_Followup_2__c, Geo_fencing_Followup_3__c, Multiple_Creatives__c, Notes__c, Web_Mobile__c, File_Path__c from Campaign_Questionnaire__c where Id = :id];
            opportunity = [select Name, High_Priority_Checkbox__c from Opportunity where Id = :questionnaire.Opportunity__c];

            if(questionnaire.Opportunity__r.StageName != 'Closed Won')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This questionnaire has not yet been submitted. The opportunity must be closed won before it can be submitted.'));
            else{
                if(questionnaire.To_be_Submitted__c)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This questionnaire will be submitted upon save. No changes are allowed after the submission.'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This questionnaire has been submitted.'));
            }
            campaignPriorityCheckbox = questionnaire.Campaign_Priority_Checkbox__c ? 'true' : 'false';
            campaignPriority = questionnaire.Campaign_Priority__c;
            budgetPriority = questionnaire.Budget_Priority__c;
            campaignMainGoal = questionnaire.Campaign_s_Main_Goal__c;
            campaignGoal = questionnaire.Campaign_Goal__c ? 'true' : 'false';
            thirdParty = questionnaire.Third_Party__c ? 'true' : 'false';
            billingImpressions = questionnaire.Billing_Impression_Nmbers__c ? 'true' : 'false';
            billingFixedCPMs = questionnaire.Billing_Fixed_CPMs__c ? 'true' : 'false';
            pacingOptions = questionnaire.Pacing_Spend_vs_Impressions__c;
            geotarget = questionnaire.Geotarget__c ? 'true' : 'false';
            campaignExtension = questionnaire.Campaign_Extension__c ? 'true' : 'false';
            flights = questionnaire.Flights__c ? 'true' : 'false';
            adFormats = questionnaire.Ad_formats__c ? 'true' : 'false';
            facebookFollowup = questionnaire.Facebook_Followup__c ? 'true' : 'false';
            siteRetargeting = questionnaire.Site_re_targeting__c ? 'true' : 'false';
            siteRetargetingFollowup1 = questionnaire.Site_re_targeting_Followup__c ? 'true' : 'false';
            siteRetargetingFollowup2 = questionnaire.Site_re_targeting_Followup_2__c ? 'true' : 'false';
            searchRetargeting = questionnaire.Search_re_targeting__c ? 'true' : 'false';
            searchRetargetingFollowup  = questionnaire.Search_re_targeting_Followup__c ? 'true' : 'false';
            behaviouralTargeting = questionnaire.Behavioural_Targeting__c ? 'true' : 'false';
            comScore = questionnaire.comScore__c ? 'true' : 'false';
            customIntegrations = questionnaire.Custom_Integrations__c ? 'true' : 'false';
            customIntegrationsFollowup = questionnaire.Custom_Integrations_Followup__c ? 'true' : 'false';
            dealID = questionnaire.Deal_ID__c ? 'true' : 'false';
            dealIDFollowup = questionnaire.Deal_ID_Followup__c ? 'true' : 'false';
            eyeVerify = questionnaire.eyeVerify__c ? 'true' : 'false';
            whitelistOrVerticals = questionnaire.Whitelist_Or_Verticals__c ? 'true' : 'false';
            geofencing = questionnaire.Geo_fencing__c ? 'true' : 'false';
            geofencingFollowup1 = questionnaire.Geo_fencing_Followup__c ? 'true' : 'false';
            geofencingFollowup2 = questionnaire.Geo_fencing_Followup_2__c ? 'true' : 'false';
            geofencingFollowup3 = questionnaire.Geo_fencing_Followup_3__c ? 'true' : 'false';
            multipleCreatives = questionnaire.Multiple_Creatives__c ? 'true' : 'false';
            webMobile = questionnaire.Web_Mobile__c ? 'true' : 'false';
            notes = questionnaire.Notes__c;
            filePath = questionnaire.File_Path__c;
        } else if (opportunityId != null) {
            opportunity = [select Name, StageName from Opportunity where Id = :opportunityId];
            questionnaire = new Campaign_Questionnaire__c();
            questionnaire.Name = (opportunity.Name).length() > 65 ? (opportunity.Name).substring(0,65) + ' questionnaire' : opportunity.Name + ' questionnaire';    
            questionnaire.Opportunity__c = opportunityId;
            budgetSelectOptions = new List<SelectOption>();
            booleanSelectOptions = new List<SelectOption>();
            campaignGoalSelectOptions = new List<SelectOption>();
            pacingSelectOptions = new List<SelectOption>();
            setSelectOptions();
        } else {
            GeneralException generalException  = new GeneralException();
            generalException.setMessage('Opportunity is not Closed Won or doesn\'t exist.');
            ApexPages.addMessages(generalException);
        }
    }

    public CampaignQuestionnaireExtension() {
        questionnaire = new Campaign_Questionnaire__c();
        opportunity = [select Name from Opportunity where Id = :opportunityId];
        questionnaire.Name = (opportunity.Name).length() > 65 ? (opportunity.Name).substring(0,65) + ' questionnaire' : opportunity.Name + ' questionnaire';    
        questionnaire.Opportunity__c = opportunityId;
        budgetSelectOptions = new List<SelectOption>();
        booleanSelectOptions = new List<SelectOption>();
        campaignGoalSelectOptions = new List<SelectOption>();
        pacingSelectOptions = new List<SelectOption>();
        setSelectOptions();
    }

    public PageReference save() {
        if (id == null && opportunityId == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'This Campaign Questionnaire needs to be created from a linked Opportunity.'));
            return null;
            //return new PageReference(retUrl);
        }
        else{ //Only 1 campaign questionnaire is allowed per opportunity
            Integer numOfQuestionnairesList = [SELECT count() FROM Campaign_Questionnaire__c WHERE Opportunity__c =: opportunityId];
            if(numOfQuestionnairesList >= 1){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'A Campaign Questionnaire for this Opportunity has already been created. Please delete or modify the existing record.'));
                return null;
            }
        }

        Boolean isValid = true;
        if(campaignPriorityCheckbox == null || campaignPriorityCheckbox == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 1'));
            isValid = false;
        }
        
        if((campaignPriorityCheckbox == 'true') && (campaignPriority == null || campaignPriority == '')){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Provide a Reason to Question 1'));
            isValid = false;
        }

        if(budgetPriority == null || budgetPriority == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 2'));
            isValid = false;
        }

        if(campaignMainGoal == null || campaignMainGoal == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 3'));
            isValid = false;
        }

        if(thirdParty == null || thirdParty == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 4'));
            isValid = false;
        }

        if(billingImpressions == null || billingImpressions == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 5'));
            isValid = false;
        }

        if(billingFixedCPMs == null || billingFixedCPMs == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 6'));
            isValid = false;
        }

        if(pacingOptions == null || pacingOptions == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 7'));
            isValid = false;
        }

        if(siteRetargeting == null || siteRetargeting == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 16'));
            isValid = false;
        } else if (siteRetargeting != null && siteRetargeting == 'true'){
            if(siteRetargetingFollowup1 == null || siteRetargetingFollowup1 == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 16 a'));
                isValid = false;
            }
            if(siteRetargetingFollowup2 == null || siteRetargetingFollowup2 == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 16 b'));
                isValid = false;
            }
        }

        if(searchRetargeting == null || searchRetargeting == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 17'));
            isValid = false;
        } else if (searchRetargeting != null && searchRetargeting == 'true'){
            if(searchRetargetingFollowup == null || searchRetargetingFollowup == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 17 a'));
                isValid = false;
            }
        }

        if(dealID == null || dealID == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 21'));
            isValid = false;
        } else if (dealID != null && dealID == 'true'){
            if(dealIDFollowup == null || dealIDFollowup == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 21 a'));
                isValid = false;
            }
        }

        if(customIntegrations == null || customIntegrations == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 22'));
            isValid = false;
        } else if (customIntegrations != null && customIntegrations == 'true'){
            if(customIntegrationsFollowup == null || customIntegrationsFollowup == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 22 a'));
                isValid = false;
            }
        }

        if(comScore == null || comScore == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select Answer to Question 23'));
            isValid = false;
        }

        if(filePath == null || filePath == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Enter File Path in Question 26'));
            isValid = false;
        }

        if(!isValid)
            return null;
        else{
            updateValues();
            markHighPriority();
            upsert questionnaire;

            // Anytime the campaign questionnaire is edited, update the PDF attachment
            addPdfAttachment();

            return (new ApexPages.StandardController(opportunity)).view();
        }
    }

    public void markHighPriority() {
        if (campaignPriorityCheckbox == 'true')
            opportunity.High_Priority_Checkbox__c = TRUE;
        else
            opportunity.High_Priority_Checkbox__c = FALSE;
        update opportunity;
    }

    // Add Campaign Questionaire as a PDF attachment to the parent Opportunity
    public void addPdfAttachment() {
        // If there is no Campaign Questionnaire PDF attachment, create
        String questionnairePdfName = questionnaire.Opportunity__c + '-campaignQuestionnairePDF.pdf';
        List<Attachment> questionnairePdfAttachmentList = [select Body from Attachment where ParentId = :questionnaire.Opportunity__c and Name = :questionnairePdfName];
        PageReference questionnairePdf = createPdf();
        Blob questionnairePdfPageBlob = questionnairePdf.getContentAsPDF();
        if (questionnairePdfAttachmentList.size() == 0) {
            Attachment questionnairePdfAttachment = new Attachment();
            questionnairePdfAttachment.ParentId = questionnaire.Opportunity__c;
            questionnairePdfAttachment.Name = questionnairePdfName;
            questionnairePdfAttachment.Body = questionnairePdfPageBlob;
            insert questionnairePdfAttachment;
        }
        // If an attachment exists under the Opportunity ID, update
        else {
            Attachment questionnairePdfAttachment = questionnairePdfAttachmentList[0];
            questionnairePdfAttachment.Body = questionnairePdfPageBlob;
            update questionnairePdfAttachment;
        }
    }

    public PageReference cancel() {
        if (id == null && opportunityId == null)
            return new PageReference(retUrl);
        else
            return (new ApexPages.StandardController(opportunity)).view();
    }

    public PageReference createPdf() {
        PageReference pageRef = new PageReference('/apex/Campaign_Questionnaire_PDF');
        pageRef.getParameters().put('id', id);
        return pageRef;
    }

    private void setSelectOptions() {
        booleanSelectOptions.add(new SelectOption('true', 'Yes'));
        booleanSelectOptions.add(new SelectOption('false', 'No'));

        // Set budget picklist values
        Schema.DescribeFieldResult fieldResult = Campaign_Questionnaire__c.Budget_Priority__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry picklistValue : picklistValues) {
            budgetSelectOptions.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
        }

        // Set campaign goal picklist values
        Schema.DescribeFieldResult campaignMainGoalFieldResult = Campaign_Questionnaire__c.Campaign_s_Main_Goal__c.getDescribe();
        List<Schema.PicklistEntry> campGoalPicklistValues = campaignMainGoalFieldResult.getPicklistValues();

        for (Schema.PicklistEntry campGoalPicklistValue : campGoalPicklistValues) {
            campaignGoalSelectOptions.add(new SelectOption(campGoalPicklistValue.getLabel(), campGoalPicklistValue.getValue()));
        }

        // Set campaign pacing picklist values
        Schema.DescribeFieldResult campaignPacingFieldResult = Campaign_Questionnaire__c.Pacing_Spend_vs_Impressions__c.getDescribe();
        List<Schema.PicklistEntry> campPacingPicklistValues = campaignPacingFieldResult.getPicklistValues();

        for (Schema.PicklistEntry campPacingPicklistValue : campPacingPicklistValues) {
            pacingSelectOptions.add(new SelectOption(campPacingPicklistValue.getLabel(), campPacingPicklistValue.getValue()));
        }
    }

    @TestVisible private void updateValues() {
        //System.debug(budgetPriority);
        questionnaire.Campaign_Priority_Checkbox__c = (campaignPriorityCheckbox == 'true');
        questionnaire.Campaign_Priority__c = campaignPriority;
        questionnaire.Budget_Priority__c = budgetPriority;
        questionnaire.Campaign_s_Main_Goal__c = campaignMainGoal;
        questionnaire.Third_Party__c = (thirdParty == 'true');
        questionnaire.Billing_Impression_Nmbers__c = (billingImpressions == 'true');
        questionnaire.Billing_Fixed_CPMs__c = (billingFixedCPMs == 'true');
        questionnaire.Pacing_Spend_vs_Impressions__c = pacingOptions;
        questionnaire.Campaign_Goal__c = (campaignGoal == 'true');
        questionnaire.Geotarget__c = (geotarget == 'true');
        questionnaire.Campaign_Extension__c = (campaignExtension == 'true');
        questionnaire.Flights__c = (flights == 'true');
        questionnaire.Ad_formats__c = (adFormats == 'true');
        questionnaire.Multiple_Creatives__c = (multipleCreatives == 'true');
        questionnaire.Web_Mobile__c = (webMobile == 'true');
        questionnaire.Facebook_Followup__c = (facebookFollowup == 'true');
        questionnaire.Site_re_targeting__c = (siteRetargeting == 'true');
        questionnaire.Site_re_targeting_Followup__c = (siteRetargetingFollowup1  == 'true');
        questionnaire.Site_re_targeting_Followup_2__c = (siteRetargetingFollowup2  == 'true');
        questionnaire.Search_re_targeting__c = (searchRetargeting == 'true');
        questionnaire.Search_re_targeting_Followup__c = (searchRetargetingFollowup  == 'true');
        questionnaire.Behavioural_Targeting__c = (behaviouralTargeting == 'true');
        questionnaire.Whitelist_Or_Verticals__c = (whitelistOrVerticals == 'true');
        questionnaire.Geo_fencing__c = (geofencing == 'true');
        questionnaire.Geo_fencing_Followup__c = (geofencingFollowup1 == 'true');
        questionnaire.Geo_fencing_Followup_2__c = (geofencingFollowup2 == 'true');
        questionnaire.Geo_fencing_Followup_3__c = (geofencingFollowup3 == 'true');
        questionnaire.Deal_ID__c = (dealID == 'true');
        questionnaire.Deal_ID_Followup__c = (dealIDFollowup == 'true');
        questionnaire.Custom_Integrations__c = (customIntegrations == 'true');
        questionnaire.Custom_Integrations_Followup__c = (customIntegrationsFollowup == 'true');
        questionnaire.comScore__c = (comScore == 'true');
        questionnaire.eyeVerify__c = (eyeVerify == 'true');
        questionnaire.Notes__c = notes;
        questionnaire.File_Path__c = filePath;
        questionnaire.To_be_Submitted__c = false;
    }
}