public class ReportOpportunitySalesRepMismatchDash extends ReportOpportunitySalesRepMismatch{
    public override void getOpportunities(){
        opportunities = [select
            AccountId,
            Name,
            Type,
            RecordTypeId,
            RecordType.Name,
            Primary_Display_Sales_Rep__r.Name,
            Primary_Mobile_Sales_Rep__r.Name,
            Account.Name,
            Account.Adserving_Sales_Rep__r.Name,
            Account.eyedemand_Sales_Rep__r.Name
        from Opportunity LIMIT 50];
    }
}