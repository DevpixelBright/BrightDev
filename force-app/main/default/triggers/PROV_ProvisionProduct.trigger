trigger PROV_ProvisionProduct on SMS_Provisioned_Product__c (after insert, after update) {
    System.debug('*** Trigger SMS_ProvisionProducttesting ***');
    for(SMS_Provisioned_Product__c product : trigger.new){
        if(product.Provisioned_Status__c == 'Pending Provisioned' || product.Provisioned_Status__c == 'Pending Deprovisioned'){
            if(!(System.isFuture() || System.isBatch())){
                PROV_ProvisionProduct pp = new PROV_ProvisionProduct(product);  
            }             
        }
    }
    if(Trigger.isAfter && (Trigger.isInsert)){
        if(ErrorProvisionedHandler.isFirstTime){
            ErrorProvisionedHandler.isFirstTime = false;
            //ErrorProvisionedHandler.provProdTC(Trigger.New);
        }
    }
}