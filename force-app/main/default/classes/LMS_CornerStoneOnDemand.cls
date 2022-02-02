/* 
    Class handles Corner stone on demand process
*/

public Class LMS_CornerStoneOnDemand {  
    
    private static Map<String, String> resultMap;
    private static Subscriptions__c subscription;
    private static Map<String, String> responseMap;
    private static Related_Association__c association;
    private static Relationship__c relation;
    private static Map<String, String> csodSettingsMap;
    
    @future (callout = true)
    public Static void insertUser(String subscriptionId) {      
        try {         
            subscription = getSubscriptionDetails(subscriptionId);
            getCSODSettings(); 
            if(String.isBlank(subscription.AgentKey__c))
                subscription.AgentKey__c = '0';
            
            if(subscription.BRIGHT_ConversionIsInPreview__c)
                subscription.Service_Jurisdiction__c = 'BRIGHT';
            
            if(!isUserExists(subscription.Name)) 
                setCSODUser(false);
            else
                setCSODUser(true);  
             
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            String subject = 'CSOD Error Log for Subscription(' + subscriptionId + ') insert';          
            String body = e.getMessage() + '\n' + e.getStackTraceString();
            sendEmailNotification(subject, body);
        }          
    }
    
    @future (callout = true)
    public Static void updateUser(String subscriptionId) {      
        try {         
            subscription = getSubscriptionDetails(subscriptionId);
            
            if(subscription.BRIGHT_ConversionIsInPreview__c)
                subscription.Service_Jurisdiction__c = 'BRIGHT';
                
            getCSODSettings(); 
            if(isUserExists(subscription.Name)) 
                setCSODUser(true);
            else {
                //subscription.Date_Joined__c = date.parse('1900-01-01');
                subscription.Date_Joined__c = date.valueOf('1900-01-01');
                setCSODUser(false);
            }               
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            String subject = 'CSOD Error Log for Subscription(' + subscriptionId + ') update';         
            String body = e.getMessage() + '\n' + e.getStackTraceString();
            sendEmailNotification(subject, body);
        }          
    }  
    
    @future (callout = true)
    public Static void updateAssociation(String associationId) {      
        try {         
            association = getSubscriptionAssociation(associationId);
            getCSODSettings();
            if(isUserExists(association.Subscription_ID__c)) 
                updateCSODUserAssociation();  
             
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            String subject = 'CSOD Error Log for Association(' + associationId + ') update';
            String body = e.getMessage() + '\n' + e.getStackTraceString();
            sendEmailNotification(subject, body);
        }          
    }
    
    @future (callout = true)
    public Static void updateRelationship(String relationId) {      
        try {         
            relation = getSubscriptionRelationship(relationId);
            getCSODSettings();
            if(!isUserExists(relation.Subscription_ID__c)) 
                throw new CustomException('User does not exist.');
            
            Boolean isUpdateRelation = true;
            String userRelationCSOD = responseMap.get('Relationship');
            if(userRelationCSOD == relation.Relationship_Type__c && relation.Status__c == 'Inactive') {
                relation.Relationship_Type__c = 'None';
                isUpdateRelation = true;
            } 
            else if(relation.Relationship_Type__c == 'Broker Of Record')
                isUpdateRelation = true;
            else if(userRelationCSOD == 'Broker Of Record' && relation.Status__c == 'Active')
                isUpdateRelation = false;
            else if(relation.Relationship_Type__c == 'Broker Of Record - Branch Office' && relation.Status__c == 'Active')
                isUpdateRelation = true;
            else if((relation.Relationship_Type__c == 'Office Manager' && relation.Status__c == 'Active') && (userRelationCSOD != 'Broker Of Record' && userRelationCSOD != 'Broker Of Record - Branch Office'))   
                isUpdateRelation = true;
            else if((relation.Relationship_Type__c == 'Authorized Signer' && relation.Status__c == 'Active') && (userRelationCSOD != 'Broker Of Record' && userRelationCSOD != 'Broker Of Record - Branch Office' && userRelationCSOD != 'Office Manager'))
                isUpdateRelation = true;
            else
                throw new CustomException('No match exists to update relationship');
            
            updateCSODUserRelationship();  
             
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            String subject = 'CSOD Error Log for Relationship(' + relationId + ') update';
            String body = e.getMessage() + '\n' + e.getStackTraceString();
            sendEmailNotification(subject, body);
        }          
    }  
    
    private Static void updateCSODUserRelationship() {
        try {
            String requestMsg = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:Cornerstone:ClientData" xmlns:ns2="urn:Cornerstone:ClientDataService">'
                                + '<SOAP-ENV:Header>'
                                    + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                        + '<wsse:UsernameToken>'
                                            + '<wsse:Username>' + csodSettingsMap.get('CSOD_USERNAME') + '</wsse:Username>'
                                            + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + csodSettingsMap.get('CSOD_PASSWORD') + '</wsse:Password>'
                                        + '</wsse:UsernameToken>'
                                    + '</wsse:Security>'
                                + '</SOAP-ENV:Header>'  
                                + '<SOAP-ENV:Body>'
                                    + '<ns2:SetUsers>'
                                        + '<ns1:Users>'
                                            + '<ns1:User Id="' + relation.Subscription_ID__c + '" Active="true" Absent="false" AllowReconcile="true" ActivationDate="2015-05-20">'
                                                + '<ns1:Organization Approvals="0">'
                                                    + '<ns1:Unit Type="Relationship">' + relation.Relationship_Type__c + '</ns1:Unit>'         
                                                + '</ns1:Organization>'
                                            + '</ns1:User>'
                                        + '</ns1:Users>'
                                    + '</ns2:SetUsers>'
                                + '</SOAP-ENV:Body>'
                                + '</SOAP-ENV:Envelope>';

            makeCSODAPICall(requestMsg, 'SetUsers');

            if(String.isNotBlank(responseMap.get('Status'))) {
                if(responseMap.get('Status') == 'Error')
                    throw new CustomException(responseMap.get('User'));
                if(responseMap.get('Status') != 'Updated')
                    throw new CustomException('Relationship got ' + responseMap.get('Status') + ' instead of Update');
                if(responseMap.get('Status') == 'Updated')
                    System.debug('Relationship updated successfully');    
            }
            else
                throw new CustomException('Failed: Response Status does not exist');
               
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }    
    }        
    
    private Static void updateCSODUserAssociation() {
        try {
            String requestMsg = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:Cornerstone:ClientData" xmlns:ns2="urn:Cornerstone:ClientDataService">'
                                + '<SOAP-ENV:Header>'
                                    + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                        + '<wsse:UsernameToken>'
                                            + '<wsse:Username>' + csodSettingsMap.get('CSOD_USERNAME') + '</wsse:Username>'
                                            + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + csodSettingsMap.get('CSOD_PASSWORD') + '</wsse:Password>'
                                        + '</wsse:UsernameToken>'
                                    + '</wsse:Security>'
                                + '</SOAP-ENV:Header>'  
                                + '<SOAP-ENV:Body>'
                                    + '<ns2:SetUsers>'
                                        + '<ns1:Users>'
                                            + '<ns1:User Id="' + association.Subscription_ID__c + '" Active="true" ActivePeriod="true" Absent="false" AllowReconcile="true" ActivationDate="2015-05-20">'
                                                + '<ns1:Organization Approvals="0">'
                                                    + '<ns1:Unit Type="Association">' + association.Association_Office_ID__c + '</ns1:Unit>'         
                                                + '</ns1:Organization>'
                                            + '</ns1:User>'
                                        + '</ns1:Users>'
                                    + '</ns2:SetUsers>'
                                + '</SOAP-ENV:Body>'
                                + '</SOAP-ENV:Envelope>';

            makeCSODAPICall(requestMsg, 'SetUsers');

            if(String.isNotBlank(responseMap.get('Status'))) {
                if(responseMap.get('Status') == 'Error')
                    throw new CustomException(responseMap.get('User'));
                if(responseMap.get('Status') != 'Updated')
                    throw new CustomException('Association got ' + responseMap.get('Status') + ' instead of Update');
                if(responseMap.get('Status') == 'Updated')
                    System.debug('Association updated successfully');    
            }
            else
                throw new CustomException('Failed: Response Status does not exist');
               
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }    
    }           
    
    private Static void setCSODUser(Boolean isUpdate) {
        try {
            
            String activationDatestr = '';
            String originalHireDateStr = '';
            if(!isUpdate && subscription.Date_Joined__c != null)
                activationDatestr = 'ActivePeriod="true" ActivationDate="' + String.valueOf(subscription.Date_Joined__c).substring(0,10) + '"';
                
            if(!isUpdate && subscription.Date_Joined__c != null)
                originalHireDateStr = 'OriginalHireDate="' + String.valueOf(subscription.Date_Joined__c).substring(0,10) + '"';                
            
            String requestMsg = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:Cornerstone:ClientData" xmlns:ns2="urn:Cornerstone:ClientDataService">'
                                + '<SOAP-ENV:Header>'
                                    + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                        + '<wsse:UsernameToken>'
                                            + '<wsse:Username>' + csodSettingsMap.get('CSOD_USERNAME') + '</wsse:Username>'
                                            + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + csodSettingsMap.get('CSOD_PASSWORD') + '</wsse:Password>'
                                        + '</wsse:UsernameToken>'
                                    + '</wsse:Security>'
                                + '</SOAP-ENV:Header>'  
                                + '<SOAP-ENV:Body>'
                                    + '<ns2:SetUsers>'
                                        + '<ns1:Users>'
                                            + '<ns1:User Id="' + subscription.Name + '" Active="true" Absent="false" AllowReconcile="true" ' + activationDatestr + '>'
                                                + '<ns1:Contact>'
                                                    + '<ns1:Name Prefix="" First="' + subscription.Contact_Nickname__c + '" Middle="" Last="' + subscription.Contact_Last_Name__c + '" Suffix=""/>'
                                                    + '<ns1:Email>' + subscription.Private_Email__c + '</ns1:Email>'
                                                    + '<ns1:Phone Type="Work">' + subscription.Primary_Phone__c + '</ns1:Phone>'
                                                    + '<ns1:Address CountryCode="US">'
                                                    + '<ns1:Line1></ns1:Line1>'
                                                    + '<ns1:Line2></ns1:Line2>'
                                                    + '<ns1:MailStop></ns1:MailStop>'
                                                    + '<ns1:City></ns1:City>'
                                                    + '<ns1:State>' + subscription.State__c + '</ns1:State>'
                                                    + '<ns1:PostalCode></ns1:PostalCode>'
                                                    + '</ns1:Address>'
                                                + '</ns1:Contact>'
                                                + '<ns1:Organization Approvals="0">'
                                                    + '<ns1:Unit Type="Subscription Type">' + subscription.Subscription_Type__c + '</ns1:Unit>'
                                                    + '<ns1:Unit Type="Division">' + subscription.Service_Jurisdiction__c + '</ns1:Unit>';
                                                if(!isUpdate) {
                                                   requestMsg += '<ns1:Unit Type="Association">NONE1</ns1:Unit>'
                                                              + '<ns1:Employment Status="Active" '+ originalHireDateStr +' />';
                                                }
                                                            
                                     requestMsg += '</ns1:Organization>'
                                                + '<ns1:Authentication>'
                                                    + '<ns1:Username>' + subscription.Name + '</ns1:Username>'
                                                + '</ns1:Authentication>'
                                                + '<ns1:Custom>'
                                                    + '<ns1:Field Name="Office ID">' + subscription.Related_Broker_Code__c + '</ns1:Field>'
                                                    + '<ns1:Field Name="County">' + subscription.QAS_Mailing_County__c + '</ns1:Field>'
                                                    + '<ns1:Field Name="ServiceJurisdiction">' + subscription.Service_Jurisdiction__c + '</ns1:Field>'
                                                    + '<ns1:Field Name= "ConversionPreviewDate">'+subscription.BRIGHT_ConversionPreviewDate__c+ '</ns1:Field>'
                                                + '</ns1:Custom>'
                                            + '</ns1:User>'
                                        + '</ns1:Users>'
                                    + '</ns2:SetUsers>'
                                + '</SOAP-ENV:Body>'
                                + '</SOAP-ENV:Envelope>';
            System.debug('*** requestMsg' + requestMsg);

            makeCSODAPICall(requestMsg, 'SetUsers');
            
            if(!isUpdate){
                if(String.isNotBlank(responseMap.get('Status'))&& responseMap.get('Status') != 'Added')
                    throw new CustomException('User got ' + responseMap.get('Status') + ' instead of Insert');
                if(String.isNotBlank(responseMap.get('Status')) && responseMap.get('Status') == 'Added') 
                    System.debug('User added successfully');
            }
            if(isUpdate){
                if(String.isNotBlank(responseMap.get('Status'))&& responseMap.get('Status') != 'Updated')
                    throw new CustomException('User got ' + responseMap.get('Status') + ' instead of Update');
                if(String.isNotBlank(responseMap.get('Status')) && responseMap.get('Status') == 'Updated') 
                    System.debug('User updated successfully'); 
            }                   
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }    
    }
    
    private Static Boolean isUserExists(String subscriptionId) {
        try {
            String requestMsg = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
                                    + '<SOAP-ENV:Header>'
                                        + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                            + '<wsse:UsernameToken>'
                                                + '<wsse:Username>' + csodSettingsMap.get('CSOD_USERNAME') + '</wsse:Username>'
                                                + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + csodSettingsMap.get('CSOD_PASSWORD') + '</wsse:Password>'
                                            + '</wsse:UsernameToken>'
                                        + '</wsse:Security>'
                                    + '</SOAP-ENV:Header>'
                                    + '<SOAP-ENV:Body>'
                                        + '<m:GetUser xmlns:m="urn:Cornerstone:ClientDataService">'
                                            + '<m:strUserId>' + subscriptionId + '</m:strUserId>'
                                        + '</m:GetUser>'
                                    + '</SOAP-ENV:Body>'
                                + '</SOAP-ENV:Envelope>';
                                
            makeCSODAPICall(requestMsg, 'GetUser');

            if(String.isNotBlank(responseMap.get('Username')))
                return true;
            
            return false;
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    private static void makeCSODAPICall(String requestMsg, String soapAction) {
        try {
            System.debug('Request:' + requestMsg);
        
            System.HttpRequest request = new System.HttpRequest();
            request.setBody(requestMsg);
            request.setMethod('POST');
            request.setEndpoint(csodSettingsMap.get('CSOD_WS'));
            request.setTimeout(90000);
            request.setHeader('Content-type', 'text/xml');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/xml');
            request.setHeader('Cache-Control', 'no-cache');
            request.setHeader('Pragma', 'no-cache');
            request.setHeader('SOAPAction', soapAction);
            request.setHeader('Connection', 'Keep-Alive');
            System.debug('*** request' + request);
            
            try {
                System.HttpResponse response = new System.HttpResponse();
                if (Test.isRunningTest())
                    response = LMS_MockDataGenerator.generateMockData(request);
                else
                    response = new System.Http().send(request);
                     
                String responseBody = response.getBody();
                System.debug('*** responseBody' + responseBody);
                
                if(!(response.getStatusCode() == 200))
                    throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus());
                
                responseMap = new Map<String, String>();
                Dom.Document result = response.getBodyDocument();
                Dom.XMLNode envelope = result.getRootElement();
                parseXML(envelope);              
                System.debug('*** responseMap:' + responseMap); 
                for(String key : responseMap.keyset()){
                    System.debug('*** response key value:' + key + '==' + responseMap.get(key));
                }
                
                if(!(responseMap.Size() > 0))
                    throw new CustomException('Failed: Unable to process response');
                
                if(String.isNotBlank(responseMap.get('ExceptionMessage')))
                    throw new CustomException(responseMap.get('ExceptionMessage') + ': ' + responseMap.get('ExceptionInfo'));                                                   
            }
            catch(System.CalloutException e) {
                throw new CustomException('CalloutException: ' + e.getMessage());
            }              
        } 
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }            
    }
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if (node.getText().trim() != '') {
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
      
    private static Subscriptions__c getSubscriptionDetails(String subscriptionId) {
        List<Subscriptions__c> subscriptionList = [SELECT Id, 
                                                          Name,
                                                          AgentKey__c,
                                                          Contact_Last_Name__c,
                                                          Contact_Nickname__c,
                                                          Date_Joined__c,
                                                          Nickname__c,
                                                          Primary_Phone__c,
                                                          Private_Email__c,
                                                          QAS_Mailing_County__c,
                                                          Related_Broker_Code__c,
                                                          State__c,
                                                          Subscription_Type__c,
                                                          Service_Jurisdiction__c,
                                                          BRIGHT_ConversionPreviewDate__c, 
                                                          BRIGHT_ConversionIsInPreview__c   
                                                    FROM  Subscriptions__c
                                                    WHERE Id = :subscriptionId];
        if(subscriptionList.Size() != 1)
            throw new CustomException('Invalid subscription');
            
        return subscriptionList[0];                                                          
    } 
    
    private static Related_Association__c getSubscriptionAssociation(String associationId) {
        List<Related_Association__c> associationList = [SELECT  AgentKey__c,
                                                                Association_Office_ID__c,
                                                                Id,
                                                                Status__c,
                                                                Subscription_ID__c
                                                        FROM Related_Association__c
                                                        WHERE Id = :associationId];
                                                        
        if(associationList.Size() != 1)
            throw new CustomException('Invalid subscription association');
            
        return associationList[0];                                                           
    }
    
    private static Relationship__c getSubscriptionRelationship(String relationshipId) {
        List<Relationship__c> relationshipList = [SELECT AgentKey__c, 
                                                      Broker_Office_Code__c, 
                                                      Id, 
                                                      Relationship_Type__c, 
                                                      Status__c, 
                                                      Subscription_ID__c
                                               FROM Relationship__c 
                                               WHERE Id = :relationshipId];
                                               
        if(relationshipList.Size() != 1)
            throw new CustomException('Invalid subscription relationship'); 
            
        return relationshipList[0];                                              
    }
    
    private Static void getCSODSettings() {
        List<LMS_CSOD_Settings__c> csodSettings = [SELECT Id, Name, Value__c FROM LMS_CSOD_Settings__c];
        csodSettingsMap = new Map<String, String>();
        for(LMS_CSOD_Settings__c csodSetting : csodSettings) {
            csodSettingsMap.put(csodSetting.Name, csodSetting.Value__c);    
        }      
    }
    
    private Static void sendEmailNotification(String subject, String body) {     
        String emails = csodSettingsMap.get('CSOD_EMAIL_ALERTS');
        if(String.isNotBlank(emails)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            List<String> sendTo = emails.split(',');
            mail.setToAddresses(sendTo); 
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }    
    }      
    
    public Class CustomException extends Exception {}
}