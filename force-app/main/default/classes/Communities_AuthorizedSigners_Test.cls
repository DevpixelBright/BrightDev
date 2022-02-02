@isTest
public class Communities_AuthorizedSigners_Test {
    
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
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');      
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {    
             ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_AuthorizedSigners obj = new Communities_AuthorizedSigners();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewSigner();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_AuthorizedSigners.searchInput searchObj = new Communities_AuthorizedSigners.searchInput();
            searchObj.subscriberId = s1.Name;
            searchObj.firstName = 'Test Class'; 
            searchObj.lastName = 'Contact';
            searchObj.officeId = a1.Name;
            obj.search = searchObj;
            obj.getSearchResults();
            
            /* Select subscriber from search results */
            obj.subscriberSelected = s1.Id;
            obj.individualSelected();
            
            /* Selecting offices from list to assign authority */
            Set<String> offices = new Set<String>{a2.Id};
            obj.selectedOfficesStr = JSON.Serialize(offices);
            obj.assignAuthority();
            
            /* Review and saving the signers */
            obj.reviewChanges();
            obj.saveSigners();
        }        
    }
    private static testMethod void doTestTwo() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');      
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        ApexPages.currentPage().getParameters().put('subid',s1.Id);
            Test.setCurrentPage(ApexPages.currentPage());
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {  
             ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_AuthorizedSigners obj = new Communities_AuthorizedSigners();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewSigner();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_AuthorizedSigners.searchInput searchObj = new Communities_AuthorizedSigners.searchInput();
            searchObj.subscriberId = s1.Name;
            searchObj.firstName = 'Test Class'; 
            searchObj.lastName = 'Contact';
            searchObj.officeId = null;
            obj.search = searchObj;
            obj.getSearchResults();
            
            /* Select subscriber from search results */
             
           // obj.subscriberSelected = s1.Id;
            obj.individualSelected();
            
            /* Selecting offices from list to assign authority */
           // Set<String> offices = new Set<String>{a2.Id};
            Set<String> offices = new Set<String>{};
            obj.selectedOfficesStr = JSON.Serialize(offices);
            obj.assignAuthority();
            
            /* Review and saving the signers */
            obj.reviewChanges();
            obj.saveSigners();
        }        
    }
    private static testMethod void doTestThree() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Contact c2 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);  
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);  
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a2.Id, c2.Id, s1.Id, 'Broker Of Record');      
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        ApexPages.currentPage().getParameters().put('subid',s2.Id);
            Test.setCurrentPage(ApexPages.currentPage());
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {  
             ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
             Communities_AuthorizedSigners obj = new Communities_AuthorizedSigners();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewSigner();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_AuthorizedSigners.searchInput searchObj = new Communities_AuthorizedSigners.searchInput();
            searchObj.subscriberId = s1.Name;
            searchObj.firstName = 'Test Class'; 
            searchObj.lastName = 'Contact';
            searchObj.officeId = null;
            obj.search = searchObj;
            obj.getSearchResults();
            
            /* Select subscriber from search results */
             
            obj.subscriberSelected = s2.Id;
            obj.individualSelected();
            
            /* Selecting offices from list to assign authority */
            Set<String> offices = new Set<String>{a2.Id,a1.Id};
            obj.selectedOfficesStr = JSON.Serialize(offices);
            obj.assignAuthority();
            
            /* Review and saving the signers */
            obj.reviewChanges();
            obj.saveSigners();
        }        
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
    
    private Static License__c createLicense(String contactId, String licenseType) {
        License__c l = new License__c();
        l.Contact__c = contactId;
        l.Name = 'XYZ4534';
        l.License_State__c = 'VA';
        l.License_Type__c = licenseType;
        l.License_Expiration_Date__c = Date.today();
        insert l;
        
        return l;
    }
    
    private Static Related_Association__c createSubscriptionAssociation(String associationAccountId, String accountId, String subscriptionId) {
        Related_Association__c sa = new Related_Association__c();
        sa.Association__c = associationAccountId;
        sa.Broker_Code__c = accountId;
        sa.Subscription__c = subscriptionId;
        sa.Status__c = 'Active';
        sa.Start_Date__c = Date.today();
        sa.Primary__c = true;
        insert sa;
        
        return sa;
    }          
}