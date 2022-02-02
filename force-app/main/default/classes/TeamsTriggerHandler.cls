/***********************************************************************************************
*       Class Name      : TeamsTriggerHandler
*       Date            : 10/19/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is Handler for TeamsTrigger
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/19/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class TeamsTriggerHandler 
{
    public static void sendBrightKeyToTeams(list<Teams__c> newTeam, Map<Id, Teams__c> oldTeamMap)
    {
        for(Teams__c team : newTeam)
        {
            if(!String.isBlank(team.Bright_Team_Key__c) && (oldTeamMap == null || String.isBlank(oldTeamMap.get(team.Id).Bright_Team_Key__c)))
            {
                TeamsAppCallout.teamCallout(JSON.serialize(new TeamsModal.TeamKeyRequest(team.Bright_Team_Key__c, team.Team_Request_ID__c)), 'sfsetteamkey', team.Id);
            }
        }
    }
    
    public static void createTeamSubscription(list<Teams__c> newTeam, Map<Id, Teams__c> oldTeamMap)
    {
        list<string> teamIds = new list<string>();
        for(Teams__c team : newTeam)
        {
            if(team.Invitation_Status__c == 'Approved' && team.Team_Option__c == 'Premium' && 
               team.Team_Lead__c != null && 
               (oldTeamMap == null || oldTeamMap.get(team.Id).Invitation_Status__c != 'Approved' || oldTeamMap.get(team.Id).Team_Option__c != 'Premium')
              )
            {
                teamIds.add(team.Id);
            }
        }
        /*
        if(!teamIds.isEmpty()){
            Zuora_Team_Invoice.createTeamSubscriptionRequest(teamIds);
        }*/
    }
    
    public static void updatedDateConversion()
    {
        for(Teams__c team : (list<Teams__c>)Trigger.New)
        {
            if(team.Status__c == 'Inactive')
            {
                Datetime dt;
                if(team.Status_Reason__c == 'System Disband'){
                    dt = system.now();
                }else{
                    dt = team.Updated_Date__c;
                }
                system.debug('***dt'+dt);
                String dtEST = dt.format('dd-MM-yyyy', 'EST');
                system.debug('***dtEST'+dtEST);
                String[] strDate = dtEST.split('-');
                Integer myIntDate = integer.valueOf(strDate[0]);
                Integer myIntMonth = integer.valueOf(strDate[1]);
                Integer myIntYear = integer.valueOf(strDate[2]);
                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                
                if(//(Trigger.oldMap == null || ((Teams__c)Trigger.oldMap.get(team.Id)).Updated_Date__c != team.Updated_Date__c) && team.Updated_Date__c != null && 
                    (Trigger.oldMap == null || ((Teams__c)Trigger.oldMap.get(team.Id)).Status__c != team.Status__c) && team.Status__c != null){
                        if(team.Status__c == 'Inactive')
                        {
                            team.Disband_Date__c = d;
                        }
                    }
            }
        }
    }
    
}