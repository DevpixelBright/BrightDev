trigger SubLicenseUpdate on Subscription_License__c (before insert, before update) {
    
    /*if (Utils.BypassValidationrules())return;
    
    if(Trigger.isBefore ){
        if ( Trigger.isInsert) {
            SubLicenseTriggerHandler.validateSubLicense(Trigger.New);
        }
        
        if(Trigger.isUpdate){
            SubLicenseTriggerHandler.validateSubLicense(Trigger.New);
        }
    }*/
}