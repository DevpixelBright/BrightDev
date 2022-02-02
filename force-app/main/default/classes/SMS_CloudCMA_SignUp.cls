public Class SMS_CloudCMA_SignUp {
    public Id recordId { get; set; }
     
    public zSubscriptionSummary getzSubscriptionResult() {
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        /*
        List<SMS_Provisioned_Product__c> provisionProductList = [SELECT Id,
                                                              Name,
                                                              MRIS_Subscription_Id__c,
                                                              zuora_product_id__c,
                                                              zuora_product_rate_plan_id__c,
                                                              Order_Id__c
                                                       FROM SMS_Provisioned_Product__c
                                                       WHERE Id = :recordId];                                   
        if(provisionProductList.Size() == 1) {
        SMS_Provisioned_Product__c provisionProduct = provisionProductList[0];
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        
        String zAccountQuery = 'SELECT Id, Name FROM Account WHERE AccountNumber = \'' + provisionProduct.MRIS_Subscription_Id__c + '\'';        
        List<Zuora.zObject> zAccount = zUtilInstance.zquery(zAccountQuery);
            
        String zSubscriptionQuery = 'SELECT Id, Name, ContractEffectiveDate, ServiceActivationDate, TermStartDate, TermEndDate, SubscriptionStartDate, SubscriptionEndDate FROM Subscription WHERE AccountId = \'' + (String)zAccount[0].getValue('Id') + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionQuery);
        
        Integer i = 0;
        String zRatePlanQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';     
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            
            if (i != 0)
                zRatePlanQuery += ' OR ';        
            
            zRatePlanQuery += 'SubscriptionId = \'' + (String)zSubscription.getValue('Id') + '\'';
            i++;            
        }
        
        List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(zRatePlanQuery);
        System.debug(zRatePlans);
        zSubscriptionSummary obj = new zSubscriptionSummary();
        for(Integer j=zRatePlans.Size()-1; j>=0; j--) {
            Zuora.zObject zRatePlan = zRatePlans[j];
            if((String)zRatePlan.getValue('ProductRatePlanId') == provisionProduct.zuora_product_rate_plan_id__c) {
                obj.subscriptionId = (String)zRatePlan.getValue('SubscriptionId');
                obj.ratePlanId = (String)zRatePlan.getValue('Id');
                obj.productRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                break;
            }
        }
        
        String zRatePlanChargeQuery = 'SELECT Id, Name, Price FROM RatePlanCharge WHERE RatePlanId = \'' + obj.ratePlanId + '\'';
        List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(zRatePlanChargeQuery);
        obj.price = (Decimal)zRatePlanCharges[0].getValue('Price');
        
        String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + obj.productRatePlanId + '\'';
        List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
        obj.period = (String)ratePlanCharges[0].getValue('BillingPeriod');
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            if((String)zSubscription.getValue('Id') == obj.subscriptionId) {
                DateTime termStartDate = (Date)zSubscription.getValue('TermStartDate');
                DateTime termEndDate = (Date)zSubscription.getValue('TermEndDate');
                DateTime serviceActivationDate = (Date)zSubscription.getValue('ServiceActivationDate');
                DateTime contractEffectiveDate = (Date)zSubscription.getValue('ContractEffectiveDate');
                
                obj.serviceActivationDate = serviceActivationDate.addDays(-1).formatGmt('MM/dd/YYYY');
                break;
            }   
        }
        return obj;
        }
        else
        */
            return new zSubscriptionSummary();
        
    }
     
    public class zSubscriptionSummary {
        public String subscriptionId { get; set; }
        public String ratePlanId { get; set; }
        public String productRatePlanId { get; set; }
        public Decimal price { get; set; }
        public String period { get; set; }
        public String termStartDate { get; set; }
        public String termEndDate { get; set; }
        public String serviceActivationDate { get; set; }
        public String contractEffectiveDate { get; set; }
    }

}