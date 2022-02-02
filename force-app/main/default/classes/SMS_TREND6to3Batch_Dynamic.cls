global class SMS_TREND6to3Batch_Dynamic implements Database.Batchable<Subscriptions__c>,Database.AllowsCallouts, Database.Stateful {
    private Static SMS_ZuoraUtil zUtilInstance;
    private String query;
    private String zCoreInTermSubscription;
    private DateTime zSubscriptionTermEndDate;
    private Subscriptions__c sSubscription;
    private string oldRatePlan;
    private string newRatePlan;
    private integer oldRatePlanTerm;
    private integer newRatePlanTerm;
    
    global SMS_TREND6to3Batch_Dynamic(String query, string oldRatePlan, string newRatePlan, integer oldRatePlanTerm, integer newRatePlanTerm){
        this.query = query;
    }
    
    global List<Subscriptions__c> start(Database.BatchableContext BC)  {    
       System.debug('***Query is : '+ query);
       List<Subscriptions__c> billingAccounts = new List<Subscriptions__c>();
       billingAccounts = Database.query(query);
       
       return billingAccounts;
    }
    
    global void execute(Database.BatchableContext BC, List<Subscriptions__c> scope){
         zUtilInstance = new SMS_ZuoraUtil();
         Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
         List<Subscriptions__c> billingAccounts = new List<Subscriptions__c>();
         
         for(Subscriptions__c billingAccount : scope){
             
             string zAccountId = zuoraAccountId(billingAccount.Name);
             //billingAccount.Zuora__Notes__c = 'Processed';
             /*sSubscription = [
                        SELECT Contact_Type__c, Subscription_Type__c, Primary__c, Billing_Jurisdiction__c
                        FROM   Subscriptions__c
                        WHERE  Name = :billingAccount.SubscriptionID__c];
         		*/
             
             zCoreInTermSubscription = null;
             zSubscriptionTermEndDate = null;
             getOldCoreSubscriptions(zAccountId);
             Boolean isNewPresent = isNewCoreSubscriptionPresent(zAccountId);
             
             if(String.isNotBlank(zCoreInTermSubscription)){
                 // set auto renew to false for 6 months subscriptions
                String autoRenewResult = setAutoRenewToFalse(zCoreInTermSubscription);
                //billingAccount.Zuora__Notes__c += ', ' + autoRenewResult ;
                
                if(autoRenewResult.contains('Success') && !isNewPresent){
                    // create zuora subscription with new rate plan of 3 months                    
                    String subscribeResult = createNewZSubscription(zAccountId, zSubscriptionTermEndDate);
                    //billingAccount.Zuora__Notes__c += ',' + subscribeResult;
                }  
             }
             else{
                 //billingAccount.Zuora__Notes__c += ', ' + 'No Old core within term found';
             }
             
             //billingAccounts.add(billingAccount);             
         }
         
         //update billingAccounts;                                 
    }
    private string zuoraAccountId(string subName){
        string query = 'SELECT Id, Status, AccountNumber FROM Account WHERE AccountNumber = \''+subName+'\'';
        List<Zuora.zObject> zAccount = zUtilInstance.zquery(query);
        System.debug('*** zAccount : ' + zAccount);
        if(zAccount != null){
            string zAccountId = (String)zAccount[0].getValue('Id');
            return zAccountId;
        }
        else
            return null;
    }
    private Boolean isNewCoreSubscriptionPresent(String zAccountId){
        String zSubscriptionsQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status';
        zSubscriptionsQuery += ' FROM Subscription WHERE AccountId = \'' + zAccountId + '\'';
        zSubscriptionsQuery += ' AND Status = \'Active\' AND IsCore__c = true AND InitialTerm = '+newRatePlanTerm+' AND AutoRenew = true';
        
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
        zSubscriptionsQuery += ' AND Status = \'Active\' AND InitialTerm = '+oldRatePlanTerm+' AND AutoRenew = true';
        
        System.debug('*** zSubscriptionsQuery : ' + zSubscriptionsQuery);    
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery);
        System.debug('*** zSubscriptions : ' + zSubscriptions);        
        Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date();
        
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            if (((Date)zSubscription.getValue('TermEndDate')) >= todayDate && ((Date)zSubscription.getValue('TermStartDate')) <= todayDate) {
                zCoreInTermSubscription = (String)zSubscription.getValue('Id');
                zSubscriptionTermEndDate = (Date)zSubscription.getValue('TermEndDate');                    
            } /*
            else {
                //This is a future core subscription with old rate plan. Delete It
                List<Zuora.zApi.DeleteResult> zDeleteResult = new List<Zuora.zApi.DeleteResult>();                
                zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { (String)zSubscription.getValue('Id') }); 
            } 
            */                                
        }
        
        Zuora.zObject sub = findZSubscription(zAccountId, oldRatePlan);
        
    }
    
    
    private Static Zuora.zObject findZSubscription(String zAccountId, String zProductRatePlanId){
        String currentDate = DateTime.now().format('yyyy-MM-dd','PST');
        String zSubId = null;
        String subQuery = 'SELECT Id, Name, Status, TermStartDate, TermEndDate FROM Subscription WHERE AccountId = \'' + zAccountId + '\' AND IsCore__c = false AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        if (zSubscriptions.Size() == 0) 
            return null;
        
        map<string, Zuora.zObject> mapStringSub = new map<string, Zuora.zObject>();
        Integer i = 0;
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        for (Zuora.zObject zSubscription : zSubscriptions) {
            String zSubscriptionId = (String)zSubscription.getValue('Id');

            if (i != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            i++;
            
            mapStringSub.put((String)zSubscription.getValue('Id'), zSubscription);
        }
        
        system.debug('***Rate plan qury is '+ratePlansQuery);
        if(i != 0){
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);            
            system.debug('***zRatePlans ' + zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {                
                if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == zProductRatePlanId){
                    zSubId = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                    break;
                }                    
             }                     
         }
         
        //return zSubId;
        return mapStringSub.get(zSubId);
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
        /* 
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
        }*/
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
        //subscription.setValue('InitialTerm', productRatePlans[0].Term_Duration__c);
        //subscription.setValue('RenewalTerm', productRatePlans[0].Term_Duration__c);
        subscription.setValue('InitialTerm', newRatePlanTerm);
        subscription.setValue('RenewalTerm', newRatePlanTerm);
        
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', true);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        //ratePlan.setValue('ProductRatePlanId', productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
        ratePlan.setValue('ProductRatePlanId', newRatePlan);
        
        
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