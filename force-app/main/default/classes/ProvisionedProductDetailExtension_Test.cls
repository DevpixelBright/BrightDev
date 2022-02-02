@istest
public class ProvisionedProductDetailExtension_Test {

    public static testMethod void doTestOne() {
        
        SMS_Provisioned_Product__c provisionedProduct = new SMS_Provisioned_Product__c();  
        ApexPages.StandardController sc = new ApexPages.StandardController(provisionedProduct);
        
        ProvisionedProductDetailExtension controller = new ProvisionedProductDetailExtension(sc);
        Boolean a = controller.UserCanEdit;
        Boolean b = controller.UserCanSendOutboundMessages;
        
    }

}