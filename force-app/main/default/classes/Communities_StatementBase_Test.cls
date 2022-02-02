@istest(seealldata = true)
public class Communities_StatementBase_Test {
  private static testMethod void doTestOne() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'MRIS');
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'MRIS');       
        s1.Status__c = 'Active';
        update  s1;     
        User communityUser = createCommunityUser(s1);             
        System.RunAs(communityUser) {                   
        
            Communities_StatementBase_Controller obj = new Communities_StatementBase_Controller();
              
        }        
    }
    private static testMethod void doTestTwo() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');    
        s1.Status__c = 'Active';
        update  s1; 
        User communityUser = createCommunityUser(s1);  
        System.RunAs(communityUser) {                           
            Communities_StatementBase_Controller obj = new Communities_StatementBase_Controller();
                        
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
        account.Status__c = 'Active';
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
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
  private static User createCommunityUser(Subscriptions__c subscription) {
        User communityUser;
      if(subscription.Service_Jurisdiction__c == 'TREND'){
         communityUser = [Select ID,NAME  from user where  FederationIdentifier = :subscription.Name];
      }
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
                                          WHERE  id = :subscription.Id];        
        
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