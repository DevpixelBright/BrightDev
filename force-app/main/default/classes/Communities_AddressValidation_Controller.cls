global Class Communities_AddressValidation_Controller {  
    
    @RemoteAction
    global static String smartyValidation(String address) {
        system.debug('address' +address);
        
        String authId = Smarty_Streets__c.getValues('Auth ID').Value__c;
        String authToken =  Smarty_Streets__c.getValues('Auth Token').Value__c;
        String URL =  Smarty_Streets__c.getValues('URL').Value__c;  
        
        String requestURL = String.valueOf(URL) + '?auth-id=' + String.valueOf(authId) + '&auth-token=' + String.valueOf(authToken) + '&candidates=10&street=' + address;
        system.debug('requestURL' +requestURL);
        Http h = new Http();
        System.HttpRequest request = new System.HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(requestURL);
        system.debug('requestURL' +requestURL);
        
        System.HttpResponse response = new System.HttpResponse();
        response = Test.isRunningTest()? new HTTpResponse() : h.send(request);
        system.debug('response' +response);
        return JSON.serialize(response.getBody());
        
      }   
    
    }