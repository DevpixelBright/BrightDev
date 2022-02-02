global class SubscriptionDataInsertionBatch implements Database.Batchable<Sobject> {
global Database.querylocator start(Database.BatchableContext BC) {
return Database.getQueryLocator([select Id, Name from Subscriptions__c LIMIT 60]);
}
global void execute(Database.BatchableContext BC, list<Subscriptions__c> scope) {
    for(Integer i=0;i<100;i++){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = 'TEST-SUB-'+i;
        subscription.Contact__c = '003J000001UXYNx';
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
       // subscription.City__c = 'Herndon';
        //subscription.State__c = 'VA';
        //subscription.Zip__c = '20171';
        subscription.County__c = 'Rayac';
        //subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        //subscription.AgentKey__c = '123111';
        subscription.Related_Location_Broker_Office__c = '001J000001vdOrE';
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';  
        subscription.Service_Jurisdiction__c = 'BRIGHT';
        subscription.Billing_Jurisdiction__c = 'Rayac';
        //subscription.ZuoraIntegrationWorkflowBypass__c = false;
        insert subscription;
    }
}
global void finish(Database.BatchableContext BC) {
}
}