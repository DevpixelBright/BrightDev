/***********************************************************************************************
*       Class Name      : BatchTeamDisbandTeamsCallout
*       Date            : 08/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Batch Class is used to do call outs to Team APP API for Team Disband after 14 days from Team Lead in Inactive
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       08/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
global class BatchTeamDisbandTeamsCallout implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global set<string> subNames = new set<string>();
    global set<id> teamIdToSuspend = new set<id>();
    string query = '';
    global BatchTeamDisbandTeamsCallout(set<string> subNames, set<id> teamIdToSuspend)
    {
        system.debug('subNames--'+subNames);
        system.debug('teamIdToSuspend--'+teamIdToSuspend);
        this.subNames = subNames;
        this.teamIdToSuspend = teamIdToSuspend;
        this.query = 'SELECT Id,Team_Name__c,Status_of_Invitation__c, Status_of_team__c, Status_of_Team_Member__c, End_Date__c,'+
            ' Team_Lead_Sub_ID__c, Team_Member_Sub_ID__c, Invitation_Request_ID__c, Team_Request_ID__c FROM Team_Members__c '+
            ' WHERE Team_Lead_Sub_ID__c IN :subNames AND Team_Name__c IN :teamIdToSuspend';
            //' WHERE (Team_Lead_Sub_ID__c IN :subNames OR Team_Member_Sub_ID__c IN :subNames) ';
            //No Need to send whole team to Team App API, as Team APP will take care of the Inactive all team members
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('query---'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Team_Members__c> scope)
    {    
        for (Team_Members__c teamMem : scope){
            string payload = SubscriptionsHandler.getPayload(teamMem);
            try{
                TeamsAppCallout.teamCallout(payload, SubscriptionsHandler.getMethod(teamMem), teamMem.Id);
            }catch(Exception e){
                System.debug('Error-' + e.getMessage());   
                TeamsAppCallout.prepareExceptionLog(payload, e, scope[0].Id);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {   
    }
}