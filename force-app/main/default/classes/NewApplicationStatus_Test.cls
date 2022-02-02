@isTest(seealldata = true)
public class NewApplicationStatus_Test {
    
    private static testMethod void doTestOne() {
        /* Test scenario for new agent application approved */
        generateData();
        Account a1 = createAccount('Association','XYZ124', 'BRIGHT');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'BRIGHT');       
        s1.Status__c = 'Active';
        update  s1;
        
        License__c l1 = createLicense(c1.Id, 'Salesperson');    
        MRIS_Application__c  application = createMRISApplication(a1, c1, l1, 'New Agent'); 
        
        PageReference pageRef = Page.NewApplicationStatus;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('Id', application.Id);
            
        application.Status__c = 'Approved';
        application.Association_Board_Affiliation__c = a1.Id;
        update application;
                            
        NewApplicationStatus obj = new NewApplicationStatus();
        obj.createSubcription();
        obj.createOrder();
        obj.paymentMethodId = '3425432545';
        obj.makePayment();
        obj.activateSubscription();
        obj.updateTrendSub();       
    }
    
    private static testMethod void doTestTwo() {
        /* Test scenario for reinstatement agent application approved */
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Inactive';
        update  s1;                
        
        License__c l1 = createLicense(c1.Id, 'Salesperson');    
        MRIS_Application__c  application = createMRISApplication(a1, c1, l1, 'Reinstatement');
        application.Agent_Subscription_ID__c = s1.Id;
        application.Status__c = 'Approved';
        update application; 
        
        PageReference pageRef = Page.NewApplicationStatus;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('Id', application.Id);
                  
        NewApplicationStatus obj = new NewApplicationStatus();
        obj.createOrder(); 
        obj.activateSubscription();       
    }
    
    private static testMethod void doTestThree() {
        NewApplicationStatus obj = new NewApplicationStatus();
    }    
    
    private static testMethod void doTestFour() {
        PageReference pageRef = Page.NewApplicationStatus;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('Id', '123');  
        ApexPages.currentPage().getParameters().put('Type', 'New');  
        NewApplicationStatus obj = new NewApplicationStatus();
    }    
    
    @isTest
    private static void validateLoginName() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124','BRIGHT');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'BRIGHT');
       	s1.Status__c = 'Inactive';
        update  s1;
        License__c l1 = createLicense(c1.Id, 'Salesperson');    
        MRIS_Application__c  application = createMRISApplication(a1, c1, l1, 'Reinstatement');
        application.Agent_Subscription_ID__c = s1.Id;
        application.Status__c = 'Approved';
        application.Service_Jurisdiction__c = 'BRIGHT';
        application.Billing_Jurisdiction__c = 'Lancaster';
        application.Association_Board_Affiliation__c = a1.Id;
        update application;
        s1.SFDC_Application__c = application.Id;
        PageReference pageRef = Page.NewApplicationStatus;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('Id', application.Id);  
        ApexPages.currentPage().getParameters().put('Type', 'New'); 
        NewApplicationStatus  nas = new NewApplicationStatus();
        nas.trendLoginName = 'red@.-';
        nas.validateLoginName();
        nas.createSubcription();
    }
    @isTest
    private static void validateLoginNamewithoutloginname() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124','TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Inactive';
        update  s1;
        PageReference pageRef = Page.NewApplicationStatus;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('Id', '123');  
        ApexPages.currentPage().getParameters().put('Type', 'New'); 
        NewApplicationStatus  nas = new NewApplicationStatus();
        //nas.trendLoginName = '';
        nas.createSubcription();
        nas.validateLoginName();
    }
    private static Account createAccount(String type, String name, String jurisdiction) {
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
        account.Type = 'Association';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
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
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String jurisdiction) {
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
		subscription.Service_Jurisdiction__c = jurisdiction;
		subscription.TREND_Login_Name__c = 're@.-';        
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
    
    private Static MRIS_Application__c createMRISApplication(Account brokerOffice, Contact contact, License__c license, String applicationType) {
        MRIS_Application__c newApplication = new MRIS_Application__c(); 
        newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
        newApplication.Type__c = 'Agent';
        newApplication.City__c = contact.City__c;
        newApplication.Country__c = contact.Country__c;
        newApplication.County__c = contact.County__c;
        
        Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
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
        
        insert newApplication;
        
        return newApplication;    
    } 
}