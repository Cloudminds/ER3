/*
 What        : This rule applies to Opportunity records of type "Creative Production"
              Sets the value of the field Second_Business_Date_of_Next_Month__c for the opportunity record
              Throws error when Ready to bill date > Second Business Date    
 When        : Nov 2015
 Who         : Vishal Khanna
 */
 trigger RunSecondBusinessDateRule on Opportunity ( before update) {
  
  List<Opportunity> listToUpdate = new List<Opportunity>();
  boolean doSave = true;
  string strErrorCode;
  if(!System.isBatch()){
    if(trigger.IsUpdate && trigger.isBefore){   
      // Fetch the value of Next Holiday date from the custom setting
      Holiday_Settings__c HS = Holiday_Settings__c.getOrgDefaults();
      if(HS==null) HS = new Holiday_Settings__c();
      Date NextHoliday = HS.Next_Holiday_Date__c ;
    
      // Fetch Creative Production opportunities in the trigger context....
      Set<ID> ids = Trigger.newMap.keySet();
      List<Opportunity> listCPOpps = [Select Id, StageName, First_Date_of_Next_Month__c, Ready_To_Bill_Date__c, First_Day_of_Next_Month__c, Second_Date_of_Next_Month__c, Second_Business_Date_of_Next_Month__c, RecordType.Name from Opportunity where RecordType.Name='Creative Production' and Id in: ids];
    
      // Loop through listCPOpps and set the value of Second_Business_Date_of_Next_Month__c
      for(Opportunity o : listCPOpps){
        string fday = o.First_Day_of_Next_Month__c;
        date fdat = o.First_Date_of_Next_Month__c;
        date sdat = o.Second_Date_of_Next_Month__c;  
        date fridayPlusThree = fdat + 3;
        date saturdayPlusTwo = fdat + 2;
        date saturdayPlusThree = fdat + 3;
        date sundayPlusOne = fdat + 1;
        date sundayPlusTwo = fdat + 2;
        
        // Check for Mon Or Tue Or Wed
        if(fday=='Monday' || fday=='Tuesday' || fday=='Wednesday'){
            if(fdat!= NextHoliday && sdat!=NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 1;
            }
            else if(fdat== NextHoliday || sdat== NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 2;
            }
        }
        
        // Check for Thu
        if(fday=='Thursday' ){
            if(fdat!= NextHoliday && sdat!=NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 1;
            }
            else if(fdat== NextHoliday || sdat== NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 4;
            }
        }
        
        // Check for Fri
        if(fday=='Friday'){
            if(fdat!= NextHoliday && fridayPlusThree!=NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 3;
            }
            else if(fdat== NextHoliday || fridayPlusThree == NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 4;
            }
        }
        
        // Check for Sat
        if(fday=='Saturday'){
            if(saturdayPlusTwo!= NextHoliday && saturdayPlusThree!=NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 3;
            }
            else if(saturdayPlusTwo==NextHoliday || SaturdayPlusThree==NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 4;
            }
        }
        
        // Check for Sun
        if(fday=='Sunday'){
            if(sundayPlusOne!= NextHoliday && sundayPlusTwo!=NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 2;
            }
            else if(sundayPlusOne==NextHoliday || sundayPlusTwo==NextHoliday){
                o.Second_Business_Date_of_Next_Month__c = o.First_Date_of_Next_Month__c + 3;
            }
        }
        
        System.Debug('second bus date:' + o.Second_Business_Date_of_Next_Month__c); // OK
        System.Debug('o.Ready_To_Bill_Date__c :' + o.Ready_To_Bill_Date__c ); // OK
        
        Opportunity o2 = new Opportunity(
           id = o.id,
           Second_Business_Date_of_Next_Month__c = o.Second_Business_Date_of_Next_Month__c,
           Ready_To_Bill_Date__c = o.Ready_To_Bill_Date__c
          );
          
          System.Debug('o2.Second_Business_Date_of_Next_Month__c='+o2.Second_Business_Date_of_Next_Month__c
         );
         listToUpdate.add(o2);
    }
    
    map<Id, Opportunity> mapOppError = new map<Id, Opportunity>();
    
    if(listToUpdate.size()==1){
        
           for(Opportunity ou:listToUpdate){
                Integer ReadyToBillMonth = ou.Ready_To_Bill_Date__c.month();    
                Integer PreviousMonth = Date.Today().month() - 1;
                if(ou.Ready_To_Bill_Date__c > ou.Second_Business_Date_of_Next_Month__c){
                    mapOppError.put(ou.Id, null); 
                    strErrorCode = '1';                     
                }  
                else if(PreviousMonth == ReadyToBillMonth ){
                    mapOppError.put(ou.Id, null); 
                    strErrorCode = '2';   
                }                 
           }
            
     } 
     
     
     for(Opportunity os: Trigger.new){
      if(mapOppError.containsKey(os.Id)){           
                doSave = false;
                if(strErrorCode=='1'){
                  os.addError('The Ready To Bill Date cannot be greater than the second business day of the current month');
                } 
                if(strErrorCode=='2'){
                  os.addError('The Ready To Bill Date cannot be a date of the previous month');
                } 
        }       
      }
      
      System.Debug('listToUpdate before saving:'+listToUpdate);
      
   }
 } 
 
 if(doSave==true){
       System.Debug('doSave is TRUE');
       if(listToUpdate.size()>0){
           System.Debug('Size is '+listToUpdate.size());
            // System.Debug('TriggerHelper.runonce()::::'+TriggerHelper.RunOnce());
            //if(TriggerHelper.runonce()){ 
                update listToUpdate; 
                System.Debug('listToUpdate:'+listToUpdate);
            //}
       }
      }
     
}