trigger SMS_LookupSubOnProvisioned on SMS_Provisioned_Product__c (before insert, before update) {
     
     Map<String,List<SMS_Provisioned_Product__c>> provisionedProducts = new Map<String,List<SMS_Provisioned_Product__c>>();
     
     for (SMS_Provisioned_Product__c provisionedProduct : trigger.new) {
         if(!provisionedProducts.containsKey(provisionedProduct.MRIS_Subscription_Id__c))
             provisionedProducts.put(provisionedProduct.MRIS_Subscription_Id__c, new List<SMS_Provisioned_Product__c>());
         
         provisionedProducts.get(provisionedProduct.MRIS_Subscription_Id__c).add(provisionedProduct);
     }
     
     system.debug('*** provisionedProducts : ' + provisionedProducts);
     
     if(provisionedProducts.keyset().size() > 0) {
        List<SMS_Provisioned_Product__c> updateProvisionedProducts  = new List<SMS_Provisioned_Product__c>();
        for(Subscriptions__c sSusbcription : [Select id,Name,Private_Email__c FROM Subscriptions__c WHERE Name in :provisionedProducts.keyset()]) {
            for(SMS_Provisioned_Product__c updateProvisionedProduct : provisionedProducts.get(sSusbcription.Name)){
                updateProvisionedProduct.Subscription__c = sSusbcription.Id;
                updateProvisionedProduct.Private_Email__c = sSusbcription.Private_Email__c;
            }          
        }
     }
   
}