public class IntegrationLogUtils {
    
    public static Integration_Log__c createLog(TeamsModal.IntegrationLog logWrap)
    {
        Integration_Log__c newLog = new Integration_Log__c();
        newLog.Log_Type__c 		= logWrap.logType;
        newLog.Method_Type__c 	= logWrap.methodType;
        newLog.Request__c 		= logWrap.request;
        newLog.Response__c 		= logWrap.response;
        newLog.Status_Code__c 	= logWrap.statusCode;
        newLog.Status_Message__c = logWrap.statusMessage;
        newLog.StackTrace__c	= logWrap.StackTrace;
        Id parentId = logWrap.parentId;
        if(String.valueof(parentId.getSObjectType()) == 'Team_Members__c')
        {
            newLog.Team_Members__c 	= parentId;
        }
        else if(String.valueof(parentId.getSObjectType()) == 'Teams__c')
        {
            newLog.Teams__c 	= parentId;
        }            
        insert newLog;
        return newLog;
    }
}