public class LoginName{
    
    public Static void isAvailable(String subscriptionId, String newLoginName){
        Boolean available = true;
        
        basicValidation(newLoginName);
        
        if(String.isBlank(subscriptionId)){
            if(newLoginName.isNumeric())
                throw new CustomException('Numeric Login Name is not allowed on initial creation.');            
        }
        else{
            List<Subscriptions__c> subscriptions = [SELECT Id, Name, BRIGHT_LoginName__c, TREND_Login_Name__c, Service_Jurisdiction__c 
                                              FROM   Subscriptions__c 
                                              WHERE  Id = :subscriptionId];
            
                if(newLoginName.isNumeric() && newLoginName != subscriptions[0].Name)
                    throw new CustomException('Numeric Login Name is not allowed unless it is your subscription ID.'); 
        
        } 
        
        if(available){
            if(!validateInSF(newLoginName)) 
                available = false;
            else if(!validatewithWS(newLoginName))
                available = false;      
        }
        
        if(!available)
            throw new CustomException('Login Name is already taken. Please enter a different one.');            
    }
    
    private Static void basicValidation(String newLoginName){
        if(String.isBlank(newLoginName))            
                throw new CustomException('Please enter a login name.');            
        
        if(newLoginName.length() < 3 || newLoginName.length() > 25)
            throw new CustomException('Login Name should be a minimum of 3 characters or a maximum of 25 characters.');
            
        String regex = '^[A-Za-z0-9 @.-]*$';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(newLoginName);
        Boolean regexfind =  regexMatcher.find();
        
        if(!regexfind)
            throw new CustomException('Login Name can only contain the following special characters: @ <at>, .<period> , -<dash>, <space>');    
    }
    
    private Static Boolean validateInSF(String newLoginName){
        Integer checkDuplicates = [SELECT count() 
                                   FROM   Subscriptions__c 
                                   WHERE  BRIGHT_LoginName__c = :newLoginName 
                                   OR     TREND_Login_Name__c = :newLoginName
                                  ];
        if(checkDuplicates > 0)
            return false;
        else 
            return true;
    }
    
    public Static Boolean validatewithWS(String newLoginName){  
        Boolean available = false;     
            
        String endpoint = LoginUniqueness__c.getValues('Endpoint').Value__c;
        String soapAction = LoginUniqueness__c.getValues('SoapAction').Value__c;            
        
        String requestMsg  =  '<?xml version="1.0" encoding="utf-8"?>';
                requestMsg += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://www.talend.org/service/">';
                requestMsg += '<soap:Body>';
                requestMsg += '<ser:ValidateLoginNameRequest  xmlns="http://www.talend.org/service/">';
                requestMsg += '<LoginName>' + newLoginName + '</LoginName>';
                requestMsg += '</ser:ValidateLoginNameRequest>';
                requestMsg += '</soap:Body>';
                requestMsg += '</soap:Envelope>';
                
        System.HttpRequest request = new System.HttpRequest();
        request.setBody(requestMsg);
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setTimeout(50000);
        request.setHeader('Content-type', 'text/xml');
        request.setHeader('charset', 'utf-8');
        request.setHeader('Accept', 'text/xml');
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Pragma', 'no-cache');
        request.setHeader('SOAPAction', soapAction);
        request.setHeader('Connection', 'Keep-Alive');
        
        System.HttpResponse response = new System.HttpResponse();
        
        if (Test.isRunningTest()) 
            response = LoginName_MockDataGenerator.generateMockData(request);
        else
            response = new System.Http().send(request);
        
            String responseBody = response.getBody();
        System.debug('*** response: ' + responseBody);
        
        if(responseBody.contains('<root>')) {
            String jsonStr = responseBody.subString(responseBody.indexOf('<root>')+6, responseBody.indexOf('</root>'));
            
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            
            
            for(String s : jsonMap.keySet()){
                system.debug('*** Login Name response: ' + s + '---' + jsonMap.get(s));
                if(jsonMap.containsKey(s) && s == 'available') 
                    available = (Boolean)jsonMap.get('available');  
            }
            
        }
            
        return available;
    } 
    
    public class CustomException extends Exception{}       
}