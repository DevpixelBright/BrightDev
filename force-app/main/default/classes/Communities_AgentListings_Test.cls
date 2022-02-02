@isTest
public class Communities_AgentListings_Test {
    
    private static testMethod void doTestOne() {
        
         Listing_Transfer__c ltcs1 = new Listing_Transfer__c();
        ltcs1.Name = 'BRIGHT Password';
        ltcs1.Value__c = '111017';
        Listing_Transfer__c ltcs2 = new Listing_Transfer__c();
        ltcs2.Name = 'BRIGHT URL';
        ltcs2.Value__c = 'https://lmsapi.dev.brightmls.com/services/dbping';
        Listing_Transfer__c ltcs3 = new Listing_Transfer__c();
        ltcs3.Name = 'BRIGHT UserAgent';
        ltcs3.Value__c = 'eProcess/1.0';
        Listing_Transfer__c ltcs4 = new Listing_Transfer__c();
        ltcs4.Name = 'BRIGHT UserName';
        ltcs4.Value__c = 'EPROCESSBRIGHT1';
        Listing_Transfer__c ltcs5 = new Listing_Transfer__c();
        ltcs5.Name = 'MDS Timeout';
        ltcs5.Value__c = '10';
        List<Listing_Transfer__c> csettingsList = new List<Listing_Transfer__c>{ltcs1, ltcs2, ltcs3, ltcs4, ltcs5}; 
        insert csettingsList;
        
        
        
        
        // test for validating listings
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription('987678', a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Subscriptions__c s2 = createSubscription('987899', a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Test.StartTest();
        PageReference pageRef = Page.Communities_AgentListings; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);       
        
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id];        
        
        System.RunAs(communityUser) { 
            Communities_AgentListings obj = new Communities_AgentListings();
            obj.validateListingRequests();
            obj.findCanceledRequestMDS(new Map<String, Listing_Transfer_Request__c> {'205026134428' => LTr});
            obj.getListingStatus();
            obj.query = 'query string';
            obj.serviceJurisdiction = 'BRIGHT';
            obj.isAgentActive = true;
            obj.selectedStatus = 'all';
            obj.listingDetails = new List<Communities_AgentListings.ListingDetail>();
        }  
        
        Test.StopTest();     
    }
    
