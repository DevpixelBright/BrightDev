@istest(SeeAllData = true)
private class SMS_TerminateProvisionedProduct_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static SMS_Provisioned_Product__c provisionedProduct;

    private static testMethod void doTestOne(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);  
        
        String zProductRatePlanId = '2cdft45236ehwrf3j2oi';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ProductRatePlanId', zProductRatePlanId);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;      
        createProvisionedProduct(subscription.Name,zProductRatePlanId); 
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_TerminateProvisionedProduct;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', provisionedProduct.Id);  
        SMS_TerminateProvisionedProduct controller = new SMS_TerminateProvisionedProduct();          
        controller.terminateProvisionedProduct();
    }
    
    private static testMethod void doTestTwo(){
        /* Create page reference */
        PageReference pageRef = Page.SMS_TerminateProvisionedProduct;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', '');  
        SMS_TerminateProvisionedProduct controller = new SMS_TerminateProvisionedProduct();          
        controller.terminateProvisionedProduct();    
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
        
    private Static void createProvisionedProduct(String subscriptionId, String zProductRatePlanId){
        provisionedProduct = new SMS_Provisioned_Product__c();                           
        provisionedProduct.MRIS_Subscription_Id__c = subscriptionId;                            
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Provisioned_Status__c = 'Provisioned';
        provisionedProduct.Zuora_Product_Rate_Plan_Id__c = zProductRatePlanId;
        insert provisionedProduct;                       
    }
}