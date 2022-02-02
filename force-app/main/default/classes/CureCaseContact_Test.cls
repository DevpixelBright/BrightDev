@istest
private class CureCaseContact_Test {
   private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription; 
    
    private static testMethod void Testone(){
        
        
        Account a1 = createAccount('RETS','XYZ124', 'MRIS');
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        c1.Status__c = 'Active';
        update c1;
        
        User communityUser = createCommunityUser(a1, c1); 
        
        
        Case c = new Case();
        c.Origin = 'CURE Community'; 
        c.SuppliedEmail = 'test@test.com';
        c.Description='from unit test';
        c.Subject ='testing trigger';
        c.Status='New';    
        
        insert c;
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
        //account.Status__c = 'Active';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        account.Status__c = 'In Progress';
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId, String jurisdiction) {
        Contact contact = new Contact();
        contact.Email = 'test@test.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'test@test.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        contact.Service_Jurisdiction__c = jurisdiction;
        contact.Status__c = 'In Progress';
        insert contact;
        
        return contact;
    }
    
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static User createCommunityUser(account acc, contact con) {
        
        User communityUser = new User();
        communityUser.username = con.name + 'test@test.com';
        communityUser.email = con.Email;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = Con.FirstName;
        communityUser.FirstName = Con.LastName;
        communityUser.FederationIdentifier = con.Name;
        communityUser.Alias = acc.Name; //(sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = Con.Id;
        communityUser.isActive = true;
        communityUser.CommunityNickname = con.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'CURE Customer'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        return communityUser;   
    }
}