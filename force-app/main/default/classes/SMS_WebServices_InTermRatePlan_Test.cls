@istest(SeeAllData=true)
public class SMS_WebServices_InTermRatePlan_Test{

    static testMethod void doTestOne() {
        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/InTermProductRatePlans';  
        req.addParameter('subscriptionId', '123456');
        req.addParameter('productId', '123456');
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;

        List<string> results = SMS_WebServices_InTermProductRatePlans.GetRatePlans();
    
    }

    static testMethod void doTestTwo() {
        try {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
    
            req.requestURI = '/services/apexrest/InTermProductRatePlans';  
            req.addParameter('subscriptionId', '');
            
            RestContext.request = req;
            RestContext.response = res;
    
            List<string> results = SMS_WebServices_InTermProductRatePlans.GetRatePlans(); 
        }
        catch(Exception e) { }   
    }

}