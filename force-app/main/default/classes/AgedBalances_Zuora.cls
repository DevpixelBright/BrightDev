public class AgedBalances_Zuora {
    SMS_ZuoraUtil zUtilInstance;
    Zuora.zApi.LoginResult zLoginResult;
    
    String agedBalancesRatePlanId;
    String agedBalancesRatePlanChargeId; 
        
    Map<String, Exception> InvoiceException;
    Map<String, Decimal> InvoiceSuccess;
    
    public AgedBalances_Zuora(List<String> zAgedInvoiceNumbers){
        
        String agedBalancesProductName = Aged_Balances__c.getall().values()[0].Name;
        agedBalancesRatePlanId = Aged_Balances__c.getValues(agedBalancesProductName).Zuora_Product_Rate_Plan_Id__c;
        agedBalancesRatePlanChargeId = Aged_Balances__c.getValues(agedBalancesProductName).Zuora_Product_Rate_Plan_Charge_Id__c;
        
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin(); 
        
        InvoiceException = new Map<String, Exception>();
        InvoiceSuccess = new Map<String, Decimal>();  
        
        String zAgedInvoiceQuery = 'SELECT Id, InvoiceNumber, AccountId, Amount, Balance, PaymentAmount FROM Invoice WHERE ';
        List<Zuora.zObject> zAgedInvoices = new List<Zuora.zObject>();
        List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
        Zuora.zApi.SubscribeResult SubResult; 
        Integer i = 0;
        
        for(String zInvoiceNumber : zAgedInvoiceNumbers){
            if(i != 0)
                zAgedInvoiceQuery += ' OR '; 
            
            zAgedInvoiceQuery += 'InvoiceNumber = \'' + zInvoiceNumber + '\'';
            i++;
            
            if(i == 199){
                List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
                zObjects = zUtilInstance.zquery(zAgedInvoiceQuery);
                i = 0;
                zAgedInvoiceQuery = 'SELECT Id, InvoiceNumber, AccountId, Amount, Balance, PaymentAmount FROM Invoice WHERE ';
                zAgedInvoices.addAll(zObjects);
            }
            system.debug('*** zInvoiceNumber : ' + zInvoiceNumber );
        }
        system.debug('*** zAgedInvoices : ' + zAgedInvoices );
        
        if(i > 0){
            List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
            zObjects = zUtilInstance.zquery(zAgedInvoiceQuery);
            system.debug('*** zObjects : ' + zObjects );
            i = 0;
            zAgedInvoiceQuery = 'SELECT Id, InvoiceNumber, AccountId, Amount, Balance, PaymentAmount FROM Invoice WHERE ';
            zAgedInvoices.addAll(zObjects);
        }
        
        system.debug('*** zAgedInvoices : ' + zAgedInvoices );
        for(Zuora.zObject zInvoice : zAgedInvoices){
            String zAccountId = (String)zInvoice.getValue('AccountId');
            Decimal zAgedInvoiceBalance = (Decimal)zInvoice.getValue('Balance');
            String zAgedInvoiceId = (String)zInvoice.getValue('Id');
            String zInvoiceNumber = (String)zInvoice.getValue('InvoiceNumber');
            
            try{
                if(zAgedInvoiceBalance > 0){
                    SubResult = createAgedBalancesSubscription(zAccountId, -zAgedInvoiceBalance, 'Invoice write off for FY 2014,2015,2016');
                    system.debug('*** SubResult : ' + SubResult );
                    
                    addToCreditBalance(SubResult.InvoiceId);
                    
                    applyCreditBalance(zAgedInvoiceId, zAgedInvoiceBalance);                    
                }
                InvoiceSuccess.put(zInvoiceNumber, zAgedInvoiceBalance);
                
            }
            catch(Exception e){
                InvoiceException.put(zInvoiceNumber, e); 
            }
        }
        
        for(String invoiceNumber : InvoiceSuccess.keySet()){
            SMS_ZuoraHistory.createSuccess('AgedBalances_Zuora: ' + invoiceNumber + ', Amount: ' + InvoiceSuccess.get(invoiceNumber) , null);    
        }
        
        for(String invoiceNumber : InvoiceException.keySet()){
            SMS_ZuoraHistory.createError(InvoiceException.get(invoiceNumber), 'AgedBalances_Zuora: ' + invoiceNumber, null);    
        }
        
    }    
    
    public void addToCreditBalance(String zInvoiceId){
        String zNewInvoiceBalanceQuery = 'SELECT Id, InvoiceNumber, AccountId, Amount, Balance, PaymentAmount FROM Invoice WHERE ';
        zNewInvoiceBalanceQuery += 'Id = \'' + zInvoiceId + '\'';
        system.debug('zNewInvoiceBalanceQuery '+ zNewInvoiceBalanceQuery);
        
        List<Zuora.zObject> zNewInvoices = new List<Zuora.zObject>();
        zNewInvoices = zUtilInstance.zquery(zNewInvoiceBalanceQuery);
        system.debug('zNewInvoices '+zNewInvoices);
        for(Zuora.zObject zNewInvoice : zNewInvoices){
            Decimal zNewInvoiceBalance = (Decimal)zNewInvoice.getValue('Balance');
            system.debug('zNewInvoiceBalance '+ zNewInvoiceBalance);    
            
            Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
            adjustment.setValue('SourceTransactionId', zInvoiceId);
            adjustment.setValue('Type', 'Increase');
            adjustment.setValue('Amount', -zNewInvoiceBalance);
            
            List<Zuora.zApi.SaveResult> results = zUtilInstance.zcreate(new List<Zuora.zObject>{adjustment}); 
            for (Zuora.zApi.SaveResult result : results){
                if (!result.Success){
                    String exceptionMsg = 'Aged Balances: ';
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors)
                        exceptionMsg = exceptionMsg + 'addToCreditBalance Exception: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                            
                    throw new CustomException('Error: ' + exceptionMsg);   
                } 
            }            
        }       
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
                String exceptionMsg = 'Aged Balances: ';
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'applyCreditBalance Exception: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                            
                throw new CustomException('Error: ' + exceptionMsg);   
            } 
        }
    } 
    
    public Zuora.zApi.SubscribeResult createAgedBalancesSubscription(String zAccountId, Decimal creditAmount, String description){
        system.debug('zAccountId'+zAccountId);
        system.debug('creditAmount'+creditAmount);
        system.debug('description'+description);
        
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(zAccountId, agedBalancesRatePlanId, agedBalancesRatePlanChargeId, creditAmount, description);
        system.debug('agedBalancesRatePlanId'+agedBalancesRatePlanId);
        system.debug('agedBalancesRatePlanChargeId'+agedBalancesRatePlanChargeId);
        
        subscribeRequests.add(subscriptionRequest);
        system.debug('subscribeRequests'+subscribeRequests);
        String invoiceId;
        Zuora.zApi.SubscribeResult res; 
        system.debug('zUtilInstance'+zUtilInstance);
        List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subscribeRequests);
        
        for (Zuora.zApi.SubscribeResult result : results){
            if (!result.Success){
                String exceptionMsg = 'Aged Balances: ';
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                                            
                throw new CustomException('Error: ' + exceptionMsg);   
            } 
            else{
                res = result; 
            }
        }
        
        return res;
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
        subscription.setValue('IsInvoiceSeparate', true);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
        ratePlanCharge.setValue('Price', Price);
        ratePlanCharge.setValue('Description', description);
        
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