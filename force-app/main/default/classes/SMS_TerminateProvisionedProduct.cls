public class SMS_TerminateProvisionedProduct {
    
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    
    private String productId ;
    
    public SMS_TerminateProvisionedProduct() {
        try {
            productId = ApexPages.currentpage().getparameters().get('id');
            if (String.isBlank(productId))
                throw new CustomException('Invalid provisioned product Id');
            
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        } 
    }
    public PageReference terminateProvisionedProduct() {
        String sSubscriptionId = null;
        Boolean isCloudCMA = false;
        SMS_Provisioned_Product__c provisionedProduct = new SMS_Provisioned_Product__c();
        try {        
            provisionedProduct = [SELECT id, Name, 
                                         Product_Status_Reason__c,
                                         MRIS_Subscription_Id__c, 
                                         Provisioned_Status__c,
                                         Product_Status__c,
                                         Product_Type__c,
                                         Zuora_Product_Rate_Plan_Id__c
                                  FROM SMS_Provisioned_Product__c 
                                  WHERE id = :productId];
                                  
            if(!provisionedProduct.Provisioned_Status__c.equals('Provisioned'))
                throw new CustomException('This product cannot be terminated since it is not Provisioned');
                
            if(provisionedProduct.Product_Type__c == 'CloudCMA')
                isCloudCMA = true;
                
            provisionedProduct.Provisioned_Status__c = 'Pending Deprovisioned'; 
            provisionedProduct.Product_Status__c = 'Terminate';
            provisionedProduct.Product_Status_Reason__c = 'Staff Terminated';
            sSubscriptionId =   provisionedProduct.MRIS_Subscription_Id__c;     
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin(); 
            
            String zAccountsQuery = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + provisionedProduct.MRIS_Subscription_Id__c + '\'';
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery); 
            
            String zAccountId = (String)zAccounts[0].getValue('Id');
            if(String.isBlank(zAccountId))
                throw new CustomException('Zuora account does not exists.'); 
                
            String zSubscriptionQuery = 'SELECT Id, Name, ServiceActivationDate FROM Subscription WHERE AccountId =\'' + zAccountId + '\' AND IsCore__c = \'false\' AND Status = \'Active\'';                                                             
            List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionQuery);
            Map<String,Date> zSubIdSAD = new Map<String,Date>();
            
            String zRatePlanQuery = 'SELECT Id, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
            List<Zuora.zObject> zRatePlans = new List<Zuora.zObject>();
            Boolean isNotFirst = false;
            
            for(Zuora.zObject zSubscription : zSubscriptions) {
                String zSubscriptionId = (String)zSubscription.getValue('Id');
                system.Debug('*** zSubscriptionId : ' + zSubscriptionId);
                if (isNotFirst) 
                    zRatePlanQuery += ' OR ';
                
                zRatePlanQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
                isNotFirst = true; 
                
                zSubIdSAD.put(zSubscriptionId,((Date)zSubscription.getValue('ServiceActivationDate')));
                
            } 
            
            if(isNotFirst){
                zRatePlans = zUtilInstance.zquery(zRatePlanQuery);
                if(zRatePlans.size() > 0){
                    Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date(); 
                    for(Zuora.zObject zRatePlan : zRatePlans) {
                        system.debug('*** zRatePlan : ' + zRatePlan);
                        String zProductRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                        
                        if(zProductRatePlanId == provisionedProduct.Zuora_Product_Rate_Plan_Id__c){
                            String zSubscriptionId = (String)zRatePlan.getValue('SubscriptionId'); 
                            if(isCloudCMA && zSubIdSAD.get(zSubscriptionId) > todayDate){
                                /*
                                  If ServiceActivationDate is greater than today's date and if it is a CloudCMA product, 
                                  Zuora subscription should be cancelled as this is a subscriber voluntary termination in 
                                  the free period and the invoice is not yet generated.
                                */
                                
                                List<Zuora.zApi.DeleteResult> zDeleteResult = new List<Zuora.zApi.DeleteResult>();
                
                                zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { zSubscriptionId });
                                SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_TerminateProvisionedProduct', sSubscriptionId);
                            }
                            else{
                                system.debug('*** Amend this : ' + (String)zRatePlan.getValue('SubscriptionId'));
                                
                                List<Zuora.zApi.AmendRequest> amendRequestList  = new List<Zuora.zApi.AmendRequest>();  
                                Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest((String)zRatePlan.getValue('SubscriptionId'), false);
                                amendRequestList.add(amendRequest);
                            
                                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                SMS_ZuoraHistory.processZResults(amendResults,'SMS_TerminateProvisionedProduct',sSubscriptionId);
                            }                            
                        }
                    }
                }  
            }
            
            update provisionedProduct;       
            SMS_ZuoraHistory.createSuccess('SMS_TerminateProvisionedProduct',sSubscriptionId);
            PageReference provisionedProductView = new ApexPages.StandardController(provisionedProduct).view();
            return provisionedProductView;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            SMS_ZuoraHistory.createError(e,'SMS_TerminateProvisionedProduct',sSubscriptionId);
            
            return null;
        }  
        
    }
    private Static Zuora.zApi.AmendRequest getAutoRenewAmendmentRequest(String zSubscriptionId, Boolean autoRenew){
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST'); 
 
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Set Auto Renew to ' + autoRenew);
        amendment.setValue('SubscriptionId', zSubscriptionId );
        
        amendment.setValue('Type', 'TermsAndConditions');
        amendment.setValue('AutoRenew', autoRenew);
        
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = true;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    }     
    public class CustomException extends Exception {}
}