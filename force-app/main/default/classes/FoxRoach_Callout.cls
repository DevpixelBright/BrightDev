/***********************************************************************************************
*       Class Name      : FoxRoach_Callout
*       Date            : 10/13/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is used to do Callout to Reliance API and get Fox & Roach Data into salesforce
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/13/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_Callout 
{
    public static string URL;
    public static string AUTH;
    
    public static HttpResponse foxRoachCallout(String payload, string methodName, string method) 
    {
        HttpResponse foxRoachResponse;
        if(!System.isBatch())
        {
            foxRoachCalloutFuture(payload, methodName, method);
        }else{
            foxRoachResponse = foxRoachCalloutApex(payload, methodName, method);
        }
        return foxRoachResponse;
    }
    
    @future(callout=true)
    public static void foxRoachCalloutFuture(String payload, string methodName, string method) 
    {
        foxRoachCalloutApex(payload, methodName, method);
    }
    
    public static HttpResponse foxRoachCalloutApex(String payload, string methodName, string method) 
    {
        Http h = new Http(); 
        HttpRequest req = new HttpRequest();
        
        if(string.isBlank(URL) || string.isBlank(AUTH))
        {
            Reliance_API_Configuration__mdt relianceConfig = [SELECT URL__c, Authorization__c FROM Reliance_API_Configuration__mdt WHERE MasterLabel = 'Fox & Roach'];
        	URL = relianceConfig.URL__c;
            AUTH = relianceConfig.Authorization__c;
        }
        req.setHeader('Authorization', AUTH);
        req.setHeader('Content-Type', 'application/json');
        string endPointURL = URL + methodName;
        req.setEndpoint(endPointURL);
        if(!string.isEmpty(method))
        {
            req.setMethod(method);
        }else{
            req.setMethod('GET');
        }        
        if(!string.isEmpty(payload))
        {
            req.setBody(payload);
        }
        system.debug('payload---'+payload);
        system.debug('req---'+req);
        HttpResponse relianceResponse = h.send(req);
        system.debug('response---'+relianceResponse.getBody());
                
        return relianceResponse;
    }

}