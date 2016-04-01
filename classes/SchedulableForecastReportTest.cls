@isTest
public class SchedulableForecastReportTest {
    public static testMethod void testSchedule() {
        Test.startTest();
        SchedulableForecastReport schedRpt = new SchedulableForecastReport ();
        Id job_id = System.schedule('test', '0 0 0 30 12 ? 2099', schedRpt);
        System.assertNotEquals(null, job_id);
        Test.stopTest();
    }
}