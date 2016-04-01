@isTest
public class CampaignQuestionnaireExtensionTest {

    // Init the page controller
    private static OpportunityExtension initPage(Opportunity opportunity) {
        PageReference pageRef = Page.Opportunity_Custom;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunity);
        return new OpportunityExtension(standardController);
    }

    private static Campaign_Questionnaire__c createCampaignQuestionnaire() {
        Campaign_Questionnaire__c campaignQuestionnaire = new Campaign_Questionnaire__c();
        return campaignQuestionnaire;
    }

    // Init the page controller
    private static CampaignQuestionnaireExtension initPage(Campaign_Questionnaire__c campaignQuestionnaire, String opportunityId) {
        PageReference pageRef = Page.Campaign_Questionnaire;
        pageRef.getParameters().put('opportunityId', opportunityId);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(campaignQuestionnaire);
        return new CampaignQuestionnaireExtension(standardController);
    }

    // Init the page controller
    private static CampaignQuestionnaireExtension initPage(Campaign_Questionnaire__c campaignQuestionnaire) {
        PageReference pageRef = Page.Campaign_Questionnaire;
        pageRef.getParameters().put('id', campaignQuestionnaire.Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(campaignQuestionnaire);
        return new CampaignQuestionnaireExtension(standardController);
    }

    public static testMethod void createTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Employee__c employee = ObjectFactory.createEmployee('Name');
        employee.Sales_Rep__c = true;
        insert employee;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opp Name');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);
        pageController.opportunity = opportunity;
        //pageController.selectedAnalyst = employee.Id;
        pageController.selectedTrafficker = employee.Id;
        pageController.selectedDisplayRep = employee.Id;
        pageController.selectedMobileRep = employee.Id;
        pageController.opportunity.Client_Contact__c = contact.Id;
        pageController.opportunity.Billing_Contact__c = contact.Id;
        pageController.selectedStage = 'Closed Won';
        pageController.oldStage = 'RFP/Proposal';
        pageController.changeNewStageName();

        // Set assert parameters
        System.PageReference saveTempPage = pageController != null ? pageController.save() : null;

        if(saveTempPage != null){
            String saveResultUrl = saveTempPage.getUrl();
            String saveExpectUrl = new PageReference('/apex/Campaign_Questionnaire?' + ('opportunityId=' + pageController.opportunity.get('Id'))).getUrl();
            Test.stopTest();

            // Assert
            System.assertEquals(saveExpectUrl, saveResultUrl);
        }
    }

    public static testMethod void emailTest() {Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opp Name');
        insert opportunity;
        Campaign_Questionnaire__c campaignQuestionnaire = createCampaignQuestionnaire();
        campaignQuestionnaire.Opportunity__c = opportunity.Id;
        insert campaignQuestionnaire;
        CampaignQuestionnaireExtension campaignQuestionnaireExtension = initPage(CampaignQuestionnaire, opportunity.Id);
        campaignQuestionnaireExtension.campaignGoal = 'true';
        campaignQuestionnaireExtension.save();

        ERSyncController.emailNewCampaignQuestionnaire(campaignQuestionnaire.Id);
        ERSyncController.emailUpdateCampaignQuestionnaire(campaignQuestionnaire.Id);

        Test.stopTest();
    }


    public static testMethod void openExistingTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opp Name');
        insert opportunity;
        Campaign_Questionnaire__c campaignQuestionnaire = createCampaignQuestionnaire();
        campaignQuestionnaire.Opportunity__c = opportunity.Id;
        insert campaignQuestionnaire;
        CampaignQuestionnaireExtension campaignQuestionnaireExtension = initPage(CampaignQuestionnaire, opportunity.Id);
        campaignQuestionnaireExtension.campaignGoal = 'true';
        campaignQuestionnaireExtension.save();
        campaignQuestionnaireExtension.cancel();
        campaignQuestionnaireExtension.updateValues();

        Campaign_Questionnaire__c campaignQuestionnaireLoad = campaignQuestionnaire;//campaignQuestionnaireExtension.questionnaire;
        CampaignQuestionnaireExtension campaignQuestionnaireExtensionLoad = initPage(campaignQuestionnaireLoad);

        // Set assert parameters
        // String expectUrl = '';
        Test.stopTest();

        // Assert
        // System.assertEquals(1, 1);
    }

}