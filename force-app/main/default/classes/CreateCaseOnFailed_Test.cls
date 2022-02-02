@isTest
private class CreateCaseOnFailed_Test {
  
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription; 
    
    private static testMethod void doTestOne() {            
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription;
        
        CreateCaseOnFailed_New.createCase(account);
        CreateCaseOnFailed_New.createCaseForSub(subscription);
        //CreateCaseOnFailed_New.

    } 
    
     private static void createAccount(String type,String name){
        account = new Account();
        account.name = name;
        account.type = type;
        account.Account_Name__c = 'Test Account';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
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
        subscription.Name = 'Test Subscription';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.name = '123111';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.County__c = 'Fairfax';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Addl_Display_Name__c = 'Test';
        subscription.QAS_Mailing_Country__c = 'USA';
        subscription.QAS_Mailing_County__c = 'Fairfax';
        subscription.State__c = 'VA';
        subscription.QAS_Mailing_Street_Direction__c = 'NORTH';
        subscription.Street_Name__c = 'First';
        subscription.Street_Number__c ='1275';
        subscription.Street_Number_Suffix__c = NULL;
        subscription.Unit__c = '1';
        subscription.QAS_Mailing_Unit_Type__c = 'SU';
        subscription.Zip__c ='20002';
        subscription.Zip_4__c = NULL;
        subscription.QAS_Mailing_POBox__c = NULL;
        subscription.QAS_Mailing_Record_Type__c = NULL;
        subscription.Copy_Address_to_Billing__c = true;
        subscription.QAS_Mailing_Record_Type__c = 'P';
        subscription.QAS_Billing_Record_Type__c = 'P';
        subscription.Primary__c = true;
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }                 
}