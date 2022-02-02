trigger SMS_ProvisionedProductHistory on SMS_Provisioned_Product__c (before update) {
    
    List<SMS_Provisioned_Product_History__c> provisionedProductHistoryList = new List<SMS_Provisioned_Product_History__c>();
    
    for (SMS_Provisioned_Product__c provisionedProduct : trigger.old) {
        System.debug('1----------->'+provisionedProduct.Provisioned_Status__c);
        System.debug('2----------->'+provisionedProduct.Previous_Provisioned_Status__c);
        //Provisioned Product History record creation
        SMS_Provisioned_Product_History__c provisionedProductHistory = new SMS_Provisioned_Product_History__c();
        provisionedProductHistory.Authentisign_Id__c = provisionedProduct.Authentisign_Id__c;
        provisionedProductHistory.Authentisign_User_Id__c = provisionedProduct.Authentisign_User_Id__c;
        provisionedProductHistory.MRIS_Subscription_Id__c =  provisionedProduct.MRIS_Subscription_Id__c;
        provisionedProductHistory.Order__c = provisionedProduct.Order__c;
        provisionedProductHistory.Product_Status__c = provisionedProduct.Product_Status__c;
        provisionedProductHistory.Product_Sub_Type__c = provisionedProduct.Product_Sub_Type__c;
        provisionedProductHistory.Product_Type__c = provisionedProduct.Product_Type__c;
        provisionedProductHistory.Provisioned_Product_Id__c = provisionedProduct.Id;
        provisionedProductHistory.Provisioned_Status__c = provisionedProduct.Provisioned_Status__c;
        provisionedProductHistory.RealPing_Id__c = provisionedProduct.RealPing_Id__c;
        provisionedProductHistory.XactSite_Salesperson_Name__c = provisionedProduct.XactSite_Salesperson_Name__c;
        provisionedProductHistory.Zuora_Product_Id__c = provisionedProduct.Zuora_Product_Id__c;
        provisionedProductHistory.Zuora_Product_Rate_Plan_Id__c = provisionedProduct.Zuora_Product_Rate_Plan_Id__c;
        provisionedProductHistory.Previous_Provisioned_Status__c = provisionedProduct.Previous_Provisioned_Status__c;
        provisionedProductHistory.Product_Status_Reason__c = provisionedProduct.Product_Status_Reason__c;
        provisionedProductHistory.Status_Message__c = provisionedProduct.Status_Message__c;
        provisionedProductHistory.Subscription__c = provisionedProduct.Subscription__c;
        provisionedProductHistory.XactSite_Office_ID__c = provisionedProduct.XactSite_Office_ID__c;
        provisionedProductHistory.Request_Product_Logging__c = provisionedProduct.Request_Product_Logging__c;
        provisionedProductHistory.Response_Product_Logging__c = provisionedProduct.Response_Product_Logging__c; 
        

        // 2/17/2014, adding the fields of Relay Site ID and Relay Site URL into this trigger
        //provisionedProductHistory.Relay_Site_ID__c = provisionedProduct.Relay_Site_ID__c;
        //provisionedProductHistory.Relay_Site_URL__c = provisionedProduct.Relay_Site_URL__c;        
        
        provisionedProductHistoryList.add(provisionedProductHistory);
        
        if(provisionedProduct.Provisioned_Status__c != trigger.newMap.get(provisionedProduct.id).Provisioned_Status__c)
            trigger.newMap.get(provisionedProduct.id).Previous_Provisioned_Status__c = trigger.oldMap.get(provisionedProduct.id).Provisioned_Status__c;
        
        //added Previuos_ProductSubType__c for triggering email alerts when a product sub type is changed
        if(provisionedProduct.Product_Sub_Type__c != trigger.newMap.get(provisionedProduct.id).Product_Sub_Type__c)
            trigger.newMap.get(provisionedProduct.id).Previuos_ProductSubType__c = trigger.oldMap.get(provisionedProduct.id).Product_Sub_Type__c;
    }
    
    insert provisionedProductHistoryList;
    
}