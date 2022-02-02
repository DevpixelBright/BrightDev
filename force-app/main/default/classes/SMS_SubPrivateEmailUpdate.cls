public class SMS_SubPrivateEmailUpdate {
    public Static void updateContactEmail(String sSubscriptionId) 
    {
        if(system.isBatch() || system.isFuture())
        {
            updateContactEmailApex(sSubscriptionId);
        }else{
            updateContactEmailFuture(sSubscriptionId);
        }
    }
    @future(callout = true)
    public Static void updateContactEmailFuture(String sSubscriptionId) 
    {
        updateContactEmailApex(sSubscriptionId);
    }
    
    public Static void updateContactEmailApex(String sSubscriptionId) 
    {
        try {
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();                
             
            List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>(); 
            Set<String> zContactIds = new Set<String>();
            
            String contactEmail;
            
            sBillingAccounts = [SELECT Id,
                                       Name,
                                       Zuora__Account__c,
                                       Zuora__Zuora_Id__c,
                                       Zuora__BillToId__c,
                                       Zuora__SoldToId__c,
                                       Subscription__r.Private_Email__c
                                FROM   Zuora__CustomerAccount__c 
                                WHERE  SubscriptionID__c = :sSubscriptionId
                               ];            
            
            if(sBillingAccounts.size() > 0){                                   
                contactEmail = sBillingAccounts[0].Subscription__r.Private_Email__c;
                for(Zuora__CustomerAccount__c billingAccount : sBillingAccounts) {
                    zContactIds.add(billingAccount.Zuora__BillToId__c);
                    zContactIds.add(billingAccount.Zuora__SoldToId__c);
                }
            }
            else {
                List<Subscriptions__c> sSubscription = [SELECT id,Name, Private_Email__c
                                                        FROM   Subscriptions__c
                                                        WHERE  Name = :sSubscriptionId
                                                       ];                
                contactEmail = sSubscription[0].Private_Email__c;
                String zAccountsQuery = 'SELECT Id, BillToId, SoldToId FROM Account WHERE SubscriptionID__c = \'' + sSubscriptionId  + '\' AND Status = \'Active\'';                       
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
                if (zAccounts.Size() == 1) {
                    zContactIds.add((String)zAccounts[0].getValue('BillToId'));
                    zContactIds.add((String)zAccounts[0].getValue('SoldToId'));
                }
            }
            List<Zuora.zObject> zContacts = new List<Zuora.zObject>();
            Integer i = 1; 
            
            for(String zContactId : zContactIds) {
                Zuora.zObject zContact = new Zuora.zObject('Contact');
                zContact.setValue('Id',zContactId);
                zContact.setValue('PersonalEmail', contactEmail);
                zContact.setValue('WorkEmail', contactEmail);
                
                system.debug('$$$ zContact : ' + zContact);
                i++;
                
                    zContacts.add(zContact);                
            }
            
            if(zContacts.size() > 0) {
                List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zupdate(zContacts);
                SMS_ZuoraHistory.processZResults(zSaveResultList,'SMS_SubPrivateEmailUpdate',sSubscriptionId);
            }
            SMS_ZuoraHistory.createSuccess('SMS_SubPrivateEmailUpdate',sSubscriptionId);                                    
        }
        catch(Exception e) {
            system.debug('*** TEST Exception :' + e.getStackTraceString());
            SMS_ZuoraHistory.createError(e,'SMS_SubPrivateEmailUpdate',sSubscriptionId);
        }
    }
}