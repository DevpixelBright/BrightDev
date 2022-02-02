Public Class SMS_CloudCMA {
    
    private static Map<String, String> cloudCMASettings;    
    public Static String findCloudCMAType(String subscriptionId){    
        /*
Assumption: Private Email id of subscription  is unique for CloudCMA product.

For the product CloudCMA 
1. Check SMS CloudCMA Users object if the subscription exists
2. If found return "CloudCMA Paid"
3. Check whether the product exists in SMS Provisioning Table
4. If found return "CloudCMA Paid MRIS"
5. Check whether the product exists in CloudCMA database
6. If not found return "Not Found"
7. If found and the type is CloudCMA LITE return "CloudCMA LITE"

Not Found == New User of CloudCMA and from MRIS. One month free
CloudCMA Lite == Old User of CloudCMA and New user from MRIS. One month free
CloudCMA Paid == Old User of CloudCMA and MRIS before SMS Billing. Cannot modify from MRIS.Display an error message.
CloudCMA Paid MRIS == Old User of CloudCMA from MRIS after SMS Billing. No one month free    
*/
        try {
            
            Subscriptions__c subscription = new Subscriptions__c();            
            subscription = [SELECT Id, Name, Private_Email__c, Service_Jurisdiction__c
                            FROM   Subscriptions__c 
                            WHERE  Id = :subscriptionId 
                            AND    Status__c = 'Active'];     
            
            String productTypeCloudCMA = 'Not Found';
            List<SMS_CloudCMA_Users__c> cloudCMAUsers = new List<SMS_CloudCMA_Users__c>();
            cloudCMAUsers = [SELECT Id, Email_Address__c, Mls_Id__c
                             FROM   SMS_CloudCMA_Users__c
                             WHERE  Email_Address__c = :subscription.Private_Email__c];
            
            if(cloudCMAUsers.size() > 0)
                productTypeCloudCMA = 'CloudCMA Paid';
            else {
                
                //Verify SMS Provisioned Product object
                List<SMS_Provisioned_Product__c> provisionProducts = new List<SMS_Provisioned_Product__c>();
                provisionProducts = [SELECT Id,Name 
                                     FROM   SMS_Provisioned_Product__c 
                                     WHERE  Product_Type__c = 'CloudCMA'
                                     AND    MRIS_Subscription_Id__c = :subscription.Name];
                
                if(provisionProducts.size() > 0)
                    productTypeCloudCMA = 'CloudCMA Paid MRIS';
                else 
                    productTypeCloudCMA = checkProduct(subscription.Private_Email__c, subscription.Service_Jurisdiction__c); //api call to cloudCMA database to verify product existence
            }
            
            return productTypeCloudCMA;
        }
        catch(Exception e) {
            return e.getMessage();
        }        
    }
    
    public static String checkProduct(String emailAddress, string serviceJurisdiction) { 
        
        cloudCMASettings = getCloudCMASettings(serviceJurisdiction);
        
        System.HttpRequest request = new System.HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(cloudCMASettings.get('SERVICE_URL') + '/status?UserEmail=' + emailAddress + '&AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN') + '&ApiKey=' + cloudCMASettings.get('API_KEY'));
        
        System.HttpResponse response = new System.HttpResponse();
        if (Test.isRunningTest()) 
            response = SMS_CloudCMA_MockDataGenerator.generateMockData();
        else
            response = new System.Http().send(request);
        
        if(!(response.getStatusCode() == 200)) 
            throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus() + ':' + response.getBody());         
        
        String responseBody = response.getBody();
        System.debug('*** responseBody:' + responseBody);
        
        Map<String, String> responseMap = parseJson(responseBody);  
        if(responseMap.get('success') == 'true') {
            Set<String> cloudCMALiteVersions = getCloudCMALiteVersions();
            if(String.isNotBlank(responseMap.get('plan')) && cloudCMALiteVersions.Contains(responseMap.get('plan'))) {
                if(String.isNotBlank(responseMap.get('name'))) {
                    String cancelResponse = cancellation(responseMap.get('name'), responseMap.get('code'), serviceJurisdiction);
                    if(cancelResponse != 'success')
                        throw new CustomException('Failed to cancel free version. ' + cancelResponse);  
                }
                return 'CloudCMA Lite';
            }
            else
                return 'CloudCMA Paid'; 
        }
        else if(responseMap.get('success') == 'false')
            return 'Not Found';  
        else
            throw new CustomException('ParsingError: ' + responseBody);    
    }
    
    public Static Map<String, String> provisionCloudCMADirect(SMS_Provisioned_Product__c provProduct) {
        Map<String, String> provMap = new Map<String, String>();
        
        try {
            
            List<Subscriptions__c> subscription = new List<Subscriptions__c>();     
            subscription = PROV_GetProvisionProductDetails.getSubscriptionDetails(provProduct.MRIS_Subscription_Id__c);                 
            
            if(!(subscription.Size() == 1))
                throw new CustomException('Invalid subscription');
            
            
            if(subscription[0].Service_Jurisdiction__c != null )
                cloudCMASettings = getCloudCMASettings(subscription[0].Service_Jurisdiction__c);
            
            if(provProduct.provisioned_status__c == 'Pending Provisioned') {    
                /* Query zuora to know the rate plan term and amount */
                if(String.isBlank(provProduct.Zuora_Product_Rate_Plan_Id__c))
                    throw new CustomException('Zuora product rate plan does not exist.');
                
                SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
                
                String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + provProduct.Zuora_Product_Rate_Plan_Id__c + '\'';
                List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
                String billingPeriod = '';
                Decimal amount = 0;
                if(ratePlanCharges.Size() > 0) {
                    billingPeriod = (String)ratePlanCharges[0].getValue('BillingPeriod');
                    String ratePlanPriceQuery = 'SELECT Id, Price, ProductRatePlanChargeId FROM ProductRatePlanChargeTier WHERE ProductRatePlanChargeId = \'' + (String)ratePlanCharges[0].getValue('Id') + '\'';
                    List<Zuora.zObject> ratePlanPrice = zUtilInstance.zquery(ratePlanPriceQuery);
                    if(ratePlanPrice.Size() > 0) 
                        amount = (Decimal)ratePlanPrice[0].getValue('Price');    
                    else
                        throw new CustomException('Invalid Zuora product rateplan charge tier');
                }
                else
                    throw new CustomException('Invalid zuora product rateplan id.');
                
                String requestMsg  = 'AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN');
                requestMsg += '&ApiKey=' + cloudCMASettings.get('API_KEY');
                requestMsg += '&MlsCode=' + cloudCMASettings.get('MLS_CODE');
                requestMsg += '&MlsId=' + subscription[0].Name;
                requestMsg += '&UserName=' + subscription[0].Contact__r.FirstName + ' ' + subscription[0].Contact__r.LastName;
                requestMsg += '&UserEmail=' + subscription[0].Private_Email__c;
                
                if(billingPeriod == 'Two Years')
                    requestMsg += '&PricingPlan=TwoYear';
                else if(billingPeriod == 'Annual')
                    requestMsg += '&PricingPlan=Year';
                else if(billingPeriod == 'Month')
                    requestMsg += '&PricingPlan=Month';
                else
                    throw new CustomException('Invalid zuora billing period: ' + billingPeriod);   
                
                requestMsg += '&Amount=' + amount; 
                
                wrapper wrap = makeCloudCMAAPICall(requestMsg, 'purchase');
                System.HttpResponse response = wrap.response;
                provMap.put('provisioned_status__c', 'Provisioned'); 
                provMap.put('Status_Message__c', response.getBody());
                provMap.put('Response_Product_Logging__c', response.toString() + response.getBody());
                provMap.put('Request_Product_Logging__c', wrap.request.toString() + requestMsg);
            }
            else if(provProduct.provisioned_status__c == 'Pending Deprovisioned') {
                String requestMsg  = 'AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN');
                requestMsg += '&ApiKey=' + cloudCMASettings.get('API_KEY');
                requestMsg += '&MlsCode=' + cloudCMASettings.get('MLS_CODE');
                requestMsg += '&MlsId=' + subscription[0].Name;
                
                wrapper wrap = makeCloudCMAAPICall(requestMsg, 'cancel');
                System.HttpResponse response = wrap.response;
                provMap.put('provisioned_status__c', 'Deprovisioned'); 
                provMap.put('Status_Message__c', response.getBody());
                provMap.put('Request_Product_Logging__c ', wrap.request.toString() + requestMsg);
                system.debug('***response.getBody' +response.getBody());
                system.debug('***response.getBody' +response.getBody());
                provMap.put('Response_Product_Logging__c ', response.toString() + response.getBody());
                
                
            }                                 
        }
        catch(Exception e) {
            provMap.put('provisioned_status__c', 'Error ' + provProduct.provisioned_status__c);
            provMap.put('Status_Message__c', e.getMessage());
        } 
        
        provMap.put('Id', provProduct.Id);
        return provMap;         
    }
    
    @future (callout = true)
    public static void provisionCloudCMA(String provProductId) {
        try {
            List<SMS_Provisioned_Product__c> provisionProduct = new List<SMS_Provisioned_Product__c>();
            provisionProduct = PROV_GetProvisionProductDetails.getProvisionProduct(provProductId);
            
            if(!(provisionProduct.Size() == 1))
                throw new CustomException('Invalid provisioned product');
            
            SMS_Provisioned_Product__c provProduct = provisionProduct[0];
            
            try {
                
                List<Subscriptions__c> subscription = new List<Subscriptions__c>();     
                subscription = PROV_GetProvisionProductDetails.getSubscriptionDetails(provisionProduct[0].MRIS_Subscription_Id__c);                 
                
                if(!(subscription.Size() == 1))
                    throw new CustomException('Invalid subscription');
                
                if(subscription[0].Service_Jurisdiction__c != null )
                    cloudCMASettings = getCloudCMASettings(subscription[0].Service_Jurisdiction__c);
                
                if(provProduct.provisioned_status__c == 'Pending Provisioned') {    
                    /* Query zuora to know the rate plan term and amount */
                    if(String.isBlank(provProduct.Zuora_Product_Rate_Plan_Id__c))
                        throw new CustomException('Zuora product rate plan does not exist.');
                    
                    SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                    Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
                    
                    String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + provProduct.Zuora_Product_Rate_Plan_Id__c + '\'';
                    List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
                    String billingPeriod = '';
                    Decimal amount = 0;
                    if(ratePlanCharges.Size() > 0) {
                        billingPeriod = (String)ratePlanCharges[0].getValue('BillingPeriod');
                        String ratePlanPriceQuery = 'SELECT Id, Price, ProductRatePlanChargeId FROM ProductRatePlanChargeTier WHERE ProductRatePlanChargeId = \'' + (String)ratePlanCharges[0].getValue('Id') + '\'';
                        List<Zuora.zObject> ratePlanPrice = zUtilInstance.zquery(ratePlanPriceQuery);
                        if(ratePlanPrice.Size() > 0) 
                            amount = (Decimal)ratePlanPrice[0].getValue('Price');    
                        else
                            throw new CustomException('Invalid Zuora product rateplan charge tier');
                    }
                    else
                        throw new CustomException('Invalid zuora product rateplan id.');
                    
                    String requestMsg  = 'AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN');
                    requestMsg += '&ApiKey=' + cloudCMASettings.get('API_KEY');
                    requestMsg += '&MlsCode=' + cloudCMASettings.get('MLS_CODE');
                    requestMsg += '&MlsId=' + subscription[0].Name;
                    requestMsg += '&UserName=' + subscription[0].Contact__r.FirstName + ' ' + subscription[0].Contact__r.LastName;
                    requestMsg += '&UserEmail=' + subscription[0].Private_Email__c;
                    
                    if(billingPeriod == 'Two Years')
                        requestMsg += '&PricingPlan=TwoYear';
                    else if(billingPeriod == 'Annual')
                        requestMsg += '&PricingPlan=Year';
                    else if(billingPeriod == 'Month')
                        requestMsg += '&PricingPlan=Month';
                    else
                        throw new CustomException('Invalid zuora billing period: ' + billingPeriod);   
                    
                    requestMsg += '&Amount=' + amount; 
                    
                    wrapper wrap = makeCloudCMAAPICall(requestMsg, 'purchase');
                    System.HttpResponse response = wrap.response;
                    provProduct.provisioned_status__c = 'Provisioned'; 
                    provProduct.Status_Message__c = response.getBody();
                    system.debug('***response.getBody' +response.getBody());
                    provProduct.Response_Product_Logging__c = response.toString() + response.getBody();
                    provProduct.Request_Product_Logging__c = wrap.request.toString() + requestMsg;
                    if(!(response.getStatusCode() == 200)) 
                        throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus() + ':' + response.getBody());
                    String emailData = getNewSignUpEmailData(provProduct);
                    provProduct.CloudCMA_Email_Content__c = emailData;                       
                }
                else if(provProduct.provisioned_status__c == 'Pending Deprovisioned') {
                    String requestMsg  = 'AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN');
                    requestMsg += '&ApiKey=' + cloudCMASettings.get('API_KEY');
                    requestMsg += '&MlsCode=' + cloudCMASettings.get('MLS_CODE');
                    requestMsg += '&MlsId=' + subscription[0].Name;
                    
                    wrapper wrap = makeCloudCMAAPICall(requestMsg, 'cancel');
                    System.HttpResponse response = wrap.response;
                    system.debug('***response.getBody' +response.getBody());
                    provProduct.Response_Product_Logging__c = response.toString() + response.getBody();
                    provProduct.Request_Product_Logging__c = wrap.request.toString() + requestMsg;
                    
                    if(!(response.getStatusCode() == 200)) 
                        throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus() + ':' + response.getBody());
                    
                    provProduct.provisioned_status__c = 'Deprovisioned'; 
                    provProduct.Status_Message__c = response.getBody();
                }                                 
            }
            catch(Exception e) {
                provProduct.provisioned_status__c = 'Error ' + provProduct.provisioned_status__c;
                provProduct.Status_Message__c = e.getMessage(); 
                
            } 
            
            update provProduct;
        }  
        catch(Exception e) {
            
        }       
    }    
    
    /*
public static String payment() {
String requestMsg  = 'AffiliateToken=' + affiliateToken;
requestMsg += '&ApiKey=' + apiKey;
requestMsg += '&MlsCode=12345';
requestMsg += '&MlsId=11234';

return makeCloudCMAAPICall(requestMsg, 'payment');
}
*/
    
    public static String cancellation(String mlsId, String mlsCode, string serviceJurisdiction) {
        try {
            cloudCMASettings = getCloudCMASettings(serviceJurisdiction);
            String requestMsg  = 'AffiliateToken=' + cloudCMASettings.get('AFFILIATE_TOKEN');
            requestMsg += '&ApiKey=' + cloudCMASettings.get('API_KEY');
            requestMsg += '&MlsCode=' + cloudCMASettings.get('MLS_CODE');
            requestMsg += '&MlsId=' + mlsId;
            
            wrapper wrap = makeCloudCMAAPICall(requestMsg, 'cancel');
            System.HttpResponse response = wrap.response;
            
            if(!(response.getStatusCode() == 200)) 
                throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus() + ':' + response.getBody());
                    
            return 'success';
        }
        catch(Exception e) {
            return e.getMessage();    
        }
    }        
    
    private static String makeCloudCMAAPICallOld(String requestMsg, String actionMethod) {
        System.HttpRequest request = new System.HttpRequest();
        request.setBody(requestMsg);
        system.debug('*** requestMsg' +requestMsg);
        request.setMethod('POST');
        request.setEndpoint(cloudCMASettings.get('SERVICE_URL') + actionMethod);
        request.setTimeout(90000);
        request.setHeader('Connection', 'Keep-Alive');
        
        System.HttpResponse response = new System.HttpResponse();
        if (Test.isRunningTest()) 
            response = SMS_CloudCMA_MockDataGenerator.generateMockData();
        else
            response = new System.Http().send(request);
        system.debug('*** Request: ' + request);
        system.debug('*** Response: ' + response);
        system.debug('*** response msg:' + response.getBody());
        
        if(!(response.getStatusCode() == 200)) 
            throw new CustomException('Failed: ' + response.getStatusCode() + '-' + response.getStatus() + ':' + response.getBody()); 
        
        return response.getBody();               
    }
    
    private static wrapper makeCloudCMAAPICall(String requestMsg, String actionMethod) {
        System.HttpRequest request = new System.HttpRequest();
        request.setBody(requestMsg);
        system.debug('*** requestMsg' +requestMsg);
        request.setMethod('POST');
        request.setEndpoint(cloudCMASettings.get('SERVICE_URL') + actionMethod);
        request.setTimeout(90000);
        request.setHeader('Connection', 'Keep-Alive');
        
        System.HttpResponse response = new System.HttpResponse();
        if (Test.isRunningTest()) 
            response = SMS_CloudCMA_MockDataGenerator.generateMockData();
        else
            response = new System.Http().send(request);
        system.debug('*** Request: ' + request);
        system.debug('*** Response: ' + response);
        system.debug('*** response msg:' + response.getBody());
        wrapper wrap = new wrapper();
        wrap.request = request;
        wrap.response = response;
       
        return wrap;               
    }
    
    private static Map<String, String> parseJson(String responseBody) {
        JSONParser parser = JSON.createParser(responseBody);
        Set<String> ignoreParameters = new Set<String> {'{', '}', 'user', 'mls_credential', 'subscription'};
            Map<String, String> responseMap = new Map<String, String>(); 
        while (parser.nextToken() != null) {
            if(!ignoreParameters.contains(parser.getText())) {
                String lable = parser.getText();
                parser.nextToken();
                String value = parser.getText();
                responseMap.put(lable, value);
            }
        }
        
        return responseMap;    
    }
    
    private static Map<String, String> getCloudCMASettings(string serviceJurisdiction) {
        List<SMS_CloudCMA_Settings__c> settings = [SELECT Id, Name, Value__c, AFFILIATE_TOKEN__c, MLS_CODE__c, API_KEY__c, SERVICE_URL__c FROM SMS_CloudCMA_Settings__c where Name =:serviceJurisdiction];
        Map<String, String> settingsMap = new Map<String, String>();
        for(SMS_CloudCMA_Settings__c setting : settings) {
            //settingsMap.put(setting.Name, setting.Value__c);
            settingsMap.put('AFFILIATE_TOKEN', setting.AFFILIATE_TOKEN__c);
            settingsMap.put('MLS_CODE', setting.MLS_CODE__c);
            settingsMap.put('API_KEY', setting.API_KEY__c);
            settingsMap.put('SERVICE_URL', setting.SERVICE_URL__c);
        }
        return settingsMap;       
    }
    
    private static Set<String> getCloudCMALiteVersions() {
        List<SMS_CloudCMA_Free_Versions__c> products = [SELECT Id, Name FROM SMS_CloudCMA_Free_Versions__c];
        Set<String> liteProducts = new Set<String>();
        for(SMS_CloudCMA_Free_Versions__c product : products ) {
            liteProducts.add(product.Name);    
        }
        return liteProducts;       
    }
    
    private static String getNewSignUpEmailData(SMS_Provisioned_Product__c provisionProduct) {
        String response = '';
        try {
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            String zAccountQuery = 'SELECT Id, Name FROM Account WHERE AccountNumber = \'' + provisionProduct.MRIS_Subscription_Id__c + '\'';        
            List<Zuora.zObject> zAccount = zUtilInstance.zquery(zAccountQuery);
            
            String zSubscriptionQuery = 'SELECT Id, Name, ContractEffectiveDate, ServiceActivationDate, TermStartDate, TermEndDate, SubscriptionStartDate, SubscriptionEndDate FROM Subscription WHERE AccountId = \'' + (String)zAccount[0].getValue('Id') + '\'';
            List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zSubscriptionQuery);
            
            Integer i = 0;
            String zRatePlanQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';     
            
            for (Zuora.zObject zSubscription : zSubscriptions) {
                
                if (i != 0)
                    zRatePlanQuery += ' OR ';        
                
                zRatePlanQuery += 'SubscriptionId = \'' + (String)zSubscription.getValue('Id') + '\'';
                i++;            
            }
            
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(zRatePlanQuery);
            System.debug(zRatePlans);
            zSubscriptionSummary obj = new zSubscriptionSummary();
            for(Integer j=zRatePlans.Size()-1; j>=0; j--) {
                Zuora.zObject zRatePlan = zRatePlans[j];
                if((String)zRatePlan.getValue('ProductRatePlanId') == provisionProduct.zuora_product_rate_plan_id__c) {
                    obj.subscriptionId = (String)zRatePlan.getValue('SubscriptionId');
                    obj.ratePlanId = (String)zRatePlan.getValue('Id');
                    obj.productRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                    break;
                }
            }
            
            String zRatePlanChargeQuery = 'SELECT Id, Name, Price FROM RatePlanCharge WHERE RatePlanId = \'' + obj.ratePlanId + '\'';
            List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(zRatePlanChargeQuery);
            obj.price = (Decimal)zRatePlanCharges[0].getValue('Price');
            
            String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + obj.productRatePlanId + '\'';
            List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
            obj.period = (String)ratePlanCharges[0].getValue('BillingPeriod');
            
            for (Zuora.zObject zSubscription : zSubscriptions) {
                if((String)zSubscription.getValue('Id') == obj.subscriptionId) {
                    DateTime termStartDate = (Date)zSubscription.getValue('TermStartDate');
                    DateTime termEndDate = (Date)zSubscription.getValue('TermEndDate');
                    DateTime serviceActivationDate = (Date)zSubscription.getValue('ServiceActivationDate');
                    DateTime contractEffectiveDate = (Date)zSubscription.getValue('ContractEffectiveDate');
                    
                    obj.serviceActivationDate = serviceActivationDate.addDays(-1).formatGmt('MM/dd/YYYY');
                    break;
                }   
            }
            System.debug('*** obj: ' + obj);
            response = 'Your Free Trial ends at midnight on ' + obj.serviceActivationDate + '.  If you keep your account open past that time, you will be charged $' + obj.price + ' per ' + obj.period + ' for your Cloud CMA service.  If you do not wish to continue using Cloud CMA, simply cancel before ' + obj.serviceActivationDate + ' and you will not be charged.';
        }
        catch(Exception e) {
            System.debug('*** e: ' + e.getMessage());
        }
        
        return response;    
    }
    
    public class zSubscriptionSummary {
        public String subscriptionId { get; set; }
        public String ratePlanId { get; set; }
        public String productRatePlanId { get; set; }
        public Decimal price { get; set; }
        public String period { get; set; }
        public String termStartDate { get; set; }
        public String termEndDate { get; set; }
        public String serviceActivationDate { get; set; }
        public String contractEffectiveDate { get; set; }
    }

    public class wrapper{
        public System.HttpRequest request { get; set; }
        public System.HttpResponse response { get; set; }
    }    
    
    public Class CustomException extends Exception {}
}