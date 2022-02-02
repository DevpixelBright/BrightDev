@isTest
public class TeamsModalTest 
{   
    @isTest
    public static void testTeamsModal()
    {
        TeamsModal.TeamMemberRequest memReq = new TeamsModal.TeamMemberRequest('test','test','test');
        TeamsModal.TeamMemberRequest memReq2 = new TeamsModal.TeamMemberRequest('test','test','test','test');
        TeamsModal.TeamRequest teamReq = new TeamsModal.TeamRequest('test','test','test');
        TeamsModal.TeamRequest teamReq2 = new TeamsModal.TeamRequest('test','test','test','test');
        TeamsModal.IntegrationLog ReqLog = new TeamsModal.IntegrationLog('test','test','test','test','test','test','test');
        TeamsModal.IntegrationLog ReqLog2 = new TeamsModal.IntegrationLog();
    }
    
}