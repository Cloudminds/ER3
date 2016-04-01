@isTest
public class OpportunityExtensionTest {
    
    public static Map<String, Id> recordTypeMap {get; set;}{
        recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' ORDER BY Name]) {
            recordTypeMap.put(rt.Name,rt.Id);
        }
    }
    
    // Init the page controller without an opp
    private static OpportunityExtension initPage() {
        PageReference pageRef = Page.Opportunity_Custom;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(new Opportunity());
        return new OpportunityExtension(standardController);
    }

    // Init the page controller
    private static OpportunityExtension initPage(Opportunity opportunity) {
        PageReference pageRef = Page.Opportunity_Custom;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunity);
        return new OpportunityExtension(standardController);
    }

    // Init the page controller
    private static OpportunityExtension initPage(Opportunity opportunity, Map<String, String> getParameters) {
        PageReference pageRef = Page.Opportunity_Custom;
        for (String key : getParameters.keySet())
            pageRef.getParameters().put(key, getParameters.get(key));
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunity);
        return new OpportunityExtension(standardController);
    }

    // Fail with missing fields
    public static testMethod void SaveFailTest() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        //opportunity.Name = null;
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);
        opportunity.RecordTypeId = null ;
        opportunity.StageName= null;
        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';
        expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        Test.stopTest();

        // Assert
        //System.assertEquals(expectUrl, resultUrl);
    }

    // Save with proper fields
    public static testMethod void SaveNewSuccessTest() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);

        System.PageReference tempPage = pageController.save();
        
        pageController.saveObjectDrafts();
        pageController.saveDraft();
        pageController.testCAmount();
        pageController.removeComment() ;
        pageController.updateOppTypeDependencies();
       // pageController.refresh();
        

        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';
        expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        Test.stopTest();

        // Assert
        //System.assertEquals(expectUrl, resultUrl);
    }

    // Save existing with proper fields
    public static testMethod void SaveSuccessTest() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);
        pageController.setOriginalOpportunityDates();
        pageController.setCampaignDates();
        pageController.opportunity.Display_Budget_Change_Amount__c = 100;
        pageController.opportunity.Mobile_Budget_Change_Amount__c = 100;
        pageController.opportunity.Display_Budget_Change__c = 'Decrease';
        pageController.opportunity.Mobile_Budget_Change__c = 'Decrease';
        pageController.getAmount();
        pageController.opportunity.Display_Budget_Change__c = 'Increase';
        pageController.opportunity.Mobile_Budget_Change__c = 'Increase';
        pageController.getAmount();

        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';

        expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        Test.stopTest();

        // Assert
        //System.assertEquals(expectUrl, resultUrl);
    }

    // Save and new with proper fields
    public static testMethod void SaveAndNewSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Lead_Source__c ls = ObjectFactory.createLeadSource();
        insert ls;
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;

        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        opportunity.Client_Contact__c = contact.Id;
        opportunity.Industry__c = 'industry101';
        opportunity.Campaign_Start_Date__c = Date.today();
        opportunity.Campaign_End_Date__c = Date.today() + 1;
        opportunity.Display_Budget__c = 1;
        opportunity.Lead_Source__c = ls.Id;
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);

        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';

        expectUrl = (new PageReference('/' + ('' + pageController.opportunity.get('Id')).subString(0, 3) + '/e?')).getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        Test.stopTest();

        // Assert
        //System.assertEquals(expectUrl, resultUrl);
    }

    // Save closed won
    public static testMethod void SaveClosedWonTest() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);
        
        pageController.selectedStage = 'Closed Won';
        pageController.changeNewStageName();
        pageController.opportunity.Client_Contact__c = contact.Id;
        pageController.opportunity.Billing_Contact__c = contact.Id;
       
        System.PageReference tempPage = pageController.save();
        
        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';
        
        expectUrl = new PageReference('/apex/Campaign_Questionnaire?' + ('opportunityId=' + pageController.opportunity.get('Id'))).getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        
        Test.stopTest();

    }

    // Cancel
   public static testMethod void CancelTest() {
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
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);

        // Set assert parameters
        String resultUrl = pageController.cancel().getUrl();
        String expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        Test.stopTest();

        // Assert
        System.assertEquals(expectUrl, resultUrl);
    }

    public static testMethod void CloneTest() {
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
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        Map<String, String> getParameters = new Map<String, String>();
        getParameters.put('clone', '1');
        getParameters.put('id', '006f0000005K6Dx');
        OpportunityExtension pageController = initPage(opportunity, getParameters);

        // Set assert parameters
        Test.stopTest();
        String expect = opportunity.Name;
        String result = pageController.pageTitle;

        // Assert
        System.assertEquals(expect, result);
        System.assertEquals(true, pageController.isClone);
        System.assertEquals(null, pageController.opportunity.StageName);

    }

    public static testMethod void GetAmountTest() {
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
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);
        pageController.opportunity.Display_Budget__c = 10;
        pageController.opportunity.Mobile_Budget__c = 10;
        pageController.getAmount();

        // Set assert parameters
        Test.stopTest();
        Decimal db = pageController.opportunity.Display_Budget__c;
        Decimal mb = pageController.opportunity.Mobile_Budget__c;

        // Assert
        System.assertEquals(db + mb, pageController.opportunity.amount);
    }

    public static testMethod void CopyFromAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Employee__c salesRep = ObjectFactory.createSalesRep('Name');
        insert salesRep;
        Opportunity opportunity;
        client.Sales_Rep_eyeDemand__c = salesRep.Id;
        OpportunityExtension pageController = initPage();
        pageController.opportunity.AccountId = client.Id;
        pageController.opportunity.Type = 'eyeDemand';
        pageController.opportunity.RecordTypeId = '012i0000000tVpdAAE';
        pageController.setClient();

        Test.stopTest();
    }

    public static testMethod void SaveNewCreativeOppSuccessTest() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity = ObjectFactory.createCreativeOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        OpportunityExtension pageController = initPage(opportunity);

        System.PageReference tempPage = pageController.save();

        // Set assert parameters
        String expectUrl = '';
        String resultUrl = '';
        expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null;
        Test.stopTest();
    }   
    
    public static testMethod void SaveFailureNameException() {
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
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Opportunity opportunity1 = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity1;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        
        
        OpportunityExtension pageController = initPage(opportunity);
        pageController.setOriginalOpportunityDates();
        pageController.setCampaignDates();
        pageController.opportunity.Display_Budget_Change_Amount__c = 100;
        pageController.opportunity.Mobile_Budget_Change_Amount__c = 100;
        pageController.opportunity.Display_Budget_Change__c = 'Decrease';
        pageController.opportunity.Mobile_Budget_Change__c = 'Decrease';
        pageController.getAmount();
        pageController.opportunity.Display_Budget_Change__c = 'Increase';
        pageController.opportunity.Mobile_Budget_Change__c = 'Increase';
        pageController.getAmount();
        opportunity.AccountId = null;
        opportunity.OwnerId = null;
        opportunity.CloseDate = null;
        System.PageReference tempPage ;
        try {
            tempPage = pageController.save();     
        }
        catch (exception e) {}
        
        String expectUrl = '';
        String resultUrl = '';

        expectUrl = (new ApexPages.StandardController(opportunity)).view().getUrl();
        resultUrl = tempPage != null ? tempPage.getUrl() : null; 
        
        Test.stopTest();

    }     
      
    
   public static testMethod void SaveTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        ObjectFactory.createDefaultSalesRep();
        Account client = ObjectFactory.createCAClient('Client');
        client.Credit_App_Approved__c = true;
        client.Credit_Card__c  = true;
        insert client;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Employee__c analyst = ObjectFactory.createEmployee('Leticia', 'Kwok');
        insert analyst;
        Lead_Source__c ls = ObjectFactory.createLeadSource();
        insert ls;
        RecordType rc =[Select Name,Id,sObjectType,DeveloperName FROM RecordType WHERE Name='eyeDemand' and sObjectType = 'Opportunity'];
        Opportunity opportunity =  New Opportunity ( Name ='TestOpportunity' , StageName = 'Closed Won' ,CloseDate = system.Today().adddays(5),
                                                    RecordTypeId = rc.Id ,Lead_Source__c = ls.Id ,AccountId = client.Id ,Currency__c ='USD',Brand__c = brand.Id) ;
        insert opportunity;
        
        
        OpportunityExtension pageController = initPage(opportunity);
        pageController.opportunity.StageName =  'Closed Won' ;
       
        pageController.opportunity.RecordTypeId = rc.Id ;
        pageController.opportunity.Client_Contact__c = contact.Id;
        pageController.opportunity.Industry__c = 'industry101';
        pageController.opportunity.Campaign_Start_Date__c = Date.today();
        pageController.opportunity.Campaign_End_Date__c = Date.today() + 1;
        pageController.opportunity.Display_Budget__c = 1;
        //geController.opportunity.Lead_Source__c = ls.Id; 
        pageController.oldStage = 'Closed Lost';
        pageController.opportunity.StageName =  'Closed Won' ;
        pageController.opportunity.Billing_Contact__c = contact.Id;

        pageController.saveDraft();  
        pageController.save();    
       
       Campaign_Questionnaire__c  q = New Campaign_Questionnaire__c (To_be_Submitted__c = true ,Opportunity__c = opportunity.Id);
       Insert q;
       pageController.oldStage = 'Closed Lost';
       pageController.save(); 
       
       pageController.saveNew();
       pageController.isClientFieldEmpty = true;
       pageController.refresh();
       pageController.opportunity.StageName = 'Paused';
       pageController.save(); 
       Set<SelectOption> allAMSet=pageController.allAMSet;
       pageController.clearAllFields();       
              
       pageController.selectedRecordType='';
       pageController.opportunity.StageName=null;
       pageController.opportunity.Name=null;
       pageController.opportunity.AccountId=null;
       pageController.opportunity.OwnerId = null;
       pageController.opportunity.CloseDate = null;
       pageController.opportunity.Region__c='';
       pageController.opportunity.Currency__c='';
       pageController.selectedDisplayRep='';
       pageController.selectedMobileRep='';
       pageController.selectedAMs=null;
       pageController.checkRequiredFields(); 
       
       pageController.opportunity.Display_Budget_Change_Amount__c = 100;
       pageController.opportunity.Display_Budget_Change__c = '';
       pageController.checkRequiredFields();
       
       pageController.opportunity.Display_Budget_Change__c = '200';
       pageController.opportunity.Display_Budget_Change_Amount__c =null;
       pageController.checkRequiredFields();
       
       Test.stopTest();

    }  
}