@istest(SeeAllData = true)
private class SMS_ChangeInPrimarySubscription_Test {

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
        update subscription;
               
        Subscriptions__c subscription1 = new  Subscriptions__c();
        subscription1.Contact__c = contact.id;
        subscription1.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription1.Status__c = 'In Progress';
        subscription1.City__c = 'Herndon';
        subscription1.Zip__c = '20171';
        subscription1.County__c = 'Fairfax';
        subscription1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription1.AgentKey__c = '123111';
        subscription1.Name = '123112';
        subscription1.County__c = 'Fairfax';
        subscription1.Related_Location_Broker_Office__c = account.id;
        subscription1.Contact_Type__c = 'Agent';
        insert subscription1;
         
        subscription1.Status__c = 'Active';
        update subscription1;                       
             
        List<Subscriptions__c> subscriptions = [ 
                SELECT Id,Name, Contact_Type__c,PrismSubscriptionID__c, Subscription_Type__c, Date_Terminated__c,Primary__c, Contact__c, SF_Subscription_ID__c, Status__c  
                FROM   Subscriptions__c
                WHERE  Contact__c = :contact.id];     
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 2; 
        SMS_ChangeInPrimarySubscription.changePrimarySubscription(subscriptions[0].Name, subscriptions[1].Name);                                 
    }
    
    private static testMethod void doTestTwo(){
        SMS_ChangeInPrimarySubscription.changePrimarySubscription('', '');                          
    }
    
    private static testMethod void doTestThree(){
        SMS_ChangeInPrimarySubscription.changePrimarySubscription('12345', '54321');                          
    }
    
    private static testMethod void doTestForChangePrimaryTrigger() {
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id); 
               
        Subscriptions__c subscription1 = new  Subscriptions__c();
        subscription1.Contact__c = contact.id;
        subscription1.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription1.Status__c = 'In Progress';
        subscription1.City__c = 'Herndon';
        subscription1.Zip__c = '20171';
        subscription1.County__c = 'Fairfax';
        subscription1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription1.AgentKey__c = '123111';
        subscription1.Name = '123112';
        subscription1.County__c = 'Fairfax';
        subscription1.Related_Location_Broker_Office__c = account.id;
        subscription1.Contact_Type__c = 'Agent';
        insert subscription1;
        
        subscription1.Related_Location_Broker_Office__c = account.Id; 
        update subscription1;         
        subscription1.Status__c = 'Active';
        update subscription1; 


        List<Subscriptions__c> subscriptions = [ 
                SELECT Id, Contact_Type__c, Subscription_Type__c, Date_Terminated__c,Primary__c, Contact__c, SF_Subscription_ID__c, Status__c  
                FROM   Subscriptions__c
                WHERE  Contact__c = :contact.id];        

        contact.Primary_Subscription__c = subscriptions[0].Id;
        update contact;
        
        contact.Primary_Subscription__c = subscriptions[1].Id;
        update contact;          
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
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        insert subscription; 
    }    
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static void createBillingAccount(String accountId, String accountName, String subId) {
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subId;
        insert billingAccount; 
    } 
       public Class CustomException extends Exception {}     
}