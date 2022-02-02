public Class LT_ListingUpdateService {
    
    private static Map<String, String> mdsConnections;
    
    private Static void setMDSConnections(){
        mdsConnections = new Map<String, String>();
        mdsConnections.put('Password' , Listing_Transfer__c.getValues('BRIGHT Password').Value__c);
        mdsConnections.put('URL' , Listing_Transfer__c.getValues('BRIGHT URL').Value__c);
        mdsConnections.put('UserAgent' , Listing_Transfer__c.getValues('BRIGHT UserAgent').Value__c);
        mdsConnections.put('UserName' , Listing_Transfer__c.getValues('BRIGHT UserName').Value__c);  
        mdsConnections.put('Host' , Listing_Transfer__c.getValues('BRIGHT Host').Value__c); 
        mdsConnections.put('LUS URL' , Listing_Transfer__c.getValues('BRIGHT LUS URL').Value__c); 
    }
    
    public Static ListingUpdateResponse reassignAgent(String listingKey, Long listAgentKey, Long listAgentOfficeKey, Long transferredAgentKey){        
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeNumberField('ListAgentKey', listAgentKey);//agent key of who it is reassigned to
        gen.writeNumberField('ListAgentOfficeKey', listAgentOfficeKey);// office key of originating office
        gen.writeNumberField('TransferredAgentKey', transferredAgentKey);//agent key of the listing
        gen.writeStringField('UpdateType','ORIG_BROKER_DECLINED_TRANSFER_AND_REASSIGN');
        gen.writeEndObject();    
        String requestBody = gen.getAsString();
        
        return updateCallLUS(listingKey, requestBody);        
    }
    
    public Static ListingUpdateResponse transferListing(String listingKey, Long listAgentKey, Long listAgentOfficeKey){        
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeNumberField('ListAgentKey', listAgentKey);// agent key of listing
        gen.writeNumberField('ListAgentOfficeKey', listAgentOfficeKey);// office key of the destination office
        gen.writeNumberField('TransferredAgentKey', listAgentKey);// agent key of listing
        gen.writeStringField('UpdateType','DEST_BROKER_ACCEPTED_TRANSFER');
        gen.writeEndObject();    
        String requestBody = gen.getAsString();
        
        return updateCallLUS(listingKey, requestBody);
        
    }
    
    public Static ListingUpdateResponse withdrawListing(String listingKey, Long listAgentKey){        
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeNumberField('TransferredAgentKey', listAgentKey);//agent key of the listing
        gen.writeStringField('UpdateType','DEST_BROKER_NO_ACTION_AND_WITHDRAW');
        gen.writeEndObject();    
        String requestBody = gen.getAsString();
        
        return updateCallLUS(listingKey, requestBody);        
    }
    
    private Static ListingUpdateResponse updateCallLUS(String listingKey, String requestBody){
        setMDSConnections();
        Blob headerValue = Blob.valueOf(mdsConnections.get('UserName') + ':' + mdsConnections.get('Password'));
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug('request Body:' + requestBody);
        System.HttpRequest request = new System.HttpRequest();
        request.setBody(requestBody);
        request.setMethod('POST');
        request.setEndpoint(mdsConnections.get('LUS URL') + listingKey);
        request.setHeader('Accept', 'application/json');        
        request.setHeader('Content-Type', 'application/json');        
        request.setHeader('User-Agent', mdsConnections.get('UserAgent'));
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('charset', 'utf-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Language', 'en-US,en;q=0.5');
        request.setHeader('Accept-Encoding', 'gzip, deflate');
        request.setHeader('Host', mdsConnections.get('Host'));
        request.setHeader('Content-Length', String.valueOf(requestBody.length()));
        request.setTimeout(120000);
        
        System.HttpResponse response = new System.HttpResponse();
        if (Test.isRunningTest())
            response = PROV_MockDataGenerator.generateMockData(request);    
        else
        	response = new System.Http().send(request);
        
        ListingUpdateResponse lusResponse = new ListingUpdateResponse(); 
        if(response.getStatusCode() == 200){
            lusResponse.Status = 'Success';
            lusResponse.StatusMessage = 'Success';
        }
        else{
            lusResponse.Status = 'Failure';
            lusResponse.StatusMessage = response.getBody();
        }

        system.debug('lusResponse:' + lusResponse);        
        
        return lusResponse;
        
    }
    
    public class ListingUpdateResponse {
        public String Status { get; set; } 
        public String StatusMessage { get; set; } 
    }
    
    public Class CustomException extends Exception {}
}