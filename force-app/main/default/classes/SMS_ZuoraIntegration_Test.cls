@istest(SeeAllData = true)
private class SMS_ZuoraIntegration_Test{
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
    private Static SMS_Provisioned_Product__c provisionedProduct;
    
    private static testMethod void doTestOne() {

        generateData();             
        createAccount('Residential','ABC123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription; 

        subscription.Status__c = 'Inactive';
        subscription.Status_Change_Reason__c = 'Terminated';
        update subscription;        
    }
    
    private static testMethod void doTestTwo() {

        generateData();             
        createAccount('Residential','ABC123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        subscription.Private_Email__c = 'test@test.com';
        update subscription;  
    }
    
    private static testMethod void doTestThree() {

        generateData();             
        createAccount('Residential','ABC123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        subscription.Contact_Type__c = 'Government Agency';
        update subscription;
        
    }
    
    private static testMethod void doTestFour() {

        generateData();             
        createAccount('Residential','ABC123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscription.Subscription_Type__c = 'REALTOR Appraiser Shareholder - Quarterly';
        update subscription; 
    }
    
    private static testMethod void doTestFive() {

        generateData();             
        createAccount('RETS','ABC123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;  
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
        account.Billing_Period__c = 'Quarterly';
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
        subscription.State__c = 'VA';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static void createBillingAccount() {
        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
        
        Subscriptions__c sSubscription = [SELECT Id, Name FROM Subscriptions__c WHERE  id = :subscription.id];      
        
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = personAccount.id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = sSubscription.Name;
        insert billingAccount; 
    }
    
    private Static void createProvisionedProduct(String subscriptionId){
        Subscriptions__c sSubscription = [SELECT Id, Name, SF_Subscription_ID__c 
        FROM Subscriptions__c WHERE  id = :subscriptionId];
        system.debug('*** Test Sub Id :' + sSubscription.Name);
        provisionedProduct = new SMS_Provisioned_Product__c();                           
        provisionedProduct.MRIS_Subscription_Id__c = sSubscription.SF_Subscription_ID__c;                            
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Provisioned_Status__c = 'Provisioned';
                                
    }
}