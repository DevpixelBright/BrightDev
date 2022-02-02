@istest(seealldata = true)
private class SMS_CloudCMA_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Relationship__c relaion;  
    private static SMS_Provisioned_Product__c provisionProduct;  
    
    
    private static testMethod void doTestOne() {       
        SMS_ZuoraMockDataGenerator.preDefinedValues = new Map<String, String>{'BillingPeriod'=>'Annual'};    
        generateTestData();
        
        SMS_CloudCMA_Free_Versions__c liteVersionSetting = new SMS_CloudCMA_Free_Versions__c();
        liteVersionSetting.Name = 'Month';
        insert liteVersionSetting;
        
        SMS_CloudCMA_MockDataGenerator.isSuccess = true;
        SMS_CloudCMA.findCloudCMAType(subscription.Id);                       
    }
    
    private static testMethod void doTestTwo() {       
        SMS_ZuoraMockDataGenerator.preDefinedValues = new Map<String, String>{'BillingPeriod'=>'Annual', 'ProductRatePlanId'=>'2c92c0f851b3afa80151c9b35fba1b70'};    
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'CloudCMA', 'CloudCMA 1 Year', 'New', 'Pending Provisioned'); 
        SMS_CloudCMA_MockDataGenerator.isSuccess = true;       
        SMS_CloudCMA.findCloudCMAType(subscription.Id); 
        SMS_CloudCMA.provisionCloudCMADirect(provisionProduct);                        
    } 
    
    private static testMethod void doTestThree() {       
        SMS_ZuoraMockDataGenerator.preDefinedValues = new Map<String, String>{'BillingPeriod'=>'Two Years', 'ProductRatePlanId'=>'2c92c0f851b3afa80151c9b35fba1b70'};    
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'CloudCMA', 'CloudCMA 1 Year', 'New', 'Pending Provisioned');
        provisionProduct.provisioned_status__c = 'Pending Deprovisioned'; 
        update provisionProduct; 
        SMS_CloudCMA_MockDataGenerator.isSuccess = true;       
        SMS_CloudCMA.findCloudCMAType(subscription.Id); 
        SMS_CloudCMA.provisionCloudCMADirect(provisionProduct);                        
    }
    
    private static testMethod void doTestFour() {       
        SMS_ZuoraMockDataGenerator.preDefinedValues = new Map<String, String>{'BillingPeriod'=>'Month', 'ProductRatePlanId'=>'2c92c0f851b3afa80151c9b35fba1b70'};    
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'CloudCMA', 'CloudCMA 1 Year', 'New', 'Pending Provisioned');
        provisionProduct.Zuora_Product_Rate_Plan_Id__c = ''; 
        update provisionProduct; 
        SMS_CloudCMA_MockDataGenerator.isSuccess = true;       
        SMS_CloudCMA.findCloudCMAType(subscription.Id); 
        SMS_CloudCMA.provisionCloudCMADirect(provisionProduct);                        
    }              
    
    private static void generateTestData() {
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;    
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
        account.Street_Type__c = 'ACRES, ACRES';
        account.Street_Number__c = '453';
        account.Street_Name__c = 'avenue';
        account.Street_Direction__c = 'W, WEST'; 
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
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test@test.com';
        subscription.Primary_Phone__c = '9999999999';

        insert subscription; 
    }
    
    private Static void createProvisionProduct(String subId, String subName, String product, String subType, String productStatus, String provStatus) {
        provisionProduct = new SMS_Provisioned_Product__c();
        provisionProduct.MRIS_Subscription_Id__c = subName;
        provisionProduct.Product_Type__c = product;
        provisionProduct.Product_Sub_Type__c = subType;
        provisionProduct.Product_Status__c = productStatus;
        provisionProduct.Provisioned_Status__c = provStatus;
        provisionProduct.Zuora_Product_Rate_Plan_Id__c = '2c92c0f851b3afa80151c9b35fba1b70';
        insert provisionProduct;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }     
}