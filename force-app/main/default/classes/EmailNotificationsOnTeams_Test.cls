@istest
public class EmailNotificationsOnTeams_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Relationship__c r;
    
    private Static Teams__c team;
    private Static Team_Members__c teamMember;
    
    private static testMethod void doTestOne(){
        generateData();
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Personal Assitant');
        
        List<Subscriptions__c> subscriptions = [SELECT Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];
        
        createTeam(account.Id, subscriptions[0].Name);
        createTeamMembers(team.Id, subscriptions[0].Name);
    }
    private static testMethod void doTestTwo(){
        generateData();
        createAccount('Association','XYZ124','MRIS');
        String brokerCode = account.Id;
        account.Status__c = 'Active';
        update account;
        createContact(account.Id,'MRIS');
        createSubscription(account.Id, contact.Id,'MRIS');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Authorized Signer');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Broker of Record');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Office Manager');
        createRelationship(account.Id, contact.Id, subscription.Id, 'Personal Assitant');
        
        List<Subscriptions__c> subscriptions = [SELECT Name, SF_Subscription_ID__c, Status__c  
                                                FROM   Subscriptions__c
                                                WHERE  Contact__c = :contact.id];
        
        createTeam2(account.Id, subscriptions[0].Name);
        
        createTeamMembers(team.Id, subscriptions[0].Name);
    }
    
    private static void generateData(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
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
        subscription.City__c = 'Herndon';
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
    
    private Static void createTeam(String accountId, String subscriptionName) {
        
        team = new Teams__c();
        //team.Name = 'Team Name';
        team.Team_Name__c = 'Team Name';
        team.Team_Lead_Sub_ID__c = subscriptionName;
        team.Team_Lead__c = contact.Id;
        team.Office_ID__c = accountId; 
        team.Team_Lead_Email__c = 'test@testlead.com';
        team.Invitation_Status__c = 'Requested';
        team.Team_Request_ID__c = 'aurajfqeuyrqperyqe';
        insert team;        
    }
    private Static void createTeam2(String accountId, String subscriptionName) {
        
        team = new Teams__c();
        //team.Name = 'Team Name';
        team.Team_Name__c = 'Team Name';
        team.Team_Lead_Sub_ID__c = subscriptionName;
        team.Team_Lead__c = contact.Id;
        team.Office_ID__c = accountId; 
        team.Team_Lead_Email__c = 'test@testlead.com';
        team.Invitation_Status__c = 'Requested';
        team.Remainder_Email__c = '7 Day Reminder';
        team.Team_Request_ID__c = 'aurajfqeuyrqperyqe';
        team.Requested_Date__c = system.now();
        insert team;        
    }
    private Static void createTeamMembers(String teamId, String subscriptionName) {
        
        teamMember = new Team_Members__c();
        teamMember.Team_Name__c = teamId;
        teamMember.Team_Member_Sub_ID__c = subscriptionName;
        teamMember.Team_Lead_Sub_ID__c = subscriptionName;
        teamMember.Team_Member_Email__c = 'test@test.com';
        teamMember.Team_Lead_Email__c = 'test@testlead.com';
        teamMember.Updated_Date__c = system.today();        
        insert teamMember;
    }

}