@isTest                   
private class MdsDigestQuery_Test {
     
     private static testMethod void doTestOne() {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('WWW-Authenticate', 'realm=123');
        res.setHeader('Set-Cookie', 'test');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        
        try {
            MdsDigestQuery.digestResponse(res);
        }
        catch(Exception e) { }
        
        try {
            MdsDigestQuery.tmpMethod();
        } 
        catch(Exception e) { }
        
        try {
            MdsDigestQuery.prtHdr(res);
        } 
        catch(Exception e) { }        
        
        
    }
    
}