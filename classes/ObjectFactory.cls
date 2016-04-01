@isTest
global class ObjectFactory {

    // Create an Employee
    global static Employee__c createEmployee(String name) {
        Employee__c employee = new Employee__c();
        employee.Name = name;
        employee.First_Name__c = 'First';
        employee.Last_Name__c = 'Last';
        employee.Analyst__c = true;
        employee.Trafficker__c = true;
        return employee;
    }

    // Create an Employee with First and Last Name
    global static Employee__c createEmployee(String firstName, String lastName) {
        Employee__c employee = new Employee__c();
        employee.First_Name__c = firstName;
        employee.Last_Name__c = lastName;
        employee.Name = firstName + ' ' + lastName;
        employee.Analyst__c = true;
        employee.Trafficker__c = true;
        return employee;
    }

    // Create a default Sales_Rep
    global static void createDefaultSalesRep() {
        Employee__c salesRep = new Employee__c();
        salesRep.Name = '-UNASSIGNED-';
        salesRep.First_Name__c = '-';
        salesRep.Last_Name__c = '-';
        salesRep.Sales_Rep__c = true;
        insert salesRep;
    }

    // Create a new Sales_Rep
    global static Employee__c createSalesRep(String name) {
        Employee__c salesRep = new Employee__c();
        salesRep.Name = name;
        salesRep.First_Name__c = 'First';
        salesRep.Last_Name__c = 'Last';
        salesRep.eyereports_ID__c = 1;
        salesRep.eyereturnFinance_ID__c = 5001;
        salesRep.Sales_Rep__c = true;
        salesRep.Enabled__c = true;
        return salesRep;
    }

    // Create a new Sales_Rep with external IDs
    global static Employee__c createSalesRep(String name, Integer erId, Integer erfId) {
        Employee__c salesRep = new Employee__c();
        salesRep.Name = name;
        salesRep.First_Name__c = 'First';
        salesRep.Last_Name__c = 'Last';
        salesRep.eyereports_ID__c = erId;
        salesRep.eyereturnFinance_ID__c = erfId;
        salesRep.Sales_Rep__c = true;
        return salesRep;
    }

    // Create a new Contact
    global static Contact createContact(Account account) {
        Contact contact = new Contact();
        Contact.AccountId = account.Id;
        contact.Type__c = 'Sales';
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.Email = 'email@email.com';
        return contact;
    }

    // Create a new Canadian Account/Client
    global static Account createCAClient(String name) {
        Account account = new Account();
        account.Type = 'Client';
        account.Name = name;
        account.Region__c = 'Canada';
        return account;
    }

    // Create a new US Account/Client
    global static Account createUSClient(String name) {
        Account account = new Account();
        account.Type = 'Client';
        account.Name = name;
        account.Region__c = 'United States';
        return account;
    }

    // Create a new Brand
    global static Brand__c createBrand(String name) {
        Brand__c brand = new Brand__c();
        brand.Name = name;
        return brand;
    }

    // Create a new Brand with Account
    global static Account_Brand_Junction__c createAccountBrandJunction(Account account, Brand__c brand) {
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        abj.Brand__c = brand.Id;
        abj.Account__c = account.Id;
        return abj;
    }

    // Create a new Opportunity
    private static Opportunity createOpportunity(Account account, Brand__c brand, String name) {
        Opportunity opportunity = new Opportunity();
        opportunity.Type = 'Adserving';
        opportunity.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Adserving'][0].Id;
        opportunity.Name = name;
        opportunity.AccountId = account.Id;
        opportunity.Brand__c = brand.Id;
        opportunity.IsAPI__c = false;
        opportunity.CloseDate = Date.today();
        opportunity.Currency__c = 'CDN';
        opportunity.Region__c = 'Canada';
        return opportunity;
    }

    // Create a new RFP Opportunity
    global static Opportunity createRFPOpportunity(Account account, Brand__c brand, String name) {
        Opportunity opportunity = createOpportunity(account, brand, name);
        opportunity.StageName = 'RFP/Proposal';
        return opportunity;
    }

    // Create a new Closed Won Opportunity
    global static Opportunity createClosedWonOpportunity(Account account, Brand__c brand, String name) {
        Opportunity opportunity = createOpportunity(account, brand, name);
        opportunity.StageName = 'Closed Won';
        return opportunity;
    }
    
    // Create a new Creative Opportunity
    global static Opportunity createCreativeOpportunity(Account account, Brand__c brand, String name) {
        Opportunity opportunity = createOpportunity(account, brand, name);
        opportunity.StageName = 'Ready To Bill';
        try {
        	Map<String,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
        	Schema.RecordTypeInfo rtByName =  rt_Map.get('Creative Production');
        	opportunity.RecordTypeId = rtByName.getRecordTypeId();
        } catch (System.Exception e){
    		e.getStackTraceString();
        }
        return opportunity;
    }

    global static Campaign_Questionnaire__c createQuestionnaire() {
        Campaign_Questionnaire__c cq = new Campaign_Questionnaire__c();
        cq.Budget_Priority__c = 'Must spend entire budget';
        cq.Campaign_s_Main_Goal__c = 'CTR';
        cq.Third_Party__c = false;
        cq.Billing_Impression_Nmbers__c = false;
        cq.Billing_Fixed_CPMs__c = false;
        cq.Pacing_Spend_vs_Impressions__c = 'Spend';
        return cq;
    }

    // Create a new Task
    global static Task createTask() {
        Task task = new Task();
        task.Subject = 'Test Task';
        task.ActivityDate = Date.today();
        return task;
    }

    // Create a new Month_Spend
    global static Month_Spend__c createMonthSpend(Opportunity opportunity, Integer amount) {
        Month_Spend__c monthSpend = new Month_Spend__c();
        monthSpend.Type__c = 'Display';
        monthSpend.Amount__c = amount;
        monthSpend.Month__c = 'January';
        monthSpend.Year__c = Date.today().year();
        monthSpend.Opportunity__c = opportunity.Id;
        return monthSpend;
    }

    global static Month_Spend__c createMonthSpendWithDate(Opportunity opportunity, Integer amount, String month, Integer year) {
        Month_Spend__c monthSpend = new Month_Spend__c();
        monthSpend.Type__c = 'Display';
        monthSpend.Amount__c = amount;
        monthSpend.Month__c = month;
        monthSpend.Year__c = year;
        monthSpend.Opportunity__c = opportunity.Id;
        return monthSpend;
    }

    global static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(Alias = 'standt', Email='teststandarduser@eyereturn.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@eyereturn.com');
        return user;
    }

    // Create a new Lead Source
    global static Lead_Source__c createLeadSource() {
        Lead_Source__c leadSource = new Lead_Source__c();
        leadSource.Name = 'Test Source';
        return leadSource;
    }
}