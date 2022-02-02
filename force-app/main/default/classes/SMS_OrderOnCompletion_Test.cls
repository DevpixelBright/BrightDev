@isTest
private class SMS_OrderOnCompletion_Test
{
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static SMS_Order__c order;
    private Static SMS_OrderItem__c  orderItem;
    private Static SMS_Product_Mapping__c   productMapping;
    private Static SMS_Provisioned_Product__c  provisionedProduct;
    
    private static testMethod void doTestOne(){
    // Test One:  Scenario 
    // Test for behaviour of Class when No Provisioning is done
        generateData('MRIS');
        
        order.Status__c = 'Completed';   
        update order;       
        //SMS_OrderOnCompletion orderOnCompletion = new SMS_OrderOnCompletion (order.id);   
    }
    
    private static testMethod void doTestTwo(){         
    // *** WITH PROVISIONING ***  Same sub type not terminated
    
        generateData('MRIS');
        createProvisionedProduct();
        
        order.Status__c = 'Completed';   
        update order;       
        //SMS_OrderOnCompletion orderOnCompletion = new SMS_OrderOnCompletion (order.id);  
    }
    
    private static testMethod void doTestThree(){         
    // *** WITH PROVISIONING ***  Different sub type not terminated  
    
        generateData('MRIS');
        createProvisionedProduct(); 
         
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Product_Sub_Type__c = 'XactSite';
        update provisionedProduct;
        
        order.Status__c = 'Completed';   
        update order;       
        //SMS_OrderOnCompletion orderOnCompletion = new SMS_OrderOnCompletion (order.id);  
    
    }
    
    private static testMethod void doTestFour(){         
    // *** WITH PROVISIONING ***  Same sub type terminated
        
        generateData('MRIS');
        createProvisionedProduct(); 
        
        provisionedProduct.Product_Status__c = 'Terminate';
        provisionedProduct.Product_Sub_Type__c = 'XactSite Office';
        update provisionedProduct;
        
        order.Status__c = 'Completed';   
        update order;       
        //SMS_OrderOnCompletion orderOnCompletion = new SMS_OrderOnCompletion (order.id);    
    }
    
    private static testMethod void doTestFive(){         
    // *** WITH PROVISIONING ***  Different sub type terminated  
        
        generateData('MRIS');
        createProvisionedProduct();   
         
        provisionedProduct.Product_Status__c = 'Terminate';
        provisionedProduct.Product_Sub_Type__c = 'XactSite';  
        update provisionedProduct;
        
        order.Status__c = 'Completed';   
        update order;       
        //SMS_OrderOnCompletion orderOnCompletion = new SMS_OrderOnCompletion (order.id);  
    
    }
    
    private static testMethod void doTestSix(){         
    // *** Test method for apex triggers SMS_Provisioning_OnComplete,SMS_PremiumProductsReinstatement and SMS_CreateCaseonProvisioningFailure

        generateData('MRIS');
        createProvisionedProduct();   
         
        order.Status__c = 'New';
        update order;
        
        order.Status__c = 'Completed';
        order.IsEzJoinApplication__c = true;  
        update order; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='API']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testapi@testorg.com');

        System.runAs(u) {        
            createProvisionedProduct();           
            provisionedProduct.Provisioned_Status__c = 'Error Pending Provisioned';
            update provisionedProduct;        
        }              
    } 
    
    private static testMethod void doTestSeven(){
        /* Failure of provisionin due to duplicate values */
        generateData('MRIS');
        createProvisionedProduct();
        createProvisionedProduct();
        
        order.Status__c = 'Completed';   
        update order;  
    }   
     private static testMethod void doTestEight(){
       
        generateData('TREND');
        createProvisionedProduct();
              
        order.Status__c = 'Completed';   
        update order;  
    }
    private static testMethod void doTestNine(){
       
        generateData('BRIGHT');
        createProvisionedProduct();
              
        order.Status__c = 'Completed';   
        update order;  
    }
    private Static void generateData(String jurisdiction){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        account = new Account();
        account.name = 'ADA1234';
        account.type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        insert account;
        
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.Service_Jurisdiction__c = jurisdiction;
        insert contact;
        
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
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Service_Jurisdiction__c = jurisdiction;
        subscription.TREND_Login_Name__c = 'TREND002';
        insert subscription;
        
        order = new SMS_Order__c();
        order.Name = 'Order Id';
        order.Token__c = '';
        order.Zuora_Account_Id__c = '2c92c0f9430459c20143070e03101551';
        order.MRIS_Subscription_Id__c = subscription.id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = true;
        order.Private_Email__c = ''; 
        insert order; 
        
        orderItem = new SMS_OrderItem__c();
        orderItem.Order_Id__c = order.Id;                  
        orderItem.Bundle_Id__c = '';
        orderItem.Bundle_Name__c = '';                                      
        orderItem.Zuora_Product_Id__c = '2c92c0f83fd52d73013fee5f3c343fac' ;
       // orderItem.Zuora_Product_Name__c = 'XactSite Office'; 
         orderItem.Zuora_Product_Name__c  = 'IDX Subscriber';
        orderItem.OneTimeProductRatePlanId__c = '';
       
        orderItem.OneTimeProductRatePlanName__c = '';   
        orderItem.RecurringProductRatePlanId__c = '2c92c0f83fd52d73013fee5f3ca73fbe';
       // orderItem.RecurringProductRatePlanName__c = '365+ Reinstatement'; 
        orderItem.RecurringProductRatePlanName__c = 'IDX Subscriber Monthly';
        orderItem.DiscountProductRatePlanId__c = '';
        orderItem.DiscountProductRatePlanName__c = '';    
        orderItem.TermDuration__c = 3;                              
        orderItem.IsCore__c = false; 
        insert orderItem;
        
        productMapping = new SMS_Product_Mapping__c();
        productMapping.Product_Sub_Type__c = 'XactSite Office';
        productMapping.Product_Type__c = 'XactSite Office';
        productMapping.Zuora_ProductRatePlan_Id__c = '2c92c0f83fd52d73013fee5f3ca73fbe';
        insert productMapping;    
    
    }
    
    private Static void createProvisionedProduct(){
        List<Subscriptions__c>  subscriptions = new List<Subscriptions__c>();
        subscriptions = [SELECT Name FROM Subscriptions__c ];
        
        provisionedProduct = new SMS_Provisioned_Product__c();     
        provisionedProduct.Authentisign_Id__c = '';
        provisionedProduct.Authentisign_User_Id__c = '';
        provisionedProduct.MRIS_Subscription_Id__c = subscriptions[0].Name;
        provisionedProduct.Order__c = order.Id;
        provisionedProduct.Previous_Provisioned_Status__c = '';
        provisionedProduct.Product_Status__c = 'New';
        provisionedProduct.Product_Sub_Type__c = 'XactSite Office';
        provisionedProduct.Product_Type__c = 'XactSite Office';
        provisionedProduct.Provisioned_Status__c = 'Pending Provisioned';
        provisionedProduct.Zuora_Product_Id__c = orderItem.Zuora_Product_Id__c;
        provisionedProduct.Zuora_Product_Rate_Plan_Id__c = orderItem.RecurringProductRatePlanId__c;    
        insert provisionedProduct ;    
    }
    
}