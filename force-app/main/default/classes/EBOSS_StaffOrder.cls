public class EBOSS_StaffOrder { 
    
    private SMS_ZuoraUtil zUtilInstance; 
    private Zuora.zApi.LoginResult zLoginResult;
    public List<Zuora.zObject> zObject;
    
    public Boolean isPreview;
    
    public List<SelectOption> productTypes { get; set; }    
    public List<SelectOption> zProductRatePlans { get; set; }
    public List<SelectOption> zOnetimeRatePlans { get; set; }
    Map<String, Zuora.zObject> zProductRatePlanIdObject { get; set; }
    Map<String, Zuora.zObject> zProductRatePlanChargeIdObject { get; set; }
    Map<String, String> zRatePlanChargeMap { get; set; }
    
    public String zAmendRatePlanId { get; set; }
    public String zAmendSubscriptionId { get; set; }
    
    private String subscriptionId;   
    public Subscriptions__c subscription {get; set;}
    public String zAccountId { get; set; }
    public Boolean hasCoreEB { get; set; }
    public Set<String> eligibleProducts { get; set; }
    public String existingCoreEBRecurringRatePlanId { get; set; }  
    public String terminateProductType { get; set; }
    public String updateProductType { get; set; }
    public Boolean isTerminate { get; set; }
    public Boolean isUpdate { get; set; }
    public Boolean isOrder { get; set; }
    public Boolean isBilling { get; set; }
    
    public String zProductType { get; set; }
    public String zRecurringProductRatePlanId { get; set; }
    public String zOneTimeProductRatePlanId { get; set; }
    public Integer quantity { get; set; }
    
    public Map<String, EB_ProductOrder__c> currentProductTypes { get; set; }
    public Invoice invoiceDetails { get; set; }
    
    
    public EBOSS_StaffOrder() {       
        subscriptionId = ApexPages.currentpage().getparameters().get('id');
        quantity = 0;
        isPreview = true;
        isUpdate = false;
        isTerminate = false;
        isBilling = false;
        
        if(String.isBlank(subscriptionId ))
            throw new CustomException('Invalid Operation');
        subscription = new Subscriptions__c();
        try {             
            List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                subscriptions = [SELECT id,Name,Contact__r.Name,
                            Related_Location_Broker_Office__r.Name,
                            Contact__c,
                            Contact_Type__c,
                            Subscription_Type__c,                             
                            Private_Email__c
                            FROM Subscriptions__c 
                            WHERE Name = :subscriptionId 
                            AND   Status__c = 'Active'
                           ];                                                    
            
            system.debug('*** subscription Id :' + subscription.Name);
            if(subscriptions.size() > 0)
                subscription = subscriptions[0];
            else
                throw new CustomException('Subscription is not Active');  
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [Select Id, name, Status__c 
                             From Relationship__c 
                             Where Subscription__r.Id = :subscription.Id 
                             AND  Relationship_Type__c IN ('Broker Of Record','Office Manager')
                             AND     (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                            ];
            
            system.debug('$$$ subscriptionId :' + subscriptionId);           
            
            if(relationships != null && relationships.size() == 0)
                throw new CustomException('Elevate BOSS orders are available only for a Broker or Office Manager');   
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();
            
            
            String zAccountsQuery = 'SELECT Id, Name, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + subscription.Name + '\'';
            system.debug('*** zAccountsQuery :' + zAccountsQuery);
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
            
            system.debug('*** zAccounts: ' +  zAccounts);
            
            zAccountId = (String)zAccounts[0].getValue('Id');
            if(String.isBlank(zAccountId))               
                throw new CustomException('No Zuora Account found'); 
            
            String zAccountName = (String)zAccounts[0].getValue('Name'); 
            findCurrentProducts();
            getZuoraDetails();
            //displayProductRatePlans();
            
        } 
        catch(Exception e){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        } 
        
    }
    
    public void newProductOrder(){
        isOrder = true;
        isUpdate = false;
        isTerminate = false;
        isBilling = false;
        quantity = 1;
        
        eligibleProducts = new Set<String>();        
        if(currentProductTypes.isEmpty()){
            eligibleProducts.add('Elevate BOSS by Bright MLS');
            eligibleProducts.add('Elevate BOSS Elite by Bright MLS');       
        }
        else{         
            if(!currentProductTypes.containsKey('BOSS Agent DMS')) 
                eligibleProducts.add('BOSS Agent DMS');
            if(!currentProductTypes.containsKey('BOSS Agent IDX and CRM')) 
                eligibleProducts.add('BOSS Agent IDX and CRM');
            if(!currentProductTypes.containsKey('Additional Advertising Spend')) 
                eligibleProducts.add('Additional Advertising Spend');
            if(!currentProductTypes.containsKey('Elevate Pro')) 
                eligibleProducts.add('Elevate Pro');                
        }
        
        productTypes = new List<SelectOption>();
        productTypes.add(new SelectOption('','-- Choose --'));
        for(String product : eligibleProducts){          
            productTypes.add(new SelectOption(product,product));         
        }
        
        displayProductRatePlans();
    }
    
    public void updateProductOrder(){
        EB_ProductOrder__c updateOrder =  currentProductTypes.get(updateProductType);
        isUpdate = true;
        isOrder = true;
        isBilling = false;
        isTerminate = false;
        
        eligibleProducts = new Set<String>();
        eligibleProducts.add(updateOrder.ProductType__c);
        displayProductRatePlans();
        
        zRecurringProductRatePlanId = updateOrder.ZRecurringRatePlanId__c;
        zOneTimeProductRatePlanId = updateOrder.ZOneTimeRatePlanId__c;  
        quantity = (Integer)updateOrder.Quantity__c;
    }
    
    public void terminateProductOrder(){
        EB_ProductOrder__c updateOrder =  currentProductTypes.get(terminateProductType);
        isTerminate = true;
        isOrder = true;
        isBilling = false;
        
        eligibleProducts = new Set<String>();
        eligibleProducts.add(updateOrder.ProductType__c);
        displayProductRatePlans();
        
        zRecurringProductRatePlanId = updateOrder.ZRecurringRatePlanId__c;
        zOneTimeProductRatePlanId = updateOrder.ZOneTimeRatePlanId__c; 
        quantity = (Integer)updateOrder.Quantity__c;
    }
    
    public void cancel(){
        findCurrentProducts();        
        quantity = 0;
        isPreview = true;
        isUpdate = false;
        isTerminate = false;
        isBilling = false;
        isOrder = false;
        zRecurringProductRatePlanId = null;
        zOneTimeProductRatePlanId = null;
    }
    
    public void getZuoraDetails(){
        String zProductQuery = 'SELECT Id, Name, EffectiveEndDate, EffectiveStartDate FROM Product WHERE Name = \'ELEVATE BOSS\'';
        String todayDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        zObject = zUtilInstance.zquery(zProductQuery);
        String zProductId;
        
        for (Zuora.zObject zProduct : zObject) {
            zProductId = (String)zProduct.getValue('Id');
        }
        
        String zPRatePlanQuery = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE ProductId =\'' + zProductId + '\'' + ' AND EffectiveEndDate >= ' + todayDate + ' AND EffectiveStartDate <= ' + todayDate;
        zObject = zUtilInstance.zquery(zPRatePlanQuery);
        
        zProductRatePlanIdObject = new Map<String, Zuora.zObject>();        
        zProductRatePlanChargeIdObject = new Map<String, Zuora.zObject>();
        zRatePlanChargeMap = new Map<String,String>();
        
        for (Zuora.zObject zProductRatePlan : zObject) {
            zProductRatePlanIdObject.put((String)zProductRatePlan.getValue('Id'), zProductRatePlan); 
        }            
        
        Integer i = 0;
        String ratePlanChargeQuery = 'SELECT Id, Name, ChargeType, ProductRatePlanId FROM ProductRatePlanCharge WHERE ';     
        
        for (String zProductRatePlanId : zProductRatePlanIdObject.keySet()) {            
            if (i != 0)
                ratePlanChargeQuery += ' OR ';        
            
            ratePlanChargeQuery += 'ProductRatePlanId = \'' + zProductRatePlanId + '\'';
            i++;            
        }
        System.debug('***' + ratePlanChargeQuery );
        
        List<Zuora.zObject> zRatePlanCharges = zUtilInstance.zquery(ratePlanChargeQuery);
        for(Zuora.zObject zRatePlanCharge : zRatePlanCharges) {            
            zProductRatePlanChargeIdObject.put((String)zRatePlanCharge.getValue('Id'), zRatePlanCharge);
            zRatePlanChargeMap.put((String)zRatePlanCharge.getValue('ProductRatePlanId'), (String)zRatePlanCharge.getValue('Id'));
        }            
    }
    
    public void displayProductRatePlans(){
        
        zProductRatePlans = new List<SelectOption>(); 
        zOnetimeRatePlans = new List<SelectOption>();
        
        for(Zuora.zObject zRatePlanCharge : zProductRatePlanChargeIdObject.values()) {
            String zrPNameId = (String)zRatePlanCharge.getValue('ProductRatePlanId');
            Zuora.zObject zProductRatePlan = zProductRatePlanIdObject.get(zrPNameId);
            String zrPName = (String)zProductRatePlan.getValue('Name');
            
            for(String productName : eligibleProducts){                
                if(zrPName.contains(productName) || zrPName.contains(productName)){                    
                    if ((String)zRatePlanCharge.getValue('ChargeType') == 'OneTime')
                        zOnetimeRatePlans.add(new SelectOption(zrPNameId, zrPName));
                    else
                        zProductRatePlans.add(new SelectOption(zrPNameId, zrPName));                       
                }
            }
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
        
    }
    
    public void previewOrder(){
        isPreview = true;
        isBilling = true;
        if(!isTerminate)
            placeOrder(); 
        else 
            terminateProduct();
    }
    
    public void confirmOrder(){
        isPreview = false;
        if(!isTerminate)
            placeOrder(); 
        else 
            terminateProduct();
        
        cancel();
    }    
    
    public void placeOrder(){
        
        Map<String,String> zProductRatePlanChargeIds = new Map<String,String>();
        zProductRatePlanChargeIds.put(zRecurringProductRatePlanId, zRatePlanChargeMap.get(zRecurringProductRatePlanId));
        if(String.isNotBlank(zOneTimeProductRatePlanId))
            zProductRatePlanChargeIds.put(zOneTimeProductRatePlanId, zRatePlanChargeMap.get(zOneTimeProductRatePlanId));
        
        Zuora.zObject zProductRatePlan = zProductRatePlanIdObject.get(zRecurringProductRatePlanId);
        String orderedRatePlanName = (String)zProductRatePlan.getValue('Name');
        String countType = null;
        if(orderedRatePlanName.contains('BOSS Agent'))
            countType = 'Agent(s)';
        else
            countType = 'Block(s)';
        
        List<Zuora.zApi.SubscribeRequest> subRequestList = new List<Zuora.zApi.SubscribeRequest>();
        List<EB_ProductOrder__c> orders = new List<EB_ProductOrder__c>();
        EB_ProductOrder__c newOrder = new EB_ProductOrder__c();
        
        orders = [SELECT Id, Name, ProductType__c, Quantity__c, StartDate__c 
                  FROM   EB_ProductOrder__c 
                  WHERE  Subscription__c = :subscription.Id
                  AND    ProductStatus__c IN ('New', 'Update') 
                  AND    ZRecurringRatePlanId__c = :zRecurringProductRatePlanId
                 ];
        
        if(orders.size() == 1){
            // Create amendment
            newOrder = orders[0];
            if(newOrder.Quantity__c > 0){
                // Quantity Adjustment Amendment
                
                getAmendmentDetails(zRecurringProductRatePlanId);
                String description = orderedRatePlanName + ':' + quantity + ' ' + countType;
                List<Zuora.zApi.AmendRequest> amendRequestList = new List<Zuora.zApi.AmendRequest>();
                Zuora.zApi.AmendRequest request = getProductAmendmentRequest(zAmendSubscriptionId, zRecurringProductRatePlanId, zAmendRatePlanId, zRatePlanChargeMap.get(zRecurringProductRatePlanId), quantity,  description, isPreview);
                amendRequestList.add(request);
                system.debug('*** amendResults request: ' + request);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                system.debug('*** amendResults Result: ' + amendResults);
                if(!amendResults.Success){
                    
                    String zerrorMessage = 'Error occured while amending the quantity request: ';
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors) 
                        zerrorMessage = zerrorMessage + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                    
                    system.debug('Amend zerrorMessage: ' + zerrorMessage);
                    throw new CustomException('Error: ' + zerrorMessage);
                }
                else{
                    newOrder.Quantity__c = quantity;
                    newOrder.ProductStatus__c = 'Update';               
                    
                    Zuora.zObject[] invoiceDatas = amendResults.invoiceDatas;
                    if(amendResults.invoiceDatas != null){
                        processZInvoiceData(invoiceDatas);
                    }
                    if(!isPreview)
                        update newOrder;
                }                
            }            
        }
        else{
            // This is a new order. Create Zuora Subscription         
            
            newOrder.ZRecurringRatePlanId__c = zRecurringProductRatePlanId;
            newOrder.StartDate__c = System.today();
            newOrder.Quantity__c = 0;
            newOrder.ProductStatus__c = 'New';
            newOrder.Contact__c = subscription.Contact__c;
            newOrder.PrivateEmail__c = subscription.Private_Email__c;
            newOrder.ZOneTimeRatePlanId__c = zOneTimeProductRatePlanId;
            newOrder.Subscription__c = subscription.Id;
            
            if(orderedRatePlanName.contains('BOSS by Bright MLS')){
                Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanChargeIds, null, null, null,isPreview);            
                subRequestList.add(request); 
                newOrder.ProductType__c = 'Elevate BOSS by Bright MLS';
            }
            else if(orderedRatePlanName.contains('BOSS Elite by Bright MLS')){
                Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanChargeIds, null, null, null, isPreview);            
                subRequestList.add(request);
                newOrder.ProductType__c = 'Elevate BOSS Elite by Bright MLS';
            }
            else{
                String description = orderedRatePlanName + ':' + quantity + ' ' + countType;
                Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanChargeIds, description, quantity, 'Count', isPreview);            
                subRequestList.add(request);
                
                newOrder.ProductType__c = orderedRatePlanName;
                newOrder.Quantity__c = quantity;
            }
            system.debug('----isPreview:'+isPreview);
            system.debug('---subRequestList:'+ subRequestList);
            List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
            
            for(Zuora.zApi.SubscribeResult result : results){
                system.debug('*** Subscribe Result: ' + result);
                if(!result.Success){                
                    Zuora.zObject[] errors = result.errors;
                    String zerrorMessage = 'Error while creating subscription in zuora: ';
                    for (Zuora.zObject error : errors) 
                        zerrorMessage = zerrorMessage  + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');
                    
                    throw new CustomException('Error: ' + zerrorMessage);
                }
                else{
                    
                    Zuora.zObject[] invoiceDatas = result.invoiceDatas;
                    if(result.invoiceDatas != null){
                        processZInvoiceData(invoiceDatas);
                    }
                    if(!isPreview)
                        insert newOrder;                    
                }                
            }             
        }
    }
    
    public void terminateProduct(){
        List<EB_ProductOrder__c> terminateOrders = new List<EB_ProductOrder__c>();
        List<Zuora.zApi.AmendRequest> amendRequestList = new List<Zuora.zApi.AmendRequest>();
        Boolean isError = false;
        invoiceDetails = new Invoice();invoiceDetails.Amount = 0;
        invoiceDetails.tax = 0;
        invoiceDetails.existingBalance = 0;
        invoiceDetails.amountDue = 0;
        invoiceDetails.invoiceItems = new List<InvoiceItem>();
        if(terminateProductType == 'Elevate BOSS by Bright MLS' || terminateProductType == 'Elevate BOSS Elite by Bright MLS'){
            // terminate all the product types    
            for(String prdType : currentProductTypes.keyset()){
                EB_ProductOrder__c order = new EB_ProductOrder__c();
                order = currentProductTypes.get(prdType);
                getAmendmentDetails(order.ZRecurringRatePlanId__c);
                amendRequestList = new List<Zuora.zApi.AmendRequest>();
                Zuora.zApi.AmendRequest request = getCancelProductRequest(zAmendSubscriptionId, isPreview);
                amendRequestList.add(request);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                if(!amendResults.Success){                
                    String zerrorMessage = 'Error occured while terminating the product:';
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors) 
                        zerrorMessage = zerrorMessage + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                    
                    system.debug('Amend zerrorMessage: ' + zerrorMessage);
                }
                else{
                    order.ProductStatus__c = 'Terminate';
                    terminateOrders.add(order);
                    Zuora.zObject[] invoiceDatas = amendResults.invoiceDatas;
                    if(amendResults.invoiceDatas != null){
                        processZInvoiceData(invoiceDatas);
                    }
                }
            }
        } 
        else{
            EB_ProductOrder__c order = new EB_ProductOrder__c();
            order = currentProductTypes.get(terminateProductType);
            getAmendmentDetails(order.ZRecurringRatePlanId__c);
            
            amendRequestList = new List<Zuora.zApi.AmendRequest>();
            Zuora.zApi.AmendRequest request = getCancelProductRequest(zAmendSubscriptionId, isPreview);
            amendRequestList.add(request);
            Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
            if(!amendResults.Success){                
                String zerrorMessage = 'Error occured while terminating the product:';
                Zuora.zObject[] errors = amendResults.errors;
                for (Zuora.zObject error : errors) 
                    zerrorMessage = zerrorMessage + 'zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');   
                
                system.debug('Amend zerrorMessage: ' + zerrorMessage);
            }
            else{
                order.ProductStatus__c = 'Terminate';
                order.EndDate__c = system.today();
                terminateOrders.add(order);
                Zuora.zObject[] invoiceDatas = amendResults.invoiceDatas;
                if(amendResults.invoiceDatas != null){
                    processZInvoiceData(invoiceDatas);
                }
            }
        }
        
        if(! isPreview)
            update terminateOrders;
    }
    
    
    
    private void getAmendmentDetails(String zProductRatePlanId){
        
        String currentDate = DateTime.now().format('yyyy-MM-dd');
        List<String> zSubscriptionIds = new List<String>();
        
        String zsubQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, Status FROM Subscription WHERE AccountId = \'' + zAccountId + '\' AND IsCore__c = false AND AutoRenew = true AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(zsubQuery);
        system.debug('zsubscriptions : ' + zSubscriptions);
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            system.debug('****' + zSubscription.getValue('Id'));
            zSubscriptionIds.add(String.valueOf(zSubscription.getValue('Id')));
        }
        
        Integer i = 0;
        String zRatePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        system.debug('****ratePlansQuery' + zRatePlansQuery);
        for (String zSubscriptionId : zSubscriptionIds) {
            if (i != 0)
                zRatePlansQuery += ' OR ';        
            
            zRatePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            i++;
        }
        system.debug('***Rate plan qury is ' + zRatePlansQuery);
        if(i != 0){
            
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(zRatePlansQuery);
            if (!(zRateplans.Size() > 0)) 
                throw new CustomException('Zuora Rateplan not found');
            system.debug('***zRatePlans '+zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {
                
                if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == zProductRatePlanId ){
                    system.debug('***zRecurringProductRatePlanId found');
                    zAmendSubscriptionId = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                    zAmendRatePlanId = String.valueOf(zRatePlan.getValue('Id'));
                    break;
                }
                
            }
            
        }
        
        system.debug('****zAmendSubscriptionId  '+ zAmendSubscriptionId);
        system.debug('***zAmendRatePlanId   ' + zAmendRatePlanId);
        
        
    }
    
    private void findCurrentProducts(){
        
        List<EB_ProductOrder__c> orders = new List<EB_ProductOrder__c>();
        currentProductTypes = new Map<String, EB_ProductOrder__c>();
        
        orders = [SELECT Id, Name, ProductType__c,ProductStatus__c,ZRecurringRatePlanId__c,ZOneTimeRatePlanId__c, Quantity__c, StartDate__c FROM 
                  EB_ProductOrder__c 
                  WHERE  Subscription__c = :subscription.Id
                  AND    ProductStatus__c IN ('New', 'Update')                  
                 ];
        
        for(EB_ProductOrder__c order : orders){
            currentProductTypes.put(order.ProductType__c, order); 
            if(order.ProductType__c == 'Elevate BOSS by Bright MLS' || order.ProductType__c == 'Elevate BOSS Elite by Bright MLS')
                existingCoreEBRecurringRatePlanId =  order.ZRecurringRatePlanId__c;           
        }
        if(String.isNotBlank(existingCoreEBRecurringRatePlanId)){           
            hasCoreEB = true;   
        }
        else{         
            hasCoreEB = false;      
        }
    }
    
    private Invoice processZInvoiceData(Zuora.zObject[] invoiceDatas){
        if(! isTerminate){
            invoiceDetails = new Invoice();
        invoiceDetails.Amount = 0;
        invoiceDetails.tax = 0;
        invoiceDetails.existingBalance = 0;
        invoiceDetails.amountDue = 0;
             invoiceDetails.invoiceItems = new List<InvoiceItem>();
        }
        
        for(Zuora.zObject invoiceData : invoiceDatas){                      
            system.debug('invoiceData: ' + invoiceData);
            
            List<Object> InvoiceItems = invoiceData.getArrayValue('InvoiceItem');
            for(Object obj : InvoiceItems){                
                Zuora.zObject zInvoiceItem = (Zuora.zObject) obj;
                system.debug('zInvoiceItem: ' + zInvoiceItem);
                
                InvoiceItem invItem = new InvoiceItem();
                invItem.ProductRatePlanChargeId = (String)zInvoiceItem.getValue('ProductRatePlanChargeId');
                if(zProductRatePlanChargeIdObject.containskey(invItem.ProductRatePlanChargeId)){
                Zuora.zObject zRatePlanCharge = zProductRatePlanChargeIdObject.get(invItem.ProductRatePlanChargeId);
                String zrPNameId = (String)zRatePlanCharge.getValue('ProductRatePlanId');
                if(zrPNameId == zOneTimeProductRatePlanId || zrPNameId == zRecurringProductRatePlanId){
                    Zuora.zObject zProductRatePlan = zProductRatePlanIdObject.get(zrPNameId);
                    invItem.productRatePlanName = (String)zProductRatePlan.getValue('Name');
                }
                    
                invoiceDetails.Amount = invoiceDetails.Amount + (Decimal)zInvoiceItem.getValue('ChargeAmount');
                invoiceDetails.tax = invoiceDetails.tax + (Decimal)zInvoiceItem.getValue('TaxAmount');
                
                invItem.ChargeAmount = (Decimal)zInvoiceItem.getValue('ChargeAmount');
                invItem.ChargeDescription = (String)zInvoiceItem.getValue('ChargeDescription');                
                invItem.ChargeName = (String)zInvoiceItem.getValue('ChargeName');
                
                
                invItem.ServiceEndDate = (Date)zInvoiceItem.getValue('ServiceEndDate');
                invItem.ServiceStartDate = (Date)zInvoiceItem.getValue('ServiceStartDate');
                
                invItem.TaxAmount = (Decimal)zInvoiceItem.getValue('TaxAmount');
                invItem.UnitPrice = (Decimal)zInvoiceItem.getValue('UnitPrice');
                 String countType = null;   
                    if(invItem.ChargeName.contains('Elevate BOSS'))
                        countType = '';
                    else if(invItem.ChargeName.contains('BOSS Agent'))
                        countType = 'Agent(s)';
                    else
                        countType = 'Block(s)';
                    invItem.Quantity = String.valueOf(zInvoiceItem.getValue('Quantity')) + ' ' + countType;
                invItem.isRemoval = false;
                
                if(invItem.ChargeAmount < 0)
                    invItem.isRemoval = true;
                
                invoiceDetails.invoiceItems.add(invItem);
                
                system.debug('*** invItem: ' + invItem);
                }
                
            }
            
        }
        
        return invoiceDetails;
    }
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, Map<String,String> zProductRatePlanChargeIds, String description, Decimal quantity, String type, Boolean isPreview) {
        String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST');
        
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
        
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', zAccountId);
        
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = !isPreview;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = isPreview;
        
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', effectiveDate);
        subscription.setValue('ServiceActivationDate', effectiveDate);
        subscription.setValue('TermType', 'TERMED');
        
        subscription.setValue('InitialTerm', '12');
        subscription.setValue('RenewalTerm', '1');
        
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', false);
        
        request.SubscriptionData.Subscription = subscription;
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        for (String zProductRatePlanId : zProductRatePlanChargeIds.keyset()) {
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
            
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            ratePlanData.setValue('RatePlan', ratePlan);           
            
            if(type == 'Count'){
                String zProductRatePlanChargeId = zProductRatePlanChargeIds.get(zProductRatePlanId);
                Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
                ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
                ratePlanCharge.setValue('Description', description);
                ratePlanCharge.setValue('Quantity', quantity);
                
                Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
                
                ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
            }       
            
            ratePlanDataList.add(ratePlanData);
        } 
        
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
        
        return request;                 
    }
    
    private Static Zuora.zApi.AmendRequest getProductAmendmentRequest(String zSubscriptionId, String zProductRatePlanId, String zRateplanId, String zProductRatePlanChargeId, Decimal quantity, String description, Boolean isPreview ) {
        String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST');
        system.debug('zSubscriptionId' + zSubscriptionId);
        system.debug('zProductRatePlanId' + zProductRatePlanId);
        system.debug('zRateplanId' + zRateplanId);
        system.debug('zProductRatePlanChargeId' + zProductRatePlanChargeId);
        system.debug('quantity' + quantity);
        system.debug('isPreview' + isPreview);
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
        request.AmendOptions.generateInvoice = !isPreview;        
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = isPreview;
        
        return request;
    }
    
    private Static Zuora.zApi.AmendRequest getCancelProductRequest(String zSubscriptionId, Boolean isPreview){       
        
        String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST');
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Cancel Product');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        amendment.setValue('Type', 'Cancellation');
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = !isPreview;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = isPreview;
        return request;
    }
    
    public class Invoice{
        public Decimal tax { get; set; }
        public Decimal amount { get; set; }
        public Decimal existingBalance { get; set; }
        public Decimal amountDue { get; set; }
        public List<InvoiceItem> invoiceItems { get; set; }
    }
    
    public class InvoiceItem {
        public String productRatePlanName { get; set; }
        public Decimal ChargeAmount { get; set; }
        public Boolean  isRemoval { get; set; }
        public String  ChargeDescription { get; set; }
        public String  ProductRatePlanChargeId { get; set; }
        public Date  ServiceEndDate { get; set; }
        public Date ServiceStartDate { get; set; }
        public String ChargeName { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal UnitPrice { get; set; }
        public String Quantity { get; set; }
    }
    
    public Class CustomException extends Exception {} 
    
}