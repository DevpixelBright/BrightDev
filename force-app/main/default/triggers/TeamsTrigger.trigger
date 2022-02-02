Trigger TeamsTrigger on Teams__c (before insert, before update, after insert, after update) {
    list<Teams__c> teams = new list<Teams__c>();
    list<Teams__c> teamDisband = new list<Teams__c>();
    list<Teams__c> Day7Remainder = new list<Teams__c>();
    list<Teams__c> Day11Remainder = new list<Teams__c>();
    List<Id> teamIds = new List<Id>();
    List<Id> OffCodeList=new List<Id>();
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        TeamsTriggerHandler.sendBrightKeyToTeams(Trigger.New, Trigger.OldMap);
        TeamsTriggerHandler.createTeamSubscription(Trigger.New, Trigger.OldMap);
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        TeamsTriggerHandler.updatedDateConversion();
    }
    for(Teams__c team : Trigger.New)
    {
        if(Trigger.isAfter && Trigger.isInsert && team.Invitation_Status__c == 'Requested'){
            teams.add(team);
            teamIds.add(team.Id);
            OffCodeList.add(team.Office_ID__c);
        } 
        if(Trigger.isAfter && Trigger.isUpdate && team.Status__c == 'Inactive'){
            teamDisband.add(team); 
        }
        if(Trigger.isAfter && Trigger.isUpdate && team.Invitation_Status__c == 'Requested' && team.Remainder_Email__c == '7 Day Reminder'){
            Day7Remainder.add(team); 
        }
        if(Trigger.isAfter && Trigger.isUpdate && team.Invitation_Status__c == 'Requested' && team.Remainder_Email__c == '11 Day Reminder'){
            Day11Remainder.add(team); 
        }
    } 
    
    if(!teams.isEmpty()){
        EmailNotificationsOnTeams tEmail = new EmailNotificationsOnTeams();
        tEmail.sendNotificationEmail(teams);
    }
    //EmailAsyncProcess.createSignleEmails(teamIds,OffCodeList);
    if(!teamDisband.isEmpty()){
        EmailNotificationsOnTeams tEmail = new EmailNotificationsOnTeams();
        tEmail.disbandNotificationEmail(teamDisband);
    }
    if(!Day7Remainder.isEmpty()){
        EmailNotificationsOnTeams tEmail = new EmailNotificationsOnTeams();
        tEmail.sendNotificationEmail2(Day7Remainder);
    }
    if(!Day11Remainder.isEmpty()){
        EmailNotificationsOnTeams tEmail = new EmailNotificationsOnTeams();
        tEmail.sendNotificationEmail3(Day11Remainder);
    }

}