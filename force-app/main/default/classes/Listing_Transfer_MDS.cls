public class Listing_Transfer_MDS {
    
    private static Map<String, String> digestParameters;
    private static Map<String, String> responseMap;
    public static Set<String> responseList =new Set<String>();
    
   
  /* This method returns the set of listing keys */
    public Static Set<String> getMDSConnection(String schematable,String resourceKey,String query) {
        try { 
            
            getDigestInformation(schematable,resourceKey);
            if(query != null && resourceKey == null){
                queryMDSData(schematable,query);
            }
            
            else if(query == null && resourceKey != null){
                resourceKey = '20101004254';
                getMDSData(schematable,resourceKey);
            }
            
            return responseList;
        }
        catch(Exception e) {
           throw new CustomException(e.getMessage()); 
        }           
    }
    
	/* This method returns the property details for a given listing keys*/
	public Static map<String, map<String, String>> getListingDetailsfromMDS(String schematable, String resourceKey, String query, list<string> resKeys, string temp){
		
		system.debug('---resourceKey in listing details method ----'+resourceKey+'---'+temp);
		
		set<string> tempSet = new set<string>();
		tempSet.addAll(resKeys);
		
		//LT_GeneralUtilCls.sfdcPreviousListingRequests(tempSet, temp);
		
		getDigestInformation(schematable,resourceKey);
		return getPropertyDetails(schematable,resourceKey,query, temp);
	    
	}


    private Static void getMDSData(String schematable,String resourceKey) {
         system.debug('getMDSData');
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('EPROCESS1'+':'+digestParameters.get('realm')+':'+'122911')));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+'/' + resourceKey+ '?Lock=1')));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            //request.setEndpoint('http://devdata.mris.com/services/rest/'+schematable+'/' + resourceKey+ '?Lock=1');
            request.setEndpoint('http://devdata.mris.com/services/rest/'+schematable+'/' + resourceKey+ '?Select=ListingID,ListPicture2URL,ListPicture3URL');
            
            //request.setEndpoint('http://devdata.mris.com/services/rest/Property?Query=(LocaleListingStatus IN  \'ACTIVE-CORE\',\'APP REG-CORE\',\'CNTG/NO KO-CORE\',\'COMING SOON-CORE\',\'CONTRACT-CORE\',\'EXPIRED-CORE\',\'RENTED-CORE\',\'SOLD-CORE\',\'TEMPOFF-CORE\',  \'WITHDRN-CORE\') AND  (ListAgentAgentID EQ \'7777\')  AND (Comparable EQ 0) ');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+'EPROCESS1'+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/'+schematable+'/' + resourceKey +'?Lock=1",response="'+responsestr1+'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            system.debug('response is '+response);
                         
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            //System.debug(response);
            //System.debug(response.getBody());
            String responseBody = response.getBody(); 
            if(responseBody.indexOf('KeysNotFound', 0) > 0)
                throw new CustomException('CS Lock Failed: ');
            //responseList = new List<String>();
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            parseXML(envelope); 
            //System.debug(responseMap);
            
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
    
    private Static void queryMDSData(String schematable,String query) {
        system.debug('queryMDSMethod');
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('EPROCESS1'+':'+digestParameters.get('realm')+':'+'122911')));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+'?Query='+query)));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('http://devdata.mris.com/services/rest/'+schematable+'?Query='+query);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+'EPROCESS1'+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/'+schematable+'?Query='+query+ '",response="'+responsestr1+'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            system.debug('response is '+response);
                         
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            System.debug(response);
            System.debug(response.getBody());
            String responseBody = response.getBody(); 
            if(responseBody.indexOf('KeysNotFound', 0) > 0)
                throw new CustomException('CS Lock Failed: ');
            
            //responseList = new List<String>();
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            parseXML(envelope); 
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
    
	Public Static map<String, map<string, string>> getPropertyDetails(String schematable,String resourceKey,String query, string resKeys) {
        system.debug('getPropertyDetails method resKeys---->'+resKeys);
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('EPROCESS1'+':'+digestParameters.get('realm')+':'+'122911')));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+'/'+resourceKey+'?Select='+query)));
            //String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+'/'+resKeys+'?Select='+query)));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('http://devdata.mris.com/services/rest/'+schematable+'/'+resKeys+'?Select='+query);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+'EPROCESS1'+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/'+schematable+'/'+resourceKey+'?Select='+query+ '",response="'+responsestr1+'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            //system.debug('getPropertyDetails response is ------->'+response);
                         
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            //System.debug(response);
            //System.debug(response.getBody());
            String responseBody = response.getBody(); 
            if(responseBody.indexOf('KeysNotFound', 0) > 0)
                throw new CustomException('CS Lock Failed: ');
            
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            system.debug('--Dom.XMLNode envelope--->'+envelope);
            parseXML1(envelope);
            
            system.debug('----getPropertyDetails after parse responseMap ----'+responseMap.size());
            system.debug('----getPropertyDetails after parse mapTempListing ----'+mapTempListing.size()+'--'+mapTempListing);
            system.debug('----getPropertyDetails after responseList ----'+responseList);
            
            if(resourceKey != null && mapListingIdMapDetails.containsKey(resourceKey))
				mapListingIdMapDetails.put(resourceKey, responseMap);
            system.debug('----getPropertyDetails after mapListingIdMapDetails ----'+mapListingIdMapDetails.size()+'-->'+mapListingIdMapDetails);
            for(string str : mapListingIdMapDetails.keySet())
            	system.debug('--map--'+str+'--value--'+mapListingIdMapDetails.get(str));
            
            return mapListingIdMapDetails;

        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());    
        }
       
    }
    
    
    private Static void getDigestInformation(String schematable, String resourceKey) {
        
        try {
            /* Digest information can get by sending a request to server */
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('http://devdata.mris.com/services/rest/'+schematable+'/'+ resourceKey);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
            
            //system.debug('---getDigestInformation response ---'+response);
            String digestHeader = response.getHeader('WWW-Authenticate');
            //system.debug('---getDigestInformation digestHeader ---'+digestHeader); 
            
            if(String.isBlank(digestHeader))
                throw new CustomException('Request1: Failed to get digest authentication header');
            
            parseAuthorizationHeader('', digestHeader);
            
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('EPROCESS1'+':'+digestParameters.get('realm')+':'+'122911')));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+'/' + resourceKey)));
            //String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/'+schematable+ '?Query='+query)));
            String responsestr = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            //system.debug('---a1--->'+a1);
            //system.debug('---a2--->'+a2);
            //system.debug('---responsestr--->'+responsestr);
            
            request.setHeader('Authorization', 'Digest username="'+'EPROCESS1'+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/'+schematable+'/' + resourceKey + '",response="'+responsestr+'",algorithm="MD5"');
            //request.setHeader('Authorization', 'Digest username="'+'EPROCESS1'+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/'+schematable+ '?Query='+query+ '",response="'+responsestr+'",algorithm="MD5"');
            System.HttpResponse response1 = new System.HttpResponse();
            
            //system.debug('---request--->'+request);
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response1 = PROV_MockDataGenerator.generateMockData(request);    
            else
                response1 = new System.Http().send(request);

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
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if (node.getText().trim() != '') {
                //System.debug(node.getName() + '-' + node.getText().trim());
             	system.debug('--parse in 1st if-->'+node.getName()+'---node.getText().trim()-->'+node.getText().trim());
                responseMap.put(node.getName(), node.getText().trim());
            }
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    system.debug('node.getAttributeKeyAt(i)--->'+node.getAttributeKeyAt(i));
                    system.debug('node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i))--->'+node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                      if(node.getAttributeKeyAt(i) == 'ResourceKey')
                          responseList.add(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                    responseMap.put(node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                }
            }
            for (Dom.XMLNode child: node.getChildElements()) {
              parseXML(child);
            }
            system.debug('response Map inside parseXML --->'+responseMap);
        }
    }          
    
    public static string resourceKey = '';
    public static map<string, map<string, string>> mapListingIdMapDetails = new map<string, map<string, string>>();
    public static map<string, string> mapTempListing = new map<string, string>();
    
    public static void parseXML1(DOM.XMLNode node) {
    	
		system.debug('----parseXML1 mapListingIdMapDetails ----'+mapListingIdMapDetails.size()+'-->'+mapListingIdMapDetails);
		system.debug('---parseXML1 mapTempListing --'+mapTempListing);    	
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if (node.getText().trim() != '') {
                //System.debug(node.getName() + '-' + node.getText().trim());
             	system.debug('--parse in 1st if getName-->'+node.getName()+'---node.getText().trim()-->'+node.getText().trim());
                responseMap.put(node.getName(), node.getText().trim());
                mapTempListing.put(node.getName(), node.getText().trim());
            }
			if (node.getAttributeCount() > 0) {
				for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
					system.debug('node.getAttributeKeyAt(i) parseXML1--->'+node.getAttributeKeyAt(i));
					system.debug('node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)) parseXML1--->'+node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
					if(node.getAttributeKeyAt(i) == 'ResourceKey'){
						responseList.add(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
						
						system.debug('---outer if--->'+node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i))+'--resourceKey-->'+resourceKey);
						if(resourceKey != null && resourceKey != '' && mapListingIdMapDetails.containsKey(resourceKey)){
							mapListingIdMapDetails.put(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)), mapTempListing);
							mapTempListing = new map<string, string>();
							system.debug('---if attrib---'+mapListingIdMapDetails);
						}
						else{
							system.debug('---else attrib---'+node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
							mapListingIdMapDetails.put(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)), new map<string, string>());
						}
						
						resourceKey = node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
						system.debug('----parseXML1 mapListingIdMapDetails in if----'+mapListingIdMapDetails.size()+'-->'+mapListingIdMapDetails);
					}
					mapTempListing.put(node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
					responseMap.put(node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
				}
			}
            for (Dom.XMLNode child: node.getChildElements()) {
              parseXML1(child);
            }
        }
    }
    

    public Class CustomException extends Exception {}
}