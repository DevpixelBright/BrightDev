public class SMS_Provisioned_Product_Discounts {
    
    @AuraEnabled
    public static List<wrapper> getProductRatePlans(String recordId, String provisionedStatus, String productSubType) {
        List<wrapper> lDiscounts = new List<wrapper>();
        lDiscounts.add(new wrapper('--None--', '', ''));
        SMS_Provisioned_Product__c oProvisionedPrdt = [SELECT Id, Name, Provisioned_Status__c, Product_Sub_Type__c, Product_Type__c, Zuora_Product_Id__c, Zuora_Product_Rate_Plan_Id__c FROM SMS_Provisioned_Product__c WHERE Id =: recordId];
        if(oProvisionedPrdt.Provisioned_Status__c == 'Provisioned'){
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zLogin();
            
            String zProductRatePlanId = oProvisionedPrdt.Zuora_Product_Rate_Plan_Id__c; // Id of the rate plan that needs discount
            String zQuery = 'SELECT Id, ProductRatePlanChargeId, AppliedProductRatePlanId, AppliedProductRatePlanChargeId FROM ProductDiscountApplyDetail WHERE AppliedProductRatePlanId =\'' + zProductRatePlanId + '\'';
            List<Zuora.zObject> zObject = zUtilInstance.zquery(zQuery);
            system.debug(zObject.size());
            
            //Product rate plan charge
            Integer count = 0;
            String ProductRatePlanChargeQuery = '';
            List<Zuora.zObject> zProductRatePlanCharge = new List<Zuora.zObject>();
            List<Zuora.zObject> zProductRatePlanChargeResult = new List<Zuora.zObject>();
            for (Zuora.zObject zcharge: zObject) {
                if(count == 0)
                    ProductRatePlanChargeQuery = 'SELECT Id, Name, ProductRatePlanId FROM ProductRatePlanCharge WHERE ';
                
                if (count > 0)
                    ProductRatePlanChargeQuery += ' OR ';        
                
                ProductRatePlanChargeQuery += 'Id = \'' + (String)zcharge.getValue('ProductRatePlanChargeId') + '\' ';
                count++;
                
                if(count > 198) {
                    zProductRatePlanChargeResult = zUtilInstance.zquery(ProductRatePlanChargeQuery);
                    zProductRatePlanCharge.addAll(zProductRatePlanChargeResult);
                    count = 0;
                    ProductRatePlanChargeQuery = '';
                }
            }
            
            zProductRatePlanChargeResult = zUtilInstance.zquery(ProductRatePlanChargeQuery);
            zProductRatePlanCharge.addAll(zProductRatePlanChargeResult);
            system.debug('****' + zProductRatePlanCharge.Size());
            
            Boolean flag = false;
            Map<String, set<String>> mRPtoRPC = new Map<String, Set<String>>();
            String ProductRatePlanQuery = 'SELECT Id, Name, EffectiveStartDate, EffectiveEndDate FROM ProductRatePlan WHERE ';
            for (Zuora.zObject zProdRatePlanCharge: zProductRatePlanCharge) {
                system.debug('zProdRatePlanCharge');
                system.debug(zProdRatePlanCharge);
                if(!mRPtoRPC.containsKey((String)zProdRatePlanCharge.getValue('ProductRatePlanId'))){
                    mRPtoRPC.put((String)zProdRatePlanCharge.getValue('ProductRatePlanId'), new Set<String>());
                }
                mRPtoRPC.get((String)zProdRatePlanCharge.getValue('ProductRatePlanId')).add((String)zProdRatePlanCharge.getValue('Id'));
                if (flag)
                    ProductRatePlanQuery += ' OR ';        
                
                ProductRatePlanQuery += 'Id = \'' + (String)zProdRatePlanCharge.getValue('ProductRatePlanId') + '\' ';
                flag = true;
            }
            
            List<Zuora.zObject> zProductRatePlan = zUtilInstance.zquery(ProductRatePlanQuery);    
            
            for (Zuora.zObject zProdRatePlan: zProductRatePlan) { 
                system.debug('zProdRatePlan');
                system.debug(zProdRatePlan);
                Date EffectiveStartDate = (Date)zProdRatePlan.getValue('EffectiveStartDate');
                Date EffectiveEndDate = (Date)zProdRatePlan.getValue('EffectiveEndDate');
                if(EffectiveStartDate!= null && EffectiveEndDate != null && EffectiveStartDate <= system.today() && EffectiveEndDate >= system.today() && mRPtoRPC.containsKey((String)zProdRatePlan.getValue('Id'))){
                    for(String RPC : mRPtoRPC.get((String)zProdRatePlan.getValue('Id')))
                    	lDiscounts.add(new wrapper((String)zProdRatePlan.getValue('Name'), RPC, (String)zProdRatePlan.getValue('Id')));
                }
            }
            
            system.debug('mRPtoRPC');
            system.debug(mRPtoRPC);
        }
        return lDiscounts;
    }
     
    @AuraEnabled
    public static Boolean applyDiscount(String zDiscountRateplanId, String zDiscountRateplanChargeId, String recordId){
        SMS_Provisioned_Product__c oProvisionedPrdt = [SELECT Id, Name, Provisioned_Status__c, Product_Sub_Type__c, Product_Type__c, Zuora_Product_Id__c, Zuora_Product_Rate_Plan_Id__c, Subscription__r.name FROM SMS_Provisioned_Product__c WHERE Id =: recordId];
        if(oProvisionedPrdt.Provisioned_Status__c == 'Provisioned' && String.isNotBlank(zDiscountRateplanId) && String.isNotBlank(zDiscountRateplanChargeId)){
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zLogin();
            
            
            String accountQuery = 'SELECT Id,Name FROM Account WHERE SubscriptionID__c = \'' + oProvisionedPrdt.Subscription__r.name + '\'';
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);        
            String zAccountId = String.valueOf(zAccounts[0].getValue('Id'));     
            
            String subQuery = 'SELECT Id FROM Subscription WHERE AccountId = \'' + zAccountId + '\' AND Status=\'Active\'';
            List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
            system.debug('zsubscriptions : '+zSubscriptions);
            List<String> zSubscriptionIDs = new List<String>();
            for (Zuora.zObject zSubscription : zSubscriptions) {
                zSubscriptionIDs.add(String.valueOf(zSubscription.getValue('Id')));
            }
                        
            integer i =0;
            String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
            for (String zSubscriptionId : zSubscriptionIDs) {
                if (i != 0)
                    ratePlansQuery += ' OR ';        
                
                ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
                i++;
            }
            
            String zSubId , zRateplanId;
            if(i != 0){            
                List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);            
                for(Zuora.zObject zRatePlan : zRatePlans) {                
                    if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == oProvisionedPrdt.Zuora_Product_Rate_Plan_Id__c ){
                        zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                        zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                        break;
                    }
                }
            }
            
            system.debug('zRateplanId : '+zRateplanId);
            String RatePlanChargeQuery = 'SELECT Id, BillCycleDay, BillCycleType, BillingPeriod, BillingPeriodAlignment, EffectiveStartDate, EffectiveEndDate, ChargedThroughDate FROM RatePlanCharge where RatePlanId = \'' + zRateplanId + '\'';// AND Status=\'Active\'';
            List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(RatePlanChargeQuery);
            String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
            if(zRatePlanCharges.size() > 0){
                /*Integer eDate = (Integer)zRatePlanCharges[0].getValue('BillCycleDay');
                Date d = Date.today();
                system.debug(zRatePlanCharges[0].getValue('BillingPeriod'));
                if((String)zRatePlanCharges[0].getValue('BillingPeriod') == 'Month'){
                    if(d.day() > eDate){
                        d = d.addMonths(1);
                    }
                }else if((String)zRatePlanCharges[0].getValue('BillingPeriod') == 'Quater'){
                    if(d.day() > eDate){
                        d = d.addMonths(1);
                    }
                }
                
                Datetime effDate = Datetime.newinstance(d.year(), d.month(), eDate);
                effectiveDate = effDate.format('yyyy-MM-dd','PST');*/
                system.debug(zRatePlanCharges[0].getValue('ChargedThroughDate'));
                
                effectiveDate = String.valueOf((zRatePlanCharges[0].getValue('ChargedThroughDate')));
                effectiveDate = effectiveDate.split(' ')[0];
            }
            
            Zuora.zApi.AmendRequest request = getNewProductAmendmentRequest(zsubID, zDiscountRateplanId, effectiveDate);
            system.debug(request);
            List<Zuora.zApi.AmendRequest> amendRequestList  = new List<Zuora.zApi.AmendRequest>();  
            amendRequestList.add(request);
            
            Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);                                
            System.Debug('*** amendResults : '+ amendResults);
            return amendResults.Success;
        }
        return false;
    }
    
    //used for integration test
    public Static Zuora.zApi.AmendRequest getNewProductAmendmentRequest(String zSubscriptionId,String zProductRatePlanId, String effectiveDate) {
        //String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId',zProductRatePlanId);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Add a New Product');
        amendment.setValue('SubscriptionId',zSubscriptionId);
        
        amendment.setValue('Type', 'NewProduct');
        amendment.setValue('RatePlanData',ratePlanData);
        
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = false;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    }
    
    public class wrapper{
        @AuraEnabled public String ratePlanChargeId;
        @AuraEnabled public String ratePlanId;
        @AuraEnabled public String label;
        
        public wrapper(String label, String ratePlanChargeId, String ratePlanId){
            this.ratePlanChargeId = ratePlanChargeId;
            this.label = label;
            this.ratePlanId = ratePlanId;
        }
    }
}