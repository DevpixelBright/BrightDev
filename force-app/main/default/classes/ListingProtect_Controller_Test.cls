@isTest
public class ListingProtect_Controller_Test
{
    private static Account createAccount(String companyType)
    {
        Account a = new Account();
        a.Name = 'ADA1231';
        a.Type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.Company_Type__c = companyType;
        return a;
    }
    
    private static Contact createContact(String accountId)
    {
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = accountId;
        c.Salutation = 'Mr.';
        c.QAS_Mailing_County__c = 'Arlington';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';  
        return c;
    }
    
    private static void createSubscription(String relationType,String companyType)
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
               
        Account a = new Account();
        a = createAccount(companyType);
        insert a;
        
        Contact c = new Contact();
        c = createContact(a.id);
        insert c;
        
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = '3044809';
        s.Primary__c = true;
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123111';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'email@something.com';
        s.Private_Email__c = 'email@something.com';
        insert s;
        
        Relationship__c r = new Relationship__c();
        r = createRelationship(a.id,c.id,s.id,relationType);
        insert r;
    }
    
    private static Relationship__c createRelationship(String accountID,String contactId,String subscriptionId,String relationType)
    {
        Relationship__c r = new Relationship__c();
        r.Relationship_Type__c = relationType;
        r.Contact__c = contactId;
        r.Broker_Office__c = accountID;
        r.Subscription__c = subscriptionId;
        r.Relationship_End_Date__c = System.Today().addDays(5);
        return r;
    }
    
    static testMethod void testValidSubscription() 
    {       
        createSubscription('Broker of Record','Broker Office');
        Subscriptions__c subs = [SELECT id,Name from Subscriptions__c LIMIT 1];
               
        PageReference protectPage = Page.ListingProtect;
        Test.setCurrentPage(protectPage);
             
        ListingProtect_Controller validSubscription = new ListingProtect_Controller();  
        validSubscription.SubscriptionId = subs.Name;
        validSubscription.LoadDetails();
        validSubscription.OptIn = true;
        validSubscription.Agreed = true;
        validSubscription.Initials = 'TEST';
        validSubscription.Submit();
        validSubscription.Cancel();
        validSubscription.Refresh();
        
        ListingProtect_Controller invalidSubscriptions = new ListingProtect_Controller();  
        invalidSubscriptions.LoadDetails();
        try{invalidSubscriptions.Submit();} catch(Exception e){} 
        
    }
    
    static testMethod void testInvalidRelation() 
    {
        createSubscription('Invalid','Broker Office');
        Subscriptions__c subs = [SELECT id,Name from Subscriptions__c LIMIT 1];
                
        PageReference protectPage = Page.ListingProtect;
        Test.setCurrentPage(protectPage);
        
        ListingProtect_Controller invalidRelation = new ListingProtect_Controller();  
        invalidRelation.SubscriptionId = subs.Name;
        invalidRelation.LoadDetails();
        try{invalidRelation.Submit();} catch(Exception e){}
        invalidRelation.Refresh();
    }
}