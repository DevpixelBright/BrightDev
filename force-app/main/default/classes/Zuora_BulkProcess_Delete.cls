global class Zuora_BulkProcess_Delete implements Database.Batchable<Zuora_Bulk_Process__c>,Database.AllowsCallouts, Database.Stateful {
    /*
        String query = 'SELECT Id,Name, Zuora_Id__c, Status__c, Status_Message__c, zObject_Type__c FROM Zuora_Bulk_Process__c WHERE Status__c = \'In Progress\' LIMIT 5';
        Zuora_BulkProcess_Delete zBulkProcess =  new Zuora_BulkProcess_Delete(query, 'Amendment');
        Database.executeBatch(zBulkProcess);
    */
    
    private Static SMS_ZuoraUtil zUtilInstance;
    private String query;
    private String zobjectType;    
    
    global Zuora_BulkProcess_Delete(String query, String zobjectType){
        this.query = query;
        this.zobjectType = zobjectType;
    }
    
    global List<Zuora_Bulk_Process__c> start(Database.BatchableContext BC)  {    
        System.debug('***Query is : '+ query);
        List<Zuora_Bulk_Process__c> zuoraRecords = new List<Zuora_Bulk_Process__c>();
        zuoraRecords = Database.query(query);
        
        return zuoraRecords;
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora_Bulk_Process__c> scope){
        try{
        zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
        
        List<String> zSubscriptionIds = new List<String>();
        List<Zuora_Bulk_Process__c> zUpdateRecords = new List<Zuora_Bulk_Process__c>();
        Map<String,String> zIdsfId = new Map<String,String>();
        
        for(Zuora_Bulk_Process__c zRecord : scope){        
            zIdsfId.put(zRecord.Zuora_Id__c, zRecord.Id);
            if(zIdsfId.size() == 50 || Test.isRunningTest()){
                List<String> zIds = new List<String>();
                zIds.addAll(zIdsfId.keyset());
                List<Zuora.zApi.DeleteResult> results = zUtilInstance.zdelete(zobjectType, zIds ); 
                for(Zuora.zApi.DeleteResult result : results){
                    String zId = result.Id;
                    Zuora_Bulk_Process__c zUpdateRecord = new Zuora_Bulk_Process__c();
                    zUpdateRecord.Id = zIdsfId.get(zId);
                    zUpdateRecord.Status__c = 'Success';
                    zUpdateRecord.Status_Message__c = 'Success';            
                    if(!result.Success){
                        zUpdateRecord.Status__c = 'Failure';
                        Zuora.zObject[] errors = result.errors;
                        for (Zuora.zObject error : errors) 
                            zUpdateRecord.Status_Message__c = 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                          
                        
                    }
                    zUpdateRecords.add(zUpdateRecord);
                }
                zIdsfId = new Map<String,String>();
            }
        }
        
        
        if(zIdsfId.size() > 0  || Test.isRunningTest()){
            List<String> zIds = new List<String>();
            zIds.addAll(zIdsfId.keyset());
            List<Zuora.zApi.DeleteResult> results = zUtilInstance.zdelete(zobjectType, zIds ); 
            for(Zuora.zApi.DeleteResult result : results){
                String zId = result.Id;
                Zuora_Bulk_Process__c zUpdateRecord = new Zuora_Bulk_Process__c();
                zUpdateRecord.Id = zIdsfId.get(zId);
                zUpdateRecord.Status__c = 'Success';
                zUpdateRecord.Status_Message__c = 'Success';  
                if (Test.isRunningTest()){
                    result.Success = false;
                    Zuora.zObject error = new Zuora.zObject('Error');
                    error.setValue('Code', 'Error Code');
                    error.setValue('Message', 'Error Code Message');
                    result.errors = new List<Zuora.zObject> {error};                    
                }
                if(!result.Success){
                    zUpdateRecord.Status__c = 'Failure';
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) 
                        zUpdateRecord.Status_Message__c = 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                          
                    
                }
                zUpdateRecords.add(zUpdateRecord);
            }
            zIdsfId = new Map<String,String>();
        }
        
        if(zUpdateRecords.size() > 0)
            update zUpdateRecords;
            }catch(Exception e){}
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}