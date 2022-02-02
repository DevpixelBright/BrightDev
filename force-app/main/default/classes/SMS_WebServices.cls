@RestResource(urlMapping='/GenericPayment/*')
global with sharing Class SMS_WebServices {
    @HttpPost
    global static CreateGenericPaymentOrderResponse CreateGenericPaymentOrder(InputData request) {         
        CreateGenericPaymentOrderResponse orderResponse = new CreateGenericPaymentOrderResponse();
        OrderResult orderDetails = new OrderResult();
        ResponseParameters result = new ResponseParameters();
        
        String zAccountId;
        String sSubscriptionId; 
         
        try {
            if(request == null) throw new CustomException('OrderRequest is Null'); 
            
            if (String.isBlank(request.ZuoraAccountId) && String.isBlank(request.MRISSubscriptionId )) 
                throw new CustomException('Zuora account id or MRIS SubscriptionId can not be null');            
            
            Boolean createOrder = true;
            List<SMS_OrderItem__c> orderItems = new List<SMS_OrderItem__c>();
            
            Map<String,String> zProductMap = new Map<String,String>();
            Map<String,String> zProductRatePlanMap = new Map<String,String>();
            Map<String,String> zProductRatePlanValidate = new Map<String,String>();
             
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            String accountQuery = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE Status = \'Active\' ';
            
            if (String.isNotBlank(request.ZuoraAccountId))
                accountQuery += 'AND Id = \'' + request.ZuoraAccountId + '\' ';
                
            if (String.isNotBlank(request.MRISSubscriptionId))
                accountQuery += 'AND SubscriptionID__c = \'' + request.MRISSubscriptionId + '\' ';
             
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
            if(!(zAccounts.Size() > 0))
                throw new CustomException('Invalid zuora account id');
                
            zAccountId = (String)zAccounts[0].getValue('Id');
            sSubscriptionId = (String)zAccounts[0].getValue('SubscriptionID__c');
            Subscriptions__c sSubscription = [SELECT id,Name,Private_Email__c FROM Subscriptions__c WHERE Name = :sSubscriptionId];            
            
            List<Zuora.zObject> zProducts = zUtilInstance.zquery('SELECT Id, Name FROM Product'); 
            for (Zuora.zObject zProduct : zProducts)             
                zProductMap.put((String)zProduct.getValue('Id'),(String)zProduct.getValue('Name'));
                
            List<Zuora.zObject> zProductRatePlans = zUtilInstance.zquery('SELECT Id, Name, ProductId FROM ProductRatePlan');
            for (Zuora.zObject zProductRatePlan : zProductRatePlans ) {             
                zProductRatePlanMap.put((String)zProductRatePlan.getValue('Id'),(String)zProductRatePlan.getValue('Name')); 
                zProductRatePlanValidate.put((String)zProductRatePlan.getValue('Id'),(String)zProductRatePlan.getValue('ProductId'));
            }                                   
               
            /*
            SMS_Order__c order = new SMS_Order__c();                
            order.Name = 'Order Id';
            order.Token__c = '';
            order.Zuora_Account_Id__c = zAccountId;
            order.MRIS_Subscription_Id__c = sSubscription.id;
            order.Status__c = 'Active';
            order.Bypass_Payment__c = request.StaffInitiate;
            order.Private_Email__c = sSubscription.Private_Email__c;
            order.IsEzJoinApplication__c = request.IsEzJoinApplication == null ? false : request.IsEzJoinApplication;
                
            insert order;
              
            String salt = String.valueOf(order.id);
            String secretKey = 'secret_key';
            String algorithmName = 'HmacSHA256';
                
            Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
            string token = EncodingUtil.base64Encode(hmacData);
            
            order.Token__c = token;
            order.Name = order.id;
            update order;
            */ 
            if(request.InputItems.Size() > 0) {            
                       
                DateTime effectiveDate = System.Now();     
                for(InputItem item : request.InputItems) {                
                    if (String.isBlank(zProductMap.get(item.ProductId)))
                        throw new CustomException('Invalid Zuora product id');
                        
                    String productName = zProductMap.get(item.ProductId );
                    
                    if(String.isBlank(item.OneTimeProductRatePlanId) && String.isBlank(item.RecurringProductRatePlanId) && String.isBlank(item.DiscountProductRatePlanId))
                        throw new CustomException('Invalid product rate plan id');
                    
                    if ((zProductRatePlanValidate.get(item.OneTimeProductRatePlanId) != item.ProductId ) && (zProductRatePlanValidate.get(item.RecurringProductRatePlanId) != item.ProductId ) && (zProductRatePlanValidate.get(item.DiscountProductRatePlanId) != item.ProductId ))
                        throw new CustomException('ProductRatePlanId does not correspond to ZuoraProductId');      
                    
                    
                    // Create a list of order items
                    SMS_OrderItem__c orderItem = new SMS_OrderItem__c();                   
                    
                    //orderItem.Order_Id__c = order.Id;
                      
                    orderItem.Bundle_Id__c = item.BundleId;
                    orderItem.Bundle_Name__c = item.BundleName;
                                                     
                    orderItem.Zuora_Product_Id__c = item.ProductId ;
                    orderItem.Zuora_Product_Name__c = productName;
                    
                    orderItem.OneTimeProductRatePlanId__c = item.OneTimeProductRatePlanId;
                    orderItem.OneTimeProductRatePlanName__c = zProductRatePlanMap.get(item.OneTimeProductRatePlanId);
                    
                    orderItem.RecurringProductRatePlanId__c = item.RecurringProductRatePlanId;
                    orderItem.RecurringProductRatePlanName__c = zProductRatePlanMap.get(item.RecurringProductRatePlanId);
                    
                    orderItem.DiscountProductRatePlanId__c = item.DiscountProductRatePlanId ;
                    orderItem.DiscountProductRatePlanName__c = zProductRatePlanMap.get(item.DiscountProductRatePlanId ); 
                    
                    orderItem.TermDuration__c = item.TermDuration;                              
                    orderItem.IsCore__c = Boolean.valueOf(item.IsCore);
                    if(item.TermDuration != null) {
                        orderItem.Initial_Term__c = item.TermDuration;
                        orderItem.Renewal_Term__c = item.TermDuration;     
                    }
                    else {
                        orderItem.Initial_Term__c = 12;
                        orderItem.Renewal_Term__c = 12;
                    }
                    orderItem.Contract_Effective_Date__c = effectiveDate;
                    orderItem.Service_Activation_Date__c = effectiveDate;
                    
                    if ( String.isBlank(item.OneTimeProductRatePlanId) && String.isBlank(item.RecurringProductRatePlanId) && String.isNotBlank(item.DiscountProductRatePlanId))
                        orderItem.IsDiscountOnly__c = true;  
                    
                    if(productName == 'CloudCMA' && !orderItem.IsDiscountOnly__c){
                        String productTypeCloudCMA;
                        String zRecurringProductRatePlanId = item.RecurringProductRatePlanId;
                        productTypeCloudCMA = SMS_CloudCMA.findCloudCMAType(sSubscription.Id);                   
                        
                        String ratePanChargeQuery = 'SELECT Id, Name, ChargeType, BillingPeriod FROM ProductRatePlanCharge WHERE ChargeType = \'Recurring\' AND ProductRatePlanId = \'' + zRecurringProductRatePlanId + '\'';
                        List<Zuora.zObject> ratePlanCharges = zUtilInstance.zquery(ratePanChargeQuery);
                        
                        String billingPeriod = (String)ratePlanCharges[0].getValue('BillingPeriod');
                        
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
                            else if(billingPeriod == 'Month') {
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
                            else if(billingPeriod == 'Month') {
                                orderItem.Initial_Term__c = 1;
                                orderItem.Renewal_Term__c = 1;                            
                            }
                        }
                        else if(productTypeCloudCMA == 'CloudCMA Paid'){
                            createOrder = false;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Already in CloudCMA. Contact CloudCMA for any modifications'));
                        }
                    }
                    
                    orderItems.add(orderItem);
                }
                
                //insert orderItems; 
            }
            
            if(createOrder){
                SMS_Order__c order = new SMS_Order__c();                
                order.Name = 'Order Id';
                order.Token__c = '';
                order.Zuora_Account_Id__c = zAccountId;
                order.MRIS_Subscription_Id__c = sSubscription.id;
                order.Status__c = 'Active';
                order.Bypass_Payment__c = request.StaffInitiate;
                order.Private_Email__c = sSubscription.Private_Email__c;
                order.IsEzJoinApplication__c = request.IsEzJoinApplication == null ? false : request.IsEzJoinApplication;
                    
                insert order;
                  
                String salt = String.valueOf(order.id);
                String secretKey = 'secret_key';
                String algorithmName = 'HmacSHA256';
                    
                Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
                string token = EncodingUtil.base64Encode(hmacData);
                
                order.Token__c = token;
                order.Name = order.id;
                update order;
                
                for(SMS_OrderItem__c orderItem : orderItems){
                    orderItem.Order_Id__c = order.Id;
                }
                
                insert orderItems; 
                
                //Schedule batch apex  will execute after ten minutes  after insert 
                     
                String query = 'SELECT Id,Status__c FROM SMS_Order__c WHERE Token__c =  \'' + token + '\'';              
                String jobName = 'SMS Order Update -' + String.ValueOf(Math.random());
    
                SMS_OrderBatch updateOrder = new SMS_OrderBatch(query);
                String cronID = System.scheduleBatch(updateOrder, jobName, 10);
                   
                String encodedToken = EncodingUtil.urlEncode(String.valueOf(token), 'UTF-8');
                   
                orderDetails.Token = encodedToken;
                orderDetails.Status = 'Pending Payment';     
                orderDetails.OrderID = order.id;
                result.status = 'Success'; 
                orderResponse.order = orderDetails;
            }
            else
                throw new CustomException('Already in CloudCMA. Contact CloudCMA for any modifications');
                
            SMS_ZuoraHistory.createSuccess('SMS_WebServices',sSubscriptionId);    
        }
        catch(Exception ex) {
            result.status= 'Failed';
            result.errorCode = '1000';
            result.errorDescription = ex.getMessage();
            SMS_ZuoraHistory.createError(ex,'SMS_WebServices',sSubscriptionId);
        }
        orderResponse.response = result;
        return orderResponse;
    } 
           
    global Class InputData {        
        WebService String ZuoraAccountId { get; set; } 
        WebService String MRISSubscriptionId{ get; set; } 
        WebService Boolean StaffInitiate { get; set; }
        WebService Boolean IsEzJoinApplication { get; set; }
        WebService List<InputItem> InputItems { get; set; }                   
    }
    
    global Class CreateGenericPaymentOrderResponse {
        WebService ResponseParameters response { get; set; }
        WebService OrderResult order { get; set; }    
    }
    
    global Class InputItem {
        WebService String BundleId { get; set; } 
        WebService String BundleName { get; set; }
        WebService  String ProductId { get; set; }
        WebService  String OneTimeProductRatePlanId { get; set; } 
        WebService  String RecurringProductRatePlanId { get; set; }
        WebService  String DiscountProductRatePlanId { get; set; }
        WebService  Integer TermDuration { get; set; }
        WebService  Boolean IsCore { get; set; }
    }
    
    global Class OrderResult {
        WebService String OrderID { get; private set; }
        WebService String Status{ get; private set; }
        WebService String Token { get; private set; }
    } 
    
    global Class ResponseParameters {
        WebService String Status { get; set; }
        WebService String errorCode { get; set; }
        WebService String errorDescription { get; set; }
    } 
        
    public Class CustomException extends Exception {}   
    
}