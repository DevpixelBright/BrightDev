/***********************************************************************************************
*       Class Name      : TeamLeadInactiveDisbandTeam_PB
*       Date            : 08/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is used to call from Process builder in Invocable action after 14 days from Team Lead in Inactive
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       08/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class TeamLeadInactiveDisbandTeam_PB
{
    @InvocableMethod
    public static void inactivateTeamLead(list<Id> subIds)
    {
        set<string> subNames = new set<string>();
        set<id> teamIdToSuspend = new set<id>();
        set<string> teamLeadsubNameToSuspend = new set<string>();
        list<Subscriptions__c> subscriptions = [SELECT Id, Name FROM Subscriptions__c WHERE Id IN :subIds ];	//AND Status__c = 'Inactive'];
        for(Subscriptions__c sub : subscriptions)
        {
            subNames.add(sub.Name);
        }
        if(!subNames.isEmpty())
        {
            
            //Update Team Lead End date after 14 days if not end dated.
            list<Team_Members__c> teamMembers = [SELECT Id, Status_of_Team_Member__c, End_Date__c,Team_Lead_Sub_ID__c, 
                                                 Team_Member_Sub_ID__c,Team_Name__c FROM Team_Members__c 
                                                 WHERE Team_Member_Sub_ID__c IN :subNames AND Status_of_Team_Member__c = 'Inactive'
                                                 AND Team_Name__r.Status__c = 'Active'];
            for(Team_Members__c teamMem : teamMembers)
            {
                //Add Team Ids to Suspend after Lead Inactivation
                teamIdToSuspend.add(teamMem.Team_Name__c);
                //teamMem.Status_of_Team__c = 'Inactive';//teamMem.Team_Name__r.Status__c;
                if(teamMem.End_Date__c == null)
                {
                    teamMem.End_Date__c = system.today();
                }
            }
            if(teamMembers != null && !teamMembers.isEmpty())
            {
                update teamMembers;
                //Disband Team if No new Team lead is assigned after 14 days
                list<Teams__c> teams = [SELECT Id, Name, Team_Name__c, Status__c, Team_Lead_Sub_ID__c FROM Teams__c 
                                        WHERE Team_Lead_Sub_ID__c IN :subNames 
                                        AND Status__c = 'Active' 
                                        AND Id IN :teamIdToSuspend];
                for(Teams__c team : teams)
                {
                    teamLeadsubNameToSuspend.add(team.Team_Lead_Sub_ID__c);
                    team.Status__c  = 'Inactive';
                    team.Status_Reason__c = 'System Disband';
                }
                if(teams != null && !teams.isEmpty())
                {
                    //When Team is Inactive, all team members get inactive from process builder
                    update teams;
                }
            }
            //Set Batch size to 1 to do callout of each team member/Lead one by one
            database.executeBatch(new BatchTeamDisbandTeamsCallout(teamLeadsubNameToSuspend, teamIdToSuspend), 1);
        }
    }
    
}