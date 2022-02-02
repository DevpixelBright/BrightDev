public class SMS_CloudCMA_MockDataGenerator {
    public static String methodName;
    public static Boolean isSuccess;
    public static String errorType;
    public static String subscriptionName;
    private static System.HttpResponse response;
    
    public static System.HttpResponse generateMockData() {
        response = new System.HttpResponse();
        
        if(!isSuccess) {
            if(errorType == 'HTTPError') {
                response.setStatusCode(401);
                response.setStatus('Unauthorized');
                response.setBody('');
            }
            else if(errorType == 'EmptyResponse') {
                response.setStatusCode(200);
                response.setStatus('Ok');
                response.setBody('');
            }                     
        }
        else {
            response.setStatusCode(200);
            response.setStatus('Ok');
            response.setBody('{"success":true,"user":{"id":1129786,"email":"katt@mris.com","firstname":"Katt","lastname":"Eaton","companyname":"ERA OakCrest Realty, Inc.","city":"Winchester","state":"VA","created_at":"2015-12-10T03:48:39-08:00","updated_at":"2016-01-19T03:59:15-08:00"},"mls_credential":{"code":"mris","name":"3096413"},"subscription":{"plan":"Month","amount":34.95}}');
        }
        System.debug('*** response:' + response);
        return response;
    }
}