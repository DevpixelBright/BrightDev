@isTest(seealldata = true)
public class Communities_OfficeDetails_Test {
    
    private static testMethod void doTestOne() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');       
        License__c l = createLicense(c1.Id, 'Salesperson');   
        
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            String parentid = a1.Id;
           String result= Communities_OfficeDetails.attachFile(parentid,'','Test.js','javascript',bodyBlob.toString());
         List<Attachment> a = [Select Id, ContentType, Body, ParentId from Attachment where Id =: result];
         Blob newBody = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(a.get(0).Body) + bodyBlob.toString());
         String result2 =Communities_OfficeDetails.attachFile(parentid, a.get(0).Id,'','',bodyBlob.toString());
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {   
            ApexPages.currentPage().getParameters().put('sid', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeDetails obj = new Communities_OfficeDetails();
            obj.editContactInfo();
            obj.saveContactInfo();
            obj.cancelContactEdit();
            obj.editAddressInfo();
            obj.reloadAccount();
            
            obj.office.Account_Name__c = 'TEST';
            obj.office.Street_Number__c = '345';
            obj.office.Street_Name__c = 'Avenue';
            obj.office.QAS_Mailing_Street_Type__c = 'AVE';
            obj.office.Street_Number_Suffix__c = 'a';
            obj.office.QAS_Mailing_Street_Direction__c = 'NE';
            obj.office.QAS_Mailing_Unit_Type__c = 'AVE';
            obj.office.Unit__c = '3';
            obj.office.Addl_Display_Name__c = 'TEST';
            obj.office.Zip__c = '20110';
            obj.office.Zip_4__c = '20110';
            obj.office.City__c = 'MANASSAS';
            obj.office.State__c = 'VA';
            obj.office.QAS_Mailing_County__c = 'TEXAS';  
            obj.saveAddressInfo();
            obj.cancelAddressEdit();
            obj.saveTrendAccount();
            obj.saveTrendOrBrightAccount();
            obj.addressUpdated();
        }        
    }
    
    private static testMethod void doTestTwo() {
        /* Test scenario with Authorized Signer */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');       
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {   
            ApexPages.currentPage().getParameters().put('sid', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeDetails obj = new Communities_OfficeDetails();          
        }        
    }
    
    private static testMethod void doTestThree() {
        /* Test scenario with Office Manager */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Office Manager');       
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {  
            ApexPages.currentPage().getParameters().put('sid', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeDetails obj = new Communities_OfficeDetails();          
        }        
    } 
    
    private static testMethod void doTestFour() {
        Communities_OfficeDetails obj = new Communities_OfficeDetails(); 
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