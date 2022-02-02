public class SMS_UpdateAddress_Future {

    public Static void updateContactZuora(String sSubscriptionId) {
        if(System.isFuture() || System.isBatch()){
            updateContactZuoraApex(sSubscriptionId);
        }else{
            updateContactZuoraFuture(sSubscriptionId);
        }
    }
    @future(callout = true)
    public Static void updateContactZuoraFuture(String sSubscriptionId) {
        updateContactZuoraApex(sSubscriptionId);
    }
    
    public Static void updateContactZuoraApex(String sSubscriptionId) {
        try {
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();                
             
            List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>(); 
            Set<String> zContactIds = new Set<String>();
            String state;
            String city;
            String zip;
            String contactEmail;
            
            sBillingAccounts = [SELECT Id,
                                       Name,
                                       Zuora__Account__c,
                                       Zuora__Zuora_Id__c,
                                       Zuora__BillToId__c,
                                       Zuora__SoldToId__c,
                                       Subscription__r.Related_Location_Broker_Office__r.State__c,
                                       Subscription__r.Related_Location_Broker_Office__r.City__c,
                                       Subscription__r.Related_Location_Broker_Office__r.Zip__c,
                                       Subscription__r.Private_Email__c
                                FROM   Zuora__CustomerAccount__c 
                                WHERE  SubscriptionID__c = :sSubscriptionId
                               ];            
            
            if(sBillingAccounts.size() > 0){                   
                state = sBillingAccounts[0].Subscription__r.Related_Location_Broker_Office__r.State__c;
                city = sBillingAccounts[0].Subscription__r.Related_Location_Broker_Office__r.City__c;
                zip = sBillingAccounts[0].Subscription__r.Related_Location_Broker_Office__r.Zip__c;
                contactEmail = sBillingAccounts[0].Subscription__r.Private_Email__c;
                for(Zuora__CustomerAccount__c billingAccount : sBillingAccounts) {
                    zContactIds.add(billingAccount.Zuora__BillToId__c);
                    zContactIds.add(billingAccount.Zuora__SoldToId__c);
                }
            }
            else {
                List<Subscriptions__c> sSubscription = [SELECT id,Name, Private_Email__c,
                                                               Related_Location_Broker_Office__r.State__c,
                                                               Related_Location_Broker_Office__r.City__c,
                                                               Related_Location_Broker_Office__r.Zip__c
                                                        FROM   Subscriptions__c
                                                        WHERE  Name = :sSubscriptionId
                                                       ];
                state = sSubscription[0].Related_Location_Broker_Office__r.State__c;                                       
                city = sSubscription[0].Related_Location_Broker_Office__r.City__c;
                zip = sSubscription[0].Related_Location_Broker_Office__r.Zip__c;
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
                zContact.setValue('State',state);
                zContact.setValue('City', city);
                zContact.setValue('PostalCode', zip); 
                zContact.setValue('PersonalEmail', contactEmail);
                zContact.setValue('WorkEmail', contactEmail);
                
                system.debug('$$$ zContact : ' + zContact);
                i++;
                //if(i<50)
                    zContacts.add(zContact);
                /*else {
                    List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zupdate(zContacts);                     
                    SMS_ZuoraHistory.processZResults(zSaveResultList,'SMS_UpdateAddress_Future',sSubscriptionId);
                    zContacts.clear();
                    i = 1;
                }*/
            }
            
            if(zContacts.size() > 0) {
                List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zupdate(zContacts);
                SMS_ZuoraHistory.processZResults(zSaveResultList,'SMS_UpdateAddress_Future',sSubscriptionId);
            }
            SMS_ZuoraHistory.createSuccess('SMS_UpdateAddress_Future',sSubscriptionId);                                    
        }
        catch(Exception e) {
            system.debug('*** TEST Exception :' + e.getStackTraceString());
            SMS_ZuoraHistory.createError(e,'SMS_UpdateAddress_Future',sSubscriptionId);
        }
    }
}