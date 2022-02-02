global class SMS_TREND6to3Batch implements Database.Batchable<Zuora__CustomerAccount__c>,Database.AllowsCallouts, Database.Stateful {
    private Static SMS_ZuoraUtil zUtilInstance;
    private String query;
    private String zCoreInTermSubscription;
    private DateTime zSubscriptionTermEndDate;
    private Subscriptions__c sSubscription;
    
    global SMS_TREND6to3Batch(String query){
        this.query = query;
    }
    
    global List<Zuora__CustomerAccount__c> start(Database.BatchableContext BC)  {    
       System.debug('***Query is : '+ query);
       List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
       billingAccounts = Database.query(query);
       
       return billingAccounts;
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__CustomerAccount__c> scope){
         zUtilInstance = new SMS_ZuoraUtil();
         Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
         List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
         
         for(Zuora__CustomerAccount__c billingAccount : scope){
             billingAccount.Zuora__Notes__c = 'Processed';
             sSubscription = [
                        SELECT Contact_Type__c, Subscription_Type__c, Primary__c, Billing_Jurisdiction__c
                        FROM   Subscriptions__c
                        WHERE  Name = :billingAccount.SubscriptionID__c];
         
             zCoreInTermSubscription = null;
             zSubscriptionTermEndDate = null;
             getOldCoreSubscriptions(billingAccount.Zuora__Zuora_Id__c);
             Boolean isNewPresent = isNewCoreSubscriptionPresent(billingAccount.Zuora__Zuora_Id__c);
             
             if(String.isNotBlank(zCoreInTermSubscription)){
                 // set auto renew to false for 6 months subscriptions
                String autoRenewResult = setAutoRenewToFalse(zCoreInTermSubscription);
                billingAccount.Zuora__Notes__c += ', ' + autoRenewResult ;
                
                if(autoRenewResult.contains('Success') && !isNewPresent){
                    // create zuora subscription with new rate plan of 3 months                    
                    String subscribeResult = createNewZSubscription(billingAccount.Zuora__Zuora_Id__c, zSubscriptionTermEndDate);
                    billingAccount.Zuora__Notes__c += ',' + subscribeResult;
                }  
             }
             else{
                 billingAccount.Zuora__Notes__c += ', ' + 'No Old core within term found';
             }
             
             billingAccounts.add(billingAccount);             
         }
         
         update billingAccounts;                                 
    }
    
    private Boolean isNewCoreSubscriptionPresent(String zAccountId){
        String zSubscriptionsQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status';
        zSubscriptionsQuery += ' FROM Subscription WHERE AccountId = \'' + zAccountId + '\'';
        zSubscriptionsQuery += ' AND Status = \'Active\' AND IsCore__c = true AND InitialTerm = 3 AND AutoRenew = true';
        
        System.debug('*** zSubscriptionsQuery : ' + zSubscriptionsQuery);    
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery);
        System.debug('*** zSubscriptions : ' + zSubscriptions);        
        Boolean isNew = false;
        
        if(zSubscriptions.size() > 0)
            isNew = true;
         
        return isNew;
    }
    
    private void getOldCoreSubscriptions(String zAccountId){
        String zSubscriptionsQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status';
        zSubscriptionsQuery += ' FROM Subscription WHERE AccountId = \'' + zAccountId + '\'';
        zSubscriptionsQuery += ' AND Status = \'Active\' AND IsCore__c = true AND InitialTerm = 6 AND AutoRenew = true';
        
        System.debug('*** zSubscriptionsQuery : ' + zSubscriptionsQuery);    
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery);
        System.debug('*** zSubscriptions : ' + zSubscriptions);        
        Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date();
        
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            if (((Date)zSubscription.getValue('TermEndDate')) >= todayDate && ((Date)zSubscription.getValue('TermStartDate')) <= todayDate) {
                zCoreInTermSubscription = (String)zSubscription.getValue('Id');
                zSubscriptionTermEndDate = (Date)zSubscription.getValue('TermEndDate');                    
            } 
            else {
                //This is a future core subscription with old rate plan. Delete It
                List<Zuora.zApi.DeleteResult> zDeleteResult = new List<Zuora.zApi.DeleteResult>();                
                zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { (String)zSubscription.getValue('Id') }); 
            } 
                                                
        }            
        
    }
    
    private Static String setAutoRenewToFalse(String zSubscriptionId){
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Set Auto Renew to false');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        
        amendment.setValue('Type', 'TermsAndConditions');
        amendment.setValue('AutoRenew', 'false');
        
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
        
        Zuora.zApi.AmendResult zAmendResult = zUtilInstance.zamend(new List<Zuora.zApi.AmendRequest> {request});
        
        system.debug('***zAmendResult : ' + zAmendResult );
        String resultMessage = 'AutoRenew Success';
        if (!zAmendResult.Success) {        
            Zuora.zObject[] errors = zAmendResult.errors;
            for (Zuora.zObject error : errors){
                resultMessage = 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                                    
            }  
        } 
        
        return resultMessage;
    }
    
    private String createNewZSubscription(String zAccountId, DateTime effectiveStartDate){  
         String subscribeResult = 'Subscribe Success';
         String status = 'Reinstatement <= 30';
         system.debug('*** effectiveStartDate:' + effectiveStartDate);
         String effectiveDate = effectiveStartDate.addDays(1).format('yyyy-MM-dd'); 
         List<SMS_CoreMapping__c> productRatePlans = [
                        SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c
                        FROM   SMS_CoreMapping__c
                        WHERE  Type__c = :sSubscription.Contact_Type__c
                        AND    SubType__c = :sSubscription.Subscription_Type__c
                        AND    Status__c = :status
                        AND    IsPrimaryFlag__c = :sSubscription.Primary__c
                        AND    Billing_Jurisdiction__c = :sSubscription.Billing_Jurisdiction__c
                       ];
        
        if(productRatePlans.size() != 1){
            subscribeResult = 'No CORE Mapping found';
            return subscribeResult;
        }
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
        subscription.setValue('ContractEffectiveDate', effectiveDate);
        subscription.setValue('ServiceActivationDate', effectiveDate);
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('InitialTerm', productRatePlans[0].Term_Duration__c);
        subscription.setValue('RenewalTerm', productRatePlans[0].Term_Duration__c);
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', true);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanDataList.add(ratePlanData);
        
        request.SubscriptionData.RatePlanData = ratePlanDataList; 
        
        system.debug('*** request:' + request);          
        
        List<Zuora.zApi.SubscribeResult> results = new List<Zuora.zApi.SubscribeResult>();
        results = zUtilInstance.zsubscribe(new List<Zuora.zApi.SubscribeRequest>{request}); 
        
        for (Zuora.zApi.SubscribeResult result : results){
            if (!result.Success) {        
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors)
                    subscribeResult = 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                    
            }            
        }
        
        return subscribeResult;
    } 
    
    global void finish(Database.BatchableContext BC) {
         
    }
}