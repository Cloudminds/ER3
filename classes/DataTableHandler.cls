public with sharing class DataTableHandler {

    public Transient String columnFields { get; set; }
    public Transient String columnTitles { get; set; }
    public Transient String soql { get; set; }
    public Transient String tableId { get; set; }

    public Transient List<String> columnFieldsListHelper;
    public Transient List<String> columnTitlesListHelper;
    public Transient List<List<sObject>> recordsHelper;

    public List<String> columnFieldsList {
        get {
            if(columnFieldsListHelper == null && columnFields != null) {
                columnFieldsListHelper = columnFields.split(',');
                for(Integer x = 0; x < columnFieldsListHelper.size(); x++) {
                    columnFieldsListHelper[x] = columnFieldsListHelper[x].trim();
                }
            }
            return columnFieldsListHelper;
        }
        set;
    }

    public List<String> columnTitlesList {
        get {
            if(columnTitlesListHelper == null && columnTitles != null) {
                columnTitlesListHelper = columnTitles.split(',');
                for(Integer x = 0; x < columnTitlesListHelper.size(); x++) {
                    columnTitlesListHelper[x] = columnTitlesListHelper[x].trim();
                }
            }
            return columnTitlesListHelper;
        }
        set;
    }

    public List<List<sObject>> records {
        get {
            if(recordsHelper == null && soql != null) {
                recordsHelper = new List<List<sObject>>();
                List<sObject> tempList = new List<sObject>();
                for(sObject a : Database.query(soql)){
                    tempList.add(a);
                    if(tempList.size() == 1000){
                        recordsHelper.add(tempList);
                        tempList = new List<sObject>();
                    }
                }
                recordsHelper.add(tempList);
            }
            return recordsHelper;
        }
        set;
    }

    public dataTableHandler(){}
}