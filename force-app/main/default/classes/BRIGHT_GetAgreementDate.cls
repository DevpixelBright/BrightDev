@RestResource(urlMapping='/GetBRIGHTAgreementDate/*')
global class BRIGHT_GetAgreementDate {
    
    @HttpPost
    global static Response updateAgreementDate(String subscriptionId) {
        Response res = new Response();
        try{
            res.subscriptionId = subscriptionId;
            res.agreementDate = null;
            
            if(String.isBlank(subscriptionId)) 
                throw new CustomException('Subscription Id can not be null'); 
            
            List<Subscriptions__c> sSubscriptions = new List<Subscriptions__c>();
            sSubscriptions = [SELECT Id, Name, BRIGHT_AgreementAcceptanceDate__c 
                              FROM   Subscriptions__c 
                              WHERE  Name = :subscriptionId
                              AND    Service_Jurisdiction__c = 'BRIGHT'
                             ]; 
            
            if(sSubscriptions.size() != 1)
                throw new CustomException('Invalid Subscription Id');
            
            sSubscriptions[0].BRIGHT_AgreementAcceptanceDate__c = system.now();
            update sSubscriptions[0];
            
            res.agreementDate = sSubscriptions[0].BRIGHT_AgreementAcceptanceDate__c;    
            res.status = 'Success';
        }
        catch(Exception e){
            res.status = 'Failed';
            res.errorDescription = e.getMessage();
        }
        
        return res;
    }
    
    @HttpGet
    global static Response GetAgreementDate() {
        Response res = new Response();
        try{
            
            RestRequest req = RestContext.request;         
            String subscriptionId = req.params.get('subscriptionId');
            
            res.subscriptionId = subscriptionId;
            res.agreementDate = null;
            
            if(String.isBlank(subscriptionId)) 
                throw new CustomException('Subscription Id can not be null'); 
            
            List<Subscriptions__c> sSubscriptions = new List<Subscriptions__c>();
            sSubscriptions = [SELECT Id, Name, BRIGHT_AgreementAcceptanceDate__c 
                              FROM   Subscriptions__c 
                              WHERE  Name = :subscriptionId
                              AND    Service_Jurisdiction__c = 'BRIGHT'
                             ]; 
            
            if(sSubscriptions.size() != 1)
                throw new CustomException('Invalid Subscription Id');
            
            
            res.agreementDate = sSubscriptions[0].BRIGHT_AgreementAcceptanceDate__c;    
            res.status = 'Success'; 
        }
        catch(Exception e){
            res.status = 'Failed';
            res.errorDescription = e.getMessage();
        } 
        
        return res;          

    }
    
    global Class Response {
        WebService String status { get; set; }       
        WebService String subscriptionId { get; set; }
        WebService DateTime agreementDate { get; set; }
        WebService String errorDescription { get; set; }
    } 
    
    class CustomException extends Exception {}    
}