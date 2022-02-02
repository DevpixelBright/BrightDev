@isTest(seeAlldata = true)
private class PROV_SphereOffice_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Relationship__c borRelationship;  
    private static SMS_Provisioned_Product__c provisionProduct;  
    
    
    private static testMethod void doTestSphereOfficeOne(){       
        generateTestData('121136084063');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'SOAPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
        
        //PROV_SphereOfficeDirect.provisionSphereOffice(provisionProduct);                                    
    } 
    
    private static testMethod void doTestSphereOfficeTwo(){         
        generateTestData('121136084063');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'New', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
    private static testMethod void doTestSphereOfficeThree(){
        generateTestData('121136084063');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'Reinstate', 'Pending Deprovisioned');
        system.debug('---provisionProduct-->'+provisionProduct);
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError'; 
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
     private static testMethod void doTestSphereOfficeFour(){ 
        generateTestData('121136084063');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'Reinstate', 'Pending Deprovisioned');
        system.debug('---provisionProduct-->'+provisionProduct);
        PROV_MockDataGenerator.isSuccess = true;
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
    private static testMethod void doTestSphereOfficeFive(){         
        generateTestData('');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'Terminate', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
    private static testMethod void doTestSphereOfficeSix(){
        generateTestData('');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'Terminate', 'Pending Deprovisioned');
        system.debug('---provisionProduct-->'+provisionProduct);
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError'; 
        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
     private static testMethod void doTestSphereOfficeSeven(){
        generateTestData('');
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere Office by Bright MLS', 'Sphere Office by Bright MLS', 'Reinstate', 'Pending Deprovisioned');
        system.debug('---provisionProduct-->'+provisionProduct);
        PROV_MockDataGenerator.isSuccess = true;
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);         
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
    }
    
    private static void generateTestData(string brightkey) {
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id, brightkey);
        
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
    
    private Static void createSubscription(String accountId, String contactId,string brightkey){
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
        Subscription.BRIGHT_Agent_Key__c = brightkey;
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
        provisionProduct.RealPing_Id__c = '20586';
        insert provisionProduct;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility(); 
        cau.addAddrs();  
    }
    
    private Static void subscriptionRelationship(String subName) {
        borRelationship = new Relationship__c();
        borRelationship.Relationship_Type__c = 'Broker Of Record';
        borRelationship.Subscription__c= subName;
        insert borRelationship;
    }
  
}