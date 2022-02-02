public with sharing class RETS_ProductOrder_Billing {
    
    public static SMS_ZuoraUtil zUtilInstance; 
    public static  Zuora.zApi.LoginResult zLoginResult;
    public static List<Zuora.zApi.SubscribeRequest> subRequestList;
    public static List<Zuora.zApi.AmendRequest> amendRequestList;
    public static String zAccId {get;set;}
    public static String zSubId {get;set;}
    public Static String sSubscription {get;set;}
    private Static List<String> zSubscriptionIDs;
    public static RETS_Product_Order__c order {get;set;}
    
    public static final String AGENT ='Agent';
    public static final String BROKERAGE ='Brokerage';
    public static final String VENDOR ='Vendor';
    
    public static decimal newQuantity {get;set;}
    public static boolean isVendorDiscounted {get;set;}
    public static boolean isVendor {get;set;}
    
    public static String subcontractorProductRatePlanId {get;set;}
    public static String enterpriseProductRatePlanId {get;set;}
    public static String brokerageProductRatePlanId {get;set;}
    public static String agentProductRatePlanId {get;set;}
    public static String agentOldProductRatePlanId {get;set;}
    
    public static String vendorDiscountRatePlanId {get;set;}
    public static String zRateplanId {get;set;}
    public static String invoiceResponsejson {get;set;}
    public static Decimal agentQuantity {get;set;}
    public static Decimal brokerageQuantity {get;set;}
    
    public static List<RETS_Product_Order__c > lstOrders {get;set;}
    public static boolean isamendmentonOldPrice;
    
    public RETS_ProductOrder_Billing (){
        invoiceResponsejson = ApexPages.currentPage().getParameters().get('id');
    }   
    
    Public static void init(String ordId){
        system.debug('*** ordId: ' + ordId);
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin();
        subRequestList  = new List<Zuora.zApi.SubscribeRequest>();
        amendRequestList = new List<Zuora.zApi.AmendRequest>();
        zSubscriptionIDs = new List<String>();
        order = new RETS_Product_Order__c();
        subcontractorProductRatePlanId = RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductRatePlanId__c;
        enterpriseProductRatePlanId = RETS_Rate_Plan__c.getInstance('Enterprise').Zuora_ProductRatePlanId__c;
        brokerageProductRatePlanId = RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductRatePlanId__c;
        agentProductRatePlanId = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanId__c;
        agentOldProductRatePlanId = RETS_Rate_Plan__c.getInstance('Agent - Old Price').Zuora_ProductRatePlanId__c;
        vendorDiscountRatePlanId = RETS_Rate_Plan__c.getInstance('Discount').Zuora_ProductRatePlanId__c;
        isamendmentonOldPrice = false;
        
        
        lstOrders = [Select id, name, Agent__c, Agent_Office__c, Brokerage__c, End_Date__c, Is_External_Billing__c,URL__c,Agent__r.Name,Status_Reason__c,
                     On_Behalf_of_Agent__c, RETS_Sub_Product__c,RETS_Sub_Product__r.Name__c,On_Behalf_of_Agent__r.CUSTOMERNAME__c, Start_Date__c, Status__c, Vendor_Order_Description__c, 
                     Vendor_Product__c,Vendor_Product__r.RETS_BillingHasFullDiscount__c,Vendor_Product__r.RETS_Billing_Type__c
                     From RETS_Product_Order__c Where id = :ordId];
        
    }
    
    @Future(callout = true) 
    Public static void createOrUpdateVendorSubscription(string ordId){
        try{
            init(ordId);
            RETS_Product_Order__c orderUpdate = new RETS_Product_Order__c();
            
            if( lstOrders.size()>0)
                order = lstOrders[0]; 
            
            orderUpdate.Id = ordId;         
            
            String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00');
            if(order.Status__c == 'Active' && order.Start_Date__c != null){
                effectiveDate = order.Start_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
            }
            
            String zProdID = '';
            String zProductRatePlanId = ''; 
            String zProductRatePlanChargeId='';
            
            String description = ''; 
            ID crmId = order.Vendor_Product__c;
            
            /* Updating the quantity only if the order is for Brokerage */
            
            getZuoraDetails(crmId,VENDOR);
            
            if(order.Vendor_Product__r.RETS_Billing_Type__c  == 'Subcontractor'){
                
                Decimal finalQuantity = getSubcontractorCount(crmId);
                
                if(order.Brokerage__c != null){
                    
                    if(finalQuantity == 0){
                        description = 'No products';
                    }
                    if(finalQuantity == 1){
                        description = finalQuantity + ' Brokerage';
                    }else{
                        description = finalQuantity + ' Brokerages';
                    }
                }
                
                
                zProdID = RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductId__c;
                zProductRatePlanId = RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductRatePlanId__c;
                zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('Subcontractor').Zuora_ProductRatePlanChargeId__c;
                Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zSubId,zProductRatePlanId,zProductRatePlanChargeId,finalQuantity,description ,effectiveDate,VENDOR );
                system.debug('Product update amendRequest :' + amendrequest );
                amendRequestList.add(amendrequest);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                
                if(!amendResults.Success){
                    orderUpdate.ZuoraVendorProductIntegrationStatus__c = 'Failure';
                    orderUpdate.ZuoraVendorIntegrationStatusMessage__c = 'Error occured while amending the quantity request for Vendor.';
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors) 
                        orderUpdate.ZuoraVendorIntegrationStatusMessage__c = orderUpdate.ZuoraVendorIntegrationStatusMessage__c + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                    
                }
                else{
                    orderUpdate.ZuoraVendorProductIntegrationStatus__c = 'Success';
                    orderUpdate.ZuoraVendorIntegrationStatusMessage__c = 'Success';
                }
                
                amendRequestList.clear();
                system.debug('Amend Results :' + amendResults);
                
            }else if (order.Vendor_Product__r.RETS_Billing_Type__c  == 'Enterprise'){
                Decimal finalQuantity = getEnterpriseCount(crmId);
                //Decimal finalQuantity = quantity + newquantity;
                if(finalQuantity == 0){
                    description = 'No products';
                }
                if(finalQuantity == 1){
                    description = finalQuantity + ' Brokerage';
                }else{
                    description = finalQuantity + ' Brokerages';
                }
                
                if(order.Brokerage__c != null){
                    zProdID = RETS_Rate_Plan__c.getInstance('Enterprise').Zuora_ProductId__c;
                    zProductRatePlanId = RETS_Rate_Plan__c.getInstance('Enterprise').Zuora_ProductRatePlanId__c;
                    zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('Enterprise').Zuora_ProductRatePlanChargeId__c;
                    
                    Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zSubId,zProductRatePlanId,zProductRatePlanChargeId,finalQuantity,description ,effectiveDate,VENDOR );
                    system.debug('Product update amendRequest :' + amendrequest );
                    amendRequestList.add(amendrequest);
                    Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                    
                    if(!amendResults.Success){
                        orderUpdate.ZuoraVendorProductIntegrationStatus__c = 'Failure';
                        orderUpdate.ZuoraVendorIntegrationStatusMessage__c = 'Error occured while amending the quantity request for Vendor.';
                        Zuora.zObject[] errors = amendResults.errors;
                        for (Zuora.zObject error : errors) 
                            orderUpdate.ZuoraVendorIntegrationStatusMessage__c = orderUpdate.ZuoraVendorIntegrationStatusMessage__c + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                        
                    }
                    else{
                        orderUpdate.ZuoraVendorProductIntegrationStatus__c = 'Success';
                        orderUpdate.ZuoraVendorIntegrationStatusMessage__c = 'Success';
                    }
                    
                    amendRequestList.clear();
                    system.debug('Amend Results :' + amendResults);
                }
            }
            update orderUpdate;
            
            
        }catch (Exception e){
            system.debug('error message '+e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'RETS_ProductOrder_Billing, Vendor: ' + ordId, null);
        }
    }
    
    @Future(callout = true)
    Public static void createOrUpdateBrokerageSubscription(string ordId){
        try{
            init(ordId);            
            
            RETS_Product_Order__c orderUpdate = new RETS_Product_Order__c();
            
            if( lstOrders.size()>0)
                order = lstOrders[0]; 
            
            orderUpdate.Id = ordId;
            
            
            String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00');
            if(order.Status__c == 'Active' && order.Start_Date__c != null){
                effectiveDate = order.Start_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
            }
            
            String zProdID = '';
            String zProductRatePlanId = ''; 
            String zProductRatePlanChargeId='';
            String description = '';  
            String prefix_string = '';
            ID crmId = order.Brokerage__c;
            
            
            /* Updating the quantity only if the order is for Brokerage */
            if(order.Brokerage__c != null){
                
                zProdID = RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductId__c;
                zProductRatePlanId = RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductRatePlanId__c;
                zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('BrokerageOffice').Zuora_ProductRatePlanChargeId__c;
                
                
                getZuoraDetails(crmId,BROKERAGE);
                
                
                //Decimal finalQuantity = getBrokerageCount(crmId);
                
                String per_description = generateBrokerageInvoiceDescription(crmId); 
                
                
                // Decimal finalQuantity = quantity + newquantity;
                if(brokerageQuantity == 0){
                    prefix_string = 'No products';
                }
                if(brokerageQuantity == 1){
                    prefix_string = brokerageQuantity + ' product';
                }
                else {
                    prefix_string = brokerageQuantity + ' products';                          
                }
                
                description = prefix_string + per_description;
                
                
                if((brokerageQuantity == 1 || brokerageQuantity == 0) && zRateplanId == null){
                    Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccId,zProductRatePlanId,zProductRatePlanChargeId,description,brokerageQuantity,effectiveDate,BROKERAGE);
                    subRequestList.add(request);
                    List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
                    
                    for(Zuora.zApi.SubscribeResult result : results){
                        if(!result.Success){
                            orderUpdate.ZuoraIntegrationStatus__c = 'Failure';
                            orderUpdate.ZuoraIntegrationStatusMessage__c = 'Failed to create zuora subscription for Brokerage.';
                            Zuora.zObject[] errors = result.errors;
                            for (Zuora.zObject error : errors) 
                                orderUpdate.ZuoraIntegrationStatusMessage__c = orderUpdate.ZuoraIntegrationStatusMessage__c + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                            
                        }
                        
                        else {
                            orderUpdate.ZuoraIntegrationStatus__c = 'Success';
                            orderUpdate.ZuoraIntegrationStatusMessage__c = 'Success';
                            orderUpdate.ZuoraSubscriptionID__c = result.SubscriptionId;
                        }
                    }
                    
                    
                    system.debug('*** Subscription Results :' + results);
                }
                else if((brokerageQuantity == 0 && zRateplanId != null) || brokerageQuantity > 0){
                    
                    Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zSubId,zProductRatePlanId,zProductRatePlanChargeId,brokerageQuantity,description ,effectiveDate,BROKERAGE );
                    system.debug('Product update amendRequest :' + amendrequest );
                    amendRequestList.add(amendrequest);
                    Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                    if(!amendResults.Success){
                        orderUpdate.ZuoraIntegrationStatus__c = 'Failure';
                        orderUpdate.ZuoraIntegrationStatusMessage__c = 'Error occured while amending the quantity request for Brokerage.';
                        Zuora.zObject[] errors = amendResults.errors;
                        for (Zuora.zObject error : errors) 
                            orderUpdate.ZuoraIntegrationStatusMessage__c = orderUpdate.ZuoraIntegrationStatusMessage__c + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                        
                    }
                    
                    else{
                        orderUpdate.ZuoraIntegrationStatus__c = 'Success';
                        orderUpdate.ZuoraIntegrationStatusMessage__c = 'Success';
                        orderUpdate.ZuoraSubscriptionID__c = amendResults.SubscriptionId;
                    }
                    
                    
                    amendRequestList.clear();
                    system.debug('Amend Results :' + amendResults);                    
                }
                
                update orderUpdate;
            } 
        }catch (Exception e){
            system.debug('error message '+e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'RETS_ProductOrder_Billing, Brokerage: ' + ordId, null);
        }
    }
    
    @Future(callout= true)
    Public static void createOrUpdateAgentSubscription(string ordId){
        system.debug('**** in createOrUpdateAgentSubscription method');
        try{
            String zProdID = '';
            String zProductRatePlanId = ''; 
            String zProductRatePlanChargeId='';
            String prefix_string;  
            String per_description= '';
            String description= '';
            
            init(ordId);
            
            
            RETS_Product_Order__c orderUpdate = new RETS_Product_Order__c();
            
            if( lstOrders.size()>0)
                order = lstOrders[0]; 
            
            orderUpdate.Id = ordId;
            
            Subscriptions__c subs = [SELECT ID,name, Date_Terminated__c,(SELECT id, name, start_date__c FROM RETS_Product_Orders__r WHERE Status__c = 'Active' Order by start_date__c desc) from subscriptions__c where id =: order.Agent__c];
            sSubscription = subs.Name;
            
            String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00');
            if(order.Status__c == 'Active' && order.Start_Date__c != null){
                effectiveDate = order.Start_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
            }
            else if(order.Status__c == 'Inactive'){
                if(order.Status_Reason__c == 'Misreported'){
                    effectiveDate = order.End_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
                    system.debug('effectiveDate :' + effectiveDate);
                    if(order.Start_Date__c.format('yyyy-MM-dd\'T\'00:00:00') == DateTime.newInstance(2018, 01, 01).format('yyyy-MM-dd\'T\'00:00:00'))
                        isamendmentonOldPrice = true;
                }
                else if( order.Status_Reason__c == 'Cancelled by Vendor' || order.Status_Reason__c == 'Cancelled by Subscriber'){                    
                    effectiveDate = order.End_Date__c.format('yyyy-MM-dd\'T\'00:00:00');
                }
                else if(order.Status_Reason__c == 'Subscriber Auto Suspended'){
                   effectiveDate = order.End_Date__c.format('yyyy-MM-dd\'T\'00:00:00'); 
                }
                
            } 
            
            /* Updating the quantity only if the order is for Agent*/
            if(order.Agent__c != null){       
                
                /*if misreported for orders with start date as Jan 1st, amendment should be created for old price subscription*/
                if(isamendmentonOldPrice){
                    zProdID = RETS_Rate_Plan__c.getInstance('Agent - Old Price').Zuora_ProductId__c;
                    zProductRatePlanId = RETS_Rate_Plan__c.getInstance('Agent - Old Price').Zuora_ProductRatePlanId__c;
                    zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('Agent - Old Price').Zuora_ProductRatePlanChargeId__c;
                    getZuoraDetails(sSubscription);
                    orderUpdate = handleAgentAmendments(zProductRatePlanId,zProductRatePlanChargeId,effectiveDate,orderUpdate);
                }
                
                /* Adjusting quantity for inactive or misreported for orders whose start date is not in january. */
                if(!isamendmentonOldPrice){
                    if(effectiveDate == DateTime.newInstance(2018, 01, 01).format('yyyy-MM-dd\'T\'00:00:00'))
                        effectiveDate = DateTime.newInstance(2018, 02, 01).format('yyyy-MM-dd\'T\'00:00:00');
                    
                    zProdID = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductId__c;
                    zProductRatePlanId = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanId__c;
                    zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance('Agent').Zuora_ProductRatePlanChargeId__c;
                    getZuoraDetails(sSubscription,AGENT);
                    orderUpdate = handleAgentAmendments(zProductRatePlanId,zProductRatePlanChargeId,effectiveDate,orderUpdate);
                }
                
            }
            update orderUpdate;
        }catch (Exception e){
            system.debug('error message: '+ e + e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'RETS_ProductOrder_Billing, Agent: ' + ordId, null);
        }
    }
    
    private static void getZuoraDetails(String uniqueid,String type){
        String uid ='';
        if (type != AGENT)
            uid = uniqueid.substring(0, 15);
        Decimal quantity = 0;
        // String zRateplanId;
        Integer i = 0;
        String accountQuery = 'SELECT Id,Name FROM Account WHERE ';
        if (type == AGENT)
            accountQuery += ' SubscriptionID__c = \'' + uniqueid + '\'';
        else
            accountQuery += ' CrmId LIKE \'' + uid + '%\'';
        //accountQuery += ' CrmId = \'' + uid + '\' OR  CrmId = \'' + uniqueid + '\'';
        system.debug('***accountQuery'+accountQuery);
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        if (!(zAccounts.Size() == 1)) 
            throw new CustomException('Zuora account does not exist'); 
        
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        String currentDate = DateTime.now().format('yyyy-MM-dd');
        
        String subQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, Status FROM Subscription WHERE AccountId = \'' + zAccId + '\' AND IsCore__c = false AND AutoRenew = true AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        if(type == VENDOR){
            if (!(zSubscriptions.Size() > 0)) 
                throw new CustomException('Zuora subscription does not exist'); 
        }
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            system.debug('****'+zSubscription.getValue('Id'));
            zSubscriptionIDs.add(String.valueOf(zSubscription.getValue('Id')));
        }
        
        
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        system.debug('****ratePlansQuery'+ratePlansQuery);
        for (String zSubscriptionId : zSubscriptionIDs) {
            if (i != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            i++;
        }
        system.debug('***Rate plan qury is '+ratePlansQuery);
        if(i != 0){
            system.debug('subcontractorProductRatePlanId*** '+subcontractorProductRatePlanId);
            system.debug('enterpriseProductRatePlanId*** '+enterpriseProductRatePlanId);
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);
            if (!(zRateplans.Size() > 0)) 
                throw new CustomException('Zuora Rateplan not found');
            system.debug('***zRatePlans '+zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {
                if(type == VENDOR){
                    if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == subcontractorProductRatePlanId ){
                        system.debug('***subcontractorProductRatePlanId ');
                        zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                        zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                        break;
                    }
                    else if (zRatePlan.getValue('ProductRatePlanId') == enterpriseProductRatePlanId ){
                        system.debug('***enterpriseProductRatePlanId ');
                        zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                        zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                        break;
                    }   
                }else if (type == BROKERAGE){
                    system.debug('***brokerage ');
                    if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == brokerageProductRatePlanId ){
                        zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                        zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                        break;
                    }
                } else if (type == AGENT){
                    if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == agentProductRatePlanId ){
                        system.debug('***agent ');
                        zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                        zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                        break;
                    }
                }
            }
        }
        system.debug('****zRateplanId  '+zRateplanId);
        system.debug('***zsubID   '+zsubID);
        /* if(zRateplanId != null ){
String ratePlanChargeQuery = 'SELECT ID,Quantity from RatePlanCharge where RatePlanId =\''+zRateplanId+'\'';
List<Zuora.zObject> zRateplanCharge = zUtilInstance.zquery(ratePlanChargeQuery);
system.debug('***zRateplanCharge   '+zRateplanCharge);
if (!(zRateplanCharge.Size() > 0)) 
quantity = 0;
else
quantity = (Decimal)zRateplanCharge[0].getValue('Quantity');
system.debug('quantity is : '+quantity);
}*/
        
        
    }
    
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId,String zProductRatePlanChargeId,String description,Decimal quantity, String serviceActivationDate, String type) {
        
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
        

        request.ZAccount.setValue('Id', zAccountId);
        
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = false;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', serviceActivationDate);
        subscription.setValue('ServiceActivationDate', serviceActivationDate);
        subscription.setValue('TermType', 'TERMED');
        
        if(type == AGENT){
            subscription.setValue('InitialTerm', '1');
            subscription.setValue('RenewalTerm', '1');
        }
        else{
            subscription.setValue('InitialTerm', '12');
            subscription.setValue('RenewalTerm', '12');
        }
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', false);
        
        request.SubscriptionData.Subscription = subscription;
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');       
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);        
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
        ratePlanCharge.setValue('Description', description);
        ratePlanCharge.setValue('Quantity', quantity);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
        
        ratePlanDataList.add(ratePlanData);
        
        /* if(order.Vendor_Product__r.RETS_BillingHasFullDiscount__c && type == VENDOR ){
Zuora.zObject discountPlan = new Zuora.zObject('RatePlan');
discountPlan.setValue('ProductRatePlanId', vendorDiscountRatePlanId);
Zuora.zObject discountRatePlanData = new Zuora.zObject('RatePlanData');
discountRatePlanData.setValue('RatePlan', discountPlan);
// ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
ratePlanDataList.add(discountRatePlanData);
}*/
        
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
        
        return request;                 
    }
    
    private Static Zuora.zApi.AmendRequest getProductAmendmentRequest(String zSubscriptionId,String zProductRatePlanId,String zProductRatePlanChargeId,Decimal quantity,String description, String effectiveDate, String type ) {
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);        
        ratePlan.setValue('AmendmentSubscriptionRatePlanId',zRateplanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
        ratePlanCharge.setValue('Description', description);
        ratePlanCharge.setValue('Quantity', quantity);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
        ratePlanDataList.add(ratePlanData);
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Update Product quantity');
        amendment.setValue('SubscriptionId',zSubscriptionId);
        
        amendment.setValue('Type', 'UpdateProduct');
        amendment.setValue('RatePlanData',ratePlanData);
        
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = false;        
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    }
    /*
private Static Zuora.zApi.AmendRequest getAutoRenewAmendmentRequest(String zSubscriptionId, Boolean autoRenew,String effectiveDate){
Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
request.Amendments = new List <Zuora.zObject>();    


Zuora.zObject amendment = new Zuora.zObject('Amendment');
amendment.setValue('Name', 'Set Auto Renew to ' + autoRenew);
amendment.setValue('SubscriptionId', zSubscriptionId );

amendment.setValue('Type', 'TermsAndConditions');
amendment.setValue('AutoRenew', autoRenew);

amendment.setValue('Status', 'Completed');
amendment.setValue('ContractEffectiveDate', effectiveDate);
amendment.setValue('EffectiveDate', effectiveDate);
amendment.setValue('ServiceActivationDate', effectiveDate);            

request.Amendments.add(amendment);

request.AmendOptions = new Zuora.zApi.AmendOptions();
//if (Utils.BypassValidationrules())
request.AmendOptions.generateInvoice = false;
//else
//request.AmendOptions.generateInvoice = true;
request.AmendOptions.processPayments = false;

request.PreviewOptions = new Zuora.zApi.PreviewOptions();
request.PreviewOptions.EnablePreviewMode = false;

return request;
} 
*/
    /* public static void attachInvoicesToAccount(String ZAccountId,String parentId){
invoiceResponsejson = SMS_UpdateZInvoice.getInvoicesFromZuora(ZAccountId);
system.debug('invoiceResponsejson '+invoiceResponsejson);
PageReference pdf = Page.RETS_InvoicePDF;
pdf.getParameters().put('id',invoiceResponsejson);
Attachment attach = new Attachment();
Blob body;

body = pdf.getContent();
system.debug('body '+body);
attach.Body = body;
attach.Name = 'RETS-INVOICE.pdf';
attach.IsPrivate = false;
attach.ParentId = parentId;
insert attach;

// send email
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

// Create the email attachment
Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
efa.setFileName('RETSInvoicePDF.pdf');
efa.setBody(body);

list<string> toAddresses = new list<string>();
toAddresses.add('test.mrisblt@gmail.com');
string subject = 'Test';
email.setSubject( subject );
email.setToAddresses( toAddresses );
email.setPlainTextBody( 'test email' );
email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
}*/
    
    public static String generateAgentInvoiceDescription(String sSubscription){
        List<RETS_Product_Order__c> agent_order = [SELECT ID,RETS_Sub_Product__r.Name__c,On_Behalf_of_Agent__c,Agent__r.Name,
                                                   On_Behalf_of_Agent__r.CUSTOMERNAME__c,URL__c, Vendor_Product__r.Account_Name__c 
                                                   from RETS_Product_Order__c
                                                   where Agent__r.Name = :sSubscription and status__c = 'Active' 
                                                   and Is_External_Billing__c = false and RETS_Billing_Exclusion__c excludes ('Agent') order by createdDate desc];
        
        agentQuantity = agent_order.size();
        String description = '';
        for (RETS_Product_Order__c order : agent_order ){
            system.debug('****description.length() '+description.length());
            String subName = order.Vendor_Product__r.Account_Name__c;
            if(String.isNotBlank(order.RETS_Sub_Product__r.Name__c))
                subName = order.RETS_Sub_Product__r.Name__c;
            
            if(order.On_Behalf_of_Agent__c != null){
                description+= ' // - ' + subName  + ' , for ' + order.On_Behalf_of_Agent__r.CUSTOMERNAME__c ;
            }else if(order.URL__c != null){
                description += ' // - ' + subName +' , ' + order.URL__c;
            }else if (order.On_Behalf_of_Agent__c == null && order.URL__c == null){
                description += ' // - ' + subName;
            }    
            if(description.length() > 450){
                
                description = description.substring(0, 447) + ' ...';
                break;
            }
        }
        system.debug('description is '+description);
        system.debug('description.length()---'+description.length());
        return description;
        
    }
    
    
    public static Decimal getEnterpriseCount(String vendorId){
        Decimal quantity = [SELECT count() from RETS_Product_Order__c
                            where Vendor_Product__c = :vendorId and status__c = 'Active' 
                            and Is_External_Billing__c = false and RETS_Billing_Exclusion__c excludes ('Vendor') 
                            and Brokerage__c != null];
        
        
        return quantity;
    }
    public static Decimal getSubcontractorCount(String vendorId){
        Decimal quantity = [SELECT count() from RETS_Product_Order__c
                            where Vendor_Product__c = :vendorId and status__c = 'Active' 
                            and Is_External_Billing__c = false and RETS_Billing_Exclusion__c excludes ('Vendor') 
                           ];
        
        
        return quantity;
    }
    
    public static String generateBrokerageInvoiceDescription(String brokergeId){
        List<RETS_Product_Order__c> brokerage_order = [SELECT ID,RETS_Sub_Product__r.Name__c,Brokerage__c,Brokerage__r.Name,
                                                       On_Behalf_of_Agent__r.CUSTOMERNAME__c,URL__c, Vendor_Product__r.Account_Name__c 
                                                       from RETS_Product_Order__c
                                                       where Brokerage__c = :brokergeId and status__c = 'Active' 
                                                       and Is_External_Billing__c = false and RETS_Billing_Exclusion__c excludes ('Brokerage') order by createdDate desc];
        
        brokerageQuantity = brokerage_order.size();
        String description = '';
        for (RETS_Product_Order__c order : brokerage_order ){
            system.debug('****description.length() '+description.length());
            String subName = order.Vendor_Product__r.Account_Name__c;
            if(String.isNotBlank(order.RETS_Sub_Product__r.Name__c))
                subName = order.RETS_Sub_Product__r.Name__c;
            
            if(order.URL__c != null){
                description += ' // - ' + subName +' , ' + order.URL__c;
            }else {
                description += ' // - ' + subName;
            }    
            if(description.length() > 450){
                
                description = description.substring(0, 447) + ' ...';
                break;
            }
        }
        system.debug('description is '+description);
        system.debug('description.length()---'+description.length());
        return description;
        
    }
    
    private Static Zuora.zApi.AmendRequest zeroQuantityCancelSub(String zSubscriptionId){ //, Decimal quantity, String description, String effectiveDate, String type ) {
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil(); 
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
        List<Zuora.zApi.AmendRequest> amendRequestList = new List<Zuora.zApi.AmendRequest>();
        system.debug('=====cencel sub===='+zSubscriptionId);
        
        String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST');
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Zero quantity cancel amendment');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        amendment.setValue('Type', 'Cancellation');
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = false;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        return request;
    }
    
    
    private static void getZuoraDetails(String agentId){
        String accountQuery = 'SELECT Id,Name FROM Account WHERE SubscriptionID__c = \'' + agentId + '\'';
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        if (!(zAccounts.Size() == 1)) 
            throw new CustomException('Zuora account does not exist'); 
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        
        String subQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, Status FROM Subscription WHERE AccountId = \'' + zAccId + '\' AND IsCore__c = false '; // AND AutoRenew = true AND Status=\'Active\'
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            system.debug('****'+zSubscription.getValue('Id'));
            zSubscriptionIDs.add(String.valueOf(zSubscription.getValue('Id')));    
        }
        for(String zSubscriptionId : zSubscriptionIDs){
            String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE AmendmentType !=null AND ProductRatePlanId=\''+agentOldProductRatePlanId+'\' AND SubscriptionId =\''+zSubscriptionId+'\''; 
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);
            for(Zuora.zObject zRatePlan : zRatePlans) {
                zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
            }
        }
        system.debug('**** zRateplanId : '+zRateplanId);
        system.debug('**** zRateplanId : '+zsubID);
    }
    
    public static RETS_Product_order__c handleAgentAmendments(String zProductRatePlanId,String zProductRatePlanChargeId,String effectiveDate, RETS_Product_order__c orderUpdate){
        String prefix_string;  
        String description= '';
        String per_description = generateAgentInvoiceDescription(sSubscription); 
        
        if(agentQuantity == 0){
            prefix_string = 'No products';
        }
        if(agentQuantity == 1){
            prefix_string = agentQuantity + ' product';
        }
        else {
            prefix_string = agentQuantity + ' products';                          
        }
        
        description = prefix_string + per_description;      
        system.debug('--agentQuantity-->'+agentQuantity+'--zRateplanId-->'+zRateplanId); 
        
        if((agentQuantity == 0 || agentQuantity == 1)  && zRateplanId == null){    
            Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccId,zProductRatePlanId,zProductRatePlanChargeId,description,agentQuantity,effectiveDate,AGENT);
            subRequestList.add(request);
            List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
            for(Zuora.zApi.SubscribeResult result : results){
                if(!result.Success){
                    orderUpdate.ZuoraIntegrationStatus__c = 'Failure';
                    orderUpdate.ZuoraIntegrationStatusMessage__c = 'Failed to create zuora subscription for Brokerage.';
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) 
                        orderUpdate.ZuoraIntegrationStatusMessage__c = orderUpdate.ZuoraIntegrationStatusMessage__c + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                }
                else {
                    orderUpdate.ZuoraIntegrationStatus__c = 'Success';
                    orderUpdate.ZuoraIntegrationStatusMessage__c = 'Zuora subscription created succesfully';
                    orderUpdate.ZuoraSubscriptionID__c = result.SubscriptionId;
                }
            }
            system.debug('*** Subscription Results :' + results); 
            
        }else if((agentQuantity == 0 && zRateplanId != null) || agentQuantity > 0){ 
            
            Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zSubId,zProductRatePlanId,zProductRatePlanChargeId,agentQuantity,description ,effectiveDate, AGENT);
            system.debug('Product update amendRequest :' + amendrequest );
            amendRequestList.add(amendrequest);
            Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
            if(!amendResults.Success){
                orderUpdate.ZuoraIntegrationStatus__c = 'Failure';
                orderUpdate.ZuoraIntegrationStatusMessage__c = 'Error occured while amending the quantity request for Agent.';
                Zuora.zObject[] errors = amendResults.errors;
                for (Zuora.zObject error : errors) 
                    orderUpdate.ZuoraIntegrationStatusMessage__c = orderUpdate.ZuoraIntegrationStatusMessage__c + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
            }    
            else{
                orderUpdate.ZuoraIntegrationStatus__c = 'Success';
                orderUpdate.ZuoraIntegrationStatusMessage__c = 'Success';
                orderUpdate.ZuoraSubscriptionID__c = amendResults.SubscriptionId;
                system.debug('---amendResults.SubscriptionId--'+amendResults.SubscriptionId);
                if(agentQuantity == 0 && !isamendmentonOldPrice){
                    amendrequest = new Zuora.zApi.AmendRequest();
                    amendrequest = zeroQuantityCancelSub(amendResults.SubscriptionId);
                    system.debug('---amendrequest---'+amendrequest);
                    
                    amendRequestList.clear();
                    amendRequestList.add(amendrequest);
                    amendResults = new Zuora.zApi.AmendResult();
                    amendResults = zUtilInstance.zamend(amendRequestList);
                    system.debug('Amend Result '+amendResults);
                    if(!amendResults.Success){
                        orderUpdate.ZuoraIntegrationStatus__c = 'Failure';
                        orderUpdate.ZuoraIntegrationStatusMessage__c = 'Error occured while Subscription cancel request for Agent.';
                        Zuora.zObject[] errors = amendResults.errors;
                        for (Zuora.zObject error : errors) 
                            orderUpdate.ZuoraIntegrationStatusMessage__c = orderUpdate.ZuoraIntegrationStatusMessage__c + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                    }
                    amendRequestList.clear();
                }
            }
            amendRequestList.clear();
            system.debug('Amend Results :' + amendResults);
        }
        if(isamendmentonOldPrice)
            isamendmentonOldPrice= false;
        
        if(orderUpdate.ZuoraIntegrationStatus__c != 'Failure' && orderUpdate.ZuoraIntegrationStatus__c != 'Success')
            orderUpdate.ZuoraIntegrationStatus__c = 'Skipped for Agent or Brokerage';
        return orderUpdate;
        
    }
    public Class CustomException extends Exception {} 
}