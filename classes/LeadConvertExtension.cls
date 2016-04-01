public class LeadConvertExtension {
    public Lead lead { get; set; }
    public Account account { get; set; }
    public Contact contact { get; set; }
    public boolean createAccount { get; set; }
    public boolean showAccount { get; set; }
    public boolean showContact { get; set; }
    public String accountNameErrorMsg { get; set; }
    public String classInputAccountName { get; set; }
    public Boolean overrideRegion { get; set; }
    String leadId = ApexPages.currentPage().getParameters().get('id');
    public Employee__c unassignedRep { get {
        unassignedRep = [select Id from Employee__c where Name = '-UNASSIGNED-'];
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
    public SelectOption[] salesRepsAdServing { get; set; } {
        salesRepsAdServing = new List<SelectOption>();
        List<Employee__c> salesReps = [Select Name from Employee__c];
        if (salesReps == null)
            salesRepsAdServing.add(new SelectOption('--NONE--', '--NONE--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsAdServing.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }
    public SelectOption[] salesRepsEyeDemand { get; set; } {
        salesRepsEyeDemand = new List<SelectOption>();
        List<Employee__c> salesReps = [Select Name from Employee__c];
        if (salesReps == null)
            salesRepsEyeDemand.add(new SelectOption('--NONE--', '--NONE--', true));
        else
            for (Employee__c salesRep : salesReps) {
                salesRepsEyeDemand.add(new SelectOption(salesRep.Id, salesRep.Name));
            }
    }

    // Trafficker Start
    public String selectedTrafficker { get {
        if (selectedTrafficker == null)
            selectedTrafficker = '--None--';
        return selectedTrafficker;
    } set; }
    public SelectOption[] traffickers { get; set; } {
        traffickers = new List<SelectOption>();
        List<Employee__c> employees = [select Id, Name from Employee__c where Trafficker__c = true];
        traffickers.add(new SelectOption('--None--', '--None--', true));
        for (Employee__c employee : employees) {
            traffickers.add(new SelectOption(employee.Id, employee.Name));
        }
    }
    // Trafficker End

    public LeadConvertExtension(ApexPages.StandardController stdController) {
        // Get and assign all variables
        createAccount = true;
        showAccount = true;
        showContact = true;
        lead = [select Name, Company, Notes__c, FirstName, LastName, Email, Fax, Phone, Street, City, Country, CountryCode, PostalCode, State, StateCode, OwnerId, Status, Region__c from Lead where Id = :leadId][0];
        account = new Account();
        contact = new Contact();
        overrideRegion = false;

        // Assign account information
        try {
            account.Name = lead.Company;
            // Run validation to see if account already exists
            runAccountNameValidation();
            account.Phone = lead.Phone;
            account.Fax = lead.Fax;
            account.BillingStreet = lead.Street;
            account.BillingCity = lead.City;
            account.BillingCountryCode = lead.CountryCode;
            account.BillingPostalCode = lead.PostalCode;
            account.BillingStateCode = lead.StateCode;
            account.OwnerId = lead.OwnerId;
            account.Description = lead.Notes__c;
            account.Region__c = lead.Region__c;
        } catch (DuplicateAccountNameException e) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Account already exists. Contact account set.');
                ApexPages.addMessage(myMsg);
                createAccount = false;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }

        // Assign contact information
        try {
            contact.FirstName = lead.FirstName;
            contact.LastName = lead.LastName;
            contact.Email = lead.Email;
            contact.Phone = lead.Phone;
            contact.Fax = lead.Fax;
            contact.MailingStreet = lead.Street;
            contact.MailingCity = lead.City;
            contact.MailingCountryCode = lead.CountryCode;
            contact.MailingPostalCode = lead.PostalCode;
            contact.MailingStateCode = lead.StateCode;
            contact.OwnerId = lead.OwnerId;
            if (!createAccount) {
                Account tempAccount = [select Id from Account where Name = :lead.Company];
                contact.AccountId = tempAccount.Id;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference save() {
        Database.LeadConvert converter = new Database.LeadConvert();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];

        try {
            // Save account if checked
            if (createAccount) {
                runAccountNameValidation();
                account.Adserving_Sales_Rep__c = selectedAdServingRep;
                // account.Sales_Rep_Ad_Serving__c = selectedAdServingRep;
                account.eyedemand_Sales_Rep__c = selectedEyeDemandRep;
                // account.Sales_Rep_EyeDemand__c = selectedEyeDemandRep;
                upsert(account);
                contact.AccountId = account.Id;
                upsert(contact);
                converter.setLeadId(lead.id);
                converter.setAccountId(account.id);
                converter.setContactId(contact.id);
                converter.setConvertedStatus(convertStatus.MasterLabel);
                converter.setDoNotCreateOpportunity(true);
                Database.ConvertLead(converter, true);
            } else {
                insert(contact);
                converter.setLeadId(lead.id);
                converter.setAccountId(contact.AccountId);
                converter.setContactId(contact.id);
                converter.setConvertedStatus(convertStatus.MasterLabel);
                converter.setDoNotCreateOpportunity(true);
                Database.ConvertLead(converter, true);
            }
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch(DuplicateAccountNameException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account name already exists!');
            ApexPages.addMessage(myMsg);
            return null;
        }

        // After save, switch to default view
        if (createAccount)
            return (new ApexPages.StandardController(account)).view();
        else
            return (new ApexPages.StandardController(contact)).view();
    }

    public PageReference cancel() {
        return (new ApexPages.StandardController(lead)).view();
    }

    public void runAccountNameValidation() {
        Account[] matchedAccounts = [select Id from Account where Name=:account.Name];
        if (!matchedAccounts.isEmpty()) {
            accountNameErrorMsg = 'An account with that name already exists. Uncheck "Convert to Account" if you want to add contact to the existing account';
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

    public void setRegion() {
        if (!overrideRegion) {
            if (account.BillingCountryCode == 'CA')
                account.Region__c = 'Canada';
            else if (account.BillingCountryCode == 'US')
                account.Region__c = 'United States';
        }
    }
}