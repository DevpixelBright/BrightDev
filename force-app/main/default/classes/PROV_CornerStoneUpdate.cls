public Class PROV_CornerStoneUpdate {
    
    private static Map<String, String> digestParameters;
    private static Map<String, String> responseMap;
    private Static Map<String, String> provisionSettings;
    
    public Static String updateCornerStone(String agentKey, String realpingId) {
        try {
            if(String.isNotBlank(agentKey)) {
            
                /* Get provisioning custom settings */
                provisionSettings = PROV_GetProvisionProductDetails.getProvisionSettings();    
                            
                getDigestInformation(agentKey);
                lockCornerStoneRecord(agentKey);
                
                getDigestInformation(agentKey);
                updateCornerStoneRecord(agentKey, realpingId);
                
                return 'Success';
            }
            else
                throw new CustomException('Missing input parameter: AgentKey');  
        }
        catch(Exception e) {
            return e.getMessage();   
        }           
    }
    
    private Static void updateCornerStoneRecord(String agentKey, String realpingId) {
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(provisionSettings.get('CORNERSTONE_USERNAME')+':'+digestParameters.get('realm')+':'+provisionSettings.get('CORNERSTONE_PWD'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('POST:/services/rest/Agent/' + agentKey + '?CommitType=0&Delimiter=09&Record=AgentKey%3D' + agentKey + '%09AgentRealPingID%3D' + realpingId)));
            String responsestr = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setBody('CommitType=0&Delimiter=09&Record=AgentKey%3D' + agentKey + '%09AgentRealPingID%3D' + realpingId);
            request.setMethod('POST');
            request.setEndpoint(provisionSettings.get('CORNERSTONE_WS') + agentKey + '?CommitType=0&Delimiter=09&Record=AgentKey%3D' + agentKey + '%09AgentRealPingID%3D' + realpingId);
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');
            request.setHeader('ContentType', 'application/x-www-form-urlencoded');
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+provisionSettings.get('CORNERSTONE_USERNAME')+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Agent/' + agentKey + '?CommitType=0&Delimiter=09&Record=AgentKey%3D' + agentKey + '%09AgentRealPingID%3D' + realpingId + '",response="'+responsestr+'",algorithm="MD5"');
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
                
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Update Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            System.debug(response);
            System.debug(response.getBody());            
            responseMap = new Map<String, String>();
            Dom.Document result = response.getBodyDocument();
            Dom.XMLNode envelope = result.getRootElement();
            parseXML(envelope); 
            
            if(!(responseMap.Size() > 0))
                throw new CustomException('CS Update Failed: Unable to process record lock response');
                
            if(String.isBlank(responseMap.get('StatusCode')))
                throw new CustomException('CS Update Failed: Did not receive status code in response');
            
            if(responseMap.get('StatusCode') != '0')
                throw new CustomException('CS Update Failed: ' + responseMap.get('StatusCode') + '-' + responseMap.get('StatusMessage'));    
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }
    }    
    
    private Static void lockCornerStoneRecord(String agentKey) {
        try {
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(provisionSettings.get('CORNERSTONE_USERNAME')+':'+digestParameters.get('realm')+':'+provisionSettings.get('CORNERSTONE_PWD'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/Agent/' + agentKey + '?Lock=1')));
            String responsestr1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(provisionSettings.get('CORNERSTONE_WS') + agentKey + '?Lock=1');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
            request.setHeader('User-Agent', 'Pervasive/1.0');
            request.setHeader('Connection', 'keep-alive');            
            request.setHeader('Cookie', digestParameters.get('cookie'));
            request.setHeader('Authorization', 'Digest username="'+provisionSettings.get('CORNERSTONE_USERNAME')+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Agent/' + agentKey + '?Lock=1",response="'+responsestr1+'",algorithm="MD5"');
            
            System.HttpResponse response = new System.HttpResponse();
                
            /* Process response from cornerstone web services */
            if (Test.isRunningTest())
                response = PROV_MockDataGenerator.generateMockData(request);    
            else
                response = new System.Http().send(request);
                         
            if(!(response.getStatusCode() == 200))
                throw new CustomException('CS Lock Failed: ' + response.getStatusCode() + '-' + response.getStatus());            
            
            System.debug(response);
            System.debug(response.getBody());
            String responseBody = response.getBody(); 
            if(responseBody.indexOf('KeysNotFound', 0) > 0)
                throw new CustomException('CS Lock Failed: ' + agentKey + ' not found');
            
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
    
    private Static void getDigestInformation(String agentKey) {
        
        try {
            /* Digest information can get by sending a request to server */
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(provisionSettings.get('CORNERSTONE_WS') + agentKey);
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
                
            String digestHeader = response.getHeader('WWW-Authenticate');
            
            if(String.isBlank(digestHeader))
                throw new CustomException('Request1: Failed to get digest authentication header');
            
            parseAuthorizationHeader('', digestHeader);
            
            String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(provisionSettings.get('CORNERSTONE_USERNAME')+':'+digestParameters.get('realm')+':'+provisionSettings.get('CORNERSTONE_PWD'))));
            String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('GET:/services/rest/Agent/' + agentKey)));
            String responsestr = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1+':'+digestParameters.get('nonce')+':'+a2)));
            
            request.setHeader('Authorization', 'Digest username="'+provisionSettings.get('CORNERSTONE_USERNAME')+'",realm="'+digestParameters.get('realm')+'",nonce="'+digestParameters.get('nonce')+'",opaque="'+digestParameters.get('opaque')+'",uri="/services/rest/Agent/' + agentKey + '",response="'+responsestr+'",algorithm="MD5"');
            System.HttpResponse response1 = new System.HttpResponse();
                
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
                responseMap.put(node.getName(), node.getText().trim());
            }
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {            
                    responseMap.put(node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                } 
            }
            for (Dom.XMLNode child: node.getChildElements()) {
              parseXML(child);
            }
        }
    }          
    
    public Class CustomException extends Exception {}
}