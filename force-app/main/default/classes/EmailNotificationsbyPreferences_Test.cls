@istest(SeeAllData = true)
public class EmailNotificationsbyPreferences_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static License__c newLicense;
    private Static MRIS_Application__c newApplication;
    private Static Relationship__c r;
    
   /** ApplicationsEmailNotifications trigger will trigger the corresponding  methods based on the events */
    private static testMethod void doTestOne(){
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        CreateLicense();
        createMRISApplication('MRIS','New Agent');        
    }
    private static testMethod void doTestTwo(){
         createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        CreateLicense();
        createMRISApplication('MRIS','New Agent');
        newApplication.Reminder_Email__c = True;
        update newApplication; 
          
    }
    private static testMethod void doTestThree(){
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        CreateLicense();
        createMRISApplication('MRIS','Agent Transfer');
        //newApplication.Application_Type__c = 'Agent Transfer';
        newApplication.Destination_Broker_Office__c = account.id;
        newApplication.Reminder_Email__c = True;
        update newApplication;        
    }
     private static testMethod void doTestFour(){
        createAccount('Association','XYZ124','TREND');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'TREND');
        createSubscription(account.Id, contact.Id,'TREND');
         createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        CreateLicense();
        createMRISApplication('TREND','New Agent');
        newApplication.Status__c = 'Expired';
        update newApplication;        
    }
    private static testMethod void doTestFive(){
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        CreateLicense();
        createMRISApplication('MRIS','Agent Transfer');
        //newApplication.Application_Type__c = 'Agent Transfer';
        newApplication.Destination_Broker_Office__c = account.id;
        newApplication.Status__c='Approved';
        update newApplication; 
        newApplication.Status__c='Completed';
        update newApplication;         
    }
   private static testMethod void doTestSix(){
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        CreateLicense();
        createMRISApplication('MRIS','Agent Transfer');
        //newApplication.Application_Type__c = 'Agent Transfer';
        newApplication.Destination_Broker_Office__c = account.id;
        newApplication.Reminder_Email__c = True;
        update newApplication;         
    }

    private static void createAccount(String type,String name, String jurisdiction){
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
        account.Primary_Service_Jurisdiction__c = jurisdiction; 
        insert account; 
    } 
    private static void createContact(String accountId, String jurisdiction){
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
        contact.Professional_Designations__c = 'ABR;CCIM;CIPS';
        contact.PrimaryMLS__c ='Garden State MLS';
        contact.AdditionalMLS__c ='Coastal MLS' ;
        contact.Service_Jurisdiction__c = jurisdiction;
        insert contact;  
    }
    private Static void createSubscription(String accountId, String contactId, String jurisdiction){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Private_Email__c = 'test@test.com';
        subscription.Service_Jurisdiction__c = jurisdiction;
        subscription.TREND_Login_Name__c = 'TREND002';
        
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    private static void createLicense(){
        newLicense = new License__c();
        newLicense.name = 'LIC68';
        newLicense.Contact__c = subscription.Contact__c;
        newLicense.License_Type__c = 'Salesperson';
        newLicense.License_State__c = 'VA';
        insert newLicense;
        Subscription_License__c subLicense = new Subscription_License__c();
        subLicense.Subscription__c = subscription.Id;
        subLicense.License__c = newLicense.Id;
        insert subLicense;
    }
    
    public static void createMRISApplication(String mls,String applicationtype){
        
        
        newApplication = new MRIS_Application__c(); 
        
        if(String.isBlank(account.id)){
            newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
            newApplication.Type__c = 'Agent';
        }
        else {
            Account assoc = [SELECT Id, Account_Name__c FROM Account WHERE Id = :account.id];
            if(assoc.Account_Name__c.contains('None'))
                newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
            else
                newApplication.Subscription_Type__c = 'Realtor/Shareholder';
            newApplication.Type__c = 'Agent';
            newApplication.Association_Board_Affiliation__c = account.id;
        }        
        
        newApplication.City__c = contact.City__c;
        newApplication.Country__c = contact.Country__c;
        newApplication.County__c = contact.County__c;
        if(applicationtype == 'New Agent'){
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
        }
        newApplication.First_Name__c = contact.FirstName;
        newApplication.Last_Name__c = contact.LastName;
        newApplication.License_Number__c = newLicense.Name;
        newApplication.License_Expiration_Date__c = newLicense.License_Expiration_Date__c;
        newApplication.License_State__c = newLicense.License_State__c;
        newApplication.License_Type__c = newLicense.License_Type__c;
        newApplication.Middle_Name__c = contact.Middle_Name__c;
        newApplication.Mobile_Phone__c = contact.Phone;
        newApplication.Nickname__c = contact.Nickname__c;
        // newApplication.NRDS_ID__c = nrdsId;
        newApplication.Company_Code__c = account.id;
        newApplication.Primary_Phone__c = contact.Phone;
        newApplication.Private_Email__c = contact.Email;
        newApplication.Private_Phone__c = contact.Phone;
        newApplication.Public_Email__c = contact.Email;
        newApplication.Salutation__c = contact.Salutation;
        newApplication.State__c = contact.State__c;
        newApplication.Status__c = 'New'; 
        newApplication.Service_Jurisdiction__c = mls;    
        newApplication.Comments__c='["a06J000000HdijXIAR"]';
        
        newApplication.Zip__c = contact.Zip__c;
        //newApplication.Application_Type__c = 'New Agent';
        newApplication.Application_Type__c = applicationtype;
        insert newApplication;
        
    }
    private Static void createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        insert r; 
    }
}