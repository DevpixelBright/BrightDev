global class BrightBillingJurisdictionAssignment implements Database.Batchable<sObject>{
    global List<Subscriptions__c> subscriptionslist;
    global Map<String,String> billingJurisdictionsMap;
    global Map<String,String> jurisdictionbatchmap;
    global Map<ID,Zuora__CustomerAccount__c> subscriptionbillingaccountmap;
    global List<BRIGHT_Billing_Jurisdiction__c> billingJurisdictionList;
    global List<ID> subscriptionIDs; 
    global List<Zuora__CustomerAccount__c> billingaccountslist;
    global List<Zuora__CustomerAccount__c> finalbillingaccountslist;
    
    global BrightBillingJurisdictionAssignment(){
        subscriptionslist = new List<Subscriptions__c>();
        billingJurisdictionsMap = new Map<String,String>(); 
        subscriptionIDs = new List<ID>();
        billingaccountslist = new List<Zuora__CustomerAccount__c>(); 
        finalbillingaccountslist = new List<Zuora__CustomerAccount__c>();
        subscriptionbillingaccountmap = new Map<ID,Zuora__CustomerAccount__c>();
        
        jurisdictionbatchmap = new Map<String,String>();
        jurisdictionbatchmap.put('Lancaster','30');
        jurisdictionbatchmap.put('Lebanon','30');
        jurisdictionbatchmap.put('Harrisburg','31');
        jurisdictionbatchmap.put('RAYAC','32');
        
        billingJurisdictionList =[SELECT Id, Name, County__c, State__c, Billing_Jurisdiction__c FROM BRIGHT_Billing_Jurisdiction__c];
        for(BRIGHT_Billing_Jurisdiction__c bj : billingJurisdictionList){
            billingJurisdictionsMap.put(bj.County__c, bj.Billing_Jurisdiction__c);
        } 
      
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  'select ID,name,County__c,State__c,billing_jurisdiction__c from subscriptions__c where service_jurisdiction__c = \'BRIGHT\' and state__c = \'PA\' and Name=\'4513609\' ';
        system.debug('**** query***'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Subscriptions__c> subscriptionslist){
        system.debug('*****subscriptionslist in execute****'+subscriptionslist);
        for(subscriptions__c subs : subscriptionslist){
            subscriptionIDs.add(subs.Id);
        }
        billingaccountslist = [SELECT Id,Zuora__Batch__c,Subscription__c FROM Zuora__CustomerAccount__c where Subscription__c in :subscriptionIDs];
         system.debug('****billingaccountslist***'+billingaccountslist);
        for(Zuora__CustomerAccount__c zc : billingaccountslist){
            subscriptionbillingaccountmap.put(zc.Subscription__c,zc);
        }
        for(subscriptions__c subs : subscriptionslist){
            if(billingJurisdictionsMap.containsKey(subs.county__c)){
                String bjurisdiction = billingJurisdictionsMap.get(subs.county__c);
                system.debug('*****bjurisdiction****'+bjurisdiction);
                subs.billing_jurisdiction__c = bjurisdiction;
                if(subscriptionbillingaccountmap.containsKey(subs.ID)){
                    Zuora__CustomerAccount__c zAccount = new Zuora__CustomerAccount__c();
                    zAccount = subscriptionbillingaccountmap.get(subs.ID);
                    if(bjurisdiction!=null && jurisdictionbatchmap.containsKey(bjurisdiction)){
                        zAccount.Zuora__Batch__c = jurisdictionbatchmap.get(bjurisdiction);
                        system.debug('*****zAccount.Zuora__Batch__c****'+zAccount.Zuora__Batch__c);
                        finalbillingaccountslist.add(zAccount);
                    }
                    
                }
            }
        }
        /*****Following lines should be uncommented once data is confirmed***/
       // update subscriptionslist;
       // update finalbillingaccountslist;
    }    
    
    global void finish(Database.BatchableContext bc){
        
    } 
}