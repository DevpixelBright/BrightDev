@isTest
private class SFQPConnectorUtility_UnitTest {
  
    private static testMethod void testSFQPConnectorUtility() {
    
        List<Account> accounts = new  List<Account>();
        List<Contact> contacts = new  List<Contact>();
        List<Subscriptions__c> subscriptions = new  List<Subscriptions__c>();
        List<Relationship__c> relationships = new  List<Relationship__c>();
        
        generateData(); 
        
        Account mainAccount = createAccount('Residential','XYZ123');       
        Account associationAccount = createAccount('Association','XYZ124'); 
        
        accounts.add(mainAccount);
        accounts.add(associationAccount);
        
        insert accounts;            
        
        Contact contact = createContact(associationAccount.Id);        
        contacts.add(contact);
        
        insert contacts;
        
        Subscriptions__c subscription =  createSubscription(associationAccount.Id, contact.Id);
        
        subscriptions.add(subscription);
        
        insert subscriptions;
        
        Relationship__c relationship = new Relationship__c();
        relationship.Relationship_Type__c = 'Corporate';
        relationship.Related_Account__c = mainAccount.Id;
        relationship.MDS_Status__c = 'Success';
        relationship.Broker_Office__c = mainAccount.Id;
        relationship.Subscription__c = subscription.Id;
        insert relationship;
        
        Related_Association__c subAssociation = new Related_Association__c();
        subAssociation.Broker_Code__c = mainAccount.Id;
        subAssociation.Primary__c = true;
        subAssociation.Association__c = associationAccount.Id;   
        subAssociation.Status__c = 'Active'; 
        subAssociation.Subscription__c = subscription.Id;                 
        insert subAssociation;
        
        Subscription_Role__c subscriptionRole = new Subscription_Role__c ();
        subscriptionRole.Role__c = 'Applied Video';
        subscriptionRole.Status__c = 'Active';
        subscriptionRole.sysPrRoleKey__c = '89752575777';
        subscriptionRole.Subscription__c = subscription.id;
        subscriptionRole.Role__c = 'Status Duplicate';
        insert subscriptionRole;
        
        List<SFQPConnector__c> SFQPConnectors = new  List<SFQPConnector__c>();
        
        SFQPConnectors.add(createSFQPConnector('Account', associationAccount.Id, 'SFMessageIdOne'));
        SFQPConnectors.add(createSFQPConnector('AccountType', subscriptionRole.Id, 'SFMessageIdTwo'));
        SFQPConnectors.add(createSFQPConnector('AccountCompanyType', mainAccount.Id, 'SFMessageIdThree'));
        SFQPConnectors.add(createSFQPConnector('AccountRole', mainAccount.Id, 'SFMessageIdFour'));
        SFQPConnectors.add(createSFQPConnector('AccountStockholder', mainAccount.Id, 'SFMessageIdFive'));
        SFQPConnectors.add(createSFQPConnector('Relationship__c', relationship.Id, 'SFMessageIdSix'));
        SFQPConnectors.add(createSFQPConnector('Subscription', subscription.Id, 'SFMessageIdSeven'));
        SFQPConnectors.add(createSFQPConnector('Related_Association__c', subAssociation.Id, 'SFMessageIdEight'));
        SFQPConnectors.add(createSFQPConnector('Subscription_Role__c', subscriptionRole.Id, 'SFMessageIdNine'));
        
        insert SFQPConnectors;  
        
    }
    
    private static Account createAccount(String type,String name){
        Account account = new Account();
        account.name = name;
        account.type = type;
        account.Account_Name__c = 'Test Account';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.OfficeKey__c = '14523698';
        return account; 
    }
    
    private static Contact createContact(String accountId){
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
        return contact;  
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = 'Test Subscription';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription.Status__c = 'In Progress';
        //subscription.AgentKey__c = '125489';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
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
        subscription.MDS_Status__c = 'Success';
        subscription.Mobile_Phone__c = '(301) 838-7101';
        return subscription; 
    }
    
    private Static SFQPConnector__c  createSFQPConnector(String objectType, String relatedId, String SFMessageId) {
        SFQPConnector__c  SFQPConnector =  new SFQPConnector__c();
        SFQPConnector.MessageSent__c = 'MSTest Message';
        SFQPConnector.ObjectType__c = objectType;
        SFQPConnector.QPMessage__c = 'QPTest Message';
        SFQPConnector.QPStatus__c = 'Success';
        SFQPConnector.relatedid__c = relatedId;
        SFQPConnector.SFMessageID__c = SFMessageId;
        return SFQPConnector;
    }   
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    } 

}