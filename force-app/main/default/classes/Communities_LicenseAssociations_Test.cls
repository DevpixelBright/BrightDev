@istest(seealldata = true)
private class Communities_LicenseAssociations_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static License__c newLicense;
    
    private static testMethod void addLicenceTestOne(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        ApexPages.currentPage().getParameters().put('sid', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.subscriptionId = subscription.Id;
        objCLA.licenseSelected = null;
        objCLA.addLicense();
        objCLA.saveLicense();
        objCLA.removeLicense();
        objCLA.removeOnConfirm();
        objCLA.closeModal();
    } 
    
    
    private static testMethod void addLicenceTestTwo(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;  
        insertNewLicense();
        ApexPages.currentPage().getParameters().put('sid', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.subscriptionId = subscription.Id;
        objCLA.licenseSelected = newLicense.Id;
        objCLA.addLicense();
        objCLA.saveLicense();
        objCLA.removeLicense();
        objCLA.removeOnConfirm();
        objCLA.closeModal();
    } 
    private static testMethod void addLicenceTestThree(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        insertNewLicense();
        ApexPages.currentPage().getParameters().put('sid', '');
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.subscriptionId = subscription.Id;
        objCLA.licenseSelected = null;
        objCLA.addLicense();
        objCLA.saveLicense();
        objCLA.removeLicense();
       // objCLA.licenses();
        //objCLA.removeOnConfirm();
        //objCLA.closeModal();
    } 
    private static testMethod void addLicenceTestFour(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        Related_Association__c newAssociation = new Related_Association__c();
        newAssociation.Subscription__c = subscription.Id;
        newAssociation.Primary__c = true;
        newAssociation.Start_Date__c = Date.valueOf('2017-08-03');
        insert newAssociation;
        ApexPages.currentPage().getParameters().put('sid', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.newAssociation = newAssociation;
        objCLA.subscriptionId = subscription.Id;
        objCLA.associationSelected = newAssociation.ID;
        objCLA.addAssociation();
        objCLA.saveAssociation();
        
        
    } 
    private static testMethod void addAssociationTestOne(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        ApexPages.currentPage().getParameters().put('sid', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.subscriptionId = subscription.Id;
        objCLA.associationSelected = null;
        objCLA.addAssociation() ;
        objCLA.saveAssociation();
    } 
    
    private static testMethod void saveprofessionalDetailsandMLSTest(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;  
        ApexPages.currentPage().getParameters().put('sid', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        Communities_LicenseAssociations objCLA = new Communities_LicenseAssociations();
        objCLA.saveProfessionalDesignations(); 
        objCLA.saveMLS();
    }
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
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
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        // subscription.Service_Jurisdiction__c = account.Service_Jurisdiction__pc;
        //subscription.TREND_Login_Name__c = 'xyz';
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    private static void insertNewLicense(){
        newLicense = new License__c();
        newLicense.Contact__c = subscription.Contact__c;
        newLicense.License_Type__c = 'Salesperson';
        insert newLicense;
        Subscription_License__c subLicense = new Subscription_License__c();
        subLicense.Subscription__c = subscription.Id;
        subLicense.License__c = newLicense.Id;
        subLicense.SoftDelete__c = 'No';
        insert subLicense;
    }
}