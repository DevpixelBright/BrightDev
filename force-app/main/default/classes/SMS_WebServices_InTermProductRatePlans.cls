@RestResource(urlMapping='/InTermProductRatePlans/*')
global class SMS_WebServices_InTermProductRatePlans{

    @HttpGet
    global static List<string> GetRatePlans() {
        RestRequest req = RestContext.request;         
        String mrisSubscriptionId = req.params.get('subscriptionId');
        
        if(String.isBlank(mrisSubscriptionId)) 
            throw new CustomException('Subscription Id can not be null'); 
        
        String zAccountId;
        String query;
        Boolean isFirst;
        
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();           
        
        /* Query zuora account based on Subscription Id */
        query = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + mrisSubscriptionId+ '\'';
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(query); 
        //List<Zuora.zObject> zAccounts = zApiInstance.zquery(query);
        
        if(zAccounts.size() > 1)
            throw new CustomException('Multiple accounts found with subscription id ' + mrisSubscriptionId); 
        
        if(zAccounts.size() == 0)
            throw new CustomException('No accounts found with subscription id ' + mrisSubscriptionId);
        
        zAccountId = (String)zAccounts[0].getValue('Id'); 
        
        query = 'SELECT Id FROM Subscription WHERE AccountId = \'' + zAccountId
            + '\' AND Status = \'Active\' AND IsCore__c = false AND TermEndDate >= ' 
            + DateTime.now().format('yyyy-MM-dd','PST')
            + ' AND TermStartDate <= ' + 
            + DateTime.now().format('yyyy-MM-dd','PST');

        //List<Zuora.zObject> zSubscriptions = zApiInstance.zquery(query);
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(query);
        
        if(zSubscriptions.size() == 0)
            return new List<string>();
        
        query = 'SELECT Id, ProductRatePlanId FROM RatePlan WHERE ';
        isFirst = true;
        for (Zuora.zObject zSubscription : zSubscriptions) {
            String zSubscriptionId = (String) zSubscription.getValue('Id');
            if(isFirst) isFirst = false;
            else query += ' OR ';
            
            query += 'SubscriptionId = \'' + zSubscriptionId + '\'';
                
        }
        
        //List<Zuora.zObject> zRatePlans = zApiInstance.zquery(query);
        List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(query);
        
        Boolean filterByProduct = false;
        List<Zuora.zObject> zProductRatePlans = null;
        Set<String> filteredPlans = new Set<String>();
        
        String productId = req.params.get('productId');
        
        if(String.isNotBlank(productId)) {
            
            filterByProduct = true;
            query = 'SELECT Id FROM ProductRatePlan WHERE ProductId = \'' + productId + '\'';
            
            //zProductRatePlans = zApiInstance.zquery(query);
            zProductRatePlans = zUtilInstance.zquery(query);
            
            if(zProductRatePlans.size() == 0)
                throw new CustomException('No products were found with Product Id ' + productId);
            
            for(Zuora.zObject zProductRatePlan : zProductRatePlans)
                filteredPlans.add((String) zProductRatePlan.getValue('Id'));
        }
        
        List<String> productRatePlans = new List<String>();
        for (Zuora.zObject zRatePlan : zRatePlans) {
            if(filterByProduct) {
                if(filteredPlans.contains((String) zRatePlan.getValue('ProductRatePlanId')))
                    productRatePlans.add((String) zRatePlan.getValue('ProductRatePlanId'));
            }
            else {
                productRatePlans.add((String) zRatePlan.getValue('ProductRatePlanId'));
            }
        }
        
        return productRatePlans;
    }
    
    class CustomException extends Exception {}   
}