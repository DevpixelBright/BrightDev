@isTest(SeeAllData = true)
private class SMS_PaymentMethodNotification_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;

    public static testMethod void doTestOne() {
                         
        
        Profile p = [SELECT Id FROM Profile WHERE Name='API']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testapi@testorg.com');

        System.runAs(u) {
             generateData();             
             createAccount('Residential','XYZ123');            
             createContact(account.Id);             
             createSubscription(account.Id, contact.Id);
             
             subscription.Related_Location_Broker_Office__c = account.Id; 
             update subscription;
            
             subscription.Status__c = 'Active';
             update subscription; 
             
             Subscriptions__c sfSubscription = [ 
             SELECT Id, Name  
             FROM   Subscriptions__c
             WHERE  Contact__c = :contact.id];             
             
             billingAccount = new Zuora__CustomerAccount__c();
             billingAccount.Zuora__Account__c = account.id;
             billingAccount.Name = account.Name;
             billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
             billingAccount.SubscriptionID__c  = sfSubscription.Name;
             insert billingAccount;               
        
             Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
             paymentMethod.Zuora__BillingAccount__c = billingAccount.Id;
             paymentMethod.Zuora__Type__c = 'CreditCard';
             insert paymentMethod;                
             
             delete paymentMethod;
        }
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
        subscription.Private_Email__c = 'test@test.com';
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
     
}