public without sharing class BuyPremiumProductController {
    private SMS_ZuoraUtil zUtilInstance; 
    private Zuora.zApi.LoginResult zLoginResult;
    public List<Zuora.zObject> zObject;
    
    public String subscriptionId;
    public String productType;
    public String zProductId { get; set; }
    
    public List<SelectOption> zProducts { get; set; }
    public List<SelectOption> zProductRatePlans { get; set; }
    public List<SelectOption> zOnetimeRatePlans { get; set; }
    
    public Subscriptions__c subscription {get; set;}
    private String zProductName;
    private Map<String,String> zRatePlanMap;
    
    public static String zAccId {get;set;}
    public static Boolean showProcess { get; set; }
    public static String processURL { get; set; }
    public static String iframeDomain { get; set; } 
    public static String redirectUrl { get; private set; }
    public static String cancelUrl { get; private set; }
    
    
    public BuyPremiumProductController(){
        subscriptionId = ApexPages.currentpage().getparameters().get('id');
        productType = ApexPages.currentpage().getparameters().get('productType');
        
        if(String.isBlank(subscriptionId))
            throw new CustomException('Subscription Id is null');
        
        if(String.isBlank(productType))
            throw new CustomException('Product Type is null');
        
        zUtilInstance = new SMS_ZuoraUtil();
        zLoginResult = zUtilInstance.zlogin();
        
        
        
        //populateProductRatePlans(zProductId);
        
        //system.debug('zProductRatePlans: ' + zProductRatePlans);
        //system.debug('zOnetimeRatePlans: ' + zOnetimeRatePlans);
        
    }
    
    @AuraEnabled
    public Static List<RatePlanDetail> populateProductRatePlans(String subId, String productType){
        
       
        system.debug('subId---'+subId);
        Subscriptions__c subs = [SELECT Id, Name, Contact__r.Name,
                                 Related_Location_Broker_Office__c,
                                 Contact__c,Status__c,
                                 Subscription_Type__c,
                                 Service_Jurisdiction__c
                                 FROM Subscriptions__c
                                 WHERE Name = :subId];
        
        String contactName = subs.Name;
        
        List<RatePlanDetail> ratePlanFullList = new List<RatePlanDetail>();
        SMS_Premium_Products__c premiumProducts = new SMS_Premium_Products__c();
        premiumProducts = [SELECT Id, Name, Product_ID__c 
                           FROM   SMS_Premium_Products__c 
                           WHERE  Product_ID__c = :productType];
        
        if(String.isBlank(premiumProducts.Name))
            throw new CustomException('Product Type is not valid');
        
        String productId = premiumProducts.Id;
        String zProductName = premiumProducts.Name;
        String zProductId;
        Map<String,String> zRatePlanMap = new Map<String,String>();
        Map<String,Decimal> zRatePlanChargeAmount = new Map<String,Decimal>();
        Map<String,String> chargeId_ratePlanId = new Map<String,String>();
        Map<Decimal,String> tireAmount_chargeId = new Map<Decimal,String>();
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        List<Zuora.zObject> zObject;
        
        String todayDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        String zProductQuery = 'SELECT Id, Name, EffectiveEndDate, EffectiveStartDate FROM Product WHERE EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;
        zObject = zUtilInstance.zquery(zProductQuery); 
        
        System.debug('zProduct-->'+zObject);
        for (Zuora.zObject zProduct : zObject) {
            String zPName = (String)zProduct.getValue('Name');
            if(zProductName == zPName){
                zProductId = (String)zProduct.getValue('Id');
            }
        }
        
        if(String.isBlank(zProductId))
            throw new CustomException('Product Type is not valid');
        
        system.debug('*** Get Rate Plans method is called');
        List<SelectOption> zProductRatePlans = new List<SelectOption>(); 
        List<SelectOption> zOnetimeRatePlans = new List<SelectOption>();        
        
        String zoql;          
        zoql = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE ProductId =\'' + zProductId + '\'';              
        zObject = zUtilInstance.zquery(zoql); 
        
        system.debug('*** zProductId : ' + zProductId );        
        system.debug('*** zRatePlanMap: ' + zRatePlanMap);
        
        Integer i = 0;
        String ratePlanChargeQuery = 'SELECT Id, Name, ChargeType, ProductRatePlanId FROM ProductRatePlanCharge WHERE ';     
        
        String zProductRatePlan;
        String zProductRatePlanId;
        
        for (Zuora.zObject zProduct : zObject) {
            
            zProductRatePlan = (String)zProduct.getValue('Name');
            zProductRatePlanId = (String)zProduct.getValue('Id');
            zRatePlanMap.put(zProductRatePlanId, zProductRatePlan);
            zRatePlanChargeAmount.put(zProductRatePlanId, 0);
            if (i != 0)
                ratePlanChargeQuery += ' OR ';        
            
            ratePlanChargeQuery += 'ProductRatePlanId = \'' + zProductRatePlanId + '\'';
            i++;            
        }
        String chargeId;
        String zRatePlanChargeTierQuery; 
        zRatePlanChargeTierQuery = 'SELECT Id, ProductRatePlanChargeId, Price FROM ProductRatePlanChargeTier WHERE '; 
        
        System.debug('***' + ratePlanChargeQuery );
        system.debug('*** zRatePlanMap: ' + zRatePlanMap);
        
        /* Querying rate plan charges to differentiate onetime rate plans */
        List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(ratePlanChargeQuery);
        i=0;
        for(Zuora.zObject zRatePlanCharge : zRatePlanCharges) {
            chargeId = (String)zRatePlanCharge.getValue('Id');
            chargeId_ratePlanId.put(chargeId,(String)zRatePlanCharge.getValue('ProductRatePlanId'));
            if (i != 0)
                zRatePlanChargeTierQuery += ' OR ';        
            
            zRatePlanChargeTierQuery += 'ProductRatePlanChargeId = \'' + chargeId + '\'';
            i++;    
            if ((String)zRatePlanCharge.getValue('ChargeType') == 'OneTime')
                zOnetimeRatePlans.add(new SelectOption((String)zRatePlanCharge.getValue('ProductRatePlanId'), zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId'))));
            else
                zProductRatePlans.add(new SelectOption((String)zRatePlanCharge.getValue('ProductRatePlanId'), zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId'))));    
            
            //ratePlanFullList.put((String)zRatePlanCharge.getValue('ProductRatePlanId'), zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId')));
        }
        List<Zuora.zObject> zRatePlanChargeTier = zUtilInstance.zquery(zRatePlanChargeTierQuery);
        String ZRatePlanChargeId;
        Decimal zRatePlanPrice;
        for(Zuora.zObject zRatePlanTier : zRatePlanChargeTier){
            ZRatePlanChargeId = (String)zRatePlanTier.getValue('ProductRatePlanChargeId');
            zRatePlanPrice = (Decimal)zRatePlanTier.getValue('Price');
            chargeId_ratePlanId.get(ZRatePlanChargeId);
            zRatePlanChargeAmount.put(chargeId_ratePlanId.get(ZRatePlanChargeId),zRatePlanPrice);
        }
        /* Sorting recurring rate plans */
        Map<String, SelectOption> labelOptions = new Map<String, SelectOption>();
        
        for(SelectOption option : zProductRatePlans)
            labelOptions.put(option.getLabel(), option);
        
        //Sort the keys and items in ascending order
        List<String> keys = new List<String>(labelOptions.keySet());
        keys.sort();
        zProductRatePlans.clear();
        zProductRatePlans.add(new SelectOption('','-- Choose --'));
        for(String k : keys){
            RatePlanDetail ratePlan = new RatePlanDetail();
            ratePlan.rateplanName = k;
            ratePlan.rateplanId = labelOptions.get(k).getValue();
            ratePlan.chargeType = 'Recurring';
            ratePlan.chargeAmount = zRatePlanChargeAmount.get(ratePlan.rateplanId);
            ratePlanFullList.add(ratePlan);
            zProductRatePlans.add(labelOptions.get(k)); 
        }
        
        /* Sorting onetime rate plans */
        labelOptions = new Map<String, SelectOption>();
        
        for(SelectOption option : zOnetimeRatePlans)
            labelOptions.put(option.getLabel(), option);
        
        //Sort the keys and items in ascending order
        keys = new List<String>(labelOptions.keySet());
        keys.sort();
        zOnetimeRatePlans.clear();
        //zOnetimeRatePlans.add(new SelectOption('','-- Choose --'));
        for(String k : keys){
            RatePlanDetail ratePlan = new RatePlanDetail();
            ratePlan.rateplanName = k;
            ratePlan.rateplanId = labelOptions.get(k).getValue();
            ratePlan.chargeType = 'OneTime';
            ratePlan.chargeAmount = zRatePlanChargeAmount.get(ratePlan.rateplanId);
            ratePlanFullList.add(ratePlan);
            zOnetimeRatePlans.add(labelOptions.get(k)); 
        }
        RatePlanDetail subscription = new RatePlanDetail();
        subscription.sub = contactName;
        subscription.productName = zProductName;
        subscription.productId = productId;
        ratePlanFullList.add(subscription);
        
        system.debug('*** zOnetimeRatePlans: ' + zOnetimeRatePlans);
        system.debug('*** zProductRatePlans: ' + zProductRatePlans);
        system.debug('*** ratePlanFullList: ' + ratePlanFullList);
        
        return ratePlanFullList;
    } 
    
    @AuraEnabled
    public Static String getExistingProduct(String productName, String subId){
        String productTypeCloudCMA;
        
        system.debug('subId---'+subId);
        Subscriptions__c subs = [SELECT Id, Name, Contact__r.Name,
                                 Related_Location_Broker_Office__c,
                                 Contact__c,Status__c,
                                 Subscription_Type__c,
                                 Service_Jurisdiction__c
                                 FROM Subscriptions__c
                                 WHERE Name = :subId];
        
        if(productName == 'CloudCMA'){
            
            productTypeCloudCMA = SMS_CloudCMA.findCloudCMAType(subs.Id);                   
            
            /*  if(productTypeCloudCMA == 'Not Found'|| productTypeCloudCMA == 'CloudCMA Lite'){
orderItem.Service_Activation_Date__c = System.Now().addDays(30);
if(billingPeriod == 'Two Years'){
orderItem.Initial_Term__c = 25;
orderItem.Renewal_Term__c = 24;
}
else if(billingPeriod == 'Annual'){
orderItem.Initial_Term__c = 13;
orderItem.Renewal_Term__c = 12;
}
else if(billingPeriod == 'Month'){
orderItem.Initial_Term__c = 2;
orderItem.Renewal_Term__c = 1;                        
}
} 
else if(productTypeCloudCMA == 'CloudCMA Paid MRIS'){
if(billingPeriod == 'Two Years'){
orderItem.Initial_Term__c = 24;
orderItem.Renewal_Term__c = 24;
}
else if(billingPeriod == 'Annual'){
orderItem.Initial_Term__c = 12;
orderItem.Renewal_Term__c = 12;
}
else if(billingPeriod == 'Month'){
orderItem.Initial_Term__c = 1;
orderItem.Renewal_Term__c = 1;                        
}
}
else */
            if(productTypeCloudCMA == 'CloudCMA Paid MRIS'){
                //Verify SMS Provisioned Product object
                List<SMS_Provisioned_Product__c> provisionProducts = new List<SMS_Provisioned_Product__c>();
                provisionProducts = [SELECT Id,Name, Product_Status__c 
                                     FROM   SMS_Provisioned_Product__c 
                                     WHERE  Product_Type__c = 'CloudCMA'
                                     AND    MRIS_Subscription_Id__c = :subs.Name];
                
                for(SMS_Provisioned_Product__c pProduct : provisionProducts){
                    if(pProduct.Product_Status__c == 'Terminate'){
                        productTypeCloudCMA = 'Cloud CMA Terminated';
                    }
                }   
            }
        }
        return productTypeCloudCMA;
    }
    
    @AuraEnabled
    public Static String orderConfirm(String productName, String ratePlanName, String subId, String onetimeRatePlanName) {
        //  try {
        String iframeUrl;
        String ProductsId;
        String recurringRatePlanId;
        String oneTimeRatePlanIds;
        system.debug('productId'+productName);
        system.debug('ratePlanId'+ratePlanName);
        system.debug('subId'+subId);
        //Inserts the products as Order Items into SMS_OrderItems object
        //iframeDomain = ApexPages.currentpage().getparameters().get('iframeDomain');
        Boolean createOrder = true;
        DateTime effectiveDate = System.Now();
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        
        String zProductQuery = 'SELECT Id, Name, EffectiveEndDate, EffectiveStartDate FROM Product WHERE';
        zProductQuery += ' Name = \'' +productName + '\'';
        
        List<Zuora.zObject> zProducts = zUtilInstance.zquery(zProductQuery); 
        for (Zuora.zObject zProduct : zProducts) {
            ProductsId = (String)zProduct.getValue('Id');
            
        }
        
        String zoql = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE';
        zoql += ' Name = \'' +ratePlanName + '\'';
        List<Zuora.zObject> zObject = zUtilInstance.zquery(zoql); 
        
        for (Zuora.zObject zProduct : zObject) {
            recurringRatePlanId = (String)zProduct.getValue('Id');
        }
        
        String zoql2 = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE';
        zoql2 += ' Name = \'' +onetimeRatePlanName + '\'';
        List<Zuora.zObject> zObject2 = zUtilInstance.zquery(zoql2); 
        
        for (Zuora.zObject zProduct : zObject2) {
            oneTimeRatePlanIds = (String)zProduct.getValue('Id');
        }
        
        SMS_OrderItem__c orderItem = new SMS_OrderItem__c();
        
        //orderItem.Order_Id__c = order.Id;                                             
        orderItem.Zuora_Product_Id__c = ProductsId ;
        orderItem.Zuora_Product_Name__c = ProductName;            
        orderItem.RecurringProductRatePlanId__c = recurringRatePlanId;
        orderItem.RecurringProductRatePlanName__c = ratePlanName;  
        //  orderItem.DiscountProductRatePlanId__c = item.DiscountProductRatePlanId;
        //  orderItem.DiscountProductRatePlanName__c = item.DiscountProductRatePlanName;
        orderItem.OneTimeProductRatePlanId__c =  oneTimeRatePlanIds;
        orderItem.OneTimeProductRatePlanName__c = onetimeRatePlanName;        
        orderItem.Initial_Term__c = 12;
        orderItem.Renewal_Term__c = 12;
        orderItem.Contract_Effective_Date__c = effectiveDate;
        orderItem.Service_Activation_Date__c = effectiveDate;                              
        orderItem.IsCore__c = false;
        orderItem.IsDiscountOnly__c = false; 
        // String zRecurringProductRatePlanId = item.RecurringProductRatePlanId;
        
        
        
        String accountQuery = 'SELECT Id,Name FROM Account WHERE ';
        accountQuery += ' AccountNumber = \'' +subId + '\'';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        //String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + zRecurringProductRatePlanId + '\'';
        //List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
        
        String billingPeriod = '12';//(String)ratePlanCharges[0].getValue('BillingPeriod'); 
        Subscriptions__c subscriptions = [SELECT Id, Name   
                                          FROM   Subscriptions__c
                                          WHERE  Name = :subId];
        
        
        if(createOrder){ 
            SMS_Order__c order = new SMS_Order__c();                
            order.Name = 'Order Id';
            order.Token__c = '';
            order.Zuora_Account_Id__c = zAccId;
            order.MRIS_Subscription_Id__c = subscriptions.Id;
            order.Status__c = 'Active';
            order.Bypass_Payment__c = false;
            
            insert order;
            
            system.debug('**** Insert order  : ' + order );       
            
            String salt = String.valueOf(order.id);
            String secretKey = 'secret_key';
            String algorithmName = 'HmacSHA256';
            
            Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
            string token = EncodingUtil.base64Encode(hmacData);
            
            order.Token__c = token;
            order.Name = order.id;
            update order;
            system.debug('order' +order);
            system.debug('**** Update order  : ' + order );
            
            // for(SMS_OrderItem__c orderItem : orderItems){
            orderItem.Order_Id__c = order.Id;
            // }*/
            system.debug('orderItem'+orderItem);
            insert orderItem; 
            
            //Schedule batch apex  will execute after ten minutes  after insert 
            
            String query = 'SELECT Id,Status__c FROM SMS_Order__c WHERE Token__c =  \'' + token + '\'';              
            String jobName = 'SMS Order Update -' + String.ValueOf(Math.random());
            
            SMS_OrderBatch updateOrder = new SMS_OrderBatch(query);
            String cronID = System.scheduleBatch(updateOrder, jobName, 10);
            //showProcess = true;
            
            // String encodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
            
            //iframeDomain = 'https://dev-mrisonboarding.cs9.force.com';
            
            /*String path = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Communities_BuyPremiumProduct?id=' + subId + '&iframeDomain=' + iframeDomain;
redirectUrl = path;
cancelUrl = path;
path = EncodingUtil.urlEncode(path, 'UTF-8');
processURL = iframeDomain + '/SMS/SMS_GenericPaymentWrapper?token=' + encodedToken + '#' + path; 
String encodedToken = EncodingUtil.urlEncode(order.Token__c, 'UTF-8');
iframeDomain = URL.getSalesforceBaseUrl().toExternalForm();

String path = Label.Generic_Payment_Wrapper + '/apex/Communities_BuyPremiumProduct?Id=' + subId;
redirectUrl = path;
cancelUrl = path;

wrapperUrl = Label.Generic_Payment_Wrapper + '/SMS/SMS_GenericPaymentWrapper?token=' + encodedToken  + '#' + path;
String orderId = order.Id;*/
            String iframeDomain = Label.MRIS_SMS_URL.replace('/SMS/', '');
            String encodedToken = EncodingUtil.urlEncode(order.Token__c, 'UTF-8');
            // String iframeDomain = URL.getSalesforceBaseUrl().toExternalForm();
            String path = Label.MRIS_Communities_URL + 'apex/Communities_BuyPremiumProduct?Id=' + subId;
            system.debug('path'+path);
            iframeUrl = Label.Generic_Payment_Wrapper + '/SMS/SMS_GenericPaymentWrapper?id=' +subId +'&token=' + encodedToken  + '#' + path;
            system.debug('iframeUrl'+iframeUrl);
            
            //  SMS_ZuoraHistory.createSuccess('SMS_StaffOrder_Controller',subscriptionId);
            // }
            //  } 
            // catch(Exception e){
            //   SMS_ZuoraHistory.createError(e,'SMS_StaffOrder_Controller', subscriptionId);
            // } 
        }
        return iframeUrl;
    }
  /*  @AuraEnabled
    public static void provProd(String orderId){
        System.debug('Order Id'+orderId);
        SMS_Provisioned_Product__c spp = [SELECT Id, Order__c, 
                                             Product_Type__c,
                                             Product_Sub_Type__c,
                                             Product_Status__c,
                                             Provisioned_Status__c from SMS_Provisioned_Product__c where Order__c = :orderId];
            if(spp.Product_Type__c == 'CloudCMA' && spp.Provisioned_Status__c == 'Error Provisioned'){
                Case createCase = new Case();
                createCase.Subject = 'Error on Cloud CMA provisioning';
                createCase.Status = 'Not Started';
                createCase.Description = spp.Id;
                createCase.Case_Reason__c = 'Defect';
                createCase.Product__c = 'Cloud CMA';
                createCase.Category__c = 'Error on provisioning';
                createCase.Origin = '';
                insert createCase; 
            }
    }*/
    /* @AuraEnabled
    public Static SMS_Provisioned_Product__c errorProduct(String provProduct, String subId) {
        SMS_Provisioned_Product__c pProduct = [SELECT Id, Name, Subscription__c, Subscription__r.Name   
                                          FROM   SMS_Provisioned_Product__c
                                          WHERE  Name = :provProduct];
        if(pProduct.Product_Type__c == 'CloudCMA' && pProduct.Provisioned_Status__c == 'Error Provisioned'){
            string errorMessage = 'Your Error Message';
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }
        return pProduct;
    }*/
    @AuraEnabled
    public static SMS_Provisioned_Product__c provProdError(String subId){
       
    SMS_Provisioned_Product__c sppTC = [SELECT  Id, Order__c, 
                                                  Product_Type__c,
                                                  Product_Sub_Type__c,
                                                  Product_Status__c,
                                                  Provisioned_Status__c, 
                                                  Subscription__r.Contact__r.Name,
                                                  Subscription__c
                                          FROM    SMS_Provisioned_Product__c
                                          WHERE   Subscription__r.Name =: subId];
        return sppTC;
    }
    @AuraEnabled
    public Static Custom_Content__c termsConditionsCloudCMA(){
        Custom_Content__c cc = new Custom_Content__c();
        cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Cloud CMA' AND Status__c = 'Published'];
        
         return cc;
    }
    @AuraEnabled
    public Static Custom_Content__c termsConditionsSocialPro(){
        
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2 = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
               where Type__c = 'Buy Now Terms and Conditions - Socialpro' AND Status__c = 'Published'];
        
         return cc2;
    }
    @AuraEnabled
    public Static Custom_Content__c termsConditionsAuthentisign(){
        
        Custom_Content__c cc3 = new Custom_Content__c();
        cc3 = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
               where Type__c = 'Buy Now Terms and Conditions - Authentisign' AND Status__c = 'Published'];
        
         return cc3;
    }
    @AuraEnabled
    public Static Custom_Content__c termsConditionsDefault(){
        
        Custom_Content__c cc4 = new Custom_Content__c();
        cc4 = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
               where Type__c = 'Buy Now Terms and Conditions - Default' AND Status__c = 'Published'];
        
         return cc4;
    }
   /* @AuraEnabled
    public Static SMS_Onetime_Product_Mapping__c newSetupFeeMapping(String subId, String productType, String selectPlan){
        SMS_Onetime_Product_Mapping__c oneTimeProductMapping = [Select Id, Name, Current_Product_Sub_Type__c,
                                                               Current_Rate_Plan_ID__c, New_Product_Sub_Type__c,
                                                               New_Rate_Plan_ID__c, Product_ID__c, Product_Type__c,
                                                               Zuora_OnetimeProductRatePlan_Id__c 
                                                               FROM SMS_Onetime_Product_Mapping__c
                                                               Where Product_ID__c = 'Sphere by Bright MLS Office IDX'
                                                               LIMIT 1];
        return oneTimeProductMapping;
    }*/
    public class RatePlanDetail{
        @AuraEnabled public String chargeType;
        @AuraEnabled public String rateplanName;
        @AuraEnabled public String rateplanId;
        @AuraEnabled public String sub; 
        @AuraEnabled public String productName;
        @AuraEnabled public String productId;
        @AuraEnabled public Decimal chargeAmount;
        
    }
    public class ExistProduct{
        @AuraEnabled public String produtName;
        @AuraEnabled public String SubId;
        @AuraEnabled public String product;        
    }
    
    public class CustomException extends Exception{}
    
}