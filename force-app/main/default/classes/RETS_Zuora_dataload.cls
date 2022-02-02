public class RETS_Zuora_dataload {
    
    public SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
    public Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
    public void updateBilling(){
        List<RETS_Product_Order__c> orders = [Select id, name, Agent__c, Brokerage__c, End_Date__c, Is_External_Billing__c,
                                              On_Behalf_of_Agent__c, RETS_Sub_Product__c, Start_Date__c, 
                                              Status__c, 
                                              Vendor_Order_Description__c, 
                                              Vendor_Product__c,
                                              Vendor_Product__r.RETS_BillingHasFullDiscount__c,
                                              Vendor_Product__r.RETS_Billing_Type__c,
                                              Vendor_Product__r.RETS_Broker_Count__c,
                                              Vendor_Product__r.RETS_Agent_Count__c,
                                              Vendor_Product__r.RETS_Product_Count__c
                                              From RETS_Product_Order__c];
        
        Map<String,Decimal> vendorSubcontractorCounts = new Map<String,Decimal>();
        Map<String,Decimal> vendorEnterpriseCounts = new Map<String,Decimal>();
        Map<String,Decimal> brokerCounts = new Map<String,Decimal>();
        Map<String,Decimal> agentCounts = new Map<String,Decimal>();
        Set<ID> AgentIDs = new Set<ID>();
        
        for(RETS_Product_Order__c o : orders){
            if(o.Vendor_Product__r.RETS_Billing_Type__c == 'Subcontractor')
                vendorSubcontractorCounts.put(o.Vendor_Product__c, o.Vendor_Product__r.RETS_Broker_Count__c + o.Vendor_Product__r.RETS_Agent_Count__c);
            else if(o.Vendor_Product__r.RETS_Billing_Type__c == 'Enterprise')
                vendorSubcontractorCounts.put(o.Vendor_Product__c, o.Vendor_Product__r.RETS_Broker_Count__c);
            
            brokerCounts.put(o.Brokerage__c, o.Vendor_Product__r.RETS_Product_Count__c);
            
            AgentIDs.add(o.Agent__c);
        }
        
        List<Subscriptions__c> agentSubs = [select id,name,RETS_Product_count__c from subscriptions__c where id in : AgentIDs];
        for(Subscriptions__c s : agentSubs){
            agentCounts.put(s.id, s.RETS_Product_count__c);
        }
        
        
        String zProdID = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductId__c;
        String zProductRatePlanId = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanId__c;
        String zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanChargeId__c;
        
        // for agents
        for(String agentID :agentCounts.keySet()) {
            
            String accountQuery = 'SELECT Id,Name FROM Account WHERE SubscriptionID__c = \'' + agentID + '\'';
            String serviceActivationDate = DateTime.now().format('yyyy-MM-dd','PST');
            Decimal quantity = agentCounts.get(agentID);
            String description = 'New order';
            List<Zuora.zApi.SubscribeRequest> subRequestList = new List<Zuora.zApi.SubscribeRequest>() ;
            
            
            system.debug('***accountQuery'+accountQuery);
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
            String zAccountId = String.valueOf(zAccounts[0].getValue('Id'));
            
            Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
            
            request.ZAccount = new Zuora.zObject('Account');
            request.ZAccount.setValue('Id', zAccountId);
            
            request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
            request.SubscribeOptions.GenerateInvoice = false;
            request.SubscribeOptions.ProcessPayments = false;
            
            request.PreviewOptions = new Zuora.zApi.PreviewOptions();
            request.PreviewOptions.EnablePreviewMode = false;
            
            request.SubscriptionData = new Zuora.zApi.SubscriptionData();
            
            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('ContractEffectiveDate', serviceActivationDate);
            subscription.setValue('ServiceActivationDate', serviceActivationDate);
            subscription.setValue('TermType', 'TERMED');
            
            subscription.setValue('InitialTerm', '1');
            subscription.setValue('RenewalTerm', '1');
            
            subscription.setValue('AutoRenew', true);
            subscription.setValue('IsCore__c', false);
            
            request.SubscriptionData.Subscription = subscription;
            
            List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            
            ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
            
            
            Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
            ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
            //ratePlanCharge.setValue('Price', price);
            ratePlanCharge.setValue('Quantity', quantity);
            ratePlanCharge.setValue('Description', description);
            
            Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
            ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
            
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            ratePlanData.setValue('RatePlan', ratePlan);
            ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
            
            ratePlanDataList.add(ratePlanData);
            
            request.SubscriptionData.RatePlanData = ratePlanDataList;    
            
            subRequestList.add(request);
            List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
            system.debug('*** Subscription Results :' + results);
            
        }
        // implement for brokers
        // implement for vendors
        
    }
    
}