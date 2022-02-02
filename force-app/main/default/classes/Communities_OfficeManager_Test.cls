@isTest(seeAllData=TRUE)
public class Communities_OfficeManager_Test {
    
    private static testMethod void doTestOne() {
        /* Test scenario with Broker of Record */
        Test.startTest();
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        rel.add(r1);
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');      
        rel.add(r2);
        insert rel;
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        // insert l;
        
        User communityUser = createCommunityUser(s1.Id);    
        System.RunAs(communityUser) {    
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeManager obj = new Communities_OfficeManager();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewManager();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_OfficeManager.searchInput searchObj = new Communities_OfficeManager.searchInput();
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
            obj.saveManagers();
            //setTemplateIds();
            //sendEmailToOfficeManager()
        } 
        Test.stopTest();
    }
    private static testMethod void doTestTwo() {
        /* Test scenario with Broker of Record */
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        rel.add(r1);
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Office Manager');      
        rel.add(r2);
        insert rel;     
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        ApexPages.currentPage().getParameters().put('subid',s1.Id);
        Test.setCurrentPage(ApexPages.currentPage());
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {  
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeManager obj = new Communities_OfficeManager();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewManager();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_OfficeManager.searchInput searchObj = new Communities_OfficeManager.searchInput();
            searchObj.subscriberId = s1.Name;
            searchObj.firstName = 'Test Class'; 
            searchObj.lastName = 'Contact';
            searchObj.officeId = null;
            obj.search = searchObj;
            obj.getSearchResults();
            
            
            
            /* Select subscriber from search results */
            
            // obj.subscriberSelected = s1.Id;
            // obj.individualSelected();
            
            /* Selecting offices from list to assign authority */
            // Set<String> offices = new Set<String>{a2.Id};
            Set<String> offices = new Set<String>{};
                obj.selectedOfficesStr = JSON.Serialize(offices);
            obj.assignAuthority();
            
            /* Review and saving the signers */
            obj.reviewChanges();
            
            Communities_OfficeManager.officeRecord record = new Communities_OfficeManager.officeRecord();
            record.status = 'New';
            record.id = '001ewrtertyetyu';
            record.officeId = a1.Id;
            record.name = 'test213'; 
            record.street = 'rockie';
            record.city = 'Huntingtown';
            record.state = 'MD';
            record.zip = '20639';
            record.signersCount = '2';
            record.signers = 'test';
            record.isChecked = true;
            obj.selectedoffices.add(record);
            obj.subscriberSelected = s1.Id;
            obj.individualSelected();
            obj.saveManagers();
        }        
    }
    private static testMethod void doTestThree() {
        try{
            test.startTest();
            generateData();
            List <Account> acc = new List <Account>();
            Account a1 = createAccount('Residential','XYZ124');
            acc.add(a1);
            Account a2 = createAccount('Residential','XYZ125');
            acc.add(a2);
            insert acc;
            List <Contact> con = new List <Contact>();
            Contact c1 = createContact(acc[0].Id);
            con.add(c1);
            Contact c2 = createContact(acc[1].Id); 
            con.add(c2);
            insert con;
            List<Subscriptions__c>subs= new List<Subscriptions__c>();
            Subscriptions__c s1 = createSubscription(acc[0].Id, con[0].Id);
            subs.add(s1);
            Subscriptions__c s2 = createSubscription(acc[1].Id, con[1].Id);
            subs.add(s2);
            subs[0].Status__c = 'Active';
            subs[1].Status__c = 'Active';
            update  subs;
            
            List <Relationship__c> rel = new List <Relationship__c>();
            Relationship__c r1 = createRelationship(acc[0].Id, con[0].Id, subs[0].Id, 'Broker Of Record'); 
            rel.add(r1);
            Relationship__c r2 = createRelationship(acc[1].Id, con[1].Id, subs[1].Id, 'Office Manager');   
            rel.add(r2);
            insert rel;
            List <License__c> lic = new List<License__c>();
            License__c l = createLicense(con[0].Id, 'Broker');   
            lic.add(l);
            ApexPages.currentPage().getParameters().put('subid',subs[1].Id);
            Test.setCurrentPage(ApexPages.currentPage());
            User communityUser = createCommunityUser(subs[0].Id);  
            
            System.RunAs(communityUser) {  
                ApexPages.currentPage().getParameters().put('id', subs[0].name);
                Test.setCurrentPage(ApexPages.currentPage());
                Communities_OfficeManager obj = new Communities_OfficeManager();
                obj.officeId = acc[0].Id;
                obj.accountDetails();
                obj.addNewManager();
                
                Communities_OfficeManager.searchInput searchObj = new Communities_OfficeManager.searchInput();
                searchObj.subscriberId = subs[0].Name;
                searchObj.firstName = 'Test Class'; 
                searchObj.lastName = 'Contact';
                searchObj.officeId = null;
                obj.search = searchObj;
                obj.getSearchResults();
                
                
                obj.subscriberSelected = subs[1].Id;
                obj.individualSelected();
                
                Set<String> offices = new Set<String>{acc[1].Id,acc[0].Id};
                    obj.selectedOfficesStr = JSON.Serialize(offices);
                obj.assignAuthority();
                
                obj.reviewChanges();
                obj.saveManagers();
                test.stopTest();
            } 
        }
        catch(exception e){
            system.debug('---exception--->'+e.getMessage());
        }
        
    }
    
