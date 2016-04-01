global with sharing class ReportALLSalesQuotaVsClosed {
    global static Employee__c salesRep {get;set;}
    global static Decimal salesActual {get;set;}
    global static Decimal salesQuota {get;set;}
    global static String quarter {get;set;}
    global static String THIS_YEAR {get;set;}
    global static List<BatChartData> barChartDataList{get;set;}
    
    global class BatChartData {
        global String id { get; set; }
        global String name { get; set; }
        global Decimal salesActualAmt { get; set; }
        global Decimal salesQuotaAmt { get; set; }
        global BatChartData(String name, Decimal salesActualAmt, Decimal salesQuotaAmt) {
            this.name = name;
            this.salesActualAmt = salesActualAmt;
            this.salesQuotaAmt = salesQuotaAmt;
        }
    }

    global ReportALLSalesQuotaVsClosed() {}
    /**
      Loads most Closed Amt vs Sales Quota for each Sales Rep
    */
    @RemoteAction
    global static BatChartData[] loadOpps() {
        try {
            List<Employee__c> salesRepList = [SELECT Id, Name FROM Employee__c WHERE Sales_Rep__c = TRUE];
            barChartDataList = new List < BatChartData > ();
            for (Employee__c e: salesRepList)
            barChartDataList.add(new BatChartData(e.Name, getSalesActual(e), getSalesQuota(e)));
            return barChartDataList;
        } catch (Exception e) {
            System.debug('ERROR:' + e);
            return null;
        }
    }

    global static Decimal getSalesActual(Employee__c emp) {
        try {
            salesActual = 0.0;
            salesRep = emp;
            DateTime d = datetime.now();
            THIS_YEAR = d.format('YYYY');
            if (salesRep != null) {
                List < Opportunity > opportunitiesOwned = [SELECT Display_Budget__c, Mobile_Budget__c, Primary_Display_Sales_Rep__c, Primary_Mobile_Sales_Rep__c, Secondary_Display_Sales_Rep__c, Secondary_Mobile_Sales_Rep__c FROM Opportunity WHERE CloseDate = THIS_FISCAL_QUARTER AND StageName = 'Closed Won'];

                for (Opportunity o: opportunitiesOwned) {
                    if (o.Primary_Display_Sales_Rep__c == salesRep.Id && o.Secondary_Display_Sales_Rep__c == salesRep.Id) salesActual += (o.Display_Budget__c != null ? o.Display_Budget__c / 2 : 0);
                    else if (o.Primary_Display_Sales_Rep__c == salesRep.Id || o.Secondary_Display_Sales_Rep__c == salesRep.Id) salesActual += (o.Display_Budget__c != null ? o.Display_Budget__c : 0);

                    if (o.Primary_Mobile_Sales_Rep__c == salesRep.Id && o.Secondary_Mobile_Sales_Rep__c == salesRep.Id) salesActual += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c / 2 : 0);
                    else if (o.Primary_Mobile_Sales_Rep__c == salesRep.Id || o.Secondary_Mobile_Sales_Rep__c == salesRep.Id) salesActual += (o.Mobile_Budget__c != null ? o.Mobile_Budget__c : 0);
                }
            }
        } catch (Exception e) {
            System.debug('ERROR:' + e);
        }
        return salesActual;
    }

    global static Decimal getSalesQuota(Employee__c emp) {
        try {
            salesQuota = 0.0;
            salesRep = emp;
            DateTime d = datetime.now();
            THIS_YEAR = d.format('YYYY');
            if (salesRep != null) {
                List < Sales_Quota__c > quotasOwned = [SELECT Q1_Quota__c, Q2_Quota__c, Q3_Quota__c, Q4_Quota__c FROM Sales_Quota__c WHERE Year__c = : THIS_YEAR AND Employee__c = : salesRep.Id];

                quarter = 'Q' + (((System.Today().Month() - 1) / 3) + 1);
                String qtrFilter = quarter + '_Quota__c';
                if (!quotasOwned.isEmpty()) {
                    for (Sales_Quota__c sq: quotasOwned)
                    salesQuota += (Decimal) sq.get(qtrFilter);
                }
            }
        } catch (Exception e) {
            System.debug('ERROR:' + e);
        }
        return salesQuota;
    }
}