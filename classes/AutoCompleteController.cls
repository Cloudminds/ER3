/*
* Controller to implement the auto-complete feature on the Visualforce page
*/
public with sharing class AutoCompleteController {
    // Instance fields
    public String searchTerm {get; set;}

    // Constructor
    public AutoCompleteController(ApexPages.StandardController stdController) {}

    public AutoCompleteController() {}

    // JS Remoting action called when searching for an account name
    @RemoteAction
    public static List<Account> searchAccount(String searchTerm) {
        System.debug('Account Name is: ' + searchTerm);
        List<Account> accounts = Database.query('Select Id, Name from Account where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return accounts;
    }

    @RemoteAction
    public static List<Brand__c> searchBrand(String searchTerm) {
        System.debug('Brand Name is: ' + searchTerm);
        List<Brand__c> brands = Database.query('Select Id, Name from Brand__c where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return brands;
    }
}