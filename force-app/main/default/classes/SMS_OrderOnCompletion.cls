public class SMS_OrderOnCompletion {
    
    String orderId;
    SMS_Order__c order;
    List<SMS_OrderItem__c> orderItems;
    Boolean isXactSite;
    Boolean isAuthentisign;
    Boolean isCloudCMA;
    Boolean isSocialPro;
    Boolean isSphere;
    
    List<SMS_Product_Mapping__c> productMapping ;    
    public SMS_OrderOnCompletion(String orderId) {
        this.orderId = orderId;
        isXactSite = false;
        isAuthentisign = false;
        isCloudCMA = false;
        isSocialPro = false;
        isSphere = false;
        
        getOrderDetails(orderId);
        if(order.Service_Jurisdiction__c == null || order.Service_Jurisdiction__c == 'MRIS')
            provisionProduct();
        else if(order.Service_Jurisdiction__c == 'TREND'){
            if(isXactSite || isCloudCMA || isAuthentisign || isSocialPro || isSphere)
                provisionProduct();
            else
                premiumTRENDProduct();
        }
        else if(order.Service_Jurisdiction__c == 'BRIGHT'){
            if(isXactSite || isCloudCMA || isAuthentisign || isSocialPro || isSphere)
                provisionProduct();
        }
    }
    
    private void premiumTRENDProduct(){
        List<TREND_IDX_Premium_Product__c> products = new List<TREND_IDX_Premium_Product__c>();
        for(SMS_OrderItem__c orderItem : orderItems ) { 
            TREND_IDX_Premium_Product__c product = new TREND_IDX_Premium_Product__c();
            product.MRIS_Subscription_ID__c = order.MRIS_Subscription_Id__c;
            product.Member__c = order.MRIS_Subscription_Id__r.Contact__c;
            product.Product_Status__c = 'Active';
            product.Product_Sub_Type__c = orderItem.RecurringProductRatePlanName__c;
            product.Product_Type__c = orderItem.Zuora_Product_Name__c;
            product.Office_ID__c = order.MRIS_Subscription_Id__r.Related_Location_Broker_Office__c;
            products.add(product);
        }
        insert products;
    }
    
    public void provisionProduct() {
        //getOrderDetails(orderId);
        List<SMS_Provisioned_Product__c> upsertProductProvisioning = new List<SMS_Provisioned_Product__c>();
                 
        for(SMS_OrderItem__c orderItem : orderItems ) {            
            
            getProductMapping(orderItem.RecurringProductRatePlanId__c);                             
            
            if(productMapping.size() > 1) 
                throw new CustomException('More than one record found for the product rate plan id: ' + orderItem.RecurringProductRatePlanId__c);
            
            if(productMapping.size() == 1) {
                List<SMS_Provisioned_Product__c> provisionedProducts = new List<SMS_Provisioned_Product__c>();
                provisionedProducts = [SELECT id,Name,
                                             MRIS_Subscription_Id__c,
                                             Order__c,
                                             Product_Type__c,
                                             Product_Sub_Type__c,
                                             Product_Status__c,
                                             Provisioned_Status__c,
                                             Zuora_Product_Rate_Plan_ID__c,
                                             Zuora_Product_Id__c,
                                             XactSite_Office_ID__c
                                      FROM   SMS_Provisioned_Product__c
                                      WHERE  Product_Type__c = :productMapping[0].Product_Type__c
                                      AND    MRIS_Subscription_Id__c = :order.MRIS_Subscription_Id__r.Name
                                     ];
                         
                if(provisionedProducts.size() > 1) 
                    throw new CustomException('More than one record found for the product: ' + productMapping[0].Product_Type__c + ' in provisioning table for the subscription ' + order.MRIS_Subscription_Id__r.Name);
                                     
                if(provisionedProducts.size() == 0) {
                    system.debug('*** Provisioned Product does not exist');
                    //Provisioned Product does not exist
                    SMS_Provisioned_Product__c provisionedProduct = new SMS_Provisioned_Product__c();
                    provisionedProduct.MRIS_Subscription_ID__c = order.MRIS_Subscription_Id__r.Name;
                    provisionedProduct.Order__c = order.Id;
                    provisionedProduct.Product_Type__c = productMapping[0].Product_Type__c;
                    provisionedProduct.Product_Sub_Type__c = productMapping[0].Product_Sub_Type__c;
                    provisionedProduct.Product_Status__c = 'New';
                    provisionedProduct.Provisioned_Status__c = 'Pending Provisioned';
                    provisionedProduct.Zuora_Product_Rate_Plan_ID__c = orderItem.RecurringProductRatePlanId__c;
                    provisionedProduct.Zuora_Product_ID__c = orderItem.Zuora_Product_Id__c;
                    provisionedProduct.Product_Status_Reason__c = 'Ordered';
                    provisionedProduct.Service_Jurisdiction__c = order.Service_Jurisdiction__c;
                    
                    if(!order.Bypass_Payment__c){
                      provisionedProduct = updateTermsConditions(provisionedProduct);  
                    }
                    
                    if(order.Bypass_Payment__c && (orderItem.Zuora_Product_Name__c == 'XactSite Office' || orderItem.Zuora_Product_Name__c == 'MRIS XactSite Office' ))                    
                        provisionedProduct.XactSite_Office_ID__c = order.MRIS_Subscription_Id__r.Related_Location_Broker_Office__r.Name;
                    
                    upsertProductProvisioning.add(provisionedProduct);
                }
                else {
                    system.debug('*** Original provisionedProduct ' + provisionedProducts[0]);
                    system.debug('*** Provisioned Product exists');
                    
                    SMS_Provisioned_Product__c provisionedProduct = new SMS_Provisioned_Product__c();
                    provisionedProduct = provisionedProducts[0];
                    
                    if(order.Bypass_Payment__c && (orderItem.Zuora_Product_Name__c == 'XactSite Office' || orderItem.Zuora_Product_Name__c == 'MRIS XactSite Office' ))                    
                        provisionedProduct.XactSite_Office_ID__c = order.MRIS_Subscription_Id__r.Related_Location_Broker_Office__r.Name;
                    
                    if(!order.Bypass_Payment__c){
                      provisionedProduct = updateTermsConditions(provisionedProduct);  
                    }
                    //Provisioned Product exists
                    if(productMapping[0].Product_Sub_Type__c == provisionedProduct.Product_Sub_Type__c) {
                        system.debug('*** Same Product Sub Type');
                        //Same Product Sub Type
                        if(provisionedProduct.Product_Status__c == 'Terminate'){
                            system.debug('*** Provisioned product is terminated');
                            //Provisioned product is terminated
                            upsertProductProvisioning.add(updateProvisionedProduct(provisionedProduct, null, orderItem.RecurringProductRatePlanId__c, 'Reinstate', 'Pending Provisioned'));
                        }
                        else {
                            system.debug('*** Provisioned product is not terminated');
                            //Provisioned Product is not terminated
                            upsertProductProvisioning.add(updateProvisionedProduct(provisionedProduct, null, orderItem.RecurringProductRatePlanId__c, null, null));
                        }
                    }
                    else {
                        system.debug('*** Different Product Sub Type');
                        //Different Product Sub Type
                        if(provisionedProduct.Product_Status__c == 'Terminate'){
                            system.debug('*** Provisioned product is terminated');
                            //Provisioned product is terminated
                            upsertProductProvisioning.add(updateProvisionedProduct(provisionedProduct, productMapping[0].Product_Sub_Type__c, orderItem.RecurringProductRatePlanId__c, 'Update', 'Pending Provisioned'));
                        }
                        else {
                            system.debug('*** Provisioned product is not terminated');
                            //Provisioned Product is not terminated
                            upsertProductProvisioning.add(updateProvisionedProduct(provisionedProduct, productMapping[0].Product_Sub_Type__c, orderItem.RecurringProductRatePlanId__c, 'Update', 'Pending Provisioned'));
                        }                    
                    }                        
                }
            }
        }
        
        upsert upsertProductProvisioning; 
    }
    
    public void getOrderDetails(String orderId) {
        order = new SMS_Order__c();
        order = [SELECT id,Name,MRIS_Subscription_Id__c,
                        Service_Jurisdiction__c,
                        MRIS_Subscription_Id__r.Name,
                        MRIS_Subscription_Id__r.Related_Location_Broker_Office__r.Name,
                        MRIS_Subscription_Id__r.Related_Location_Broker_Office__c,
                        MRIS_Subscription_Id__r.Contact__c,
                        MRIS_Subscription_Id__r.Contact__r.Name,
                        Zuora_Account_Id__c,
                        Bypass_Payment__c
                 FROM   SMS_Order__c
                 WHERE  id = :orderId
                ];
                
        orderItems = new List<SMS_OrderItem__c>();
        orderItems = [SELECT id,Name,
                             RecurringProductRatePlanId__c,
                             Zuora_Product_Id__c,
                             Zuora_Product_Name__c,
                             RecurringProductRatePlanName__c
                      FROM   SMS_OrderItem__c
                      WHERE  Order_Id__c = :orderId
                      AND    IsCore__c = false
                    ]; 
                    
       for(SMS_OrderItem__c orderItem : orderItems){
           if(orderItem.Zuora_Product_Name__c.contains('XactSite'))
               isXactSite = true; 
           else if(orderItem.Zuora_Product_Name__c.contains('Authentisign'))
               isAuthentisign = true;
           else if(orderItem.Zuora_Product_Name__c.contains('CloudCMA'))
               isCloudCMA = true;
           else if(orderItem.Zuora_Product_Name__c.contains('Social Pro')) 
               isSocialPro = true;
           else if(orderItem.Zuora_Product_Name__c.contains('Sphere'))    
               isSphere = true;
       }
       system.debug('*** isXactSite  ' + isXactSite ); 
       system.debug('*** isAuthentisign  ' + isAuthentisign ); 
       system.debug('*** isCloudCMA  ' + isCloudCMA );              
       system.debug('*** Order details ' + order ); 
       system.debug('*** Order Item details ' + orderItems );   
    }
    
    public void getProductMapping(String recurringProductRatePlanId) {
        productMapping = new List<SMS_Product_Mapping__c>();
        productMapping = [SELECT id,Name,
                                 Product_Sub_Type__c,
                                 Product_Type__c
                          FROM   SMS_Product_Mapping__c 
                          WHERE  Zuora_ProductRatePlan_Id__c = :recurringProductRatePlanId                             
                         ];
                         
        system.debug('*** product mapping : ' + productMapping );
    }
    
    public SMS_Provisioned_Product__c updateProvisionedProduct(SMS_Provisioned_Product__c provisionedProduct, String productSubType, String zProductRatePlanId, String productStatus, String provisionedStatus) {
        if(String.isNotBlank(productSubType))
            provisionedProduct.Product_Sub_Type__c = productSubType;
            
        if(String.isNotBlank(zProductRatePlanId))
            provisionedProduct.Zuora_Product_Rate_Plan_ID__c = zProductRatePlanId;
            
        if(String.isNotBlank(productStatus))
             provisionedProduct.Product_Status__c = productStatus;
             
        if(String.isNotBlank(provisionedStatus))  
            provisionedProduct.Provisioned_Status__c = provisionedStatus; 
            
        //if(order.Bypass_Payment__c)
            provisionedProduct.Product_Status_Reason__c = 'Ordered';            
        
        system.debug('*** updated provisionedProduct : ' + provisionedProduct);
        return provisionedProduct;
    }
    
    public SMS_Provisioned_Product__c updateTermsConditions(SMS_Provisioned_Product__c provisionedProduct){
    Custom_Content__c cc = new Custom_Content__c();    
        
        if(provisionedProduct.Product_Type__c == 'CloudCMA'){
            cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c 
                  FROM   Custom_Content__c 
                  WHERE  Type__c = 'Buy Now Terms and Conditions - Cloud CMA' 
                  AND    Status__c = 'Published'];    
            
            if(cc.Status__c == 'Published')  {
                provisionedProduct.T_C_accepted_by__c = order.MRIS_Subscription_Id__r.Contact__r.Name;
                provisionedProduct.T_C_acceptance_date__c = System.today();
                provisionedProduct.T_C_version__c = cc.Version_Number__c; 
            }
        }
        
       /* if(provisionedProduct.Product_Type__c == 'Social Pro'){
            cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c 
                  FROM   Custom_Content__c 
                  WHERE  Type__c = 'Buy Now Terms and Conditions - Socialpro' 
                  AND    Status__c = 'Published'];
            
            if(cc.Status__c == 'Published')  {
                provisionedProduct.T_C_accepted_by__c = order.MRIS_Subscription_Id__r.Contact__r.Name;
                provisionedProduct.T_C_acceptance_date__c = System.today();
                provisionedProduct.T_C_version__c = cc.Version_Number__c; 
            }
        }
        if(provisionedProduct.Product_Type__c == 'Authentisign'){
            cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c 
                  FROM   Custom_Content__c 
                  WHERE  Type__c = 'Buy Now Terms and Conditions - Authentisign' 
                  AND    Status__c = 'Published'];  
            
            if(cc.Status__c == 'Published')  {
                provisionedProduct.T_C_accepted_by__c = order.MRIS_Subscription_Id__r.Contact__r.Name;
                provisionedProduct.T_C_acceptance_date__c = System.today();
                provisionedProduct.T_C_version__c = cc.Version_Number__c; 
            }
        }*/
        
        return provisionedProduct;
        
    }
    
    public class CustomException extends Exception{}
}