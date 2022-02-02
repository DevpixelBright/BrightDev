public class PROV_ProvisionProduct {
    private SMS_Provisioned_Product__c provisionProduct;
    private List<Subscriptions__c> subscription;
    private String xactsiteLable = 'XactSite';
    private Set<String> xactsiteAgentSubTypes = new Set<String>{'XactSite Select', 'XactSite Premium', 'XactSite Agent IDX', 'XactSite Total'};
    
    public PROV_ProvisionProduct(SMS_Provisioned_Product__c provisionProduct){
        try {
            this.provisionProduct = new SMS_Provisioned_Product__c();
            this.provisionProduct = provisionProduct;
                        
            if(this.provisionProduct.product_type__c == 'Authentisign')
                PROV_Authentisign.provisionAuthentisign(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c.indexOf(xactsiteLable, 0) >= 0) {
                if(xactsiteAgentSubTypes.contains(this.provisionProduct.Product_Sub_Type__c))
                    PROV_XactsiteAgent.provisionXactsiteAgent(this.provisionProduct.Id); 
            else 
                    PROV_XactsiteOffice.provisionXactsiteOffice(this.provisionProduct.Id); 
                                            
            }
               
            else if(this.provisionProduct.product_type__c == 'realPING')
                PROV_RealPing.provisionRealPing(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c == 'CloudCMA')
                SMS_CloudCMA.provisionCloudCMA(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c == 'Sphere by Bright MLS')
                PROV_Sphere.provisionSphereAgent(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c == 'Sphere by Bright MLS Agent IDX')
                PROV_SphereAgentIDX.provisionSphereAgentIDX(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c == 'Sphere by Bright MLS Office IDX')
                PROV_SphereOfficeIDX.provisionSphereOfficeIDX(this.provisionProduct.Id);
            else if(this.provisionProduct.product_type__c == 'Sphere Office by Bright MLS')
                PROV_SphereOffice.provisionSphereOffice(this.provisionProduct.Id); 
        }
        Catch(Exception e) {
        
        }
    }
 
    public Class CustomException extends Exception {}
}