    private static testMethod void doTestTwo() {
        // Test scenario with eligible listings
        
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Inactive');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription('9856985',a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Subscriptions__c s2 = createSubscription('9856258',a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Test.StartTest();
        PageReference pageRef = Page.Communities_AgentListings; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id];
        System.RunAs(communityUser) {  
            Communities_AgentListings obj = new Communities_AgentListings();
            String statuses = '\'ACTIVE-BRIGHT\',\'PENDING-BRIGHT\',\'TEMP OFF MARKET-BRIGHT\',\'CANCELED-BRIGHT\',\'WITHDRAWN-BRIGHT\',\'EXPIRED-BRIGHT\',\'DELETED-BRIGHT\',\'COMING SOON-BRIGHT\',\'CLOSED-BRIGHT\'';  
            String subscriptionId = s1.name;
            String type = 'eligible';
            String officeCode = a1.name;
            Communities_AgentListings.getListingKeys(statuses, subscriptionId, type);
            
            List<String> listingKeys = new List<String>{'205026134428', '205026350934'};
            Communities_AgentListings.getProperties(listingKeys, 'eligible', s1.Name);
        } 
        Test.StopTest();
    }
    
    private static testMethod void doTestThree() {
        // Test scenario with All listings 
        
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Inactive');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription('9856985',a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Subscriptions__c s2 = createSubscription('9856258',a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');         
        Test.StartTest();
        PageReference pageRef = Page.Communities_AgentListings; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id];         
        System.RunAs(communityUser) {  
            Communities_AgentListings obj = new Communities_AgentListings();
            String statuses = '\'ACTIVE-BRIGHT\',\'PENDING-BRIGHT\',\'TEMP OFF MARKET-BRIGHT\',\'CANCELED-BRIGHT\',\'WITHDRAWN-BRIGHT\',\'EXPIRED-BRIGHT\',\'DELETED-BRIGHT\',\'COMING SOON-BRIGHT\',\'CLOSED-BRIGHT\'';  
            String subscriptionId = s1.name;
            String type = 'all';
            String officeCode = a1.name;
            Communities_AgentListings.getListingKeys(statuses, subscriptionId, type);
            
            List<String> listingKeys = new List<String>{'205026134428', '205026350934'};
            Communities_AgentListings.getProperties(listingKeys, 'all', s1.Name);
        } 
        Test.StopTest();
    }
    
    private static testMethod void doTestFour() {
        // Test scenario with ineligible listings 
        
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription('9856985',a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Subscriptions__c s2 = createSubscription('9856258',a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Test.StartTest();
        PageReference pageRef = Page.Communities_AgentListings; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id];
        System.RunAs(communityUser) {  
            Communities_AgentListings obj = new Communities_AgentListings();
            obj.validateListingRequests();
            String statuses = '\'ACTIVE-BRIGHT\',\'PENDING-BRIGHT\',\'TEMP OFF MARKET-BRIGHT\',\'CANCELED-BRIGHT\',\'WITHDRAWN-BRIGHT\',\'EXPIRED-BRIGHT\',\'DELETED-BRIGHT\',\'COMING SOON-BRIGHT\',\'CLOSED-BRIGHT\'';  
            String subscriptionId = s1.name;
            String type = 'ineligible';
            String officeCode = a1.name;
            
            Communities_AgentListings.getListingKeys(statuses, subscriptionId, type); 
            List<String> listingKeys = new List<String>{'205026134428', '205026350934'};
            Communities_AgentListings.getProperties(listingKeys, 'ineligible', s1.Name);
        } 
        Test.StopTest();
    }

    private static testMethod void doTestFive() {
        // Test scenario with ineligible listings 
        
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription('9856985',a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;
        Subscriptions__c s2 = createSubscription('9856258',a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Test.StartTest();
        PageReference pageRef = Page.Communities_AgentListings; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id];
        System.RunAs(communityUser) {  
            Communities_AgentListings obj = new Communities_AgentListings();
            obj.validateListingRequests();
            String statuses = '\'ACTIVE-BRIGHT\',\'PENDING-BRIGHT\',\'TEMP OFF MARKET-BRIGHT\',\'CANCELED-BRIGHT\',\'WITHDRAWN-BRIGHT\',\'EXPIRED-BRIGHT\',\'DELETED-BRIGHT\',\'COMING SOON-BRIGHT\',\'CLOSED-BRIGHT\'';  
            String subscriptionId = s1.name;
            String type = 'pending';
            String officeCode = a1.name;
            
            Communities_AgentListings.getListingKeys(statuses, subscriptionId, type); 
            List<String> listingKeys = new List<String>{'205026134428', '205026350934'};
            Communities_AgentListings.getProperties(listingKeys, 'pending', s1.Name);
        } 
        Test.StopTest();
    }    
    
    private static testMethod void doTestSix() {
        // Test Scenarios with submit listings
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Contact c1 = createContact(a1.Id);
        List<Communities_AgentListings.ListingRequest> lrequest = new List<Communities_AgentListings.ListingRequest>();
        Subscriptions__c s1 = createSubscription('9856985',a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        update  s1;  
        Communities_AgentListings.ListingRequest req = new Communities_AgentListings.ListingRequest();
        req.listingKey = '205026134428';
        req.listingId = '';
        req.agentId = s1.Name;
        req.originatingOffice = a1.Name;
        lrequest.add(req);
        User communityUser = [SELECT Id, Name FROM User WHERE ContactId = :c1.Id]; 
        System.RunAs(communityUser) {
            Communities_AgentListings.submitListingTransferRequest(lrequest);
            Communities_AgentListings.getOriginationOfficeDetails(a1.Name);
        }
    }  
    
    
    
    private static Account createAccount(String type, String name, String status) {
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
        account.Status__c = status;
        account.Primary_Service_Jurisdiction__c = 'BRIGHT';
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
        contact.Service_Jurisdiction__c = 'BRIGHT';
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String subscriptionId, String accountId, String contactId) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = subscriptionId;
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@' + accountId + '.com';
        subscription.Service_Jurisdiction__c = 'BRIGHT';        
        insert subscription; 
        
        return subscription;
        
        
        
    }
    
    private static Listing_Transfer_Request__c createListingTransferRequest(Id a1, Id a2, Id s1, Id s2, String status ) {
        Listing_Transfer_Request__c LT_Request = new  Listing_Transfer_Request__c();
        LT_Request.StatusCode__c = status;
        LT_Request.ListingKey__c = '205026134428';
        LT_Request.RequestedOn__c = system.today();
        LT_Request.CanceledOn__c = system.today().addDays(1);
        LT_Request.IsActive__c = true;
        LT_Request.OriginationDecisionOn__c = Date.today();
        LT_Request.DestinationDecisionOn__c = Date.today().addDays(3);
        LT_Request.OriginationOfficeCode__c = a1;
        LT_Request.DestinationOfficeCode__c = a2;
        LT_Request.Requested_By__c = s1;
        LT_Request.Reassigned_To__c = s2;
        LT_Request.ExpirationDate__c = Date.today().addDays(4);
        
        insert LT_Request;
        return LT_Request;
    }
    
    private Static void createLTSettings(){
        List<Listing_Transfer__c> ltSettings = new  List<Listing_Transfer__c>();
        
        Listing_Transfer__c UserName = new Listing_Transfer__c();
        userName.Name = 'BRIGHT UserName';
        userName.Value__c = 'BRIGHT UserName';
        ltSettings.add(userName);
        
        Listing_Transfer__c UserAgent = new Listing_Transfer__c();
        UserAgent.Name = 'BRIGHT UserAgent';
        UserAgent.Value__c = 'BRIGHT UserAgent';
        ltSettings.add(UserAgent);
        
        Listing_Transfer__c Password = new Listing_Transfer__c();
        Password.Name = 'BRIGHT Password';
        Password.Value__c = 'BRIGHT Password';
        ltSettings.add(Password);
        
        Listing_Transfer__c URL = new Listing_Transfer__c();
        URL.Name = 'BRIGHT URL';
        URL.Value__c = 'BRIGHT URL';
        ltSettings.add(URL);
        
        Listing_Transfer__c lusURL = new Listing_Transfer__c();
        lusURL.Name = 'BRIGHT LUS URL';
        lusURL.Value__c = 'BRIGHT lusURL';
        ltSettings.add(lusURL);
        
        Listing_Transfer__c host = new Listing_Transfer__c();
        host.Name = 'BRIGHT Host';
        host.Value__c = 'BRIGHT Host';
        ltSettings.add(host);
        
        Listing_Transfer__c expirydays = new Listing_Transfer__c();
        expirydays.Name = 'Expiry Days';
        expirydays.Value__c = '14';
        ltSettings.add(expirydays);
        
        insert ltSettings;
    }
    
     private Static void createLTDetail(){
     
 
 }
}