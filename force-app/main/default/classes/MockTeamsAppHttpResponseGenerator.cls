@isTest
global class MockTeamsAppHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        Teams_App_API_Configuration__mdt teamsConfig = [SELECT API_Key__c,End_Point_URL__c FROM Teams_App_API_Configuration__mdt WHERE MasterLabel = 'Teams App Configuration'];
        
        System.assert(req.getEndpoint().contains(teamsConfig.End_Point_URL__c));
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message": "successfully triggered"}');
        res.setStatusCode(200);
        return res;
    }
}