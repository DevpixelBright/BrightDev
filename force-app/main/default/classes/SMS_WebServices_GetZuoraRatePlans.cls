@RestResource(urlMapping='/GetZuoraRatePlans/*')
global class SMS_WebServices_GetZuoraRatePlans {

    @HttpPost
    global static Response GetZuoraRatePlans(InputData request) {
        Response res = new Response();
        try {
            if(request.MRISSubscriptionId == null || request.ZuoraProductId == null)
                throw new CustomException('Missing required input parameters');
            
            List<Subscriptions__c> subscriptions = [SELECT id,Name,
                                   Related_Location_Broker_Office__r.Name,
                                   Contact__c,
                                   Contact_Type__c,
                                   Subscription_Type__c
                            FROM Subscriptions__c 
                            WHERE Name = :request.MRISSubscriptionId 
                            AND   Status__c = 'Active'];
                            
            if(subscriptions.Size() != 1)
                throw new CustomException('Invalid MRIS Subscription Id');
            
            String productId = request.ZuoraProductId;
            /* Product rate plan names */
            List<String> ratePlanNames = new List<String>{'Select', 'Agent IDX', 'Total', 'Premium', 'Office Website', 'Office IDX', 'realPING', 'Authentisign', 'CloudCMA'};
                
            /* Check current provision status */
            List<SMS_Provisioned_Product__c> provProducts = new List<SMS_Provisioned_Product__c>();
            provProducts = [SELECT Id,Name,Product_Status_Reason__c,Product_Status__c,Product_Sub_Type__c,
                            Product_Type__c,Provisioned_Status__c,Status_Message__c,Zuora_Product_Rate_Plan_Id__c  
                            FROM   SMS_Provisioned_Product__c 
                            WHERE  MRIS_Subscription_Id__c =: subscriptions[0].Name
                            AND    Product_Type__c IN ('XactSite Agent','XactSite Office', 'MRIS XactSite Agent', 'MRIS XactSite Office')];
            
            Map<String, String> productProvRatePlans = new Map<String, String>();
            Boolean isTerminated = false;
            if(provProducts.Size() > 0) {
                for(SMS_Provisioned_Product__c provProduct : provProducts) {
                    if(!provProduct.Product_Status_Reason__c.contains('Terminated')) {
                        for(String ratePlanName : ratePlanNames) {
                            if(provProduct.Product_Sub_Type__c.Contains(ratePlanName))
                                productProvRatePlans.put(ratePlanName, provProduct.Zuora_Product_Rate_Plan_Id__c);
                        }
                    }
                    else
                        isTerminated = true;        
                }
            }
            
            /* If product not terminated check all provision rate plans in history */
            if(!isTerminated) {
                List<SMS_Provisioned_Product_History__c> provHistoryProducts = new List<SMS_Provisioned_Product_History__c>();
                provHistoryProducts = [SELECT Id,Name,Product_Status_Reason__c,Product_Status__c,Product_Sub_Type__c,
                                       Product_Type__c,Provisioned_Status__c,Status_Message__c,Zuora_Product_Rate_Plan_Id__c  
                                       FROM   SMS_Provisioned_Product_History__c 
                                       WHERE  MRIS_Subscription_Id__c =: subscriptions[0].Name
                                       AND    Product_Type__c IN ('XactSite Agent','XactSite Office', 'MRIS XactSite Agent', 'MRIS XactSite Office')
                                       ORDER BY CreatedDate DESC];
                if(provHistoryProducts.Size() > 0) {
                    for(SMS_Provisioned_Product_History__c provProduct : provHistoryProducts) {
                        if(!provProduct.Product_Status_Reason__c.contains('Terminated')) {
                            for(String ratePlanName : ratePlanNames) {
                                if(provProduct.Product_Sub_Type__c.Contains(ratePlanName) && String.isBlank(productProvRatePlans.get(ratePlanName)))
                                    productProvRatePlans.put(ratePlanName, provProduct.Zuora_Product_Rate_Plan_Id__c);
                            }
                        }        
                    }
                }
                System.debug('*** productProvRatePlans: ' + productProvRatePlans);
            }
            
            /* Get rate plans from zuora */
            SMS_ZuoraUtil zUtilInstance; 
            Zuora.zApi.LoginResult zLoginResult;
            List<Zuora.zObject> zObject;
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();
            Map<String, String> isOldRatePlanMap = new Map<String, String>();
            
            String zoql = 'SELECT Id, Name, ProductId, IsOld__c FROM ProductRatePlan WHERE ProductId =\''+productId+'\'';              
            zObject = zUtilInstance.zquery(zoql); 
            /* For loop decide which rate plans needs to load either new or old */
            for (Zuora.zObject zProductRatePlan : zObject) {
                for(String ratePlanName : ratePlanNames) {
                    if(((String)zProductRatePlan.getValue('Name')).contains(ratePlanName) && (String)zProductRatePlan.getValue('Id') == productProvRatePlans.get(ratePlanName) && (String)zProductRatePlan.getValue('IsOld__c') == 'true')
                        productProvRatePlans.put(ratePlanName, 'Old');
                         
                    isOldRatePlanMap.put((String)zProductRatePlan.getValue('Id'), (String)zProductRatePlan.getValue('IsOld__c'));   
                }
            }
            System.debug('*** productProvRatePlans: ' + productProvRatePlans);
            System.debug('*** isOldRatePlanMap: ' + isOldRatePlanMap);
            
            /* Frame map with rate plans which display in front end */
            Map<String, String> finalRatePlans = new Map<String, String>();
            for (Zuora.zObject zProductRatePlan : zObject) {
                for(String ratePlanName : ratePlanNames) {
                    if(((String)zProductRatePlan.getValue('Name')).contains(ratePlanName) && productProvRatePlans.get(ratePlanName) == 'Old' && (String)zProductRatePlan.getValue('IsOld__c') == 'true')   
                        finalRatePlans.put((String)zProductRatePlan.getValue('Id'), (String)zProductRatePlan.getValue('Name'));
                    else if(((String)zProductRatePlan.getValue('Name')).contains(ratePlanName) && productProvRatePlans.get(ratePlanName) != 'Old' && (String)zProductRatePlan.getValue('IsOld__c') != 'true')   
                        finalRatePlans.put((String)zProductRatePlan.getValue('Id'), (String)zProductRatePlan.getValue('Name'));   
                }
            }
            
            Map<String, String> zRatePlanMap = finalRatePlans;
            
            String ratePlanChargeQuery = 'SELECT Id, Name, ChargeType, ProductRatePlanId FROM ProductRatePlanCharge WHERE ';     
            Integer i = 0;        
            for (String zProductRatePlan : zRatePlanMap.keySet()) {
                
                if (i != 0)
                    ratePlanChargeQuery += ' OR ';        
                
                ratePlanChargeQuery += 'ProductRatePlanId = \'' + zProductRatePlan + '\'';
                i++;            
            }
            System.debug('***' + ratePlanChargeQuery );
            
            /* Querying rate plan charges to differentiate onetime rate plans */
            List<ratePlan> onetimeList = new List<ratePlan>();
            List<ratePlan> upgradeList = new List<ratePlan>();
            List<ratePlan> recurringList = new List<ratePlan>();
            
            List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(ratePlanChargeQuery);
            for(Zuora.zObject zRatePlanCharge : zRatePlanCharges) {
            
                String productChargeName = (String)zRatePlanCharge.getValue('Name');
                ratePlan rp = new ratePlan();
                rp.ratePlanId = (String)zRatePlanCharge.getValue('ProductRatePlanId'); 
                rp.ratePlanName = zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId'));
                if(isOldRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId')) == 'true')
                    rp.isOld = 'true';
                else
                    rp.isOld = 'false';
                               
                if ((String)zRatePlanCharge.getValue('ChargeType') == 'OneTime' && productChargeName.Contains('Setup Fee'))
                    onetimeList.add(rp);    
                else if ((String)zRatePlanCharge.getValue('ChargeType') == 'OneTime' && !productChargeName.Contains('Setup Fee'))
                    upgradeList.add(rp);    
                else
                    recurringList.add(rp);    
            }
            res.Status = 'Success';
            res.setupFeeRatePlans = onetimeList;
            res.upgradeFeeRatePlans = upgradeList;
            res.recurringFeeRatePlans = recurringList;  
            res.errorDescription = '';         
        }
        Catch(Exception e) {
            res.Status = 'Failed';
            res.setupFeeRatePlans = new List<ratePlan>();
            res.upgradeFeeRatePlans = new List<ratePlan>();
            res.recurringFeeRatePlans = new List<ratePlan>(); 
            res.errorDescription = e.getMessage();         
        }
        System.debug(res);
        return res;
    }
    
    global Class InputData {        
        WebService String ZuoraProductId { get; set; } 
        WebService String MRISSubscriptionId { get; set; }                  
    }  
    
    global Class Response {
        WebService String Status { get; set; }       
        WebService List<ratePlan> setupFeeRatePlans { get; set; }
        WebService List<ratePlan> upgradeFeeRatePlans { get; set; }
        WebService List<ratePlan> recurringFeeRatePlans { get; set; }
        WebService String errorDescription { get; set; }
    }  
    
    global Class ratePlan {
        WebService String ratePlanId { get; set; }
        WebService String ratePlanName { get; set; }
        WebService String isOld { get; set; }
    }    
    
    class CustomException extends Exception {}   
}