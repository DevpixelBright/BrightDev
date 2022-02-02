trigger SMS_SubTypeRatePlan on Zuora__SubscriptionProductCharge__c (before insert, before update) {
    
    Map<String,String> ratePlanSubType = new Map<String,String>();

    for(SMS_SubType_RatePlan__c mapping : SMS_SubType_RatePlan__c.getall().values()){
        ratePlanSubType.put(mapping.Zuora_RatePlan_Name__c, mapping.Sub_Type__c);
    }
    
    for(Zuora__SubscriptionProductCharge__c  zCharge : trigger.new){
        if(ratePlanSubType.keyset().contains(zCharge.Zuora__RatePlanName__c)){
            String subType = ratePlanSubType.get(zCharge.Zuora__RatePlanName__c);
            if(subType == zCharge.Sub_Type__c){
                zCharge.Is_Same_SubType_RatePlan__c = true;
            }
        }
    }

}