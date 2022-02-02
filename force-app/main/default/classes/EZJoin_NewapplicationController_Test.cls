/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Test Class for EZJoin_NewapplicationController
*
* SAL- 2118
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Usha
* @version        1.0
* @created        2020-04-17
* @modified       2020-04-21
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Usha
* 2020-04-21      Updated the code to cover submitApplication method
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@isTest
public class EZJoin_NewapplicationController_Test {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Method to create a new MRIS application
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public static testMethod void testOne(){
        EZJoin_NewApplicationController.licenseWrapper lw = new EZJoin_NewApplicationController.licenseWrapper();
        MRIS_Application__c lApp = new MRIS_Application__c();
        Subscription_License__c sublicense = new Subscription_License__c();
        generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Appraiser','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);  
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        try{
            EZJoin_NewapplicationController.submitApplication(application, a2 , 'OfficeSecretary');
        }catch (exception e){}    
        EZJoin_NewapplicationController.verifyLicenseDetails(l1.Name,l1.License_State__c,'Agent');    
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Method to retrieve the picklist values of a field from an object
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public static testMethod void testTwo(){
        generateData();
        Account a1 = createAccount('Residential','XYZ124');
        Account a2 = createAccount('Residential','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id); 
        EZJoin_NewapplicationController.getPicklistValues('Application_Type__c', 'MRIS_Application__c');
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Method to create a new MRIS application
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public static testMethod void testThree(){
        generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Appraiser','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);  
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        try{
            EZJoin_NewapplicationController.submitApplication(application, a2 , 'PersonalAssistant');   
        }catch (exception e){}
    }
    
    public static testMethod void testFour(){
        generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Commercial','XYZ125');
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);  
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        try{
            EZJoin_NewapplicationController.submitApplication(application, a2 , 'PersonalAssistant');   
        }catch (exception e){}
    }
    
