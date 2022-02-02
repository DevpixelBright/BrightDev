@isTest
public class LT_ListingRequestUpdate_Test {
	
    @isTest
    static void lT_ListingRequestUpdateTriggerReassigned() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        ltreq.StatusCode__c = 'Rejected';
        update ltreq;
    }
    @isTest
    static void lT_ListingRequestUpdateTriggerReassigned90() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        for(Integer i = 0; i < 90; i++) {
        	Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        	ltreq.StatusCode__c = 'Rejected';
            requests.add(ltreq);
        }
        update requests;
    }
    @isTest
    static void lT_ListingRequestUpdateTriggerReassignedNull() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, null, 'Pending');
        ltreq.StatusCode__c = 'Rejected';
        update ltreq;
    }
    @isTest
    static void lT_ListingRequestUpdateTriggerReassignedNull90() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        for(Integer i = 0; i < 90; i++) {
        	Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, null, 'Pending');
        	ltreq.StatusCode__c = 'Rejected';
            requests.add(ltreq);
         }
        update requests;
    }
    @isTest
    static void lT_ListingRequestUpdateTriggerApproved() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, null, 'Pending');
        ltreq.StatusCode__c = 'Approved';
        update ltreq;
    }
    @isTest
    static void lT_ListingRequestUpdateTriggerApproved90() {
        generateData();
        createLTSettings();
        PROV_MockDataGenerator.isSuccess = true;
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id , c1.Id);       
        s2.Status__c='Active';
        update s2;
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        for(Integer i = 0; i < 90; i++) {
        	Listing_Transfer_Request__c ltreq = createListingTransferRequest(a1.Id, a2.Id, s1.Id, null, 'Pending');
        	ltreq.StatusCode__c = 'Approved';
            requests.add(ltreq);
        }
        update requests;
    }
    private static void generateData() {         
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();  
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
            account.Unit_Type__c ='FRNT, FRONT';
            account.Unit__c='Test Unit';
            account.Zip_4__c ='2122';
            account.Street_Direction__c='SW, SOUTHWEST';
            account.Street_Type__c='ACRES, ACRES';
            account.Street_Name__c='Test Street';
            account.Street_Number_Suffix__c='Test Suffix';
            account.Street_Number__c='Test Streetnumber';
            account.Bright_Office_Key__c = '123456';
            //account.Primary_Service_Jurisdiction__c = jurisdiction;
            
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
            //contact.Name='Test prime';
            contact.phone='987654321';
            contact.Email='agent45.test@gmail.com';
            insert contact;
            
            return contact;
        }
          private Static Subscriptions__c createSubscription(String accountId, String contactId ) {
            Subscriptions__c subscription = new  Subscriptions__c();
            subscription.Name = '123456';
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
            subscription.Public_Email__c = 'test@test.com';
            subscription.Bright_Agent_Key__c ='123435645352'; 
           //subscription.Service_Jurisdiction__c = jurisdiction;
            
            insert subscription; 
            
            return subscription;
        }
         private static Listing_Transfer_Request__c createListingTransferRequest(Id a1, Id a2, Id s1, Id s2, String status ) {
          Listing_Transfer_Request__c LT_Request = new  Listing_Transfer_Request__c();
            LT_Request.StatusCode__c = 'Pending';
            LT_Request.ListingKey__c = '205026350973';
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
            //LT_Request.OriginationDecision__c='Approved';
            //LT_Request.DestinationDecision__c='Approved';
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
        
        insert ltSettings;
    }
}