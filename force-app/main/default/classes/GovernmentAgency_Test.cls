@isTest(seeAllData = true)
private class GovernmentAgency_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;

    static testMethod void testOne() {
        generateData();             
        createAccount('Government Agency','TSTA12345'); 
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', account.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        
        account.Billing_Period__c = 'Quarterly';
        account.status__c = 'Active';
        update account;
    }
   
    static testMethod void testTwo() {
        generateData();             
        createAccount('Government Agency','TSTA12345'); 
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', account.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        
        account.Billing_Period__c = 'Quarterly';
        account.status__c = 'Active';
        update account;
        
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        System.Debug('### sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        //subs[0].Id = 'Quarterly';
        subs[0].status__c = 'Active';
        update subs[0];     
        
    }
    
    static testMethod void testThree() {
       
        generateData();             
        createAccount('Government Agency','TSTA12345'); 
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', account.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        
        account.Billing_Period__c = 'Annual';
        account.status__c = 'Active';
        update account;
    }
    
    static testMethod void testFour() {
        generateData();             
        createAccount('Government Agency','TSTA12345'); 
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('Id', account.Id);
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        
        account.Billing_Period__c = 'Annual';
        account.status__c = 'Active';
        update account;
        
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        System.Debug('### sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';        
        SMS_ZuoraMockDataGenerator.preDefinedValues.put('CrmId', account.Id);
        //subs[0].Id = 'Quarterly';
        subs[0].status__c = 'Active';
        update subs[0]; 
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
        subscription.Subscription_Type__c = 'Government Agency';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Government Agency';
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }   
}