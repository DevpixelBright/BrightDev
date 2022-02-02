@isTest
public class Communities_AgentTransferListing_Test {
    
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
        License__c l1 = createLicense(c1.Id, 'Salesperson');    
        MRIS_Application__c  application = createMRISApplication(a1, c1, l1, 'Agent Transfer', s1.Id);  
        MRIS_Application__c  application2 = createMRISApplication(a1, c1, l1, 'Agent Transfer', s1.Id);                                                
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) { 
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_AgentTransferListing obj = new Communities_AgentTransferListing();
            obj.applicationId = application.Id;
            obj.viewApplication(); 
            try{obj.approve();}
            catch(Exception e){}
            obj.applicationId = application2.Id;
            obj.viewApplication(); 
            try{obj.reject(); }
            catch(Exception e){}  
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
             ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_AgentTransferListing obj = new Communities_AgentTransferListing();
            obj.appId = '10';
            obj.agentName = 'test';
            obj.originationOffice = 'test';
            obj.destinationOffice = 'nt';
            obj.status = 'New';
            obj.searchApplications();
        }        
    } 
    
    private static testMethod void doTestThree() {
        Communities_AgentTransferListing obj = new Communities_AgentTransferListing();
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
    
    private Static MRIS_Application__c createMRISApplication(Account brokerOffice, Contact contact, License__c license, String applicationType, String subscriptionId) {
        MRIS_Application__c newApplication = new MRIS_Application__c(); 
        newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
        newApplication.Type__c = 'Agent';
        newApplication.City__c = contact.City__c;
        newApplication.Country__c = contact.Country__c;
        newApplication.County__c = contact.County__c;
        
        New_Agent_Approval_Days__c daysSetting = new New_Agent_Approval_Days__c();
        daysSetting.Name = applicationType;
        daysSetting.No_Of_Days__c = 19;
        insert daysSetting;
        
        Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues(applicationType).No_Of_Days__c;
        newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
        newApplication.First_Name__c = contact.FirstName;
        newApplication.Last_Name__c = contact.LastName;
        newApplication.License_Number__c = license.Name;
        newApplication.License_Expiration_Date__c = license.License_Expiration_Date__c;
        newApplication.License_State__c = license.License_State__c;
        newApplication.License_Type__c = license.License_Type__c;
        newApplication.Middle_Name__c = contact.Middle_Name__c;
        newApplication.Mobile_Phone__c = contact.Phone;
        newApplication.Nickname__c = contact.Nickname__c;
        newApplication.Company_Code__c = brokerOffice.Id;
        newApplication.Primary_Phone__c = contact.Phone;
        newApplication.Private_Email__c = 'test@test.com';
        newApplication.Private_Phone__c = contact.Phone;
        newApplication.Public_Email__c = 'test@test.com';
        newApplication.Salutation__c = contact.Salutation;
        newApplication.State__c = contact.State__c;
        newApplication.Status__c = 'New'; 
        newApplication.Service_Jurisdiction__c = 'MRIS';                   
        newApplication.Zip__c = contact.Zip__c;
        newApplication.Application_Type__c = applicationType;
        newApplication.Comments__c = '["' + subscriptionId + '"]';
        insert newApplication;
        
        return newApplication;    
    }               
}