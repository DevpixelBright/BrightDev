@isTest
public class EZJoin_NewApplicationStatus_Test {
    
   @isTest(SeeAllData=true)
    public static void TestOrderOne() {
        try{
            //Test.setMock(HttpCalloutMock.class, new Zuora_AccountMock());
            generateData();
            Account a1 = createAccount('Residential','XYZ124');
            createAccount1('Residential','XYZ12456');
            Contact c1 = createContact(a1.Id); 
            Subscriptions__c s1 = createSub(a1.Id, c1.Id);
            SMS_CoreMapping__c sms = createSMSCoreMapping(s1.Id, 'Agent','Realtor/Shareholder');
            s1.Status__c = 'Inactive';
            s1.Status_Change_Reason__c = 'Reinstate';
            //s1.Date_Reinstated__c = Date.today();
            s1.ZuoraIntegrationWorkflowBypass__c = false;
            s1.Billing_Jurisdiction__c = 'BRIGHT';
            s1.Date_Terminated__c = system.today();
            update s1;
            Zuora__CustomerAccount__c customerAcc = createBillingAccount(a1.Id, 'Patrick Crown', s1.Name, 101.01); 
            SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
            SMS_ZuoraMockDataGenerator.isCore = 'true';
            Subscriptions__c sub = [SELECT Id, Name from Subscriptions__c WHERE Id =: s1.Id];
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('SubscriptionID__c', sub.Name);
            preDefinedValues.put('Status', 'Active');
            SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
            EZJoin_NewApplicationStatusController.createOrder(s1.Id); 
        }
        catch(exception ex){
            system.debug('---Exception ex---' + ex);
        }
    }
    
     public static testMethod void testOne() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        //Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSub(a1.Id, c1.Id);
        s1.Status__c = 'In Progress';
        s1.Status_Change_Reason__c = 'Reinstate';
        s1.Date_Reinstated__c = Date.today();
        s1.ZuoraIntegrationWorkflowBypass__c = false;
        update s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson');  
        
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        application.Status__c = 'Approved';
        application.Agent_Subscription_ID__c = s1.Id;
        update application;
        MRIS_Application__c app = [SELECT Id, Name from MRIS_Application__c WHERE Id =: application.Id];
        EZJoin_NewApplicationStatusController.getApplicationDetails(app.Name);
        
