@istest
public class Zuora_AccountMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        System.HttpResponse resp = new System.HttpResponse();
        resp.setBody('[PREDEFINED_ZOBJECT_MAP={}, arrayfields={}, fields={AutoPay=false, Id=2c92c0f971c65dfe0171cb3494475a27}, isPredefined=false, namespace=http://object.api.zuora.com/, zType=Account]');
        return resp;
    }
}