public class ExpiringCredits_Zuora {
    
    SMS_ZuoraUtil zUtilInstance;
    Zuora.zApi.LoginResult zLoginResult;
    String expiringCreditRatePlanId;
    String expiringCreditRatePlanChargeId;
    
    Map<String, Exception> subscriptionException ;
    Map<String, Decimal> subscriptionCredit ;
    Map<String, Exception> accountException ;
    Map<String, Decimal> accountCredit ;
    
    
    public ExpiringCredits_Zuora(List<String> recordIds, String objectName){ // recordIds can be subscription ids or account ids
        if(String.isBlank(objectName))
            throw new CustomException('Object Name is not specified'); 
        
        String expiringCreditProductName = Expiring_Credits__c.getall().values()[0].Name;
        expiringCreditRatePlanId = Expiring_Credits__c.getValues(expiringCreditProductName).Zuora_Product_Rate_Plan_Id__c;
        expiringCreditRatePlanChargeId = Expiring_Credits__c.getValues(expiringCreditProductName).Zuora_Product_Rate_Plan_Charge_Id__c;
        
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin();
        
        subscriptionException = new Map<String, Exception>();
        subscriptionCredit = new Map<String, Decimal>();
        
        accountException = new Map<String, Exception>();
        accountCredit = new Map<String, Decimal>();
        
        if(objectName == 'Subscription'){
            for(Subscriptions__c subscription : [SELECT Id, Name, Status__c, DateTerminated__c 
                                                 FROM Subscriptions__c
                                                 WHERE	Name IN :recordIds                    
                                                ]) {
                try{
                    if(subscription.Status__c != 'Inactive')
                        throw new CustomException('Subscription is not Inactive. Its status is ' + subscription.Status__c);                         
                    Zuora.zObject zAccount = getZuoraAccount(subscription.Name);
                    Decimal creditBalance = (Decimal)zAccount.getValue('CreditBalance');
                    String zAccountId = (String)zAccount.getValue('Id');
                    if(CreditBalance == 0){
                        throw new CustomException('No credit balance found for ' + subscription.Name);   
                    }
                    
                    String invoiceId = createExpiringCreditsSubscription(zAccountId, CreditBalance, 'Expiring Credits');
                    applyCreditBalance(invoiceId, creditBalance);
                    
                    subscriptionCredit.put(subscription.Name, creditBalance);
                    //SMS_ZuoraHistory.createSuccess('ExpiringCredits_Zuora: ' + creditBalance, subscription.Name);  
                }
                catch(Exception e){
                    //SMS_ZuoraHistory.createError(e, 'ExpiringCredits_Zuora', subscription.Name);
                    subscriptionException.put(subscription.Name, e);
                    system.debug('Exception from Test: ' + e.getStackTraceString());
                }     
            }
            
        }   
        else if(objectName == 'Account'){
            for(Account acc : [SELECT Id, Name, Status__c 
                               FROM Account
                               WHERE Name IN :recordIds                   
                              ]) {
                try{
                    if(acc.Status__c != 'Inactive')
                        throw new CustomException('Account is not Inactive. Its status is ' + acc.Status__c);
                    
                    Zuora.zObject zAccount = getZuoraAccount(acc.Name);
                    Decimal creditBalance = (Decimal)zAccount.getValue('CreditBalance');
                    String zAccountId = (String)zAccount.getValue('Id');
                    if(CreditBalance == 0){
                        throw new CustomException('No credit balance found for ' + acc.Name);   
                    }
                    
                    String invoiceId = createExpiringCreditsSubscription(zAccountId, CreditBalance, 'Expiring Credits');
                    
                    applyCreditBalance(invoiceId, creditBalance);
                    accountCredit.put(acc.Name, creditBalance);
                    //SMS_ZuoraHistory.createSuccess('ExpiringCredits_Zuora: ' + acc.Name + ', Amount: ' + creditBalance , null);  
                }
                catch(Exception e){
                    //SMS_ZuoraHistory.createError(e, 'ExpiringCredits_Zuora: ' + acc.Name, null); 
                    accountException.put(acc.Name, e);
                }
                
            }
        }
        else
            throw new CustomException('Object Name is neither Subscription nor Account');  
        
        for(String recordName : subscriptionCredit.keySet()){
        	SMS_ZuoraHistory.createSuccess('ExpiringCredits_Zuora: ' + subscriptionCredit.get(recordName), recordName);    
        }
        
        for(String recordName : accountCredit.keySet()){
        	SMS_ZuoraHistory.createSuccess('ExpiringCredits_Zuora: ' + recordName + ', Amount: ' + accountCredit.get(recordName) , null);    
        }
        
        for(String recordName : subscriptionException.keySet()){
        	SMS_ZuoraHistory.createError(subscriptionException.get(recordName), 'ExpiringCredits_Zuora', recordName);    
        }
        
        for(String recordName : accountException.keySet()){
        	SMS_ZuoraHistory.createError(accountException.get(recordName), 'ExpiringCredits_Zuora: ' + recordName, null);    
        }
        
    }
    
