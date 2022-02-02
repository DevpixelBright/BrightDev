public class PROV_GetProvisionProductDetails {
    
    public Static List<SMS_Provisioned_Product__c> getProvisionProduct(String provProductId) {
            /* Get provision product information */
            List<SMS_Provisioned_Product__c> provisionProduct = new List<SMS_Provisioned_Product__c>();
            provisionProduct = [SELECT  Id,
                                        Name,
                                        LastModifiedDate,
                                        MRIS_Subscription_Id__c,
                                        Order_Id__c,
                                        Product_Status__c,
                                        Product_sub_type__c,
                                        product_type__c,
                                        provisioned_product_Id__c,
                                        provisioned_status__c,
                                        xactsite_office_id__c,
                                        zuora_product_id__c,
                                        zuora_product_rate_plan_id__c,
                                        Authentisign_Id__c,
                                        Authentisign_User_Id__c,
                                        Previous_Provisioned_Status__c,
                                        RealPing_Id__c,
                                        Status_Message__c
                               FROM SMS_Provisioned_Product__c
                               WHERE Id = :provProductId];
            return provisionProduct;                                
    }
    
    public Static List<Subscriptions__c> getSubscriptionDetails(String mrisSubId) {
            /* Get required data for webservices */
            List<Subscriptions__c> subscription = new List<Subscriptions__c>();
            subscription = [SELECT Name, 
                                agentkey__c, 
                                NRDS_ID__c, 
                                Private_Email__c, 
                                Primary_Phone__c, 
                                Mobile_Phone__c, 
                                Home_Fax__c, 
                                Voicemail__c,  
                                Subscriptions__c.Contact__r.FirstName, 
                                Subscriptions__c.Contact__r.LastName, 
                                Subscriptions__c.Contact__r.Middle_Name__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.Name,
                                Subscriptions__c.Related_Location_Broker_Office__r.Account_Name__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.NRDS_ID__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.Full_Street_Address__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.City__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.State__c,
                                Subscriptions__c.Related_Location_Broker_Office__r.Zip__c,
                            	Subscriptions__c.Related_Location_Broker_Office__r.BRIGHT_Office_Key__c,
                                Service_Jurisdiction__c,
                                BRIGHT_Agent_Key__c                                    
                            FROM Subscriptions__c 
                            WHERE Name = :mrisSubId];
            return subscription;    
    }
    
    public Static Map<String, String> getProvisionSettings() {
        List<PROV_Provision_Settings__c> provSettings = [SELECT Id, Name, Value__c FROM PROV_Provision_Settings__c];
        Map<String, String> provSettingsMap = new Map<String, String>();
        for(PROV_Provision_Settings__c provSetting : provSettings) {
            provSettingsMap.put(provSetting.Name, provSetting.Value__c);    
        }
        return provSettingsMap;       
    }
    
}