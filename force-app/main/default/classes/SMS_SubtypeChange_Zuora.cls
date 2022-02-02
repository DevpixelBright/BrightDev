public Class SMS_SubtypeChange_Zuora {
    
    @future(callout = true)
    public Static void createSubscription(String sSubscriptionId) {
        try {   
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();                 
             
            List<Zuora.zApi.AmendRequest> amendRequestList  = new List<Zuora.zApi.AmendRequest>();  
            
            String zChildAccountId = null;
            String zParentAccountId = null;             
            
            List<Zuora__CustomerAccount__c> sBillingAccounts = [
                                SELECT id, Name, Zuora__Zuora_Id__c, Zuora__Parent__r.Zuora__Zuora_Id__c 
                                FROM   Zuora__CustomerAccount__c
                                WHERE  SubscriptionID__c = :sSubscriptionId ];
            
            if (sBillingAccounts.Size() > 0) 
                zChildAccountId = sBillingAccounts[0].Zuora__Zuora_Id__c;
            
            if (String.isBlank(zChildAccountId)) {
                String zAccountsQuery = 'SELECT Id, ParentId FROM Account WHERE SubscriptionID__c = \'' + sSubscriptionId  + '\' AND Status = \'Active\'';                       
                
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
                if (zAccounts.Size() == 1) 
                    zChildAccountId = (String)zAccounts[0].getValue('Id');
            }
            
            if (String.isNotBlank(zChildAccountId)) {
                /* Find to be zuora product and product rate plan id for recurring and one time */
                List<Subscriptions__c> subscriptionDetails = [
                    SELECT Contact_Type__c, Subscription_Type__c, Date_Terminated__c,Primary__c, Contact__c, Billing_Jurisdiction__c 
                    FROM   Subscriptions__c
                    WHERE  Name = :sSubscriptionId ];
                      
                Subscriptions__c sub = subscriptionDetails[0];              
    
                String status = 'New';
                if (subscriptionDetails[0].Date_Terminated__c != null) {            
                    if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) > 30)
                        status = 'Reinstatement > 30';
                    else if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today()))>= 0 && subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) <= 30)
                        status = 'Reinstatement <= 30';
                }
                
                if(String.isBlank(subscriptionDetails[0].Billing_Jurisdiction__c))
                    subscriptionDetails[0].Billing_Jurisdiction__c = 'MRIS';
                
                List<SMS_CoreMapping__c> productRatePlans = [
                    SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c 
                    FROM   SMS_CoreMapping__c
                    WHERE  Type__c = :subscriptionDetails[0].Contact_Type__c 
                    AND    SubType__c = :subscriptionDetails[0].Subscription_Type__c 
                    AND    Status__c = :status
                    AND    IsPrimaryFlag__c = :subscriptionDetails[0].Primary__c
                    AND    Billing_Jurisdiction__c = :subscriptionDetails[0].Billing_Jurisdiction__c];
                    
                if(productRatePlans.size() == 0)
                    throw new CustomException('CORE Mapping not found');               
                    
                String zSubscriptionsQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status FROM Subscription WHERE AccountId = \'' + zChildAccountId + '\' AND Status = \'Active\'';
                
                System.debug('*** zSubscriptionsQuery : ' + zSubscriptionsQuery);    
                List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery); 
                System.debug('*** zSubscriptions : ' + zSubscriptions);
                
                String zSubscriptionTermEndDate;
                String zSubscriptionTermStartDate;
                String zCoreInTermSubscriptionId;
                String zCoreFutureSubscriptionId; 
                
                Date todayDate = (date.valueOf(DateTime.now().format('yyyy-MM-dd', 'PST')));
                ZuoraActivationDate__c setting = ZuoraActivationDate__c.getValues('Default');                 
                
                if(setting.ActivationDate__c != null){
                    String activationDate = datetime.newInstance(setting.ActivationDate__c.year(), setting.ActivationDate__c.month(),setting.ActivationDate__c.day()).format('yyyy-MM-dd','PST'); 
                    List<Zuora.zApi.SubscribeRequest> requestList  = new List<Zuora.zApi.SubscribeRequest>();
                    Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(zChildAccountId,  new List<String> { productRatePlans[0].ZuoraRecurringProductRatePlanId__c}, true, true, activationDate, String.valueOf(productRatePlans[0].Term_Duration__c), false); 
                    requestList.add(subscriptionRequest);
                    system.debug('*** subscriptionRequest : ' + subscriptionRequest);
                    List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(requestList);       
                    system.debug('*** Subscription Results :' + results); 
                    SMS_ZuoraHistory.processZResults(results, 'SMS_SubtypeChange_Zuora', sSubscriptionId );    
                }
                else
                {for (Zuora.zObject zSubscription : zSubscriptions) {
                    if ((String)zSubscription.getValue('TermType') == 'TERMED' && ((String)zSubscription.getValue('Status') == 'Active')) {
                        if ((String)zSubscription.getValue('IsCore__c') == 'true') {
                            if (((Date)zSubscription.getValue('TermEndDate')) >= todayDate && ((Date)zSubscription.getValue('TermStartDate')) <= todayDate) {
                                zCoreInTermSubscriptionId = (String)zSubscription.getValue('Id'); 
                                zSubscriptionTermEndDate = String.valueOf(zSubscription.getValue('TermEndDate'));
                                zSubscriptionTermEndDate = zSubscriptionTermEndDate.Replace(' ', 'T');                
                            }
                            else if (((Date)zSubscription.getValue('TermStartDate')) > todayDate) {
                                zCoreFutureSubscriptionId = (String)zSubscription.getValue('Id');
                            }  
                        }                                                                
                    }                       
                }
                                
                System.Debug('*** zCoreInTermSubscriptions : ' + zCoreInTermSubscriptionId);
                System.Debug('*** zSubscriptionTermEndDate: ' + zSubscriptionTermEndDate); 
                System.Debug('*** zCoreFutureSubscriptionId : ' + zCoreFutureSubscriptionId );
                
                Boolean isRatePlanExists = false;
                
                //amend existing subscription, if it exists
                if (String.isBlank(zCoreInTermSubscriptionId) == false) {
                    if (productRatePlans.Size() > 0) {    
                        String zSubRatePlansQuery = 'SELECT Id,Name,ProductRatePlanId,SubscriptionId FROM RatePlan WHERE SubscriptionId = \'' + zCoreInTermSubscriptionId + '\'';
                        List<Zuora.zObject> zSubRatePlans = zUtilInstance.zquery(zSubRatePlansQuery);
                        if (zSubRatePlans.Size() > 0) {
                            for (Zuora.zObject zSubRatePlan : zSubRatePlans) {
                                if ((String)zSubRatePlan.getValue('ProductRatePlanId') == productRatePlans[0].ZuoraRecurringProductRatePlanId__c)
                                    isRatePlanExists = true;
                            }
                        }
                    }
                    
                    Zuora.zApi.AmendRequest autoRenewRequest;
                    if (isRatePlanExists == null || !isRatePlanExists || !(productRatePlans.Size() > 0)) {
                        System.Debug('*** condition1');
                        autoRenewRequest = getAutoRenewAmendmentRequest(zCoreInTermSubscriptionId, false);
                    }
                    else {
                        System.Debug('*** condition2');
                        autoRenewRequest = getAutoRenewAmendmentRequest(zCoreInTermSubscriptionId, true);
                    }
                        
                    system.debug('*** Auto Renew amendRequest :' + autoRenewRequest);
                    amendRequestList.add(autoRenewRequest); 
                    Zuora.zApi.AmendResult autoRenewResults = zUtilInstance.zamend(amendRequestList);       
                    system.debug('*** autoRenewResults :' + autoRenewResults);
                    SMS_ZuoraHistory.processZResults(autoRenewResults, 'SMS_SubtypeChange_Zuora', sSubscriptionId );
                    amendRequestList.clear(); 
                }
                
                //Delete the future subscription 
                if(String.isNotBlank(zCoreFutureSubscriptionId )) {
                    List<Zuora.zApi.DeleteResult> zDeleteResult = zUtilInstance.zdelete('Subscription', new List<String> { zCoreFutureSubscriptionId });
                    system.debug('*** zDeleteResult :' + zDeleteResult);  
                }              
                
                if (!isRatePlanExists && productRatePlans.Size() > 0) {
                    //create a new subscription 
                    List<Zuora.zApi.SubscribeRequest> requestList  = new List<Zuora.zApi.SubscribeRequest>();
                    Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(zChildAccountId,  new List<String> { productRatePlans[0].ZuoraRecurringProductRatePlanId__c}, true, true, zSubscriptionTermEndDate, String.valueOf(productRatePlans[0].Term_Duration__c), true); 
                    requestList.add(subscriptionRequest);
                    system.debug('*** subscriptionRequest : ' + subscriptionRequest);
                    List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(requestList);       
                    system.debug('*** Subscription Results :' + results); 
                    SMS_ZuoraHistory.processZResults(results, 'SMS_SubtypeChange_Zuora', sSubscriptionId );
                }
                }                                                
            }
            SMS_ZuoraHistory.createSuccess('SMS_SubtypeChange_Zuora',sSubscriptionId);
        }
        catch(Exception e) {
            system.debug('==================== EXCEPTION ==='+e);
            SMS_ZuoraHistory.createError(e,'SMS_SubtypeChange_Zuora',sSubscriptionId); 
        }                        
    }   
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, List<String> zProductRatePlanIds, Boolean autoRenew, Boolean isCore, String serviceActivationDate, String termDuration, Boolean generateInvoice) {
                   
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');  
        
        if (String.isBlank(serviceActivationDate))
            serviceActivationDate = effectiveDate;      
           
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
         
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', zAccountId);
         
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = generateInvoice;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false; 
                
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', serviceActivationDate);
        subscription.setValue('ServiceActivationDate', serviceActivationDate);
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('InitialTerm', termDuration);
        subscription.setValue('RenewalTerm', termDuration);
        subscription.setValue('AutoRenew', autoRenew);
        subscription.setValue('IsCore__c', isCore);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        for (String zProductRatePlanId : zProductRatePlanIds) {
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
                        
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            ratePlanData.setValue('RatePlan', ratePlan);
            ratePlanDataList.add(ratePlanData);
        }
                  
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
        
        return request;                 
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
    
    public Class CustomException extends Exception {}            
}