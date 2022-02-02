@isTest(SeeAllData = False)
public class Communities_ResponsibleBrokerTest {
    
    private static testMethod void doTestOne() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        License__c l = createLicense(c1.Id, 'Broker');
        Subscription_License__c sl1 = createSubLicense(s1.Id, l.Id);
        
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.searchBlockState = 'Completed';
        obj.addNewResponsibleBroker();
        obj.modifyResponsibleBroker();
        obj.individualSelected();
        obj.assignAuthority();
        obj.reviewChanges();
        obj.isEdit = false;
        Communities_ResponsibleBroker.officeRecord OfcRecord = new Communities_ResponsibleBroker.officeRecord();
        OfcRecord.check = true;
        OfcRecord.oAccount = a2;
        obj.lOffice.add(OfcRecord);
        obj.subscriberSelected = sl1.Id;
        obj.individualSelected();
        obj.saveSigners();
        
        obj.closeModal();
        obj.dummy();
        obj.accordian1();
        obj.accordian2();
        obj.accordian3();
        obj.accordian4();
        obj.accordian5();
        obj.termsCheck();

    }
    
    private static testMethod void doTestTwo() {
        generateData();
        Account a1 = createAccount('Residential','XYZ127');
        Account a2 = createAccount('Residential','XYZ128');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.subscriberSelected = s1.Name;
    }
    
    private static testMethod void doTestThree() {
        generateData();
        Account a1 = createAccount('Residential','XYZ129');
        Account a2 = createAccount('Residential','XYZ120');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.searchBlockState = 'Completed';
        obj.accordian2();
    }
    
    private static testMethod void doTestFour() {
        generateData();
        Account a1 = createAccount('Residential','XYZ121');
        Account a2 = createAccount('Residential','XYZ122');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.assignBlockState = 'Completed';
        obj.accordian3();
    }
    
    private static testMethod void doTestFive() {
        generateData();
        Account a1 = createAccount('Residential','XYZ121');
        Account a2 = createAccount('Residential','XYZ122');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.reviewBlockState = 'Completed';
        obj.accordian4();
    }
    
    private static testMethod void doTestSix() {
        generateData();
        Account a1 = createAccount('Residential','XYZ121');
        Account a2 = createAccount('Residential','XYZ122');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.termsBlockState = 'Completed';
        obj.accordian5();
    }
    
    private static testMethod void doTestSeven() {
        generateData();
        Account a1 = createAccount('Residential','XYZ122');
        Account a2 = createAccount('Residential','XYZ110');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_ResponsibleBroker obj = new Communities_ResponsibleBroker();
        obj.searchBlockState = 'Completed';
        obj.accordian1();
    }
    
    private static testMethod void doTestEight() {
        Subscription_License__c SubId = new Subscription_License__c();
        Communities_ResponsibleBroker.RBListview wrap = new Communities_ResponsibleBroker.RBListview(SubId);
        Relationship__c oRel = new Relationship__c();
        wrap.addRelation(oRel);
        wrap.addDecision(oRel);
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
        l.License_Type__c = 'Broker';
        l.License_Expiration_Date__c = Date.today();
        insert l;
        return l;
    } 
    
    private static Subscription_License__c createSubLicense(String subscriptionId, String license){
        Subscription_License__c subLicense = new Subscription_License__c();
        subLicense.Subscription__c = subscriptionId;
        subLicense.License__c = license;
        insert subLicense;
        return subLicense;
    }
}