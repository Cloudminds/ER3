global class ReportAccountAging {
    public List<Account> accounts { get; set; }
    public List<AgingData> agingData { get; set; }
    public List<AgingData> agingDataTrimmed { get; set; }
    public String userId { get; set; }

    global class AgingData implements Comparable {
        public String id { get; set; }
        public String name { get; set; }
        public Date contactDate { get; set; }
        public Integer age { get; set; }
        public AgingData(String id, String name, DateTime contactDate) {
            this.id = id;
            this.name = name;
            this.contactDate = contactDate.date();
            calculateAge();
        }
        public AgingData(String id, String name, Date contactDate) {
            this.id = id;
            this.name = name;
            this.contactDate = contactDate;
            calculateAge();
        }
        public void calculateAge() {
            this.age = this.contactDate.daysBetween(Date.today());
        }
        global Integer compareTo(Object compareTo) {
            AgingData otherData = (AgingData) compareTo;
            return otherData.contactDate.daysBetween(contactDate);
        }
    }

    public ReportAccountAging() {
        accounts = new List<Account>();
        agingData = new List<AgingData>();
        agingDataTrimmed = new List<AgingData>();
        userId = UserInfo.getUserId();
        getAccounts();
        agingData.sort();
        for (Integer i = 0; i < 10 && i < agingData.size(); i ++) {
            agingDataTrimmed.add(agingData[i]);
        }
    }

    private void getAccounts() {
        // Select Opportunity and Contact field requirements for Account last contact
        AggregateResult[] opportunityAggregateResults = [select Account.Id, Account.Name, MAX(CreatedDate) Created from Opportunity where Account.Type = 'Client' AND Account.OwnerId =: userId group by Account.Id, Account.Name order by MAX(CreatedDate)];
        AggregateResult[] taskAggregateResults = [select AccountId, Account.Name, MAX(CreatedDate) Created from Task where AccountId != null and Account.Type = 'Client' AND Account.OwnerId =: userId group by AccountId, Account.Name];
        AggregateResult[] eventAggregateResults = [select AccountId, Account.Name, MAX(CreatedDate) Created from Event where AccountId != null and Account.Type = 'Client' AND Account.OwnerId =: userId group by AccountId, Account.Name];

        Map<String, AgingData> accountAgeMap = new Map<String, AgingData>();
        // Add Opportunity data
        for (AggregateResult aggregateResult : opportunityAggregateResults) {
            AgingData agingDatum = new AgingData((String) aggregateResult.get('Id'), (String) aggregateResult.get('Name'), (DateTime) aggregateResult.get('Created'));
            accountAgeMap.put((String) aggregateResult.get('Id'), agingDatum);
        }
        // Max with Task data
        for (AggregateResult aggregateResult : taskAggregateResults) {
            AgingData agingDatum;
            String accountId = (String) aggregateResult.get('AccountId');
            Date createdDate = ((DateTime) aggregateResult.get('Created')).date();
            if (accountAgeMap.containsKey(accountId)) {
                agingDatum = accountAgeMap.get(accountId);
                agingDatum.contactDate = createdDate > agingDatum.contactDate ? createdDate : agingDatum.contactDate;
                agingDatum.calculateAge();
            } else {
                agingDatum = new AgingData(accountId, (String) aggregateResult.get('Name'), createdDate);
            }
            accountAgeMap.put(accountId, agingDatum);
        }
        // Max with Event data
        for (AggregateResult aggregateResult : eventAggregateResults) {
            AgingData agingDatum;
            String accountId = (String) aggregateResult.get('AccountId');
            Date createdDate = ((DateTime) aggregateResult.get('Created')).date();
            if (accountAgeMap.containsKey(accountId)) {
                agingDatum = accountAgeMap.get(accountId);
                agingDatum.contactDate = createdDate > agingDatum.contactDate ? createdDate : agingDatum.contactDate;
                agingDatum.calculateAge();
            } else {
                agingDatum = new AgingData(accountId, (String) aggregateResult.get('Name'), createdDate);
            }
            accountAgeMap.put(accountId, agingDatum);
        }
        // Add all Accounts
        for (AgingData agingDatum : accountAgeMap.values()) {
            agingData.add(agingDatum);
        }
    }
}