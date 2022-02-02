global  class MRISSFQPSentStatus implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query = 'Select id,QPStatus__c from SFQPConnector__c where QPStatus__c = \'Sent\' and CreatedDate < ';
 
    global  Database.Querylocator start(Database.BatchableContext bc) {
        
        System.debug('Inside execute inside start ' + query); 
        long lnDt = System.currentTimeMillis() - Long.valueOf(System.Label.MRIS_QP_Sent_Status_Delay);
        DateTime dt1 = DateTime.newInstance(lnDt);
        String dt2 = dt1.formatGmt('yyyy-MM-dd HH:mm:ss.S');
        dt2 = dt2.replaceAll(' ','T');
        dt2 = dt2 + 'z';
        query = query + dt2 + ' LIMIT 10';
        System.debug('Query -->' + query); 
        
        if(Test.isRunningTest())
            return Database.getQueryLocator('Select id,QPStatus__c from SFQPConnector__c where QPStatus__c = \'Sent\'');
        else
            return  Database.getQueryLocator(query);
        
    } 
     
    global void execute (Database.Batchablecontext bc, List <sObject> ac){
    
        System.debug('in Execuute ---> ' + ac.size());
        List <SFQPConnector__c> mList = new List<SFQPConnector__c>();
        for (sObject a: ac) {
            SFQPConnector__c a1 = (SFQPConnector__c) a;
           a1.QPStatus__c = 'Failed-Sent';
            upsert a1; 
             
        }
        //upsert mList;
    }
    
    global void finish(Database.Batchablecontext bc){
        
    }
    
}