trigger LicenseUpdate on License__c (after update,before insert, before update) {
    if(Trigger.isAfter ){
    List<Subscription_License__c> subscriptionLicenses = new List<Subscription_License__c>();
    
    for(Subscription_License__c subLicense : [SELECT Id, Notes__c 
                                              FROM   Subscription_License__c
                                              WHERE  License__c IN :trigger.oldMap.keyset()
                                             ]){
                                                 subLicense.Notes__c = 'License update on ' + system.now();
                                                 subscriptionLicenses.add(subLicense);
                                             }
    update subscriptionLicenses;
    }
    
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
   /* if(Trigger.isBefore ){
        if ( Trigger.isInsert) {
            LicenseTriggerHandler.validateLicense(Trigger.New);
        }
        
        if(Trigger.isUpdate){
            LicenseTriggerHandler.validateLicense(Trigger.New);
        }
    }*/
}