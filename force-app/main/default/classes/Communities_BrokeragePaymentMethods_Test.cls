@istest(SeeAllData = true)
private class Communities_BrokeragePaymentMethods_Test{
        
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Relationship__c relationship;
    
    private static testMethod void doTestOne(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 2; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData('PQZ123');       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c,Status__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        subs[0].Status__c = 'Active';
        update subs[0];
        
        /* Create page reference */
        PageReference pageRef = Page.Communities_BrokeragePaymentMethods;
        Test.setCurrentPage(pageRef);
        
        String pmid = 'ewruw82758yuwehr';        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);       
        ApexPages.currentPage().getParameters().put('pmId', pmid);
        ApexPages.currentPage().getParameters().put('paymentOption', 'Direct Debit');              
        
               
        Communities_BrokeragePaymentMethods_Cls controller = new Communities_BrokeragePaymentMethods_Cls();
        controller.paymentSetting = 'Direct Debit';
        controller.initPaymentMethodPortal();
        
        Communities_BrokeragePaymentMethods_Cls.PaymentMethod paymentMethod = new Communities_BrokeragePaymentMethods_Cls.PaymentMethod();
        paymentMethod.Id = pmid;        
        
        Communities_BrokeragePaymentMethods_Cls.PaymentMethodData paymentMethodData = new Communities_BrokeragePaymentMethods_Cls.PaymentMethodData();
        paymentMethodData.PaymentMethods = new List<Communities_BrokeragePaymentMethods_Cls.PaymentMethod> {paymentMethod};
        
        controller.Payment = paymentMethodData;
        controller.reloadPaymentMethods();
        controller.initHPM();
        controller.reloadHPM();
        controller.removeHPM();
        controller.clearDefaultPaymentMethod(); 
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod();          
        controller.updatePaymentMethod(); 
        controller.updateACHPaymentMethod();
        controller.deletePaymentMethod();   
    }
    
    private static testMethod void doTestTwo(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData('ABC1234');       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Status__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        subs[0].Status__c = 'Active';
        update subs[0];
        
        /* Create page reference */
        PageReference pageRef = Page.Communities_BrokeragePaymentMethods;
        Test.setCurrentPage(pageRef);
        
        Communities_BrokeragePaymentMethods_Cls controller = new Communities_BrokeragePaymentMethods_Cls();
        controller.initPaymentMethodPortal();
        SMS_ZuoraMockCall.isSuccess = false;
        controller.updatePaymentMethod();              
             
    }
    
    private static testMethod void doTestThree(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
       
        generateTestData('MNO123');       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c,Status__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        subs[0].Status__c = 'Active';
        update subs[0];
        
        /* Create page reference */
        PageReference pageRef = Page.Communities_BrokeragePaymentMethods;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('paymentOption', 'Credit Card'); 
        
        String pmid = 'ewruw82758yuwehr';        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);       
        ApexPages.currentPage().getParameters().put('pmId', pmid);              
        
        Communities_BrokeragePaymentMethods_Cls controller = new Communities_BrokeragePaymentMethods_Cls();
        controller.initPaymentMethodPortal(); 
        
        Communities_BrokeragePaymentMethods_Cls.LegacyACH legacyACH = new Communities_BrokeragePaymentMethods_Cls.LegacyACH();
        legacyACH.Id = pmid;
        Communities_BrokeragePaymentMethods_Cls.PaymentMethodData paymentMethodData = new Communities_BrokeragePaymentMethods_Cls.PaymentMethodData();
        paymentMethodData.LegacyACHs = new List<Communities_BrokeragePaymentMethods_Cls.LegacyACH> {legacyACH};       
        SMS_ZuoraMockCall.isSuccess = false;
        controller.reloadPaymentMethods();        
        controller.initHPM();
        controller.reloadHPM();
        controller.removeHPM();
        controller.clearDefaultPaymentMethod(); 
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod(); 
        controller.deletePaymentMethod(); 
        controller.updatePaymentMethod();
        controller.updateACHPaymentMethod();    
    }
    
    private static testMethod void doTestFour() {
        Communities_BrokeragePaymentMethods_Cls controller = new Communities_BrokeragePaymentMethods_Cls();
        controller.initHPM();
        controller.clearDefaultPaymentMethod();
        controller.updateACHPaymentMethod();
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod();    
    }
    
    private Static void generateTestData(String ofiiceName){
        generateCornerstone();             
        createAccount('Residential',ofiiceName, 'Broker Office');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        createRelationship(account.Id, subscription.Id, 'Broker Of Record');
    }
    
    private static void createAccount(String type,String name, string companyType ){
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
        account.Company_Type__c = companyType;
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
    
    private static void createRelationship(string accountId, string subscriptionId, string relationType){
        
        relationship = new Relationship__c();
        relationship.Subscription__c = subscriptionId;
        relationship.Broker_Office__c = accountId;
        relationship.Relationship_Type__c = relationType;
        relationship.Relationship_End_Date__c = system.today().addDays(2);
        insert relationship;
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}