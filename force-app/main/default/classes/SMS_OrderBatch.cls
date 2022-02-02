global class SMS_OrderBatch implements Database.Batchable<sObject>{
    global String Query;
   
    global SMS_OrderBatch(String q) {
        Query = q;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<SMS_Order__c> scope){
        List<SMS_Order__c> abandonOrder = new List<SMS_Order__c>();
        
        for(SMS_Order__c order : scope) {
            if(order.Status__c.equals('Active')) {
                order.Status__c = 'Abandoned';
                abandonOrder.add(order);  
            }
        }
        
        update abandonOrder;                                 
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}