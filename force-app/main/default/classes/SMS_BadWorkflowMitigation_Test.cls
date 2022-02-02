@isTest(SeeAllData = true)
private class SMS_BadWorkflowMitigation_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
    private Static SMS_Order__c order;
    
    private static testMethod void doTestOne(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        createOrder(subscription.Id); 
        
        Map<Id,string> oldSerializedSubscriptionsMap = new Map<Id,string>(); 
        oldSerializedSubscriptionsMap.put(subscription.id,JSON.serialize(subscription));
        Map<Id,string> newSerializedSubscriptionsMap = new Map<Id,string>();
        newSerializedSubscriptionsMap.put(subscription.id,JSON.serialize(subscription));
        
        SMS_BadWorkflowMitigation badWorkflow = new SMS_BadWorkflowMitigation();
        SMS_BadWorkflowMitigation.getAllSelectFieldsForSubscription();
        SMS_BadWorkflowMitigation.isPrimarySubscription(contact.Id);
        SMS_BadWorkflowMitigation.sendUpdatedSubscriptionToQueueProcessor(oldSerializedSubscriptionsMap,newSerializedSubscriptionsMap);
        SMS_BadWorkflowMitigation.updateStatusChangeFee(order.Id);
        
        SMS_BadWorkflowMitigation_Temp.isPrimarySubscriptionReinstatement(contact.id,subscription.Name);               
    } 
    
     
    
    private static void createOrder(String subscriptionId){
        order = new SMS_Order__c();
        order.Name = 'Order Id';
        order.Token__c = 'bqFyrhqraFfGAJ7dEY/atiM5RbV3fStmvjP00XKO6Oc=';
        order.Zuora_Account_Id__c = '2c92c0f9430459c20143070e03101551';
        order.MRIS_Subscription_Id__c = subscriptionId;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = true;
        order.Private_Email__c = ''; 
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
    
    private static void createBillingAccount(String accountId, String accountName, String subId) {
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subId;
        insert billingAccount; 
    } 
       public Class CustomException extends Exception {}   
}