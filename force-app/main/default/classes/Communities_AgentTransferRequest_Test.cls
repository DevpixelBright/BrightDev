@istest(seealldata = true)
private class Communities_AgentTransferRequest_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Related_Agent__c ra;
    
    private static testMethod void doTestOne(){
        generateData();
        createAccount('Residential','XYZ124');
        account.Status__c = 'Active';
        update account;
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        
        Communities_AgentTransferRequest objCATR = new Communities_AgentTransferRequest();
        Communities_AgentTransferRequest.searchBroker('RNET1','TREND');
        Communities_AgentTransferRequest.searchBroker('RNET1','MRIS');
        objCATR.subscriptionId = subscription.Id;
        objCATR.destinationBrokerCode = null;
        objCATR.destinationVerified();                        
    }
     
    private static testMethod void doTestTwo(){
        generateData();
        createAccount('Residential','XYZ124');
        account.Status__c = 'Active';
        update account;
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createRelatedAgent();
        
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
        
        Communities_AgentTransferRequest objCATR = new Communities_AgentTransferRequest();
        objCATR.subscriptionId = subscription.Id;
        createAccount('Residential','XYZ1234');
         account.Status__c = 'Active';
        update account;
        objCATR.destinationBrokerCode = account.Name;
        
        objCATR.selectedPAStr= JSON.serialize(new Set<String>{subscription.Id});
        objCATR.destinationVerified();  
        objCATR.next();
        objCATR.reload();
        objCATR.submitApplication();
        objCATR.continueToReview();
        
    }
    
    private static testMethod void doTestThree(){
        generateData();
        createAccount('Residential','XYZ124');
        account.Status__c = 'Active';
        update account;
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());        
        
        Communities_AgentTransferRequest objCATR = new Communities_AgentTransferRequest();
        objCATR.isChangeEmail = true;
        objCATR.newEmailAddress = 'test@test.com';
        objCATR.next();
        objCATR.isChangeEmail = true;
        objCATR.submitApplication();
    }
    
    private static testMethod void doTestFour() {
        Communities_AgentTransferRequest objCATR = new Communities_AgentTransferRequest();
        objCATR.isChangeEmail = true;
        objCATR.newEmailAddress = 'test@test.com';
        objCATR.next();
        objCATR.destinationBrokerCode = 'ERwtr@123';
        objCATR.destinationVerified();
        objCATR.isChangeEmail = true;
        objCATR.submitApplication();    
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
        //account.Status__c = 'Active';
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
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static void createRelatedAgent() {
        ra = new Related_Agent__c();
        ra.Subscription__c = subscription.Id;
        ra.Assistant_to__c = contact.Id;
        ra.Personal_Assistant_Sub_ID__c = subscription.Id; 
        ra.Personal_Assistant__c = contact.Id; 
        insert ra;
    }
}