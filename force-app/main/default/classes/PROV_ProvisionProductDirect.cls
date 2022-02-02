public class PROV_ProvisionProductDirect {
    private static String xactsiteLable = 'XactSite';
    private static Set<String> xactsiteAgentSubTypes = new Set<String>{'XactSite Select', 'XactSite Premium', 'XactSite Agent IDX', 'XactSite Total'};
    
    public static void PROV_ProvisionProduct(List<SMS_Provisioned_Product__c> provisionProducts){

        List<Map<String, String>> newProvisionProducts = new List<Map<String, String>>();
        
        for(SMS_Provisioned_Product__c provisionProduct : provisionProducts) {
            try {                           
                if(provisionProduct.product_type__c == 'Authentisign') {
                    Map<String, String> provMap = PROV_AuthentisignDirect.provisionAuthentisign(provisionProduct);
                    newProvisionProducts.add(provMap);
                }
                else if(provisionProduct.product_type__c.indexOf(xactsiteLable, 0) >= 0) {
                    if(xactsiteAgentSubTypes.contains(provisionProduct.Product_Sub_Type__c)) {
                        Map<String, String> provMap = PROV_XactsiteAgentDirect.provisionXactsiteAgent(provisionProduct);
                        newProvisionProducts.add(provMap); 
                    }
                    else {
                        Map<String, String> provMap = PROV_XactsiteOfficeDirect.provisionXactsiteOffice(provisionProduct);
                        newProvisionProducts.add(provMap);
                    }                                   
                }
                else if(provisionProduct.product_type__c == 'realPING') {
                    Map<String, String> provMap = PROV_RealPingDirect.provisionRealPing(provisionProduct);
                    newProvisionProducts.add(provMap);
                } 
                else if(provisionProduct.product_type__c == 'CloudCMA') {
                    Map<String, String> provMap = SMS_CloudCMA.provisionCloudCMADirect(provisionProduct);
                    newProvisionProducts.add(provMap);
                }
                else if(provisionProduct.product_type__c == 'Sphere by Bright MLS') {
                    Map<String, String> provMap = PROV_SphereDirect.provisionSphereAgent(provisionProduct); 
                    newProvisionProducts.add(provMap);
                } 
                else if(provisionProduct.product_type__c == 'Sphere by Bright MLS Agent IDX') {
                    Map<String, String> provMap = PROV_SphereAgentIDXDirect.provisionSphereAgentIDX(provisionProduct); 
                    newProvisionProducts.add(provMap);
                }
                else if(provisionProduct.product_type__c == 'Sphere by Bright MLS Office IDX') {
                    Map<String, String> provMap = PROV_SphereOfficeIDXDirect.provisionSphereOfficeIDX(provisionProduct); 
                    newProvisionProducts.add(provMap);                                      
                   }
                   else if(provisionProduct.product_type__c == 'Sphere Office by Bright MLS'){
                    Map<String, String> provMap  = PROV_SphereOfficeDirect.provisionSphereOffice(provisionProduct);
                    newProvisionProducts.add(provMap);                                      
                   }
               }
            catch(Exception e) {
                System.debug('### Error' + e.getMessage());
            }
        }
       
        update provisionProducts;
        
        List<SMS_Provisioned_Product__c> updateProvRecords = new List<SMS_Provisioned_Product__c>();
        for(Map<String, String> provRecord : newProvisionProducts) {
            SMS_Provisioned_Product__c provProduct = new SMS_Provisioned_Product__c();
            provProduct.Id = provRecord.get('Id');
            provProduct.provisioned_status__c = provRecord.get('provisioned_status__c');
            provProduct.Authentisign_Id__c = provRecord.get('Authentisign_Id__c');
            provProduct.Authentisign_User_Id__c = provRecord.get('Authentisign_User_Id__c');
            provProduct.Status_Message__c = provRecord.get('Status_Message__c');
            provProduct.Request_Product_Logging__c = provRecord.get('Request_Product_Logging__c');
            provProduct.Response_Product_Logging__c = provRecord.get('Response_Product_Logging__c');
            updateProvRecords.add(provProduct);
        }
        update updateProvRecords;
    }
    
    public Class CustomException extends Exception {}
}