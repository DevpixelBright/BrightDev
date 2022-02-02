@istest(SeeAllData = true)
private class NewAgentApplication_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static License__c newLicense;
    private Static MRIS_Application__c newApplication;
    
    private static testMethod void doTestOne(){
        try {
            createAccount('Residential','XYZ124');
            String brokerCode = account.Id;
            account.Status__c = 'Active';
            update account;
            createContact(account.Id);
            createSubscription(account.Id, contact.Id);
            createAccount('Association','XYZ125');
            String association = account.Id;
            account.Status__c = 'Active';
            update account;
            CreateLicense();
            //createMRISApplication();
            PageReference pageRef = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef);
            NewAgentApplication objNA = new NewAgentApplication();
            objNA.license = newLicense;
            objNA.getStates();
            objNA.getTypes();
            objNA.getSuffix();
            objNA.getSalutation();
            objNA.verifyLicenseDetails();
            objNA.brokerCode = brokerCode;
            objNA.association = association;
            objNA.brokerBlockState = 'Verified';
            objNA.verifyBrokerCode();
            objNA.loadBrokerTREND();
            objNA.redirectToReinstate();
            objNA.redirectToPayment();
            objNA.redirectApplication();
            objNA.redirectReinstate();
            objNA.continueContactSave();
            objNA.acceptAgreement();
            objNA.verifyContactDetails();
            objNA.searchTerm = '123';
            NewAgentApplication.searchBroker(objNA.searchTerm,'TREND');
            NewAgentApplication.searchBroker(objNA.searchTerm,'TRENDS');
            NewAgentApplication.searchBroker(objNA.searchTerm,'BRIGHT');
            NewAgentApplication.verifyLicense('LIC68','Salesperson','VA');

            
            PageReference pageRef1 = objNA.saveApplication();
            Test.setCurrentPage(pageRef1); 
            Id appid = pageRef1.getParameters().get('id');
            MRIS_Application__c mr = [SELECT ID,Name,status__c from MRIS_Application__c where id =:appid];
            mr.Status__c = 'Approved';
            //mr.Status__c = 'Rejected';
            mr.Last_Name__c = contact.LastName;
            mr.Suffix__c = 'SR.';
            mr.Subscription_Type__c = 'Realtor/Non Shareholder';
            mr.Type__c = 'Agent';
            update mr;
            objNA.applicationName = mr.Name;
            objNA.saveApplication();
        }
        Catch(Exception e) {
            e.getMessage();
        }
        
    }
    private static testMethod void doTestTwo(){
        createAccount('Residential','XYZ124');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id);
        createSubscription(account.Id, contact.Id);
        createAccount('Association','XYZ125');
        String association = account.Id;
        account.Shareholder_Board__c = 'Yes';
        account.Status__c = 'Active';
        update account;
        PageReference pageRef = Page.NewAgentApplication;
        Test.setCurrentPage(pageRef);
        NewAgentApplication objNA = new NewAgentApplication();
        objNA.brokerCode = brokerCode;
        objNA.license = newLicense;
        objNA.loadBrokerTREND();
        objNA.verifyBrokerCode();
        objNA.redirectToReinstate();
        
    }   
    
    private static testMethod void doTestThree(){
        try {
            createAccount('Residential','XYZ124');
            String brokerCode = account.Id;
            account.Status__c = 'Active';
            update account;
            createContact(account.Id);
            createSubscription(account.Id, contact.Id);                  
            createAccount('Association','XYZ125');
            String association = account.Id;
            account.Account_Name__c = 'None';
            account.Status__c = 'Active';
            update account;
            CreateLicense();
            //createMRISApplication();
            PageReference pageRef = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef);
            NewAgentApplication objNA = new NewAgentApplication();
            objNA.subscriberId=subscription.Name;
            objNA.trendLoginName= 'trend123'; 
            objNA.getStates();
            objNA.getTypes();
            //objNA.subscription = '123465';
            subscription.Status__c = 'Inactive';
        	update  subscription;
            objNA.verifyLicenseDetails();            
            objNA.redirectToPayment();
            
        }
        Catch(Exception e) {
            e.getMessage();
        }
        
    }
    private static testMethod void doTestFour(){
        try {
            createAccount('Residential','XYZ124');
            String brokerCode = account.Id;
            account.Status__c = 'Active';
            update account;
            createContact(account.Id);
            createSubscription(account.Id, contact.Id);
            createAccount('Association','XYZ125');
            String association = account.Id;
            account.Shareholder_Board__c = 'No';
            account.Status__c = 'Active';
            update account;
            CreateLicense();
            //createMRISApplication('Reinstatement');
            PageReference pageRef = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef);
            NewAgentApplication objNA = new NewAgentApplication();
            objNA.license = newLicense;
            objNA.getStates();
            objNA.getTypes();
            objNA.brokerBlockState = ''; 
            objNA.verifyLicenseDetails();
            
            
            PageReference pageRef1 = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef1);
            NewAgentApplication objNA1 = new NewAgentApplication();
            objNA.brokerBlockState = ''; 
            objNA.contactBlockState = '';
            objNA.verifyLicenseDetails();
            
            PageReference pageRef2 = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef2);
            NewAgentApplication objNA2 = new NewAgentApplication();
            objNA.brokerBlockState = ''; 
            objNA.contactBlockState = '';
            objNA.agreementBlockState='';
            objNA.verifyLicenseDetails();  
            
        }
        Catch(Exception e) {
            e.getMessage();
        }
        
    }
    private static testMethod void doTestFive(){
        try {
            createAccount('Residential','XYZ124');
            String brokerCode = account.Id;
            account.Status__c = 'Active';
            update account;
            createContact(account.Id);
            createSubscription(account.Id, contact.Id);
            createAccount('Association','XYZ125');
            String association = account.Id;
            account.Status__c = 'Active';
            update account;
            CreateLicense();
            createMRISApplication('Reinstatement');
            PageReference pageRef = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef);
            NewAgentApplication objNA = new NewAgentApplication();
            objNA.applicationId = newApplication.Name;
            objNA.subscriberId= '';
            objNA.verifyLicenseDetails();                       
        }
        Catch(Exception e) {
            e.getMessage();
        }
        
    }
    
    private static testMethod void doTestSix(){
        try {
            createAccount('Residential','XYZ124');
            String brokerCode = account.Id;
            account.Status__c = 'Active';
            update account;
            createContact(account.Id);
            createSubscription(account.Id, contact.Id);
            CreateLicense();
            createMRISApplication('New Agent');
            PageReference pageRef = Page.NewAgentApplication;
            Test.setCurrentPage(pageRef);
            NewAgentApplication objNA = new NewAgentApplication();
            objNA.applicationId = newApplication.Id;
            objNA.subscriberId= '';
            objNA.verifyLicenseDetails();
            
            PageReference pageRef1 = objNA.saveApplication();

            
        }
        Catch(Exception e) {
            e.getMessage();
        }
        
    }
    private static void createAccount(String type,String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
    } 
    private static void createContact(String accountId){
        contact = new Contact();
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
        contact.Professional_Designations__c = 'ABR;CCIM;CIPS';
        contact.PrimaryMLS__c ='Garden State MLS';
        contact.AdditionalMLS__c ='Coastal MLS' ;
        insert contact;  
    }
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    private static void createLicense(){
        newLicense = new License__c();
        newLicense.name = 'LIC68';
        newLicense.Contact__c = subscription.Contact__c;
        newLicense.License_Type__c = 'Salesperson';
        newLicense.License_State__c = 'VA';
        insert newLicense;
        Subscription_License__c subLicense = new Subscription_License__c();
        subLicense.Subscription__c = subscription.Id;
        subLicense.License__c = newLicense.Id;
        insert subLicense;
    }
    
    private Static MRIS_Application__c createMRISApplication(String applicationType) {
        newApplication = new MRIS_Application__c(); 
        newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
        newApplication.Type__c = 'Agent';
        newApplication.City__c = contact.City__c;
        newApplication.Country__c = contact.Country__c;
        newApplication.County__c = contact.County__c;
        
        Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
        newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
        newApplication.First_Name__c = contact.FirstName;
        newApplication.Last_Name__c = contact.LastName;
        newApplication.License_Number__c = newLicense.Name;
        newApplication.License_Expiration_Date__c = newLicense.License_Expiration_Date__c;
        newApplication.License_State__c = newLicense.License_State__c;
        newApplication.License_Type__c = newLicense.License_Type__c;
        newApplication.Middle_Name__c = contact.Middle_Name__c;
        newApplication.Mobile_Phone__c = contact.Phone;
        newApplication.Nickname__c = contact.Nickname__c;
        newApplication.Company_Code__c = account.Id;
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
        
        insert newApplication;
        
        return newApplication;    
    } 
}