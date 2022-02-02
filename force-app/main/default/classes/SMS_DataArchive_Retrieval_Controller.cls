public with sharing class SMS_DataArchive_Retrieval_Controller {
    
    private String subId;
    private List<Map<String,String>> archivedCases;
    private List<Map<String,String>> archivedTasks;
    
    public String caseList {get; set;} 
    public String taskList {get; set;} 
    
    public String archivedDataCSV { get; set; }
    public String fileName { get; set; }
    
    public SMS_DataArchive_Retrieval_Controller(){        
        subId = ApexPages.currentPage().getParameters().get('id');
        archivedCases = new List<Map<String,String>>();
        archivedTasks = new List<Map<String,String>>();
        fileName = ''; 
        if(String.isNotBlank(subId)){
            SMS_DynamoDB db = new SMS_DynamoDB();
            String queryResult;
            
            queryResult = db.query(SMS_DynamoDB_Config__c.getValues('Case').Table_Name__c, subId);             
            archivedCases = constructData(queryResult);
            caseList = JSON.serialize(archivedCases); 
                       
            queryResult = db.query(SMS_DynamoDB_Config__c.getValues('Task').Table_Name__c, subId);            
            archivedTasks = constructData(queryResult);            
            taskList = JSON.serialize(archivedTasks);                     
        }
        else{
            taskList = JSON.serialize(archivedTasks); 
            caseList = JSON.serialize(archivedCases); 
        }        
    } 
    
    
    public PageReference createCSV(){
        
        if(fileName.equals('Cases'))
            archivedDataCSV = constructCSV(archivedCases); 
        else if(fileName.equals('Tasks'))
            archivedDataCSV = constructCSV(archivedTasks); 
        
        PageReference csvPage = Page.SMS_DataArchive_CSV;
        csvPage.setRedirect(false);
        
        return csvPage;
    }
    
    
    private List<Map<String,String>> constructData(String queryResult){
        List<Map<String,String>> archivedData = new List<Map<String,String>>();
        
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(queryResult);            
        List<Object> b = (List<Object>)m.get('Items');
        
        if(b != null && b.Size() > 0){
            for(Integer i=0; i<b.Size(); i++) {
                Map<String, Object> c = (Map<String, Object>)b[i];
                Set<String> fieldNames = (Set<String>)c.keyset();
                Map<String,String> archivedDatum = new Map<String,String>();
                
                for(String fieldName : fieldNames){
                    Map<String, Object> fieldValueMap = (Map<String, Object>)c.get(fieldName); 
                    Set<String> fieldKeys = (Set<String>)fieldValueMap.keyset();
                    for(String fieldKey : fieldKeys){
                        String fieldValue = (String)fieldValueMap.get(fieldKey);
                        archivedDatum.put(fieldName,fieldValue);
                    }
                }
                archivedData.add(archivedDatum);
            }
            system.debug('*** Archived Data: ' + archivedData);
        }
        
        return archivedData;
    }
    
    private String constructCSV(List<Map<String,String>> archivedData){
        archivedDataCSV = '';
        List<String> fieldNames = new List<String>();
        fieldNames.addAll(archivedData[0].keyset());
        fieldNames.sort();
        for(String fieldName : fieldNames){
            archivedDataCSV = archivedDataCSV + fieldName + ',';
        }
        archivedDataCSV = archivedDataCSV + '\n';
        for(Map<String,String> cs : archivedData){
            for(String fieldName : fieldNames){
                archivedDataCSV = archivedDataCSV + cs.get(fieldName).replaceAll('\n','.').replaceAll('-','_').replaceAll(',',' ').replaceAll('\r','.') + ',';
            }
            archivedDataCSV = archivedDataCSV + '\n';
        }
        
        return archivedDataCSV;
    }   
        
}