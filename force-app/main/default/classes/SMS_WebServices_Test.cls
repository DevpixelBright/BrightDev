@istest(SeeAllData=true)
public class SMS_WebServices_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;

    public static testMethod void doTestOne() {
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);     
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];          
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c0f93fd531f1013ff29cc48a55e2');
        preDefinedValues.put('ProductId', '2c92c0f93fd531f1013ff29cc48a55e2');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;                
        
        SMS_WebServices.InputItem items = new SMS_WebServices.InputItem();
        items.BundleId = '';
        items.BundleName = '';
        items.ProductId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.OneTimeProductRatePlanId = '';
        items.RecurringProductRatePlanId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.DiscountProductRatePlanId = '';
        items.TermDuration = 12;
        items.IsCore = true;
        
        List<SMS_WebServices.InputItem> itemsList = new List<SMS_WebServices.InputItem>();
        itemsList.add(items);
      
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        input.InputItems = itemsList;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);   
    
    }

    public static testMethod void doTestTwo() {
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);
    }
    
    public static testMethod void doTestThree() {
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);  
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];        
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c0f93fd531f1013ff29cc48a55e2');
        preDefinedValues.put('ProductId', '2c92c0f93fd531f1013ff29cc48a55e2');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;                
        
        SMS_WebServices.InputItem items = new SMS_WebServices.InputItem();
        items.BundleId = '';
        items.BundleName = '';
        items.ProductId = '';
        items.OneTimeProductRatePlanId = '';
        items.RecurringProductRatePlanId = '';
        items.DiscountProductRatePlanId = '';
        items.TermDuration = 12;
        items.IsCore = true;
        
        List<SMS_WebServices.InputItem> itemsList = new List<SMS_WebServices.InputItem>();
        itemsList.add(items);
      
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        input.InputItems = itemsList;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);      
    }
    
    public static testMethod void doTestFour() {
    
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];  
            
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c0f93fd531f1013ff29cc48a55e2');
        preDefinedValues.put('ProductId', '2c92c0f93fd531f1013ff29cc48a55e2');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;                
        
        SMS_WebServices.InputItem items = new SMS_WebServices.InputItem();
        items.BundleId = '';
        items.BundleName = '';
        items.ProductId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.OneTimeProductRatePlanId = '';
        items.RecurringProductRatePlanId = '';
        items.DiscountProductRatePlanId = '';
        items.TermDuration = 12;
        items.IsCore = true;
        
        List<SMS_WebServices.InputItem> itemsList = new List<SMS_WebServices.InputItem>();
        itemsList.add(items);
      
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        input.InputItems = itemsList;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);    
    } 
    
    public static testMethod void doTestFive() {
    
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);  
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];    
        
        SMS_ZuoraMockDataGenerator.emptyResult = true;
        
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);       
    }
    
    public static testMethod void doTestSix() {
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);  
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];        
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c0f93fd531f1013ff29cc48a55e2');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;                
        
        SMS_WebServices.InputItem items = new SMS_WebServices.InputItem();
        items.BundleId = '';
        items.BundleName = '';
        items.ProductId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.OneTimeProductRatePlanId = '';
        items.RecurringProductRatePlanId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.DiscountProductRatePlanId = '';
        items.TermDuration = 12;
        items.IsCore = true;
        
        List<SMS_WebServices.InputItem> itemsList = new List<SMS_WebServices.InputItem>();
        itemsList.add(items);
      
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        input.InputItems = itemsList;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);   
    
    } 
    
    public static testMethod void doTestSeven() {
    
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);  
        
        Subscriptions__c subscriptions = [SELECT Id,Name FROM   Subscriptions__c WHERE  Contact__c = :contact.id];    
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2c92c0f93fd531f1013ff29cc48a55e2');
        preDefinedValues.put('ProductId', '2c92c0f93fd531f1013ff29cc48a55e2');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;                
        
        SMS_WebServices.InputItem items = new SMS_WebServices.InputItem();
        items.BundleId = '';
        items.BundleName = '';
        items.ProductId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.OneTimeProductRatePlanId = '';
        items.RecurringProductRatePlanId = '';
        items.DiscountProductRatePlanId = '2c92c0f93fd531f1013ff29cc48a55e2';
        items.TermDuration = 12;
        items.IsCore = true;
        
        List<SMS_WebServices.InputItem> itemsList = new List<SMS_WebServices.InputItem>();
        itemsList.add(items);
      
        SMS_WebServices.InputData input = new SMS_WebServices.InputData();
        input.ZuoraAccountId = '2c92c0f841ba8ff60141c7888e5b68b4';
        input.MRISSubscriptionId = subscriptions.Name;
        input.StaffInitiate = false;
        input.InputItems = itemsList;
        
        SMS_WebServices.CreateGenericPaymentOrderResponse res = SMS_WebServices.CreateGenericPaymentOrder(input);   
    
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
        //subscription.Primary__c = true;
        insert subscription; 
    }    
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }              
}