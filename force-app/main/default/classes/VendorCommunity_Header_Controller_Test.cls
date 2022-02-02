@isTest
public class VendorCommunity_Header_Controller_Test {
    
    private Static Account account;
    private Static Contact contact;
    //private Static Subscriptions__c subscription;
    
    public static testMethod void doTestOne() {
        
        generateCornerstone();             
        createAccount('RETS','XYZ123');                   
        createContact(account.Id);                          
        
        User communityUser = new User();
        communityUser.username = contact.Name + contact.Email;
        communityUser.email = contact.Email;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = contact.LastName;
        communityUser.FirstName = contact.FirstName;
        communityUser.FederationIdentifier = contact.Name;
        //Alias is up to 8 char only
        communityUser.Alias = (account.Name.length() > 7) ? account.Name.substring(0, 7) : account.Name; 
        communityUser.ContactId = Contact.Id;
        communityUser.isActive = true;
        communityUser.CommunityNickname = contact.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        System.RunAs(communityUser) { 
            VendorCommunity_Header_Controller obj = new VendorCommunity_Header_Controller(); 
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
        account.Office_Email__c = 'test@gmail.com';
        account.Status__c = 'In Progress';
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
        contact.Status__c = 'In Progress';
        insert contact;  
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }        
    
}