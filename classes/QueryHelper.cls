global class QueryHelper {
	// Implement select * in SOQL - WHERE clause is REQUIRED!
    global static List<SObject> selectAllQuery(String objectName, String condition) {
        List<SObject> recordList;
        String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		 
		// Grab the fields from the describe method and append them to the queryString one by one.
		for(String s : objectFields.keySet()) {
		   
			// Opportunity specific - do not add these unused native fields
		    if(('opportunity').equals((objectName).toLowerCase())){
		    	if(!(('contractid').equals(s) || ('totalopportunityquantity').equals(s) ||  ('expectedrevenue').equals(s) ||  ('isprivate').equals(s))){
		    		query += ' ' + s + ', ';
		    	}
			} else{
		   		query += ' ' + s + ', ';
		    }
		}

		// Add Record Types
		query += 'RecordType.Name';

		//Strip off the last comma if it exists.
		if (query.subString(query.Length()-2,query.Length()-1) == ','){
		    query = query.subString(0,query.Length()-2);
		}
		 
		// Add FROM statement
		query += ' FROM ' + objectName;
		
		if (!String.isBlank(condition)){
			query += ' ' + condition;
		}

		try {
			// Add on a WHERE/ORDER/LIMIT statement as needed
			// System.debug('++++++++++++++ Print query: ' + query);
			recordList = database.query(query);

		} catch (QueryException e){
		    System.Debug('Error: Query exception ['+ e.getMessage()+']');
		}
        return recordList;
    }
}