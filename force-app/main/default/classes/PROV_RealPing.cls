/* 
    Class handles provisioning for the product Xactsite Agent 
*/

public Class PROV_RealPing {  
    
    private Static SMS_Provisioned_Product__c provProduct;
    private Static Subscriptions__c subscription;
    private Static Map<String, String> provisionSettings;
    
    @future (callout = true)
    public Static void provisionRealPing(String provProductId) {
        
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
                    addSubscriber();
                else if(provProduct.Product_Status__c == 'Terminate')
                    updateSubscriberStatus('disabled'); 
                else if(provProduct.Product_Status__c == 'Reinstate')
                    updateSubscriberStatus('active'); 
                else if(provProduct.Product_Status__c == 'Update')
                    updateSubscriber();                                     
            }
            catch(Exception e) {
                System.debug('Error:' + e.getMessage());
            }
        }
        catch(Exception e) {
        
        }
        
    }
    
    private static void updateSubscriber() {
        try {
            
            String query  = 'action=update_subscriber';
                   query += '&license=' + provisionSettings.get('REALPING_LICENSE');
                   query += '&format=xml';
                   query += '&subscriber=' + EncodingUtil.urlEncode(provProduct.RealPing_Id__c, 'UTF-8');
                   query += '&poc=' + EncodingUtil.urlEncode(subscription.Contact__r.FirstName + ' ' + subscription.Contact__r.LastName, 'UTF-8');
                   query += '&email=' + EncodingUtil.urlEncode(subscription.Private_Email__c, 'UTF-8');
                   query += '&address=' +  EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Full_Street_Address__c, 'UTF-8');
                   query += '&city=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.City__c, 'UTF-8');
                   query += '&state=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.State__c, 'UTF-8');
                   query += '&zip=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Zip__c, 'UTF-8');
                   query += '&phone=' + EncodingUtil.urlEncode(subscription.Primary_Phone__c, 'UTF-8');
                   query += '&company=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Account_Name__c, 'UTF-8');
                   
            Map<String, String> resultMap = makeRealPingAPICall(query);  
            if(Integer.valueOf(resultMap.get('response')) > 0) {
                provProduct.RealPing_Id__c =  resultMap.get('response'); 
                provProduct.Status_Message__c = 'Subscriber details updated';                   
            }    
        }
        catch(Exception e) {
            provProduct.Status_Message__c = 'Failed to update. ' + e.getMessage();        
        }
        
        update provProduct;
    }    
    
    private static void updateSubscriberStatus(String status) {
        try {
            
            String query  = 'action=update_status';
                   query += '&license=' + provisionSettings.get('REALPING_LICENSE');
                   query += '&format=xml';
                   query += '&subscriber=' + EncodingUtil.urlEncode(provProduct.RealPing_Id__c, 'UTF-8');
                   query += '&status=' + status;
                   
            Map<String, String> resultMap = makeRealPingAPICall(query);  
            if(Integer.valueOf(resultMap.get('response')) > 0) {
                String csError = '';
                if(String.isNotBlank(subscription.agentkey__c)) {
                    String csReponse = '';
                    if(status == 'disabled')
                        csReponse = PROV_CornerStoneUpdate.updateCornerStone(subscription.agentkey__c, '');
                    else
                        csReponse = PROV_CornerStoneUpdate.updateCornerStone(subscription.agentkey__c, provProduct.RealPing_Id__c);
                        
                    if(csReponse != 'Success')
                        csError = csReponse;
                }
                
                if(status == 'disabled')
                    provProduct.provisioned_status__c =  'Deprovisioned';
                else
                    provProduct.provisioned_status__c =  'Provisioned';
                    
                provProduct.RealPing_Id__c =  resultMap.get('response'); 
                
                if(String.isNotBlank(csError) && csError.length() > 250)
                    csError = csError.subString(0, 250);                
                
                provProduct.Status_Message__c = csError;                   
            }    
        }
        catch(Exception e) {
            provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
            provProduct.Status_Message__c = e.getMessage();        
        }
        
        update provProduct;
    }    
    
    private static void addSubscriber() {
        try {
            
            String query  = 'action=add_subscriber';
                   query += '&license=' + provisionSettings.get('REALPING_LICENSE');
                   query += '&format=xml';
                   query += '&poc=' + EncodingUtil.urlEncode(subscription.Contact__r.FirstName + ' ' + subscription.Contact__r.LastName, 'UTF-8');
                   query += '&email=' + EncodingUtil.urlEncode(subscription.Private_Email__c, 'UTF-8');
                   query += '&address=' +  EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Full_Street_Address__c, 'UTF-8');
                   query += '&city=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.City__c, 'UTF-8');
                   query += '&state=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.State__c, 'UTF-8');
                   query += '&zip=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Zip__c, 'UTF-8');
                   query += '&phone=' + EncodingUtil.urlEncode(subscription.Primary_Phone__c, 'UTF-8');
                   query += '&company=' + EncodingUtil.urlEncode(subscription.Related_Location_Broker_Office__r.Account_Name__c, 'UTF-8');
                   
            Map<String, String> resultMap = makeRealPingAPICall(query);  
            if(Integer.valueOf(resultMap.get('id')) > 0) {
                String csError = '';
                if(String.isNotBlank(subscription.agentkey__c)) {
                    String csReponse = PROV_CornerStoneUpdate.updateCornerStone(subscription.agentkey__c, resultMap.get('id'));
                    if(csReponse != 'Success')
                        csError = csReponse;
                }
                
                provProduct.provisioned_status__c =  'Provisioned';
                provProduct.RealPing_Id__c =  resultMap.get('id'); 
                
                if(String.isNotBlank(csError) && csError.length() > 250)
                    csError = csError.subString(0, 250);
                
                provProduct.Status_Message__c = csError;                   
            }
      
        }
        catch(Exception e) {
            provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
            provProduct.Status_Message__c = e.getMessage();        
        }
        
        update provProduct;
    }
    
    private static Map<String, String> makeRealPingAPICall(String query) {
        Map<String, String> resultMap = new Map<String, String>();
        try {
        
            System.HttpRequest request = new System.HttpRequest();
            request.setMethod('POST');
            request.setEndpoint(provisionSettings.get('REALPING_WS') + '?' + query);
            request.setHeader('Content-type', 'text/xml');
            request.setHeader('charset', 'utf-8');
            request.setHeader('Accept', 'text/xml');
            request.setHeader('Cache-Control', 'no-cache');
            request.setHeader('Pragma', 'no-cache');
            
            try {    
                System.HttpResponse response = new System.HttpResponse();
                    
                /* Process response from authentisn web services */
                if (Test.isRunningTest())
                    response = PROV_MockDataGenerator.generateMockData(request);    
                else
                    response = new System.Http().send(request);
                
                /* Verify http response status */
                if(!(response.getStatusCode() == 200))
                    throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus()); 
                
                String responseBody = response.getBody();                
                System.debug(response);
                System.debug(responseBody);                    
                    
                /* Check for realping service response */ 
                if(responseBody.indexOf('<RealPING>', 0) >= 0) {
                    resultMap = parseResponse(response);
                    if(String.isNotBlank(resultMap.get('response'))) {
                        if(resultMap.get('response') == '0')
                            throw new CustomException('Failed: ' + resultMap.get('response') + '-' + resultMap.get('message'));
                        else
                            return resultMap;   
                    }
                    else
                        throw new CustomException('Failed: No response code received from services');
                }
                else
                    throw new CustomException('Failed: ' + responseBody);              
            }
            catch(System.CalloutException e) {
                throw new CustomException('CalloutException: ' + e.getMessage());
            }
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }
        return resultMap;         
    }
    
    private static Map<String, String> parseResponse(System.HttpResponse response) {
        Map<String, String> resultMap = new Map<String, String>(); 
       
        Dom.Document result = response.getBodyDocument();
        Dom.XMLNode root = result.getRootElement();

        for(Dom.XMLNode child1: root.getChildElements()) {
            if(child1.getName() == 'response' || child1.getName() == 'message')
                resultMap.put(child1.getName(), child1.getText());
            else {
                for(Dom.XMLNode ele: child1.getChildElements())
                    resultMap.put(ele.getName(), ele.getText());  
            }
        }

        return resultMap;
    }        
    
    public Class CustomException extends Exception {}
}