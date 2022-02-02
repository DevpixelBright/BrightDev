@istest(seealldata = true)
private class LMS_CornerStoneOnDemand_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount; 
    private static Related_Association__c association;
    private static Relationship__c relaion;   
    
    private static testMethod void doTestOne(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = false;
        LMS_MockDataGenerator.errorType = 'HTTPError';
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);  
                               
    } 
    
    private static testMethod void doTestTwo(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = false;
        LMS_MockDataGenerator.errorType = 'ServiceError';
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);                                 
    } 
    
    private static testMethod void doTestThree(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = false;
        LMS_MockDataGenerator.errorType = 'EmptyResponse';
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);                                 
    } 
    
    private static testMethod void doTestFour(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = 'GetUserNotExists';
        LMS_MockDataGenerator.methodName = 'Added';
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);                                 
    } 
    
    private static testMethod void doTestFive(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = 'GetUserNotExists';
        LMS_MockDataGenerator.methodName = 'Error';
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);
        LMS_CornerStoneOnDemand.updateUser(subscription.Id);                                  
    } 
    
    private static testMethod void doTestSix(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);
        LMS_CornerStoneOnDemand.updateUser(subscription.Id);                                  
    }  
    private static testMethod void doTestSeven(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Error';
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_CornerStoneOnDemand.insertUser(subscription.Id);
        LMS_CornerStoneOnDemand.updateUser(subscription.Id);                                  
    } 
    
    private static testMethod void doTestEight(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionAssociation(subscription.Id);
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = false;
        LMS_MockDataGenerator.errorType = 'HTTPError';
        LMS_CornerStoneOnDemand.updateAssociation(association.Id);                              
    }              
    
    private static testMethod void doTestNine(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionAssociation(subscription.Id);
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_CornerStoneOnDemand.updateAssociation(association.Id);                              
    } 
    
   private static testMethod void doTestTen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionAssociation(subscription.Id);
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Error';
        LMS_CornerStoneOnDemand.updateAssociation(association.Id);                              
    } 
    
   private static testMethod void doTestEleven(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionAssociation(subscription.Id);
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Added';
        LMS_CornerStoneOnDemand.updateAssociation(association.Id);                              
    }         

    private static testMethod void doTestTwelve(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = false;
        LMS_MockDataGenerator.errorType = 'HTTPError';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    }
    
    private static testMethod void doTestThirteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    } 
    
    private static testMethod void doTestFourteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Error';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    } 
    
    private static testMethod void doTestFifteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Added';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    }
    
    private static testMethod void doTestSixteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Office Manager');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Added';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    }
    
    
    private static testMethod void doTestSeventeen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record - Branch Office');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    }
    
    private static testMethod void doTestEightteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Authorized Signer');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
    } 
    
    private static testMethod void doTestNineteen(){
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Authorized Signer1');
        
        LMS_MockDataGenerator.subscriptionName = subscription.Name;
        LMS_MockDataGenerator.isSuccess = true;
        LMS_MockDataGenerator.errorType = '';
        LMS_MockDataGenerator.methodName = 'Updated';
        LMS_CornerStoneOnDemand.updateRelationship(relaion.Id);                              
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
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '';
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
    
    private static void subscriptionAssociation(String subName) {
       
        association = new Related_Association__c();
        association.Status__c = 'Active';
        association.Subscription__c= subName;
        insert association;

    } 
    
    private Static void subscriptionRelationship(String subName, String relationType) {
        relaion = new Relationship__c();
        relaion.Relationship_Type__c = relationType;
        relaion.Subscription__c= subName;
        relaion.Status__c = 'Active';
        insert relaion;
    }        
}