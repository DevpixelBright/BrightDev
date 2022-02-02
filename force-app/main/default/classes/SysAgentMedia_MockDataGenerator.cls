public class SysAgentMedia_MockDataGenerator{
    private static System.HttpResponse response;
        public static System.HttpResponse generateMockData(System.HttpRequest request) {
        
        response = new System.HttpResponse();

        String responseBody = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://devdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=BRIGHT">';
              responseBody += '<ResponseStatus><StatusCode>0</StatusCode><StatusMessage>Success</StatusMessage></ResponseStatus><BrightAgentMedia><MediaData ResourceKey="200007100670"/></BrightAgentMedia></Response>';
            
        response.setHeader('WWW-Authenticate', 'Digest realm="users@mris.com", nonce="31353533353130333639353631200d4ced1a6578efe647ab8dc8636b34e6", opaque="6e6f742075736564"');
        response.setHeader('Set-Cookie', 'MDS-Session-ID=85081077681; Path=/');
        response.setStatusCode(200);
        response.setBody(responseBody);       
        
        return response;
            
        }
}