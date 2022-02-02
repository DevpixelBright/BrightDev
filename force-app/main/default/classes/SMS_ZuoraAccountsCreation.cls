public class SMS_ZuoraAccountsCreation {
    private enum zOperation { zCREATE, zUPDATE }
    private static SMS_ZuoraUtil zUtilInstance;
    private Static Zuora.zApi.SaveResult zSaveResult;
    
    private Static String sfSubscriptionId;
    private Static String sfSubscriptionRecordId;

    public static String createParentOrChildAccount(String mSubscriptionId) {
        if (String.isBlank(mSubscriptionId))
            throw new CustomException('Invalid Operation');
        
        sfSubscriptionRecordId = mSubscriptionId;
        try {
            String zChildId;
            String zParentId;            
            
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();

            String sId = getPersonAccountId(mSubscriptionId); 
            String contactKey = getContactKey(mSubscriptionId);
             System.Debug('### sfSubscriptionId ' + sfSubscriptionId ); 
            /* Find Parent Account in Zuora */
            zParentId = getZParentIdFromZuora(sId);
            
            if (String.isBlank(zParentId)){
                /* Create Zuora Parent Account */
                zParentId = createAccount(sId, contactKey);
                createAccount(sId, zParentId, sfSubscriptionId, contactKey);                 
            } 
            else {
                if (!isChildAlreadyInZuora(mSubscriptionId))
                    createAccount(sId, zParentId, sfSubscriptionId, contactKey);    
            }
            return 'success';
        }
        catch (Exception e) {
            return e.getMessage();
        }
    }
    
    private Static String createAccountDraft(String sAccountId, String zParentAccountId, String mSubscriptionId, String contactKey){
        Boolean createParentAccount = String.isNotBlank(sAccountId) && String.isBlank(zParentAccountId) && String.isBlank(mSubscriptionId);
        Boolean createChildAccount = String.isNotBlank(sAccountId) && String.isNotBlank(zParentAccountId) && String.isNotBlank(mSubscriptionId);
        
        if (!createParentAccount && !createChildAccount)
            throw new CustomException('Invalid Operation');
            
        try {
            Account sAccount = getSalesforceAccount(sAccountId);         
            
            /* Populate Zuora Account object */
            Zuora.zObject zAccount = new Zuora.zObject('Account');
            
            zAccount.setValue('CrmId', sAccount.Id);
            zAccount.setValue('Name', sAccount.Name);
            zAccount.setValue('Currency', 'USD');
            zAccount.setValue('BillCycleDay', '1');
            zAccount.setValue('PaymentTerm', 'Due upon receipt');
            zAccount.setValue('Batch', 'Batch1');
            zAccount.setValue('Status', 'Draft');           
            
            if (createChildAccount) {
                zAccount.setValue('ParentId', zParentAccountId);
                zAccount.setValue('SubscriptionID__c', mSubscriptionId);
                zAccount.setValue('AccountNumber', mSubscriptionId);//Child Account's Account Number same as the MRIS Subscription Id
                zAccount.setValue('Batch', 'Batch1');
                
                String billingJurisdiction = getBillingJurisdiction();
                
                if(billingJurisdiction != null) {
                  system.debug('---billingJurisdiction '+billingJurisdiction );
                  system.debug('---bj ---'+BRIGHT_Billing_Jurisdiction__c.getAll());
                  Map<String, BRIGHT_Billing_Jurisdiction__c> mcMap = BRIGHT_Billing_Jurisdiction__c.getAll();
                 
                 for(BRIGHT_Billing_Jurisdiction__c jurisdiction : mcMap.values()) {
                     if(jurisdiction.Batch__c != null) {
                         if(jurisdiction.Billing_Jurisdiction__c == billingJurisdiction ) 
                            zAccount.setValue('Batch', jurisdiction.Batch__c);
                            break; 
                     }
                 }
                }
            }
            else if (createParentAccount) {
                zAccount.setValue('AccountNumber', contactKey);//Parent Account's Account Number same as the Person's contact Key
            }
            
            /* Create Zuora Account in draft status */
            callZuora(zOperation.zCREATE, zAccount);
            
            if (zSaveResult == null)
                throw new CustomException('Error Creating Zuora Account');    
            
            return zSaveResult.Id;
        }
        catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    private Static String activateZAccount(String zAccountId, String zContactId){
        try{
            Zuora.zObject zAccount = new Zuora.zObject('Account');
            zAccount.setValue('Id', zAccountId);
            zAccount.setValue('BillToId', zContactId);
            zAccount.setValue('SoldToId', zContactId);
            zAccount.setValue('Status', 'Active');
            
            /* Activate Zuora Account */
            callZuora(zOperation.zUPDATE, zAccount);
            
            if (zSaveResult == null)
                throw new CustomException('Error Activating Zuora Account');

            return zSaveResult.Id;
        }
        catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    
    }
    
    private Static String createContact(String sAccountId, String zAccountId, Boolean isChild) {        
        try{
             Account sAccount = getSalesforceAccount(sAccountId);    
             /* Initally set contact state to subscription's person account state */
            String contactState = sAccount.State__c;
            String contactCity;
            String contactZip;
            
            if (isChild) {
             /* Find Subscription's related location office state*/
                
                List<Subscriptions__c> subscriptionOfficeId = [
                    SELECT Related_Location_Broker_Office__c
                    FROM   Subscriptions__c 
                    WHERE  Id = :sfSubscriptionRecordId
                ];
                if(subscriptionOfficeId.IsEmpty()) {
                    throw new CustomException('Subscription is missing Related Location');
                }
                List<Account> office = [
                    SELECT State__c, Zip__c, City__c  
                    FROM Account 
                    WHERE ID = :subscriptionOfficeId[0].Related_Location_Broker_Office__c
                ];
                if(office.IsEmpty()) {
                    throw new CustomException('Subscription\'s reference Related Location could not be found');
                }
                contactState = office[0].State__c;
                contactCity = office[0].City__c;
                contactZip = office[0].Zip__c;
            }
                
            /* Populate Zuora Contact object */
            Zuora.zObject zContact = new Zuora.zObject('Contact');
                           
            zContact.setValue('FirstName', sAccount.FirstName);
            zContact.setValue('LastName', sAccount.LastName);
            zContact.setValue('State', contactState);
            zContact.setValue('City', contactCity);
            zContact.setValue('PostalCode', contactZip);  
            zContact.setValue('Country', 'United States');
            zContact.setValue('AccountId', zAccountId); 
                
            callZuora(zOperation.zCREATE, zContact);
            
             if (zSaveResult == null)
                throw new CustomException('Error Creating Zuora Contact');
             
             return zSaveResult.Id;
        }
        catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    private Static String getContactKey(String mSubscriptionId) {
        List<Subscriptions__c> sSubscriptions = [SELECT Id, Name, Contact__c, Contact__r.Contact_Key__c
                                                 FROM Subscriptions__c
                                                 WHERE  Id = :mSubscriptionId
                                                ];
        if (sSubscriptions.isEmpty())
            throw new CustomException('No Subscriptions Found');
            
        if (sSubscriptions.size() > 1)
            throw new CustomException('Multiple Matching Subscription Found');   

        return sSubscriptions[0].Contact__r.Contact_Key__c;  
    }
    
    private Static String getPersonAccountId(String mSubscriptionId) {
        
        List<Subscriptions__c> sSubscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Contact__c 
                                                 FROM   Subscriptions__c 
                                                 WHERE  Id = :mSubscriptionId // <- updated to bypass workflow
                                                ];
                                                
        if (sSubscriptions.isEmpty())
            throw new CustomException('No Subscriptions Found');
            
        if (sSubscriptions.size() > 1)
            throw new CustomException('Multiple Matching Subscription Found');
            
        if (String.isNotBlank(sSubscriptions[0].Name) && sSubscriptions[0].Name != 'To be filled in when saved')
            sfSubscriptionId = sSubscriptions[0].Name;
        else   
            sfSubscriptionId = String.valueOf(sSubscriptions[0].SF_Subscription_ID__c); 
          
        System.Debug('### sSubscriptions ' + sSubscriptions ); 
        System.Debug('### sfSubscriptionId ' + sfSubscriptionId ); 
                 
        List<Account> personAccounts = [SELECT id,Name 
                                        FROM   Account 
                                        WHERE  Contact__c = :sSubscriptions[0].Contact__c
                                       ];
              
        if (personAccounts.isEmpty())
            throw new CustomException('No Accounts Found');
            
        if (personAccounts.size() > 1)
            throw new CustomException('Multiple Matching Accounts Found');        

        return personAccounts[0].Id;                             
    }
    
    private Static String getZParentIdFromZuora(String sAccountId) {
        String query = 'SELECT Id, Status FROM Account WHERE CrmId LIKE \'' + sAccountId + '%\'' + '\' AND ParentId = null';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(query); //will be used while writing test classes
        
        if (zAccounts.isEmpty())
            return null;
            
        if (zAccounts.size() > 1)
            throw new CustomException('Multiple Matching Zuora Parent Accounts Found');

        if(zAccounts[0].getValue('Status') == 'Draft'){
            String zContactId = createContact(sAccountId, String.valueOf(zAccounts[0].getValue('Id')), false);
            activateZAccount(String.valueOf(zAccounts[0].getValue('Id')), zContactId);        
        }
        
        return String.valueOf(zAccounts[0].getValue('Id'));
    }
    
    //This is creating parent account. 
    private Static String createAccount(String sAccountId, String contactKey) {
        return createAccount(sAccountId, null, null, contactKey);
    }
        
    private Static String createAccount(String sAccountId, String zParentAccountId, String mSubscriptionId, String contactKey) {
        Boolean createParentAccount = String.isNotBlank(sAccountId) && String.isBlank(zParentAccountId) && String.isBlank(mSubscriptionId);
        Boolean createChildAccount = String.isNotBlank(sAccountId) && String.isNotBlank(zParentAccountId) && String.isNotBlank(mSubscriptionId);
        
        if (!createParentAccount && !createChildAccount)
            throw new CustomException('Invalid Operation');
        
        try {
            String zAccountId = createAccountDraft(sAccountId, zParentAccountId, mSubscriptionId, contactKey);
            String zContactId;
            
            if(createChildAccount)
                zContactId = createContact(sAccountId, zAccountId, true);
            else
                zContactId = createContact(sAccountId, zAccountId, false);
            
            zAccountId = activateZAccount(zAccountId, zContactId);
            
            return zAccountId;     
        }
        catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    private Static Account getSalesforceAccount(String sAccountId) {
        List<Account> sAccounts = [
            SELECT  Id, 
                    Name, 
                    FirstName, 
                    LastName, 
                    State__c, 
                    QAS_Mailing_Country__c
            FROM    Account 
            WHERE   Id = :sAccountId
        ];
        
        if (sAccounts.isEmpty())
            throw new CustomException('Invalid Salesforce Account');
        
        Account sAccount = sAccounts[0];
        
        if (String.isEmpty(sAccount.FirstName) || String.isEmpty(sAccount.LastName) || String.isEmpty(sAccount.State__c) )
            /// Why? || String.isEmpty(sAccount.QAS_Mailing_Country__c)) 
            throw new CustomException('Incomplete Salesforce Account');
        
        return sAccount;
    }
    
    private Static Boolean isChildAlreadyInZuora(String mSubscriptionId ) {
        /* Code added to check whether a child account is already present in Zuora*/
    
        String query = 'SELECT Id, Status FROM Account WHERE SubscriptionID__c = \'' + mSubscriptionId + '\' AND ParentId != null';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(query); //will be used while writing test classes
        
        if(!zAccounts.isEmpty()){
            if(zAccounts[0].getValue('Status') == 'Draft'){
                String sAccountId = getPersonAccountId(mSubscriptionId); 
                String zContactId = createContact(sAccountId, String.valueOf(zAccounts[0].getValue('Id')), true);
                activateZAccount(String.valueOf(zAccounts[0].getValue('Id')), zContactId); 
            }       
        }
        
        return !zAccounts.isEmpty();
    }
    
    private Static Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject> { content };
        List<Zuora.zApi.SaveResult> zSaveResultList;
        
        if (operation == zOperation.zCREATE) {
           zSaveResultList = zUtilInstance.zcreate(zObjectList); //will be used while writing test classes
        }
        else if (operation == zOperation.zUPDATE){
           zSaveResultList = zUtilInstance.zupdate(zObjectList); //will be used while writing test classes
        }
        else
            throw new CustomException('Illegal Zuora Operation');
        
        system.debug('*** zSaveResultList : ' + zSaveResultList);
        SMS_ZuoraHistory.processZResults(zSaveResultList, 'SMS_ZuoraCreateParentOrChildAccount', sfSubscriptionId);
        zSaveResult = !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
        
        return zSaveResult;
    }
     private static String getBillingJurisdiction() {
        system.debug('sfSubscriptionRecordId --- '+sfSubscriptionRecordId );
        if(sfSubscriptionRecordId  != null) {
          List<Subscriptions__c> subscriptions =  [SELECT Id, Name, SF_Subscription_ID__c, Contact__c, Billing_Jurisdiction__c 
                                                   FROM   Subscriptions__c 
                                                   WHERE  Id = :sfSubscriptionRecordId 
                                                  ];
            if(subscriptions.size() == 1){
                system.debug('---subscriptions.size() == '+subscriptions.size());
                system.debug('---subscriptions[0].Billing_Jurisdiction__c=== '+subscriptions[0].Billing_Jurisdiction__c);
                return subscriptions[0].Billing_Jurisdiction__c;
            }
        }
        return null;
    }
    public class CustomException extends Exception {}

}