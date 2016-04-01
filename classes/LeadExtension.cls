public class LeadExtension {
    private ApexPages.StandardController m_sc;
    public Lead lead { get; set; }
    public String pageTitle { get; set; }
    public Boolean overrideRegion { get; set; }
    // Lead Source Start
    public String selectedLeadSource { get {
        if (selectedLeadSource == null)
            selectedLeadSource = '--None--';
        return selectedLeadSource;
    } set; }
    public SelectOption[] leadSources { get; set; } {
        leadSources = new List<SelectOption>();
        List<Lead_Source__c> leadSourceList = [select Id, Name from Lead_Source__c];
        leadSources.add(new SelectOption('--None--', '--None--', true));
        for (Lead_Source__c leadSource : leadSourceList)
            leadSources.add(new SelectOption(leadSource.Id, leadSource.Name));
    }
    // Lead Source End

    public LeadExtension(ApexPages.StandardController stdController) {
        m_sc = stdController;
        lead = (Lead) stdController.getRecord();
        if (lead.Id == null && ApexPages.currentPage().getParameters().get('Id') == null) {
            overrideRegion = false;
            lead = new Lead();
            pageTitle = 'New Lead';
            lead.OwnerId = UserInfo.getUserId();
            lead.Region__c = 'Canada';
            selectedLeadSource = null;
        } else {
            lead = [select
                Company,
                Name,
                FirstName,
                LastName,
                Title,
                Email,
                Phone,
                Region__c,
                OwnerId,
                Status,
                Lead_Source__c,
                Advertiser__c,
                Industry,
                Country,
                CountryCode,
                Street,
                City,
                StateCode,
                PostalCode,
                Notes__c,
                Department__c
            from Lead where Id=:lead.Id][0];
            pageTitle = lead.Name;
            if (lead.Country != lead.Region__c)
                overrideRegion = true;
            else
                overrideRegion = false;
            selectedLeadSource = lead.Lead_Source__c;
            setRegion();
        }
    }

    public PageReference save() {
        try {
            lead.Lead_Source__c = selectedLeadSource;
            upsert(lead);
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        // After save, switch to detail view
        return (new ApexPages.StandardController(lead)).view();
    }

    public PageReference saveNew() {
        try {
            lead.Lead_Source__c = selectedLeadSource;
            upsert(lead);
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // After save, switch to new view
        String s = '/' + ('' + lead.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }

    public PageReference cancel() {
        return m_sc.cancel();
    }

    public void setRegion() {
        if (!overrideRegion) {
            if (lead.CountryCode == 'CA')
                lead.Region__c = 'Canada';
            else if (lead.CountryCode == 'US')
                lead.Region__c = 'United States';
        }
    }
}