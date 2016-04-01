public class AccountExtension {
    private ApexPages.StandardController m_sc;
    public Account account { get; set; }
    public boolean isAdmin { get; set; }
    public String pageTitle { get; set; }
    public String accountNameErrorMsg { get; set; }
    public String classInputAccountName { get; set; }
    public Employee__c unassignedRep { get {
        if ([select Id from Employee__c where Name = '-UNASSIGNED-' ORDER BY Name ASC].isEmpty())
            unassignedRep = null;
        else
            unassignedRep = [select Id from Employee__c where Name = '-UNASSIGNED-' ORDER BY Name ASC];
        return unassignedRep;
    } set; }
    public String selectedAdServingRep { get {
        if (selectedAdServingRep == null) {
            if (unassignedRep == null)
                selectedAdServingRep = '--NONE--';
            else
                selectedAdServingRep = unassignedRep.Id;
        }
        return selectedAdServingRep;
    } set; }
    public String selectedEyeDemandRep { get {
        if (selectedEyeDemandRep == null) {
            if (unassignedRep == null)
                selectedEyeDemandRep = '--NONE--';
            else
                selectedEyeDemandRep = unassignedRep.Id;
        }
        return selectedEyeDemandRep;
    } set; }
    public String selectedAnalyst { get {
        if (selectedAnalyst == null) {
            selectedAnalyst = '--NONE--';
        }
        return selectedAnalyst;
    } set; }
    public SelectOption[] salesRepsAdServing { get; set; } {
        salesRepsAdServing = new List<SelectOption>();
        List<Employee__c> salesReps = [Select Name from Employee__c WHERE Sales_Rep__c = true AND Enabled__c = true ORDER BY Name ASC];
        if (salesReps == null || salesReps.size() == 0)
            salesRepsAdServing.add(new SelectOption('--NONE--', '--NONE--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsAdServing.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] salesRepsEyeDemand { get; set; } {
        salesRepsEyeDemand = new List<SelectOption>();
        List<Employee__c> salesReps = [Select Name from Employee__c WHERE Sales_Rep__c = true AND Enabled__c = true ORDER BY Name ASC];
        if (salesReps == null || salesReps.size() == 0)
            salesRepsEyeDemand.add(new SelectOption('--NONE--', '--NONE--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsEyeDemand.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] analystList { get; set; } {
        analystList = new List<SelectOption>();
        analystList.add(new SelectOption('--NONE--', '--NONE--', false));
        List<Employee__c> analysts = [Select Name from Employee__c WHERE Analyst__c = true AND Enabled__c = true ORDER BY Name ASC];
        if (analysts != null || analysts.size() > 0)
            for (Employee__c analyst : analysts) {
                analystList.add(new SelectOption(analyst.Id, analyst.Name));
            }
    }
    public AccountExtension(ApexPages.StandardController stdController) {
        m_sc = stdController;
        account = (Account) stdController.getRecord();
        setUserRole();
        if (account.Id == null && ApexPages.currentPage().getParameters().get('Id') == null) {
            account = new Account();
            pageTitle = 'New Account';
            account.Type = 'Client';
            account.OwnerId = UserInfo.getUserId();
            setSalesReps();
        } else {
            account = [select
                Type,
                Name,
                OwnerId,
                Account_Currency__c,
                Site,
                Legal_Name__c,
                Website,
                Description,
                Credit_Limit__c,
                Adserving_Sales_Rep__c,
                eyedemand_Sales_Rep__c,
                analyst__c,
                Enable_EyeVerify__c,
                Org_ID__c,
                BillingCountryCode,
                BillingStreet,
                BillingCity,
                BillingStateCode,
                BillingPostalCode,
                Phone,
                Region__c,
                Credit_App_Approved__c,
                Credit_Card__c,
                Ad_Serving_Agreement_Signed__c,
                Invoice_Addressed_To__c,
                Out_of_Sync__c
            from Account where Id = : account.Id][0];
            pageTitle = account.Name;
            selectedAdServingRep = account.Adserving_Sales_Rep__c;
            selectedEyeDemandRep = account.eyedemand_Sales_Rep__c;
            selectedAnalyst = account.Analyst__c;
        }
    }

    private void saveObjects() {
        runAccountNameValidation();
        account.Adserving_Sales_Rep__c = selectedAdServingRep;
        account.eyedemand_Sales_Rep__c = selectedEyeDemandRep;
        account.Analyst__c = ( !selectedAnalyst.equals('--NONE--') ? selectedAnalyst : null);
        upsert(account);
    }

    public PageReference save() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (DuplicateAccountNameException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account name already exists!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        // After save, switch to detail view
        return (new ApexPages.StandardController(account)).view();
    }

    public PageReference saveNew() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (DuplicateAccountNameException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account name already exists!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        // After save, switch to new view
        String s = '/' + ('' + account.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }

    public PageReference cancel() {
        // If new Account, redirect to main Account page
        return m_sc.cancel();
    }

    public void setUserRole() {
        String userRole = [Select Name from UserRole where Id = :UserInfo.getUserRoleId()][0].Name;
        isAdmin = (userRole == 'eyeReturn Operations');
    }

    public void setSalesReps() {
        String fullname = UserInfo.getName();
        List<Employee__c> salesRepList = [select Id from Employee__c where Name = :fullname];
        if (salesRepList.size() > 0) {
            Employee__c salesRep = salesRepList[0];
            selectedAdServingRep = salesRep.Id;
            selectedEyeDemandRep = salesRep.Id;
        }
    }

    public void runAccountNameValidation() {
        Account[] matchedAccounts;
        if (account.Id == null)
            matchedAccounts = [select Id from Account where Name = :account.Name];
        else
            matchedAccounts = [select Id from Account where Name = :account.Name and Id <> :account.Id];
        if (!matchedAccounts.isEmpty()) {
            accountNameErrorMsg = 'Name already exists';
            classInputAccountName = 'error';
            throw new DuplicateAccountNameException('Account name already exists!');
        } else {
            accountNameErrorMsg = '';
            classInputAccountName = '';
        }
    }

    public void validateAccountName() {
        try {
            runAccountNameValidation();
        } catch(DuplicateAccountNameException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account name already exists!');
            ApexPages.addMessage(myMsg);
        }
    }
}