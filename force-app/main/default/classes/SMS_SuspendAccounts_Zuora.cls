public class SMS_SuspendAccounts_Zuora {
    
    @future(callout = true) 
    public Static void suspendAccounts(String maximumAccounts, String amount, String days) {
        try {   
            SMS_AutoSuspend_Status__c setting = SMS_AutoSuspend_Status__c.getValues('Auto Suspend');
            Set<String> includedBillingJurisdictions = new Set<String>();
            //Set<String> includedServiceJurisdictions = new Set<String>();

           
            
            //Excluding billing jurisdictions
            if(String.isNotBlank(setting.IncludedBillingJurisdictions__c)){
                includedBillingJurisdictions.addAll(setting.IncludedBillingJurisdictions__c.split(','));
                
                if(includedBillingJurisdictions.contains('MRIS'))
                    includedBillingJurisdictions.add(NULL);
            }
                               
            
            // Excluding service jurisdictions
           /* if(String.isNotBlank(setting.IncludedServiceJurisdictions__c)){
                includedServiceJurisdictions.addAll(setting.IncludedServiceJurisdictions__c.split(','));
                
                if(includedServiceJurisdictions.contains('MRIS'))
                    includedServiceJurisdictions.add(NULL);
            }*/
            
        
            if(setting.IsActive__c) {
                
                SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); //will be used while writing test classes         
                
                Integer thresholdDays = Integer.valueOf(days);      
                Decimal thresholdAmount = Decimal.ValueOf(amount);
                Integer thresholdmaxAccs = Integer.valueOf(maximumAccounts);
                
                Set<String> sBillingAccountZIds = new Set<String>();       
                Set<String> zAccountIds = new Set<String>();
                Set<String> tobesuspend = new Set<String>();                
                
                Boolean isNotFirst = false;
                Date thresholdate = date.valueOf(system.today().addDays(-thresholdDays));

                // Querying Salesforce to retreive the accounts to be suspended
                List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>();             
                
                sBillingAccounts = [Select id,Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c
                                    WHERE  Oldest_Invoice_Due__c <=  :thresholdate
                                    AND    Subscription__r.Status__c = 'Active'
                                    AND    Zuora__Balance__c >= :thresholdAmount
                                    AND    Subscription__r.IsExcludedFromAutomatedSuspension__c = false
                                    AND    Subscription__r.Billing_Jurisdiction__c in : includedBillingJurisdictions
                                   // AND    Subscription__r.Service_Jurisdiction__c in : includedServiceJurisdictions
                                    
                                    LIMIT 200
                                   ];
                
                String zQuery = 'SELECT Id,Balance,Name,SubscriptionID__c,ParentId FROM Account WHERE ';
                
                for(Zuora__CustomerAccount__c sBillingAccount : sBillingAccounts){
                    
                    if (isNotFirst)
                        zQuery += ' OR ';
                    
                    zQuery += 'Id = \'' + sBillingAccount.Zuora__Zuora_Id__c + '\'';
                    isNotFirst = true;             
                }
                
                if(isNotFirst) {
                    List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zQuery);
                    Set<String> zAccountParentIds = new Set<String>();
                    
                    for(Zuora.zObject zAccount : zAccounts){  
                        if((Decimal)zAccount.getValue('Balance') > 0 &&  zAccountParentIds.size() < Integer.ValueOf(thresholdmaxAccs))                            
                            zAccountParentIds.add((String)zAccount.getValue('ParentId'));
                    }
                    
                    
                    zQuery = 'SELECT Id,SubscriptionID__c,Name,Balance FROM Account WHERE ';
                    isNotFirst = false;                 
                    
                    for(String zAccountId : zAccountParentIds) {    
                        if (isNotFirst) 
                            zQuery += ' OR ';
                        
                        zQuery += 'ParentId = \'' + zAccountId + '\'';
                        isNotFirst = true;             
                    }
                    
                    if(isNotFirst) {
                        system.debug('---zQuery--->'+zQuery);
                        List<Zuora.zObject> zChildAccounts = zUtilInstance.zquery(zQuery);                         
                        system.debug('---zChildAccounts-->'+zChildAccounts);
                        Map<String,SMS_Auto_Suspended_Account__c> suspendAccounts = new Map<String,SMS_Auto_Suspended_Account__c>();
                        List<SMS_Auto_Suspended_Account__c> suspendedAccounts = new List<SMS_Auto_Suspended_Account__c>();
                        
                        for(Zuora.zObject zAccount : zChildAccounts) {
                        system.debug('*** zAccount ' + zAccount);
                            SMS_Auto_Suspended_Account__c suspendAccount = new SMS_Auto_Suspended_Account__c();
                            suspendAccount.Customer_Name__c = (String)zAccount.getValue('Name');
                            suspendAccount.Date_of_Suspension__c = System.today();
                            suspendAccount.Day_of_Suspension__c = system.now().format('EEEE');
                            suspendAccount.MRIS_Subscription_ID__c = (String)zAccount.getValue('SubscriptionID__c');
                            suspendAccount.Total_Amount_Due__c = (Decimal)zAccount.getValue('Balance');
                            suspendAccount.Zuora_Account_Id__c = (String)zAccount.getValue('Id');                        
                            suspendAccount.Status__c = 'In Progress';
                            suspendAccounts.put((String)zAccount.getValue('SubscriptionID__c'),suspendAccount);
                        }
                        system.debug('*** suspendAccounts size(): ' + suspendAccounts.size());
                        
                        if(suspendAccounts.size() > 0) {                        
                            String batchId = 'AS' + system.now().getTime() ;
                            
                            for(Subscriptions__c sSubscription : [SELECT id,Status__c,Name,Contact__r.Name,Private_Email__c,Service_Jurisdiction__c,Billing_Jurisdiction__c FROM Subscriptions__c WHERE Name in :suspendAccounts.keyset() AND Status__c = 'Active' AND IsExcludedFromAutomatedSuspension__c = false]) {
                                system.debug('*** sSubscription ' + sSubscription);
                                SMS_Auto_Suspended_Account__c suspendAccount = suspendAccounts.get(sSubscription.Name);
                                suspendAccount.Contact_Private_Email__c = sSubscription.Private_Email__c ;
                                suspendAccount.Auto_Suspend_Batch_ID__c = batchId ;
                                suspendAccount.Bright_Subscription__c   = sSubscription.ID;
                                suspendaccount.Service_Jurisdiction__c  = sSubscription.Service_Jurisdiction__c;
                                suspendaccount.Billing_Jurisdiction__c  = sSubscription.Billing_Jurisdiction__c;
                                suspendedAccounts.add(suspendAccount);
                            }
                            
                            insert suspendedAccounts;
                            
                            /*for(SMS_Auto_Suspended_Account__c suspendedAccount : suspendedAccounts){
                                Subscriptions__c s = new Subscriptions__c();
                                s.ID = suspendedAccount.Bright_Subscription__c;
                                s.status__c = 'Inactive';
                                s.Status_Change_Reason__c = 'Suspended';
                                update s;
                            }*/
                            
                            
                            system.debug('*** suspendAccounts size(): ' + suspendedAccounts.size());
                        }
                    }
                }                         
            }                
            
            SMS_ZuoraHistory.createSuccess('SMS_SuspendAccounts_Zuora',null); 
        }
        
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_SuspendAccounts_Zuora',null);            
        }
    }
}