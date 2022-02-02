@isTest(seealldata=true)
private class BillingInfoViaSubExtension_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;

    /* Scenario: Positive flow to test billing info details and Ondemand sync */
    private static testMethod void doTestOne(){
        
        /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);          
        
        List<Subscriptions__c> subscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];

        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
                    
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = personAccount.Id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subscriptions[0].Name;
        insert billingAccount;   
        
        Zuora__Subscription__c zSubscription = new Zuora__Subscription__c();  
        zSubscription.Name = 'Zuora Sub Name';
        zSubscription.Zuora__CustomerAccount__c = billingAccount.Id;
        zSubscription.Zuora__SubscriptionStartDate__c = (System.Now().addDays(-2)).Date();
        zSubscription.Zuora__ContractEffectiveDate__c = (System.Now().addDays(-2)).Date();
        zSubscription.Zuora__TermEndDate__c = (System.Now().addDays(28)).Date();
        zSubscription.Zuora__NextChargeDate__c = (System.Now().addDays(28)).Date();
        zSubscription.isCore__c = 'true';
        zSubscription.Zuora__AutoRenew__c = true;
        zSubscription.Zuora__NextRenewalDate__c = (System.Now().addDays(28)).Date();
        insert zSubscription;
        
        Zuora__SubscriptionProductCharge__c   subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c();
        subscriptionProductCharge.Name = 'Initial Fee';
        subscriptionProductCharge.Zuora__Zuora_Id__c = '2c92c0f844f280310144f8dd32d72314';
        subscriptionProductCharge.Private_Email__c = 'someone@test.com';
        subscriptionProductCharge.Zuora__Subscription__c = zSubscription.id;
        subscriptionProductCharge.Zuora__Type__c = 'Recurring';
        subscriptionProductCharge.Zuora__Account__c = personAccount.Id;
        subscriptionProductCharge.Zuora__ProductName__c = 'realPing';
        subscriptionProductCharge.Zuora__RatePlanName__c = 'Monthly';
        subscriptionProductCharge.Zuora__Price__c = 0;
        subscriptionProductCharge.Zuora__EffectiveStartDate__c = (System.Now().addDays(-2)).Date();
        insert subscriptionProductCharge;
        
        Zuora__PaymentMethod__c    paymentMethod = new  Zuora__PaymentMethod__c();
        paymentMethod.Name = 'a0WK00000023IYZ';
        paymentMethod.Zuora__BillingAccount__c = billingAccount.Id;
        paymentMethod.Private_Email__c = 'someone@test.com';
        insert paymentMethod;             
        
        /* Set controller for BillingInfoDetail */
        ApexPages.StandardController sc = new ApexPages.StandardController(subscription);
        BillingInfoViaSubExtension controller = new BillingInfoViaSubExtension(sc);
        
        PageReference pageRef = Page.BillingInfoDetail;
        pageRef.getParameters().put('id', subscriptions[0].id);
        Test.setCurrentPage(pageRef);

        List<BillingInfoViaSubExtension.SubSummary> SubSummaries = controller.Summaries;
        List<Zuora__ZInvoice__c> zInvoices = controller.InvoiceList;
        List<Zuora__Payment__c> zPayments = controller.PaymentList;
        List<Zuora__PaymentMethod__c> zPaymentMethods = controller.MethodList;      
        controller.onDemandSync();
        //controller.subscriptionOnDemandSync(subscriptions[0].Id);
    }
    
    /* Scenario: Test subscription Ondemand sync for the subscription not having already existing billing account */
    private static testMethod void doTestTwo(){
    
        /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);          
        
        List<Subscriptions__c> subscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];    
    
        /* Set controller for BillingInfoDetail */
        
        PageReference pageRef = Page.BillingInfoDetail;
        pageRef.getParameters().put('id', subscriptions[0].id);
        pageRef.getParameters().put('sync', 'true');
        Test.setCurrentPage(pageRef);        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(subscription);
        BillingInfoViaSubExtension controller = new BillingInfoViaSubExtension(sc);

        //controller.subscriptionOnDemandSync(subscriptions[0].Id);    
    }
    
    /* Scenario: Test billing info details page without person account */
    private static testMethod void doTestThree(){
    
        /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        List<Subscriptions__c> subscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];        
        
        Account acc = [select Id from Account where Contact__c = :contact.Id];
        
        delete acc;
        
        /* Set page reference */
        PageReference pageRef = Page.BillingInfoDetail;
        pageRef.getParameters().put('id', subscriptions[0].id);
        Test.setCurrentPage(pageRef);
        
        /* Set controller for BillingInfoDetail */
        ApexPages.StandardController sc = new ApexPages.StandardController(subscription);
        BillingInfoViaSubExtension controller = new BillingInfoViaSubExtension(sc); 
        List<BillingInfoViaSubExtension.SubSummary> SubSummaries = controller.Summaries;                 
    
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

        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
     
       
}