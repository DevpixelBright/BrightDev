@isTest
public class TeamLeadInactiveDisbandTeam_PBTest 
{
    @testSetup
    public static void createTestData()
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account account = new Account();
        account.Name = 'TEST567';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
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
        insert contact;
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test1@test.com';
        insert subscription; 
        
        Teams__c ts = new Teams__c();
        //ts.Name = 'Team Name';
        ts.Team_Name__c = 'Team Name';
        ts.Team_Lead_Sub_ID__c = subscription.Name;
        ts.Office_ID__c = account.Id; 
        ts.Team_Lead_Email__c = 'test@testlead.com';
        insert ts;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team_Name__c = ts.Id;
        tm.Team_Member_Sub_ID__c = subscription.Name;
        tm.Team_Lead_Sub_ID__c = subscription.Name;
        tm.Team_Member_Email__c = 'test@test.com';
        tm.Team_Lead_Email__c = 'test@testlead.com';
        tm.Status_of_Invitation__c = 'Pending';
        insert tm;
        
    }
    
    @isTest
    public static void testInactivateTeamLead()
    {
        list<Subscriptions__c> subList = [SELECT Id,Name,Status__c,Status_Change_Reason__c FROM Subscriptions__c];
        list<string> subIdList = new list<string>();
        for(Subscriptions__c sub : subList){
            subIdList.add(sub.Id);
        }
        TeamLeadInactiveDisbandTeam_PB.inactivateTeamLead(subIdList);
        
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        Teams__c ts = new Teams__c();
        //ts.Name = 'Team Name';
        ts.Team_Name__c = 'Team Name';
        ts.Team_Lead_Sub_ID__c = subList[0].Name;
        ts.Office_ID__c = account.Id; 
        ts.Team_Lead_Email__c = 'test@testlead.com';
        insert ts;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team_Name__c = ts.Id;
        tm.Team_Member_Sub_ID__c = subList[0].Name;
        tm.Team_Lead_Sub_ID__c = subList[0].Name;
        tm.Team_Member_Email__c = 'test@test.com';
        tm.Team_Lead_Email__c = 'test@testlead.com';
        tm.Status_of_Invitation__c = 'Pending';
        insert tm;
        
        
        tm.Status_of_Invitation__c = 'Accepted';
        tm.Status_of_Team_Member__c = 'Inactive';
        update tm;
        //Test.setMock(HttpCalloutMock.class, new MockTeamsAppHttpResponseGenerator());
        
        for(Subscriptions__c sub : subList){
            sub.Status__c = 'Inactive';
            sub.Status_Change_Reason__c = 'Suspended';		//Reinstate
        }
        update subList;
        
        ts.Status__c = 'Active';
        update ts;
        
        system.debug('team----'+[SELECT Id, Name, Status__c,Team_Lead_Sub_ID__c FROM Teams__c]);
        TeamLeadInactiveDisbandTeam_PB.inactivateTeamLead(subIdList);
    }
    
    @isTest
    public static void testInactivateTeamLeadMock()
    {
        list<Subscriptions__c> subList = [SELECT Id,Name,Status__c,Status_Change_Reason__c FROM Subscriptions__c];
        list<string> subIdList = new list<string>();
        for(Subscriptions__c sub : subList){
            subIdList.add(sub.Id);
        }
        TeamLeadInactiveDisbandTeam_PB.inactivateTeamLead(subIdList);
        
        for(Subscriptions__c sub : subList){
            sub.Status__c = 'Inactive';
            sub.Status_Change_Reason__c = 'Suspended';		//Reinstate
        }
        
        update subList;
        
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        Teams__c ts = new Teams__c();
        //ts.Name = 'Team Name';
        ts.Team_Name__c = 'Team Name';
        ts.Team_Lead_Sub_ID__c = subList[0].Name;
        ts.Office_ID__c = account.Id; 
        ts.Team_Lead_Email__c = 'test@testlead.com';
        insert ts;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team_Name__c = ts.Id;
        tm.Team_Member_Sub_ID__c = subList[0].Name;
        tm.Team_Lead_Sub_ID__c = subList[0].Name;
        tm.Team_Member_Email__c = 'test@test.com';
        tm.Team_Lead_Email__c = 'test@testlead.com';
        tm.Status_of_Invitation__c = 'Pending';
        insert tm;
        
        Test.setMock(HttpCalloutMock.class, new MockTeamsAppHttpResponseGenerator());
        
        system.debug('team----'+[SELECT Id, Name, Status__c,Team_Lead_Sub_ID__c FROM Teams__c]);
        TeamLeadInactiveDisbandTeam_PB.inactivateTeamLead(subIdList);
    }
    
}