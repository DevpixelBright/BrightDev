@istest(seealldata = true)
public class EBOSS_StaffOrder_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Relationship__c relationship;
    
    private static testMethod void doTestOne(){
        //SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        //SMS_ZuoraMockDataGenerator.isCore = 'false';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'Elevate BOSS Elite by Bright MLS');
        preDefinedValues.put('ProductRatePlanChargeId', '2ed984o3453453rkerlj');
        preDefinedValues.put('Id', '2ed984orkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        generateTestData();       
        
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;        
        sSubscriptionId = subs[0].Name;
        
        PageReference pageRef = Page.EBOSS_StaffOrder;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);  
        
        EBOSS_StaffOrder ebossOrder = new EBOSS_StaffOrder();
        ebossOrder.newProductOrder();
        ebossOrder.zRecurringProductRatePlanId = '2ed984orkerlj'; 
        try{
            ebossOrder.previewOrder();
        }
        catch(Exception e){
            
        }
        try{
            ebossOrder.confirmOrder(); 
        }
        catch(Exception e){
            
        }try{
            ebossOrder.terminateProductType = 'Elevate BOSS Elite by Bright MLS';
            ebossOrder.terminateProductOrder();        
            ebossOrder.terminateProduct();}
        catch(Exception e){
            
        }
        
    }
    
    private static testMethod void doTestTwo(){
        //SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        //SMS_ZuoraMockDataGenerator.isCore = 'false';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'Elevate Pro');
        preDefinedValues.put('ProductRatePlanChargeId', '2ed984o3453453rkerlj');
        preDefinedValues.put('Id', '2ed984o3453453rkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        generateTestData();       
        
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;        
        sSubscriptionId = subs[0].Name;
        
        List<Subscriptions__c> subscriptions = [SELECT id,Name,Contact__r.Name,
                                                Related_Location_Broker_Office__r.Name,
                                                Contact__c,
                                                Contact_Type__c,
                                                Subscription_Type__c,                             
                                                Private_Email__c
                                                FROM Subscriptions__c 
                                                WHERE Name = :sSubscriptionId 
                                                AND   Status__c = 'Active'
                                               ]; 
        subscription = subscriptions[0];
        EB_ProductOrder__c newOrder = new EB_ProductOrder__c();
        newOrder.ZRecurringRatePlanId__c = '2ed984orkerlj';
        newOrder.StartDate__c = System.today();
        newOrder.Quantity__c = 0;
        newOrder.ProductStatus__c = 'New';
        newOrder.Contact__c = subscription.Contact__c;
        newOrder.PrivateEmail__c = subscription.Private_Email__c;
        newOrder.ZOneTimeRatePlanId__c = 'zOneTimeProductRatePlanId';
        newOrder.Subscription__c = subscription.Id;
        newOrder.ProductType__c = 'Elevate BOSS by Bright MLS';
        
        insert neworder;
        
        newOrder = new EB_ProductOrder__c();
        newOrder.ZRecurringRatePlanId__c = '2ed984o3453453rkerlj';
        newOrder.StartDate__c = System.today();
        newOrder.Quantity__c = 5;
        newOrder.ProductStatus__c = 'New';
        newOrder.Contact__c = subscription.Contact__c;
        newOrder.PrivateEmail__c = subscription.Private_Email__c;
        newOrder.ZOneTimeRatePlanId__c = 'zOneTimeProductRatePlanId';
        newOrder.Subscription__c = subscription.Id;
        newOrder.ProductType__c = 'Elevate Pro';
        
        insert neworder;
        
        PageReference pageRef = Page.EBOSS_StaffOrder;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);  
        
        EBOSS_StaffOrder ebossOrder = new EBOSS_StaffOrder();
        
        ebossOrder.newProductOrder();
        ebossOrder.zRecurringProductRatePlanId = '2ed984orkerlj'; 
        try{
            ebossOrder.previewOrder();
        }
        catch(Exception e){
            
        }try{
            ebossOrder.confirmOrder();
        }
        catch(Exception e){
            
        }
        ebossOrder.updateProductType = 'Elevate Pro';
        ebossOrder.quantity = 15;
        ebossOrder.zRecurringProductRatePlanId = '2ed984o3453453rkerlj'; 
        ebossOrder.updateProductOrder();
        try{
            ebossOrder.previewOrder();
        }catch(Exception e){}
        try{
            ebossOrder.confirmOrder(); }catch(Exception e){}
        
        
    }
    
    private static testMethod void doTestThree(){
        //SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        //SMS_ZuoraMockDataGenerator.isCore = 'false';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'BOSS Agent DMS');
        preDefinedValues.put('ProductRatePlanChargeId', '2ed984o3453453rkerlj');
        preDefinedValues.put('Id', '2ed984o3453453rkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        generateTestData();       
        
        List<Subscriptions__c> subs = new List<Subscriptions__c>(); 
        subs = [SELECT id,Name,Date_Terminated__c FROM Subscriptions__c where Contact__c = :contact.Id];
        String sSubscriptionId;        
        sSubscriptionId = subs[0].Name;
        
        List<Subscriptions__c> subscriptions = [SELECT id,Name,Contact__r.Name,
                                                Related_Location_Broker_Office__r.Name,
                                                Contact__c,
                                                Contact_Type__c,
                                                Subscription_Type__c,                             
                                                Private_Email__c
                                                FROM Subscriptions__c 
                                                WHERE Name = :sSubscriptionId 
                                                AND   Status__c = 'Active'
                                               ]; 
        subscription = subscriptions[0];
        EB_ProductOrder__c newOrder = new EB_ProductOrder__c();
        newOrder.ZRecurringRatePlanId__c = '2ed984orkerlj';
        newOrder.StartDate__c = System.today();
        newOrder.Quantity__c = 0;
        newOrder.ProductStatus__c = 'New';
        newOrder.Contact__c = subscription.Contact__c;
        newOrder.PrivateEmail__c = subscription.Private_Email__c;
        newOrder.ZOneTimeRatePlanId__c = 'zOneTimeProductRatePlanId';
        newOrder.Subscription__c = subscription.Id;
        newOrder.ProductType__c = 'Elevate BOSS by Bright MLS';
        
        insert neworder;
        
        PageReference pageRef = Page.EBOSS_StaffOrder;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', sSubscriptionId);  
        
        EBOSS_StaffOrder ebossOrder = new EBOSS_StaffOrder();
        
        ebossOrder.newProductOrder();
        ebossOrder.zRecurringProductRatePlanId = '2ed984o3453453rkerlj'; 
        try{
            ebossOrder.previewOrder();
        }
        catch(Exception e){
            
        }
        ebossOrder.confirmOrder();
        
        ebossOrder.updateProductType = 'BOSS Agent DMS';
        ebossOrder.quantity = 15;
        ebossOrder.zRecurringProductRatePlanId = '2ed984o3453453rkerlj'; 
        ebossOrder.updateProductOrder();
        
        try{
            ebossOrder.confirmOrder();
            
            
            ebossOrder.terminateProductType = 'BOSS Agent DMS';
            ebossOrder.terminateProductOrder();        
            ebossOrder.terminateProduct();
        }
        catch(Exception e){}
        
    }
    
    private Static void generateTestData(){
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id); 
        
        subscription.Status__c = 'Active';
        update subscription;  
        
        createRelationship( account.Id, contact.Id, subscription.Id);
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
    
    private Static void createRelationship(String accountId, String contactId, String subscriptionId){
        relationship = new  Relationship__c();
        //realtionship.Name = '12345678';
        relationship.Contact__c = contact.id;
        relationship.Broker_Office__c = account.id;
        relationship.Relationship_Type__c = 'Broker of Record';
        relationship.Subscription__c = subscriptionId;
        insert relationship;
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}