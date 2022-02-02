global class SMS_InactivateSubs implements Database.Batchable<String>,Database.AllowsCallouts,Database.Stateful{
    List<String> zSubscriptionIds;
    List<String> sSubscriptionIds;
    List<String> zPaymentMethodIds;
    List<SMS_Auto_Suspended_Account__c> pendingSuspendAccounts;
    
    Set<String> zAutoRenewSubscriptionIds;
    Set<String> zDeleteSubscriptionIds;
    
    Map<String,Zuora.zObject> zActiveAccounts;    
    Set<String> zAmendedSubcriptionIds;
    Map<String,Boolean> zAccountSuspended;
    Map<String,String> zSubscriptionAccount;
    
    SMS_ZuoraUtil zUtilInstance;
    Zuora.zApi.LoginResult zLoginResult;
    
    String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');  
   
    global SMS_InactivateSubs (List<String> sSubscriptionIds) {       
        system.debug('*** Batch Constructor sSubscriptionIds : ' + sSubscriptionIds); 
        
        this.sSubscriptionIds = new List<String>();
        
        this.sSubscriptionIds.addAll(sSubscriptionIds); 
        
        zActiveAccounts = new Map<String,Zuora.zObject>();
        zAutoRenewSubscriptionIds = new Set<String>();
        zDeleteSubscriptionIds = new Set<String>();         
        
        zAccountSuspended = new Map<String,Boolean>();
        zAmendedSubcriptionIds = new Set<String>();
        zSubscriptionAccount = new Map<String,String>();
         
        system.debug('*** Batch Constructor Method'); 
         
    }    
    
    global Iterable<String> start(Database.BatchableContext BC){
        try {
        system.debug('*** Batch Start Method'); 
   
        zUtilInstance = new SMS_ZuoraUtil();
        zLoginResult = zUtilInstance.zlogin();   
        
        system.debug('*** Batch Start sSubscriptionIds : ' + sSubscriptionIds); 
        
        setZuoraSubscriptionIds(sSubscriptionIds);
        system.debug('*** Batch Start zAutoRenewSubscriptionIds: ' + zAutoRenewSubscriptionIds);  
        system.debug('*** Batch Start zDeleteSubscriptionIds: ' + zDeleteSubscriptionIds); 
        
        system.debug('*** Batch provisioned products update ');
        pendingSuspendAccounts = new List<SMS_Auto_Suspended_Account__c>();
        pendingSuspendAccounts = [SELECT id,
                                         Status__c,
                                         MRIS_Subscription_ID__c,
                                         Zuora_Account_Id__c
                                  FROM   SMS_Auto_Suspended_Account__c 
                                  WHERE  MRIS_Subscription_ID__c in :sSubscriptionIds 
                                  AND    (Status__c = 'In Progress' OR Status__c = 'Success')
                                 ];
                                 
        system.debug('*** pendingSuspendAccounts :' + pendingSuspendAccounts);
        system.debug('*** pendingSuspendAccounts size :' + pendingSuspendAccounts.size());  
                                                                                           
        if(pendingSuspendAccounts.size() > 0)
            updateProductsProvisioned(sSubscriptionIds,'Subscription Auto-Suspended');
        else 
            updateProductsProvisioned(sSubscriptionIds,'Subscription Terminated');   
        
        zSubscriptionIds = new List<String>();
        
        zSubscriptionIds.addAll(zAutoRenewSubscriptionIds);
        system.debug('*** Batch Start zSubscriptionIds: ' + zSubscriptionIds); 
        zSubscriptionIds.addAll(zDeleteSubscriptionIds);
        system.debug('*** Batch Start zSubscriptionIds: ' + zSubscriptionIds); 
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_InactivateSubs',sSubscriptionIds[0]);
        }
        return new SMS_CallIterableString(zSubscriptionIds);
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope){      
        
        system.debug('*** Execute scope :' + scope);
        system.debug('*** Execute zAutoRenewSubscriptionIds :' + zAutoRenewSubscriptionIds);
        system.debug('*** Execute zDeleteSubscriptionIds :' + zDeleteSubscriptionIds);
        
        for(String zSubscriptionId : scope) {
            try {
                Zuora.zApi.AmendResult zAmendResult = new Zuora.zApi.AmendResult();                
                       
                if(zAutoRenewSubscriptionIds.size() > 0 && zAutoRenewSubscriptionIds.contains(zSubscriptionId)) {     
                    zAmendResult = zUtilInstance.zamend(getAutoRenewAmendmentRequest(zSubscriptionId)); //will be used while writing test classes
                    SMS_ZuoraHistory.processZResults(zAmendResult,'SMS_InactivateSubs', zSubscriptionId);
                    system.debug('*** zAmendResult :' + zAmendResult );
                    if (!zAmendResult.Success) throw new CustomException('Amendment Failed');
                    zAmendedSubcriptionIds.add(zSubscriptionId); 
                }
                else if(zDeleteSubscriptionIds.size() > 0 && zDeleteSubscriptionIds.contains(zSubscriptionId)) {
                    List<Zuora.zApi.DeleteResult> zDeleteResult = zUtilInstance.zdelete('Subscription',new List<String> { zSubscriptionId }); //will be used while writing test classes
                    SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_InactivateSubs', zSubscriptionId);
                    system.debug('*** zDeleteResult : ' + zDeleteResult);
                    if (!zDeleteResult[0].Success) throw new CustomException('Delete Failed');
                    zAmendedSubcriptionIds.add(zSubscriptionId);
                }
            }
            catch(Exception e) {
                zAccountSuspended.put(zSubscriptionAccount.get(zSubscriptionId),false);
                SMS_ZuoraHistory.createError(e,'SMS_InactivateSubs',sSubscriptionIds[0]);
            }                                       
        }        
        
        system.debug('*** Batch Execute Method');                                           
    }
    
    global void finish(Database.BatchableContext BC){
       
       try {
            Set<String> suspendedZAccountIds = new Set<String>();
            Set<String> notSuspendedZAccountIds = new Set<String>();
            List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
            
            setZPaymentMethodIds(zAccountSuspended.keyset());
            
            List<Zuora.zObject> check = zUtilInstance.zquery('SELECT Id FROM PaymentMethod WHERE Type = \'Check\''); //will be used while writing test classes
            
            for(String zAccountId : zAccountSuspended.keyset()) {
                Zuora.zObject zAccount = new Zuora.zObject('Account');
                zAccount.setValue('Id',zAccountId);
                zAccount.setValue('AutoPay',false);
                zAccount.setValue('DefaultPaymentMethodId', (String)check[0].getValue('Id'));
                zAccounts.add(zAccount);
                if(zAccountSuspended.get(zAccountId))                   
                    suspendedZAccountIds.add(zAccountId);                     
                else 
                    notSuspendedZAccountIds.add(zAccountId);                                    
            }
            
            
            if(zAccounts.size() > 0) {
                List<Zuora.zApi.SaveResult> zSaveResult = zUtilInstance.zupdate(zAccounts); //will be used while writing test classes
                SMS_ZuoraHistory.processZResults(zSaveResult, 'SMS_InactivateSubs', sSubscriptionIds[0]);
            }
            if(zPaymentMethodIds.size() > 0){
               List<Zuora.zApi.DeleteResult> zDeleteResult = zUtilInstance.zdelete('PaymentMethod',zPaymentMethodIds); //will be used while writing test classes
                SMS_ZuoraHistory.processZResults(zDeleteResult, 'SMS_InactivateSubs', sSubscriptionIds[0]);       
            }
            if(pendingSuspendAccounts.size() > 0) {                
                List<SMS_Auto_Suspended_Account__c> updateSuspendAccounts = new List<SMS_Auto_Suspended_Account__c>();
                
                for(SMS_Auto_Suspended_Account__c pendingSuspendAccount : pendingSuspendAccounts) {
                    if(suspendedZAccountIds.contains(pendingSuspendAccount.Zuora_Account_Id__c)) {    
                        pendingSuspendAccount.Status__c = 'Success';
                        updateSuspendAccounts.add(pendingSuspendAccount);                                     
                    } 
                    else if(notSuspendedZAccountIds.contains(pendingSuspendAccount.Zuora_Account_Id__c)) {    
                        pendingSuspendAccount.Status__c = 'Failed';
                        updateSuspendAccounts.add(pendingSuspendAccount);
                    }    
                }
                
                update updateSuspendAccounts;
                system.debug('*** Batch finish updateSuspendAccounts : ' + updateSuspendAccounts);
            }        
                
        system.debug('*** Batch Finish Method');
        SMS_ZuoraHistory.createSuccess('SMS_InactivateSubs',sSubscriptionIds[0]);
        system.debug('*** Batch Zuora Success');
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_InactivateSubs',sSubscriptionIds[0]);
            system.debug('*** Batch Zuora Failure');
        } 
   } 
   
   private void updateProductsProvisioned(List<String> sSubscriptionIds, String productStatusReason) { 
        System.Debug('*** Products provisioned : ' + sSubscriptionIds);
        
        if (sSubscriptionIds.Size() > 0) {
            List<SMS_Provisioned_Product__c> provisionedProducts = new List<SMS_Provisioned_Product__c>();
            provisionedProducts = [
                SELECT id,Name,
                MRIS_Subscription_Id__c,
                Order__c,
                Product_Status__c,
                Provisioned_Status__c,
                Product_Status_Reason__c
                FROM   SMS_Provisioned_Product__c
                WHERE  MRIS_Subscription_Id__c = :sSubscriptionIds
            ]; 
              
            if (provisionedProducts.Size() > 0) {
                for(SMS_Provisioned_Product__c provisionedProduct : provisionedProducts) {
                    provisionedProduct.Product_Status__c = 'Terminate';
                    provisionedProduct.Provisioned_Status__c = 'Pending Deprovisioned';
                    provisionedProduct.Product_Status_Reason__c = productStatusReason;
                }
                
                update provisionedProducts;
            }
        }   
   }   
   
   private void setZuoraSubscriptionIds(List<String> sSubscriptionIds) {        
        system.debug('*** Batch sSubscriptionIds : ' + sSubscriptionIds);
       
        List<Zuora.zObject> zAccounts = getZuoraAccounts(sSubscriptionIds);
        
        if(zAccounts == null) throw new CustomException('No Zuora Accounts found'); 
        
        system.debug('*** Batch zAccounts :' + zAccounts );           
        
        for(Zuora.zObject zAccount : zAccounts) {
            if((String)zAccount.getValue('Status') == 'Active') {              
                zActiveAccounts.put((String)zAccount.getValue('Id'),zAccount);
                zAccountSuspended.put((String)zAccount.getValue('Id'),true);
            }
        }
        
        if(zActiveAccounts.keyset().size() > 0) {          
            
            List<Zuora.zObject> zSubscriptions = getZuoraSubscriptions(zActiveAccounts.keyset());
            Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date(); 
            
            system.debug('*** zSubscriptions : ' +zSubscriptions );           
             
            for(Zuora.zObject zSubscription : zSubscriptions) {
                if((String)zSubscription.getValue('Status') == 'Active' && (String)zSubscription.getValue('TermType') == 'TERMED' &&  (Boolean)zSubscription.getValue('AutoRenew') == true) {
                    if(((Date)zSubscription.getValue('TermStartDate')) > todayDate) {                 
                        zDeleteSubscriptionIds.add((String)zSubscription.getValue('Id'));
                        zSubscriptionAccount.put((String)zSubscription.getValue('Id'),(String)zSubscription.getValue('AccountId'));                     
                     }
                    else if(((Date)zSubscription.getValue('TermEndDate')) >= todayDate) {
                        zAutoRenewSubscriptionIds.add((String)zSubscription.getValue('Id'));
                        zSubscriptionAccount.put((String)zSubscription.getValue('Id'),(String)zSubscription.getValue('AccountId'));  
                     }                                                     
                }                     
            } 
        }    
    }
   
   private List<Zuora.zObject> getZuoraSubscriptions(Set<String> zAccountIds) {          

        Boolean isNotFirst = false;
        List<Zuora.zObject> zSubscriptions = new List<Zuora.zObject>();
        
        String subscriptionQuery = 'SELECT Id,AccountId,AutoRenew,Status,TermEndDate,TermStartDate,TermType FROM Subscription WHERE ';
        
        for(String zAccountId : zAccountIds) {    
            if (isNotFirst) 
                subscriptionQuery += ' OR ';
            
            subscriptionQuery += 'AccountId = \'' + zAccountId + '\'';
            isNotFirst = true;                        
            
        }

        if(isNotFirst){
            zSubscriptions = zUtilInstance.zquery(subscriptionQuery);// will be used while writing test classes
        }  
           
        return zSubscriptions;
    }
    
    private List<Zuora.zObject> getZuoraAccounts(List<String> sfSubscriptionIds) {
    
        Boolean isNotFirst= false;
        
        String accountQuery = 'SELECT Id, Status, Name, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE ';
        
        for(String sfSubscriptionId : sfSubscriptionIds) {    
            if (isNotFirst) 
            accountQuery += ' OR ';
            
            accountQuery += 'SubscriptionID__c = \'' + sfSubscriptionId + '\'';
            isNotFirst = true;             
        }
        
        if(isNotFirst){
            return zUtilInstance.zquery(accountQuery); //will be used while writing test classes
        }    
        return null;
            
    }
    
    private void setZPaymentMethodIds(Set<String> zAccountIds) {
        Boolean isNotFirst= false;
        zPaymentMethodIds = new List<String>();
        List<Zuora.zObject> zPaymentMethods = new List<Zuora.zObject>();
        
        String paymentMethodQuery = 'SELECT Id FROM PaymentMethod WHERE ';
        
        for(String zAccountId : zAccountIds) {    
            if (isNotFirst) 
            paymentMethodQuery += ' OR ';
            
            paymentMethodQuery += 'AccountId = \'' + zAccountId + '\'';
            isNotFirst = true;             
        }
        
        if(isNotFirst) {
            zPaymentMethods = zUtilInstance.zquery(paymentMethodQuery); //will be used while writing test classes
            for(Zuora.zObject zPaymentMethod : zPaymentMethods)
                zPaymentMethodIds.add((String)zPaymentMethod.getValue('Id'));
        }
        
    } 
    
    private List<Zuora.zApi.AmendRequest> getAutoRenewAmendmentRequest(String zSubscriptionId){
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
    
}