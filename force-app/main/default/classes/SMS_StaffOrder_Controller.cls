public class SMS_StaffOrder_Controller { 
    
    public String zDiscountProductRatePlanId { get; set; }
    public String zRecurringProductRatePlanId { get; set; }
    public String zOneTimeProductRatePlanId { get; set; }
    
    public Integer termDuration { get{return 12;} private set; }
    
    public List<CartItem> cartItems {get;set;} 
    public Map<String,CartItem> cartItemsMap {get;set;}
    public Boolean showCart { get; set; } 
    public Boolean showProducts { get; set; }  
    
    public String processURL { get; set; }
    public String iframeDomain { get; set; } 
    public Boolean showProcess { get; set; }  
    public String redirectUrl { get; private set; }
    public String cancelUrl { get; private set; }
    
    public String zAccountId { get; private set; }
    public String zAccountName { get; private set; }
    public String zProductId { get; set; }      
     
    public List<SelectOption> zProducts { get; set; }
    public List<SelectOption> zProductRatePlans { get; set; }
    public List<SelectOption> zOnetimeRatePlans { get; set; }
    public List<SelectOption> zDiscountRatePlans { get; set; }
    private Map<String,String> zProductMap;
    private Map<String,String> zRatePlanMap;
    private Map<String,String> zDiscountRatePlanMap; 
    private String zDiscountProductId ;   
    
    private SMS_ZuoraUtil zUtilInstance; 
    private Zuora.zApi.LoginResult zLoginResult;
    public List<Zuora.zObject> zObject;
    
    private String subscriptionId;   
    public Subscriptions__c subscription {get; set;}
        
    public SMS_StaffOrder_Controller() {       
        subscriptionId = ApexPages.currentpage().getparameters().get('id');
        iframeDomain = ApexPages.currentpage().getparameters().get('iframeDomain');
        system.debug('*** iframeDomain :' + iframeDomain );
        if(String.isBlank(subscriptionId ))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Operation'));
        subscription = new Subscriptions__c();
        try {             
            subscription = [SELECT id,Name,
                                   Related_Location_Broker_Office__r.Name,
                                   Contact__c,
                                   Contact_Type__c,
                                   Subscription_Type__c,
                                   Service_Jurisdiction__c
                            FROM Subscriptions__c 
                            WHERE id = :subscriptionId 
                            AND   Status__c = 'Active'
                           ];                                                    
            system.debug('*** subscription Id :' + subscription.Name);
            
            if(String.isBlank(subscription.Service_Jurisdiction__c))
               subscription.Service_Jurisdiction__c = 'MRIS'; 
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();
            
            String zAccountsQuery = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + subscription.Name + '\'';
            system.debug('*** zAccountsQuery :' + zAccountsQuery);
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
            
            system.debug('*** zAccounts: ' +  zAccounts);
            
            zAccountId = (String)zAccounts[0].getValue('Id');
            if(String.isNotBlank(zAccountId)) {           
            showProducts = true;                 
            zAccountName = (String)zAccounts[0].getValue('Name');       
            
            cartItemsMap = new Map<String,CartItem>();
            showCart = false;  
            
            zRatePlanMap = new Map<String,String>();
            zProductMap = new Map<String,String>(); 
            zDiscountRatePlanMap = new Map<String,String>();
                    
            zProducts = new List<SelectOption>();
            
            zDiscountRatePlans = new List<SelectOption>();            
            
            Set<String> premiumProducts = new Set<String>();
            Set<String> discountProducts = new Set<String>();
            
            Set<String> BORProducts = new Set<String>();
            
            BORProducts.add('Sphere by Bright MLS Office IDX');
            BORProducts.add('Social Pro Office by Bright MLS');
            BORProducts.add('Sphere Office by Bright MLS');
                
            List<Relationship__c> BORrelation  = [Select Id, name, Status__c, Relationship_End_Date__c 
                                            From Relationship__c 
                                            Where Subscription__r.Id =: subscriptionId 
                                            AND Relationship_Type__c IN ('Broker of Record', 'Office Manager')
                                            AND Status__c = 'Active'
                                            AND (Relationship_End_Date__c = null OR Relationship_End_Date__c >= today)];
                
            system.debug('$$$ subscriptionId :' + subscriptionId);
            system.debug('$$$ BORrelation :' + BORrelation);
                
                for(SMS_Premium_Products__c premiumProduct : SMS_Premium_Products__c.getall().values()){ 
                    system.debug('$$$ premiumProduct :' + premiumProduct);
                    Set<String> mlsSystems = new Set<String>();
                    mlsSystems.addAll(premiumProduct.Service_Jurisdiction__c.split(','));
                    if(mlsSystems.contains(subscription.Service_Jurisdiction__c)){
                        system.debug('--out --premiumProduct.Name---'+premiumProduct.Name);
                        if(BORProducts.contains(premiumProduct.Name)){
                            system.debug('-inside---premiumProduct.Name---'+premiumProduct.Name);
                            
                            if(BORrelation != null && BORrelation.size() > 0)
                                premiumProducts.add(premiumProduct.Name);
                        }                    
                        else 
                            premiumProducts.add(premiumProduct.Name); 
                    }
                }
            
            for(SMS_DiscountProducts__c discountProduct : SMS_DiscountProducts__c.getall().values()) {
                Set<String> mlsSystems = new Set<String>();
                mlsSystems.addAll(discountProduct.Service_Jurisdiction__c.split(','));
                if(mlsSystems.contains(subscription.Service_Jurisdiction__c))
                    discountProducts.add(discountProduct.Name);         
            }
            //String todayDate = System.now().format('yyyy-MM-dd\'T\'HH:mm:ss','PST'); 
            String todayDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
            String zProductQuery = 'SELECT Id, Name, EffectiveEndDate, EffectiveStartDate FROM Product WHERE EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;
             
            zObject = zUtilInstance.zquery(zProductQuery); 
            for (Zuora.zObject zProduct : zObject) {
                if(premiumProducts.contains((String)zProduct.getValue('Name'))){                       
                    zProducts.add(new SelectOption((String)zProduct.getValue('Id'),(String)zProduct.getValue('Name'))); 
                    zProductMap.put((String)zProduct.getValue('Id'),(String)zProduct.getValue('Name'));
                } 
                else if(discountProducts.contains((String)zProduct.getValue('Name'))) {
                    zDiscountProductId = (String)zProduct.getValue('Id');
                }             
            }           
            
            Map<String, SelectOption> labelOptions = new Map<String, SelectOption>();
 
            for(SelectOption option : zProducts)
                labelOptions.put(option.getLabel(), option);
     
            //Sort the keys and items in ascending order
            List<String> keys = new List<String>(labelOptions.keySet());
            keys.sort();
            zProducts.clear();
            zProducts.add(new SelectOption('','-- Choose --')); 
            
            for(String k : keys)
                zProducts.add(labelOptions.get(k));
            
            //Discount Rate Plan
            if(String.IsNotBlank(zDiscountProductId)){    
                String zoql = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE ProductId =\'' + zDiscountProductId + '\'' + ' AND EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;
                zObject = zUtilInstance.zquery(zoql); 
                
                for (Zuora.zObject zDiscountRatePlan : zObject) {
                    zDiscountRatePlanMap.put((String)zDiscountRatePlan.getValue('Id'),(String)zDiscountRatePlan.getValue('Name'));
                    zDiscountRatePlans.add(new SelectOption((String)zDiscountRatePlan.getValue('Id'),(String)zDiscountRatePlan.getValue('Name'))); 
                } 
                
                labelOptions = new Map<String, SelectOption>();
     
                for(SelectOption option : zDiscountRatePlans)
                    labelOptions.put(option.getLabel(), option);
         
                //Sort the keys and items in ascending order
                keys = new List<String>(labelOptions.keySet());
                keys.sort();
                zDiscountRatePlans.clear();
                zDiscountRatePlans.add(new SelectOption('','-- Choose --')); 
                for(String k : keys)
                    zDiscountRatePlans.add(labelOptions.get(k));
            }
                cartItems = new List<CartItem>(); 
            }
            else 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Zuora Account found'));
         
        } 
        catch(Exception e){
             if(String.isBlank(subscription.id))
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subscription is not Active'));
        } 
                
    }
   
    public PageReference populateProductRatePlans(){
        
        system.debug('*** Get Rate Plans method is called');
        zProductRatePlans = new List<SelectOption>(); 
        zOnetimeRatePlans = new List<SelectOption>();        
        /*
        String zoql;          
        zoql = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE ProductId =\'' + zProductId + '\'';              
        zObject = zUtilInstance.zquery(zoql); 
        */
        if(subscription.Service_Jurisdiction__c != null)
            zRatePlanMap = getProductRatePlans(zProductId);
        //else if(subscription.Service_Jurisdiction__c == 'TREND' || subscription.Service_Jurisdiction__c == 'BRIGHT'){
        //    zRatePlanMap = populateTRENDRatePlans(zProductId);
        //}
        system.debug('*** zProductId : ' + zProductId );

        system.debug('zRatePlanMap: ' + zRatePlanMap);
        
        Integer i = 0;
        String ratePlanChargeQuery = 'SELECT Id, Name, ChargeType, ProductRatePlanId FROM ProductRatePlanCharge WHERE ';     
        
        for (String zProductRatePlan : zRatePlanMap.keySet()) {
            
            if (i != 0)
                ratePlanChargeQuery += ' OR ';        
            
            ratePlanChargeQuery += 'ProductRatePlanId = \'' + zProductRatePlan + '\'';
            i++;            
        }
        System.debug('***' + ratePlanChargeQuery );
         
        /* Querying rate plan charges to differentiate onetime rate plans */
        //zOnetimeRatePlans.add(new SelectOption('','-- Choose --'));
        List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(ratePlanChargeQuery);
        for(Zuora.zObject zRatePlanCharge : zRatePlanCharges) {
            if ((String)zRatePlanCharge.getValue('ChargeType') == 'OneTime')
                zOnetimeRatePlans.add(new SelectOption((String)zRatePlanCharge.getValue('ProductRatePlanId'), zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId'))));
            else
                zProductRatePlans.add(new SelectOption((String)zRatePlanCharge.getValue('ProductRatePlanId'), zRatePlanMap.get((String)zRatePlanCharge.getValue('ProductRatePlanId'))));    
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
        for(String k : keys)
            zProductRatePlans.add(labelOptions.get(k)); 
            
        /* Sorting onetime rate plans */
        labelOptions = new Map<String, SelectOption>();
 
        for(SelectOption option : zOnetimeRatePlans)
            labelOptions.put(option.getLabel(), option);
 
        //Sort the keys and items in ascending order
        keys = new List<String>(labelOptions.keySet());
        keys.sort();
        zOnetimeRatePlans.clear();
        zOnetimeRatePlans.add(new SelectOption('','-- Choose --'));
        for(String k : keys)
            zOnetimeRatePlans.add(labelOptions.get(k));                    
        
        return null; 
    } 
        
    public boolean validateCartItem(CartItem ci) {
        Boolean validate = true;
        if(String.isBlank(ci.ProductId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Product'));
            validate = false;
        }
        else if(String.isBlank(ci.RecurringProductRatePlanId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Rate Plan'));
            validate = false;
        }
                
        return validate;
    }
    
    public PageReference addToCart() {
            CartItem ci = new CartItem();
     
            ci.ProductId = zProductId;            
            ci.ProductName = zProductMap.get(zProductId);
            ci.RecurringProductRatePlanId = zRecurringProductRatePlanId;    
            ci.RecurringProductRatePlanName = zRatePlanMap.get(zRecurringProductRatePlanId);
            ci.DiscountProductRatePlanId = zDiscountProductRatePlanId;
            ci.DiscountProductRatePlanName = zDiscountRatePlanMap.get(zDiscountProductRatePlanId);
            ci.OneProductRatePlanId = zOneTimeProductRatePlanId;
            ci.OneProductRatePlanName = zRatePlanMap.get(zOneTimeProductRatePlanId);
            
            ci.TermDuration = termDuration;
            ci.check = false;
        
        if(cartItems == null)
            cartItems = new List<CartItem>();
            
        if(validateCartItem(ci)) {    
            cartItemsMap.put(zProductId,ci);
            cartItems.clear();
            cartItems.addAll(cartItemsMap.values()); 
            
            showCart = true; 
            
            zProductId = null; 
            termDuration = null;
            zDiscountProductRatePlanId = null;
            zProductRatePlans.clear();
            zOnetimeRatePlans.clear();
            showProcess = false;  
        }
        return null;
    }
    
     public PageReference removeFromCart() {
        for(CartItem ci:cartItems) {
            if(ci.check)
                cartItemsMap.remove(ci.productId);
        }
        
        cartItems.clear();
        cartItems.addAll(cartItemsMap.values());
        
        if(cartItemsMap.size()==0) 
            showCart = false;       
            
        zProductId = null;         
        zProductRatePlans.clear(); 
        showProcess = false;
              
        return null;
    } 
    
    public PageReference confirm() {
        try {
        
            //Inserts the products as Order Items into SMS_OrderItems object
            
            Boolean createOrder = true;
            DateTime effectiveDate = System.Now();
             
            List<SMS_OrderItem__c> orderItems = new List<SMS_OrderItem__c>();
             
             for(CartItem item : cartItems) {
                // Create a list of order items
                String productName = zProductMap.get(item.ProductId );
                SMS_OrderItem__c orderItem = new SMS_OrderItem__c();
                
                //orderItem.Order_Id__c = order.Id;                                             
                orderItem.Zuora_Product_Id__c = item.ProductId ;
                orderItem.Zuora_Product_Name__c = productName;            
                orderItem.RecurringProductRatePlanId__c = item.RecurringProductRatePlanId;
                orderItem.RecurringProductRatePlanName__c = item.RecurringProductRatePlanName;  
                orderItem.DiscountProductRatePlanId__c = item.DiscountProductRatePlanId;
                orderItem.DiscountProductRatePlanName__c = item.DiscountProductRatePlanName;
                orderItem.OneTimeProductRatePlanId__c =  item.OneProductRatePlanId;
                orderItem.OneTimeProductRatePlanName__c = item.OneProductRatePlanName;        
                //orderItem.TermDuration__c = item.TermDuration;
                orderItem.Initial_Term__c = 12;
                orderItem.Renewal_Term__c = 12;
                orderItem.Contract_Effective_Date__c = effectiveDate;
                orderItem.Service_Activation_Date__c = effectiveDate;                              
                orderItem.IsCore__c = false;
                orderItem.IsDiscountOnly__c = false; 
                 String zRecurringProductRatePlanId = item.RecurringProductRatePlanId;
                 
                 SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                 Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
                 
                 String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + zRecurringProductRatePlanId + '\'';
                 List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
                 
                 String billingPeriod = (String)ratePlanCharges[0].getValue('BillingPeriod'); 
                
                //Determine term durations for TREND products
                if(subscription.Service_Jurisdiction__c == 'TREND' || subscription.Service_Jurisdiction__c == 'BRIGHT'){
                    
                    
                    if(orderItem.Zuora_Product_Name__c.contains('XactSite')){
                        orderItem.Initial_Term__c = 12;
                        orderItem.Renewal_Term__c = 12;
                    }
                    else if(orderItem.RecurringProductRatePlanName__c == 'Social Pro Annual Term' || orderItem.RecurringProductRatePlanName__c == 'Social Pro Office by Bright MLS Annual Term'){
                        orderItem.Initial_Term__c = 12;
                        orderItem.Renewal_Term__c = 1;
                    }
                    else if(billingPeriod == 'Semi-Annual'){
                        orderItem.Initial_Term__c = 6;
                        orderItem.Renewal_Term__c = 6;
                    }
                    else if(billingPeriod == 'Month'){
                        orderItem.Initial_Term__c = 1;
                        orderItem.Renewal_Term__c = 1;
                    }
                    else if(billingPeriod == 'Quarter'){
                        orderItem.Initial_Term__c = 3;
                        orderItem.Renewal_Term__c = 3;                        
                    }
                    else if(billingPeriod == 'Annual'){
                        orderItem.Initial_Term__c = 12;
                        orderItem.Renewal_Term__c = 12;
                    }
                    else if(billingPeriod == 'Two Years'){
                        orderItem.Initial_Term__c = 24;
                        orderItem.Renewal_Term__c = 24;                        
                    }
                }
                //CloudCMA product verification        

                if(productName == 'CloudCMA'){
                    String productTypeCloudCMA;
                    productTypeCloudCMA = SMS_CloudCMA.findCloudCMAType(subscriptionId);                   
                    
                    if(productTypeCloudCMA == 'Not Found'|| productTypeCloudCMA == 'CloudCMA Lite'){
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
                    else if(productTypeCloudCMA == 'CloudCMA Paid'){
                        createOrder = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Already in CloudCMA. Contact CloudCMA for any modifications'));
                    }
                }
                
                if(productName.contains('Sphere') && billingPeriod == 'Month'){
                    orderItem.Initial_Term__c = 12;
                    orderItem.Renewal_Term__c = 1; 
                }
                orderItems.add(orderItem);
             }
            
            if(createOrder){ 
                SMS_Order__c order = new SMS_Order__c();                
                order.Name = 'Order Id';
                order.Token__c = '';
                order.Zuora_Account_Id__c = zAccountId;
                order.MRIS_Subscription_Id__c = subscription.id;
                order.Status__c = 'Active';
                order.Bypass_Payment__c = true;
                
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
                
                system.debug('**** Update order  : ' + order );
                
                for(SMS_OrderItem__c orderItem : orderItems){
                    orderItem.Order_Id__c = order.Id;
                }
                 
                 insert orderItems; 
                 //Schedule batch apex  will execute after ten minutes  after insert 
                     
                 String query = 'SELECT Id,Status__c FROM SMS_Order__c WHERE Token__c =  \'' + token + '\'';              
                 String jobName = 'SMS Order Update -' + String.ValueOf(Math.random());
    
                 SMS_OrderBatch updateOrder = new SMS_OrderBatch(query);
                 String cronID = System.scheduleBatch(updateOrder, jobName, 10);
                 showProcess = true;
                 
                 String encodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
                 
                 //iframeDomain = 'https://dev-mrisonboarding.cs9.force.com';
            
                 String path = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SMS_StaffOrder_Preview?id=' + subscriptionId + '&iframeDomain=' + iframeDomain;
                 redirectUrl = path;
                 cancelUrl = path;
                 path = EncodingUtil.urlEncode(path, 'UTF-8');
                 processURL = iframeDomain + '/SMS/SMS_GenericPaymentWrapper?token=' + encodedToken + '#' + path; 

                 SMS_ZuoraHistory.createSuccess('SMS_StaffOrder_Controller',subscriptionId);
             }
         } 
         catch(Exception e){
              SMS_ZuoraHistory.createError(e,'SMS_StaffOrder_Controller', subscriptionId);
         } 
         return null;
    }
    
    private Map<String,String> populateTRENDRatePlans(String productId){       
        
        system.debug('*** Get Rate Plans method is called');
        /* Get rate plans from zuora */
        SMS_ZuoraUtil zUtilInstance; 
        Zuora.zApi.LoginResult zLoginResult;
        List<Zuora.zObject> zObject;
        zUtilInstance = new SMS_ZuoraUtil();
        zLoginResult = zUtilInstance.zlogin();
                    
        String todayDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        String zoql = 'SELECT Id, Name, ProductId, IsOld__c FROM ProductRatePlan WHERE ProductId =\''+ productId +'\'' + ' AND EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;             
        zObject = zUtilInstance.zquery(zoql); 
        
        Map<String, String> finalRatePlans = new Map<String, String>();   
        
        for (Zuora.zObject zProductRatePlan : zObject) {            
            finalRatePlans.put((String)zProductRatePlan.getValue('Id'), (String)zProductRatePlan.getValue('Name'));            
        }
       
        return finalRatePlans;  

    }
    
    private Map<String, String> getProductRatePlans(String productId) {
        /* Product rate plan names */
        List<String> ratePlanNames = new List<String>{'Select', 'Agent IDX', 'Total', 'Premium', 'Office Website', 'Office IDX', 'realPING', 'Authentisign', 'CloudCMA', 'Social Pro', 'Sphere'};
        
        /* Check current provision status */
        List<SMS_Provisioned_Product__c> provProducts = new List<SMS_Provisioned_Product__c>();
        provProducts = [SELECT Id,Name,Product_Status_Reason__c,Product_Status__c,Product_Sub_Type__c,
                               Product_Type__c,Provisioned_Status__c,Status_Message__c,Zuora_Product_Rate_Plan_Id__c  
                               FROM   SMS_Provisioned_Product__c 
                               WHERE  MRIS_Subscription_Id__c =: subscription.Name
                               AND    Product_Type__c IN ('XactSite Agent','XactSite Office','MRIS XactSite Agent', 'MRIS XactSite Office', 'CloudCMA')];

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
                                   WHERE  MRIS_Subscription_Id__c =: subscription.Name
                                   AND    Product_Type__c IN ('XactSite Agent','XactSite Office','MRIS XactSite Agent', 'MRIS XactSite Office', 'CloudCMA')
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
        
        String todayDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        String zoql = 'SELECT Id, Name, ProductId, IsOld__c FROM ProductRatePlan WHERE ProductId =\''+ productId +'\'' + ' AND EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;             
        zObject = zUtilInstance.zquery(zoql); 
        /* For loop decide which rate plans needs to load either new or old */
        for (Zuora.zObject zProductRatePlan : zObject) {
            for(String ratePlanName : ratePlanNames) {
                if(((String)zProductRatePlan.getValue('Name')).contains(ratePlanName) && (String)zProductRatePlan.getValue('Id') == productProvRatePlans.get(ratePlanName) && (String)zProductRatePlan.getValue('IsOld__c') == 'true')
                    productProvRatePlans.put(ratePlanName, 'Old'); 
            }
        }
        System.debug('*** productProvRatePlans: ' + productProvRatePlans);
        
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
        System.debug('*** finalRatePlans: ' + finalRatePlans);
        return finalRatePlans;
    }
    
    public PageReference cancel() {
        PageReference subscriptionView = new ApexPages.StandardController(subscription).view();
        return subscriptionView;
    }
    
    public class CartItem {
        public String ProductId { get; set; }
        public String ProductName { get; set; }
        public String RecurringProductRatePlanId { get; set; }
        public String RecurringProductRatePlanName { get; set; }
        public String DiscountProductRatePlanId { get; set; }
        public String DiscountProductRatePlanName { get; set; }
        public String OneProductRatePlanId { get; set; }
        public String OneProductRatePlanName { get; set; }
        public Integer TermDuration { get; set; }
        public Boolean check { get; set; }
        
        public Integer InitialTerm { get; set; }
        public Integer RenewalTerm { get; set; }
        public Date ServiceActivationDate { get; set; }
    } 
}