    public static testMethod void testFive(){
        generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Association','XYZ125');
        a2.Shareholder_Board__c = 'No';
        a2.Status__c = 'Active';
        update a2;
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);  
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        try{
            EZJoin_NewapplicationController.submitApplication(application, a2 , 'Agent');      
        }catch (exception e){}
    }
    
    public static testMethod void testSix(){
        generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Association','XYZ125');
        a2.Shareholder_Board__c = 'No';
        a2.Status__c = 'Active';
        update a2;
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);  
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        Account acc = [SELECT id, Name FROM Account WHERE Id =: a2.Id];
        acc.Account_Name__c = 'None';
        application.Subscription_Type__c = 'Licensee/Non Realtor';
        try{
            EZJoin_NewapplicationController.submitApplication(application, acc , 'Agent'); 
        }catch (exception e){}
    }
    
    public static testMethod void testSeven(){
         generateData();
        Account a1 = createAccount('Appraiser','XYZ124');
        Account a2 = createAccount('Association','XYZ125');
        a2.Shareholder_Board__c = 'No';
        a2.Status__c = 'Active';
        update a2;
        Contact c1 = createContact(a1.Id); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id);
        s1.Status__c = 'Active';
        update  s1;
        Relationship__c r1 = createRelationship(a1.Id, c1.Id, s1.Id, 'Broker Of Record'); 
        License__c l1 = createLicense(c1.Id, 'Salesperson',s1.Id);
        MRIS_Application__c application = createMRISApplication(a1,c1, l1 , 'New Agent', '12345');
        string query = 'SELECT Id, Name, Nickname__c FROM MRIS_application__c WHERE Id =\'' + application.Id + '\'';
            List <SObject> applications = EzjoinHelper.getApplicationDetails(query);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to generate Test data
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Account object
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @param    type		Type of the Account
* @param    name		Name of the Account
* @return   Account		Returns the newly created Account object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    private static Account createAccount(String type, String name) {
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
        insert account; 
        
        return account;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Contact object
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @param    accountId   Reference AccountId in Contact lookup field
* @return   Account		Returns the newly created contact object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private static Contact createContact(String accountId) {
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
        contact.phone='987654321';
        contact.Email='agent45.test@gmail.com';
        insert contact;
        
        return contact;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Subscription object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    accountId           Reference AccountId in Subscription lookup field
* @param    contactId           Reference contactId in Subscription lookup field
* @return   Subscription		Returns the newly created Subscription object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private Static Subscriptions__c createSubscription(String accountId, String contactId) {
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
        insert subscription; 
        
        return subscription;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Related Agent object
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscriptionId   Reference subscriptionId in Related Agent lookup field
* @return   agents		     Returns the newly created Related Agent  object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private Static Related_Agent__c createAgents(String subscriptionId) {
        Related_Agent__c agents = new  Related_Agent__c();
        agents.Personal_Assistant_Sub_ID__c = subscriptionId ;
        agents.Subscription__c = subscriptionId;
        insert agents; 
        return agents;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Listing Transfer Request object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    a1          Passing Account Id for creating Listing Transfer Request field
* @param    a2          Passing Account Id for creating Listing Transfer Request field
* @param    s1          Passing Subscription Id for creating Listing Transfer Request field
* @param    s2          Passing Subscription Id for creating Listing Transfer Request field
* @param    Status      Status field used while creating field
* @return   agents	    Returns the newly created Related Agent  object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private static Listing_Transfer_Request__c createListingTransferRequest(Id a1, Id a2, Id s1, Id s2, String status ) {
        Listing_Transfer_Request__c LT_Request = new  Listing_Transfer_Request__c();
        LT_Request.StatusCode__c = 'Pending';
        LT_Request.ListingKey__c = '205026134428';
        LT_Request.RequestedOn__c = system.today();
        LT_Request.CanceledOn__c = system.today().addDays(1);
        LT_Request.IsActive__c = true;
        LT_Request.OriginationDecisionOn__c = Date.today();
        LT_Request.DestinationDecisionOn__c = Date.today().addDays(3);
        LT_Request.OriginationOfficeCode__c = a1;
        LT_Request.DestinationOfficeCode__c = a2;
        LT_Request.Requested_By__c = s1;
        LT_Request.Reassigned_To__c = s2;
        LT_Request.ExpirationDate__c = Date.today().addDays(4);
        insert LT_Request;
        return LT_Request;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for Relationship object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    accountId          Passing Account Id for creating Relationship field
* @param    contactId          Passing Account Id for creating Relationship field
* @param    subscriptionId     Passing Subscription Id for creating Relationship field
* @param    relationType       Passing relationType value for Relationship Type field
* @return   Relationship	   Returns the newly created Relationship object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        insert r; 
        
        return r;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for communityUser 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscriptionId          Passing subscriptionId for creating communityUser field
* @return   communityUser			Returns the newly created communityUser reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private static User createCommunityUser(String subscriptionId) {
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
        
        User communityUser = new User();
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
        
        return communityUser;   
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for MRIS Application object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    brokerOffice          Passing Account object for creating Relationship field
* @param    contact               Passing Contact object for creating Relationship field
* @param    license               Passing License object for creating Relationship field
* @param    applicationType       Passing applicationType value for Application Type field
* @param    subscriptionId         Passing subscriptionId value for Comments field
* @return   newApplication	      Returns the newly created MRIS Application object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private Static MRIS_Application__c createMRISApplication(Account brokerOffice, Contact contact, License__c license, String applicationType, String subscriptionId) {
        MRIS_Application__c newApplication = new MRIS_Application__c(); 
        newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
        newApplication.Type__c = 'Assistant';
        newApplication.City__c = contact.City__c;
        newApplication.Country__c = contact.Country__c;
        newApplication.County__c = contact.County__c;
        
        New_Agent_Approval_Days__c daysSetting = new New_Agent_Approval_Days__c();
        daysSetting.Name = applicationType;
        daysSetting.No_Of_Days__c = 19;
        insert daysSetting;
        
        Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues(applicationType).No_Of_Days__c;
        newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
        newApplication.First_Name__c = contact.FirstName;
        newApplication.Last_Name__c = contact.LastName;
        newApplication.License_Number__c = license.Name;
        newApplication.License_Expiration_Date__c = license.License_Expiration_Date__c;
        newApplication.License_State__c = license.License_State__c;
        newApplication.License_Type__c = license.License_Type__c;
        newApplication.Middle_Name__c = contact.Middle_Name__c;
        newApplication.Mobile_Phone__c = contact.Phone;
        newApplication.Nickname__c = contact.Nickname__c;
        newApplication.Company_Code__c = brokerOffice.Id;
        newApplication.Primary_Phone__c = contact.Phone;
        newApplication.Private_Email__c = 'test@test.com';
        newApplication.Private_Phone__c = contact.Phone;
        newApplication.Public_Email__c = 'test@test.com';
        newApplication.Salutation__c = contact.Salutation;
        newApplication.State__c = contact.State__c;
        newApplication.Status__c = 'New'; 
        newApplication.Service_Jurisdiction__c = 'BRIGHT';                   
        newApplication.Zip__c = contact.Zip__c;
        newApplication.Application_Type__c = 'Reinstatement';
        newApplication.Comments__c = '["' + subscriptionId + '"]';
        newApplication.Billing_Jurisdiction__c = 'BRIGHT';
        newApplication.Type__c = 'Assistant';
        insert newApplication;
        
        return newApplication;    
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to create Test data for License object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @param    contactId             Passing Contact object for creating Relationship field
* @param    licenseType           Passing licenseType value for License Type field
* @return   License	              Returns the newly created License object reference
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private Static License__c createLicense(String contactId, String licenseType,string subscriptionId) {
        License__c l = new License__c();
        l.Contact__c = contactId;
        l.Name = 'XYZ4534';
        l.License_State__c = 'VA';
        l.License_Type__c = licenseType;
        l.License_Expiration_Date__c = Date.today();
        insert l;
        Subscription_License__c subLicense = new Subscription_License__c();
        subLicense.Subscription__c = subscriptionId;
        subLicense.License__c = l.Id;
        insert subLicense;
        
        return l;
    } 
    
}