@istest(SeeAllData = true)
private class Communities_PayMyBalances_Test{
        
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    
    private static testMethod void doTestOne(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c,Status__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        subs[0].Status__c = 'Active';
        update subs[0];
        
        /* Create page reference */
        PageReference pageRef = Page.Communities_PayMyBalances;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);           
        
        Communities_PayMyBalances_Controller controller = new Communities_PayMyBalances_Controller();
        controller.initPaymentPortal();          
             
    }
    
    private static testMethod void doTestTwo(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Status__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        subs[0].Status__c = 'Active';
        update subs[0];
        
        /* Create page reference */
        PageReference pageRef = Page.Communities_PayMyBalances;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subs[0].Id);           
        
        Communities_PayMyBalances_Controller controller = new Communities_PayMyBalances_Controller();
        controller.initPaymentPortal();          
             
    }
    
    
    
    private Static void generateTestData(){
        generateCornerstone();             
        createAccount('Residential','XYZABC123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id); 
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
        subscription.Subscription_Type__c = 'Personal Assistant';
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
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}