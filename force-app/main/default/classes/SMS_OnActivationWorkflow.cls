public Class SMS_OnActivationWorkflow {
    
    private Static String zChildAccountId;
    private Static String sSubscriptionId;
    private Static String termDuration;
    private Static String zServiceActivationDate;
    
    private Static List<String> zCoreInTermSubscriptions;
    private Static List<String> zPremiumInTermSubscriptions;
    private Static Map<String,String> zSubscriptionTermEndDate;
    
    private Static Map<String,Set<String>> zSubRatePlanNames;  
    private Static Map<String,Set<String>> zSubRatePlanIds;
    
    private Static List<Zuora.zApi.SubscribeRequest> requestList;
    private Static List<Zuora.zApi.AmendRequest> amendRequestList;
    private Static SMS_ZuoraUtil zUtilInstance;
    
    public static String statusReason;
    
    
    public Static void createSubscription(String subscriptionId,Boolean isPremiumReinstatement) 
    {
        if(system.isBatch() || system.isFuture()){
            createSubscriptionapex(subscriptionId, isPremiumReinstatement);
        }else{
            createSubscriptionFuture(subscriptionId, isPremiumReinstatement);
        }
    }
    
    @future(callout = true)
    public Static void createSubscriptionFuture(String subscriptionId,Boolean isPremiumReinstatement) {
        createSubscriptionapex(subscriptionId, isPremiumReinstatement);
    }
    
    public Static void createSubscriptionApex(String subscriptionId,Boolean isPremiumReinstatement) {
        try {
            
            sSubscriptionId = subscriptionId;
            system.debug('$$$ sSubscriptionId :' + sSubscriptionId);           
            
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();            
            
            requestList = new List<Zuora.zApi.SubscribeRequest>();
            amendRequestList = new List<Zuora.zApi.AmendRequest>();  
            
            zChildAccountId = null;
            Boolean isContactPrimary = false;
            
            zCoreInTermSubscriptions = new List<String>();
            zPremiumInTermSubscriptions = new List<String>();
            zSubscriptionTermEndDate = new Map<String,String>();
            
            zSubRatePlanNames = new Map<String,Set<String>>();
            zSubRatePlanIds = new Map<String,Set<String>>();
            
            List<Zuora__CustomerAccount__c> sBillingAccounts = [
                SELECT id, Name, Zuora__Zuora_Id__c, Zuora__Parent__r.Zuora__Zuora_Id__c
                FROM   Zuora__CustomerAccount__c
                WHERE  SubscriptionID__c = :sSubscriptionId];
            
            if (sBillingAccounts.Size() > 0)
                zChildAccountId = sBillingAccounts[0].Zuora__Zuora_Id__c;          
            
            if (String.isBlank(zChildAccountId)) {
                String zAccountsQuery = 'SELECT Id, ParentId FROM Account WHERE SubscriptionID__c = \'' + sSubscriptionId + '\'';                       
                System.Debug('$$$ zAccountsQuery : ' + zAccountsQuery );
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
                if (zAccounts.Size() == 1)
                    zChildAccountId = (String)zAccounts[0].getValue('Id');
            }
            
            System.Debug('$$$ zChildAccountId : ' + zChildAccountId);
            
            if (String.isNotBlank(zChildAccountId)) {
                populateInTermSubscriptions();
                
                if(isPremiumReinstatement){
                    if(zPremiumInTermSubscriptions.Size() > 0)
                        reinstatePremiumProducts();
                }
                else {
                    
                    /* Find to be zuora product and product rate plan id for recurring and one time */
                    List<Subscriptions__c> subscriptionDetails = [
                        SELECT Contact_Type__c, Subscription_Type__c, Date_Terminated__c,Zuora_Service_Activation_Date__c, Primary__c, Contact__c, Billing_Jurisdiction__c
                        FROM   Subscriptions__c
                        WHERE  Name = :sSubscriptionId];
                    
                    System.Debug('$$$ Subscription details : ' + subscriptionDetails);                    
                    
                    Reinstatement_Waiver_Range__c waiver = Reinstatement_Waiver_Range__c.getValues('Reinstatement waiver');
                    
                    System.debug(waiver);
                    
                    Date waiver1 = waiver.Cut_off_Start_Date__c;
                    Date waiver2 = waiver.Cut_off_End_Date__c;
                    
                    System.debug(waiver1);
                    System.debug(waiver2);
                    //Determine Core Mapping Status
                    String status = 'New';
                    if (subscriptionDetails[0].Date_Terminated__c != null) {
                        if((subscriptionDetails[0].Subscription_Type__c == 'Realtor/Shareholder'  || subscriptionDetails[0].Subscription_Type__c == 'Licensee/Non Realtor' || subscriptionDetails[0].Subscription_Type__c == 'Realtor/Non Shareholder') &&
                           subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) > 30 && 
                           subscriptionDetails[0].Date_Terminated__c > waiver1 && subscriptionDetails[0].Date_Terminated__c < waiver2)
                            status = 'Reinstatement <= 30'; 
                        else if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) > 30)
                            status = 'Reinstatement > 30';
                        else if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today()))>= 0 && subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) <= 30)
                            status = 'Reinstatement <= 30';
                    }                    
                    
                    //Determine whether to lookup a primary rate plan from Core Mapping
                    Boolean isPrimary = status == 'New'
                        ? SMS_BadWorkflowMitigation.isPrimarySubscription(subscriptionDetails[0].Contact__c)
                        : SMS_BadWorkflowMitigation_Temp.isPrimarySubscriptionReinstatement(subscriptionDetails[0].Contact__c, sSubscriptionId);
                    
                    if(String.isBlank(subscriptionDetails[0].Billing_Jurisdiction__c))
                        subscriptionDetails[0].Billing_Jurisdiction__c = 'MRIS';
                    
                    if(subscriptionDetails[0].Zuora_Service_Activation_Date__c != null){                        
                        zServiceActivationDate = subscriptionDetails[0].Zuora_Service_Activation_Date__c.format('yyyy-MM-dd');
                        status = 'Reinstatement <= 30';
                    }
                    
                    List<SMS_CoreMapping__c> productRatePlans = [
                        SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c
                        FROM   SMS_CoreMapping__c
                        WHERE  Type__c = :subscriptionDetails[0].Contact_Type__c
                        AND    SubType__c = :subscriptionDetails[0].Subscription_Type__c
                        AND    Status__c = :status
                        AND    IsPrimaryFlag__c = :isPrimary
                        AND    Billing_Jurisdiction__c = :subscriptionDetails[0].Billing_Jurisdiction__c
                    ];
                    system.debug('*** Status:' + status + isPrimary);
                    System.Debug('$$$ productRatePlans : ' + productRatePlans);
                    Map<String,BillingAndPayment_Settings__c> billingandPaymntSett = New Map<String,BillingAndPayment_Settings__c>();
                    
                    
                    /*
for(BillingAndPayment_Settings__c custSettVar : [Select Bypass_Billing__c, Billing_Jurisdiction__c,Bypass_Initial_Fee__c,Bypass_Reinstatement__c From BillingAndPayment_Settings__c]){
billingandPaymntSett.put(custSettVar.Billing_Jurisdiction__c,custSettVar );
}
if(billingandPaymntSett.ContainsKey(subscriptionDetails[0].Billing_Jurisdiction__c) && billingandPaymntSett.get(subscriptionDetails[0].Billing_Jurisdiction__c).Bypass_Billing__c == True)
throw new CustomException('Billing has been by passed');
*/
                    
                    
                    BillingAndPayment_Settings__c billAndPaymentSettings;
                    if(subscriptionDetails[0].Billing_Jurisdiction__c != null)
                        billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(subscriptionDetails[0].Billing_Jurisdiction__c);
                    
                    if(billAndPaymentSettings != null && billAndPaymentSettings.Billing_Jurisdiction__c.contains(subscriptionDetails[0].Billing_Jurisdiction__c) && billAndPaymentSettings.Bypass_Billing__c == True){
                        system.debug('---by pass bill ---'+billAndPaymentSettings.Bypass_Billing__c);
                        throw new CustomException('Billing has been by passed');
                    }
                    
                    if(productRatePlans.Size() > 0 && String.isNotBlank(productRatePlans[0].ZuoraRecurringProductRatePlanId__c)) {
                        termDuration = String.valueOf(productRatePlans[0].Term_Duration__c);
                        
                        
                        if(status == 'New' && billAndPaymentSettings != null && billAndPaymentSettings.Billing_Jurisdiction__c.contains(subscriptionDetails[0].Billing_Jurisdiction__c) && billAndPaymentSettings.Bypass_Initial_Fee__c == True ){
                            productRatePlans[0].ZuoraOnetimeProductRatePlanId__c = Null;
                            system.debug('---new---'+productRatePlans[0].ZuoraOnetimeProductRatePlanId__c);
                        }
                        if(status.contains('Reinstatement') && billAndPaymentSettings != null && billAndPaymentSettings.Billing_Jurisdiction__c.contains(subscriptionDetails[0].Billing_Jurisdiction__c) && billAndPaymentSettings.Bypass_Reinstatement__c==True){
                            productRatePlans[0].ZuoraOnetimeProductRatePlanId__c = Null;
                            system.debug('---Reinstatement---'+productRatePlans[0].ZuoraOnetimeProductRatePlanId__c);
                        }
                        
                        
                        if (zCoreInTermSubscriptions.Size() == 0) {
                            List<String> zProductRatePlanIdList = new List<String>();
                            zProductRatePlanIdList.add(productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
                            
                            if(String.IsNotBlank(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c))
                                zProductRatePlanIdList.add(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c);
                            
                            Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(zChildAccountId, zProductRatePlanIdList, true, true, null);
                            requestList.add(subscriptionRequest);
                            List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(requestList);
                            SMS_ZuoraHistory.processZResults(results,'SMS_OnActivationWorkflow',sSubscriptionId);
                            requestList.clear();      
                        }
                        else if (zCoreInTermSubscriptions.Size() > 0) {
                            
                            List<String> matchingZCoreSubscription = new List<String>();
                            for (String zCoreSubscriptionId : zCoreInTermSubscriptions) {
                                if(zSubRatePlanIds.get(zCoreSubscriptionId).contains(productRatePlans[0].ZuoraRecurringProductRatePlanId__c))
                                    matchingZCoreSubscription.add(zCoreSubscriptionId);
                            }
                            System.debug('$$$ matchingZCoreSubscription: ' + matchingZCoreSubscription);
                            
                            if (matchingZCoreSubscription.Size() > 0) {
                                System.Debug('$$$ Matching Core :' + productRatePlans);
                                for (String zSubscriptionId : matchingZCoreSubscription) {
                                    if(String.IsNotBlank(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c)) {
                                        Zuora.zApi.AmendRequest amendRequest = getNewProductAmendmentRequest(zSubscriptionId, productRatePlans[0].ZuoraOnetimeProductRatePlanId__c);
                                        system.debug('$$$ New Product amendRequest :' + amendRequest );
                                        amendRequestList.add(amendRequest);
                                        
                                        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                        SMS_ZuoraHistory.processZResults(amendResults,'SMS_OnActivationWorkflow',sSubscriptionId);       
                                        system.debug('$$$ Amend Results :' + amendResults);
                                    }
                                    amendRequestList.clear();
                                    Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest(zSubscriptionId, true);
                                    system.debug('$$$ Auto Renew amendRequest :' + amendRequest );
                                    amendRequestList.add(amendRequest);
                                    Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                    SMS_ZuoraHistory.processZResults(amendResults,'SMS_OnActivationWorkflow',sSubscriptionId);       
                                    system.debug('$$$ Amend Results :' + amendResults);
                                    amendRequestList.clear();                               
                                }
                            }
                            else if (matchingZCoreSubscription.Size() == 0){
                                System.Debug('$$$ New core not matching :' + productRatePlans);
                                List<String> productRatePlansList = new List<String>();                                                
                                
                                if(zCoreInTermSubscriptions[0] != null) {
                                    String zSubTermEndDate = zSubscriptionTermEndDate.get(zCoreInTermSubscriptions[0]);
                                    zSubTermEndDate = zSubTermEndDate.Replace(' ', 'T');
                                    
                                    if (String.isNotBlank(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c)) {
                                        Zuora.zApi.AmendRequest amendRequest = getNewProductAmendmentRequest(zCoreInTermSubscriptions[0], productRatePlans[0].ZuoraOnetimeProductRatePlanId__c);
                                        system.debug('$$$ New Product amendRequest :' + amendRequest );
                                        amendRequestList.add(amendRequest);
                                        
                                        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                        SMS_ZuoraHistory.processZResults(amendResults,'SMS_OnActivationWorkflow',sSubscriptionId);       
                                        system.debug('$$$ Amend Results :' + amendResults);
                                        amendRequestList.clear();   
                                    }   
                                    
                                    productRatePlansList.add(productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
                                    Zuora.zApi.SubscribeRequest subscriptionRequest2 = getZuoraSubscriptionRequest(zChildAccountId,productRatePlansList, true, true, zSubTermEndDate);
                                    System.Debug('$$$ subscriptionRequest2  :' + subscriptionRequest2 );
                                    requestList.add(subscriptionRequest2);                                     
                                    List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(requestList);
                                    SMS_ZuoraHistory.processZResults(results,'SMS_OnActivationWorkflow',sSubscriptionId);
                                    requestList.clear();
                                    
                                    Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest(zCoreInTermSubscriptions[0], false);
                                    amendRequestList.add(amendRequest);
                                    
                                    Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                                    SMS_ZuoraHistory.processZResults(amendResults,'SMS_OnActivationWorkflow',sSubscriptionId);       
                                    system.debug('$$$ Amend Results :' + amendResults);
                                    amendRequestList.clear();                                  
                                }                                                          
                            }                   
                        }  
                        if (zPremiumInTermSubscriptions.Size() > 0) {
                            reinstatePremiumProducts();      
                        }                                                 
                    }
                    else
                        throw new CustomException('CORE Product Rate Plan mapping not available');                     
                }                                
            }
            else
                throw new CustomException('Child Account not present in Zuora');
            
            List<Subscriptions__c> subscriptionDetails = [
                SELECT Id, Zuora_Service_Activation_Date__c, Service_Jurisdiction__c 
                FROM   Subscriptions__c
                WHERE  Name = :sSubscriptionId ];          
            
            if(subscriptionDetails[0].Zuora_Service_Activation_Date__c != null && subscriptionDetails[0].Service_Jurisdiction__c != 'MRIS'){
                subscriptionDetails[0].Zuora_Service_Activation_Date__c = null;
                update subscriptionDetails[0];
            }
            SMS_ZuoraHistory.createSuccess('SMS_OnActivationWorkflow',sSubscriptionId);
        }
        catch(Exception e){
            SMS_ZuoraHistory.createError(e,'SMS_OnActivationWorkflow',sSubscriptionId);
        }       
    }
    
    private Static void populateInTermSubscriptions(){
        String zSubscriptionsQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status FROM Subscription WHERE AccountId = \'' + zChildAccountId + '\'';
        
        System.debug('$$$ zSubscriptionsQuery : ' + zSubscriptionsQuery);    
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionsQuery);
        System.debug('$$$ zSubscriptions : ' + zSubscriptions);        
        Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date();
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            if ((String)zSubscription.getValue('TermType') == 'TERMED' && ((String)zSubscription.getValue('Status') == 'Active')) {
                if (((Date)zSubscription.getValue('TermEndDate')) >= todayDate && ((Date)zSubscription.getValue('TermStartDate')) <= todayDate) {
                    if ((String)zSubscription.getValue('IsCore__c') == 'true')
                        zCoreInTermSubscriptions.add((String)zSubscription.getValue('Id'));
                    else if ((String)zSubscription.getValue('IsCore__c') == 'false')
                        zPremiumInTermSubscriptions.add((String)zSubscription.getValue('Id'));
                }                                        
            }                   
            
            zSubscriptionTermEndDate.put((String)zSubscription.getValue('Id'), String.valueOf(zSubscription.getValue('TermEndDate')));                
        }
        
        
        
        Integer i = 0;
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        for (String zSubscriptionId : zPremiumInTermSubscriptions) {
            if (i != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            i++;
        }
        for (String zCoreSubscription : zCoreInTermSubscriptions) {
            if (i != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zCoreSubscription + '\'';
            i++;
        }
        if(i != 0){
            List<Zuora.zObject> zRatePlanSubscriptions = zUtilInstance.zquery(ratePlansQuery);
            for(Zuora.zObject zRatePlanSubscription : zRatePlanSubscriptions) {
                system.debug('$$$ Rate Plan Name: ' + String.valueOf(zRatePlanSubscription.getValue('Name')));
                String zSubId = String.valueOf(zRatePlanSubscription.getValue('SubscriptionId'));
                
                if(!zSubRatePlanNames.containsKey(zSubId))
                    zSubRatePlanNames.put(zSubId,new Set<String>());                    
                zSubRatePlanNames.get(zSubId).add(String.valueOf(zRatePlanSubscription.getValue('Name')));
                
                if(!zSubRatePlanIds.containsKey(zSubId))
                    zSubRatePlanIds.put(zSubId,new Set<String>());
                zSubRatePlanIds.get(zSubId).add(String.valueOf(zRatePlanSubscription.getValue('ProductRatePlanId')));
                
            }
        }
        System.debug('$$$ zPremiumInTermSubscriptions:' + zPremiumInTermSubscriptions);
        System.debug('$$$ zSubRatePlanNames:' + zSubRatePlanNames);
        System.debug('$$$ zSubRatePlanIds:' + zSubRatePlanIds);
        
    }
    
    private Static void reinstatePremiumProducts(){
        List<Subscriptions__c> csubscriptions = [SELECT Id, Name, status__c, Suspend_to_Active__c, status_change_reason__c, Date_Terminated__c FROM Subscriptions__c where Name =: sSubscriptionId];
        
        /* Exclude zuora products needs to skip */
        set<String> excludedNames = new Set<String>();
        system.debug('$$$ excludedNames :' + excludedNames);
        system.debug(' csubscriptions[0].status__c = '+ csubscriptions[0].status__c);
        system.debug('csubscriptions[0].status_change_reason__c = '+csubscriptions[0].status_change_reason__c);
        for(SMS_Excluded_Zuora_Product_Rate_Plans__c ratePlanType : SMS_Excluded_Zuora_Product_Rate_Plans__c.getall().values()){ 
            if(ratePlanType.Name == 'Legacy Invoices'){
                excludedNames.add(ratePlanType.Name);
            }else if(!csubscriptions.isEmpty() && (!csubscriptions[0].Suspend_to_Active__c || (csubscriptions[0].Suspend_to_Active__c && csubscriptions[0].Date_Terminated__c > system.now().addDays(-30)))){
                excludedNames.add(ratePlanType.Name);
            }
            
        }
        system.debug('$$$ excludedNames :' + excludedNames);
        Set<String> premiumRatePlanIds = new Set<String>();   
        
        for (String zSubscriptionId : zPremiumInTermSubscriptions) {
            boolean flag = false;
            for(String zRPlan : zSubRatePlanNames.get(zSubscriptionId)){
                if(excludedNames.contains(zRPlan)){
                    flag = true;
                    break;
                }
            }
            if(flag)
                break;
            system.debug('$$$ flag :' + flag);
            Zuora.zApi.AmendRequest amendRequest = getAutoRenewAmendmentRequest(zSubscriptionId, true);
            amendRequestList.add(amendRequest);
            
            Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
            SMS_ZuoraHistory.processZResults(amendResults,'SMS_OnActivationWorkflow',sSubscriptionId);       
            system.debug('$$$ Amend Results :' + amendResults);
            amendRequestList.clear();
            
            premiumRatePlanIds.addAll(zSubRatePlanIds.get(zSubscriptionId));
            
        }
        
        List<SMS_Provisioned_Product__c> provisionedProducts = new List<SMS_Provisioned_Product__c>();
        provisionedProducts = [
            SELECT  Id,
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
            AND    Zuora_Product_Rate_Plan_Id__c in :premiumRatePlanIds
            AND    Provisioned_Status__c != 'Provisioned'
        ];
        
        system.debug('$$$ Test prove : ' + provisionedProducts);  
        if (provisionedProducts.Size() > 0) {
            List<SMS_Provisioned_Product__c> provProducts = new List<SMS_Provisioned_Product__c>();
            for(SMS_Provisioned_Product__c provisionedProduct : provisionedProducts) {
                provisionedProduct.Product_Status__c = 'Reinstate';
                provisionedProduct.Provisioned_Status__c = 'Pending Provisioned';
                provisionedProduct.Product_Status_Reason__c = 'Subscription Reinstated';
                provProducts.add(provisionedProduct);
            }
            
            PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProducts);
        }
    }
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, List<String> zProductRatePlanIds, Boolean autoRenew, Boolean isCore, String serviceActivationDate) {
        
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
        Boolean generateInvoice = true; 
        
        if(String.isNotBlank(zServiceActivationDate)){
            serviceActivationDate = zServiceActivationDate;  
            generateInvoice = false;           
        }
        
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
        system.debug('--->' +request);
        return request;                 
    }
    
    private Static Zuora.zApi.AmendRequest getNewProductAmendmentRequest(String zSubscriptionId,String zProductRatePlanId) {
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
        
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
        request.AmendOptions.generateInvoice = true;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
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