public class LMS_MockDataGenerator {
    public static String methodName;
    public static Boolean isSuccess;
    public static String errorType;
    public static String subscriptionName;
    
    public static System.HttpResponse generateMockData(System.HttpRequest request) {
        System.HttpResponse response = new System.HttpResponse();
        String soapAction = request.getHeader('SOAPAction');
        if(!isSuccess) {
            if(errorType == 'HTTPError') {
                response.setStatusCode(401);
                response.setStatus('Unauthorized');
                response.setBody('');
            }
            else if(errorType == 'ServiceError') {
                String errorMsg = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>http://schemas.xmlsoap.org/ws/2004/08/addressing/fault</wsa:Action><wsa:MessageID>urn:uuid:f5b04a3c-3277-43cd-ba49-24569780c8a6</wsa:MessageID><wsa:RelatesTo>urn:uuid:51ae4f1c-46ec-4c72-a11a-f3e620cbcedc</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-c77aeb67-4623-463c-8e2e-1cb9bac55baa"><wsu:Created>2015-08-09T17:43:29Z</wsu:Created><wsu:Expires>2015-08-09T17:48:29Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><detail><ExceptionMessage>Exception Occurred: GUID: 9f14ad95-9be7-4d11-8b68-c5a7fde76254</ExceptionMessage><ExceptionInfo>Exception Message:      String was not recognized as a valid DateTime.;Exception Target Method: ReadParameters</ExceptionInfo></detail></soap:Body></soap:Envelope>';
                response.setBody(errorMsg);
                response.setStatusCode(200);
            }
            else if(errorType == 'EmptyResponse') {
                String errorMsg = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"></soap:Envelope>';
                response.setBody(errorMsg);
                response.setStatusCode(200);
            }             
                      
        }
        else {
            String resMsg = '';
            if(soapAction == 'GetUser') {
                if(errorType == 'GetUserNotExists')
                    resMsg = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><GetUserResponse xmlns="urn:Cornerstone:ClientDataService"><User Id="' + subscriptionName + '" Message="User does not exists"></User></GetUserResponse></soap:Body></soap:Envelope>';    
                else
                    resMsg = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><GetUserResponse xmlns="urn:Cornerstone:ClientDataService"><User><Authentication><Username>' + subscriptionName + '</Username></Authentication></User><Custom><Relationship>Office Manager</Relationship></Custom></GetUserResponse></soap:Body></soap:Envelope>';
            }
            else if(soapAction == 'SetUsers') {         
                resMsg = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> <soap:Body><SetUsersResponse xmlns="urn:Cornerstone:ClientDataService"><Status><User Id="' + subscriptionName + '" Status="' + methodName + '" /></Status></SetUsersResponse></soap:Body></soap:Envelope>';               
            }

            response.setStatusCode(200);
            response.setBody(resMsg);
        }
        return response;
    }
}