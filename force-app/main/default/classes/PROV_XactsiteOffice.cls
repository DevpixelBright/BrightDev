/* 
    Class handles provisioning for the product Xactsite Agent 
*/

public Class PROV_XactsiteOffice {  
    
    private Static SMS_Provisioned_Product__c provProduct;
    private Static Subscriptions__c subscription;
    private Static Map<String, String> provisionSettings; 
    private Static Integer retryCount = 0;
    
    @future (callout = true)
    public Static void provisionXactsiteOffice(String provProductId) {
        
        try {
            List<SMS_Provisioned_Product__c> provisionProduct = new List<SMS_Provisioned_Product__c>();
            provisionProduct = PROV_GetProvisionProductDetails.getProvisionProduct(provProductId);
            
            if(!(provisionProduct.Size() == 1))
                throw new CustomException('Invalid provisioned product');        
            
            provProduct = provisionProduct[0];
            
            try {
                /* Get data from subscription, Contact and subscription associations */                     
                List<Subscriptions__c> subscriptionList = new List<Subscriptions__c>();     
                subscriptionList = PROV_GetProvisionProductDetails.getSubscriptionDetails(provisionProduct[0].MRIS_Subscription_Id__c); 
 
                if(!(subscriptionList.Size() == 1))
                    throw new CustomException('Invalid subscription');
                    
                subscription = subscriptionList[0];
                
                /* Get provisioning custom settings */
                provisionSettings = PROV_GetProvisionProductDetails.getProvisionSettings();                 
                
                /* Check product status to decide api call */
                if(provProduct.Product_Status__c == 'New')
                    activateAgentWebsite(); 
                else if(provProduct.Product_Status__c == 'Reinstate')  
                    reinstateAgentWebsite();
                else if(provProduct.Product_Status__c == 'Terminate')
                    terminateAgentWebsite(false);
                else if(provProduct.Product_Status__c == 'Update') {
                    terminateAgentWebsite(true);
                    activateAgentWebsite();
                }                               
            }
            catch(Exception e) {
            
            }        
        }
        catch(Exception e) {
        
        }
        
    }
    
    private static void terminateAgentWebsite(Boolean isUpdate) {
        try {
            String requestMsg = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                                    + '<soap:Body>'
                                        + '<DeactivateOfficeWebsite xmlns="http://services.fnistools.com/">'
                                            + '<officeAdminAgentCode>' + subscription.Related_Location_Broker_Office__r.Name + '</officeAdminAgentCode>'
                                            //+ '<officeAdminAgentCode>' + subscription.Related_Location_Broker_Office__r.BRIGHT_Office_Key__c + '</officeAdminAgentCode>'
                                        + '</DeactivateOfficeWebsite>'
                                    + '</soap:Body>'
                                + '</soap:Envelope>';
                  
            Boolean isAgentTerminated = makeXactsiteAPICall(provisionSettings.get('XACTSITE_SOAP_ACTION_DEACTIVATE_OFFICE'), requestMsg);
            if(isAgentTerminated) {
                provProduct.provisioned_status__c =  'Deprovisioned'; 
                provProduct.Status_Message__c = '';   
            }
            else
                throw new CustomException('Failed: MakeXactsiteAPICall - Unexpected error occured');                            
        }
        catch(Exception e) {
            provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
            provProduct.Status_Message__c = e.getMessage();              
        }
        
        if(!isUpdate)
            update provProduct;     
    }    
    
    private static void reinstateAgentWebsite() {
        try {
            String requestMsg = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                                    + '<soap:Body>'
                                        + '<ReactivateOfficeWebsite xmlns="http://services.fnistools.com/">'
                                            + '<officeAdminAgentCode>' + subscription.Related_Location_Broker_Office__r.Name + '</officeAdminAgentCode>'
                                            //+ '<officeAdminAgentCode>' + subscription.Related_Location_Broker_Office__r.BRIGHT_Office_Key__c + '</officeAdminAgentCode>'
                                        + '</ReactivateOfficeWebsite>'
                                    + '</soap:Body>'
                                + '</soap:Envelope>';
                  
            Boolean isAgentTerminated = makeXactsiteAPICall(provisionSettings.get('XACTSITE_SOAP_ACTION_REACTIVATE_OFFICE'), requestMsg);
            if(isAgentTerminated) {
                provProduct.provisioned_status__c =  'Provisioned'; 
                provProduct.Status_Message__c = '';   
            }
            else
                throw new CustomException('Failed: MakeXactsiteAPICall - Unexpected error occured');                            
        }
        catch(Exception e) {
            provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
            provProduct.Status_Message__c = e.getMessage();              
        }
        
        update provProduct;       
    }
    
    private static void activateAgentWebsite() {
        try {
            //String phoneNumber = subscription.Primary_Phone__c;
            //phoneNumber = phoneNumber.replaceAll('[^0-9]', ''); 
            String requestMsg = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.fnistools.com/">'
                                 + '<soap:Body>'
                                         + '<ser:ActivateOfficeWebsite xmlns="http://services.fnistools.com/">'
                                             + '<ser:officeAdmin>'
                                                 + '<ser:FirstName>' + subscription.Contact__r.FirstName + '</ser:FirstName>'
                                                 + '<ser:LastName>' + subscription.Contact__r.LastName + '</ser:LastName>'
                                                 + '<ser:AgentCode>' + subscription.Related_Location_Broker_Office__r.Name + '</ser:AgentCode>'
                                                 + '<ser:Login>' + subscription.Related_Location_Broker_Office__r.Name + '</ser:Login>'
                                                 + '<ser:Password>changeme</ser:Password>'
                                                 //+ '<ser:OfficeCode>' +  subscription.Related_Location_Broker_Office__r.Name + '</ser:OfficeCode>'
                                                 + '<ser:OfficeCode>' +  subscription.Related_Location_Broker_Office__r.BRIGHT_Office_Key__c + '</ser:OfficeCode>'
                                                 + '<ser:UserTemplateName>' + provProduct.Product_sub_type__c + '</ser:UserTemplateName>'
                                                 + '<ser:Phones>'
                                                     + '<ser:Phone>'
                                                         + '<ser:PhoneType>DirectOffice</ser:PhoneType>'
                                                         + '<ser:PhoneNumber>' + subscription.Primary_Phone__c + '</ser:PhoneNumber>'
                                                         + '<ser:Extension></ser:Extension>'
                                                     + '</ser:Phone>'
                                                 + '</ser:Phones>'
                                                 + '<ser:Emails>'
                                                     + '<ser:Email>'
                                                         + '<ser:EmailType>Primary</ser:EmailType>'
                                                         + '<ser:EmailAddress>' +  subscription.Private_Email__c + '</ser:EmailAddress>'
                                                     + '</ser:Email>'
                                                 + '</ser:Emails>'
                                                 + '<ser:Website>'
                                                     + '<ser:BillingType>Active</ser:BillingType>'
                                                     + '<ser:WebsitePackage>' + provProduct.Product_sub_type__c + '</ser:WebsitePackage>'
                                                     + '<ser:WebsiteDesign>Design 41</ser:WebsiteDesign>'
                                                     + '<ser:RealPingID>' + provProduct.RealPing_Id__c + '</ser:RealPingID>'
                                                     + '<ser:Urls/>'
                                                 + '</ser:Website>'
                                             + '</ser:officeAdmin>'
                                         + '</ser:ActivateOfficeWebsite>'
                                + '</soap:Body>'
                                + '</soap:Envelope>';
            
            Boolean isAgentActivated = makeXactsiteAPICall(provisionSettings.get('XACTSITE_SOAP_ACTION_ACTIVATE_OFFICE'), requestMsg);
            if(isAgentActivated) {
                provProduct.provisioned_status__c =  'Provisioned'; 
                provProduct.Status_Message__c = '';              
            }
            else
                throw new CustomException('Failed: MakeXactsiteAPICall - Unexpected error occured');                                     
        }
        catch(Exception e) {
            provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
            provProduct.Status_Message__c = e.getMessage();              
        }
        
        update provProduct;       
    }
    
    private static Boolean makeXactsiteAPICall(String soapAction, String requestMsg) {
        try {      
            System.HttpRequest request = new System.HttpRequest();
            System.debug('***requestMsg' + requestMsg);
            request.setBody(requestMsg);
            request.setMethod('POST');
            request.setEndpoint(provisionSettings.get('XACTSITE_WS'));
            request.setTimeout(50000);
            request.setHeader('Content-type', 'text/xml');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/xml');
            request.setHeader('Cache-Control', 'no-cache');
            request.setHeader('Pragma', 'no-cache');
            request.setHeader('SOAPAction', soapAction);
            request.setHeader('Connection', 'Keep-Alive');
            
            Blob headerValue = Blob.valueOf(provisionSettings.get('XACTSITE_USERNAME') + ':' + provisionSettings.get('XACTSITE_PWD'));
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader); 
            
            try {
                System.HttpResponse response = new System.HttpResponse();
                    
                /* Process response from authentisn web services */
                if (Test.isRunningTest())
                    response = PROV_MockDataGenerator.generateMockData(request);    
                else
                    response = new System.Http().send(request);
                system.debug('FULL request: ' + request);
                if(!(response.getStatusCode() == 200))
                    throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus());
                    
                String responseBody = response.getBody();
                System.debug('***responseBody' + responseBody);                    
                
                Map<String, String> resultMap = new Map<String, String>(); 
                Boolean isSoapFault = false;  
                /* Is response has SOAP fault */
                if(responseBody.indexOf('<soap:Fault>', 0) > 0) { 
                    resultMap = parseResponse(response, true);
                    isSoapFault = true;
                }
                else
                    resultMap = parseResponse(response, false);
                    
                System.debug(resultMap);
                
                if(!(resultMap.Size() > 0))
                    throw new CustomException('Did not receive expected response: ' + responseBody); 
                    
                if(isSoapFault)
                    throw new CustomException('SoapFault: ' + resultMap.get('faultcode') + ' - ' + resultMap.get('faultstring'));
                else {
                    if(resultMap.get('StatusCode') == '200')
                        return true;
                    else {
                        if(String.isNotBlank(resultMap.get('StatusCode')))
                            throw new CustomException(resultMap.get('StatusCode') + ': ' + resultMap.get('StatusMessage'));
                        else
                            throw new CustomException('Received unexpected error in response');
                    }    
                }                                  
            }
            catch(System.CalloutException e) {
                throw new CustomException('CalloutException: ' + e.getMessage());
            }                                               
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        } 
        
        return false;  
    }
    
    private static Map<String, String> parseResponse(System.HttpResponse response, Boolean isSoapFault) {
        Map<String, String> resultMap = new Map<String, String>(); 
       
        Dom.Document result = response.getBodyDocument();
        Dom.XMLNode envelope = result.getRootElement();
        Dom.XMLNode body= envelope.getChildElements()[0];
        if(isSoapFault) {
            for(Dom.XMLNode soapFault: body.getChildElements()) {
                for(Dom.XMLNode ele : soapFault.getChildElements())
                    resultMap.put(ele.getName(), ele.getText()); 
            }        
        }
        else {
            for(Dom.XMLNode ActivateAgentWebsiteResponse: body.getChildElements()) {
                for(Dom.XMLNode ActivateAgentWebsiteResult: ActivateAgentWebsiteResponse.getChildElements()) {
                    for(Dom.XMLNode ele : ActivateAgentWebsiteResult.getChildElements())
                        resultMap.put(ele.getName(), ele.getText());  
                }
            }
        }
        return resultMap;
    }    
    
    public Class CustomException extends Exception {}
}