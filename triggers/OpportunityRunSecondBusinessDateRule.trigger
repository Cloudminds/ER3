/*
What        : This rule applies to Opportunity records of type "Creative Production"
              Sets the value of the field Second_Business_Date_of_Next_Month__c for the opportunity record
              Throws error when Ready to bill date > Second Business Date    
When        : Nov 2015
Who         : Vishal Khanna
Which       : Version 2.0

DS
changes made to line 21,34,37,44,47,54,57,64,67,74,77 
from First_Date_of_Next_Month__c
To First_Date_of_Next_Month2__c

*/
trigger OpportunityRunSecondBusinessDateRule on Opportunity (before update) {
    // Get Record Type Id For Creative Opportunities
    Map<String,Schema.RecordTypeInfo> rt_Map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
    Schema.RecordTypeInfo rtByName =  rt_Map.get('Creative Production');
    Id creativeOppRecTypeId = rtByName.getRecordTypeId();
    // Fetch the value of Next Holiday date from the custom setting
    Holiday_Settings__c HS = Holiday_Settings__c.getOrgDefaults();
    if(HS==null) HS = new Holiday_Settings__c();
    Date NextHoliday = HS.Next_Holiday_Date__c ;
    for(Opportunity o:Trigger.new){
        if(o.RecordTypeId.equals(creativeOppRecTypeId) && o.StageName.equals('Ready To Bill')){
            String firstDay = o.First_Day_of_Next_Month__c;
            date firstDate = o.First_Date_of_Next_Month2__c;
            date secondDate = o.Second_Date_of_Next_Month__c;  
            date fridayPlusThree = firstDate + 3;
            date saturdayPlusTwo = firstDate + 2;
            date saturdayPlusThree = firstDate + 3;
            date sundayPlusOne = firstDate + 1;
            date sundayPlusTwo = firstDate + 2;
        
            Date sbdnm ; // Second business date of next month
            
            // Check for Mon Or Tue Or Wed
            if(firstDay=='Monday' || firstDay=='Tuesday' || firstDay=='Wednesday'){
              if(firstDate!= NextHoliday && secondDate!=NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 1;
              }
              else if(firstDate== NextHoliday || secondDate== NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 2;
              }
            }
            
            // Check for Thu
            if(firstDay=='Thursday' ){
              if(firstDate!= NextHoliday && secondDate!=NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 1;
              }
              else if(firstDate== NextHoliday || secondDate== NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 4;
              } 
             }
        
            // Check for Fri
            if(firstDay=='Friday'){
              if(firstDate!= NextHoliday && fridayPlusThree!=NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 3;
              }
              else if(firstDate== NextHoliday || fridayPlusThree == NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 4;
              }
            }
        
            // Check for Sat
            if(firstDay=='Saturday'){
              if(saturdayPlusTwo!= NextHoliday && saturdayPlusThree!=NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 3;
              }
              else if(saturdayPlusTwo==NextHoliday || SaturdayPlusThree==NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 4;
              }
            }
        
            // Check for Sun
            if(firstDay=='Sunday'){
              if(sundayPlusOne!= NextHoliday && sundayPlusTwo!=NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 2;
              }
              else if(sundayPlusOne==NextHoliday || sundayPlusTwo==NextHoliday){
                sbdnm = o.First_Date_of_Next_Month2__c + 3;
              }
            }
          
          o.Second_Business_Date_of_Next_Month__c = sbdnm;
          
          date currentDate = Date.today();
          Integer M = currentDate.Month(); // The current month number
          String strSBDNM = String.valueOf(o.Second_Business_Date_of_Next_Month__c);
          if(o.Ready_To_Bill_Date__c > o.Second_Business_Date_of_Next_Month__c -1 ){
            o.addError('Ready to Bill Date cannot be greater than the Second Business Date of next Month which is '+strSBDNM);
          }
        }       
    }
}