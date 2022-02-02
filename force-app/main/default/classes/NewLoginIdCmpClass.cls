public class NewLoginIdCmpClass {
    public String subsId { get; set; }
    public String newValue {set; get;}
    public Boolean available {set; get;}
    public Subscriptions__c sub { set; get;}
    String loginId;
    
    
    public NewLoginIdCmpClass() {
        
        loginId = '';
        //available = false;
        
        string subId = Apexpages.currentpage().getParameters().get('Id');
        list<Subscriptions__c> lstsubs = [SELECT Id, Name, BRIGHT_LoginName__c, TREND_Login_Name__c, Service_Jurisdiction__c, MRIS_Login_ID__c 
                                          FROM Subscriptions__c 
                                          WHERE Name =: subId Or Id =: subId ];
        if(lstsubs != null && !lstsubs.isEmpty()){
            sub = lstSubs[0];
            if(sub != null && sub.Service_Jurisdiction__c == 'BRIGHT')
                newValue = sub.BRIGHT_LoginName__c;
            if(sub != null && sub.Service_Jurisdiction__c == 'TREND')
                newValue = sub.TREND_Login_Name__c;
        }
    }
    
    public void furtherValidate() {
        
        String pattern = ApexPages.currentPage().getParameters().get('pattern');
        if(pattern != null || pattern != ''){
            
            Map<String, LoginUniqueness__c> settingsMap = LoginUniqueness__c.getAll();
            String endpoint = '';
            String soapAction = '';
            for(String cs : settingsMap.keySet()) {
                if(cs == 'Endpoint')
                    endpoint = settingsMap.get(cs).Value__c;
                if(cs == 'SoapAction')
                    soapAction = settingsMap.get(cs).Value__c; 
            }
            //String endpoint = 'https://talend.tst.brightmls.com/services/LoginNameService';
            //String soapAction = 'http://www.talend.org/service/ValidateLoginName';
            
            String requestMsg =  '<?xml version="1.0" encoding="utf-8"?>';
            requestMsg += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://www.talend.org/service/">';
            requestMsg += '<soap:Body>';
            requestMsg += '<ser:ValidateLoginNameRequest  xmlns="http://www.talend.org/service/">';
            requestMsg += '<LoginName>' + pattern + '</LoginName>';
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
            response = new System.Http().send(request);
            //system.debug('*** response: ' + requestMsg);
            String responseBody = response.getBody();
            System.debug('*** response: ' + responseBody);
            if(responseBody.contains('<root>')) {
                String jsonStr = responseBody.subString(responseBody.indexOf('<root>')+6, responseBody.indexOf('</root>'));
                
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                loginId = '';
                available = false;
                for(String s : jsonMap.keySet()) {
                    //String loginId = jsonMap.get();
                    if(s == '_id' && jsonMap.containsKey(s))
                        loginId = (String)jsonMap.get('_id');
                    
                    if(jsonMap.containsKey(s) && s == 'available') 
                        available = (Boolean)jsonMap.get('available');  
                }
                system.debug('---available-->'+available);
               
                if(available) {
                    if(loginId != null) {
                        Integer checkDuplicatesubs = [SELECT count() FROM Subscriptions__c 
                                                      WHERE BRIGHT_LoginName__c = :loginId OR TREND_Login_Name__c = :loginId];
                        if(checkDuplicatesubs > 0){
                            available = false;
                        }
                        else{
                            available = true;
                            updateSubscription();
                        }
                    }
                }
                else{
                    available = false;
                    
                }
            }
        }
    }
    
    public Subscriptions__c updateSubscription() {
            
        system.debug('----sub--->'+sub.id);
        
        if(sub.Service_Jurisdiction__c == 'BRIGHT') {
            sub.BRIGHT_LoginName__c = loginId;
        }
        else if(sub.Service_Jurisdiction__c == 'TREND') {
            sub.TREND_Login_Name__c = loginId;
        }
        
        return null;
      /*  try{
            update sub;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Login Name updated successfully'));
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error while updating Login Name: '+ex.getMessage()));
        } */
    }
        
}