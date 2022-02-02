public class LoginName_MockDataGenerator {
	
    public static System.HttpResponse generateMockData(System.HttpRequest request) {
        System.HttpResponse response = new System.HttpResponse();
        String responseBody = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><root>{"_id":"test@archive.com","available":true}</root></soap:Body></soap:Envelope>';
        
        response.setStatusCode(200);
        response.setBody(responseBody);       

        return response;
    } 
}