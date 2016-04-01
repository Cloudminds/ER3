@isTest
private class AccountRatecardTest {
	
    static testMethod void runDateOverlapTest() {
        Test.startTest();
     	List<Account> accountList = new List<Account>();
     	List<Ratecard_Account__c> ratecardAccountList = new List<Ratecard_Account__c>();
     	   
        for(Integer i = 0; i < 15; i++){
        	Account client = ObjectFactory.createCAClient('C'+i);
        	accountList.add(client);
        }
        insert accountList;
        
        for(Integer i = 0; i < 15; i++){
        	Ratecard_Account__c rateAcc = new Ratecard_Account__c(
        		Activation_Date__c = date.today(), 
        		Expiration_Date__c = date.today(), 
        		Account__c = accountList.get(i).Id, 
        		Title__c = 'Ratecard ' + accountList.get(i).Name,
        		DB4_Last_Save_Date__c = date.today()
        	);
        	ratecardAccountList.add(rateAcc);
        }
        insert ratecardAccountList;
        
        Test.stopTest();
    }
}