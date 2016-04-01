public class AnalystToOrgBrandMapping {
    private ApexPages.StandardController m_sc;
    public Account account { get; private set; }
    public Brand__c brand { get; private set; }
    public Account_Brand_Junction__c accBrandJunc { get; private set; }
    public Boolean isAccountBrand { get; set; }
    public List<SelectOption> brandPickList { get; set;}
    public String selectedBrand { get; set; }
    
    public AnalystToOrgBrandMapping(ApexPages.StandardController controller) {
        m_sc = controller;
        account = (Account) controller.getRecord();
        Id id = account.Id;
        account = (id == null) ? new Account() : 
            [SELECT Id, Name FROM Account WHERE Id = :id];
        brand = new Brand__c();
        accBrandJunc = new Account_Brand_Junction__c();
        brandPicklist = null;
        selectedBrand = null;
        isAccountBrand = false;
    } 
    
    public void getBrandOptions(){
        List<Brand__c> brandList  = [SELECT Id, Name FROM Brand__c where Id in (SELECT Brand__c FROM Account_Brand_Junction__c WHERE account__c = :accBrandJunc.account__c) ORDER BY Name DESC];
        brandPicklist = new List<SelectOption>();
        if (!brandList.isEmpty()) {
            Id brandId = brandList.get(0).Id;
            if(selectedBrand == null)
                selectedBrand = (brandId == null ? '' : brandId);

            for (Integer i = 0; i < brandList.size(); i++)
                brandPicklist.add(new SelectOption(brandList.get(i).Id, brandList.get(i).Name));
        }
        
    }

    public PageReference save() {
        try {
            if(!isAccountBrand){
                Account[] matchedAccounts = [select Id from Account where Name = :account.Name];
                if (matchedAccounts.isEmpty()) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account name does not exist! Please select an existing account.');
                    ApexPages.addMessage(myMsg);
                    return null;
                } else{
                    if(account != null && account.Analyst__c != null){
                        account.Id = matchedAccounts[0].Id;
                        update account;
                    }
                }
            }else{
                if(accBrandJunc != null && accBrandJunc.Analyst__c != null){
                    Account_Brand_Junction__c[] matchedAccBrandJunc = [select Id from Account_Brand_Junction__c where account__c = :accBrandJunc.Account__c AND brand__c =:selectedBrand];
                    if (matchedAccBrandJunc.isEmpty()) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Account Brand Junction does not exist! Please select an existing account brand junction record.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    } else{
                        accBrandJunc.Id = matchedAccBrandJunc[0].Id;
                        //if (selectedBrand != '') accBrandJunc.Brand__c = selectedBrand;
                        update(accBrandJunc);
                    }
                }
            } 
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        //  After Save, navigate to the default view page:
        PageReference retPage = new PageReference('/apex/Analyst_To_Org_Brand_Mapping');
        retPage.setRedirect(true);
        return retPage;
    }

}