public class Communities_BORPayment {
    
    SMS_ZuoraUtil zApiInstance;
    Zuora.zApi.LoginResult zLoginResult;

    public List<String> subscriptionIds;
    public String borSubId;
    public Map<String,BORPayment> BORPayments;
    public Decimal totaBalance;
    
    public Communities_BORPayment(String BORsubscriptionId){
        try{
            zApiInstance = new SMS_ZuoraUtil(); 
            zLoginResult = zApiInstance.zlogin();
        }
        catch(Exception e){
            //Create a case with support
        }
        
    }
    
    public void makeBORPayment(String zAccountId, String paymentMethodId, Decimal amount){
        try{
            Zuora.zObject zPayment = new Zuora.zObject('Payment');
            
            zPayment.setValue('AccountId', zAccountId);
            zPayment.setValue('AppliedCreditBalanceAmount', amount);
            zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST'));
            zPayment.setValue('PaymentMethodId', paymentMethodId);
            zPayment.setValue('Status', 'Processed');
            zPayment.setValue('Type', 'Electronic');        
            zPayment.setValue('Comment', 'Broker of Record Payment for ' + Datetime.now().format('yyyy-MM-dd','PST'));
            List<Zuora.zObject> zPayments = new List<Zuora.zObject>();    
            zPayments.add(zPayment);
            System.debug('*** zPayments: ' + zPayments);
            List<Zuora.zApi.SaveResult> zSaveResultPayment = zApiInstance.zcreate(zPayments);
            
            for (Zuora.zApi.SaveResult result : zSaveResultPayment ) {
                    if(!result.Success) {
                        Zuora.zObject[] errors = result.errors;
                        for (Zuora.zObject error : errors) {
                            String errorCode = (String)error.getValue('Code');
                            String message = (String)error.getValue('Message');
                            throw new CustomException('Create BOR Payment:' + errorCode + '-' + message); 
                        }               
                    }
            }
            
            String zInvoiceId = createSubscription(zAccountId, amount); 
                                        
            createCreditBalanceAdjustment(zInvoiceId, amount, 'Decrease');
        }
        catch(Exception e){
        
        }
    }
    
    private String createSubscription(String zAccountId, Decimal amount){
        SMS_CreditsTranfer__c primary = SMS_CreditsTranfer__c.getInstance('Primary');
        SMS_CreditsTranfer__c secondary = SMS_CreditsTranfer__c.getInstance('Secondary'); 
        String zInvoiceId = null;
        
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        subscribeRequests.add(getZuoraSubscriptionRequest(zAccountId, primary.zProductRatePlanId__c, primary.zProductRatePlanChargeId__c, amount));
        List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
        
         for(Zuora.zApi.SubscribeResult result : results){
            if(result.Success){
                zInvoiceId = (String)result.InvoiceId;                            
            }
            else{
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');
                    throw new CustomException('Create Subscription for BOR:' + errorCode + '-' + message); 
                } 
            }                   
        }
        
        return zInvoiceId;
    }
    
    private void createCreditBalanceAdjustment(String zInvoiceId, Decimal amount, String type){
        List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
        Boolean isSuccess = false; 
        
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', type);
        adjustment.setValue('Amount', amount);
                
        creditBalanceAdjustments.add(adjustment);
        List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments);
        
        for(Zuora.zApi.SaveResult result : zSaveResultList){
            if(!result.Success){
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');
                    throw new CustomException('Apply Credit Balance to BOR Invoice:' + errorCode + '-' + message); 
                } 
            }            
        }        
    }
    
    private Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId, 
                                                                          String zProductRatePlanChargeId, Decimal amount) {
        
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
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
        ratePlanCharge.setValue('Price', amount);
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
    
    public class BORPayment{
        public String zAccountId { get; set; }
        public List<Zuora.zObject> zInvoices { get; set; }
        public String status { get; set; } 
        public String statusMessage { get; set; }
        
        public Decimal invoiceBalance { get; set; }
        public String sfSubscriptionId { get; set; }
        
    }
    
    public Class CustomException extends Exception {} 


}