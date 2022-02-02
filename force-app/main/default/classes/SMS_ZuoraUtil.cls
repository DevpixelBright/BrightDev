public class SMS_ZuoraUtil {
    private Zuora.zApi zconnection;
    
    public SMS_ZuoraUtil(){
        zconnection = new Zuora.zApi();
    }
     
    public Zuora.zApi.LoginResult zLogin() {
        Zuora.zApi.LoginResult zLoginResult = new Zuora.zApi.LoginResult();
        if (Test.isRunningTest()) {
            zLoginResult.ServerUrl = 'mockurl';
            zLoginResult.Session = 'mockSession98766';
        }
        else {
            zLoginResult = zconnection.zlogin();
        }
        
        return zLoginResult;
    }
   
    public List<Zuora.zApi.SaveResult> zcreate(List<Zuora.zObject> zobjects) {
        List<Zuora.zApi.SaveResult> zSaveResult = new List<Zuora.zApi.SaveResult>();
        
        if (Test.isRunningTest())
           zSaveResult = SMS_ZuoraMockCall.getZSaveResult(zobjects);
        else 
           zSaveResult = zconnection.zcreate(zobjects);
        
        return zSaveResult;
    }
    
    public List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjects) {
        List<Zuora.zApi.SaveResult> zSaveResult = new List<Zuora.zApi.SaveResult>();
        
        if (Test.isRunningTest())
           zSaveResult = SMS_ZuoraMockCall.getZSaveResult(zobjects);
        else 
           zSaveResult = zconnection.zupdate(zobjects);
        
        return zSaveResult;
    }
    
    public List<Zuora.zApi.SaveResult> zgenerate(List<Zuora.zObject> zobjects) {
        List<Zuora.zApi.SaveResult> zSaveResult = new List<Zuora.zApi.SaveResult>();
        
        if (Test.isRunningTest())
           zSaveResult = SMS_ZuoraMockCall.getZSaveResult(zobjects);
        else 
           zSaveResult = zconnection.zgenerate(zobjects);
        
        return zSaveResult;
    }
    
    public List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> zSubscribeRequest) {
        List<Zuora.zApi.SubscribeResult> zSubscribeResult = new List<Zuora.zApi.SubscribeResult>();
        
        if (Test.isRunningTest())
           zSubscribeResult = SMS_ZuoraMockCall.getZSubscribeResult(zSubscribeRequest);
        else  
            zSubscribeResult = zconnection.zsubscribe(zSubscribeRequest);
            
        return zSubscribeResult;
    }  

    public Zuora.zApi.AmendResult zamend(List<Zuora.zApi.AmendRequest> zAmendRequest) {
        Zuora.zApi.AmendResult zAmendResult = new Zuora.zApi.AmendResult(); 
        
        if (Test.isRunningTest())
           zAmendResult = SMS_ZuoraMockCall.getZAmendResult(zAmendRequest);
        else 
            zAmendResult = zconnection.zamend(zAmendRequest);
            
        return zAmendResult;
    }  

    public List<Zuora.zApi.DeleteResult> zdelete(String zType, List<String> zids) {
        List<Zuora.zApi.DeleteResult> zDeleteResults = new List<Zuora.zApi.DeleteResult>(); 
        
        if (Test.isRunningTest())
           zDeleteResults = SMS_ZuoraMockCall.getZDeleteResults(zType, zids);
        else 
            zDeleteResults = zconnection.zdelete(zType, zids);
            
        return zDeleteResults;
    }  
    
    public List<Zuora.zObject> zquery(String zQuery) {
        List<Zuora.zObject> zobjects = new List<Zuora.zObject>();
        System.Debug('*** zQuery : '+ zQuery);
        if (Test.isRunningTest())
           zobjects = SMS_ZuoraMockCall.getZObjects(zQuery);
        else 
           zobjects = zconnection.zquery(zQuery);
        
        return zobjects;
    }     
}