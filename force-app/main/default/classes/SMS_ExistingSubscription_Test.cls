@istest(seealldata = true)
private class SMS_ExistingSubscription_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;    
    
    private static testMethod void doTestOne(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update  subscription;
        
        SMS_ExistingSubscription obj = new SMS_ExistingSubscription();       
        obj.mrisSubscription = subscription.Name;
        obj.verifySubscription();
        obj.createPersonAccount();
        obj.createZuoraAccounts();
        obj.createZuoraSubscription();
        
        SMS_ZuoraMockDataGenerator.emptyResult = true;
        obj.createZuoraAccounts();
                           
    } 
    
    private static testMethod void doTestTwo(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update  subscription;
        
        SMS_ZuoraAccountsCreation.createParentOrChildAccount(subscription.Id);                                  
    }
    
    private static testMethod void doTestThree(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update  subscription;
        
        SMS_ZuoraMockDataGenerator.emptyResult = true;
        SMS_ZuoraAccountsCreation.createParentOrChildAccount(subscription.Id);                                  
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
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
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
    
    private static void createBillingAccount(String accountId, String accountName, String subId, Decimal balance) {
       
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subId;
        billingAccount.Oldest_Invoice_Due__c = system.today().addDays(-5);
        billingAccount.Zuora__Balance__c = balance;
        insert billingAccount; 
    }         
}