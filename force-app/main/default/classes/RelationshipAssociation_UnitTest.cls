@isTest
private class RelationshipAssociation_UnitTest {
  
      static testMethod void doTestOne() {

        List<Account> accounts = new  List<Account>();
        List<Contact> contacts = new  List<Contact>();
        List<Subscriptions__c> subscriptions = new  List<Subscriptions__c>();
        List<Related_Association__c> relationships = new  List<Related_Association__c>();
        
        generateData(); 
        
        Account mainAccount = createAccount('Residential','XYZ123');       
        Account associationAccountOne = createAccount('Association','XYZ124'); 
        Account associationAccountTwo = createAccount('Association','XYZ125');
        Account associationAccountThree = createAccount('Association','XYZ126');
        associationAccountThree.Company_Type__c = 'Corporate Office';
        
        accounts.add(mainAccount);
        accounts.add(associationAccountOne);
        accounts.add(associationAccountTwo);
        accounts.add(associationAccountThree);
        
        insert accounts;            
        
        Contact mainContact = createContact(mainAccount.Id);
        Contact contactOne = createContact(associationAccountOne.Id);
        Contact contactTwo = createContact(associationAccountTwo.Id);
        
        contacts.add(mainContact);
        contacts.add(contactOne);
        contacts.add(contactTwo);
        
        insert contacts;
        
        Subscriptions__c mainSubscription =  createSubscription(mainAccount.Id, mainContact.Id, '145236');
        Subscriptions__c subscriptionOne =  createSubscription(associationAccountOne.Id, contactOne.Id, '145238');
        Subscriptions__c subscriptionTwo =  createSubscription(associationAccountTwo.Id, contactTwo.Id, '145237');
        
        subscriptions.add(mainSubscription);
        subscriptions.add(subscriptionOne);
        subscriptions.add(subscriptionTwo);
        
        insert subscriptions;  
        
        relationships.add(createRelationship(mainSubscription.Id, 'Agent', associationAccountOne.Id, mainAccount.Id));
        relationships.add(createRelationship(subscriptionOne.Id, 'Broker Office', associationAccountOne.Id, mainAccount.Id));
        relationships.add(createRelationship(subscriptionTwo.Id, 'Office Manager', associationAccountOne.Id, mainAccount.Id));
        relationships.add(createRelationship(mainSubscription.Id, 'Authorized Signer', associationAccountOne.Id, associationAccountTwo.Id));
        relationships.add(createRelationship(subscriptionOne.Id, 'Broker Of Record', associationAccountOne.Id, associationAccountTwo.Id));
        relationships.add(createRelationship(subscriptionTwo.Id, 'Agent', associationAccountOne.Id, associationAccountTwo.Id));
        relationships.add(createRelationship(mainSubscription.Id, 'Agent', associationAccountTwo.Id, associationAccountTwo.Id));
        relationships.add(createRelationship(subscriptionOne.Id, 'Broker Of Record', associationAccountThree.Id, associationAccountTwo.Id));
                                                                
        insert relationships;
   
        for(Related_Association__c rel : relationships) {
            rel.MDS_Status__c = 'Success';
            rel.Status__c= 'Inactive';
        }
        update relationships;     
  }
  
  private static Account createAccount(String type,String name){
        Account account = new Account();
        account.name = name;
        account.type = type;
        account.Account_Name__c = 'Test Account';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_County__c = 'FAIRFAX';
        account.County__c = 'FAIRFAX';
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
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String agentKey){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = 'Test Subscription';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.AgentKey__c = agentKey;
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
    
    private Static Related_Association__c createRelationship(String subscriptionId, String relationType, String brokerOfficeId, String relatedAccountId) {
        Related_Association__c relationship = new Related_Association__c();
        relationship.Association__c = brokerOfficeId;
        relationship.Broker_Code__c = relatedAccountId;
        relationship.Status__c = 'Active';
        relationship.MDS_Status__c  = 'Sent';
        relationship.Subscription__c = subscriptionId;
        return relationship;
    }   
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }                 

}