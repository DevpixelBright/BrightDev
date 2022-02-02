trigger RETS_SubProduct on RETS_Sub_Products__c (after insert, before update) {
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    if((Trigger.isAfter && Trigger.IsInsert) || (Trigger.isBefore && Trigger.isUpdate)){
        list<RETS_Sub_Products__c> lstSubProds = [ Select id, Name, RETS_Billing_Exclusion__c, Vendor_Product__r.RETS_Billing_Exclusion__c 
                                                    From RETS_Sub_Products__c Where id in: Trigger.New];
        
        for(RETS_Sub_Products__c sub : lstSubProds){
            system.debug('----sub--->'+sub.id+'---'+Trigger.newMap.get(sub.id).RETS_Billing_Exclusion__c);
            if(sub.Vendor_Product__r.RETS_Billing_Exclusion__c != null && (Trigger.newMap.get(sub.id).RETS_Billing_Exclusion__c == null || !Trigger.newMap.get(sub.id).RETS_Billing_Exclusion__c.contains(sub.Vendor_Product__r.RETS_Billing_Exclusion__c))){
                Trigger.NewMap.get(sub.id).RETS_Billing_Exclusion__c.addError('Must contain Vendor Product exclusion list or more');
            }
        }
    }
}