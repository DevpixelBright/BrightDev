@isTest
private class Communities_Inactives_Test{
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    public static testMethod void doTestOne() {
        
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        Subscriptions__c sSubscription = new Subscriptions__c();
        
        subscription.Status__c = 'Inactive';
        update subscription;
        
        sSubscription = [SELECT Id, Name,Public_Email__c, SF_Subscription_ID__c,AgentKey__c,Contact__c FROM Subscriptions__c WHERE  id = :subscription.id];         
        Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];   
       
        User communityUser = new User();
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        communityUser.username = sSubscription.AgentKey__c + sSubscription.Public_Email__c;
        communityUser.email = sSubscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = contact.LastName;
        communityUser.FirstName = contact.FirstName;
        communityUser.FederationIdentifier = sSubscription.Name;
        //Alias is up to 8 char only
        communityUser.Alias = (sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = sSubscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = sSubscription.Name;
        
        insert(communityUser);
        
        System.RunAs(communityUser) { 
            PageReference pageRef = Page.Communities_Inactives;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', sSubscription.Name);
            Communities_Inactives obj = new Communities_Inactives();
            try{
                Communities_Inactives.submitSubscription('/customers/apex/Communities_SOA?id=' + sSubscription.Name);
            }
            catch(exception ex){
                system.debug('---Exception ex---' + ex);
            }
        }
        
    }
    
    public static testMethod void doTestTwo() {
            try{
                Communities_Inactives.submitSubscription('/customers/apex/Communities_SOA?id=Name');
            }
            catch(exception ex){
                system.debug('---Exception ex---' + ex);
            }
    }
    
    public static testMethod void doTestFour() {
            try{
                Communities_Inactives.submitSubscription('/customers/apex/Communities_SOA');
            }
            catch(exception ex){
                system.debug('---Exception ex---' + ex);
            }
    }
    public static testMethod void doTestThree() {
        
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        Subscriptions__c sSubscription = new Subscriptions__c();
        
        sSubscription = [SELECT Id, Name,Public_Email__c, SF_Subscription_ID__c,AgentKey__c,Contact__c FROM Subscriptions__c WHERE  id = :subscription.id];         
        Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];   
       
        User communityUser = new User();
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        communityUser.username = sSubscription.AgentKey__c + sSubscription.Public_Email__c;
        communityUser.email = sSubscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = contact.LastName;
        communityUser.FirstName = contact.FirstName;
        communityUser.Alias = (sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = sSubscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = sSubscription.Name;
        
        insert(communityUser);
        
        System.RunAs(communityUser) { 
            try{
                Communities_Inactives.submitSubscription('/customers/apex/Communities_SOA?id=' + sSubscription.Name);
            }
            catch(exception ex){
                system.debug('---Exception ex---' + ex);
            }
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
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Personal Assistant';
        subscription.Status__c = 'Inactive';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Import_Source__c = 'JSMLS';
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }        
    
}