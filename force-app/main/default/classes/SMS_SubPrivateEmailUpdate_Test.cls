@istest(SeeAllData=true)
public class SMS_SubPrivateEmailUpdate_Test {
    
    private static Account account;
    private static Contact contact;
    private static Subscriptions__c subscription;
    private static Zuora__CustomerAccount__c billingAccount;
    
    private static testMethod void Testone(){
        generateTestData();
        Subscriptions__c sSubscription = [SELECT Id, Name FROM Subscriptions__c WHERE Id = :Subscription.Id];
        SMS_SubPrivateEmailUpdate.updateContactEmail(sSubscription.Name);            
    }
    
    private static testMethod void TestTwo(){        
        generateTestData(); 
        Subscriptions__c sSubscription = [SELECT Id, Name FROM Subscriptions__c WHERE  id = :subscription.Id]; 
        createBillingAccount(); 
        SMS_SubPrivateEmailUpdate.updateContactEmail(sSubscription.Name);       
    }
    
    private Static void generateTestData(){
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id); 
    }
    
    private static void createAccount(String type, String name){
        account = new account();
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
    
    private static void createContact(String AccountId){
        contact = new contact();
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
    
    private static void createSubscription(String AccountId, String contactId){
        subscription = new Subscriptions__c();
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
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    }
    
    private static void createBillingAccount(){
        Account personAccount = [SELECT Id, Name from Account where Contact__c = :contact.id];
        
        Subscriptions__c sSubscription = [SELECT Id, Name from Subscriptions__c where id = :subscription.Id];
        
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = personAccount.id;
        billingAccount.Name = personAccount.Name;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = sSubscription.Name;
        insert billingAccount; 
    }
}