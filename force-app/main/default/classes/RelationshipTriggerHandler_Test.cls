@istest(seealldata = true)
public class RelationshipTriggerHandler_Test {

    Private Static Account account;
    Private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static License__c newLicense;
    Private Static Subscription_License__c newsubscription;
    
    private static testMethod void SubOne(){
         try{
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Inactive';
        update  subscription;
        createRelationship(subscription.Id, 'Responsible Broker',account.Id);
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());

         }
        catch(exception e){
        	System.assertEquals(e.getMessage(),'Insert Failed');
        }
    } 
    private static testMethod void SubTwo(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Inactive';
        update  subscription;
        //insertNewLicense();
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
    } 
    private static testMethod void SubThree(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        //insertNewLicense();
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
    } 
    private static testMethod void SubFour(){
        generateData();
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Inactive';
        update  subscription;
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
    }
    
    private static testMethod void SubFive(){
        generateData();
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createRelationship(subscription.Id, 'Responsible Broker',account.Id);
        ApexPages.currentPage().getParameters().put('Id', subscription.Name);
        Test.setCurrentPage(ApexPages.currentPage());
    } 
    private Static void CreateAccount(String type, String Name){
        account = new account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
 		account.State__c = 'VA';
        account.Status__c = 'Active';
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
        
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    
        private Static void createRelationship(String subscriptionId, String relationType, String brokerOfficeId) {
        Relationship__c relationship = new Relationship__c();
        relationship.Broker_Office__c = brokerOfficeId;
        relationship.Relationship_Type__c= relationType;
        relationship.Status__c = 'Active';
        relationship.MDS_Status__c  = 'Sent';
        relationship.Subscription__c = subscriptionId;
        relationship.Relationship_End_Date__c = system.Today();
        relationship.State__c = 'VA';
        insert relationship;  
    }
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}