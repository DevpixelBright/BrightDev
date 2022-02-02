/***********************************************************************************************
*       Class Name      : TeamsAppCallout
*       Date            : 08/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is used to do Callout to Teams APP API and capture logs
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       08/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class TeamsAppCallout {
    
    public static void teamCallout(String payload, string methodName, string parentId) 
    {
        if(!System.isBatch())
        {
            teamCalloutFuture(payload, methodName, parentId);
        }else{
            teamCalloutApex(payload, methodName, parentId);
        }
    }
    
    @future(callout=true)
    public static void teamCalloutFuture(String payload, string methodName, string parentId) 
    {
        teamCalloutApex(payload, methodName, parentId);
    }
    
    public static void teamCalloutApex(String payload, string methodName, string parentId) 
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        Teams_App_API_Configuration__mdt teamsConfig = [SELECT API_Key__c,End_Point_URL__c FROM Teams_App_API_Configuration__mdt WHERE MasterLabel = 'Teams App Configuration'];
        req.setHeader('x-api-key', teamsConfig.API_Key__c);
        req.setHeader('Content-Type', 'application/json');
        string endPointURL = teamsConfig.End_Point_URL__c + methodName;
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setBody(payload);
        
        system.debug('payload---'+payload);
        system.debug('req---'+req);
        
        try{
            teamCaptureResponse(payload, h.send(req), parentId);
        }catch(Exception e){
            TeamsModal.IntegrationLog newLog = prepareExceptionLog(payload, e, parentId);
            IntegrationLogUtils.createLog(newLog);
        }
    }
    
    public static void teamCaptureResponse(String payload, HttpResponse response, string parentId) 
    {
        TeamsModal.IntegrationLog newLog = prepareLog(payload, response, parentId);
        IntegrationLogUtils.createLog(newLog);
    }
    
    public static TeamsModal.IntegrationLog prepareLog(String payload, HttpResponse response, string parentId)
    {
        TeamsModal.IntegrationLog newLog = new TeamsModal.IntegrationLog();
        newLog.request = payload;
        newLog.response = response.getBody();
        newLog.statusCode = String.valueof(response.getStatusCode());
        newLog.statusMessage = response.getStatus();
        newLog.logType = 'Teams App';
        newLog.methodType = 'POST';
        newLog.parentId = parentId;
        
        return newLog;
    }
    
    public static TeamsModal.IntegrationLog prepareExceptionLog(String payload, Exception exp, string parentId)
    {
        TeamsModal.IntegrationLog newLog = new TeamsModal.IntegrationLog();
        newLog.request 		= payload;
        newLog.StackTrace	= exp.getStackTraceString();
        newLog.response 	= exp.getMessage();
        newLog.statusCode 	= 'Exception';
        newLog.statusMessage = exp.getMessage();
        newLog.logType 		= 'Teams App';
        newLog.methodType 	= 'POST';
        newLog.parentId 	= parentId;
        
        return newLog;
    }
    
    public static string dateTimeGmtLong()
    {
        return system.now().formatGMT('EEE, d MMM yyyy HH:mm:ss')+' GMT';
    }
    
    public static string prepareTeamsPayload(Team_Members__c tMember, string eventType, string guId)
    {
        string payload = '';
        //Check Member is Lead ?
        if(eventType == 'Terminated')
        {
            if(tMember.Team_Member_Sub_ID__c == tMember.Team_Lead_Sub_ID__c)
            {
                payload = JSON.serialize(new TeamsModal.TeamRequest(eventType, dateTimeGmtLong(), guId));
            }else{
                payload = JSON.serialize(new TeamsModal.TeamMemberRequest(eventType, dateTimeGmtLong(), guId));
            }
        }else{
            if(tMember.Team_Member_Sub_ID__c == tMember.Team_Lead_Sub_ID__c)
            {
                payload = JSON.serialize(new TeamsModal.TeamRequest(eventType, dateTimeGmtLong(), dateTimeGmtLong(), guId));
            }else{
                payload = JSON.serialize(new TeamsModal.TeamMemberRequest(eventType, dateTimeGmtLong(), dateTimeGmtLong(), guId));
            }
        }
        return payload;
    }
    /*
    public static string prepareTeamsEndDatePayload(Team_Members__c tMember, string eventType, string guId)
    {
        string payload = '';
        //Check Member is Lead ?
        if(tMember.Team_Member_Sub_ID__c == tMember.Team_Lead_Sub_ID__c)
        {
            payload = JSON.serialize(new TeamsModal.TeamRequest(eventType, dateTimeGmtLong(), dateTimeGmtLong(), guId));
        }else{
            payload = JSON.serialize(new TeamsModal.TeamMemberRequest(eventType, dateTimeGmtLong(), dateTimeGmtLong(), guId));
        }
        return payload;
    }
	*/
}