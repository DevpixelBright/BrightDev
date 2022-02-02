/***********************************************************************************************
*       Class Name      : TeamsModal
*       Date            : 08/20/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is Modal for requests and response bodies used in Callout to Teams APP API
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       08/20/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class TeamsModal {
    
    public class TeamMemberRequest{
        public string eventType;
        public string updatedDate;
        public string endDate;
        public string teamMemberGuid;
        
        public TeamMemberRequest(string eventType, string updatedDate, string teamMemberGuid)
        {
            this.eventType = eventType;
            this.updatedDate = updatedDate;
            this.teamMemberGuid = teamMemberGuid;
        }
        
        public TeamMemberRequest(string eventType, string updatedDate, string endDate, string teamMemberGuid)
        {
            this.eventType = eventType;
            this.updatedDate = updatedDate;
            this.endDate = endDate;
            this.teamMemberGuid = teamMemberGuid;
        }
    }
    
    public class TeamRequest{
        public string eventType;
        public string updatedDate;
        public string endDate;
        public string teamGuid;
        
        public TeamRequest(string eventType, string updatedDate, string teamGuid)
        {
            this.eventType = eventType;
            this.updatedDate = updatedDate;
            this.teamGuid = teamGuid;
        }
        
        public TeamRequest(string eventType, string updatedDate, string endDate, string teamGuid)
        {
            this.eventType = eventType;
            this.updatedDate = updatedDate;
            this.endDate = endDate;
            this.teamGuid = teamGuid;
        }
    }
    
    public class TeamKeyRequest{
        public string brightTeamKey;
        public string teamGuid;
        public TeamKeyRequest(string brightTeamKey, string teamGuid)
        {
            this.brightTeamKey = brightTeamKey;
            this.teamGuid = teamGuid;
        }
    }
    
    public class TeamKeyResponse{
        public string message;
    }
    
    public class TeamMemberResponse{
        public string status;
        public string message;
    }

    public class IntegrationLog{
        public string request;
        public string StackTrace;
        public string response;
        public string statusCode;
        public string statusMessage;
        public string logType;
        public string methodType;
        public string parentId;
        
        public IntegrationLog(string request, string response, string statusCode, string statusMessage, string logType, string methodType, string parentId)
        {
            this.request = request;
            this.response = response;
            this.statusCode = statusCode;
            this.statusMessage = statusMessage;
            this.logType = logType;
            this.methodType = methodType;
            this.parentId = parentId;
        }
        public IntegrationLog(){}
    }
}