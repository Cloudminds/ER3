public class ContactExtension {
    private ApexPages.StandardController m_sc;
    public Contact contact { get; set; }
    public String pageTitle { get; set; }
    String accId = ApexPages.currentPage().getParameters().get('accid');

    public ContactExtension(ApexPages.StandardController stdController) {
        m_sc = stdController;
        contact = (Contact) stdController.getRecord();
        if (contact.Id == null && ApexPages.currentPage().getParameters().get('Id') == null) {
            contact = new Contact();
            pageTitle = 'New Contact';
            contact.OwnerId = UserInfo.getUserId();
            if (accId != null)
                contact.AccountId = accId;
        } else {
            contact = [select
                Type__c,
                AccountId,
                FirstName,
                LastName,
                Name,
                Email,
                ReportsToId,
                Contact_ID__c,
                Title,
                Department,
                Phone,
                MobilePhone,
                Fax,
                OwnerId,
                MailingCountryCode,
                MailingStreet,
                MailingCity,
                MailingStateCode,
                MailingPostalCode,
                Email_2__c,
                Email_3__c,
                Email_4__c,
                Out_of_Sync__c,
                Lead_Source__c
            from Contact where Id = : contact.Id][0];
            pageTitle = Contact.Name;
        }
    }
    
    private void saveObjects() {
        upsert(contact);
    }
    
    public PageReference save() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // After save, switch to detail view
        return (new ApexPages.StandardController(contact)).view();
    }
    
    public PageReference saveNew() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        // After save, switch to new view
        String s = '/' + ('' + contact.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }

    public PageReference cancel() {
        // If new Account, redirect to main Account page
        return m_sc.cancel();
    }
}