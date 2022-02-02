@istest(SeeAllData = true)
private class BuyPremiumProductControllerTest {
private Static Account account;
    public static String zAccId {get;set;}
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Relationship__c relationship;
    
     private static testMethod void doTestOne(){
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
                
        subscription.Status__c = 'Active';
        update subscription;  
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'CloudCMA');
        preDefinedValues.put('ChargeType', 'OneTime');
        preDefinedValues.put('Id', '2ed984orkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        /* Create page reference */
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);
         ApexPages.currentPage().getParameters().put('productType', 'CloudCMA');
        //ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        BuyPremiumProductController controller = new BuyPremiumProductController();  
       BuyPremiumProductController c2 = new BuyPremiumProductController();
        c2.productType = '';
        c2.zProductId = '';
         createCC_CloudCMA();
         createCC_Authentisign();
         createCC_SocialPro();
         createCC_Default();
        BuyPremiumProductController.termsConditionsCloudCMA();
         BuyPremiumProductController.termsConditionsAuthentisign();
         BuyPremiumProductController.termsConditionsSocialPro();
         BuyPremiumProductController.termsConditionsDefault();
    }
    
    private static testMethod void doTestTwo(){
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
                
        subscription.Status__c = 'Active';
        update subscription;  
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'CloudCMA');
        preDefinedValues.put('ChargeType', 'OneTime');
        preDefinedValues.put('Id', '2ed984orkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        /* Create page reference */
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);
         ApexPages.currentPage().getParameters().put('productType', 'CloudCMA');
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        BuyPremiumProductController controller = new BuyPremiumProductController();  
        BuyPremiumProductController c2 = new BuyPremiumProductController();
        c2.productType = 'CloudCMA';
        c2.zProductId = '2mnsklfj728496fe';
       /* SMS_Premium_Products__c premiumProducts = new SMS_Premium_Products__c();
        premiumProducts.Name = 'CloudCMA';
        premiumProducts.Product_ID__c = 'CloudCMA';
        insert premiumProducts;*/
        SMS_Premium_Products__c premiumProducts = [SELECT Id, Name, Product_ID__c 
                           FROM   SMS_Premium_Products__c 
                           WHERE  Name = 'CloudCMA' limit 1];
        premiumProducts.Product_ID__c = 'CloudCMA';
        update premiumProducts;
        Subscriptions__c sub = [select id, Name from Subscriptions__c limit 1];
        BuyPremiumProductController.getExistingProduct(c2.productType, sub.Name);
        BuyPremiumProductController.populateProductRatePlans(sub.Name, premiumProducts.Product_ID__c);
        BuyPremiumProductController.orderConfirm(c2.productType, 'CloudCMA + Homebeat Monthly', sub.Name, '');
        createCC_CloudCMA();
         createCC_Authentisign();
         createCC_SocialPro();
         createCC_Default();
        BuyPremiumProductController.termsConditionsCloudCMA();
         BuyPremiumProductController.termsConditionsAuthentisign();
         BuyPremiumProductController.termsConditionsSocialPro();
         BuyPremiumProductController.termsConditionsDefault();
        Boolean createOrder = true;
        DateTime effectiveDate = System.Now();
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
         String accountQuery = 'SELECT Id,Name FROM Account WHERE ';
        accountQuery += ' AccountNumber = \'' +subscription.Id + '\'';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        SMS_Order__c order = new SMS_Order__c();                
            order.Name = 'Order Id';
            order.Token__c = '';
            order.Zuora_Account_Id__c = zAccId;
            order.MRIS_Subscription_Id__c = subscription.Id;
            order.Status__c = 'Active';
            order.Bypass_Payment__c = false;
            
            insert order;
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
        //account.Primary_Service_Jurisdiction__c = 'BRIGHT';
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
        
        subscription.Service_Jurisdiction__c = ' MRIS';
   
         insert subscription; 
        
    }
    private static void createCC_CloudCMA(){
       List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Cloud CMA' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTC 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Cloud CMA';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
private static void createCC_SocialPro(){
   List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Socialpro' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTCSocialPro 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Socialpro';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
    private static void createCC_Authentisign(){
       List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Authentisign' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTCAuthentisign 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Authentisign';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
    private static void createCC_Default(){
       List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Default' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTCDefault 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Default';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }

}