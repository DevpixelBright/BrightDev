@isTest
private class SMS_SendOutstandNotification_Test {
 private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static testMethod void doTestOne(){
        try {
        
   /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);          
        
        List<Subscriptions__c> subscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];
        subscriptions[0].Status__c = 'Active';
        update subscriptions[0];
        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
                    
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = personAccount.Id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subscriptions[0].Name;
        billingAccount.Zuora__Balance__c = 200;
        billingAccount.Email_Invoice_PDF__c = false;
        billingAccount.Oldest_Invoice_Due__c  = date.valueOf(system.today().addDays(-2)); 
        insert billingAccount;           
        
        SMS_SendOutstandNotification_Controller obj = new SMS_SendOutstandNotification_Controller();
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Balance__c > 0 LIMIT 2];
        List<String> billingAccountIds = new List<String>();
        //if(billingAccounts.Size() == 2)
            billingAccountIds = new List<String> {billingAccount.Id};
        
        obj.finalAccounts = JSON.serialize(billingAccountIds);
        obj.generateInvoicePdfs();
        }
        catch(Exception e) {}
    }
    
    private static testMethod void doTestTwo(){     
        try {
        
   /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);          
        
        List<Subscriptions__c> subscriptions = [SELECT Id, Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];

        Account personAccount = [SELECT id,Name FROM Account WHERE Contact__c = :contact.id];
                    
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = personAccount.Id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subscriptions[0].Name;
        insert billingAccount;           
        
        SMS_SendOutstandNotification_Controller obj = new SMS_SendOutstandNotification_Controller();
        List<String> billingAccountIds = new List<String>();
        obj.finalAccounts = JSON.serialize(billingAccountIds);
        obj.generateInvoicePdfs();
        }
        catch(Exception e) {}
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
      
}