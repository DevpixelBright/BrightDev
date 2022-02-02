@isTest(seealldata=true)
public class SubscriptionOfficeChangeHandlerTest {
        private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Related_Association__c association;
    private static Relationship__c relationship;  
  
    private static testMethod void doTestOne() {            
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription;       
        
        subscription.Subscription_Type__c = 'REALTOR Appraiser Shareholder - Quarterly';
        subscription.Website__c = 'www.newwebsite.com';
        update subscription;
        
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        
        subscription.Mobile_Phone__c = '(301) 838-7102';
        update subscription;  

    }
    
    private static testMethod void doTestTwo() {            
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription;
        
        List<Subscription_Role__c> subRoles = new List<Subscription_Role__c>();
        
        Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = subscription.Id;
        subRole.Role__c = 'Agent';
        subRole.Status__c = 'Active';
        subRole.sysPrRoleKey__c = '2343234567';
        subRoles.add(subRole); 
        
        Subscription_Role__c subRole1 = new Subscription_Role__c();
        subRole1.Subscription__c = subscription.Id;
        subRole1.Role__c = 'Status Active';
        subRole1.Status__c = 'Active';
        subRole1.sysPrRoleKey__c = '2343234569';
        subRoles.add(subRole1); 
        
        insert subRoles;
        
        createAccount('Residential','XYZ124');
        
        subscription.Related_Location_Broker_Office__c = account.Id; 
        subscription.Status__c = 'Inactive';
        subscription.Status_Change_Reason__c = 'Terminated';
        update subscription; 
    
    }
    
    private static testMethod void doTestThree() {            
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription;
        
        List<Subscription_Role__c> subRoles = new List<Subscription_Role__c>();
        
        Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = subscription.Id;
        subRole.Role__c = 'Agent';
        subRole.Status__c = 'Active';
        subRole.sysPrRoleKey__c = '2343234567';
        
        Subscription_Role__c subRole1 = new Subscription_Role__c();
        subRole1.Subscription__c = subscription.Id;
        subRole1.Role__c = 'Status Active';
        subRole1.Status__c = 'Active';
        subRole1.sysPrRoleKey__c = '2343234569';
        subRoles.add(subRole1); 
        
        insert subroles;
        
        createAccount('Residential','XYZ124');
        
        subscription.Subscription_Type__c = 'Personal Assistant';
        subscription.Website__c = 'www.newwebsite.com';
        update subscription;  

    }
    
    private static testMethod void doTestFour() {            
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);

        subscription.Status__c = 'Active';
        update subscription;
        
        List<Subscription_Role__c> subRoles = new List<Subscription_Role__c>();
        
        Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = subscription.Id;
        subRole.Role__c = 'Agent';
        subRole.Status__c = 'Active';
        subRole.sysPrRoleKey__c = '2343234567';
        subRoles.add(subRole); 
        
        Subscription_Role__c subRole1 = new Subscription_Role__c();
        subRole1.Subscription__c = subscription.Id;
        subRole1.Role__c = 'Status Active';
        subRole1.Status__c = 'Active';
        subRole1.sysPrRoleKey__c = '2343234569';
        subRoles.add(subRole1); 
        
        insert subRoles;
        
        subscription.Status__c = 'Inactive';
        subscription.Status_Change_Reason__c = 'Terminated';
        update subscription; 
        
        Subscription_Role__c subRole2 = new Subscription_Role__c();
        subRole2.Subscription__c = subscription.Id;
        subRole2.Role__c = 'Status Inactive';
        subRole2.Status__c = 'Active';
        subRole2.sysPrRoleKey__c = '2343234587';
        insert subRole2;
        
        Test.StartTest();
        
        createAccount('Residential','XYZ124');
        
        subscription.Related_Location_Broker_Office__c = account.Id;         
        subscription.Status__c = 'Active';
        subscription.Status_Change_Reason__c = 'Reinstate';
        subscription.Status_Change_Fee__c = 'No Charge';
        update subscription; 
    }
    private static testMethod void doTestFive() {            
        generateData();
        SubscriptionOfficeChangeHandler ss = new SubscriptionOfficeChangeHandler();
        ss.test1();
        ss.test2();
    }
    private static testMethod void doTestSix() {            
        generateData();
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        subscriptionRelationship(subscription.Id, 'Broker Of Record');
        relationship.Status__c = 'Inactive';
        relationship.Relationship_End_Date__c = System.today();
        update relationship;
    }
    private static void createAccount(String type,String name){
        account = new Account();
        account.name = name;
        account.type = type;
        account.Account_Name__c = 'Test Account';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
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
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = 'Test Subscription';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        //subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.County__c = 'Fairfax';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Addl_Display_Name__c = 'Test';
        subscription.QAS_Mailing_Country__c = 'USA';
        subscription.QAS_Mailing_County__c = 'Fairfax';
        subscription.State__c = 'VA';
        subscription.QAS_Mailing_Street_Direction__c = 'NORTH';
        subscription.Street_Name__c = 'First';
        subscription.Street_Number__c ='1275';
        subscription.Street_Number_Suffix__c = NULL;
        subscription.Unit__c = '1';
        subscription.QAS_Mailing_Unit_Type__c = 'SU';
        subscription.Zip__c ='20002';
        subscription.Zip_4__c = NULL;
        subscription.QAS_Mailing_POBox__c = NULL;
        subscription.QAS_Mailing_Record_Type__c = NULL;
        subscription.Copy_Address_to_Billing__c = true;
        subscription.QAS_Mailing_Record_Type__c = 'P';
        subscription.QAS_Billing_Record_Type__c = 'P';
        subscription.Primary__c = true;
        subscription.Mobile_Phone__c = '(301) 838-7101';
        insert subscription; 
    }
    
    private static void subscriptionAssociation(String subName) {
       
        association = new Related_Association__c();
        association.Status__c = 'Active';
        association.Subscription__c= subName;
        insert association;

    } 
    
    private Static void subscriptionRelationship(String subName, String relationType) {
        relationship = new Relationship__c();
        relationship.Relationship_Type__c = relationType;
        relationship.Subscription__c= subName;
        relationship.Status__c = 'Active';
        relationship.MDS_Status__c = 'Success';
        relationship.sysPrRoleKey__c = '145236987';
        
        insert relationship;
        
    }   
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }                 
}