@isTest
public class DataTableHandlerTest {

    // Validation test
    public static testMethod void ValidationTest() {
        Test.startTest();

        DataTableHandler datatablehandler = new DataTableHandler();		
		datatablehandler.columnFields = 'Id, Name, CreatedDate';
        datatablehandler.columnTitles = 'Id, Name, CreatedDate';
        datatablehandler.soql = 'Select Id, Name, CreatedDate From Account';
        datatablehandler.tableId = 'datatableId';
		datatablehandler.records = null;
		
		// Create objects for test
        List<Account> tempAcc = new List<Account>();
        for(Integer i = 0; i < 10; i++)
        	tempAcc.add(ObjectFactory.createCAClient('Client'+i));
        insert tempAcc;
        
        System.assertEquals(datatablehandler.columnFieldsList.size(), 3);
        System.assertEquals(datatablehandler.columnTitlesList.size(), 3);
        System.assertEquals(datatablehandler.records.size(), 1);
        

    	// Set assert parameters
        Test.stopTest();
    }

}