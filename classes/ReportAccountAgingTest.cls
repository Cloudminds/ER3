@isTest
public class ReportAccountAgingTest {

    // Init the page controller
    private static ReportAccountAging initPage() {
        Test.setCurrentPageReference(Page.Report_Account_Aging);
        return new ReportAccountAging();
    }

    private static testMethod void initTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CobwebsHttpCalloutMockImpl());

        // Create all objects for test
        Account client = ObjectFactory.createCAClient('Client');
        insert client;
        Brand__c brand = ObjectFactory.createBrand('Brand');
        insert brand;
        Account_Brand_Junction__c abj = ObjectFactory.createAccountBrandJunction(client, brand);
        insert abj;
        Opportunity opportunity = ObjectFactory.createRFPOpportunity(client, brand, 'Opportunity');
        insert opportunity;
        Contact contact = ObjectFactory.createContact(client);
        insert contact;
        Task task = ObjectFactory.createTask();
        task.WhoId = contact.Id;
        insert task;
        ReportAccountAging pageController = initPage();
        ReportAccountAging.AgingData innerClass = new ReportAccountAging.AgingData('test', 'test', DateTime.now());
        ReportAccountAging.AgingData innerClassNew = new ReportAccountAging.AgingData('test', 'test', Date.today());
        ReportAccountAging.AgingData innerClassClone = new ReportAccountAging.AgingData('test2', 'test2', DateTime.now());
        innerClass.calculateAge();
        innerClass.compareTo(innerClassClone);
        Test.stopTest();
    }
}