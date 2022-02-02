@isTest
private class LT_EmailNotifications_Test{
    @isTest
    static void scenarioApprovedEmails() {
        generateData();
        Account a1 = createAccount('Residential','XYZ129');
        Account a2 = createAccount('Residential','XYZ128');
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
        
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
      //update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        // update  s2;
        List<Subscriptions__c> sub = new List<Subscriptions__c>();
            sub.add(s1);
        sub.add(s2);
        update sub;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id, s2.Id, 'Broker Of Record');
        Relationship__c r4 = createRelationship(a2.Id, c2.Id, s2.Id, 'Authorized Signer');
        Listing_Transfer_Request__c ltr = createListingTransferRequest(a1.Id, a2.Id, s1.Id);
        ltr.DestinationDecisionOn__c = System.today().addDays(-1);
        ltr.OriginationDecisionOn__c = System.today().addDays(-1);
        ltr.OriginationDecision__c = 'Approved';
        ltr.DestinationDecision__c = 'Approved';
        ltr.StatusCode__c = 'Approved';
        ltr.IsActive__c = True;
        ltr.StatusCode__c = 'Pending';
        ltr.OriginationDecision__c = 'Approved';
		//insert ltr;
        Listing_Transfer_Request__c ltr1 = createListingTransferRequest(a1.Id, a2.Id, s2.Id);
        ltr1.DestinationDecisionOn__c = System.today().addDays(-1);
        ltr1.OriginationDecisionOn__c = System.today().addDays(-1);
        ltr1.OriginationDecision__c = 'Approved';
        ltr1.DestinationDecision__c = 'Approved';
        ltr1.StatusCode__c = 'Approved';
		//insert ltr1;
        list<Listing_Transfer_Request__c> Listingtrnsfr1 = new list<Listing_Transfer_Request__c>();
        Listingtrnsfr1.add(ltr);
        Listingtrnsfr1.add(ltr1);
        insert Listingtrnsfr1;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser) {
        EmailTemplate et = createEmailtemplateMethod('LT_AgentOriginationApprovedEmail');
        EmailTemplate et1 = createEmailtemplateMethod('LT_OriginationBrokerAuthorizedSignerDestinationApprovedEmail');       
        EmailTemplate et3 = createEmailtemplateMethod('LT_DestinationBrokerAuthorizedSignerDestinationApprovedEmail');   
            List<EmailTemplate>  emailtmple = new List<EmailTemplate>();
            emailtmple.add(et);
             emailtmple.add(et1);
             emailtmple.add(et3);
        insert emailtmple;
       
        LT_EmailNotifications emailNot = new LT_EmailNotifications();
        emailNot.sendApprovedEmails();
        }
        System.schedule('Email Notifications', '0 0 10 * * ?', new LT_ScheduleEmailNotifications());
    }
   @isTest
    static void scenarioRejectedEmails() {
        generateData();
         Account a1 = createAccount('Residential','XYZ129');
        Account a2 = createAccount('Residential','XYZ128');
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
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
       // update s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
       //update  s2;
        List<Subscriptions__c> sub = new List<Subscriptions__c>();
        sub.add(s1);
        sub.add(s2);
        update sub;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id, s2.Id, 'Broker Of Record');
        Relationship__c r4 = createRelationship(a2.Id, c2.Id, s2.Id, 'Authorized Signer');
        Listing_Transfer_Request__c ltr = createListingTransferRequest(a1.Id, a2.Id, s1.Id);
         Listing_Transfer_Request__c ltr1 = createListingTransferRequest(a1.Id, a2.Id, s2.Id);
        ltr.DestinationDecisionOn__c = System.today().addDays(-1);
        ltr.OriginationDecisionOn__c = System.today().addDays(-1);
        ltr.OriginationDecision__c = 'Rejected';
        ltr.DestinationDecision__c = 'Rejected';
        ltr.StatusCode__c = 'Rejected';
       /* list<Listing_Transfer_Request__c> lst = new list<Listing_Transfer_Request__c>();
        lst.add(ltr);
        lst.add(ltr1);
        insert lst;
       */
        ltr1.DestinationDecisionOn__c = System.today().addDays(-1);
        ltr1.OriginationDecisionOn__c = System.today().addDays(-1);
        ltr1.OriginationDecision__c = 'Rejected';
        ltr1.DestinationDecision__c = 'Rejected';
        ltr1.StatusCode__c = 'Rejected';
        List<Listing_Transfer_Request__c> ListingTransferRqst = new List<Listing_Transfer_Request__c>();
        ListingTransferRqst.add(ltr);
        ListingTransferRqst.add(ltr1);
        insert ListingTransferRqst;
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser) {
        EmailTemplate et = createEmailtemplateMethod('LT_AgentDestinationRejectedEmail');
        insert et;
        LT_EmailNotifications emailNot = new LT_EmailNotifications();
        emailNot.sendRejectedEmails();
        }
        System.schedule('Email Notifications', '0 0 10 * * ?', new LT_ScheduleEmailNotifications());
    }
  @isTest
    static void scenarioRemainderEmails() {
        generateData();
        Account a1 = createAccount('Residential','XYZ129');
        Account a2 = createAccount('Residential','XYZ128');
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
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
      update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
       update  s2;
       // Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id, s2.Id, 'Broker Of Record');
        Relationship__c r4 = createRelationship(a2.Id, c2.Id, s2.Id, 'Authorized Signer');
        Listing_Transfer_Request__c ltr = createListingTransferRequest(a1.Id, a2.Id, s1.Id);
        ltr.StatusCode__c = 'Pending';
        ltr.ExpirationDate__c = System.today().addDays(-3);
        ltr.OriginationDecision__c = null;
        ltr.DestinationDecision__c = null;
        insert ltr;
        Listing_Transfer_Request__c ltr1 = createListingTransferRequest(a1.Id, a2.Id, s2.Id);
        ltr1.StatusCode__c = 'Pending';
        ltr1.ExpirationDate__c = System.today().addDays(-3);
        ltr1.OriginationDecision__c = null;
        ltr1.DestinationDecision__c = null;
        insert ltr1;
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser) {
        EmailTemplate et = createEmailtemplateMethod('LT_AgentReminderEmail');
        EmailTemplate et1 = createEmailtemplateMethod('LT_DestinationBrokerAuthorizedReminderEmail');
        EmailTemplate et2 = createEmailtemplateMethod('LT_OriginationBrokerAuthorizedSignerReminderEmail');
        insert et;
        insert et1;
        insert et2;
        LT_EmailNotifications emailNot = new LT_EmailNotifications();
        emailNot.sendReminderEmails();
        }
        System.schedule('Email Notifications', '0 0 10 * * ?', new LT_ScheduleEmailNotifications());
    } 
    @isTest
    static void scenarioExpiryEmails() {
        generateData();
        Account a1 = createAccount('Residential','XYZ129');
        Account a2 = createAccount('Residential','XYZ128');
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
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
       // update  s1;
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        //update s2;
        List<Subscriptions__c> subs = new list<Subscriptions__c>();
        subs.add(s1);
        subs.add(s2);
        update subs;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id, s2.Id, 'Broker Of Record');
        Relationship__c r4 = createRelationship(a2.Id, c2.Id, s2.Id, 'Authorized Signer');
        Listing_Transfer_Request__c ltr = createListingTransferRequest(a1.Id, a2.Id, s1.Id);
        ltr.StatusCode__c = 'Pending';
        ltr.ExpirationDate__c = System.today().addDays(-1);
        ltr.OriginationDecision__c = null;
        ltr.DestinationDecision__c = null;
        //insert ltr;
        Listing_Transfer_Request__c ltr1 = createListingTransferRequest(a1.Id, a2.Id, s2.Id);
        ltr1.StatusCode__c = 'Pending';
        ltr1.ExpirationDate__c = System.today().addDays(-1);
        ltr1.OriginationDecision__c = null;
        ltr1.DestinationDecision__c = null;
      //  insert ltr1;
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser) {
        EmailTemplate et = createEmailtemplateMethod('LT_AgentExpiryEmail');
        EmailTemplate et1 = createEmailtemplateMethod('LT_OriginationBrokerAuthorizedExpiryEmail');
        EmailTemplate et3 = createEmailtemplateMethod('LT_DestinationBrokerAuthorizedExpiryEmail');    
       List<EmailTemplate> LtrList = new List<EmailTemplate>();
           
            LtrList.add(et);
             LtrList.add(et1);
             LtrList.add(et3);
        insert LtrList;
        LT_EmailNotifications emailNot = new LT_EmailNotifications();
        emailNot.sendExpiredEmails();
        }
        System.schedule('Email Notifications', '0 0 10 * * ?', new LT_ScheduleEmailNotifications());
    } 
    @isTest
    static void scenarioSubmissionEmails() {
        generateData();
         Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
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
        
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);  
        Subscriptions__c s2 = createSubscription(a2.Id, c2.Id); 
        List<Subscriptions__c> lSubscription = new List<Subscriptions__c>();
       s1.Status__c = 'Active';
       s2.Status__c = 'Active';
         lSubscription.add(s1);
        lSubscription.add(s2);
        update  lSubscription;
      /*  Subscriptions__c s2 = createSubscription(a2.Id, c2.Id);       
        s2.Status__c = 'Active';
        update  s2; */
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record');
        Relationship__c r2 = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');
        Relationship__c r3 = createRelationship(a2.Id, c2.Id, s2.Id, 'Broker Of Record');
        Relationship__c r4 = createRelationship(a2.Id, c2.Id, s2.Id, 'Authorized Signer');
        
        Listing_Transfer_Request__c ltr = createListingTransferRequest(a1.Id, a2.Id, s1.Id);
        Listing_Transfer_Request__c ltr1 = createListingTransferRequest(a1.Id, a2.Id, s2.Id);
        List<Listing_Transfer_Request__c> lListingTransferRequest = new List<Listing_Transfer_Request__c>();
        ltr.StatusCode__c = 'Pending';        
        ltr.OriginationDecision__c = null;
        ltr.DestinationDecision__c = null;
       
        ltr1.StatusCode__c = 'Pending';        
        ltr1.OriginationDecision__c = null;
        ltr1.DestinationDecision__c = null;
        lListingTransferRequest.add(ltr);
        lListingTransferRequest.add(ltr1);
        insert lListingTransferRequest;
        
        Test.setCreatedDate(ltr.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(ltr1.Id, Datetime.now().addDays(-1));
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser) {
        EmailTemplate et = createEmailtemplateMethod('LT_AgentNewRequestEmail');
        EmailTemplate et1 = createEmailtemplateMethod('LT_OriginationBrokerAuthorizedSignerNewRequestEmail');        
        EmailTemplate et3 = createEmailtemplateMethod('LT_DestinationBrokerAuthorizedNewRequestEmail');
        insert et;
        insert et1;
        insert et3;
        
        LT_EmailNotifications emailNot = new LT_EmailNotifications();
        emailNot.sendSubmissionEmails();
        }
        
        
        
        
        System.schedule('Email Notifications', '0 0 10 * * ?', new LT_ScheduleEmailNotifications());
    }
    
private static Account createAccount(String type, String name) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Notification';
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
       // insert contact;
        
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
        subscription.Public_Email__c = 'test@gmail.com';
		subscription.Private_Email__c = 'test@gmail.com';        
        insert subscription; 
        
        return subscription;
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
    private static Listing_Transfer_Request__c createListingTransferRequest(Id originationoffc, Id destinationoffc, Id subId) {
        Listing_Transfer_Request__c ltr = new Listing_Transfer_Request__c();
        ltr.OriginationOfficeCode__c = originationoffc;
        ltr.DestinationOfficeCode__c = destinationoffc;
        ltr.IsActive__c = true;
        ltr.Requested_By__c = subId;                                         
        return ltr;
    }
    private static EmailTemplate createEmailtemplateMethod(String templateName) {
        EmailTemplate et = new EmailTemplate();
        et.isActive = true;  
		et.Name = 'testTemplate';  
		et.DeveloperName = templateName;  
		et.TemplateType = 'text';  
		et.FolderId = UserInfo.getUserId();  
		et.Body = 'scenario7'; 
        return et;
    }
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}