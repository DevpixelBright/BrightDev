public class LT_MockDataGenerator {
    private static System.HttpResponse response;
    
    public static System.HttpResponse generateMockData(System.HttpRequest request) {
        response = new System.HttpResponse();

        String responseBody = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://devdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=BRIGHT">';
              responseBody += '<ResponseStatus><StatusCode>0</StatusCode><StatusMessage>Success</StatusMessage></ResponseStatus>';
              responseBody += '<BrightAll><AllProperty ResourceKey="205026134428"><Listing><ListingKey>205026134428</ListingKey><MlsStatus>ACTIVE</MlsStatus></Listing> <ListingDates><ModificationTimestamp>2020-08-01T14:05:30</ModificationTimestamp></ListingDates> <ListingPricing><ListPrice>167500.00</ListPrice></ListingPricing><LocationAddress>';
              responseBody += '<City>OCEAN PINES</City><PostalCode>21811</PostalCode><StateOrProvince>MD</StateOrProvince><PostalCodePlus4 xsi:nil="true"/><FullStreetAddress>17 FOSSE GRANGE</FullStreetAddress></LocationAddress><ListingAgent><ListAgentMlsId>4552631</ListAgentMlsId>';
              responseBody += '<ListAgentKey>200006375184</ListAgentKey></ListingAgent><ListingOffice><ListOfficeMlsId>100HRE</ListOfficeMlsId></ListingOffice><ListingStructure><BathroomsTotalInteger xsi:nil="true"/><BathroomsFull xsi:nil="true"/><BathroomsHalf xsi:nil="true"/>';
              responseBody += '<BedroomsTotal xsi:nil="true"/></ListingStructure><ListingMedia><ListPicture2URL xsi:nil="true"/></ListingMedia></AllProperty></BrightAll></Response>';
      
        response.setHeader('WWW-Authenticate', 'Digest realm="users@mris.com", nonce="3134333935333837303531333620cdef0349cd23d9acd8a13f372a95fc00", opaque="6e6f742075736564"');
        response.setHeader('Set-Cookie', 'MDS-Session-ID=85081077681; Path=/');
        response.setStatusCode(200);
        response.setBody(responseBody);       
        
        return response;
    }  
    
}