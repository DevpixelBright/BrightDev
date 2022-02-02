@istest(SeeAllData = true)
private class SMS_InactivateSubs_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static SMS_Provisioned_Product__c provisionedProduct;
    private Static SMS_Auto_Suspended_Account__c autoSuspendAccount;

    private static testMethod void doTestOne(){   
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        System.Debug('**** subscription : ' + subscription);
        createProvisionedProduct(subscription.Name); 
        
        List<String> inactiveSubscriptionIds = new List<String> {subscription.Name}; 
        Database.executeBatch(new SMS_InactivateSubs(inactiveSubscriptionIds),5);
    }

    private static testMethod void doTestTwo(){  
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        System.Debug('**** subscription : ' + subscription);
        createProvisionedProduct(subscription.Name); 
        
        String zAccountId = '2hjsdfe093850923hefhe';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', zAccountId);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        createAutoSuspendAccount(subscription.Name,zAccountId);
        
        List<String> inactiveSubscriptionIds = new List<String> {subscription.Name}; 
        Database.executeBatch(new SMS_InactivateSubs(inactiveSubscriptionIds),5);   
    } 
   
    private static void createAccount(String type,String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
    }
    
    private static void createContact(String accountId){
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private Static void createProvisionedProduct(String subscriptionId){
        //Subscriptions__c sSubscription = [SELECT Id, Name, SF_Subscription_ID__c FROM Subscriptions__c WHERE  id = :subscriptionId];
        //system.debug('*** Test Sub Id :' + sSubscription.Name);
        provisionedProduct = new SMS_Provisioned_Product__c();                           
        //provisionedProduct.MRIS_Subscription_Id__c = sSubscription.SF_Subscription_ID__c; 
        provisionedProduct.MRIS_Subscription_Id__c = subscriptionId;                           
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Provisioned_Status__c = 'Provisioned';
        insert provisionedProduct;                        
    }
    
    private Static void createAutoSuspendAccount(String subscriptionId, String zAccountId){
        autoSuspendAccount = new SMS_Auto_Suspended_Account__c();                           
        autoSuspendAccount.MRIS_Subscription_ID__c = subscriptionId;                           
        autoSuspendAccount.Auto_Suspend_Batch_ID__c = 'AS1395752415182';
        autoSuspendAccount.Status__c = 'In Progress';
        autoSuspendAccount.Zuora_Account_Id__c = zAccountId;
        insert autoSuspendAccount;                        
    }    
}