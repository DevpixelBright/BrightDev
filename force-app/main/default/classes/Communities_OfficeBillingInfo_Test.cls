@isTest(seealldata = true)
public class Communities_OfficeBillingInfo_Test {
   
    private static testMethod void doTestOne() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id, 'Test con', 'email@something.com'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, '123111');       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker of Record');       
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        Zuora__CustomerAccount__c billAcc = createBillingAccount(a1.Id, 'Patrick Crown', s1.Name, 101.01); 
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('SubscriptionID__c', s1.Name);
        preDefinedValues.put('Id', '254dksjfhsdkj');
        preDefinedValues.put('Status', 'Processed');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;       
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {
            
            ApexPages.currentPage().getParameters().put('id', s1.name);
            ApexPages.currentPage().getParameters().put('pmid', '254dksjfhsdkj');
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeBillingInformation obj = new Communities_OfficeBillingInformation(); 
            
            obj.proceedToPayment();
            obj.showExistingPaymentMethods();
            obj.showNewPaymentMethod();
            obj.selectPaymentMethod();
            obj.selectedSubids = s1.Name;
            obj.calculatePayableAmount();
            obj.agentPayments();
            obj.getSOAPDF();
            obj.advSearchNextResults();
            
            obj.Error = 'code=HostedPageFieldValidationError<br>code=GatewayTransactionError<br>code=GatewayTransactionError<br>code=GatewayTransactionError';
            obj.paymentMethodFailed();
            
            obj.Error = 'code=GatewayTransactionError<br>code=GatewayTransactionError<br>code=GatewayTransactionError<br>code=GatewayTransactionError';
            obj.paymentMethodFailed();
            
            obj.Error = 'code=Invalid_Security<br>code=GatewayTransactionError<br>code=GatewayTransactionError<br>code=GatewayTransactionError';
            obj.paymentMethodFailed();
            
 
        }        
    }
    
    private static testMethod void doTestTwo() {
        /* Test scenario with Authorized Signer */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id, 'Test con', 'email@something.com');
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, '123111');       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Authorized Signer');       
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        Zuora__CustomerAccount__c billAcc = createBillingAccount(a1.Id, 'Patrick Crown', s1.Name, 101.01); 
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('SubscriptionID__c', s1.Name);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;       
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {
            
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeBillingInformation obj = new Communities_OfficeBillingInformation();
            obj.displayType = 'paid'; 
            obj.officeId = a1.Id;
            obj.paymentMethodId = '254dksjfhsdkj';
            obj.proceedToPayment();
            obj.showExistingPaymentMethods();
            obj.showNewPaymentMethod();
            obj.selectPaymentMethod();
            obj.selectedSubids = s1.Name;
            obj.calculatePayableAmount();           
            
            obj.agentPayments();
            obj.billingAccounts =  [SELECT Id,
                                      Email_Invoice_PDF__c,
                                      Oldest_Invoice_Due__c,
                                      Zuora__Balance__c,
                                      Subscription__r.Name,
                                      Subscription__r.Contact__r.Name,
                                      Subscription__r.Related_Location_Broker_Office__r.Name,
                                      Zuora__Zuora_Id__c,
                                      SubscriptionID__c, createdDate
                               FROM   Zuora__CustomerAccount__c 
                               WHERE  Subscription__r.Related_Location_Broker_Office__r.Name = 'XYZ124'];
            obj.getSOAPDF();            
            obj.advSearchNextResults();
        }        
    }
  
    private static testMethod void doTestThree() {
        /* Test scenario with Office Manager */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id, 'Test con', 'email@something.com'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, '123111');       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Office Manager');       
        License__c l = createLicense(c1.Id, 'Salesperson');                                         
        Zuora__CustomerAccount__c billAcc = createBillingAccount(a1.Id, 'Patrick Crown', s1.Name, 101.01); 
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('SubscriptionID__c', s1.Name);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;       
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {
            
            ApexPages.currentPage().getParameters().put('id', s1.name);
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeBillingInformation obj = new Communities_OfficeBillingInformation();
            obj.displayType = 'paid'; 
            obj.officeId = a1.Id;
            obj.paymentMethodId = '254dksjfhsdkj';
            obj.proceedToPayment();
            obj.showExistingPaymentMethods();
            obj.showNewPaymentMethod();
            obj.selectPaymentMethod();
            obj.selectedSubids = s1.Name;
            obj.calculatePayableAmount();           
            
            obj.agentPayments();
            obj.getSOAPDF();            
            obj.advSearchNextResults();
        }        
    }
    
    private static testMethod void doTestFour() {
        /* Test scenario with Broker of Record */
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id, 'Test con', 'email@something.com');
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, '123111');       
        s1.Status__c = 'Active';
        update  s1;
        
        Relationship__c r = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker of Record');
        
        Contact objCon = createContact(a1.Id, 'Test con1', 'email1@something.com'); 
        Subscriptions__c objSub = createSubscription(a1.Id, objCon.Id, '123222');
        objSub.Status__c = 'Active';
        update objSub;
        
        Relationship__c objRel = createRelationship(a1.Id, objCon.Id, objSub.Id, 'Office Manager');
        
        
        License__c l = createLicense(c1.Id, 'Salesperson');
        Zuora__CustomerAccount__c billAcc = createBillingAccount(a1.Id, 'Patrick Crown', s1.Name, 101.01);
        Zuora__CustomerAccount__c billAcc2 = createBillingAccount(a1.Id, 'Patrick Crown1', objSub.Name, 101.01); 
            
        
        User communityUser = createCommunityUser(s1.Id);             
        System.RunAs(communityUser) {
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('SubscriptionID__c', s1.Name);
            preDefinedValues.put('Id', '254dksjfhsdkj');
            preDefinedValues.put('Status', 'Processed');
            preDefinedValues.put('InvoiceDate', Date.today().addDays(-2).format());
            
            SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;   
            
            ApexPages.currentPage().getParameters().put('id', s1.name);
            ApexPages.currentPage().getParameters().put('pmid', '254dksjfhsdkj');
            Test.setCurrentPage(ApexPages.currentPage());
            Communities_OfficeBillingInformation obj = new Communities_OfficeBillingInformation(); 
            
            obj.displayType = 'Unpaid'; 
            obj.paymentMethodId = '254dksjfhsdkj';
            obj.officeId = 'None';
            obj.balanceNextoffset = System.now().AddDays(5);
            obj.proceedToPayment();
            obj.showExistingPaymentMethods();
            obj.showNewPaymentMethod();
            obj.selectPaymentMethod();
            obj.selectedSubids = s1.Name;
            obj.calculatePayableAmount();
            obj.agentPayments();
            obj.getSOAPDF();
            obj.advSearchNextResults();
            
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
    
    private static Contact createContact(String accountId, string name, string email) {
        Contact contact = new Contact();
        contact.Email = email; // 'email@something.com';
        contact.FirstName = name;
        contact.LastName = 'Contact';
        contact.Public_Email__c = email; //'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, string name) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';    
        subscription.AgentKey__c = name;
        subscription.name = name;
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
    
    private static Zuora__CustomerAccount__c createBillingAccount(String accountId, String accountName, String subName, Decimal balance) {
       
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subName;
        billingAccount.Oldest_Invoice_Due__c = system.today().addDays(-5);
        billingAccount.Zuora__Balance__c = balance;
        billingAccount.Email_Invoice_PDF__c = true;
        insert billingAccount;
        
        return billingAccount; 
    }          
}