@istest(seealldata = true)
private class SMS_WebServices_GetZuoraRatePlans_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static SMS_Provisioned_Product__c provisionProduct;  

    private static testMethod void doTestOne(){       
        generateTestData();
        SMS_WebServices_GetZuoraRatePlans.InputData obj = new SMS_WebServices_GetZuoraRatePlans.InputData();
        SMS_WebServices_GetZuoraRatePlans.GetZuoraRatePlans(obj);
        
        obj.ZuoraProductId = '234324dfsdf34534545';
        obj.MRISSubscriptionId = '354354';
        SMS_WebServices_GetZuoraRatePlans.GetZuoraRatePlans(obj);            
        
        obj.ZuoraProductId = '234324dfsdf34534545';
        obj.MRISSubscriptionId = subscription.Name;       
        SMS_WebServices_GetZuoraRatePlans.GetZuoraRatePlans(obj);                                  
    } 
    
    private static testMethod void doTestTwo(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'MRIS Xactsite Agent', 'Xactsite Select', 'New', 'Pending Provisioned'); 
        provisionProduct.Provisioned_Status__c = 'Provisioned';
        provisionProduct.Product_Status_Reason__c = 'Staff Order';
        update provisionProduct; 
        
        SMS_WebServices_GetZuoraRatePlans.InputData obj = new SMS_WebServices_GetZuoraRatePlans.InputData();
        obj.ZuoraProductId = '234324dfsdf34534545';
        obj.MRISSubscriptionId = subscription.Name;
        
        SMS_WebServices_GetZuoraRatePlans.GetZuoraRatePlans(obj);                                  
    } 
    
    /*
    private static testMethod void doTestThree(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'MRIS Xactsite Agent', 'Xactsite Select', 'New', 'Pending Provisioned'); 
        
        SMS_Provisioned_Product_History__c provisionProductHistory = new SMS_Provisioned_Product_History__c();
        provisionProductHistory.MRIS_Subscription_Id__c = subscription.Name;
        provisionProductHistory.Provisioned_Product_Id__c = provisionProduct.Id;
        provisionProductHistory.Product_Type__c = 'MRIS Xactsite Agent';
        provisionProductHistory.Product_Sub_Type__c = 'Xactsite Select';
        provisionProductHistory.Product_Status__c = 'New';
        provisionProductHistory.Provisioned_Status__c = 'Pending Provisioned';
        provisionProductHistory.RealPing_Id__c = '20586';
        provisionProductHistory.Product_Status_Reason__c = 'Staff Order';
        insert provisionProductHistory;
        
        SMS_WebServices_GetZuoraRatePlans.InputData obj = new SMS_WebServices_GetZuoraRatePlans.InputData();
        obj.ZuoraProductId = '234324dfsdf34534545';
        obj.MRISSubscriptionId = subscription.Name;
        
        SMS_WebServices_GetZuoraRatePlans.GetZuoraRatePlans(obj);                                  
    }        
    */
    
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
        provisionProduct.RealPing_Id__c = '20586';
        insert provisionProduct;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }

}