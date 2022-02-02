/**
Test Class For	: Communities_BrokerAuthorizationRequest
Createdby	: BLT India
 */
@isTest
private class Communities_BrokerAuthorizationReq_Test {
	
	private static string accountType;
	private static string accountName;
	private static string jurisdiction;
	//private static string VendorId;
	//private static string Website;
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        accountType = 'RETS';
        accountName = 'Test 075';
        jurisdiction = 'Bright';
          
        Account accObj = createAccount(accountType, accountName, jurisdiction);
        accObj.status__c = 'Active';
        update accObj;
        
        Contact conObj = createContact(accObj.Id, jurisdiction);
        Subscriptions__c subObj = createSubscription(accObj.Id, conObj.Id, jurisdiction);
        subObj.Status__c = 'Active';
        update subObj;
        
        New_Agent_Approval_Days__c customSettingObj = createCustomSettings();
        
        PageReference myVfPage = Page.Communities_BrokerAuthorizationRequest;
		Test.setCurrentPage(myVfPage);
		// Put Id into the current page Parameters
		ApexPages.currentPage().getParameters().put('id',subObj.Name);
		
        Communities_BrokerAuthorizationRequest commBrokAuthObj = new Communities_BrokerAuthorizationRequest();
        commBrokAuthObj.getProductType();
        commBrokAuthObj.VendorId = accObj.Id;
        commBrokAuthObj.Website = 'www.test.com';
        commBrokAuthObj.selectedProdType = 'IDX';
        Communities_BrokerAuthorizationRequest.getAccountDetails(accountName, 'IDX');
        commBrokAuthObj.saveRequestApplication();
    }
    
     static testMethod void myUnitTestException() {
        // TO DO: implement unit test
        try{
        accountType = 'RETS';
        accountName = 'Test 075';
        jurisdiction = 'Bright';
        
        Account accObj = createAccount(accountType, accountName, jurisdiction);
        accObj.status__c = 'Active';
        update accObj;
        
        Contact conObj = createContact(accObj.Id, jurisdiction);
        Subscriptions__c subObj = createSubscription(accObj.Id, conObj.Id, jurisdiction);
        subObj.Status__c = 'Active';
        update subObj;
        
        //New_Agent_Approval_Days__c customSettingObj = createCustomSettings();
        
        PageReference myVfPage = Page.Communities_BrokerAuthorizationRequest;
		Test.setCurrentPage(myVfPage);
		// Put Id into the current page Parameters
		ApexPages.currentPage().getParameters().put('id',subObj.Name);
		
        Communities_BrokerAuthorizationRequest commBrokAuthObj = new Communities_BrokerAuthorizationRequest();
        commBrokAuthObj.VendorId = accObj.Id;
        commBrokAuthObj.Website = 'www.test.com';
        commBrokAuthObj.selectedProdType = 'IDX';
        Communities_BrokerAuthorizationRequest.getAccountDetails(accountName, 'IDX');
        commBrokAuthObj.saveRequestApplication();
        }
        catch(exception e){
        	System.assertEquals(e.getMessage(),'Attempt to de-reference a null object');
        }
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
        account.Status__c = 'In Progress';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        
        insert account;
        return account;
    }
    
    private static Contact createContact(String accountId, String jurisdiction) {
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
        contact.Service_Jurisdiction__c = jurisdiction;
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
        subscription.TREND_Login_Name__c = 'TREND002';    

        insert subscription;
        return subscription;
    }
    
    private Static New_Agent_Approval_Days__c createCustomSettings(){
    	New_Agent_Approval_Days__c daysSetting = new New_Agent_Approval_Days__c();
        daysSetting.Name = 'Broker Authorization Request';
        daysSetting.No_Of_Days__c = 14;
        insert daysSetting;
        return daysSetting;
    }
}