global class FutureTerminationDateBatch implements Schedulable,Database.Batchable<sObject>{ 
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator([Select Status__c,Status_Change_Reason__c,Date_Terminated__c,Future_Termination_Date__c From Subscriptions__c Where Status__c = 'Active' AND Future_Termination_Date__c = Today ]);
    }
  
  // Execute Logic
   global void execute(Database.BatchableContext BC, List<Subscriptions__c>subscriptionList){
       for(Subscriptions__c subsVar :subscriptionList){
            subsVar.Status__c = 'Inactive';
            subsVar.Date_Terminated__c = subsVar.Future_Termination_Date__c;
            subsVar.Status_Change_Reason__c = 'Subscriber Requested';
       }
        if(subscriptionList.size() > 0)
            Database.SaveResult [] updateSubscription = Database.update(subscriptionList, false);
   }
 
   global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
   }
    global void execute(SchedulableContext sc){
        Database.executeBatch(New FutureTerminationDateBatch());
    }

}