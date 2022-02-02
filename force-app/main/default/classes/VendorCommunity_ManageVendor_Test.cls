@istest(seealldata = true)
public class VendorCommunity_ManageVendor_Test {
    
    private static testMethod void doTestOne() {        
        generateData();
        Account a1 = createAccount('RETS','XYZ124', 'MRIS');
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        c1.Status__c = 'Active';
        update c1;
        
        User communityUser = createCommunityUser(a1, c1);             
        System.RunAs(communityUser) {                   
            
            VendorCommunity_ManageVendor obj = new VendorCommunity_ManageVendor();
            obj.loadAccounts();
            
        }        
    }
    
    private static testMethod void doTestTwo() {        
        generateData();
        Account a1 = createAccount('RETS','XYZ124', 'MRIS');
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        c1.Status__c = 'Active';
        update c1;
        
        User communityUser = createCommunityUser(a1, c1);             
        System.RunAs(communityUser) {                           
            VendorCommunity_ManageVendor obj = new VendorCommunity_ManageVendor();
            obj.loadAccounts();
            
        }        
    }
    private static testMethod void doTestThree() {        
        generateData();
        Account a1 = createAccount('RETS','XYZ124', 'MRIS');
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'MRIS'); 
        c1.Status__c = 'Active';
        update c1;
        
        User communityUser = createCommunityUser(a1, c1);             
        System.RunAs(communityUser) {                   
            
            VendorCommunity_ManageVendor obj = new VendorCommunity_ManageVendor();
            obj.loadAccounts();
        }        
    }
    private static testMethod void doTestFour() {        
        generateData();
        Account a1 = createAccount('RETS','XYZ124', 'TREND');
        
        a1.Status__c = 'Active';
        update a1;
        
        Contact c1 = createContact(a1.Id, 'TREND'); 
        c1.Status__c = 'Active';
        update c1;
        
        User communityUser = createCommunityUser(a1, c1);             
        System.RunAs(communityUser) {                           
            VendorCommunity_ManageVendor obj = new VendorCommunity_ManageVendor();
            obj.loadAccounts();
            
        }        
    }
    private static testMethod void doTestFive() {  
        VendorCommunity_ManageVendor obj = new VendorCommunity_ManageVendor();
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
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        return communityUser;   
    }
    
}