        s1.Subscription_Type__c = 'Office Secretary - NC';
        s1.Status__c = 'Active';
        update s1;
        EZJoin_NewApplicationStatusController.officeSecretaryCount(s1);
        //EZJoin_NewApplicationStatusController.handleAgentWithoutApplication(s1);
        EZJoin_NewApplicationStatusController.handleAgents(application, s1, false);
    }
    
     public static testMethod void testTwo() {
        try{
            EZJoin_NewApplicationStatusController.validateLoginName('Logtest');
        }
        catch(exception ex){
            system.debug('---Exception ex---' + ex);
        }
        EZJoin_NewApplicationStatusController.wrapperClass wrap = new EZJoin_NewApplicationStatusController.wrapperClass();
       // MRIS_Application__c application = new MRIS_Application__c();
        Subscriptions__c subscription = new Subscriptions__c();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSub(a1.Id, c1.Id);
        s1.Status__c = 'Inactive';
        update  s1;
        License__c l1 = createLicense(c1.Id, 'Salesperson');    
        MRIS_Application__c  application = createMRISApplication(a1, c1, l1, 'Reinstatement','12345');
        application.Agent_Subscription_ID__c = s1.Id;
        application.Status__c = 'Approved';
        application.Service_Jurisdiction__c = 'BRIGHT';
        application.Billing_Jurisdiction__c = 'Lancaster';
        application.Association_Board_Affiliation__c = a1.Id;
        update application;
        Related_Agent__c agents = createAgents(c1.Name, s1.Id);
         try{
             EZJoin_NewApplicationStatusController.createSubscription(application.Name, 'Logtest');
         }catch(exception ex){
             system.debug('---Exception ex---' + ex);
         }
        EZJoin_NewApplicationStatusController.officeSecretaryCount(s1);
        s1.Subscription_Type__c = 'Licensee/Non Realtor';
        update s1;
        
    }
    
    public static testMethod void testThree() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        //Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSub(a1.Id, c1.Id);
        //Subscriptions__c s1 = createSub(a1.Id, c1.Id);
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson'); 
        MRIS_Application__c  application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        application.Status__c = 'Approved';
        update application;
        MRIS_Application__c app = [SELECT Id, Name from MRIS_Application__c WHERE Id =: application.Id];
        
        Related_Agent__c agents = createAgents(c1.Name, s1.Id);
        //agents.Subscription__c = '4557742';
        //agents.Assistant_to__c = 'First User';
        //update agents;
        EZJoin_NewApplicationStatusController.createSubscription(app.Name, 'Logtest');
        
        EZJoin_NewApplicationStatusController.officeSecretaryCount(s1);
        s1.Subscription_Type__c = 'Licensee/Non Realtor';
        update s1;
    }
    
    public static testMethod void testFour() {
        try{
            generateData();
            Account a1 = createAccount('Residential','XYZ124');
            Account a2 = createAccount('Residential','XYZ125');
            Contact c1 = createContact(a1.Id); 
            Subscriptions__c s1 = createSub(a1.Id, c1.Id);
            s1.Status__c = 'In Progress';
            update s1;
            License__c l1 = createLicense(c1.Id, 'Salesperson'); 
            MRIS_Application__c  application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
            application.Status__c = 'Approved';
            update application;
            EZJoin_NewApplicationStatusController.activateSubscription(s1.Id, false,application.Id);
            //EZJoin_NewApplicationStatusController.handleAgentWithoutApplication(s1);
        }
        
        catch(exception ex){
            system.debug('---Exception ex---' + ex);
        }
    }
    
   private static Account createAccount(String type, String name) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'DISTRICT OF COLUMBIA';
        account.County__c = 'WASHINGTON';
        account.QAS_Billing_County__c = 'DISTRICT OF COLUMBIA';
        account.Billing_County__c = 'WASHINGTON';
        account.QAS_Billing_Country__c = 'USA';
        account.Billing_Country__c = 'UNITED STATES OF AMERICA';
        account.QAS_Mailing_Country__c = 'USA';
        account.Country__c = 'UNITED STATES OF AMERICA';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        account.Type = 'Association';
       account.Primary_Service_Jurisdiction__c = 'BRIGHT';
       account.Copy_Address_to_Billing__c = true;
       account.QAS_Mailing_Record_Type__c = 'P';
       account.QAS_Mailing_POBox__c = '4567';
       account.Billing_Street_Type__c = '';
       account.Billing_Street_Direction__c = '';
       account.Billing_Unit_Type__c = '';
        insert account; 
        
        return account;
    }
    
    private static Account createAccount1(String type, String name) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'USA';
        account.Country__c = 'UNITED STATES OF AMERICA';
        account.QAS_Mailing_Country__c = 'CAN';
        account.Country__c = 'CANADA';
        account.QAS_Billing_Country__c = 'CAN';
        account.Billing_Country__c = 'CANADA';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        account.Type = 'Association';
        account.Primary_Service_Jurisdiction__c = 'MRIS';
        account.QAS_Billing_Record_Type__c = 'P';
        account.QAS_Billing_POBox__c = '4567';
        insert account; 
        
        return account;
    }
    
    private static Zuora__CustomerAccount__c createZAccount() {
        Zuora__CustomerAccount__c account = new Zuora__CustomerAccount__c();
        account.Zuora__AutoPay__c = true;
        account.Zuora__Default_Payment_Method__c = '';
        account.Zuora__Status__c = 'Active';
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
        contact.Email = 'test@test.com';
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSub(String accountId, String contactId) {
        Subscriptions__c subscription = new  Subscriptions__c();
        // subscription.Name = '12345';
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
        subscription.TREND_Login_Name__c = 're@.-';    
        subscription.Service_Jurisdiction__c = 'BRIGHT';
        subscription.Billing_Jurisdiction__c = 'BRIGHT';
        insert subscription; 
        
        return subscription;
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
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
        newApplication.Type__c = 'Assistant';
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
        newApplication.Service_Jurisdiction__c = 'BRIGHT';                   
        newApplication.Zip__c = contact.Zip__c;
        newApplication.Application_Type__c = 'Reinstatement';
        newApplication.Comments__c = '["' + subscriptionId + '"]';
        newApplication.Billing_Jurisdiction__c = 'MRIS';
        newApplication.Type__c = 'Assistant';
        newApplication.Related_Agents__c = '[{"name":"First User","agentId":"4557742"}]';
        insert newApplication;
        
        return newApplication;    
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
    
    
    private static SMS_CoreMapping__c createSMSCoreMapping(String subscriptionId, String Type, String subtype){
        SMS_CoreMapping__c sms = new SMS_CoreMapping__c();
        sms.ZuoraProductId__c = '2c92c0f93fd531f1013ff29cc48a55e2';
        sms.ZuoraOnetimeProductRatePlanId__c = '2c92c0f84207d6b70142288606a5085f';
        sms.Term_Duration__c = 12;
        sms.Type__c = Type;
        sms.SubType__c = subType;
        sms.Status__c = 'Reinstatement <= 30';
        sms.IsPrimaryFlag__c = true;
        sms.Billing_Jurisdiction__c = 'BRIGHT';
        sms.ZuoraRecurringProductRatePlanId__c = '2c92c0f85a1174a9015a215491775bed';
        insert sms;
        
        return sms;
    }
    
    private static SMS_Order__c createOrder(String subscriptionId) {
        SMS_Order__c order = new SMS_Order__c();                
        order.Name = 'Order Id';
        order.Token__c = 'Lp+iJPN0rMv7UMX31vGXqu7KHRqCmd9PJNX8d23G0FI=';
        order.Zuora_Account_Id__c = '2c92c0f84983c1bf0149875b92d5110f';
        order.MRIS_Subscription_Id__c = subscriptionId;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = false;
        order.Private_Email__c = 'test@test.com';
        order.IsEzJoinApplication__c = true;
        insert order;
        
        return order;
    }
    
    
    private Static Related_Agent__c createAgents(String contactId, String subscriptionId) {
        Related_Agent__c agents = new  Related_Agent__c();
        agents.Personal_Assistant_Sub_ID__c = subscriptionId ;
        agents.Personal_Assistant__c = contactId;
        insert agents; 
        
        return agents;
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