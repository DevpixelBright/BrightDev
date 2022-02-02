@isTest(SeeAllData = true)
public class Communities_W9Form_Controller_Test {
	    private static testMethod void doTestOne() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
                                                       
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) { 
            
        }        
    }
    
    private static testMethod void doTestTwo() {
        /* Test scenario with Authorized signer */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer'); 
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) { 
            
        }  
    } 
    
    private static testMethod void doTestThree() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        User communityUser = createCommunityUser(s1.Id);             
            Apexpages.currentpage().getparameters().put('id','s1.Id');
            Communities_W9Form_Controller obj = new Communities_W9Form_Controller();
            Subscriptions__c sub = [SELECT id, Name FROM Subscriptions__c WHERE Id =: s1.Id];
            Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer'); 
            obj.brokerSubmittedForms();
            Communities_W9Form_Controller.searchBrokerOffices('aaaaa');
            Communities_W9Form_Controller.saveIRSData(a1.Id,'abcd1234','12345');
            string Id = Communities_W9Form_Controller.attachFile(s1.Id, null, 'fileName', 'text', 'aaaaaaaaa');
          	Communities_W9Form_Controller.attachFile(s1.Id, Id, 'fileName', 'text', 'aaaaaaaaa');
            Communities_W9Form_Controller.viewIRSUploadedDoc(s1.Id);
    }   
    
	private static testMethod void doTestFour() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription1(a1.Id, c1.Id);       
    }
    
    private static testMethod void doTestFive() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription2(a1.Id, c1.Id);       
    }
    
    
    private static Account createAccount(String type, String name) {
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
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId) {
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
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId) {
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
        insert subscription; 
        
        return subscription;
    }
    
        private Static Subscriptions__c createSubscription1(String accountId, String contactId) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'Active';
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
            try{
                insert subscription; 
            }catch(exception e){
                system.debug('---exception--->'+e.getMessage());
            }
            
        return subscription;
    }
    
    private Static Subscriptions__c createSubscription2(String accountId, String contactId) {
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'Inactive';
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
        try{
        insert subscription; 
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
        return subscription;
            
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static User createCommunityUser(String subscriptionId) {
        Subscriptions__c sSubscription = [SELECT Id, 
                                                 Name, 
                                                 Public_Email__c, 
                                                 SF_Subscription_ID__c, 
                                                 AgentKey__c, 
                                                 Contact__c, 
                                                 Contact__r.FirstName,
                                                 Contact__r.LastName 
                                          FROM Subscriptions__c 
                                          WHERE  id = :subscriptionId];         
        
        User communityUser = new User();
        communityUser.username = sSubscription.AgentKey__c + 'test@test.com';
        communityUser.email = sSubscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = sSubscription.Contact__r.FirstName;
        communityUser.FirstName = sSubscription.Contact__r.LastName;
        communityUser.FederationIdentifier = sSubscription.Name;
        communityUser.Alias = (sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = sSubscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = sSubscription.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        return communityUser;   
    }
    
    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        insert r; 
        
        return r;
    }
    
    private Static Subscription_Role__c createSubscriptionRole(String subscriptionId){
    Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = subscriptionId;
        subRole.Role__c = 'Status Active';
        subRole.Status__c = 'Active';
        subRole.sysPrRoleKey__c = '';
        insert subRole;
        
        return subRole;
    }
}