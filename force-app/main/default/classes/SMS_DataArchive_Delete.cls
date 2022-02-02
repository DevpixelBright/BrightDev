global class SMS_DataArchive_Delete implements Database.Batchable<sObject>{
    String query;
    List<String> recordIds;
    Boolean runDelete;
    
    
    global SMS_DataArchive_Delete(String objectName, List<String> records) {
        recordIds = records;
        system.debug('*** recordIds: ' + recordIds);
        query = 'SELECT Id, Is_Archive__c FROM ' + objectName + ' WHERE Id IN :recordIds AND Is_Archive__c = true AND Do_Not_Archive__c = false';
        system.debug('*** Query: ' + query);
        
        Set<String> profiles = new Set<String>();
        for(String profile : Label.MRIS_DataArchive_Profiles.split(',')){
            profiles.add(profile);
        }
        
        String userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()].Name;   
        if(profiles.contains(userProfile))
            runDelete = true;
        else
            runDelete = false; 
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('*** Batch Scope: ' + scope.size());
        if(runDelete){
            delete scope;  
            system.debug('*** Run delete: ');  
        }
        else
            system.debug('*** Do not run delete' );                 
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}