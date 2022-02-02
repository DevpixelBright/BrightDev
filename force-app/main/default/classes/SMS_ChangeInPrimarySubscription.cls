public Class SMS_ChangeInPrimarySubscription {
    
    @future(callout = true)
    public Static void changePrimarySubscription(String newSubscriptionId, String oldSubscriptionId) {
        try {
            system.debug('*** changePrimarySubscription');
            System.Debug('*** data - ' + newSubscriptionId + oldSubscriptionId);
            if (String.isBlank(newSubscriptionId) || String.isBlank(oldSubscriptionId))
                 throw new CustomException('Subscription ids can not be null');
                 
            List<Zuora.zApi.SubscribeRequest> subRequestList  = new List<Zuora.zApi.SubscribeRequest>();
            List<Zuora.zApi.AmendRequest> amendRequestList  = new List<Zuora.zApi.AmendRequest>();
            List<String> deleteSubids = new List<String>();
            
            Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date();
      
            List<String> subList = new List<String>{newSubscriptionId, oldSubscriptionId};
                 
            List<Subscriptions__c> subscriptionDetails = [ 
                    SELECT Contact_Type__c, Subscription_Type__c, Date_Terminated__c,Primary__c, Contact__c, Name, Status__c, Billing_Jurisdiction__c  
                    FROM   Subscriptions__c
                    WHERE  Name = :subList];
                    
            System.Debug('*** subscriptionDetails :' + subscriptionDetails);
                 
            if (!(subscriptionDetails.Size() == 2))
                throw new CustomException('Invalid subscriptions data');
               
            SMS_CoreMapping__c newSubMap = new SMS_CoreMapping__c();
            SMS_CoreMapping__c oldSubMap = new SMS_CoreMapping__c();
            String status = 'New';
            for (Subscriptions__c subscription : subscriptionDetails) {
                if (subscription.Name == newSubscriptionId) {
                    if(String.isBlank(subscription.Billing_Jurisdiction__c))
                        subscription.Billing_Jurisdiction__c = 'MRIS';
                    newSubMap  = [
                        SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c 
                        FROM   SMS_CoreMapping__c
                        WHERE  Type__c = :subscription.Contact_Type__c 
                        AND    SubType__c = :subscription.Subscription_Type__c 
                        AND    Status__c = :status
                        AND    IsPrimaryFlag__c = true
                        AND    Billing_Jurisdiction__c = :subscription.Billing_Jurisdiction__c];
                } 
                if (subscription.Name == oldSubscriptionId && subscription.Status__c == 'Active') {
                    if(String.isBlank(subscription.Billing_Jurisdiction__c))
                        subscription.Billing_Jurisdiction__c = 'MRIS';
                    oldSubMap = [
                        SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c 
                        FROM   SMS_CoreMapping__c
                        WHERE  Type__c = :subscription.Contact_Type__c 
                        AND    SubType__c = :subscription.Subscription_Type__c 
                        AND    Status__c = :status
                        AND    IsPrimaryFlag__c = false
                        AND    Billing_Jurisdiction__c = :subscription.Billing_Jurisdiction__c];
                }              
            }      
            
            System.Debug('*** newSubMap :' + newSubMap);
            System.Debug('*** oldSubMap :' + oldSubMap);
            
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();                  
            
            String zAccountsQuery = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + newSubscriptionId + '\' OR SubscriptionID__c = \'' + oldSubscriptionId + '\' ';
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery); 
            
            if (zAccounts.Size() != 2)
                throw new CustomException('Invalid zuora accounts');
            
            Map<String, String> zAccountsMap = new Map<String, String>();
            Integer i = 0;
            String zSubscriptionsQuery = 'SELECT Id, Name, AccountId, InitialTerm, RenewalTerm, IsCore__c, TermType, Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate FROM Subscription WHERE ';
            for (Zuora.zObject zAccount : zAccounts) {
                if (i != 0)
                    zSubscriptionsQuery += ' OR ';        
                
                zSubscriptionsQuery += 'AccountId = \'' + (String)zAccount.getValue('Id') + '\'';
                i++;
                
                zAccountsMap.put((String)zAccount.getValue('Id'), (String)zAccount.getValue('SubscriptionID__c'));
            } 
            List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery);
            
            if (!(zSubscriptions.Size() > 0))
                throw new CustomException('Zuora subscriptions does not exists.');
            
            Map<String, String> zSubscriptionsMap = new Map<String, String>();   
            i = 0;
            String zSubRatePlansQuery = 'SELECT Id,Name,ProductRatePlanId,SubscriptionId FROM RatePlan WHERE ';
            for (Zuora.zObject zSubscription : zSubscriptions) {
                       
                
                if ((String)zSubscription.getValue('Status') == 'Active' && (String)zSubscription.getValue('IsCore__c') == 'true') {
                    if (i != 0)
                        zSubRatePlansQuery += ' OR '; 
                    zSubRatePlansQuery += 'SubscriptionId = \'' + (String)zSubscription.getValue('Id') + '\'';
                    i++; 
                }
                zSubscriptionsMap.put((String)zSubscription.getValue('Id'), (String)zSubscription.getValue('AccountId'));       
            } 
            
            system.debug('*** zSubRatePlansQuery : ' + zSubRatePlansQuery);
            List<Zuora.zObject> zSubRatePlans = zUtilInstance.zquery(zSubRatePlansQuery);
            
            if (!(zSubRatePlans.Size() > 0))
                throw new CustomException('Failed to get Zuora product rate plans');
                
            String oldPrimaryEndDate = null;
            for (Zuora.zObject zSubscription : zSubscriptions) {
                if (zAccountsMap.get((String)zSubscription.getValue('AccountId')) == oldSubscriptionId) {
                    oldPrimaryEndDate = String.valueOf(zSubscription.getValue('TermEndDate'));
                    oldPrimaryEndDate = oldPrimaryEndDate .Replace(' ', 'T'); 
                }          
            }
                
            for (Zuora.zObject zSubscription : zSubscriptions) {
                
                
                if ((String)zSubscription.getValue('TermType') == 'TERMED' && ((String)zSubscription.getValue('Status') == 'Active') && ((String)zSubscription.getValue('IsCore__c') == 'true')) {
                    if (((Date)zSubscription.getValue('TermEndDate')) >= todayDate && ((Date)zSubscription.getValue('TermStartDate')) <= todayDate) {            
                
                        String ratePlanId = null;
                        if (zAccountsMap.get((String)zSubscription.getValue('AccountId')) == newSubscriptionId)
                            ratePlanId = newSubMap.ZuoraRecurringProductRatePlanId__c;
                        if (zAccountsMap.get((String)zSubscription.getValue('AccountId')) == oldSubscriptionId)
                            ratePlanId = oldSubMap.ZuoraRecurringProductRatePlanId__c;
                            
                        Boolean isRatePlanExists = false;
                        for (Zuora.zObject zSubRatePlan : zSubRatePlans) {
                            if (((String)zSubRatePlan.getValue('SubscriptionId') == (String)zSubscription.getValue('Id')) && (String)zSubRatePlan.getValue('ProductRatePlanId') == ratePlanId) 
                                isRatePlanExists = true;  
                        }
                        if (String.isNotBlank(ratePlanId)) {
                            if(isRatePlanExists) {
                                Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest((String)zSubscription.getValue('Id'), true);
                                amendRequestList.add(amendRequest);           
                                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                SMS_ZuoraHistory.processZResults(amendResults,'SMS_ChangeInPrimarySubscription',newSubscriptionId);
                                amendRequestList.clear();                              
                            }
                            else {
                                String zSubTermEndDate = null;
                                if (zAccountsMap.get((String)zSubscription.getValue('AccountId')) == newSubscriptionId && oldPrimaryEndDate != null)
                                    zSubTermEndDate = oldPrimaryEndDate;
                                else {                           
                                    zSubTermEndDate = String.valueOf(zSubscription.getValue('TermEndDate'));
                                    zSubTermEndDate = zSubTermEndDate.Replace(' ', 'T');
                                }                        
                                Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest((String)zSubscription.getValue('AccountId'), ratePlanId, zSubTermEndDate, String.valueOf(zSubscription.getValue('RenewalTerm')));
                                subRequestList.add(subscriptionRequest);
                                
                                Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest((String)zSubscription.getValue('Id'), false);
                                amendRequestList.add(amendRequest);
                                
                                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                SMS_ZuoraHistory.processZResults(amendResults,'SMS_ChangeInPrimarySubscription',newSubscriptionId);       
                                system.debug('*** Amend Results :' + amendResults); 
                                amendRequestList.clear();                                                       
                            }
                        }                                
                
                    }
                    
                    if (((Date)zSubscription.getValue('TermStartDate')) >= todayDate) {
                        deleteSubids.add((String)zSubscription.getValue('Id'));
                    }                
                }            
            }
            
            System.Debug('*** subRequestList:' + subRequestList);
            if (subRequestList.Size() > 0) {
                List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
                SMS_ZuoraHistory.processZResults(results,'SMS_ChangeInPrimarySubscription',newSubscriptionId);       
                system.debug('*** Subscription Results :' + results);
            }
            
            if (deleteSubids.Size() > 0) {
                List<Zuora.zApi.DeleteResult> results = zUtilInstance.zdelete('Subscription',deleteSubids);
                SMS_ZuoraHistory.processZResults(results,'SMS_ChangeInPrimarySubscription',newSubscriptionId);     
            }
            SMS_ZuoraHistory.createSuccess('SMS_ChangeInPrimarySubscription',newSubscriptionId);
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_ChangeInPrimarySubscription',newSubscriptionId);
        }                   
    }
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId, String serviceActivationDate, String termDuration) {
                   
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');  
        
        if (String.isBlank(serviceActivationDate))
            serviceActivationDate = effectiveDate;      
           
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
        subscription.setValue('ContractEffectiveDate', serviceActivationDate);
        subscription.setValue('ServiceActivationDate', serviceActivationDate);
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('InitialTerm', termDuration);
        subscription.setValue('RenewalTerm', termDuration);
        //subscription.setValue('IsInvoiceSeparate','true');
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', true);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();

        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
                    
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanDataList.add(ratePlanData);

                  
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