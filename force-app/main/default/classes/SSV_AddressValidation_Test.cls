@istest(seealldata = true)
public class SSV_AddressValidation_Test {
    
    private static testMethod void doTestOne() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'MRIS');
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'MRIS');       
        s1.Status__c = 'Active';
        update  s1;
        
          /* Visual force page reference */  
        PageReference pageRef = Page.SSV_AddressValidation;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.ID);
        SSV_AddressValidation ssvObj = new SSV_AddressValidation();
        ssvobj.useEnteredAddress();
        
    }
     private static testMethod void doTestTwo() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'MRIS');
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'MRIS');       
        s1.Status__c = 'Active';
        s1.City__c = 'FAIRFAX';
        update  s1;
        
          /* Visual force page reference */  
        PageReference pageRef = Page.SSV_AddressValidation;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.ID);
        SSV_AddressValidation ssvObj = new SSV_AddressValidation();
        ssvobj.saveAddress();
        
    }
    
private static Account createAccount(String type, String name, String jurisdiction) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId, String jurisdiction) {
        Contact contact = new Contact();
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
        contact.Service_Jurisdiction__c = jurisdiction;
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String jurisdiction) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Service_Jurisdiction__c = jurisdiction;
        //subscription.TREND_Login_Name__c = 'TREND002';    

        insert subscription; 
        
        return subscription;
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}