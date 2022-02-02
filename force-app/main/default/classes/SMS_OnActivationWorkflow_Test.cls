@istest(SeeAllData = true)
private class SMS_OnActivationWorkflow_Test{
    /*
        Test Class to test SMS_OnActivationWorkflow.
        Assumptions:
        1. SMS Core Mapping object is populated.
        2. SMS Product Mapping object is populated.
        3. SMS Exclude Zuora Integration custom setting is populated.
        
    */
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
    private Static SMS_Provisioned_Product__c provisionedProduct;
    
    private static testMethod void doTestOne(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;
        
        sSubscriptionId = subs[0].Name;
        createBillingAccount();
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,false);             
    }
    
    private static testMethod void doTestTwo(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
         
        generateTestData(); 
              
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c  FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId = subs[0].Name;
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,false);             
    }   
    
    private static testMethod void doTestThree(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
         
        generateTestData(); 
              
        List<Subscriptions__c> subscriptionDetails = [
                        SELECT Name, Contact_Type__c, Subscription_Type__c, Date_Terminated__c,Primary__c, Contact__c
                        FROM   Subscriptions__c
                        WHERE  Contact__c = :contact.Id];
        String sSubscriptionId = subscriptionDetails[0].Name;
                
        //Determine Core Mapping Status
        String status = 'New';
        if (subscriptionDetails[0].Date_Terminated__c != null) {            
            if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) > 30)
                status = 'Reinstatement > 30';
            else if (subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today()))>= 0 && subscriptionDetails[0].Date_Terminated__c.daysBetween(date.valueof(Date.today())) <= 30)
                status = 'Reinstatement <= 30';
        }
        
        Boolean isPrimary = status == 'New'
        ? SMS_BadWorkflowMitigation.isPrimarySubscription(subscriptionDetails[0].Contact__c)
        : SMS_BadWorkflowMitigation_Temp.isPrimarySubscriptionReinstatement(subscriptionDetails[0].Contact__c, sSubscriptionId);
        
        List<SMS_CoreMapping__c> productRatePlans = [
                                SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c
                                FROM   SMS_CoreMapping__c
                                WHERE  Type__c = :subscriptionDetails[0].Contact_Type__c
                                AND    SubType__c = :subscriptionDetails[0].Subscription_Type__c
                                AND    Status__c = :status
                                AND    IsPrimaryFlag__c = :isPrimary];
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ProductRatePlanId', productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,false);             
    } 
    
    private static testMethod void doTestFour(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        SMS_ZuoraMockDataGenerator.isCore = 'false';
 
        generateTestData(); 
              
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c  FROM Subscriptions__c where Contact__c = :contact.Id];
        subs[0].Date_Terminated__c  = (System.Now().addDays(-45)).Date(); // reinstatement > 30 days
        update subs;
        String sSubscriptionId = subs[0].Name;
        createBillingAccount();
        createProvisionedProduct(sSubscriptionId);
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,true);             
    } 
    
    private static testMethod void doTestFive(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'false';
 
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c  FROM Subscriptions__c where Contact__c = :contact.Id];
        subs[0].Date_Terminated__c  = (System.Now().addDays(-2)).Date(); // reinstatement < 30 days
        update subs;
        String sSubscriptionId = subs[0].Name; 
        createBillingAccount();
        createProvisionedProduct(sSubscriptionId);       
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,true);                  
    } 
    
     private static testMethod void doTestSix(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'false';
 
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c  FROM Subscriptions__c where Contact__c = :contact.Id];
        subs[0].Date_Terminated__c  = (System.Now().addDays(-2)).Date(); // reinstatement < 30 days
        update subs;
        String sSubscriptionId = subs[0].Name; 
        createBillingAccount();
        createProvisionedProduct(sSubscriptionId);       
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,false);                  
    }
     private static testMethod void doTestSeven(){        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 2; 
        SMS_ZuoraMockDataGenerator.isCore = 'false';
 
        generateTestData();       
                    
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c  FROM Subscriptions__c where Contact__c = :contact.Id];
        subs[0].Date_Terminated__c  = (System.Now().addDays(-2)).Date(); // reinstatement < 30 days
        update subs;
        String sSubscriptionId = subs[0].Name; 
        createBillingAccount();
        createProvisionedProduct(sSubscriptionId);       
        SMS_OnActivationWorkflow.createSubscription(sSubscriptionId,false);                  
    }
    
    private Static void generateTestData(){
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
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
        //Subscriptions__c sSubscription = [SELECT Id, Name, SF_Subscription_ID__c FROM Subscriptions__c WHERE  id = :subscriptionId];
        //system.debug('*** Test Sub Id :' + sSubscription.Name);
        provisionedProduct = new SMS_Provisioned_Product__c();                           
        provisionedProduct.MRIS_Subscription_Id__c = subscriptionId;                            
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Provisioned_Status__c = 'Provisioned';
        
        insert provisionedProduct;                                
    }
}