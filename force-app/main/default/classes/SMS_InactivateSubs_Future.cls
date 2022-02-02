public class SMS_InactivateSubs_Future{
    private Static String sSubscriptionId; 
    private Static String zCloudCMASubId;   
    private Static List<SMS_Auto_Suspended_Account__c> pendingSuspendAccounts;
    private Static List<SMS_Provisioned_Product__c> provisionedProducts;    
    
    private Static Zuora.zObject zAccount; 
    private Static String zAccountId;
    
    @TestVisible private Static SMS_ZuoraUtil zUtilInstance;
    private Static Zuora.zApi.LoginResult zLoginResult;
    
    private Static String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST'); 
    
    
    public Static void inactivateSubscription(String subId) 
    {  
        if(System.isBatch() || System.isFuture()){
            inactivateSubscriptionApex(subId);
        }else{
            inactivateSubscriptionFuture(subId);
        }
    }
    @future (callout = true)
    public Static void inactivateSubscriptionFuture(String subId) 
    {
        inactivateSubscriptionApex(subId);
    }
    
    public Static void inactivateSubscriptionApex(String subId) 
    {        
        try {        
            sSubscriptionId = subId;
            zCloudCMASubId = null;
            
            pendingSuspendAccounts = new List<SMS_Auto_Suspended_Account__c>();            
            provisionedProducts = new List<SMS_Provisioned_Product__c>();       
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();   
            
            inactivateZuoraSubscriptionIds();
            
            setDefaultPaymentMethodtoCheck();            
            
            deleteZPaymentMethodIds();            
            
            pendingSuspendAccounts = [SELECT Id,
                                      Status__c,Status_Message__c,
                                      MRIS_Subscription_ID__c,
                                      Zuora_Account_Id__c
                                      FROM   SMS_Auto_Suspended_Account__c 
                                      WHERE  MRIS_Subscription_ID__c = :sSubscriptionId
                                      AND    Status__c = 'In Progress'
                                      LIMIT  1
                                     ];
            
            system.debug('*** pendingSuspendAccounts :' + pendingSuspendAccounts);
            system.debug('*** pendingSuspendAccounts size :' + pendingSuspendAccounts.size());  
            
            if(pendingSuspendAccounts.size() > 0)
            {   
                Zuora__CustomerAccount__c zAcct = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__Balance__c 
                                                   FROM Zuora__CustomerAccount__c 
                                                   WHERE SubscriptionID__c = :pendingSuspendAccounts[0].MRIS_Subscription_ID__c];
                
                if (zAcct.Zuora__Balance__c > 0) {
                    
                    zAcct.Invoice_REST_Response__c = SMS_UpdateZInvoice.updateZInvoice(zAcct.Id);
                    zAcct.Email_Invoice_PDF__c = false; 
                    update zAcct;
                    
                    zAcct.Email_Invoice_PDF__c = true; 
                    update zAcct;
                    
                }
                updateProductsProvisioned('Subscription Auto-Suspended');
                
                pendingSuspendAccounts[0].Status__c = 'Success';
                update pendingSuspendAccounts[0];
            }
            else {
                if(String.isNotBlank(zCloudCMASubId)){
                    List<Zuora.zApi.DeleteResult> zDeleteResult = new List<Zuora.zApi.DeleteResult>();
                    
                    zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { zCloudCMASubId });
                    SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_InactivateSubs_Future', sSubscriptionId);
                }
                updateProductsProvisioned('Subscription Terminated');
                
            }
            
            SMS_ZuoraHistory.createSuccess('SMS_InactivateSubs_Future',sSubscriptionId);
        }
        catch(Exception e) {
            if(pendingSuspendAccounts.size() > 0) {                
                List<SMS_Auto_Suspended_Account__c> updateSuspendAccounts = new List<SMS_Auto_Suspended_Account__c>();
                
                for(SMS_Auto_Suspended_Account__c pendingSuspendAccount : pendingSuspendAccounts) {
                    pendingSuspendAccount.Status__c = 'Failed'; 
                    pendingSuspendAccount.Status_Message__c = e.getMessage();                   
                    updateSuspendAccounts.add(pendingSuspendAccount);
                }
                
                update updateSuspendAccounts;
            }
            
            system.debug('&&&&' + e.getStackTraceString());
            
            SMS_ZuoraHistory.createError(e,'SMS_InactivateSubs_Future',sSubscriptionId);
        }                  
    }
    
    private Static void updateProductsProvisioned(String productStatusReason) { 
        system.debug('*** Products provisioned : ' + sSubscriptionId);
        
        if (provisionedProducts.Size() > 0) {
            List<SMS_Provisioned_Product__c> provProducts = new List<SMS_Provisioned_Product__c>();
            for(SMS_Provisioned_Product__c provisionedProduct : provisionedProducts) {
                provisionedProduct.Product_Status__c = 'Terminate';
                provisionedProduct.Provisioned_Status__c = 'Pending Deprovisioned';
                provisionedProduct.Product_Status_Reason__c = productStatusReason;
                provProducts.add(provisionedProduct);    
            }
            PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProducts);
            //update provisionedProducts;
        }  
    }   
    
    private Static void inactivateZuoraSubscriptionIds() {        
        String zCloudCMARatePlanId = setZCloudCMARatePlanId();
        Set<String> notInvoicedZSubIds = new Set<String>();
        
        setZuoraAccount();       
        
        List<Zuora.zObject> zSubscriptions = getZuoraSubscriptions();
        Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date(); 
        
        List<Subscriptions__c> lSubs = [SELECT Id, Status__c, Status_Change_Reason__c FROM Subscriptions__c WHERE Name =: sSubscriptionId AND Status_Change_Reason__c = 'Suspended' AND Status__c = 'Inactive'];
        system.debug('*** zSubscriptions : ' +zSubscriptions ); 
        system.debug('*** lSubs : ' +lSubs ); 
        Map<String,Set<String>> mRatePlanNames = getRatePlanNames(zSubscriptions);
        set<String> excludedNames = new Set<String>();
        if(!lSubs.isEmpty()){
            for(SMS_Excluded_Zuora_Product_Rate_Plans__c ratePlanType : SMS_Excluded_Zuora_Product_Rate_Plans__c.getall().values()){ 
                excludedNames.add(ratePlanType.Name);
            }
        }   
        for(Zuora.zObject zSubscription : zSubscriptions) {
            String zSubscriptionId = (String)zSubscription.getValue('Id');
            
            if(((Date)zSubscription.getValue('TermStartDate')) > todayDate) { 
                List<Zuora.zApi.DeleteResult> zDeleteResult = new List<Zuora.zApi.DeleteResult>();
                
                zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { zSubscriptionId }); //will be used while writing test classes
                SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_InactivateSubs_Future', zSubscriptionId);
                
            }
            else if(((Date)zSubscription.getValue('ServiceActivationDate')) > todayDate && String.isNotBlank(zCloudCMARatePlanId)){
                notInvoicedZSubIds.add(zSubscriptionId);
            }
            else if(((Date)zSubscription.getValue('TermEndDate')) >= todayDate) {
                if(!lSubs.isEmpty()){
                    boolean flag = false;
                    for(String zRPlan : mRatePlanNames.get(zSubscriptionId)){
                        if(excludedNames.contains(zRPlan)){
                            flag = true;
                            break;
                        }
                    }
                    if(flag)
                        continue;
                }
                Zuora.zApi.AmendResult zAmendResult = new Zuora.zApi.AmendResult();                
                
                zAmendResult = zUtilInstance.zamend(getAutoRenewAmendmentRequest(zSubscriptionId)); //will be used while writing test classes
                SMS_ZuoraHistory.processZResults(zAmendResult,'SMS_InactivateSubs_Future', zSubscriptionId);
            }                                                                         
        } 
        
        if(notInvoicedZSubIds.size() > 0) 
            setCloudCMAZSubId(notInvoicedZSubIds, zCloudCMARatePlanId);              
    }
    @TestVisible
    private Static void setCloudCMAZSubId(Set<String> zSubscriptionIds, String zCloudCMARatePlanId){
        String zRatePlanQuery = 'SELECT Id, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        List<Zuora.zObject> zRatePlans = new List<Zuora.zObject>();
        Boolean isNotFirst = false;
        
        for(String zSubscriptionId : zSubscriptionIds) {
            system.Debug('*** zSubscriptionId : ' + zSubscriptionId);
            if (isNotFirst) 
                zRatePlanQuery += ' OR ';
            
            zRatePlanQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            isNotFirst = true;                         
        }
        
        if(isNotFirst){
            zRatePlans = zUtilInstance.zquery(zRatePlanQuery);
            if(zRatePlans.size() > 0){
                for(Zuora.zObject zRatePlan : zRatePlans) {
                    system.debug('*** zRatePlan : ' + zRatePlan);
                    String zProductRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                    if(zProductRatePlanId == zCloudCMARatePlanId){
                        zCloudCMASubId = (String)zRatePlan.getValue('SubscriptionId');
                    }
                }
            }
        } 
    }
    
    private Static String setZCloudCMARatePlanId(){
        String zProductRatePlanId = null;
        provisionedProducts = [SELECT  Id,
                               Name,
                               LastModifiedDate,
                               MRIS_Subscription_Id__c,
                               Order_Id__c,
                               Product_Status__c,
                               Product_sub_type__c,
                               product_type__c,
                               provisioned_product_Id__c,
                               provisioned_status__c,
                               xactsite_office_id__c,
                               zuora_product_id__c,
                               zuora_product_rate_plan_id__c,
                               Authentisign_Id__c,
                               Authentisign_User_Id__c,
                               Previous_Provisioned_Status__c,
                               RealPing_Id__c,
                               Status_Message__c,
                               Product_Status_Reason__c
                               FROM   SMS_Provisioned_Product__c
                               WHERE  MRIS_Subscription_Id__c = :sSubscriptionId
                               AND    provisioned_status__c != 'Deprovisioned'
                              ];
        
        for(SMS_Provisioned_Product__c pp : provisionedProducts){
            if(pp.Product_Type__c == 'CloudCMA')
                zProductRatePlanId = pp.zuora_product_rate_plan_id__c;
        }
        
        return zProductRatePlanId;
    }
    
    private Static List<Zuora.zObject> getZuoraSubscriptions() {          
        
        List<Zuora.zObject> zSubscriptions = new List<Zuora.zObject>();
        
        String subscriptionQuery = 'SELECT Id,AccountId,AutoRenew,Status,TermEndDate,TermStartDate,TermType,ServiceActivationDate FROM Subscription WHERE ';
        subscriptionQuery += 'AccountId = \'' + zAccountId + '\' AND Status = \'Active\' AND TermType = \'TERMED\' AND AutoRenew = true';
        
        zSubscriptions = zUtilInstance.zquery(subscriptionQuery);// will be used while writing test classes        
        
        return zSubscriptions;
    }
    
    private Static void setZuoraAccount() {        
        String accountQuery = 'SELECT Id, Status, Name, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + sSubscriptionId + '\'' + ' AND Status = \'Active\'';
        
        List<Zuora.Zobject> zAccounts = zUtilInstance.zquery(accountQuery); //will be used while writing test classes 
        
        if(zAccounts == null) throw new CustomException('No Zuora Accounts found'); 
        
        if(zAccounts.size() > 1) throw new CustomException('More than one Zuora Account found');
        
        zAccount = zAccounts[0];
        zAccountId = (String)zAccount.getValue('Id');                  
    }
    
    @TestVisible
    private Static void setDefaultPaymentMethodtoCheck(){
        
        List<Zuora.zObject> check = zUtilInstance.zquery('SELECT Id FROM PaymentMethod WHERE Type = \'Check\''); //will be used while writing test classes
        
        Zuora.Zobject zUpdateAccount = new Zuora.Zobject('Account');
        zUpdateAccount.setValue('Id',(String)zAccount.getValue('Id'));
        zUpdateAccount.setValue('AutoPay',false);
        zUpdateAccount.setValue('DefaultPaymentMethodId', (String)check[0].getValue('Id'));
        
        List<Zuora.zApi.SaveResult> zSaveResult = zUtilInstance.zupdate(new List<Zuora.Zobject>{zUpdateAccount}); //will be used while writing test classes
        SMS_ZuoraHistory.processZResults(zSaveResult, 'SMS_InactivateSubs_Future', sSubscriptionId);
    }
    @TestVisible
    private Static void deleteZPaymentMethodIds() {
        
        List<String> zPaymentMethodIds = new List<String>();
        List<Zuora.zObject> zPaymentMethods = new List<Zuora.zObject>();
        
        String paymentMethodQuery = 'SELECT Id FROM PaymentMethod WHERE AccountId = \'' + zAccountId + '\'';
        
        zPaymentMethods = zUtilInstance.zquery(paymentMethodQuery); //will be used while writing test classes
        
        for(Zuora.zObject zPaymentMethod : zPaymentMethods){
            String zPaymentMethodId = (String)zPaymentMethod.getValue('Id');             
            zPaymentMethodIds.add(zPaymentMethodId);
        }
        
        if(zPaymentMethodIds.size() > 0){
            List<Zuora.zApi.DeleteResult> zDeleteResult = zUtilInstance.zdelete('PaymentMethod',zPaymentMethodIds); //will be used while writing test classes
            SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_InactivateSubs_Future', sSubscriptionId);  
        }   
        
    } 
    
    private Static List<Zuora.zApi.AmendRequest> getAutoRenewAmendmentRequest(String zSubscriptionId){
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        
        request.Amendments = new List <Zuora.zObject>();    
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Set Auto Renew to False');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        
        amendment.setValue('Type', 'TermsAndConditions');
        amendment.setValue('AutoRenew', false);
        
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate',effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = true;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        system.debug('*** Batch Amend Auto Renew Request : ' + request );
        return new List<Zuora.zApi.AmendRequest> { request };
    }
    
    public class CustomException extends Exception {} 
    
    private static Map<String,Set<String>> getRatePlanNames(List<Zuora.zObject> zSubscriptions){
        Map<String,Set<String>> zSubRatePlanNames = new Map<String,Set<String>>();
        if(zSubscriptions != null && zSubscriptions.size() > 0){
            String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
            boolean flag = false;
            for (Zuora.zObject zSubscription : zSubscriptions) {
                if(flag){
                    ratePlansQuery += ' OR ';  
                }
                ratePlansQuery += 'SubscriptionId = \'' + (String)zSubscription.getValue('Id') + '\'';
                flag = true;
            }
            List<Zuora.zObject> zRatePlanSubscriptions = zUtilInstance.zquery(ratePlansQuery);
            for(Zuora.zObject zRatePlanSubscription : zRatePlanSubscriptions) {
                system.debug('$$$ Rate Plan Name: ' + String.valueOf(zRatePlanSubscription.getValue('Name')));
                String zSubId = String.valueOf(zRatePlanSubscription.getValue('SubscriptionId'));
                
                if(!zSubRatePlanNames.containsKey(zSubId))
                    zSubRatePlanNames.put(zSubId,new Set<String>());                    
                zSubRatePlanNames.get(zSubId).add(String.valueOf(zRatePlanSubscription.getValue('Name')));
            }
        }
        return zSubRatePlanNames;
        
    }
    
}