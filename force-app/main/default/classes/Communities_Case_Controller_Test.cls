@isTest
private class Communities_Case_Controller_Test{

    private Static Account account; 
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    public static testmethod void doTestOne(){
        
        generateCornerstone();
        Account account = new Account();
        account.Name = 'Swathi';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        account.Unit_Type__c ='FRNT, FRONT';
        account.Unit__c='Test Unit';
        account.Zip_4__c ='2122';
        account.Street_Direction__c='SW, SOUTHWEST';
        account.Street_Type__c='ACRES, ACRES';
        account.Street_Name__c='Test Street';
        account.Street_Number_Suffix__c='Test Suffix';
        account.Street_Number__c='Test Streetnumber';
        account.Primary_Service_Jurisdiction__c = 'BRIGHT';
        insert account; 
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        //contact.Name='Test prime';
        contact.phone='987654321';
        contact.Email='agent45.test@gmail.com';
        insert contact;
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '123456';
        subscription.Contact__c = contact.Id;
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
        subscription.Related_Location_Broker_Office__c = account.Id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Bright_Agent_Key__c ='Testkey'; 
        subscription.Service_Jurisdiction__c = 'BRIGHT';
        
        insert subscription; 
        
        User communityUser = new User();
        communityUser.username = subscription.AgentKey__c + subscription.Public_Email__c;
        communityUser.email = subscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = contact.LastName;
        communityUser.FirstName = contact.FirstName;
        communityUser.FederationIdentifier = subscription.Name;
        //Alias is up to 8 char only
        communityUser.Alias = (subscription.Name.length() > 7) ? subscription.Name.substring(0, 7) : subscription.Name; 
        communityUser.ContactId = subscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = subscription.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
         
        System.RunAs(communityUser){        
        
            /* Community cases controller intiation */
            List<Case> cList = new List<Case>();
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cList);
            Communities_Case_Controller obj = new Communities_Case_Controller();
            obj = new Communities_Case_Controller(controller);
            
            /* Create Case */
            String caseId = Communities_Case_Controller.remoteCreateCase(subscription.Id, 'Helpdesk', '', 'Test desc', 'BRIGHT', '123456', 'listAgent', 'brok');
            caseId = Communities_Case_Controller.remoteCreateCase(subscription.Id, 'Compliance', 'Compliance', 'Test desc', 'BRIGHT', '123456', 'listAgent', 'brok');
            caseId = Communities_Case_Controller.remoteCreateCase(subscription.Id, 'Compliance', 'Report a Violation', 'Test desc', 'BRIGHT', '123456', 'listAgent', 'brok');
            caseId = Communities_Case_Controller.remoteCreateCase(subscription.Id, 'Compliance', 'Appeals', 'Test desc', 'BRIGHT', '123456',  'listAgent', 'brok');
            String attachId = Communities_Case_Controller.attachFile(caseId, '', 'test.jpg', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            attachId = Communities_Case_Controller.attachFile(caseId, attachId, 'test.jpg', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            
            obj.filter = true;
            obj.filterValue = 'Not Started';
            obj.filterValue1 = 'Helpdesk';
            List<Case> subscriberCases = obj.subscriberCases;
            List<String> departments = obj.departments;
            List<SelectOption> complianceTypes = obj.complianceTypes;
            List<String> status = obj.status;
            List<SelectOption> subscriptionOptions = obj.subscriptionOptions;
            Integer totalPages = obj.totalPages;
            Integer pageNumber = obj.pageNumber;
            obj.first();
            obj.last();
            obj.previous();
            obj.next();
            obj.refresh();
            String createCaseSelDepart = obj.createCaseSelDepart;
            String searchKey = obj.searchKey;
            List<SelectOption> createCaseDeparts = obj.createCaseDeparts;
            system.assert(createCaseDeparts != null);
        }
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }        

}