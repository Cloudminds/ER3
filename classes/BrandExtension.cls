public class BrandExtension {
    private ApexPages.StandardController m_sc;
    String accId = ApexPages.currentPage().getParameters().get('accid');
    public Account_Brand_Junction__c abj { get; set; }
    public Brand__c brand { get; set; }
    public String brandId { get; set; }
    public Opportunity oppShell { get; set; }
    public boolean isAdmin { get; set; }
    public String pageTitle { get; set; }
    public String brandNameErrorMsg { get; set; }
    public String classInputBrandName { get; set; }
    public Boolean editing { get; set; }

    public BrandExtension(ApexPages.StandardController stdController) {
        oppShell = new Opportunity();
        m_sc = stdController;
        brand = (Brand__c) stdController.getRecord();
        setUserRole();
        if (brand.Id == null && ApexPages.currentPage().getParameters().get('Id') == null) {
            brand = new Brand__c();
            pageTitle = 'New Brand';
            editing = false;
        } else {
            brand = [select
                Name,
                Brand_ID__c
            from Brand__c where Id = : brand.Id][0];
            pageTitle = brand.Name;
            brandId = brand.Id;
            editing = true;
        }
        if (accId != null)
            oppShell.AccountId = accId;
    }

    private void saveObjects() {
        if (editing) {
            // Update all junction names
            upsert brand;
            if ([SELECT Id FROM Account_Brand_Junction__c WHERE Brand__c = :brand.Id].size() > 0) {
                List<Account_Brand_Junction__c> abjs = [SELECT Name, Account__r.Name FROM Account_Brand_Junction__c WHERE Brand__c = :brand.Id];
                for (Account_Brand_Junction__c abj : abjs) {
                    abj.Name = abj.Account__r.Name + ' - ' + brand.Name;
                    update abj;
                }
            }

        } else {
            setBrand();
            isJunctionUnique();
            createJunctionObject();
        }

    }

    public PageReference save() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (DuplicateJunctionException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Relationship already exists between Client and Brand');
            ApexPages.addMessage(myMsg);
            return null;
        }
        // After save, switch to detail view
        return (new ApexPages.StandardController(brand)).view();
    }

    public PageReference saveNew() {
        try {
            saveObjects();
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (DuplicateJunctionException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Relationship already exists between Client and Brand');
            ApexPages.addMessage(myMsg);
            return null;
        }
        // After save, switch to new view
        String s = '/' + ('' + brand.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new PageReference(s);
    }

    public PageReference cancel() {
        return m_sc.cancel();
    }

    public void setUserRole() {
        String userRole = [Select Name from UserRole where Id = :UserInfo.getUserRoleId()][0].Name;
        isAdmin = (userRole == 'eyeReturn Operations');
    }

    private void setBrand() {
        if (brandId == null || [SELECT Id, Name, Brand_ID__c FROM Brand__c WHERE Id = :brandId].size() == 0) {
            insert brand;
            brandId = brand.Id;
        } else {
            brand = [SELECT Id, Name, Brand_ID__c FROM Brand__c WHERE Id = :brandId];
        }
    }

    // Verify that Junction object relationship is unique
    private void isJunctionUnique() {
        if ([SELECT Id FROM Account_Brand_Junction__c WHERE Account__c = :oppShell.AccountId AND Brand__c = :brand.Id].size() > 0)
            throw new DuplicateJunctionException('Relationship already exists between Client and Brand');
    }

    // Create a new junction object between the client and brand
    private void createJunctionObject() {
        Account_Brand_Junction__c abj = new Account_Brand_Junction__c();
        String clientName = [SELECT Name FROM Account WHERE Id = :oppShell.AccountId][0].Name;
        abj.Name = clientName + ' - ' + brand.Name;
        abj.Account__c = oppShell.AccountId;
        abj.Brand__c = brandId;
        insert abj;
    }
}