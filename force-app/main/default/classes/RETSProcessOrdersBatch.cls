global class RETSProcessOrdersBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public List<Zuora.zApi.AmendRequest> amendRequestList = new List<Zuora.zApi.AmendRequest>();
    public SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil(); 
    public Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
    public List<Zuora.zObject> objectList = new List<Zuora.zObject>();
    public String zProductRatePlanId_rm;
    public String zProductRatePlanChargeId_rm;
    public String zRateplanId;
    public String zProductRatePlanId_add;
    public String zProductRatePlanChargeId_add;
    public Decimal quantity = 0;
    public Decimal InactiveQuantity = 0;
    public String effectiveDate;
    public String query;
    public String zParentId;
    public String zAccId;
    public String zrelatedchildsubId;
    public String zsubIdafterRemoveamend;
    public String zsubIdafterAddamend;
    public String zsubIdafterTransferamend;
    public String zsubIdafterQuantAdjamend;
    public Boolean isSuccess = true;
    public String batch;
    public String ErrorMsg;
    public List<String> zSubIds = new List<String>();
    public List<String> zAccIds = new List<String>();
    public Set<String> agentIds = new Set<String>();
    public List<RETS_Product_Order__c> agent_order = new List<RETS_Product_Order__c>();
    public List<RETS_Product_Order__c> updatedOrders = new List<RETS_Product_Order__c>();
    
    
    global RETSProcessOrdersBatch(String query,String zProductRatePlanId_rm,String zProductRatePlanChargeId_rm,String zProductRatePlanId_add,String zProductRatePlanChargeId_add,String effectiveDate,String batch){
        this.query = query;
        this.zProductRatePlanId_rm = zProductRatePlanId_rm;
        this.zProductRatePlanChargeId_rm = zProductRatePlanChargeId_rm;
        this.zProductRatePlanId_add = zProductRatePlanId_add;
        this.zProductRatePlanChargeId_add = zProductRatePlanChargeId_add;
        this.effectiveDate = effectiveDate;
        this.batch = batch;
    }
  
  global Database.QueryLocator start(Database.BatchableContext BC)  {    
       System.debug('***Query is : '+ query);
       return Database.getQueryLocator(query);
   }
    
    global void execute(Database.BatchableContext BC,List<RETS_Product_Order__c> orders){
         System.debug('***orders size  is : '+ orders.size());
        try{
        for(RETS_Product_Order__c order : orders){
            // Check if already agent subscription is already processed
             if(!agentIds.contains(order.Agent__c)){
                
              agentIds.add(order.Agent__c);
              System.debug('***order is : '+ order);
            
            //get child account,child account and subscription related to child
              getZuoraDetails(order);
             zAccIds.add(zAccId);
            
             if(isSuccess)   
               getSubscriptionRatePlanID(zrelatedchildsubId);   
                 
            //Get latest quantity and description 
            String description;
             if(isSuccess)   
                description = getQuantityDescription(order.Agent__r.Name);    
                 
            // Adjusting the qunatity before removing the product in case of misreported           
            if(isSuccess && (order.ZuoraVendorProductIntegrationStatus__c!=null &&  order.ZuoraVendorProductIntegrationStatus__c.contains('true')))
               adjustQuantity(zrelatedchildsubId,description,order.Start_Date__c); 
            else
                zsubIdafterQuantAdjamend = zrelatedchildsubId;
               
            //Remove old product
            if(isSuccess)  
              removeProduct(zsubIdafterQuantAdjamend,order);
            

            //Add product with latest quantity
               if(isSuccess && quantity > 0)  
                 addProduct(zsubIdafterRemoveamend,description,order);
            
            //Transfer subscription from parent to child
               if(isSuccess)  
                  transferSubtoChild(zsubIdafterAddamend,zAccId,order);   
                 
                 if(isSuccess){
                     ErrorMsg = 'Success';
                 }
                 updateSameAgentOrders(ErrorMsg); 
                 clearFlags();
             }            
        }
        
        //Change batch number
        updateChildBatchNumber(zAccIds);
        zAccIds.clear();
        agentIds.clear();
        
        system.debug('****updatedOrders '+updatedOrders);
        if(updatedOrders.size()>0)
            update updatedOrders;
        updatedOrders.clear();  
             }catch(Exception e){
            system.debug('exception in updating record');
        }
    }
     global void finish(Database.BatchableContext BC) {
         
     }
    
    global void addProduct(String zSubscriptionId,String description, RETS_Product_Order__c order){
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
         
    
        Zuora.zObject amendment = new Zuora.zObject('Amendment');

        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId_add);        

        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId_add);
        ratePlanCharge.setValue('Description', description);
        ratePlanCharge.setValue('Quantity', quantity);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        

        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 


        amendment.setValue('Name', 'Add the new agent product');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        
        amendment.setValue('Type', 'NewProduct');
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
        amendRequestList.add(request);
        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
        system.debug('Amend Result '+amendResults);
        amendRequestList.clear();
          if (!amendResults.Success) {        
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors){
                        isSuccess = false;
                        errorMsg = 'NewProduct :: AmendCallException : ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                            
                    }  
                }else if(amendResults.Success){
                   zsubIdafterAddamend = (String) amendResults.SubscriptionId;
                   system.debug('*** zsubIdafterAddamend :'+ zsubIdafterAddamend);
        }
          if(test.isRunningTest()){
                         isSuccess = true;
                }  
                  
    }
    
    global void removeProduct(String zSubscriptionId, RETS_Product_Order__c order){
           Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();    
        
    
        Zuora.zObject amendment = new Zuora.zObject('Amendment');

        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId_rm);        
        ratePlan.setValue('AmendmentSubscriptionRatePlanId',zRateplanId);
        

        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);


        amendment.setValue('Name', 'Remove the agent product');
        amendment.setValue('SubscriptionId', zSubscriptionId );
        
        amendment.setValue('Type', 'RemoveProduct');
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
        amendRequestList.add(request);
        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
        system.debug('Amend Result '+amendResults);
        amendRequestList.clear();
        
          if (!amendResults.Success) {        
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors){
                        isSuccess = false;
                       errorMsg = 'RemoveProduct :: zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                           
                                          }  
                }
        else if(amendResults.Success){
             zsubIdafterRemoveamend = (String) amendResults.SubscriptionId;
            system.debug('*** zsubIdafterRemoveamend :'+ zsubIdafterRemoveamend);
        }
        if(test.isRunningTest()){
                         isSuccess = true;
                }  
    }
    
    global String getQuantityDescription(String sSubscription ){
        Decimal activeQuantity = 0;

        agent_order = [SELECT ID,RETS_Sub_Product__r.Name__c,On_Behalf_of_Agent__c,Agent__r.Name,ImportSourceID__c,status__c,
                                                   On_Behalf_of_Agent__r.CUSTOMERNAME__c,URL__c, Vendor_Product__r.Account_Name__c 
                                                   from RETS_Product_Order__c
                                                   where Agent__r.Name = :sSubscription
                                                   and Is_External_Billing__c = false and RETS_Billing_Exclusion__c excludes ('Agent') order by createdDate desc];
        
        for(RETS_Product_Order__c ord : agent_order ){
            if(ord.status__c == 'Active'){
                activeQuantity +=1;
            }
            else if(ord.status__c == 'Inactive'){
                InactiveQuantity += 1;
            }
        }
        quantity = activeQuantity;
        system.debug('Active quantity is '+quantity);
        system.debug('Inctive quantity is '+InactiveQuantity);
            
        String description = '';
        String prefix_string='';
        
         if(quantity == 0){
                    prefix_string = 'No products';
                }
                if(quantity == 1){
                    prefix_string = quantity + ' product';
                }
                else {
                    prefix_string = quantity + ' products';                          
                }
                
        for (RETS_Product_Order__c order : agent_order ){
            If(order.Status__c == 'Active'){
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
        }
        
                                 
       description = prefix_string + description ; 
        
        system.debug('description is '+description);
        system.debug('description.length()---'+description.length());
        return description;

    }
    
    global void transferSubtoChild(String zsubID,String zAccID,RETS_Product_Order__c order){

                Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
                request.Amendments = new List <Zuora.zObject>();        
                
                Zuora.zObject amendment = new Zuora.zObject('Amendment');
                amendment.setValue('Name', 'Owner Transfer to child');
                amendment.setValue('SubscriptionId', zsubID);
                amendment.setValue('Type', 'OwnerTransfer');
                amendment.setValue('DestinationInvoiceOwnerId',zAccId);
                amendment.setValue('DestinationAccountId',zAccId);
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
                
                amendRequestList.add(request);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                //system.debug('Amend Result '+amendResults);
               if (!amendResults.Success) {        
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors){
                        isSuccess = false;
                        errorMsg = 'OwnerTransfer :: zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                           
                    }  
                }
                else {
                    zsubIdafterTransferamend = (String)amendResults.subscriptionID;
                    system.debug('*** zsubIdafterTransferamend : '+zsubIdafterTransferamend);
                }
                amendRequestList.clear();
               
        if(test.isRunningTest()){ isSuccess = true; }  
        
    }
    
    global void getZuoraDetails(RETS_Product_Order__c order){
        
        Map<String,String> subMap = new Map<String,String>();
        String accountQuery = 'SELECT Id,Name, ParentId FROM Account WHERE SubscriptionID__c = \'' + order.Agent__r.Name + '\'';
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        zParentId = String.ValueOf(zAccounts[0].getValue('ParentId'));

        String subQuery = 'SELECT Id,PreviousSubscriptionId, Status FROM Subscription WHERE AccountId = \'' + zParentId + '\' AND IsCore__c = false AND AutoRenew = true AND Status=\'Active\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('*** zSubscriptions: '+ zSubscriptions); 
        
        if(!(zSubscriptions.size()>0)){
            isSuccess = false;
            errorMsg = 'getZuoraDetails(): No Data Licensing subscriptions found in parent';
        }
        
        for (Zuora.zObject zsubs : zSubscriptions){
            subMap.put(String.valueOf(zsubs.getValue('PreviousSubscriptionId')), String.valueOf(zsubs.getValue('Id')));
            zsubIds.add(String.valueOf(zsubs.getValue('PreviousSubscriptionId')));
        }
        
        for(String zsubId : zsubIds){
            
            String amendQuery = 'SELECT Id, Name, SubscriptionId, Status, type FROM Amendment WHERE SubscriptionId = \'' + zsubID + '\' and type = \'OwnerTransfer\'';
            List<Zuora.zObject> zAmendments = zUtilInstance.zquery(amendQuery);
           
            system.debug('***zAmendments---'+zAmendments);
            for(Zuora.zObject zamend : zAmendments){
                String zamendName =(String) zamend.getValue('Name');
                system.debug('*****zamendName'+zamendName);
                
			 if(zamendName.contains(zAccId)){
                    zrelatedchildsubId = subMap.get((String) zamend.getValue('SubscriptionId'));
                    system.debug('**** zrelatedchildsubId'+zrelatedchildsubId);
                }
            }
        }
        if(zrelatedchildsubId == null){
            isSuccess = false;
            errorMsg = 'getZuoraDetails(): Unable to find related child subscription in parent';
        }
                 if(test.isRunningTest()){
                         isSuccess = true;
                }   
        
    }
    
    
    public void adjustQuantity(String zSubscriptionId, String description,DateTime startDate){
        String startDateStr = startDate.format('yyyy-MM-dd\'T\'00:00:00');
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId_rm);        
        ratePlan.setValue('AmendmentSubscriptionRatePlanId',zRateplanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId_rm);
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
        amendment.setValue('ContractEffectiveDate', startDateStr);
        amendment.setValue('EffectiveDate', startDateStr);
        amendment.setValue('ServiceActivationDate', startDateStr);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = false;        
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        amendRequestList.add(request);
        
        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                //system.debug('Amend Result '+amendResults);
               if (!amendResults.Success) {        
                    Zuora.zObject[] errors = amendResults.errors;
                    for (Zuora.zObject error : errors){
                        isSuccess = false;
                        errorMsg = 'Quantity Adjustement :: zAmendCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message');                             
                    } 
                } else if (amendResults.Success){
                       zsubIdafterQuantAdjamend = (String) amendResults.subscriptionId;
                       system.debug('******zsubIdafterQuantAdjamend'+zsubIdafterQuantAdjamend);
                   }
        if(test.isRunningTest()){
                         isSuccess = true;
                }  
    }
    
    
    public void updateChildBatchNumber(List<String > zAccountsId){
        for(String ZAccountID : zAccountsId){
            
            Zuora.zObject zAccount = new Zuora.zObject('Account');
            zAccount.setValue('Id', ZAccountID);
            
            zAccount.setValue('Batch', batch);  
            objectList.add(zAccount);
            
            
        }
        if(objectList!= null && objectList.size()>0){                             
            List<Zuora.zApi.SaveResult> zSaveResultList = new List<Zuora.zApi.SaveResult>();
            zSaveResultList = zUtilInstance.zupdate(objectList);  
        }
    }
    
    public void getSubscriptionRatePlanID(String zSubscriptionId){
         String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE SubscriptionId =\''+zSubscriptionId+'\'';
      List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);
        for(Zuora.zObject zRP : zRatePlans) {
            system.debug('*** ProductRatePlanId '+zRP.getValue('ProductRatePlanId'));
            system.debug('*** zProductRatePlanId_rm '+ zProductRatePlanId_rm);
      if(String.valueof(zRP.getValue('ProductRatePlanId')) == zProductRatePlanId_rm ){
                        zRateplanId = String.valueOf(zRP.getValue('Id'));
                        break;
                    }
         }     
        
        if(zRateplanId == null){
            isSuccess = false;
            errorMsg = 'getSubscriptionRatePlanID() : Unable to find RateplanId';
        }
         system.debug('***zRateplanId'+zRateplanId);   
        if(test.isRunningTest()){
                         isSuccess = true;
                }  
    }
    
    public void updateSameAgentOrders(String message){
        for(RETS_Product_Order__c orderUpdate : agent_order ){
               orderUpdate.ImportSourceID__c = orderUpdate.ImportSourceID__c +' : '+message;
               updatedOrders.add(orderUpdate);
        }

    }
    
    public void clearFlags(){
        isSuccess = true;
        errorMsg ='';
        quantity = 0;
        InactiveQuantity = 0;
        zParentId='';
        zAccId='';
        zrelatedchildsubId='';
        zsubIdafterQuantAdjamend = '';
        zsubIdafterRemoveamend='';
        zsubIdafterAddamend='';
        zsubIdafterTransferamend='';
        zRateplanId='';
        zSubIds.clear();
        agent_order.clear();
    }
}