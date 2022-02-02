@istest
public class Communities_ListingTransferRequests_Test{
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
        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, s2.Id, 'Pending');
        
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id,s2.Id, 'Broker Of Record'); 
        //Relationship__c r4 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r3);
        //insert lRelationship;
        test.startTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {  
            
            List<Communities_ListingTransferRequests.ListingDetail> listDetailList = New List<Communities_ListingTransferRequests.ListingDetail>(); 
            Communities_ListingTransferRequests.ListingDetail listDetailVar = New Communities_ListingTransferRequests.ListingDetail(); 
            listDetailVar.subscriptionId = s2.Id;
            listDetailVar.listingAgentId ='Test Id';
            listDetailVar.isChecked =True;
            listDetailVar.ListingKey='205026134428';
            listDetailVar.ListingId ='';
            listDetailVar.ListOfficeCode ='test code';
            listDetailVar.ListingStatus = 'Active'; 
            listDetailVar.BathsFull =1;
            listDetailVar.BathsHalf=1;
            listDetailVar.Beds =1;
            listDetailVar.ListPrice='12';
            listDetailVar.address='test add';
            listDetailVar.expirationText='Test text';
            listDetailVar.desinationOfficeKey ='XYZ135';
            listDetailVar.originationOfficeKey=' XYZ130';
            listDetailVar.destinationDecision ='Approved';
            listDetailVar.originationDecision ='Approved'; 
            // listDetailVar.reassignedAgentId ='322549';
            listDetailVar.reassignedAgentKey='34543435'; 
            listDetailVar.reassignedRId='123456';
            listDetailVar.agentKey='test agentkey';
            listDetailVar.isIncoming=True;
            listDetailVar.canMakeDecision=False;
            listDetailVar.reassign =True;
            listDetailVar.reassignError=True;
            listDetailVar.imageURL='Test URL';
            listDetailVar.expirationDate=Date.today();
            //listDetailVar.reassignedAgentId = s2.Id;
            listDetailList.add(listDetailVar);
            system.debug('in run as');
            PageReference pageRef = Page.Communities_ListingTransferRequests; 
            pageRef.getParameters().put('id', s1.name);
            Test.setCurrentPage(pageRef);
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            //obj.validateListingRequests();
            String subscriptionId = s1.name;
            String officeCode = a1.name;
            String requestType='Incoming';
            Communities_ListingTransferRequests.submitBrokerDecisions(listDetailList,True,s1.Name,true);
            Communities_ListingTransferRequests.getSubDetails(subscriptionId);
            Communities_ListingTransferRequests.getOfficeDetails(officeCode); 
            
            Communities_ListingTransferRequests.validateSubscription(subscriptionId,officeCode); 
            //Communities_ListingTransferRequests.getListingRequestDetails([], 'Pending');
            //Communities_ListingTransferRequests.getListingDetailsMDS('', null, false);
            test.stopTest();  
        }   
    }
    
    private static testMethod void doTestOneCondOne() {
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
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id,s2.Id, 'Broker Of Record'); 
        //Relationship__c r4 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r3);
        // insert lRelationship;
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        List<Communities_ListingTransferRequests.ListingDetail> listDetailList = New List<Communities_ListingTransferRequests.ListingDetail>(); 
        Communities_ListingTransferRequests.ListingDetail listDetailVar = New Communities_ListingTransferRequests.ListingDetail(); 
        listDetailVar.subscriptionId = s2.Id;
        listDetailVar.listingAgentId ='Test Id';
        listDetailVar.isChecked =True;
        //listDetailVar.ListingKey='Test key';
        //wrapper.ListingId ='Test Id';
        listDetailVar.ListOfficeCode ='test code';
        listDetailVar.ListingStatus = 'Active'; 
        listDetailVar.BathsFull =1;
        listDetailVar.BathsHalf=1;
        listDetailVar.Beds =1;
        listDetailVar.ListPrice='12';
        listDetailVar.address='test add';
        listDetailVar.expirationText='Test text';
        listDetailVar.desinationOfficeKey ='XYZ135';
        listDetailVar.originationOfficeKey=' XYZ130';
        listDetailVar.destinationDecision ='Approved';
        listDetailVar.originationDecision ='Approved'; 
        // listDetailVar.reassignedAgentId ='322549';
        listDetailVar.reassignedAgentKey='34543435'; 
        listDetailVar.reassignedRId='123456';
        listDetailVar.agentKey='test agentkey';
        listDetailVar.isIncoming=True;
        listDetailVar.canMakeDecision=False;
        listDetailVar.reassign =True;
        listDetailVar.reassignError=True;
        listDetailVar.imageURL='Test URL';
        listDetailVar.expirationDate=Date.today();
        listDetailVar.reassignedAgentId = s2.Id;
        listDetailList.add(listDetailVar);
        
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {  
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            //obj.validateListingRequests();
            String subscriptionId = s1.name;
            String officeCode = a1.name;
            String requestType='Incoming';
            Communities_ListingTransferRequests.submitBrokerDecisions(listDetailList,True,s1.Name,false);
            
        }   
    }
    private static testMethod void doTestOneCondtwo() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id,s2.Id, 'Broker Of Record'); 
        //Relationship__c r4 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r3);
        // insert lRelationship;
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        List<Communities_ListingTransferRequests.ListingDetail> listDetailList = New List<Communities_ListingTransferRequests.ListingDetail>(); 
        Communities_ListingTransferRequests.ListingDetail listDetailVar = New Communities_ListingTransferRequests.ListingDetail(); 
        listDetailVar.subscriptionId = s2.Id;
        listDetailVar.listingAgentId ='Test Id';
        listDetailVar.isChecked =True;
        //listDetailVar.ListingKey='Test key';
        //wrapper.ListingId ='Test Id';
        listDetailVar.ListOfficeCode ='test code';
        listDetailVar.ListingStatus = 'Active'; 
        listDetailVar.BathsFull =1;
        listDetailVar.BathsHalf=1;
        listDetailVar.Beds =1;
        listDetailVar.ListPrice='12';
        listDetailVar.address='test add';
        listDetailVar.expirationText='Test text';
        listDetailVar.desinationOfficeKey ='XYZ135';
        listDetailVar.originationOfficeKey=' XYZ130';
        listDetailVar.destinationDecision ='Approved';
        listDetailVar.originationDecision ='Approved'; 
        // listDetailVar.reassignedAgentId ='322549';
        listDetailVar.reassignedAgentKey='34543435'; 
        listDetailVar.reassignedRId='123456';
        listDetailVar.agentKey='test agentkey';
        listDetailVar.isIncoming=false;
        listDetailVar.canMakeDecision=False;
        listDetailVar.reassign =True;
        listDetailVar.reassignError=True;
        listDetailVar.imageURL='Test URL';
        listDetailVar.expirationDate=Date.today();
        listDetailVar.reassignedAgentId = s2.Id;
        listDetailList.add(listDetailVar);
        
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {  
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            //obj.validateListingRequests();
            String subscriptionId = s1.name;
            String officeCode = a1.name;
            String requestType='Incoming';
            Communities_ListingTransferRequests.submitBrokerDecisions(listDetailList,True,s1.Name,false);
        }
    }
    private static testMethod void doTesttwo() {
        generateData();
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r2 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r2);
        insert lRelationship;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        
        Test.StartTest();
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) { 
            //PROV_MockDataGenerator.isSuccess = true;    
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            obj.validateListingRequests();
        }   
    } 
    private static testMethod void doTesttwoconditionsOne() {
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
        generateData();
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, s2.Id, 'Pending');
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r2 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r2);
        insert lRelationship;
        Test.StartTest();
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            obj.validateListingRequests();
            obj.findCancelledRequestMDS(new Map<String, Listing_Transfer_Request__c> {'205026134428' => LTr});
            
        }   
    } 
    private static testMethod void doTesttwoconditionsTwo() {
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
        generateData();
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, s2.Id, 'Pending');
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r2 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r2);
        insert lRelationship;
        Test.StartTest();
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) { 
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            obj.validateListingRequests();
            
        }   
    } 
    private static testMethod void doTesttwoconditionsThree() {
        generateData();
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r2 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r2);
        insert lRelationship;
        Test.StartTest();
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            obj.validateListingRequests();
            
        }   
    } 
    
    private static testMethod void doTesttwoconditionsFour() {
        generateData();
        createLTSettings();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);
        s1.Status__c='Active';
        update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2;
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a2.Id, a1.Id, s1.Id, null, 'Pending');
        
        Relationship__c r1 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        Relationship__c r2 = createRelationship(a2.Id, c2.Id,s2.Id, 'Authorized Signer');
        List<Relationship__c> lRelationship = new List<Relationship__c>();
        lRelationship.add(r1);
        lRelationship.add(r2);
        insert lRelationship;
        Test.StartTest();
        PageReference pageRef = Page.Communities_ListingTransferRequests; 
        pageRef.getParameters().put('id', s1.name);
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {
            Communities_ListingTransferRequests obj = new Communities_ListingTransferRequests();
            obj.validateListingRequests();
            
        }   
    } 
    private static testMethod void getListingRequestDetailsMethod() {
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
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        a1.Bright_Office_Key__c = '234567';        
        a2.Bright_Office_Key__c = '456732';
        a2.OfficeKey__c = '123456';
        update lAccount;
        
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2);
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        update  s1;
        
        Listing_Transfer_Request__c LTr = createListingTransferRequest(a1.Id, a2.Id, s1.Id, null, 'Pending');
        
        
        Test.StartTest();
        Test.StopTest(); 
        User communityUser = createCommunityUser(s1.Id);
        String requestType='incoming';
        List<String> requestIds= new List<String>{LTr.Id};
            Communities_ListingTransferRequests.getListingRequestDetails(requestIds, requestType);
        System.RunAs(communityUser) {
            
            //PROV_MockDataGenerator.isSuccess = true;
            Communities_ListingTransferRequests.getListingRequestDetails(requestIds, requestType);
        }
        
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
        
        //account.Primary_Service_Jurisdiction__c = jurisdiction;
        
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
        //contact.Name='Test prime';
        contact.phone='987654321';
        contact.Email='agent45.test@gmail.com';
        //insert contact;
        
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
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Bright_Agent_Key__c ='Testkey'; 
        //subscription.Service_Jurisdiction__c = jurisdiction;
        
        insert subscription; 
        
        return subscription;
    }
    private static Listing_Transfer_Request__c createListingTransferRequest(Id a1, Id a2, Id s1, Id s2, String status ) {
        Listing_Transfer_Request__c LT_Request = new  Listing_Transfer_Request__c();
        LT_Request.StatusCode__c = 'Pending';
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
        //LT_Request.OriginationDecision__c='Approved';
        //LT_Request.DestinationDecision__c='Approved';
        insert LT_Request;
        return LT_Request;
    }
    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        //insert r; 
        
        return r;
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
    
    
    public static testmethod void Create_submitBrokerDecisions(){
        Subscriptions__c subscription = new Subscriptions__c();
        Account a1 = createAccount('Residential','XYZ124', 'Active');
        Account a2 = createAccount('Residential','XYZ125', 'Active');
        List<Account> lAccount = new List<Account>();
        lAccount.add(a1);
        lAccount.add(a2);
        insert lAccount;
        a1.Bright_Office_Key__c = '234567';        
        a2.Bright_Office_Key__c = '456732';
        a2.OfficeKey__c = '123456';
        update lAccount;
        
        Contact c1 = createContact(a1.Id);
        Contact c2 = createContact(a2.Id);
        List<Contact> lContact = new List<Contact>();
        lContact.add(c1);
        lContact.add(c2); 
        insert lContact;
        Subscriptions__c s1 = createSubscription(a1.Id , c1.Id);       
        s1.Status__c='Active';
        s1.Name = 'TestName';
        update  s1;
        
        // insert subscription;
        
        Communities_ListingTransferRequests.ListingDetail listingDetailData = new Communities_ListingTransferRequests.ListingDetail();
        list<Communities_ListingTransferRequests.ListingDetail> ListingDetail = new  list<Communities_ListingTransferRequests.ListingDetail>();
        listingDetailData.subscriptionId = '765433';
        listingDetailData.listingAgentId = '1232'; 
        listingDetailData.isChecked = True;
        listingDetailData.ListingKey = '7653';
        listingDetailData.ListingId = '6543';
        listingDetailData.ListOfficeCode = '1234';
        listingDetailData.ListingStatus = 'yes';
        listingDetailData.BathsFull = NULL ;
        listingDetailData.BathsHalf = NULL;
        listingDetailData.Beds= NULL;
        listingDetailData.ListPrice='2000';
        listingDetailData.address='Test address';
        listingDetailData.imageURL='www.google.com';
        listingDetailData.decision='';
        
        listingDetailData.expirationDate = system.today();
        listingDetailData.expirationText = 'Test expiration';
        listingDetailData.requestId = '1233';
        listingDetailData.isIncoming = True;
        listingDetailData.canMakeDecision = True;
        listingDetailData.desinationOfficeKey = '1234';
        listingDetailData.originationOfficeKey = '7653';
        listingDetailData.destinationDecision = 'Test decision';
        listingDetailData.originationDecision = 'Test Origination';
        listingDetailData.reassignedAgentId = '8767';
        listingDetailData.reassignedAgentKey = '8642';
        listingDetailData.reassignedRId = '0989';
        listingDetailData.reassign = True;
        listingDetailData.reassignError = False;
        listingDetailData.agentKey = '1234';
        ListingDetail.add(listingDetailData);
        
        List<Listing_Transfer_Request__c> updatedRequests = new List<Listing_Transfer_Request__c>();
        Listing_Transfer_Request__c request = new Listing_Transfer_Request__c();
        request.DestinationDecision__c = 'Test Decision';
        request.StatusCode__c = 'Test Decision Status code';                
        request.DestinationDecisionOn__c = system.today();
        updatedRequests.add(request);
        update updatedRequests;
        Communities_ListingTransferRequests.submitBrokerDecisions(listingDetail, true, '123112' , false);
    }
}