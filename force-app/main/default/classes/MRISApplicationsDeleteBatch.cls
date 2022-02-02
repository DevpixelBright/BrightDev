/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will delete all the MRIS Applications that are in deferred status and have passed 30 days
**/
global class MRISApplicationsDeleteBatch  implements Database.Batchable<sObject>, Database.Stateful {
     global Integer days = integer.valueof(System.Label.MRIS_VERINT_BATCH_DELETE_DAYS);

     Datetime queryDate = datetime.now().addDays(-days);
     String queryDateFormat =     queryDate.format('yyyy-MM-dd');
     global final String query = 'Select m.Status__c, m.Id From MRIS_Application__c m where m.Status__c =  ' + '\'' + 'Deferred' + '\'' + ' and m.deferred_date__c < '+queryDateFormat+'';
// global final String query = 'Select m.Status__c, m.Id From MRIS_Application__c m where m.Status__c =  ' + '\'' + 'Deferred' + '\'' + ' and m.deferred_date__c < TODAY ;


/**
    *
    *
    **/
    global  Database.Querylocator start(Database.BatchableContext bc) {
        
        System.debug('Inside execute inside start ' + query);
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute (Database.Batchablecontext bc, List <sObject> ac){
    
        List <MRIS_Application__c> mList = new List<MRIS_Application__c>();
        for (sObject a: ac) {
            mList.add((MRIS_Application__c) a);
        }
        delete mList;
    }
    
    global void finish(Database.Batchablecontext bc){
        
    }
    
    
    private testMethod static void testMRISApplication() {
        Test.StartTest();
        MRIS_Application__c m = new MRIS_Application__c();
        //m.Name = 'Test';
        m.State__c = 'VA';
        m.Status__c = 'Deferred';
        m.Comments__c = 'comment here';
        
        insert m;
        
        //This is for the Workflow that updates to date to current date
        m.Deferred_Date__c = Date.Today() - 2012;
        
        upsert m;
        MRISApplicationsDeleteBatch reassign = new MRISApplicationsDeleteBatch();
        ID batchprocessid = Database.executeBatch(reassign);
            Test.StopTest();
        
        List <MRIS_Application__c> mList = [Select m.Status__c, m.deferred_date__c,m.Id From MRIS_Application__c m where m.Status__c = 'Deferred'];
        
        System.assert(mList.size() == 0);
        
    }
}