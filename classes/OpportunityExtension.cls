public class OpportunityExtension {

    // Static Variables
    static String accId = ApexPages.currentPage().getParameters().get('accid');
    static Boolean hasValidationError = false;

    //Class Variables
    private ApexPages.StandardController m_sc;
    public Opportunity opportunity { get; set; }
    public Opportunity originalOpportunity { get; set; }
    public String pageTitle { get; set; }
    public boolean isNew { get; set; }
    public boolean isManager { get; set; }
    public String oldStage { get; set; }
    public Decimal oldAmount { get; set; }
    public Decimal oldDisplayBudget { get; set; }
    public string oldReasonComment{get;set;}
    public Date oldStartDate { get; set; }
    public Date oldEndDate { get; set; }
    public Map<String, Decimal> probabilityMap { get; set; }
    public boolean isClone = (ApexPages.currentPage().getParameters().get('clone') == '1');
    public List<SelectOption> brandPickList { get; set;}
    public String message { get; set; }
    public String selectedBrand { get; set; }
    public Boolean isClientFieldEmpty { get; set; }
  
    public List<Account_Manager_Junction__c> oppAMs { get; set; }
    public String opportunityNameErrorMsg { get; set; }
    public String classInputOpportunityName { get; set; }    
 
    // Record Type Start
    public String selectedRecordType { get {
        if (selectedRecordType == null)
            selectedRecordType = '--None--';
        return selectedRecordType;
    } set; }
    public Map<String, Id> recordTypeMap { get; set; }
    public List<SelectOption> recordTypes { get; set; } {
        recordTypes = new List<SelectOption>();
        recordTypes.add(new SelectOption('--None--', '--None--', true));
        recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' ORDER BY Name]) {
            recordTypes.add(new SelectOption(rt.Name, rt.Name));
            recordTypeMap.put(rt.Name,rt.Id); 
        } 
    }
    // Record Type End

    // Sales Rep Start
    public List<Employee__c> salesReps { get {
        salesReps = [SELECT Name FROM Employee__c WHERE Sales_Rep__c = true AND Enabled__c = true ORDER BY Name ASC];
        return salesReps;
    } set; }
    public Employee__c unassignedRep { get {
        unassignedRep = [select Id from Employee__c where Name = '-UNASSIGNED-' ORDER BY Name ASC];
        return unassignedRep;
    } set; }
    public String selectedDisplayRep { get {
        if (selectedDisplayRep == null) {
            if (unassignedRep == null)
                selectedDisplayRep = '--None--';
            else
                selectedDisplayRep = unassignedRep.Id;
        }
        return selectedDisplayRep;
    } set; }
    public String selectedMobileRep { get {
        if (selectedMobileRep == null) {
            if (unassignedRep == null)
                selectedMobileRep = '--None--';
            else
                selectedMobileRep = unassignedRep.Id;
        }
        return selectedMobileRep;
    } set; }
    public String selectedSecondaryDisplayRep { get {
        if (selectedSecondaryDisplayRep == null) {
            if (unassignedRep == null)
                selectedSecondaryDisplayRep = '--None--';
            else
                selectedSecondaryDisplayRep = unassignedRep.Id;
        }
        return selectedSecondaryDisplayRep;
    } set; }
    public String selectedSecondaryMobileRep { get {
        if (selectedSecondaryMobileRep == null) {
            if (unassignedRep == null)
                selectedSecondaryMobileRep = '--None--';
            else
                selectedSecondaryMobileRep = unassignedRep.Id;
        }
        return selectedSecondaryMobileRep;
    } set; }
    public SelectOption[] salesRepsDisplay { get; set; } {
        salesRepsDisplay = new List<SelectOption>();
        if (salesReps == null)
            salesRepsDisplay.add(new SelectOption('--None--', '--None--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsDisplay.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] salesRepsMobile { get; set; } {
        salesRepsMobile = new List<SelectOption>();
        if (salesReps == null)
            salesRepsMobile.add(new SelectOption('--None--', '--None--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsMobile.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] secondarySalesRepsDisplay { get; set; } {
        secondarySalesRepsDisplay = new List<SelectOption>();
        if (salesReps == null)
            secondarySalesRepsDisplay.add(new SelectOption('--None--', '--None--', true));
        else
            for (Employee__c salesRep : salesReps) {
                secondarySalesRepsDisplay.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] secondarySalesRepsMobile { get; set; } {
        secondarySalesRepsMobile = new List<SelectOption>();
        if (salesReps == null)
            secondarySalesRepsMobile.add(new SelectOption('--None--', '--None--', true));
        else
            for (Employee__c salesRep : salesReps) {
                secondarySalesRepsMobile.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    // Sales Rep End

    // Analyst Start
    public SelectOption[] analysts { get; set; } {
        analysts = new List<SelectOption>();
        List<Employee__c> employees = [select Id, Name from Employee__c where Analyst__c = true AND Enabled__c = true ORDER BY Name ASC];
        analysts.add(new SelectOption('--None--', '--None--', true));
        for (Employee__c employee : employees) {
            analysts.add(new SelectOption(employee.Id, employee.Name));
        }
    }
    // Analyst End
     
    // Trafficker Start
    public String selectedTrafficker { get {
        if (selectedTrafficker == null)
            selectedTrafficker = '--None--';
        return selectedTrafficker;
    } set; }
    public SelectOption[] traffickers { get; set; } {
        traffickers = new List<SelectOption>();
        List<Employee__c> employees = [select Id, Name from Employee__c where Trafficker__c = true AND Enabled__c = true ORDER BY Name ASC];
        traffickers.add(new SelectOption('--None--', '--None--', true));
        for (Employee__c employee : employees) {
            traffickers.add(new SelectOption(employee.Id, employee.Name));
        }
    }
    // Trafficker End
    
    // Account Managers
    public Set<SelectOption> selectedAMSet { get {
        if (selectedAMSet == null)
            selectedAMSet = new Set<SelectOption>();
        return selectedAMSet;
    } set; }
    public Set<SelectOption> allAMSet { get {
        if (allAMSet == null)
            allAMSet = new Set<SelectOption>();
        return allAMSet;
    } set; }
    public List<SelectOption> selectedAMs { get {
        if (selectedAMs == null)
            selectedAMs = new List<SelectOption>();
        return selectedAMs;
    } set; }
    public List<SelectOption> allAMs { get {
        if (allAMs == null)
            allAMs = new List<SelectOption>();
        return allAMs;
    } set; }

    // Stage Name Start
    public String selectedStage { get {
        if (selectedStage == null)
            selectedStage = 'RFP/Proposal';
        return selectedStage;
    } set; }
    public List<SelectOption> stages { get; set; }
    // Stage Name End

    // Forecast Category Start
    public Map<String, String> stageToForecastCategoryMap { get; set; }
    // Forecast Category End

    // Lead Source Start
    public String selectedLeadSource { get {
        if (selectedLeadSource == null)
            selectedLeadSource = '--None--';
        return selectedLeadSource;
    } set; }
    public SelectOption[] leadSources { get; set; } {
        leadSources = new List<SelectOption>();
        List<Lead_Source__c> leadSourcesList = [select Id, Name from Lead_Source__c ORDER BY Name ASC];
        leadSources.add(new SelectOption('--None--', '--None--', true));
        for (Lead_Source__c leadSource : leadSourcesList)
            leadSources.add(new SelectOption(leadSource.Id, leadSource.Name));
    }
    // Lead Source End
    
    // Opportunity Constructor
    public OpportunityExtension(ApexPages.StandardController stdController) {
        m_sc = stdController;
        opportunity = (Opportunity) m_sc.getRecord();
        
        // If Opportunity is new
        if (opportunity.Id == null && ApexPages.currentPage().getParameters().get('Id') == null) {
            isNew = true;
            opportunity = new Opportunity();
            opportunity.OwnerId = UserInfo.getUserId();
            pageTitle = 'New Opportunity';
            
            opportunity.AccountId = accId != null ? accId : null;
            isClientFieldEmpty = opportunity.AccountId == null;

        }
        // If Opportunity is cloned
        else if (isClone) {
            opportunity = getOpportunity();
            isNew = false;
            originalOpportunity = opportunity;
            opportunity = originalOpportunity.clone(true, true, false, false);
            clearAllFields();
            pageTitle = opportunity.Name;
            setAllPicklistFields();
            getAmount();
            opportunity.Id = null;
        }
        // If Opportunity already exists
        else {
            isNew = false;
            opportunity = getOpportunity();
            pageTitle = opportunity.Name;
            oldStage = opportunity.StageName;
            oldAmount =opportunity.Amount; 
            oldReasonComment=opportunity.Reason_Comment__c;
            oldStartDate = opportunity.Campaign_Start_Date__c;
            oldEndDate = opportunity.Campaign_End_Date__c;
            oldDisplayBudget =opportunity.Display_Budget__c;
            setAllPicklistFields();
            getAmount();
        }
        updateStageValues();
        setUserRole();
        setProbabilityMap();
        setClient();
        initAccountManager();
        setClientContact();
    }

    public Opportunity getOpportunity() {
        return (Opportunity)QueryHelper.selectAllQuery('opportunity', 'WHERE Id = \'' + String.valueOf(opportunity.Id) + '\'')[0];
    }

    public void refresh() {
        if (isClientFieldEmpty) {
            brandPicklist = null;
            selectedBrand = null;
        }else
            setClient();
            
        changeNewStageName();
        getAmount();        
    }

    public void saveObjects() {
        // Look for opportunity name duplicates
        runOpportunityNameValidation();
        // Set fields selected from dropdowns
        setAllPicklistDependentFields();
        // Perform validation check on Required fields
        checkRequiredFields();
        // Logic to set amount field on opportunity
        getAmount();
        // Check if Entered amount is greater or less 
        // checkDiffrences();
        // If Opportunity is new, assign adserving ratecard
        assignRatecard();
        // Upsert if validation is successful
        System.debug('@@@@@@@@'+showrequired);
    /*    if(showrequired)
        {
            Boolean shouldExecute=false;
            String message='cannot be blank when Stage is either Cancelled/Paused or Display Budget Change is Increase/Decrease';
            System.debug('{!opportunity.Reason_for_alert__c}'+opportunity.Reason_for_alert__c);
            System.debug('{!opportunity.Reason_for_alert__c}'+opportunity.Reason__c);
            System.debug('{!opportunity.Reason_for_alert__c}'+opportunity.Reason_Comment__c);
            if(opportunity.Reason__c!='' && opportunity.Reason__c!=null)
            {
                if(opportunity.Reason__c!='' && opportunity.Reason__c!=null)
                {
                    if(opportunity.Reason_Comment__c!='' && opportunity.Reason_Comment__c!=null)
                    {
                        upsert(opportunity);
                    }
                    else
                    {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'Reason Comment'+message));
                        throw new MissingOpportunityDetailException ('Reason Comment'+message);
                    }
                }
                else
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'Reason For Alert'+message));
                    throw new MissingOpportunityDetailException ('Reason For Alert'+message);
                }
            }
            else
            {
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'Reason'+message));
               throw new MissingOpportunityDetailException ('Reason'+message);
            }
        }

        else
        { */
            if (opportunity.Is_Draft__c==true)                
            opportunity.Is_Draft__c=False;
            
            upsert(opportunity);
       // }
        // Save logic for Account Manager field
        setAccountManagers();
        // Save logic for Default Analyst
        setDefaultAnalyst();        
        // Final update
        update(opportunity);
    }
    
     public void saveObjectDrafts() {
        // Set fields selected from dropdowns
        setAllPicklistDependentFields();
        // Perform validation check on Required fields
        getAmount();
        // If Opportunity is new, assign adserving ratecard
        assignRatecard();
        // Upsert if validation is successful
        opportunity.Is_Draft__c =True;
        upsert(opportunity);
        // Save logic for Account Manager field
        setAccountManagers();
        // Save logic for Default Analyst
        setDefaultAnalyst();        
        // Final update
        update(opportunity);
    }
    public PageReference save() {
        try {
        
            saveObjects();
        } catch (DuplicateOpportunityNameException e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Opportunity name already exists!');
            ApexPages.addMessage(errMsg);
            return null;
        } catch (MissingOpportunityDetailException e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errMsg);
            return null;
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // If set to Closed Won, enter the Opportunity_Survey page
        system.debug('###oldStage####' +oldStage);
        system.debug('###opportunity.StageName####' +opportunity.StageName);
        system.debug('###opportunity.RecordTypeId####' +opportunity.RecordType.Name);
        if (oldStage != 'Closed Won' && opportunity.StageName == 'Closed Won' && opportunity.RecordTypeId == recordTypeMap.get('eyeDemand')) {
            List<Campaign_Questionnaire__c> questionnaire = [SELECT Id, To_be_Submitted__c FROM Campaign_Questionnaire__c WHERE Opportunity__r.Id = :opportunity.Id];

            if (questionnaire.size() > 0) {
                questionnaire.get(0).To_be_Submitted__c = true; //temporary variable to indicate if opportunity has been closed won for the campaign questionnaire
                update questionnaire;
                PageReference pageRef = new PageReference('/apex/Campaign_Questionnaire');
                pageRef.getParameters().put('id', questionnaire[0].id);
                return pageRef;
            } else {
                PageReference pageRef = new PageReference('/apex/Campaign_Questionnaire');
                pageRef.getParameters().put('opportunityId', opportunity.Id);
                return pageRef;
            }
        }
        // After save, switch to detail view
        return (new ApexPages.StandardController(opportunity)).view();
    }
    
    public PageReference saveDraft() {
        
        try {
            saveObjectDrafts();
            /*
            PageReference MyNewPage = new PageReference('/' + opportunity.Id);            
            MyNewPage.setRedirect(true);
            */
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This is a DRAFT copy. Please click on -save- to validate your input'));
            return Null;
        } 
        catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    public PageReference saveNew() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        if (oldStage != 'Closed Won' && opportunity.StageName == 'Closed Won' && opportunity.RecordTypeId == recordTypeMap.get('eyeDemand')) {
            List<Campaign_Questionnaire__c> questionnaire = [SELECT Id FROM Campaign_Questionnaire__c WHERE Opportunity__r.Id = :opportunity.Id];
            if (questionnaire.size() > 0) {
                PageReference pageRef = new PageReference('/apex/Campaign_Questionnaire');
                pageRef.getParameters().put('id', questionnaire[0].id);
                return pageRef;
            } else {
                PageReference pageRef = new PageReference('/apex/Campaign_Questionnaire');
                pageRef.getParameters().put('opportunityId', opportunity.Id);
                return pageRef;
            }
        }
        // After save, switch to new view
        String s = '/' + ('' + opportunity.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }

    public PageReference cancel() {
        // If new Opportunity, redirect to main Opportunity page
        return m_sc.cancel();
    }
    
    public void getAllStages(){
        Schema.DescribeFieldResult F = Schema.Opportunity.StageName.getDescribe();
        List<schema.picklistentry> typeList = F.getPicklistValues();
        stages = new List<SelectOption>();
        stageToForecastCategoryMap = new Map<String, String>();

        for (Integer i = 0; i < typeList.size(); i++)
            stages.add(new SelectOption('',''));

        for (Schema.PicklistEntry TypeItem : typeList){
            if(TypeItem.getLabel().equals('RFP/Proposal')){
                stages.set(0, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Pipeline');
            }

            if(TypeItem.getLabel().equals('Closed Lost')){
                stages.set(1, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Omitted');
            }

            if(TypeItem.getLabel().equals('Closed Won')){
                stages.set(2, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Closed');
            }

            if(TypeItem.getLabel().equals('Paused')){
                stages.set(3, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Closed');
            }

            if(TypeItem.getLabel().equals('Cancelled')){
                stages.set(4, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Omitted');
            }

            if(TypeItem.getLabel().equals('Ready To Bill')){
                stages.set(5, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Closed');
            }
            if(TypeItem.getLabel().equals('Billed')){
                stages.set(6, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Closed');
            }
            if(TypeItem.getLabel().equals('Do Not Bill')){
                stages.set(7, new SelectOption(TypeItem.getValue(),TypeItem.getLabel()));
                stageToForecastCategoryMap.put(TypeItem.getLabel(), 'Closed');
            }            
        }
    }

    public void updateStageValues() {
        getAllStages();
        if (!stages.isEmpty()) {
            for (Integer i = 0; i < stages.size(); i++) {
                if (selectedRecordType != 'Creative Production') {
                    if (stages.get(i).getLabel().equals('Ready To Bill')){
                        stages.remove(i);
                    }
                    if (stages.get(i).getLabel().equals('Billed')){
                        stages.remove(i);
                    }
                    if (stages.get(i).getLabel().equals('Do Not Bill')){
                        stages.remove(i);
                    }
                    
                }
            }
            for (Integer i = 0; i < stages.size(); i++) {
                if (oldStage != 'Closed Won' && selectedStage != 'Cancelled' && selectedStage != 'Paused'){
                    if (stages.get(i).getLabel().equals('Cancelled')){
                        stages.remove(i);
                    }
                }
            }
            for (Integer i = 0; i < stages.size(); i++) {
                if (oldStage != 'Closed Won' && selectedStage != 'Paused' && selectedStage != 'Cancelled'){
                    if (stages.get(i).getLabel().equals('Paused')){
                        stages.remove(i);
                    }
                }
            }
        }
    }

    public void setAllPicklistFields(){
        selectedDisplayRep = opportunity.Primary_Display_Sales_Rep__c;
        selectedMobileRep = opportunity.Primary_Mobile_Sales_Rep__c;
        selectedSecondaryDisplayRep = opportunity.Secondary_Display_Sales_Rep__c;
        selectedSecondaryMobileRep = opportunity.Secondary_Mobile_Sales_Rep__c;
        selectedTrafficker = opportunity.Opportunity_Trafficker__c;
        selectedLeadSource = opportunity.Lead_Source__c;
        selectedBrand = opportunity.Brand__c;
        selectedStage = opportunity.StageName;
        selectedRecordType = opportunity.RecordType.Name;
        system.Debug('#####selectedRecordType#####' +selectedRecordType);
    }

    public void setAllPicklistDependentFields(){
        // Record Type
        if (selectedRecordType != '--None--') opportunity.RecordTypeId = recordTypeMap.get(selectedRecordType);

        // Stage
        if (selectedStage != '--None--') opportunity.StageName = selectedStage;
        // Display Reps
        if ((opportunity.Display_Budget__c != null && opportunity.Display_Budget__c > 0) || (selectedRecordType == 'Creative Production')) {
            opportunity.Primary_Display_Sales_Rep__c = selectedDisplayRep;
            opportunity.Secondary_Display_Sales_Rep__c = selectedSecondaryDisplayRep;
        }else {
            opportunity.Primary_Display_Sales_Rep__c = unassignedRep.Id;
            opportunity.Secondary_Display_Sales_Rep__c = unassignedRep.Id;
        }
        // Mobile Reps
        if ((opportunity.Mobile_Budget__c != null && opportunity.Mobile_Budget__c > 0) || (selectedRecordType == 'Creative Production')) {
            opportunity.Primary_Mobile_Sales_Rep__c = selectedMobileRep;
            opportunity.Secondary_Mobile_Sales_Rep__c = selectedSecondaryMobileRep;
        }else {
            opportunity.Primary_Mobile_Sales_Rep__c = unassignedRep.Id;
            opportunity.Secondary_Mobile_Sales_Rep__c = unassignedRep.Id;
        }

        // Trafficker
        if (selectedTrafficker != '--None--') opportunity.Opportunity_Trafficker__c = selectedTrafficker;
        // Lead Source
        if (selectedLeadSource != '--None--') opportunity.Lead_Source__c = selectedLeadSource;
        // Old Stage
        if (oldStage != 'Closed Won' && opportunity.StageName == 'Closed Won') setOriginalOpportunityDates();
        if (oldStage == 'Closed Won') setCampaignDates();
        // Brand
        if (selectedBrand != '') opportunity.Brand__c = selectedBrand;
        // Opportunity Forecast Category
        opportunity.ForecastCategoryName = stageToForecastCategoryMap.get(opportunity.StageName);
    }

    public void setProbabilityMap() {
        probabilityMap = new Map<String, Decimal>();
        for (OpportunityStage oppStage : [select MasterLabel, DefaultProbability from OpportunityStage]) {
            probabilityMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
        }
    }

    public void setAccountManagers(){
        // Save account managers multi picklist
        message = '';
        Boolean first = true;

        List<Account_Manager_Junction__c> addAMs = new List<Account_Manager_Junction__c>();
        List<Account_Manager_Junction__c> removeAMs = new List<Account_Manager_Junction__c>();
        
        //Add New Account Managers
        if (!selectedAMs.isEmpty()) {
            for ( SelectOption so : selectedAMs ) {
                if (so.getValue() != '--N/A--') {
                    if (!selectedAMSet.contains(new SelectOption(so.getValue(),so.getLabel()))) {
                        addAMs.add(new Account_Manager_Junction__c(
                            Employee__c = so.getValue(),
                            Opportunity__c = opportunity.Id
                        ));
                    }
                    if (!first)
                        message += ', ';
        
                    message += so.getLabel();
                    first = false;
                }
            }
        }
        selectedAMSet = new Set<SelectOption>(selectedAMs);
        
        //Remove Account Managers, if applicable
        for ( Account_Manager_Junction__c amj : oppAMs) {
            if (!selectedAMSet.contains(new SelectOption(amj.Employee__c,amj.Employee__r.Name))) {
                 removeAMs.add(new Account_Manager_Junction__c(
                    Id = amj.Id
                ));
            }
        }
        
        if (!selectedAMs.isEmpty()) {
            if (!addAMs.isEmpty()) {
                insert addAMs;
            }
            if (!removeAMs.isEmpty()) {
                delete removeAMs;
            }
            opportunity.Account_Managers__c = message;
        }
    }

    public void setDefaultAnalyst(){
        // Set analyst logic
        if (!selectedRecordType.equals('Creative Production')){
            if (opportunity.StageName.equals('Closed Won')){
                Account_Brand_Junction__c accBrandJunc = [SELECT Analyst__c FROM Account_Brand_Junction__c WHERE Account__c =:opportunity.AccountId AND Brand__c =:opportunity.Brand__c LIMIT 1];
                if(accBrandJunc != null && accBrandJunc.Analyst__c != null){
                    opportunity.Opportunity_Analyst__c = accBrandJunc.Analyst__c;
                }else{
                    Account account = [select Analyst__c from Account where Id =:opportunity.AccountId];
                    if(account != null && account.Analyst__c != null)
                        opportunity.Opportunity_Analyst__c = account.Analyst__c;
                }
                if(opportunity.Opportunity_Analyst__c == null){
                    for(SelectOption analyst : analysts){
                        if(analyst.getLabel().equals('Leticia Kwok')){
                            opportunity.Opportunity_Analyst__c = analyst.getValue();
                            break;
                        }
                    }
                }
            }
        }
    }

    public void setClientContact() {
        
        try {
            if (isNew){
                if (opportunity.Client_Contact__c!= null) {
                    Contact clientContact= [select Name, Lead_Source__c from Contact where Id = :opportunity.Client_Contact__c];
                    if (clientContact.Lead_Source__c != null) {
                        selectedLeadSource = clientContact.Lead_Source__c;
                     }
                    else 
                    selectedLeadSource =Null;
                 }
            }
            else if(opportunity.Client_Contact__c!= null){
                 Contact clientContact= [select Name, Lead_Source__c from Contact where Id = :opportunity.Client_Contact__c];
                    if (clientContact.Lead_Source__c != null) {
                        selectedLeadSource = clientContact.Lead_Source__c;
                     } 
            }
            else if (opportunity.Lead_Source__c == Null && opportunity.Client_Contact__c!= null && opportunity.Client_Contact__r.Lead_Source__c != null ){
                  selectedLeadSource = opportunity.Client_Contact__r.Lead_Source__c;      
            }
             
        }catch(ListException e) {
            System.Debug('Error: List exception ['+ e.getMessage()+']');
        }
    }
    public void setClient() {
        try {
            if (opportunity.AccountId != null) {
                Account account = [select Name, Region__c, Account_Currency__c from Account where Id = :opportunity.AccountId];
                if (account.Region__c != null) opportunity.Region__c = account.Region__c;
                if (account.Account_Currency__c != null) opportunity.Currency__c = account.Account_Currency__c;
                setSalesReps();
                setBrand();
            }
        }catch(ListException e) {
            System.Debug('Error: List exception ['+ e.getMessage()+']');
        }
    }

    public void setBrand() {
        try {
            if (opportunity.AccountId != null || opportunity.AccountId != '') {
                List<Brand__c> brandList  = [SELECT Id, Name FROM Brand__c where Id in (SELECT Brand__c FROM Account_Brand_Junction__c WHERE Account__c = :opportunity.AccountId) ORDER BY Name DESC];
                brandPicklist = new List<SelectOption>();

                if (!brandList.isEmpty()) {
                    Id brandId = brandList.get(0).Id;
                    if (selectedBrand == null)
                        selectedBrand = (brandId == null ? '' : brandId);

                    for (Integer i = 0; i < brandList.size(); i++)
                        brandPicklist.add(new SelectOption(brandList.get(i).Id, brandList.get(i).Name));
                }
            }else
                brandPicklist = null;
        }catch(ListException e) {
            System.Debug('Error: List exception ['+ e.getMessage()+']');
        }
    }

    public void setUserRole() {
        String userRole = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()][0].Name;
        isManager = (userRole == 'Canada Operations' || userRole == 'US Operations');
    }

    public void setCloseDate() {
        if (opportunity.CloseDate == null) {
            opportunity.CloseDate = Date.today();
        }
    }

    public void setOriginalOpportunityDates() {
        opportunity.Original_Opportunity_Start_Date__c = opportunity.Campaign_Start_Date__c;
        opportunity.Original_Opportunity_End_Date__c = opportunity.Campaign_End_Date__c;
    }

    public void setCampaignDates() {
        // If the budget change start date is earlier than the current start date, set the current start date
        if (opportunity.Budget_Change_Start_Date__c != null && opportunity.Campaign_Start_Date__c > opportunity.Budget_Change_Start_Date__c) {
            opportunity.Campaign_Start_Date__c = opportunity.Budget_Change_Start_Date__c;
        }
        // If the budget change end date is earlier than the current end date, set the current end date
        if (opportunity.Budget_Change_End_Date__c != null && opportunity.Campaign_End_Date__c < opportunity.Budget_Change_End_Date__c) {
            opportunity.Campaign_End_Date__c = opportunity.Budget_Change_End_Date__c;
        }
    }

    public void setSalesReps() {
        if (isNew && opportunity.AccountId != null) {
            Account account = [SELECT Sales_Rep_eyeDemand__c, Sales_Rep_Ad_Serving__c FROM Account WHERE Id = :opportunity.AccountId];
            if (selectedRecordType != null && selectedRecordType == 'eyeDemand') {
                selectedDisplayRep = account.Sales_Rep_eyeDemand__c;
                selectedMobileRep = account.Sales_Rep_eyeDemand__c;
            } else if (selectedRecordType != null && selectedRecordType == 'Adserving') {
                selectedDisplayRep = account.Sales_Rep_Ad_Serving__c;
                selectedMobileRep = account.Sales_Rep_Ad_Serving__c;
            }
        }
    }

    public void updateOppTypeDependencies(){
        // Clear unnecessary fields
        if(selectedRecordType == 'Creative Production')
            clearAllFields();
        else if(selectedRecordType == 'eyeDemand')
            clearAdServingFields();
    
        // Set Opportunity Stage and Sales Reps
        setSalesReps();
        updateStageValues();
        getAmount();
    }

    public void changeNewStageName() {
        opportunity.StageName = selectedStage;
        changeStageName();
        changeReasonAlert();
        testClear();
    }
    
    public boolean showrequired{get;set;}
    public void changeReasonAlert(){
        showrequired=false;
        /*
        if(selectedStage == 'Paused' || selectedStage == 'Cancelled'){
            opportunity.Reason_for_alert__c = 'Cancellation/Pause';
            showrequired=true;
        }

        if(opportunity.Display_Budget_Change__c =='Increase'){
            opportunity.Reason_for_alert__c = 'Heavy Up';
            showrequired=true;
        }
        
        if(opportunity.Display_Budget_Change__c =='Decrease'){
            opportunity.Reason_for_alert__c = 'Budget Decrease';
            showrequired=true;
        }
        */
        if(selectedStage!='Paused' && selectedStage != 'Cancelled' && opportunity.Display_Budget_Change__c =='')
        {
           // opportunity.Reason_for_alert__c = '';
            opportunity.Reason__c='';
            opportunity.Reason_Comment__c='';
            showrequired=false;
        }
        
    }  

    public void changeStageName() {
        // Throw error if there is no Type set
        if (opportunity.StageName == 'Closed Won' && selectedRecordType == null) {
            opportunity.StageName = null;
            selectedStage = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Select a Type before setting the Stage to Closed Won'));
        } else {
            if (probabilityMap.containsKey(opportunity.StageName)) {
                opportunity.Probability = probabilityMap.get(opportunity.StageName);
            }
            if (opportunity.StageName == 'Closed Won') {
                closedWon();
            }
        }
    }

    public void getAmount() {
        if (selectedRecordType != null && selectedRecordType != 'Creative Production') {
            Decimal db;
            Decimal mb;
            Decimal displayBudget = opportunity.Display_Budget__c;
            Decimal mobileBudget = opportunity.Mobile_Budget__c;
            String displayBudgetChange = opportunity.Display_Budget_Change__c;
            String mobileBudgetChange = opportunity.Mobile_Budget_Change__c;
            Decimal displayBudgetChangeAmount = opportunity.Display_Budget_Change_Amount__c;
            Decimal mobileBudgetChangeAmount = opportunity.Mobile_Budget_Change_Amount__c;
    
            db = (displayBudget == null) ? 0 : displayBudget;
            mb = (mobileBudget == null) ? 0 : mobileBudget;
            if (displayBudgetChangeAmount != null) {
                if (displayBudgetChange == 'Decrease')
                    db -= displayBudgetChangeAmount;
                else if (displayBudgetChange == 'Increase')
                    db += displayBudgetChangeAmount;
            }
            if (mobileBudgetChangeAmount != null) {
                if (mobileBudgetChange == 'Decrease')
                    mb -= mobileBudgetChangeAmount;
                else if (mobileBudgetChange == 'Increase')
                    mb += mobileBudgetChangeAmount;
            }
            opportunity.Amount = (db + mb);
        }
        
        changeReasonAlert();
        checkDiffrences();
    }

    public void closedWon() {
        setCloseDate();
    }
    
    //Initialize Account Manager Picklist
    public void initAccountManager() {
        //Selected AMs (right picklist)
        oppAMs = [SELECT Id, Opportunity__c, Employee__c, Employee__r.Name FROM Account_Manager_Junction__c where Opportunity__c =: opportunity.Id ORDER BY Employee__r.Name ASC];
   
        if (!oppAMs.isEmpty() ) {
            for (Account_Manager_Junction__c oppAM : oppAMs)
                selectedAMSet.add(new SelectOption(oppAM.Employee__c, oppAM.Employee__r.Name));

            for (SelectOption so : selectedAMSet)
                selectedAMs.add(so);
        }
        
        //All AMs (left picklist)
        List<Employee__c> ams = [SELECT Name, Id FROM Employee__c where Account_Manager__c = TRUE AND Enabled__c = true ORDER BY Name ASC];
        if (!ams.isEmpty() && test.isRunningTest()) {
            for (Integer i = 0; i < ams.size(); i++)
                allAMSet.add(new SelectOption(ams.get(i).Id, ams.get(i).Name));
            
            if (selectedAMSet != null)
                allAMSet.removeAll(selectedAMSet);

            for (SelectOption so : allAMSet)
                allAMs.add(so);
        }
        
        if ((!isNew && selectedAMs.isEmpty()) ) {
            selectedAMs.add(new SelectOption('--N/A--','--N/A--'));
            selectedAMSet.add(new SelectOption('--N/A--','--N/A--'));
        } else
            allAMs.add(new SelectOption('--N/A--','--N/A--'));
    }
    
    public void assignRatecard() {
        //Assign the nearest parent ratecard to the opportunity
        if (isNew) {
            if (opportunity.AccountId != null) {
                //For adServing, assign the org ratecard
                if (selectedRecordType != null && selectedRecordType == 'Adserving') {
                    try{
                        opportunity.adServing_Ratecard__c = [SELECT Ratecard__c, RecordType.Name
                        FROM Ratecard_Account__c
                        WHERE Account__c =: opportunity.AccountId
                        AND RecordType.Name = 'adServing'
                        AND (Activation_Date__c <= TODAY AND Expiration_Date__c > TODAY)
                        ORDER BY Activation_Date__c DESC
                        LIMIT 1][0].Ratecard__c;
                    }catch(ListException e) {
                        System.Debug('Error: List exception ['+ e.getMessage()+']');
                    }
                }
            }
        }
    }

    public void checkRequiredFields() {
        hasValidationError = false;
        String errorMessage = '';
        if (String.isBlank(selectedRecordType)) {
            errorMessage += '<b>Opportunity Type</b>: You must select a value.<br/>';
            hasValidationError = true;
        } 
        if (String.isBlank(opportunity.StageName)) {
            errorMessage += '<b>Stage Name</b>: You must select a value.<br/>';
            hasValidationError = true;
        } 
        if (String.isBlank(opportunity.Name)) {
            errorMessage += '<b>Opportunity Name</b>: You must enter a value.<br/>';
            hasValidationError = true;
        }
        if (String.isBlank(opportunity.AccountId)) {
            errorMessage += '<b>Client</b>: You must enter a value.<br/>';
            hasValidationError = true;
        }
        if (!String.isBlank(opportunity.StageName) && opportunity.StageName.equals('Closed Won')) {
            if (String.isBlank(selectedBrand)) {
                errorMessage += '<b>Brand</b>: You must enter a value.<br/>';
                hasValidationError = true;
            }
        }
        if (String.isBlank(opportunity.Client_Contact__c)) {
            errorMessage += '<b>Client Sales Contact</b>: You must enter a value.<br/>';
            hasValidationError = true;
        }
        if (!String.isBlank(opportunity.StageName) && (opportunity.StageName.equals('Closed Won') || selectedRecordType.equals('Creative Production'))) {
            if (String.isBlank(opportunity.Billing_Contact__c)) {
                errorMessage += '<b>Billing Contact</b>: You must enter a value.<br/>';
                hasValidationError = true;
            }
        }
        if (opportunity.OwnerId == null) {
            errorMessage += '<b>Opportunity Owner</b>: You must enter a value.<br/>';
            hasValidationError = true;
        }
        if (opportunity.CloseDate == null) {
            errorMessage += '<b>Close Date</b>: You must enter a value.<br/>';
            hasValidationError = true;
        }

        if (!String.isBlank(selectedRecordType)) 
        {
            Date firstDayOfMonth = System.today().toStartOfMonth();                 
            if (selectedRecordType.equals('Creative Production')) 
            {
                if (opportunity.StageName.equals('Ready To Bill') && opportunity.Ready_To_Bill_Date__c == null ) 
                {
                    errorMessage += '<b>Ready To Bill Date</b>: You must enter a value.<br/>';
                    hasValidationError = true;
                }
                if (opportunity.StageName.equals('Ready To Bill') && firstDayOfMonth > opportunity.Ready_To_Bill_Date__c) 
                {
                    errorMessage += '<b>Ready To Bill Date</b>: Can not be in previous billing cycle. <br/>';
                    hasValidationError = true;
                }
            }
        }
        
        if (String.isBlank(opportunity.Region__c)) {
            errorMessage += '<b>Region</b>: You must select a value.<br/>';
            hasValidationError = true;
        }
        if (String.isBlank(opportunity.Industry__c)) {
            errorMessage += '<b>Industry</b>: You must select a value.<br/>';
            hasValidationError = true;
        }
        if (String.isBlank(opportunity.Currency__c)) {
            errorMessage += '<b>Currency</b>: You must select a value.<br/>';
            hasValidationError = true;
        }
        if (!String.isBlank(selectedRecordType)) {
            if (selectedRecordType.equals('Creative Production')) {
                 if (String.isBlank(opportunity.Description)) {
                    errorMessage += '<b>Description/Details</b>: You must enter a value.<br/>';
                    hasValidationError = true;
                }
                if (opportunity.Amount == null) {
                    errorMessage += '<b>Total Amount</b>: You must enter a value.<br/>';
                    hasValidationError = true;
                }
            } else {
                if (opportunity.Campaign_Start_Date__c == null && (oldStartDate == null || oldStage != 'Closed Won')) {
                    errorMessage += '<b>Campaign Start Date</b>: You must enter a value.<br/>';
                    hasValidationError = true;
                }
                if (opportunity.Campaign_End_Date__c == null && (oldEndDate == null || oldStage != 'Closed Won')) {
                    errorMessage += '<b>Campaign End Date</b>: You must enter a value.<br/>';
                    hasValidationError = true;
                }
                if (opportunity.Display_Budget_Change_Amount__c != null) { 
                    if (String.isBlank(opportunity.Display_Budget_Change__c)) {
                        errorMessage += '<b>Display Budget Change</b>: You must select a value.<br/>';
                        hasValidationError = true;
                    }
                }
                if (!String.isBlank(opportunity.Display_Budget_Change__c)) { 
                    if (opportunity.Display_Budget_Change_Amount__c == null) {
                        errorMessage += '<b>Display Budget Change Amount</b>: You must enter a value.<br/>';
                        hasValidationError = true;
                    }   
                }

                if (opportunity.Mobile_Budget_Change_Amount__c != null) { 
                    if (String.isBlank(opportunity.Mobile_Budget_Change__c)) {
                        errorMessage += '<b>Mobile Budget Change</b>: You must select a value.<br/>';
                        hasValidationError = true;
                    }
                }

                if (!String.isBlank(opportunity.Mobile_Budget_Change__c)) { 
                    if (opportunity.Mobile_Budget_Change_Amount__c == null) {
                        errorMessage += '<b>Mobile Budget Change Amount</b>: You must enter a value.<br/>';
                        hasValidationError = true;
                    }
                }
                if (opportunity.Mobile_Budget__c == null || opportunity.Mobile_Budget__c == 0) {
                    if (opportunity.Display_Budget__c == null) {
                        errorMessage += '<b>Display Budget</b>: You must enter a value.<br/>';
                        hasValidationError = true;
                    }
                }
            }
        }
        if (String.isBlank(selectedDisplayRep)) {
            errorMessage += '<b>Primary Sales Rep - Display</b>: You must select a value.<br/>';
            hasValidationError = true;
        }
        if (String.isBlank(selectedMobileRep)) {
            errorMessage += '<b>Primary Sales Rep - Mobile You must select a value.<br/>';
            hasValidationError = true;
        }

        if (String.isBlank(opportunity.Lead_Source__c)) {
            errorMessage += '<b>Lead Source</b>: You must select a value.<br/>';
            hasValidationError = true;
        }

        if (selectedAMs.isEmpty()) {
            errorMessage += '<b>Account Manager</b>: You must select a value. Please select N/A if not applicable.<br/>';
            hasValidationError = true;
        }
        // Check if client does not have "Credit App Approval" nor the "Adserving Agreement" checked
        if ((opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Ready To Bill') && opportunity.AccountId != null) {
            Account acc = [SELECT Credit_App_Approved__c, Credit_Card__c FROM Account WHERE Id =: opportunity.AccountId LIMIT 1];
            if (!acc.Credit_App_Approved__c && !acc.Credit_Card__c) {
                errorMessage += '<b>Client needs Credit App Approval or Credit Card checked to save the opportunity as Closed Won.</b> <a href=/'+opportunity.AccountId+' target="_blank">Click here for Client page.</a> (Sales Manager permissions are required to enable the checkbox).<br/>';
                hasValidationError = true;
            }
        }
        // Throw exception if error found
        if (hasValidationError) {
            if (errorMessage != null) {
                errorMessage = errorMessage.substring(0,errorMessage.lastIndexOf('<br/'));
                throw new MissingOpportunityDetailException(errorMessage);
            }
        }
    }

    public void runOpportunityNameValidation() {
        Opportunity[] matchedOpportunities;
        if (opportunity.Id == null)
            matchedOpportunities = [select Id from Opportunity where Name = :opportunity.Name];
        else
            matchedOpportunities = [select Id from Opportunity where Name = :opportunity.Name and Id <> :opportunity.Id];
        if (!matchedOpportunities.isEmpty()) {
            opportunityNameErrorMsg = 'Opportunity Name already exists';
            classInputOpportunityName = 'error';
            throw new DuplicateOpportunityNameException(opportunityNameErrorMsg);
        } else {
            opportunityNameErrorMsg = '';
            classInputOpportunityName = '';
        }
    }
    
    public void removeComment() {    
        Opportunity.Reason_Comment__c = '';        
    }

   
    public void checkDiffrences(){
        Decimal displayBudget = opportunity.Display_Budget__c; 
        If(oldDisplayBudget > displayBudget ) 
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The budget Amount Decreased'));
        
        else if (oldDisplayBudget <displayBudget )
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The budget Amount Increased'));
        }
        
    public void testClear()
    {
        If(opportunity.StageName!= oldStage)
        {
            opportunity.Reason_Comment__c ='';             
        }
        else
        opportunity.Reason_Comment__c=oldReasonComment;
    }
    
    public void testCAmount()
    {
        If(opportunity.Amount!= oldAmount)
        {
            opportunity.Reason_Comment__c ='';             
        }
        else
        opportunity.Reason_Comment__c=oldReasonComment;
        checkDiffrences();
 
    }
    
     public void clearAllFields(){
        clearAdServingFields();
        opportunity.CID__c = null;
        opportunity.Client_PO__c = null;
        opportunity.Display_Budget__c = null;
        opportunity.Mobile_Budget__c = null;
        opportunity.Display_Budget_Change__c = null;
        opportunity.Mobile_Budget_Change__c = null;
        opportunity.Display_Budget_Change_Amount__c = null;
        opportunity.Mobile_Budget_Change_Amount__c = null;
        opportunity.Original_Opportunity_Start_Date__c = null;
        opportunity.Original_Opportunity_End_Date__c = null;
        opportunity.Campaign_Start_Date__c = null;
        opportunity.Campaign_End_Date__c = null;
        opportunity.Budget_Change_Start_Date__c = null;
        opportunity.Budget_Change_End_Date__c = null;
        opportunity.CloseDate = null;
        opportunity.StageName = null;
        opportunity.ForecastCategoryName = null;
        opportunity.Amount = null;
        opportunity.Jira_Key__c = null;
        opportunity.Jira_Key_AM__c = null;
        opportunity.Opportunity_Analyst__c = null;
        opportunity.Billing_Address__c = null;
        opportunity.Account_Managers__c = null;
        opportunity.Primary_Display_Sales_Rep__c = null;
        opportunity.Secondary_Display_Sales_Rep__c = null;
        opportunity.Primary_Mobile_Sales_Rep__c = null;
        opportunity.Secondary_Mobile_Sales_Rep__c = null;
        opportunity.Initial_Sync__c = false;
        opportunity.Ready_To_Traffic__c = false;
        opportunity.Has_Campaign__c = false;
        selectedDisplayRep = null;
        selectedMobileRep = null;
        selectedSecondaryDisplayRep = null;
        selectedSecondaryMobileRep = null;
    }

    public void clearAdServingFields(){
        opportunity.adServing_Title__c = null;
        opportunity.adServing_Ratecard_ID_FK__c = null;
        opportunity.adServing_Campaign_Budget__c = null;
        opportunity.adServing_Negotiated_Flat_Rate__c = null;
        opportunity.adServing_Number_of_Orion_Tags__c = null;
        opportunity.adServing_Setup_Fee__c = null;
        opportunity.adServing_Swap_Fee__c = null;
        opportunity.adServing_Custom_Fee__c = null;
        opportunity.adServing_Custom_Fee_Label__c = null;
        opportunity.adServing_Bonus_Impressions__c = null;
        opportunity.adServing_Bonus_Rate__c = null;
        opportunity.adServing_Bonus_Total__c = null;
        opportunity.adServing_PO_Number__c = null;
        opportunity.adServing_Trafficker_Hour__c = null;
        opportunity.adServing_Bill_on_Actual__c = false;
        opportunity.adServing_Manual_IO__c = false;
        opportunity.adServing_Waive_Minimum_Fee__c = false;
        opportunity.adServing_Prepaid__c = false;
        opportunity.adserving_db4_last_save_date__c = null;
    }
    
    public class RequiredReasonMissingException extends Exception {}
}