    public Zuora.zObject getZuoraAccount(String zAccountNumber){
        String zAccountQuery =  'SELECT Id, Name, SubscriptionID__c, CreditBalance FROM Account WHERE ';   
        
        zAccountQuery += 'SubscriptionID__c = \'' + zAccountNumber + '\'';
        zAccountQuery += ' OR ';
        zAccountQuery += 'AccountNumber = \'' + zAccountNumber + '\'';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountQuery);
        
        if (zAccounts.Size() == 1 ){
            
            return zAccounts[0];
        }            
        else
            throw new CustomException('No related account found for ' + zAccountNumber);
    }
    
    public String createExpiringCreditsSubscription(String zAccountId, Decimal creditAmount, String description){
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(zAccountId, expiringCreditRatePlanId, expiringCreditRatePlanChargeId, creditAmount, description);
        subscribeRequests.add(subscriptionRequest);
        String invoiceId;
        List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subscribeRequests);
        
        for (Zuora.zApi.SubscribeResult result : results){
            if (!result.Success){
                String exceptionMsg = 'Expiring Credit: ';
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                            
                throw new CustomException('Error: ' + exceptionMsg);   
            } 
            else{
                invoiceId = result.InvoiceId; 
            }
        }
        
        return invoiceId;
    }
    
    public void applyCreditBalance(String zInvoiceId, Decimal amount){
        
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', 'Decrease');
        adjustment.setValue('Amount', amount);
        
        List<Zuora.zApi.SaveResult> results = zUtilInstance.zcreate( new List<Zuora.zObject>{adjustment}); 
        system.debug('*** CreditBalance : ' + results );
        
        for (Zuora.zApi.SaveResult result : results){
            if (!result.Success){
                String exceptionMsg = 'Expiring Credit: ';
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                            
                throw new CustomException('Error: ' + exceptionMsg);   
            } 
        }
    }    
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionrequest(String zAccountId, String zProductRatePlanId,
                                                                           String zProductRatePlanChargeId, Decimal Price, String description) 
    {
        
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');     
        
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
        
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', zAccountId);
        
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = true;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false; 
        
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', effectiveDate);
        subscription.setValue('ServiceActivationDate', effectiveDate);
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('InitialTerm', '1');
        subscription.setValue('RenewalTerm', '1');
        subscription.setValue('AutoRenew', false);
        subscription.setValue('Notes', description);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
        ratePlanCharge.setValue('Price', Price);
        //ratePlanCharge.setValue('Description', description);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
        
        ratePlanDataList.add(ratePlanData);                  
        request.SubscriptionData.RatePlanData = ratePlanDataList;            
        
        return request;                 
    }
    
    public class CustomException extends Exception {} 
}