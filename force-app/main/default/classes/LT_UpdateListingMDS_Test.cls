@isTest
public class LT_UpdateListingMDS_Test {
    @isTest
    private static void reassignListingsMethod() {
      generateData();
      Account a1 = createAccount('Residential','XYZ124', 'Active');
      a1.Bright_Office_Key__c = '234567'; 
      update a1;  
      Account a2 = createAccount('Residential','XYZ125', 'Active');
      a2.Bright_Office_Key__c = '456732'; 
      update a2;  
      Contact c1 = createContact(a1.Id);
      Contact c2 = createContact(a2.Id);
      Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
      s1.Status__c = 'Active';
      s1.Bright_Agent_Key__c = '123456';  
      update  s1;
      Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
      s2.Status__c = 'Active';
      s2.BRIGHT_Agent_Key__c = '654321';
      update  s2;
      Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
      insert LTr;
      PROV_MockDataGenerator.isSuccess = true;
      List<String> requestIds = new List<String>{LTr.Id};
      test.startTest();
        
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
        ltcs5.Name = 'BRIGHT Host';
        ltcs5.Value__c = 'services.dev.brightmls.com:443';
        Listing_Transfer__c ltcs6 = new Listing_Transfer__c();
        ltcs6.Name = 'BRIGHT LUS URL';
        ltcs6.Value__c = 'https://lmsapi.dev.brightmls.com/ListingUpdateSvc/dbping';
        List<Listing_Transfer__c> csettingsList = new List<Listing_Transfer__c>{ltcs1, ltcs2, ltcs3, ltcs4, ltcs5, ltcs6};
        insert csettingsList;
        LT_UpdateListingMDS.reassignListings(requestIds);
      test.stopTest();  
      LT_UpdateListingMDS.approveListings(requestIds);
      LT_UpdateListingMDS.rejectListings(requestIds);
        
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
    
    private static Listing_Transfer_Request__c createListingTransferRequest(Id a1, Id a2, Id s1, Id s2, String status ) {
        Listing_Transfer_Request__c LT_Request = new  Listing_Transfer_Request__c();
        LT_Request.StatusCode__c = status;
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
        
        return LT_Request;
      }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
}