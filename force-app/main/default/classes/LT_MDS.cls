public class LT_MDS {
    
    private static Map<String, String> digestParameters;
    private static Map<String, String> responseMap;
    public static Set<String> listingKeysResult;
    private static Map<String, String> mdsConnections;
    
    public static Map<String, Map<String, String>> mapListingIdMapDetails = new Map<String, Map<String, String>>();
    public static Map<String, String> mapTempListing = new Map<String, String>();
    private Static String resourceKey = ''; 
    
    private Static void setMDSConnections(){
        mdsConnections = new Map<String, String>();
        mdsConnections.put('Password' , Listing_Transfer__c.getValues('BRIGHT Password').Value__c);
        mdsConnections.put('URL' , Listing_Transfer__c.getValues('BRIGHT URL').Value__c);
        mdsConnections.put('UserAgent' , Listing_Transfer__c.getValues('BRIGHT UserAgent').Value__c);
        mdsConnections.put('UserName' , Listing_Transfer__c.getValues('BRIGHT UserName').Value__c);
       
    }
   
   /*This method returns the set of listing keys */
   public Static Set<String> queryListingKeys(String query) {
        try { 
            setMDSConnections();
            listingKeysResult = new Set<String>();             
            
            getDigestInformation();            
            getListingKeys(query);
            
            return listingKeysResult;
        }
        catch(Exception e) {
           throw new CustomException(e.getMessage()); 
        }           
    }
    
    /* This method returns the property details for a given listing keys*/
    public Static Map<String, Map<String, String>> getListingDetailsfromMDS(String fieldNames, List<String> listingKeys){        
        
        setMDSConnections();
        getDigestInformation();
        
        return getPropertyDetails(fieldNames, listingKeys);
    
    }
    
    private Static void getListingKeys(String query) {
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(mdsConnections.get('UserName') + ':'+digestParameters.get('realm') + ':' + mdsConnections.get('Password'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/Property?Query='+query)));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(mdsConnections.get('URL') + '/Property?Query='+query);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', mdsConnections.get('UserAgent'));
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+mdsConnections.get('UserName')+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Property?Query='+query+ '",response="'+responsestr1+'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = LT_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            system.debug('Get Property keys: ' + response.getBody());
                                     
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            System.debug(response);
            System.debug(response.getBody());
            String responseBody = response.getBody(); 
            
            
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            parseQueryResultXML(envelope); 
            System.debug(responseMap);
            
            if(!(responseMap.Size() > 0))
                throw new CustomException('CS Lock Failed: Unable to process record lock response');

            if(String.isBlank(responseMap.get('StatusCode')))
                throw new CustomException('CS Lock Failed: Did not recive status code in response');
            
            if(responseMap.get('StatusCode') != '0')
                throw new CustomException('CS Lock Failed: ' + responseMap.get('StatusCode') + '-' + responseMap.get('StatusMessage'));                                  
              
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());    
        }
       
    }
    
  Public Static Map<String, Map<String, String>> getPropertyDetails(String fieldNames, List<String> listingKeys) {
        try {
            String listingKeysStr = '/';
            Boolean isFirst = false;
            
            for(String listingKey : listingKeys){
                if(isFirst)
                    listingKeysStr += ','  ;  
                listingKeysStr += listingKey;
                
                isFirst = true;                
            }
            
            system.debug('*** listingKeysStr: ' + listingKeysStr);
            
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(mdsConnections.get('UserName') + ':' + digestParameters.get('realm') + ':' + mdsConnections.get('Password'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/Property/' + listingKeys[0] + '?Select='+fieldNames)));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(mdsConnections.get('URL') + '/Property' + listingKeysStr +'?Select=' + fieldNames);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', mdsConnections.get('UserAgent'));
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="' + mdsConnections.get('UserName') + '",realm="' + digestParameters.get('realm') + '",nonce="' + digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Property/'+ listingKeys[0] + '?Select=' + fieldNames + '",response="'+ responsestr1 +'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = LT_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request); 
                                        
            system.debug('details: ' + response);   
            
            if(response.getStatusCode() != 200)
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus()); 
                
            String responseBody = response.getBody();  
            
            system.debug('details: ' + response.getBody());         
            
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            parseListingDetailsXML(envelope);            
                
            system.debug(mapListingIdMapDetails);
            
            return mapListingIdMapDetails;

        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());    
        }       
    }
    
    private Static void getDigestInformation() {
        
        try {
            /* Digest information can get by sending a request to server */
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(mdsConnections.get('URL') + '/Property?Count=1');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', mdsConnections.get('UserAgent'));
            request.setHeader('Connection', 'keep-alive');
            System.HttpResponse response = new System.HttpResponse();
            
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = LT_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            system.debug('Digest: ' + response.getBody());
            String digestHeader = response.getHeader('WWW-Authenticate');
            
            if(String.isBlank(digestHeader))
                throw new CustomException('Request1: Failed to get digest authentication header');
            
            parseAuthorizationHeader('', digestHeader);
            
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(mdsConnections.get('UserName') + ':' + digestParameters.get('realm') + ':' + mdsConnections.get('Password'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/Property?Count=1')));
            String responsestr = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1 + ':' + digestParameters.get('nonce') + ':' + a2)));
            
            request.setHeader('Authorization', 'Digest username="' + mdsConnections.get('UserName') + '",realm="' + digestParameters.get('realm') + '",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Property?Count=1",response="'+responsestr + '",algorithm="MD5"');
            System.HttpResponse response1 = new System.HttpResponse();            
            
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response1 = LT_MockDataGenerator.generateMockData(request);    
            else
                response1 = new System.Http().send(request);
                
                system.debug('Digest response1: ' + response1.getBody());

            String cookie1 = response1.getHeader('Set-Cookie');
            String digestHeader1 = response1.getHeader('WWW-Authenticate');
            
            if(String.isBlank(digestHeader1))
                throw new CustomException('Request2: Failed to get digest authentication header'); 
            if(String.isBlank(cookie1))
                throw new CustomException('Request2: Failed to get session cookie');                           
            
            parseAuthorizationHeader(cookie1, digestHeader1);
          
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }
              
    }
    
    private static void parseAuthorizationHeader(String cookie, String authorizationStr) {
        digestParameters = new Map<String, String>();
        List<String> parts = authorizationStr.split(',');
        List<String> digestparts = new List<String>();
        for(String part : parts){
            Pattern p = Pattern.compile('.*\\\"(.*)\\\".*');
            Matcher pm = p.matcher(part);
            
            if( pm.matches() )
                digestparts.add(pm.group(1));

        }
        digestParameters.put('cookie', cookie);
        digestParameters.put('nonce', digestparts[1]);
        digestParameters.put('opaque', digestparts[2]);
        digestParameters.put('realm', digestparts[0]);    
    }
    
    private static void parseQueryResultXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if (node.getText().trim() != '') {
                responseMap.put(node.getName(), node.getText().trim());
            }
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                      if(node.getAttributeKeyAt(i) == 'ResourceKey')
                          listingKeysResult.add(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                    responseMap.put(node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                }
            }
            for (Dom.XMLNode child: node.getChildElements()) {
              parseQueryResultXML(child);
            }
        }
    }          
    
    public static void parseListingDetailsXML(DOM.XMLNode node) {
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {  
                   
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    
                    if(node.getAttributeKeyAt(i) == 'ResourceKey'){
                        resourceKey = node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                                                
                        if(!mapListingIdMapDetails.containsKey(resourceKey))
                            mapListingIdMapDetails.put(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)), new Map<String, String>()); 
                        
                    }                    
                }
            }
            
            if (node.getText().trim() != '') {                
                if(mapListingIdMapDetails.containsKey(resourceKey)){
                    Map<String, String> details = mapListingIdMapDetails.get(resourceKey);
                    details.put(node.getName(), node.getText().trim());
                    mapListingIdMapDetails.put(resourceKey, details);   
                }
            }
            
            for (Dom.XMLNode child: node.getChildElements()) {
                parseListingDetailsXML(child);
            }
        }
    }

    public Class CustomException extends Exception {}
}