@isTest(seealldata=true)
private class Communities_BillingInfo_Controller_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
    private Static Zuora__Subscription__c zuoraSubscription;
    private Static Zuora__SubscriptionProductCharge__c zuoraProductCharge;
    
    public static testMethod void doTestOne() {
        try {
            generateCornerstone();             
            createAccount('Residential','XYZ123');                  
            createContact(account.Id);                     
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription; 
            
            createBillingAccount();       
            createZuoraSubscription(billingAccount.Id);
            createZuoraProductCharge(account.Id, zuoraSubscription.Id);
            
            /* Visual force page reference */  
            PageReference pageRef = Page.Communities_SubscribedProducts;
            Test.setCurrentPage(pageRef);
            
            /* Set subscription id parameter */
            ApexPages.currentPage().getParameters().put('id', subscription.Name);
            ApexPages.currentPage().getParameters().put('sync', 'true');
            
            
            /* Controller intialisation calling methods */
            Communities_BillingInfo_Controller controller = new Communities_BillingInfo_Controller();
            controller.initBillingInfoPortal();
            controller.onDemandSync();
        }
        catch(Exception e) {
        
        }            
    }
    
    public static testMethod void doTestTwo() {
        try {
            generateCornerstone();             
            createAccount('Residential','XYZ123');                  
            createContact(account.Id);                     
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription; 
            
            /* Set subscription id parameter */
            ApexPages.currentPage().getParameters().put('id', subscription.Name);
            ApexPages.currentPage().getParameters().put('sync', 'true');
            
            
            /* Controller intialisation calling methods */
            Communities_BillingInfo_Controller controller = new Communities_BillingInfo_Controller();
            controller.initBillingInfoPortal();
            controller.onDemandSync();        
        }
        catch(Exception e) {
        
        }
    } 
    
    public static testMethod void doTestThree() {
        try {
            generateCornerstone();             
            createAccount('Residential','XYZ123');                  
            createContact(account.Id);                     
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription; 
    
            createBillingAccount();
            createZuoraSubscription(billingAccount.Id);  
            createZuoraProductCharge(account.Id, zuoraSubscription.Id);
            zuoraProductCharge.Zuora__RatePlanDescription__c = '#bundle';
            update zuoraProductCharge;
            
            /* Visual force page reference */  
            PageReference pageRef = Page.Communities_SubscribedProducts;
            Test.setCurrentPage(pageRef);
            
            /* Set subscription id parameter */
            ApexPages.currentPage().getParameters().put('id', subscription.Name);
            ApexPages.currentPage().getParameters().put('sync', 'true');
            
            
            /* Controller intialisation calling methods */
            Communities_BillingInfo_Controller controller = new Communities_BillingInfo_Controller();
            controller.initBillingInfoPortal();
            controller.onDemandSync();
        }
        catch(Exception e) {
        
        }           
    }
    
    public static testMethod void doTestFour() {
        try {
            generateCornerstone();             
            createAccount('Residential','XYZ123');                  
            createContact(account.Id);                     
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription; 
    
            createBillingAccount();
            createZuoraSubscription(billingAccount.Id);
            zuoraSubscription.Zuora__TermEndDate__c = (System.Now().addDays(-1)).Date();
            update zuoraSubscription;
            createZuoraProductCharge(account.Id, zuoraSubscription.Id);
            
            /* Visual force page reference */  
            PageReference pageRef = Page.Communities_SubscribedProducts;
            Test.setCurrentPage(pageRef);
            
            /* Set subscription id parameter */
            ApexPages.currentPage().getParameters().put('id', subscription.Name);
            ApexPages.currentPage().getParameters().put('sync', 'true');
            
            
            /* Controller intialisation calling methods */
            Communities_BillingInfo_Controller controller = new Communities_BillingInfo_Controller();
            controller.initBillingInfoPortal(); 
            
            zuoraSubscription.Zuora__TermEndDate__c = (System.Now().addDays(180)).Date();
            zuoraSubscription.Zuora__TermStartDate__c= (System.Now().addDays(1)).Date();
            zuoraSubscription.Zuora__AutoRenew__c = true;
            update zuoraSubscription; 
            
            controller.initBillingInfoPortal(); 
            List<Zuora__ZInvoice__c> zInvoices = controller.InvoiceList;
            List<Zuora__Payment__c> PaymentList = controller.PaymentList;
            List<Zuora__PaymentMethod__c> MethodList = controller.MethodList;
        }
        catch(Exception e) {
        
        }                        
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
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
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
        billingAccount.Zuora__Account__c = personAccount.Id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = sSubscription.Name;
        insert billingAccount; 
    }
    
    private static void createZuoraSubscription(String billingAccId) {
        zuoraSubscription = new Zuora__Subscription__c();
        zuoraSubscription.Name = 'A--S00011773';
        zuoraSubscription.Zuora__CustomerAccount__c = billingAccId;
        zuoraSubscription.IsCore__c = 'true';
        zuoraSubscription.Zuora__ContractEffectiveDate__c = (System.Now().addDays(-20)).Date();
        zuoraSubscription.Zuora__External_Id__c = '2cttttt9014425f6c6472c80';
        zuoraSubscription.Zuora__AutoRenew__c = false;
        zuoraSubscription.Zuora__InitialTerm__c = '12'; 
        zuoraSubscription.Zuora__RenewalTerm__c = '12';
        zuoraSubscription.Zuora__ServiceActivationDate__c = (System.Now().addDays(-20)).Date();
        zuoraSubscription.Zuora__Status__c = 'Active';
        zuoraSubscription.Zuora__SubscriptionStartDate__c = (System.Now().addDays(-20)).Date();
        zuoraSubscription.Zuora__SubscriptionEndDate__c = (System.Now().addDays(180)).Date(); 
        zuoraSubscription.Zuora__NextChargeDate__c  = (System.Now().addDays(180)).Date(); 
        zuoraSubscription.Zuora__NextRenewalDate__c = (System.Now().addDays(180)).Date(); 
        zuoraSubscription.Zuora__TermStartDate__c = (System.Now().addDays(-20)).Date();
        zuoraSubscription.Zuora__TermEndDate__c = (System.Now().addDays(180)).Date(); 
        zuoraSubscription.Zuora__MRR__c = 5.75; 
        zuoraSubscription.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80'; 
        insert zuoraSubscription;     
    } 
    
    private static void createZuoraProductCharge(String accId, String zuoraSubId) {
        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
        System.debug('### personAccount : '+ personAccount);
        zuoraProductCharge = new Zuora__SubscriptionProductCharge__c();
        zuoraProductCharge.Zuora__Account__c = personAccount.Id;
        zuoraProductCharge.Zuora__Type__c = 'Recurring';
        zuoraProductCharge.Zuora__Subscription__c = zuoraSubId;
        zuoraProductCharge.Name = 'Recurring Annual Fee';
        zuoraProductCharge.Zuora__BillingPeriodStartDay__c = '1st of the month';
        zuoraProductCharge.Zuora__BillingPeriod__c= 'Annual'; 
        zuoraProductCharge.Zuora__ChargeNumber__c = '123456';
        zuoraProductCharge.Zuora__Price__c = 5.65;
        zuoraProductCharge.Zuora__ProductDescription__c = 'Document signing system';
        zuoraProductCharge.Zuora__ProductEffectiveEndDate__c = (System.Now().addDays(1000)).Date();
        zuoraProductCharge.Zuora__ProductName__c = 'Non realtor shareholder'; 
        zuoraProductCharge.Zuora__ProductSKU__c = 'SKU-00000012'; 
        zuoraProductCharge.Zuora__Quantity__c = 1; 
        zuoraProductCharge.Zuora__RatePlanEffectiveEndDate__c = (System.Now().addDays(180)).Date();
        zuoraProductCharge.Zuora__RatePlanName__c = 'Annual'; 
        zuoraProductCharge.Zuora__TotalContractValue__c = 5.75; 
        zuoraProductCharge.Zuora__Type__c = 'Recurring';
        zuoraProductCharge.Zuora__Zuora_Id__c= '2cttttt9014425f6c6472c80'; 
        zuoraProductCharge.Zuora__EffectiveStartDate__c = (System.Now().addDays(-20)).Date();
        zuoraProductCharge.Zuora__EffectiveEndDate__c = (System.Now().addDays(180)).Date();
        

        insert zuoraProductCharge;     
    }             
    
}