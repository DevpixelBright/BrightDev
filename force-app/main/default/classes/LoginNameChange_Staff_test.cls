@isTest
public class LoginNameChange_Staff_test {
	
    @isTest
    private static void loginNameMethodBright() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'BRIGHT');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'BRIGHT');
        s1.BRIGHT_LoginName__c = 'red@.-';        
        s1.Status__c = 'Active';
        update  s1;
        test.startTest();
        LoginUniqueness__c lu = createcustomsetting('Endpoint', 'https://talend.tst.brightmls.com/services/LoginNameService');
        LoginUniqueness__c lu1 = createcustomsetting('SoapAction', 'http://www.talend.org/service/ValidateLoginName');
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        User u = createUser();
        System.runAs(u) {
            LoginNameChange_Staff ln = new LoginNameChange_Staff();
            ln.newLoginName = 'green@.-';
            ln.validateLoginName();
            ln.saveLoginName();
            ln.cancel();
            try {
            	LoginName.isAvailable(null, '90867653');
            }
            catch(exception ex) {}
        }
        test.stopTest();
    }
    @isTest
    private static void loginNameMethodTrend() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');
        s1.TREND_Login_Name__c = 'red@.-';
        s1.Status__c = 'Active';
        update  s1;
        test.startTest();
        LoginUniqueness__c lu = createcustomsetting('Endpoint', 'https://talend.tst.brightmls.com/services/LoginNameService');
        LoginUniqueness__c lu1 = createcustomsetting('SoapAction', 'http://www.talend.org/service/ValidateLoginName');
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        User u = createUser();
        System.runAs(u) {
            LoginNameChange_Staff ln = new LoginNameChange_Staff();
            ln.newLoginName = 'green@.-';
            ln.validateLoginName();
            ln.saveLoginName();
            ln.cancel();
        }
        test.stopTest();
    }
    @isTest
    private static void loginNameMethodNoJurisdiction() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'MRIS');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'MRIS');
        s1.Status__c = 'Active';
        update  s1;
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        LoginNameChange_Staff ln = new LoginNameChange_Staff();
    }
    @isTest
    private static void loginNameLengthError() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');
        s1.TREND_Login_Name__c = 'red@.-';
        s1.Status__c = 'Active';
        update  s1;
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        LoginNameChange_Staff ln = new LoginNameChange_Staff();
        ln.newLoginName = 'g#';
        ln.validateLoginName();
    }
    @isTest
    private static void loginNameNumericError() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');
        s1.TREND_Login_Name__c = 'red@.-';
        s1.Status__c = 'Active';
        update  s1;
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        LoginNameChange_Staff ln = new LoginNameChange_Staff();
        ln.newLoginName = '345623';
        try {
        	ln.validateLoginName();
        }
        catch(exception ex){}
    }
     @isTest
    private static void loginNameCharacterError() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');
        s1.TREND_Login_Name__c = 'red@.-';
        s1.Status__c = 'Active';
        update  s1;
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        LoginNameChange_Staff ln = new LoginNameChange_Staff();
        ln.newLoginName = 'red@$5';
        try {
        	ln.validateLoginName();
        }
        catch(exception ex){}
    }
    @isTest
    private static void loginNameDuplicateError() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');
        s1.TREND_Login_Name__c = 'red@.-';
        s1.Status__c = 'Active';
        update  s1;
        PageReference pr = Page.LoginNameChange_Staff;
        pr.getParameters().put('Id', s1.Id);
        Test.setCurrentPage(pr);
        LoginNameChange_Staff ln = new LoginNameChange_Staff();
        ln.newLoginName = 'red@.-';
        try {
        	ln.validateLoginName();
        }
        catch(exception ex){}
    }
    //test data
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
        subscription.Public_Email__c = 'test@gmail.com';
    	//subscription.Private_Email__c = 'test@gmail.com';
        subscription.Service_Jurisdiction__c = jurisdiction;
        subscription.TREND_Login_Name__c = 'old@gmail.com';
        insert subscription; 
        
        return subscription;
    }
    
    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', profileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserbrighttrend@testorg.com');
        insert u;
        return u;
    }
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    private static LoginUniqueness__c createcustomsetting(String name, String value) {
        LoginUniqueness__c lu = new LoginUniqueness__c();
        lu.Name = name;
        lu.Value__c = value;
        insert lu;
        return lu;
    }
}