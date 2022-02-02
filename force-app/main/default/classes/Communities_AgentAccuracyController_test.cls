@isTest
private class Communities_AgentAccuracyController_test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Compliance_Violation__c ComplianceViolation;
    private static Compliance_Fine__c Compliancefine ;
    private static string qcFinePositive = 'QCDATA5';
    private static string qcFineNegative = 'CRDATA5';
    
    public static testMethod void doTestOne() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id);
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        s1.Contact_Type__c='Broker';
        update  s1;
        
        string mlsNo = '0001122';
        createCompliance_Appeal_Config();
        ComplianceViolation = createComplianceViolation(s1.Id, mlsNo, s1.Name);
        system.debug('---ComplianceViolation--->'+ComplianceViolation);
        
        list<Compliance_Fine__c> comFineList = new list<Compliance_Fine__c>();
        
        Compliance_Fine__c objFine1 = createCompliancefine(ComplianceViolation.Id, mlsNo, s1.Id, s1.Name+'-0', qcFineNegative);
        insert objFine1;
        
        Compliance_Fine__c objFine2 = createCompliancefine(ComplianceViolation.Id, mlsNo, s1.Id, s1.Name+'-1', qcFineNegative);
        comFineList.add(objFine2);
        
        Compliance_Fine__c objFine3 = createCompliancefine(ComplianceViolation.Id, mlsNo, s1.Id, s1.Name+'-2'+'check-test', null);
        objFine3.Violation__c = null;
        objFine3.Notification_Type__c = '';
        objFine3.Last_Date_to_Appeal__c = null;
        objFine3.status__c = null;
        comFineList.add(objFine3);
        
        insert comFineList;
        system.debug('---Compliancefine--->'+Compliancefine);
                                  
        PageReference pageRef = Page.Communities_AgentTransferListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', s1.name);
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {
            Communities_AgentAccuracyController obj = new Communities_AgentAccuracyController();
            Communities_AgentAccuracy_Print_export objExp = new Communities_AgentAccuracy_Print_export();
        }        
    }
    
    public static testMethod void doTestTwo() {
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);       
        s1.Status__c = 'Active';
        s1.Contact_Type__c='Broker';
        update s1;
                                  
        PageReference pageRef = Page.Communities_AgentTransferListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', s1.name);
        User communityUser = createCommunityUser(s1.Id);
        System.RunAs(communityUser) {
            Communities_AgentAccuracyController obj = new Communities_AgentAccuracyController();
            Communities_AgentAccuracy_Print_export objExp = new Communities_AgentAccuracy_Print_export();
        }        
    }
    
    private static testMethod void exceptionHandle(){
        test.startTest();
        try{
        	Communities_AgentAccuracyController obj = new Communities_AgentAccuracyController();
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
            system.assertEquals(true, e.getMessage().contains('No Subscription'));
        }
        
        try{
            Communities_AgentAccuracy_Print_export objExp = new Communities_AgentAccuracy_Print_export();
        }catch(exception e){
            system.debug('---exception--->'+e.getMessage());
            system.assertEquals(true, e.getMessage().contains('No Subscription'));
        }
        test.stopTest();
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
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        return communityUser;   
    }
    private Static Compliance_Violation__c createComplianceViolation(String subscriptionId, string mslNumber, string name){
        Compliance_Violation__c ComplianceViolation = new Compliance_Violation__c();
        ComplianceViolation.Name = name;
        ComplianceViolation.Subscription_ID__c = subscriptionId;
        ComplianceViolation.Subscription__c = subscriptionId;
        ComplianceViolation.MLS_Number__c = mslNumber;
        ComplianceViolation.Date_of_Fine__c = system.today();
        insert ComplianceViolation;
        return ComplianceViolation; 
    }
    
    private Static Compliance_Fine__c createCompliancefine(string complianceViolationId, string mlsNumber, string subId, string name, string qcFineCode){
        Compliance_Fine__c Compliancefine = new Compliance_Fine__c();
        Compliancefine.Compliance_Violation__c = complianceViolationId;
        Compliancefine.Name = name;
        Compliancefine.Date_of_Fine__c = date.today();
        Compliancefine.QC_Fine_Code__c = qcFineCode; //'CRDATA75';
        
        Compliancefine.Last_Date_to_Appeal__c = date.today() +20;
        Compliancefine.Notification_Type__c = 'Test Voilation';
        Compliancefine.Status__c = 'Pending';
        Compliancefine.Violation__c = 'Delinquent Violation';
        Compliancefine.Subscription_ID__c = subId;
        Compliancefine.Subscription__c = subId;
        
        //insert Compliancefine;
        return Compliancefine;  
    }
    private static void createCompliance_Appeal_Config(){
        Compliance_Appeal_Config__c objcomAppConf = new Compliance_Appeal_Config__c();
        objcomAppConf.Appeal_Timer__c = 20;
        insert objcomAppConf;
    }
}