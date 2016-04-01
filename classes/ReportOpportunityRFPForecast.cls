public class ReportOpportunityRFPForecast {
    public List<Opportunity> opportunities { get; set; }
    public transient List<ForecastData> forecastCA { get; set; }
    public transient List<ForecastData> forecastUS { get; set; }
    public transient List<ForecastData> forecastCATable { get; set; }
    public transient List<ForecastData> forecastUSTable { get; set; }
    @TestVisible private Decimal forecastDisplayCATotal { get; set; }
    @TestVisible private Decimal forecastDisplayUSTotal { get; set; }
    @TestVisible private Decimal forecastMobileCATotal { get; set; }
    @TestVisible private Decimal forecastMobileUSTotal { get; set; }
    public List<Decimal> ytdDisplayBudgetCA { get; set; }
    public List<Decimal> ytdDisplayBudgetUS { get; set; }
    public List<Decimal> ytdMobileBudgetCA { get; set; }
    public List<Decimal> ytdMobileBudgetUS { get; set; }
    @TestVisible private static List<String> monthsPrevYear { get {
        String year = (String.valueOf(Date.today().year() - 1));
        year = year.substring(year.length() - 2);
        monthsPrevYear = new List<String>();
        monthsPrevYear.add('Jan \'' + year);
        monthsPrevYear.add('Feb \'' + year);
        monthsPrevYear.add('Mar \'' + year);
        monthsPrevYear.add('Apr \'' + year);
        monthsPrevYear.add('May \'' + year);
        monthsPrevYear.add('Jun \'' + year);
        monthsPrevYear.add('Jul \'' + year);
        monthsPrevYear.add('Aug \'' + year);
        monthsPrevYear.add('Sep \'' + year);
        monthsPrevYear.add('Oct \'' + year);
        monthsPrevYear.add('Nov \'' + year);
        monthsPrevYear.add('Dec \'' + year);
        return monthsPrevYear;
    } set; }
    @TestVisible private static List<String> monthsThisYear { get {
        String year = (String.valueOf(Date.today().year()));
        year = year.substring(year.length() - 2);
        monthsThisYear = new List<String>();
        monthsThisYear.add('Jan \'' + year);
        monthsThisYear.add('Feb \'' + year);
        monthsThisYear.add('Mar \'' + year);
        monthsThisYear.add('Apr \'' + year);
        monthsThisYear.add('May \'' + year);
        monthsThisYear.add('Jun \'' + year);
        monthsThisYear.add('Jul \'' + year);
        monthsThisYear.add('Aug \'' + year);
        monthsThisYear.add('Sep \'' + year);
        monthsThisYear.add('Oct \'' + year);
        monthsThisYear.add('Nov \'' + year);
        monthsThisYear.add('Dec \'' + year);
        return monthsThisYear;
    } set; }
    @TestVisible private static List<String> monthsNextYear { get {
        String year = (String.valueOf(Date.today().year() + 1));
        year = year.substring(year.length() - 2);
        monthsNextYear = new List<String>();
        monthsNextYear.add('Jan \'' + year);
        monthsNextYear.add('Feb \'' + year);
        monthsNextYear.add('Mar \'' + year);
        monthsNextYear.add('Apr \'' + year);
        monthsNextYear.add('May \'' + year);
        monthsNextYear.add('Jun \'' + year);
        monthsNextYear.add('Jul \'' + year);
        monthsNextYear.add('Aug \'' + year);
        monthsNextYear.add('Sep \'' + year);
        monthsNextYear.add('Oct \'' + year);
        monthsNextYear.add('Nov \'' + year);
        monthsNextYear.add('Dec \'' + year);
        return monthsNextYear;
    } set; }
    @TestVisible private static Map<Integer,String> monthsMap = new Map<Integer,String>{
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec'
    };
    public Date today { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public Integer todayYear { get; set; }
    public Integer todayMonth { get; set; }
    public String todayMonthInText { get; set; }
    @TestVisible private final Decimal WINRATE = 0.8;

    public class ForecastData {
        public String month { get; set; }
        public Decimal displayAmount { get; set; }
        public Decimal mobileAmount { get; set; }
        public Decimal monthlyTotal { get; set; }
        public String type { get; set; }
        public ForecastData(String month, Decimal displayAmount, Decimal mobileAmount, String type) {
            this.month = month;
            this.displayAmount = displayAmount;
            this.mobileAmount = mobileAmount;
            this.monthlyTotal = displayAmount + mobileAmount;
            this.type = type;
        }
    }
    
    // Constructor
    public ReportOpportunityRFPForecast() {
        recalculateForecast();
    }

    // Recalculate forecast based on changed start date
    public void recalculateForecast() {
        initFields();

        // Forecasted
        getOpportunities();
        generatePipeline();

        // Populate Data
        createForecastData();
    }

    // Initialize fields
    @TestVisible private void initFields() {
        today = Date.today();
        todayYear = today.year();
        todayMonth = today.month();
        String yearText = String.valueOf(todayYear);
        todayMonthInText = monthsMap.get(todayMonth) + ' \'' + yearText.substring(yearText.length() - 2);
        startDate = Date.newInstance(todayYear, todayMonth, 1).addMonths(-6);
        endDate = startDate.addMonths(11);
        Integer numberOfDays = Date.daysInMonth(endDate.year(), endDate.month());
        endDate = Date.newInstance(endDate.year(), endDate.month(), numberOfDays);

        ytdDisplayBudgetCA = new List <Decimal>();
        ytdDisplayBudgetUS = new List <Decimal>();
        ytdMobileBudgetCA = new List <Decimal>();
        ytdMobileBudgetUS = new List <Decimal>();
        for(Integer i = 0; i <12; i++) {
            ytdDisplayBudgetCA.add(0);
            ytdDisplayBudgetUS.add(0);
            ytdMobileBudgetCA.add(0);
            ytdMobileBudgetUS.add(0);
        }
        forecastDisplayCATotal = 0;
        forecastDisplayUSTotal = 0;
        forecastMobileCATotal = 0;
        forecastMobileUSTotal = 0;
    }

    // Get Opportunities that are in RFP/Proposal stage and are closed after the previous month
    @TestVisible private void getOpportunities() {
        opportunities = [SELECT Name, Amount, Display_Budget__c, Mobile_Budget__c, Region__c, CloseDate, Self_Serve__c, RecordType.Name FROM Opportunity WHERE StageName = 'RFP/Proposal' AND CloseDate >=:startDate AND CloseDate <=:endDate AND RecordType.Name = 'eyeDemand'
        ];
    }

    // Place the respective opportunity amounts to the upcoming months
    @TestVisible private void generatePipeline() {
        Integer startMonth = startDate.month();
        for (Opportunity opportunity: opportunities) {
            Integer closeMonth = opportunity.CloseDate.month();

            if (startDate.year() < todayYear) {
                if ((opportunity.CloseDate).year() == todayYear - 1) {
                    if(opportunity.Region__c == 'Canada') {
                        ytdDisplayBudgetCA[closeMonth - startMonth] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetCA[closeMonth - startMonth] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                    if(opportunity.Region__c == 'United States') {
                        ytdDisplayBudgetUS[closeMonth - startMonth] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetUS[closeMonth - startMonth] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                } else if ((opportunity.CloseDate).year() == todayYear) {
                    if(opportunity.Region__c == 'Canada') {
                        ytdDisplayBudgetCA[((12 - startMonth) + closeMonth) - 1] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetCA[((12 - startMonth) + closeMonth) - 1] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                    if(opportunity.Region__c == 'United States') {
                        ytdDisplayBudgetUS[((12 - startMonth) + closeMonth) - 1] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetUS[((12 - startMonth) + closeMonth) - 1] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                }
            } else {
                if ((opportunity.CloseDate).year() == todayYear) {
                    if(opportunity.Region__c == 'Canada') {
                        ytdDisplayBudgetCA[closeMonth - startMonth] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetCA[closeMonth - startMonth] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                    if(opportunity.Region__c == 'United States') {
                        ytdDisplayBudgetUS[closeMonth - startMonth] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetUS[closeMonth - startMonth] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                } else if ((opportunity.CloseDate).year() == (todayYear + 1)) {
                    if(opportunity.Region__c == 'Canada') {
                        ytdDisplayBudgetCA[((12 - startMonth) + closeMonth) - 1] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetCA[((12 - startMonth) + closeMonth) - 1] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                    if(opportunity.Region__c == 'United States') {
                        ytdDisplayBudgetUS[((12 - startMonth) + closeMonth) - 1] += opportunity.Display_Budget__c == null ? 0 : opportunity.Display_Budget__c;
                        ytdMobileBudgetUS[((12 - startMonth) + closeMonth) - 1] += opportunity.Mobile_Budget__c == null ? 0 : opportunity.Mobile_Budget__c;
                    }
                }
            }
        }
    }

    @TestVisible private void createForecastData() {
        forecastCA = new List <ForecastData>();
        forecastUS = new List <ForecastData>();
        forecastCATable = new List <ForecastData>();
        forecastUSTable = new List <ForecastData>();

        if (startDate.year() < todayYear) {
           for (Integer i = startDate.month() - 1; i < 12; i++) {
                forecastCA.add(new ForecastData(monthsPrevYear[i], 0, 0, 'monthly'));
                forecastCATable.add(new ForecastData(monthsPrevYear[i], 0, 0, 'monthly'));
                forecastUS.add(new ForecastData(monthsPrevYear[i], 0, 0, 'monthly'));
                forecastUSTable.add(new ForecastData(monthsPrevYear[i], 0, 0, 'monthly'));
            }
            for (Integer i = 0; i < endDate.month(); i++) {
                forecastCA.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastCATable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUS.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUSTable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
            }
        } else if (startDate.year() == todayYear && endDate.year() == todayYear) {
            for (Integer i = startDate.month() - 1; i < 12; i++) {
                forecastCA.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastCATable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUS.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUSTable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
            }
        } else if (startDate.year() == todayYear && endDate.year() > todayYear) {
            for (Integer i = startDate.month() - 1; i < 12; i++) {
                forecastCA.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastCATable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUS.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
                forecastUSTable.add(new ForecastData(monthsThisYear[i], 0, 0, 'monthly'));
            }
            for (Integer i = 0; i < endDate.month(); i++) {
                forecastCA.add(new ForecastData(monthsNextYear[i], 0, 0, 'monthly'));
                forecastCATable.add(new ForecastData(monthsNextYear[i], 0, 0, 'monthly'));
                forecastUS.add(new ForecastData(monthsNextYear[i], 0, 0, 'monthly'));
                forecastUSTable.add(new ForecastData(monthsNextYear[i], 0, 0, 'monthly'));
            }
        }

        for (Integer i = 0; i < 12; i++) {
            ForecastData tempCA = forecastCA.get(i);
            ForecastData tempUS = forecastUS.get(i);
            ForecastData tempCATable = forecastCATable.get(i);
            ForecastData tempUSTable = forecastUSTable.get(i);
            // CA
            tempCA.displayAmount += WINRATE*ytdDisplayBudgetCA[i]/1000.0;
            tempCA.mobileAmount += WINRATE*ytdMobileBudgetCA[i]/1000.0;
            tempCATable.displayAmount += WINRATE*ytdDisplayBudgetCA[i];
            tempCATable.mobileAmount += WINRATE*ytdMobileBudgetCA[i];
            tempCATable.monthlyTotal += tempCATable.displayAmount + tempCATable.mobileAmount;

            // US
            tempUS.displayAmount += WINRATE*ytdDisplayBudgetUS[i]/1000.0;
            tempUS.mobileAmount += WINRATE*ytdMobileBudgetUS[i]/1000.0;
            tempUSTable.displayAmount += WINRATE*ytdDisplayBudgetUS[i];
            tempUSTable.mobileAmount += WINRATE*ytdMobileBudgetUS[i];
            tempUSTable.monthlyTotal += tempUSTable.displayAmount + tempUSTable.mobileAmount;
            
            // Total
            forecastDisplayCATotal += ytdDisplayBudgetCA[i];
            forecastMobileCATotal += ytdMobileBudgetCA[i];
            forecastDisplayUSTotal += ytdDisplayBudgetUS[i];
            forecastMobileUSTotal += ytdMobileBudgetUS[i];
        }

        forecastCATable.add(new ForecastData('TOTAL', WINRATE*forecastDisplayCATotal, WINRATE*forecastMobileCATotal, 'total'));
        forecastUSTable.add(new ForecastData('TOTAL', WINRATE*forecastDisplayUSTotal, WINRATE*forecastMobileUSTotal, 'total'));
    }
}