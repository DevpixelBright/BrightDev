public class ProvisionedProductDetailExtension {
    private SMS_Provisioned_Product__c p;
    
    public ProvisionedProductDetailExtension(ApexPages.StandardController controller) {
        p = (SMS_Provisioned_Product__c)controller.getRecord();
    }
    
    public Boolean UserCanEdit {
        get {
            List<ObjectPermissions> p = [select id from ObjectPermissions where permissionsedit = true and sobjecttype = 'sms_provisioned_product__c' and parent.profileid = :UserInfo.getProfileId()];
            if(p != null && p.size() > 0) return true;
            return false;
        }
    }
    
    public Boolean UserCanSendOutboundMessages {
        get {
            List<PermissionSet> p = [select permissionsenablenotifications from PermissionSet where profileid = :UserInfo.getProfileId()];
            if(p == null || p.size() == 0) return false;
            return p.get(0).permissionsenablenotifications;
        }
    }

}