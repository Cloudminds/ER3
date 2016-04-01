public class AccountBrandJunctionExtension {
    private ApexPages.StandardController m_sc;
    public Account_Brand_Junction__c abj { get; set; }
    public boolean isAdmin { get; set; }
    public String pageTitle { get; set; }
    public String brandNameErrorMsg { get; set; }
    public String classInputBrandName { get; set; }
    public Boolean editing { get; set; }
    public Map<String, String> getParams = ApexPages.currentPage().getParameters();
    public String saveURL = getParams.get('saveURL');
    public String retURL = getParams.get('retURL');

    // Constructor
    public AccountBrandJunctionExtension(ApexPages.StandardController stdController) {
        Integer i = 0;
        m_sc = stdController;
        abj = (Account_Brand_Junction__c) stdController.getRecord();
        setUserRole();

        // New junction
        if (abj.Id == null) {
            abj = new Account_Brand_Junction__c();
            pageTitle = 'New Account Brand Link';
            editing = false;

            // Autopopulate fields
            if (saveURL != null) {
                saveURL = saveURL.replaceAll('/', '');
                i++;
                System.debug(i);
                if ([select Id from Account where Id = :saveURL].size() > 0) {
                    abj.Account__c = [select Id from Account where Id = :saveURL][0].Id;
                } else if ([select Id from Brand__c where Id = :saveURL].size() > 0) {
                    abj.Brand__c = [select Id from Brand__c where Id = :saveURL][0].Id;
                }
                i++;
                System.debug(i);
            }
        }
        // Existing junction
        else {
            abj = [
                select Name, Account__c, Brand__c, Account__r.Name, Brand__r.Name
                from Account_Brand_Junction__c
                where Id = :abj.Id
            ][0];
            pageTitle = abj.Name;
            editing = true;
        }
    }

    public PageReference save() {
        try {
            isJunctionUnique();
            String accountName = [select Name from Account where Id = :abj.Account__c][0].Name;
            String brandName = [select Name from Brand__c where Id = :abj.Brand__c][0].Name;
            abj.Name = accountName + ' - ' + brandName;
            upsert abj;
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (DuplicateJunctionException e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Relationship already exists between Client and Brand');
            ApexPages.addMessage(myMsg);
            return null;
        }

        // After save, switch to account detail view
        if (retURL == null)
            return new PageReference('/' + ((String) abj.Id).substring(0, 2) + '/o');
        return new PageReference(retURL);

    }

    public PageReference cancel() {
        return m_sc.cancel();
    }

    public void setUserRole() {
        String userRole = [Select Name from UserRole where Id = :UserInfo.getUserRoleId()][0].Name;
        isAdmin = (userRole == 'eyeReturn Operations');
    }

    // Verify that Junction object relationship is unique
    private void isJunctionUnique() {
        if ([select Id from Account_Brand_Junction__c where Account__c = :abj.Account__c and Brand__c = :abj.Brand__c and Id <> :abj.Id].size() > 0)
            throw new DuplicateJunctionException('Relationship already exists between Client and Brand');
    }
}