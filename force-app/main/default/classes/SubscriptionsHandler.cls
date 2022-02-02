public class SubscriptionsHandler 
{
    public static void checkAndUpdateTeamMembersOnSubInactive(Map<Id,Subscriptions__c> newSubMap, Map<Id,Subscriptions__c> oldSubMap)
    {
        set<string> inactiveSubNames = new set<string>();
		for(Subscriptions__c sub : newSubMap.values())
        {
            if((sub.Status__c != oldSubMap.get(sub.Id).Status__c && sub.Status__c == 'Inactive') ||
               (sub.Related_Location_Broker_Office__c != oldSubMap.get(sub.Id).Related_Location_Broker_Office__c && 
                !BORUtilityClass.fetchActiveOfficesFromBrokerage(new List<String>{oldSubMap.get(sub.Id).Related_Location_Broker_Office__c}).contains(sub.Related_Location_Broker_Office__c)))
            {
                inactiveSubNames.add(sub.Name);
            }
        }
        if(!inactiveSubNames.isEmpty())
        {
            list<Team_Members__c> teamMembers = [SELECT Invitation_Request_ID__c,Status_of_Invitation__c,Team_Lead_Sub_ID__c,
                                                 Team_Member_Sub_ID__c,Start_Date__c,Status_of_Team_Member__c  FROM Team_Members__c 
                                                 WHERE Team_Member_Sub_ID__c IN :inactiveSubNames AND Status_of_Team_Member__c != 'Inactive'];
            for(Team_Members__c tm : teamMembers)
            {
                //Inactivate Team member if subscription is inactive only if member is not lead
                if(tm.Team_Member_Sub_ID__c != tm.Team_Lead_Sub_ID__c){
                    if(tm.Status_of_Team_Member__c == 'Active' && tm.Start_Date__c != null){
                        tm.End_Date__c = System.today();
                    }
                    tm.Status_of_Team_Member__c = 'Inactive';
                }else if(tm.Team_Member_Sub_ID__c == tm.Team_Lead_Sub_ID__c){
                    //Team Lead will Inactive but not enddated
                    tm.Status_of_Team_Member__c = 'Inactive';
                }
            }
            if(teamMembers != null && teamMembers.size()>0)
            {
                update teamMembers;
            }
            
            //Inactive Team if Team Request was not approved/Rejected 
            inActivateTeamsRequested(inactiveSubNames);
            
        }
    }
    
    public static void checkTeamMembersOnInactive(Map<Id,Subscriptions__c> newSubMap, Map<Id,Subscriptions__c> oldSubMap)
    {
        set<string> inactiveSubNames = new set<string>();
		for(Subscriptions__c sub : newSubMap.values())
        {
            if(sub.Status__c != oldSubMap.get(sub.Id).Status__c && sub.Status__c == 'Inactive')
            {
                inactiveSubNames.add(sub.Name);
            }
        }
        if(!inactiveSubNames.isEmpty())
        {
            inActiveSubscriptionTeamsAppCallout(inactiveSubNames);
        }
    }
    
    public static void inActiveSubscriptionTeamsAppCallout(set<string> subscriptionIdList)
    {
        list<Team_Members__c> teamMembers = [SELECT Invitation_Request_ID__c,Status_of_Invitation__c,Team_Lead_Sub_ID__c,Team_Member_Sub_ID__c,
                                             Team_Request_ID__c FROM Team_Members__c 
                                             WHERE Team_Member_Sub_ID__c IN :subscriptionIdList AND Status_of_Team_Member__c != 'Inactive'];
        for(Team_Members__c tm : teamMembers)
        {
            //system.debug('Mem---'+tm.Team_Member_Sub_ID__c +'--'+ tm.Team_Lead_Sub_ID__c);
            //Send Callout to teams if team member is not team lead
            if(tm.Team_Member_Sub_ID__c != tm.Team_Lead_Sub_ID__c){
                TeamsAppCallout.teamCallout(getPayload(tm), getMethod(tm), tm.Id);
            }
        }
        
        //Send Callout to teams if Team Request was not approved/Rejected 
        list<Teams__c> teams = [SELECT Id, Name, Team_Name__c, Status__c, Team_Request_ID__c FROM Teams__c 
                                WHERE Team_Lead_Sub_ID__c IN :subscriptionIdList AND Invitation_Status__c = 'Requested' AND Status__c != 'Inactive'];
        for(Teams__c team : teams)
        {
            TeamsAppCallout.teamCallout(getInactiveTeamPayload(team), 'sfteamlead', team.Id);
        }
    }
    
    public static string getPayload(Team_Members__c tMember)
    {
        string eventType;
        eventType = tMember.Status_of_Invitation__c == 'Pending' ? 'Terminated' : 'Inactive';
        return TeamsAppCallout.prepareTeamsPayload(tMember, eventType, getGuid(tMember));
    }
    
    public static string getInactiveTeamPayload(Teams__c team)
    {
        return JSON.serialize(new TeamsModal.TeamRequest('Terminated', TeamsAppCallout.dateTimeGmtLong(), team.Team_Request_ID__c));
    }
    
    public static string getMethod(Team_Members__c tMember)
    {
        return tMember.Team_Member_Sub_ID__c == tMember.Team_Lead_Sub_ID__c ? 'sfteamlead' : 'sfteammember';
    }
    
    public static string getGuid(Team_Members__c tMember)
    {
        return tMember.Team_Member_Sub_ID__c == tMember.Team_Lead_Sub_ID__c ? tMember.Team_Request_ID__c : tMember.Invitation_Request_ID__c;
    }
    
    static void inActivateTeamsRequested(set<string> subNames)
    {
        list<Teams__c> teams = [SELECT Id, Name, Team_Name__c, Status__c FROM Teams__c 
                                WHERE Team_Lead_Sub_ID__c IN :subNames AND Invitation_Status__c = 'Requested' AND Status__c != 'Inactive'];
        for(Teams__c team : teams)
        {
            team.Status__c  = 'Inactive';
        }
        if(teams != null && !teams.isEmpty())
        {
            //When Team is Inactive, all team members get inactive from process builder
            update teams;
        }
    }
}