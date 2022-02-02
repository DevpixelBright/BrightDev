global class SMS_AutoSuspendAbandon implements Database.Batchable<sObject>{
    global String Query;
   
    global SMS_AutoSuspendAbandon(String q) {
        Query = q;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<SMS_Auto_Suspended_Account__c> scope){
        List<SMS_Auto_Suspended_Account__c> abandonAutoSuspendAccounts = new List<SMS_Auto_Suspended_Account__c>();
        
        for(SMS_Auto_Suspended_Account__c autoSuspendAccount : scope) {
            if(autoSuspendAccount.Status__c.equals('In Progress')) {
                autoSuspendAccount.Status__c = 'Failed - TimedOut';
                abandonAutoSuspendAccounts.add(autoSuspendAccount);  
            }
        }
        
        update abandonAutoSuspendAccounts;                                 
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}