trigger SMS_UpdateSubscriptionDetails on Zuora__CustomerAccount__c (before update,before insert) {

    Map<String,Zuora__CustomerAccount__c> sSubscriptionIdBillingAccount = new Map<String,Zuora__CustomerAccount__c>();
    
    for(Zuora__CustomerAccount__c billAccount : trigger.new) {        
        if((billAccount.SubscriptionID__c != null) && (trigger.isInsert || billAccount.SubscriptionID__c != trigger.oldMap.get(billAccount.id).SubscriptionID__c)) {          
            sSubscriptionIdBillingAccount.put(billAccount.SubscriptionID__c,billAccount);
        }
    }
    
    if(sSubscriptionIdBillingAccount.keyset().size() > 0) {
        List<Zuora__CustomerAccount__c> updateBillingAccounts = new List<Zuora__CustomerAccount__c>();
        for(Subscriptions__c sSusbcription : [Select id,Name,Private_Email__c FROM Subscriptions__c WHERE Name in :sSubscriptionIdBillingAccount.keyset()]) {
            Zuora__CustomerAccount__c updateBillingAccount = new Zuora__CustomerAccount__c();
            updateBillingAccount = sSubscriptionIdBillingAccount.get(sSusbcription.Name);
            updateBillingAccount.Subscription__c = sSusbcription.Id;
            updateBillingAccount.Private_Email__c = sSusbcription.Private_Email__c;
        }
    }
}