@isTest
private class Inactive_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    public static testMethod void doTestOne() {
        
        generateCornerstone();             
        createAccount('Residential','XYZ123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        Subscriptions__c sSubscription = new Subscriptions__c();
        
        subscription.Status__c = 'Active';
        update subscription;
        
        sSubscription = [SELECT Id, Name,Public_Email__c, SF_Subscription_ID__c,AgentKey__c,Contact__c FROM Subscriptions__c WHERE  id = :subscription.id];         
        Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];   
        
        PageReference pageRef = Page.Communities_Inactives;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', subscription.Name);
        
        User communityUser = createCommunityUser(subscription.Name);                    
        System.RunAs(communityUser) { 
            Communities_Inactives1 obj = new Communities_Inactives1();
            try{
                Communities_Inactives1.submitSubscription1('www.test.com');
            }
            catch(exception ex){
                system.debug('---Exception ex---' + ex);
            }
            try{
                Communities_Inactives1.submitSubscription('www.test.com');
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
        //subscription.Primary__c = true;
        subscription.Public_Email__c = 'test@test.com';
        subscription.Import_Source__c = 'JSMLS';
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }  
    private static User createCommunityUser(String subscriptionId) {
        
        User communityUser = [Select ID,NAME  from user where  FederationIdentifier = :subscriptionId];
        if(communityUser == null){
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
            
            communityUser = new User();
            
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
            
            Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
            communityUser.Profile = p;
            communityUser.ProfileId = p.id;
            insert(communityUser);
        }
        return communityUser;   
    }
    
}