    private static testMethod void doTest2() {
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(acc[0].Id, c1.Id, s1.Id, 'Broker Of Record'); 
        rel.add(r1);
        Relationship__c r2 = createRelationship(acc[1].Id, c1.Id, s1.Id, 'Authorized Signer');   
        rel.add(r2);
        insert rel;
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_OfficeManager obj = new Communities_OfficeManager();
        obj.searchBlockState = 'Completed';
        obj.accordian1();
        obj.closeModal();
        obj.accordian2();
        obj.accordian3();
        obj.accordian4();
        obj.accordian5();
        obj.termsCheck();
    }
    private static testMethod void doTest() {
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(acc[0].Id, c1.Id, s1.Id, 'Broker Of Record'); 
        rel.add(r1);
        Relationship__c r2 = createRelationship(acc[1].Id, c1.Id, s1.Id, 'Authorized Signer');   
        rel.add(r2);
        insert rel;
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_OfficeManager obj = new Communities_OfficeManager();
        obj.searchBlockState = 'Completed';
        obj.accordian2();
    }
    private static testMethod void doTestFour() {
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(acc[0].Id, c1.Id, s1.Id, 'Broker Of Record'); 
        rel.add(r1);
        Relationship__c r2 = createRelationship(acc[1].Id, c1.Id, s1.Id, 'Authorized Signer');   
        rel.add(r2);
        insert rel;
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_OfficeManager obj = new Communities_OfficeManager();
        obj.assignBlockState = 'Completed';
        obj.accordian3();
    }
    
    private static testMethod void doTestFive() {
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(acc[0].Id, c1.Id, s1.Id, 'Broker Of Record'); 
        rel.add(r1);
        Relationship__c r2 = createRelationship(acc[1].Id, c1.Id, s1.Id, 'Authorized Signer');   
        rel.add(r2);
        insert rel;
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_OfficeManager obj = new Communities_OfficeManager();
        obj.reviewBlockState = 'Completed';
        obj.accordian4();
    }
    
    private static testMethod void doTestSix() {
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(acc[0].Id, c1.Id, s1.Id, 'Broker Of Record'); 
        rel.add(r1);
        Relationship__c r2 = createRelationship(acc[1].Id, c1.Id, s1.Id, 'Authorized Signer');   
        rel.add(r2);
        insert rel;
        ApexPages.currentPage().getParameters().put('id', s1.name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_OfficeManager obj = new Communities_OfficeManager();
        obj.termsBlockState = 'Completed';
        obj.accordian5();
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
        //insert account; 
        
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
        //insert contact;
        
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
        subscription.Nickname__c = 'subtest';
        // insert subscription; 
        
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
        //  insert r; 
        
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
    private static testMethod void doTest11() {
        /* Test scenario with Broker of Record */
        Test.startTest();
        generateData();
        List <Account> acc = new List <Account>();
        Account a1 = createAccount('Residential','XYZ124');
        acc.add(a1);
        Account a2 = createAccount('Residential','XYZ125');
        acc.add(a2);
        insert acc;
        Contact c1 = createContact(a1.Id); 
        insert c1;
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);   
        insert s1;
        s1.Status__c = 'Active';
        update  s1;
        List <Relationship__c> rel = new List <Relationship__c>();
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        rel.add(r1);
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');      
        rel.add(r2);
        insert rel;
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        // insert l;
        
        User communityUser = createCommunityUser(s1.Id);    
        System.RunAs(communityUser) {    
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeManager obj = new Communities_OfficeManager();
            obj.officeId = a1.Id;
            obj.accountDetails();
            obj.addNewManager();
            
            /* Search for subscriber while adding new authorized signer */
            Communities_OfficeManager.searchInput searchObj = new Communities_OfficeManager.searchInput();
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
            obj.saveManagers();
            obj.setTemplateIds();
            //obj.sendEmailToOfficeManager(rel,'test@brightmls.com','','Test',s1,'');
        } 
        Test.stopTest();
    }
    private static testMethod void doTest12() {
        Communities_OfficeManager cm = new Communities_OfficeManager();
        cm.reviewChanges();
            cm.saveManagers();
            cm.setTemplateIds();
    }
    private static testMethod void doTest13() {
      
        Communities_OfficeManager cmm = new Communities_OfficeManager();
        cmm.test1();
        cmm.test2();
        cmm.test3();
    }
    
}