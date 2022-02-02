public without sharing class TeamMembersHandler 
{
    static set<string> teamIds= new set<string>();
    
    public static void teamSubscription()
    {
        for(Team_Members__c teamMem : (list<Team_Members__c>)Trigger.New)
        {
            if((Trigger.Old == null && teamMem.Status_of_Invitation__c == 'Accepted' && teamMem.Status_of_team__c =='Active') ||
               (Trigger.Old != null && 
                ((teamMem.Status_of_Invitation__c != ((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Status_of_Invitation__c && 
                  (teamMem.Status_of_Invitation__c == 'Accepted' || ((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Status_of_Invitation__c == 'Accepted')) ||
                 (teamMem.Status_of_team__c != ((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Status_of_team__c && 
                  (teamMem.Status_of_team__c == 'Active' || ((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Status_of_team__c == 'Active'))))
              )
            {
                if(teamMem.Team_Name__c != null)
                    teamIds.add(teamMem.Team_Name__c);
                if(Trigger.OldMap !=null && ((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Team_Name__c != null)
                    teamIds.add(((Team_Members__c)Trigger.OldMap.get(teamMem.Id)).Team_Name__c);
            }
            system.debug('teamIds------'+teamIds);
        }
        /*
        if(!teamIds.isEmpty()){
            Zuora_Team_Invoice.createOrUpdateTeamSubscription(teamIds);
        }*/
		
    }
    public static void updatedDateConversion()
    {
        for(Team_Members__c team : (list<Team_Members__c>)Trigger.New)
        {
            if(team.Updated_Date__c != null){
                
                Datetime dt = team.Updated_Date__c;
                system.debug('***dt'+dt);
                String dtEST = dt.format('dd-MM-yyyy', 'EST');
                system.debug('***dtEST'+dtEST);
                String[] strDate = dtEST.split('-');
                Integer myIntDate = integer.valueOf(strDate[0]);
                Integer myIntMonth = integer.valueOf(strDate[1]);
                Integer myIntYear = integer.valueOf(strDate[2]);
                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                
                if((Trigger.oldMap == null || ((Team_Members__c)Trigger.oldMap.get(team.Id)).Updated_Date__c != team.Updated_Date__c) && team.Updated_Date__c != null && 
                   (Trigger.oldMap == null || ((Team_Members__c)Trigger.oldMap.get(team.Id)).Status_of_Invitation__c != team.Status_of_Invitation__c) && team.Status_of_Invitation__c != null){
                       if(team.Status_of_Invitation__c == 'Accepted')
                       {
                           team.Start_Date__c = d;
                       }
                       else if(team.Status_of_Invitation__c == 'Removed')
                       {
                           team.End_Date__c = d;
                       }
                       else if(team.Status_of_Invitation__c == 'Rejected')
                       {
                           team.Rejected_Date__c = d;
                       }
                   }
                if(team.Updated_Date__c != null && team.Team_Lead_Sub_ID__c == team.Team_Member_Sub_ID__c && 
                   team.Status_of_Invitation__c == 'Accepted' && team.Start_Date__c == null)
                {
                    team.Start_Date__c = d;
                }
                if(team.Team_Lead_Sub_ID__c == team.Team_Member_Sub_ID__c && 
                   team.Status_of_Invitation__c == 'Accepted' &&
                   String.isBlank(team.Status_of_Team_Member__c))
                {
                    team.Status_of_Team_Member__c = 'Active';
                }
            }
        }
    }
    /* public static void TLDateConversion()
{
for(Team_Members__c teamMember : (list<Team_Members__c>)Trigger.New)
{
if(teamMember.Updated_Date__c != null){
Datetime dt = teamMember.Updated_Date__c;
system.debug('***dt'+dt);
String dtEST = dt.format('dd-MM-yyyy', 'EST');
system.debug('***dtEST'+dtEST);
String[] strDate = dtEST.split('-');
Integer myIntDate = integer.valueOf(strDate[0]);
Integer myIntMonth = integer.valueOf(strDate[1]);
Integer myIntYear = integer.valueOf(strDate[2]);
Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);

if(teamMember.Updated_Date__c != null && teamMember.Team_Lead_Sub_ID__c == teamMember.Team_Member_Sub_ID__c && 
teamMember.Status_of_Invitation__c == 'Accepted' && teamMember.Start_Date__c == null)
{
teamMember.Start_Date__c = d;
}
}
}

}*/
}