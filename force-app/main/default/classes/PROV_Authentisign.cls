/* 
    Class handles provisioning for the product Authentisign 
*/

public Class PROV_Authentisign {  
    
    private Static SMS_Provisioned_Product__c provProduct;
    private Static Map<String, String> provisionSettings;
    
    public class MRISUser
    {
        public string MRISId;
        public string OfficeMRISId;
        public boolean IsCBRBMidAtlantic;
        public boolean IsReMaxAllegiance;
 
        public string NRDSId;
        public string FirstName;
        public string LastName;
        public string Phone;
        public string Cell;
        public string EmailAddress;
 
        public string OfficeNRDSId;
        public string OfficeName;
        public string OfficeAddress;
        public string OfficeCity;
        public string OfficeState;
        public string OfficeZipcode;
        public string OfficePhone;
        public string OfficeFax;
    }
 
    public class MRISRequestDetails
    {
        public MRISUser User;
        public Boolean SkipExistingUpgradeTest;
 
        public integer RequestCode;
        public string OrderId;
        public DateTime PurchaseDateTimeUTC;
        public string ProductSKU;
 
    }
    public static MRISUser GetUser(SMS_Provisioned_Product__c provisionProduct, Subscriptions__c subscription, Boolean isCBRB, Boolean isRMAX){
            MRISUser user = new MRISUser();
            
            user.MRISId = provisionProduct.MRIS_Subscription_Id__c;
             
            user.FirstName = subscription.Contact__r.FirstName;
            user.LastName = subscription.Contact__r.LastName;
            user.EmailAddress = subscription.Private_Email__c;
            user.Cell = subscription.Mobile_Phone__c;
            user.Phone = subscription.Primary_Phone__c;

            user.IsCBRBMidAtlantic = isCBRB;
            user.IsReMaxAllegiance = isRMAX;

            user.OfficeMRISId = provisionProduct.MRIS_Subscription_Id__c;
            user.OfficeName = subscription.Related_Location_Broker_Office__r.Name;
            user.OfficeAddress = subscription.Related_Location_Broker_Office__r.Full_Street_Address__c;
            user.OfficeCity = subscription.Related_Location_Broker_Office__r.City__c;
            user.OfficeState = subscription.Related_Location_Broker_Office__r.State__c;
            user.OfficeZipcode = subscription.Related_Location_Broker_Office__r.Zip__c;
            user.OfficePhone = '';
            user.OfficeFax = subscription.Home_Fax__c;
        
            return user;
        }
    
    @future (callout = true)
    public Static void provisionAuthentisign(String provProductId) {
        try {
               
            List<SMS_Provisioned_Product__c> provisionProduct = new List<SMS_Provisioned_Product__c>();
            provisionProduct = PROV_GetProvisionProductDetails.getProvisionProduct(provProductId);
            
            if(!(provisionProduct.Size() == 1))
                throw new CustomException('Invalid provisioned product');        
            
            provProduct = provisionProduct[0];
            
            try {
                
                /* Get data from subscription, Contact and subscription associations */                     
                List<Subscriptions__c> subscription = new List<Subscriptions__c>();     
                subscription = PROV_GetProvisionProductDetails.getSubscriptionDetails(provisionProduct[0].MRIS_Subscription_Id__c); 
                System.debug('*** test subscription: ' + subscription[0].Related_Location_Broker_Office__r.Name);  
                if(!(subscription.Size() == 1))
                    throw new CustomException('Invalid subscription');
                    
                /* Get provisioning custom settings */
                provisionSettings = PROV_GetProvisionProductDetails.getProvisionSettings();                  
                
                /* Request variables based on conditions */
                String productId = provisionProduct[0].provisioned_product_Id__c;
                if(String.isBlank(provisionProduct[0].provisioned_product_Id__c))
                     productId = provisionProduct[0].Name;
                     
                String officesCBRB = 'Alexandria/King Street,94500105,94500105,CBRB,54,MRISAndrews,91901204,91901204,CBRB,87,MRISAnnandale,94500202,94500202,CBRB,89,MRISAnnapolis Church Circle,91900201,91900201,CBRB,43,MRISAnnapolis Plaza,91900202,91900202,CBRB,29,MRISArlington,94500301,94500301,CBRB,66,MRISBethany Beach/Sunrise Court,91900702,91900702,CBRB,74,InnoviaBethesda/Downtown,91900803,91900803,CBRB,53,MRISBowie/Upper Marlboro,91905601,91905601,CBRB,69,MRISBWI @ Arundel Mills,91903601,91903601,CBRB,20,MRISCanton,91900307,91900307,CBRB,171,MRISCapitol Hill North,98000109,98000109,CBRB,92,MRISCapitol Hill South,98000104,98000104,CBRB,52,MRISCatonsville,91901301,91901301,CBRB,13,MRISCentreville,94500401,94500401,CBRB,104,MRISChestertown,91901501,91901501,CBRB,39,MRISChevy Chase,98000105,98000105,CBRB,49,MRISColumbia,91901702,91901702,CBRB,44,MRISCommercial Services,91905410,91905410,CBRB,5,MRISCrofton,91902701,91902701,CBRB,30,MRISDale City,94501902,94501902,CBRB,68,MRISDulles/Ashburn,94501601,94501601,CBRB,74,MRISDundalk,91901901,91901901,CBRB,22,MRISDupont,98000110,98000110,CBRB,106,MRISEaston,91902002,91902002,CBRB,95,MRISEldersburg,91902101,91902101,CBRB,14,MRISEllicott City/Chatham,91902303,91902303,CBRB,77,MRISEllicott City/Enchanted Forest,91902302,91902302,CBRB,19,MRISFair Oaks,94500602,94500602,CBRB,88,MRISFederal Hill,91900302,91900302,CBRB,11,MRISFells Point,91900303,91900303,CBRB,16,MRISForest Hill,91902401,91902401,CBRB,12,MRISFrederick,91902501,91902501,CBRB,28,MRISGeorgetown,98000106,98000106,CBRB,45,MRISGlen Burnie,91902801,91902801,CBRB,24,MRISGreenspring,91903701,91903701,CBRB,10,MRISHagerstown,91902901,91902901,CBRB,41,MRISHampstead,91903001,91903001,CBRB,15,MRISHarford County Regional Office,91900402,91900402,CBRB,42,MRISHunt Valley,91903101,91903101,CBRB,6,MRISJacksonville,91904602,91904602,CBRB,78,MRISLake Ridge,94501903,94501903,CBRB,63,MRISLanham/Greenbelt,91903301,91903301,CBRB,61,MRISLaurel,91903501,91903501,CBRB,81,MRISLeesburg,94501001,94501001,CBRB,46,MRISLexington Park,91901001,91901001,CBRB,38,MRISManassas,94501101,94501101,CBRB,67,MRISMcLean,94501201,94501201,CBRB,51,MRISMount Airy,91903801,91903801,CBRB,9,MRISNorth Potomac/Rockville,91902601,91902601,CBRB,70,MRISOcean City/104th St.,91904107,91904107,CBRB,44,ARISOcean City/120th St,91904119,91904119,CBRB,50,ARISOcean City/52nd St.,91904108,91904108,CBRB,46,ARISOcean City/57th St,91904120,91904120,CBRB,51,ARISOcean Pines,91900601,91900601,CBRB,47,ARISOcean Pines/Cathell Rd,91900603,91900603,CBRB,52,ARISOwings Mills,91904301,91904301,CBRB,3,MRISOxon Hill,91904401,91904401,CBRB,62,MRISPasadena/Southdale,91904501,91904501,CBRB,21,MRISPotomac,91904701,91904701,CBRB,50,MRISRehoboth,97000402,97000402,CBRB,48,InnoviaReisterstown,91904801,91904801,CBRB,4,MRISReston Town Center,94501402,94501402,CBRB,47,MRISRoland Park,91900304,91900304,CBRB,5,MRISRoland Park at Wyndhurst,91900305,91900305,CBRB,36,MRISSalisbury: Cooper-Stewart Center,91906101,91906101,CBRB,75,ARISSeverna Park,91905001,91905001,CBRB,27,MRISSpringfield,94501501,94501501,CBRB,86,MRISSt. Michaels,91905301,91905301,CBRB,99,MRISTimonium,91905413,91905413,CBRB,1,MRISTowson South,91905501,91905501,CBRB,7,MRISTowson-Lutherville,91903702,91903702,CBRB,8,MRISVienna,94501751,94501751,CBRB,58,MRISWaldorf,91905801,91905801,CBRB,37,MRISWarrenton,94501801,94501801,CBRB,60,MRISWestminster,91905901,91905901,CBRB,35,MRISWhite Marsh,91906001,91906001,CBRB,2,MRIS';
                Boolean isCBRB = false;
                if(officesCBRB.indexOf(subscription[0].Related_Location_Broker_Office__r.Name, 0) >= 0)
                    isCBRB = true;
                    
                String officeRMAX = 'RMAX1022,RMAX1023';
                Boolean isRMAX = false;
                if(officeRMAX.indexOf(subscription[0].Related_Location_Broker_Office__r.Name, 0) >= 0)
                    isRMAX = true;                    
                
                
                map<string, integer> requestCodesMap = new map<string, integer>();
                requestCodesMap.put('New', 0);
                requestCodesMap.put('Terminate', 1);
                requestCodesMap.put('Suspend', 2);
                requestCodesMap.put('Reinstate', 3);
                requestCodesMap.put('Renewal', 4);
                requestCodesMap.put('Update', 4);
        
                
                MRISRequestDetails obj = new MRISRequestDetails();
                obj.User = getUser(provisionProduct[0], subscription[0], isCBRB, isRMAX);
                obj.PurchaseDateTimeUTC = provisionProduct[0].LastModifiedDate;
                obj.OrderId = productId;
                if(requestCodesMap.containsKey(provisionProduct[0].Product_Status__c))
                    obj.RequestCode = requestCodesMap.get(provisionProduct[0].Product_Status__c);
                    
                System.debug(JSON.serialize(obj)); 
                System.HttpRequest request = new System.HttpRequest();
                request.setBody(JSON.serialize(obj));
                request.setMethod('POST');
                request.setEndpoint(provisionSettings.get('AUTHENTSIGN_WS'));
                request.setHeader('Content-type', 'text/json');
                request.setHeader('Accept', 'text/xml');

                
                try {
                    System.HttpResponse response = new System.HttpResponse();
                                       
                    /* Process response from authentisn web services */
                    if (Test.isRunningTest())
                        response = PROV_MockDataGenerator.generateMockData(request);    
                    else
                        response = new System.Http().send(request);
                        
                    System.debug('*** response' + response.getBody());
                    if(!(response.getStatusCode() == 200)) 
                        throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus());           
                    
                    Map<String, String> resultMap = parseResponse(response);
                    if(!(resultMap.Size() > 1))
                        throw new CustomException('Did not receive expected response: ' + response.getBody());
                    
                    /* Verify the response */   
                    provProduct.Status_Message__c = '';
                    
                    if(String.isNotBlank(resultMap.get('UpgradeGUID')))
                        provProduct.Authentisign_Id__c = resultMap.get('UpgradeGUID');
                    if(String.isNotBlank(resultMap.get('UserGUID'))) 
                        provProduct.Authentisign_User_Id__c = resultMap.get('UserGUID');                    
                                       
                    if((provProduct.Product_Status__c == 'NEW' && resultMap.get('ShortResult') == 'UpgradeCreatedSuccessfully') || (provProduct.Product_Status__c == 'Reinstate' && resultMap.get('ShortResult') == 'UpgradeReinstatedSuccessfully'))                 
                        provProduct.provisioned_status__c = 'Provisioned'; 
                    else if(provProduct.Product_Status__c == 'Terminate' && resultMap.get('ShortResult') == 'UpgradeTerminatedSuccessfully') 
                        provProduct.provisioned_status__c = 'Deprovisioned';
                    else {
                        provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
                        system.debug('LongResult is '+resultMap.get('LongResult'));
                        provProduct.Status_Message__c = resultMap.get('LongResult');
                    }
                    
                } 
                catch(System.CalloutException e) {
                    throw new CustomException('Failed: ' + e.getMessage());
                }        
            }  
            catch(Exception e) {
                System.debug(e.getMessage());
                provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
                provProduct.Status_Message__c = e.getMessage();                
            }
            
            update provProduct;
        }
        catch(Exception e) {
        
        }
    }
    
   /* private static Map<String, String> parseResponse(System.HttpResponse response) {
        Map<String, String> resultMap = new Map<String, String>(); 
       
        Dom.Document result = response.getBodyDocument();
        system.debug('Result is '+result);
        Dom.XMLNode envelope = result.getRootElement();
          system.debug('envelope is '+envelope);
        Dom.XMLNode body= envelope.getChildElements()[0];
          system.debug('body is '+body);
        for(Dom.XMLNode sendStoreRequestResponse : body.getChildElements()) {
             system.debug('sendStoreRequestResponse is '+sendStoreRequestResponse);
            for(Dom.XMLNode SendStoreRequestResult : sendStoreRequestResponse.getChildElements()) {
                system.debug('SendStoreRequestResult is '+SendStoreRequestResult);
                for(Dom.XMLNode ele : SendStoreRequestResult.getChildElements()) {
                      system.debug('ele is '+ele);
                    resultMap.put(ele.getName(), ele.getText());  
                }
            }
        }
        
        return resultMap;
    }*/
       
    private static Map<String, String> parseResponse(System.HttpResponse response) {
        Map<String, String> resultMap = new Map<String, String>(); 
       
        Dom.Document result = response.getBodyDocument();
        system.debug('Result is '+result);
        Dom.XMLNode envelope = result.getRootElement();
          system.debug('envelope is '+envelope);
        for(Dom.XMLNode body : envelope.getChildElements()){
            resultMap.put(body.getName(), body.getText()); 
        }

        return resultMap;
    }
    
    public Class CustomException extends Exception {}
}