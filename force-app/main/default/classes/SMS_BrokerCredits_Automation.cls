public class SMS_BrokerCredits_Automation{
    
    
    public List<Zuora.zObject> zBrokerCreditRatePlans { get; set; }
    SMS_ZuoraUtil zApiInstance;
    Zuora.zApi.LoginResult zLoginResult;
    
    public List<BrokerCredit> brokerCredits { get; set; } 
    public String brokerCreditstr { get; set; }
    
    public List<BrokerCreditRatePlan> BCRatePlans { get; set; }
    public String BCRatePlanstr { get; set; }
    
    public Map<String,BrokerCredit> subIdBrokerCredits { get; set; }
    
    public string invalidBrokerCreditsJSON {get; set;}
    public List<BrokerCredit> invalidBrokerCredits;
    
    public string processedBrokerCreditsJSON {get; set;}
    public List<BrokerCredit> processedBrokerCredits; 
    
    public string verifiedBrokerCreditsJSON {get; set;}
    public List<BrokerCredit> verifiedBrokerCredits;
    
    public string creditsFromFileJSON {get; set;}
    public set<string> fileSubIds;
    
    public SMS_BrokerCredits_Automation(){
        
        invalidBrokerCredits = new list<BrokerCredit>();
        processedBrokerCredits = new list<BrokerCredit>();
        verifiedBrokerCredits = new list<BrokerCredit>();
        
        zApiInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zApiInstance.zlogin();
        
        brokerCredits = new List<BrokerCredit>();
        BCRatePlans = new List<BrokerCreditRatePlan>();
        
        List<Zuora.zObject> zBrokerCreditProducts = new List<Zuora.zObject>();
        List<Zuora.zObject> zBrokerCreditRatePlans = new List<Zuora.zObject>();
        List<Zuora.zObject> zBrokerCreditRatePlanCharges = new List<Zuora.zObject>();
        List<Zuora.zObject> zBrokerCreditRatePlanChargeTiers = new List<Zuora.zObject>();
        
        Map<String,String> zProductIdNames = new Map<String,String>();
        Map<String,String> zRatePlanIdNames = new Map<String,String>();
        Map<String,String> zRatePlanIdProductId = new Map<String,String>();
        
        Map<String,String> zChargeIdRatePlanId = new Map<String,String>();
        Map<String,String> zChargeIdNames = new Map<String,String>();
        Map<String,String> zChargeTierIdChargeId = new Map<String,String>();
        Map<String,Decimal> zChargeTierIdPrices = new Map<String,Decimal>();
        
        String zbcProductQuery = 'SELECT Id, Name FROM Product WHERE ';
        String zbcRatePlanQuery = 'SELECT Id, Name, ProductId FROM ProductRatePlan WHERE ';
        String zbcChargeQuery = 'SELECT Id, Name, ProductRatePlanId, ChargeType, ChargeModel FROM ProductRatePlanCharge WHERE ';
        String zbcChargeTierQuery = 'SELECT Id, Price, ProductRatePlanChargeId FROM ProductRatePlanChargeTier WHERE ';
        
        Boolean isFirst = true;
        
        for(SMS_BrokerCredit_Products__c brokerCreditProduct : SMS_BrokerCredit_Products__c.getall().values()){
            if(!isFirst)
                zbcProductQuery += ' OR '; 
            
            zbcProductQuery += 'Name = \'' + brokerCreditProduct.Name + '\'';
            isFirst = false;
        }
        
        if(!isFirst){
            zBrokerCreditProducts = zApiInstance.zquery(zbcProductQuery);
            isFirst = true;   
            
            for(Zuora.zObject zbcProduct : zBrokerCreditProducts) {
                String zProductId = (String)zbcProduct.getValue('Id');
                String zProductName = (String)zbcProduct.getValue('Name');
                zProductIdNames.put(zProductId,zProductName);
                
                if(!isFirst)
                    zbcRatePlanQuery += ' OR '; 
                
                zbcRatePlanQuery += 'ProductId = \'' + zProductId + '\'';
                isFirst = false;
            }
            
            if(!isFirst){
                zBrokerCreditRatePlans = zApiInstance.zquery(zbcRatePlanQuery);
                isFirst = true;            
                
                for(Zuora.zObject zbcRatePlan : zBrokerCreditRatePlans) {
                    String zRatePlanId = (String)zbcRatePlan.getValue('Id');
                    String zRatePlanName = (String)zbcRatePlan.getValue('Name');
                    String zProductId = (String)zbcRatePlan.getValue('ProductId');
                    zRatePlanIdNames.put(zRatePlanId,zRatePlanName);
                    zRatePlanIdProductId.put(zRatePlanId,zProductId);
                    
                    if(!isFirst)
                        zbcChargeQuery += ' OR '; 
                    
                    zbcChargeQuery += 'ProductRatePlanId = \'' + zRatePlanId + '\'';
                    isFirst = false;                
                }
                
                if(!isFirst){
                    zBrokerCreditRatePlanCharges = zApiInstance.zquery(zbcChargeQuery);
                    isFirst = true;            
                    
                    for(Zuora.zObject zbcRatePlanCharge : zBrokerCreditRatePlanCharges) {
                        String zChargeModel = (String)zbcRatePlanCharge.getValue('ChargeModel');
                        String zChargeType = (String)zbcRatePlanCharge.getValue('ChargeType');
                        if(zChargeModel == 'Flat Fee Pricing' && zChargeType == 'OneTime'){
                            String zChargeId = (String)zbcRatePlanCharge.getValue('Id');
                            String zChargeName = (String)zbcRatePlanCharge.getValue('Name');
                            String zRatePlanId = (String)zbcRatePlanCharge.getValue('ProductRatePlanId');
                            zChargeIdRateplanId.put(zChargeId,zRatePlanId);
                            zChargeIdNames.put(zChargeId,zChargeName);

                            if(!isFirst)
                                zbcChargeTierQuery += ' OR '; 
                            
                            zbcChargeTierQuery += 'ProductRatePlanChargeId = \'' + zChargeId + '\'';
                            isFirst = false; 
                        }               
                    }
                    
                    if(!isFirst){
                        zBrokerCreditRatePlanChargeTiers = zApiInstance.zquery(zbcChargeTierQuery);
                        isFirst = true;            
                        
                        for(Zuora.zObject zbcRatePlanChargeTier : zBrokerCreditRatePlanChargeTiers) {
                            String zChargeTierId = (String)zbcRatePlanChargeTier.getValue('Id');
                            Decimal zChargeTierPrice = (Decimal)zbcRatePlanChargeTier.getValue('Price');
                            String zChargeId = (String)zbcRatePlanChargeTier.getValue('ProductRatePlanChargeId');
                            zChargeTierIdChargeId.put(zChargeTierId,zChargeId);
                            zChargeTierIdPrices.put(zChargeTierId,zChargeTierPrice);                                  
                        }
                    }
                }
            }            
        } 
        
        system.debug('*** zProductIdNames : ' + zProductIdNames );
        system.debug('*** zRatePlanIdNames   : ' + zRatePlanIdNames );
        system.debug('*** zRatePlanIdProductId  : ' +zRatePlanIdProductId  );
        system.debug('*** zChargeIdRatePlanId : ' + zChargeIdRatePlanId );
        system.debug('*** zChargeIdNames : ' + zChargeIdNames );
        system.debug('*** zChargeTierIdChargeId  : ' + zChargeTierIdChargeId );
        system.debug('*** zChargeTierIdPrices  : ' + zChargeTierIdPrices );
        
        for(String chargeTeirId : zChargeTierIdPrices.keyset()){            
            BrokerCreditRatePlan bcRatePlan = new BrokerCreditRatePlan();
            
            bcRatePlan.zRatePlanChargeId = zChargeTierIdChargeId.get(chargeTeirId);
            bcRatePlan.zChargeAmount = zChargeTierIdPrices.get(chargeTeirId);
            
            bcRatePlan.zRatePlanId = zChargeIdRatePlanId.get(bcRatePlan.zRatePlanChargeId);            
            bcRatePlan.zRatePlanName = zRatePlanIdNames.get(bcRatePlan.zRatePlanId);
            
            bcRatePlan.zProductId = zRatePlanIdProductId.get(bcRatePlan.zRatePlanId);
            bcRatePlan.zProductName = zProductIdNames.get(bcRatePlan.zProductId);
            
            BCRatePlans.add(bcRatePlan);                    
        }
        
        BCRatePlanstr = JSON.serialize(BCRatePlans);            
    }
    
    public Set<String> checkZuoraforProcessedSubscriptions(String fileName){
        SMS_ZuoraUtil zApiInstance = new SMS_ZuoraUtil(); 
        Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin();
        Set<String> subscriptionIds = new Set<String>();
        List<String> zAccountIds = new List<String>();
        
        String zSubQuery =  'SELECT Id, Name, AccountId FROM Subscription WHERE Notes = \'' + fileName + '\' AND Status = \'Active\'';
        List<Zuora.zObject> zSubscriptions = zApiInstance.zquery(zSubQuery);
        for(Zuora.zObject zSubscription : zSubscriptions) {
            String zAccountId = (String)zSubscription.getValue('AccountId');
            zAccountIds.add(zAccountId);
        }
        
        for(Zuora__CustomerAccount__c billingAccount : [SELECT Id, Name, SubscriptionID__c
                                                        FROM   Zuora__CustomerAccount__c
                                                        WHERE  Zuora__Zuora_Id__c IN :zAccountIds
                                                       ]){
           subscriptionIds.add(billingAccount.SubscriptionID__c);
        }
        
        List<SMS_CreditsAutomationHistory__c> creditAutoHistoryUpdates = new  List<SMS_CreditsAutomationHistory__c>();
        for(SMS_CreditsAutomationHistory__c creditAutoHistory : [SELECT Id, FileName__c, CreatedDate, SubscriptionId__c, Status__c 
                                                                 FROM SMS_CreditsAutomationHistory__c
                                                                 WHERE SubscriptionId__c IN :subscriptionIds
                                                                 AND Status__c != 'Success'
                                                                 AND fileName__c = :fileName])
        {
            creditAutoHistory.Status__c = 'Success'; 
            creditAutoHistoryUpdates.add(creditAutoHistory);
        }        
        update creditAutoHistoryUpdates;
        
        return subscriptionIds;
        
    }
    
    public void fileRecords() {
        System.debug('*** creditsFromFile ' + creditsFromFileJSON );
        
        List<BrokerCredit>  creditsFromFile = (List<BrokerCredit>)JSON.deserialize(creditsFromFileJSON, List<BrokerCredit>.class);
        String fileName = creditsFromFile[0].fileName; 
        Set<String> processedSubscriptionIds = checkZuoraforProcessedSubscriptions(fileName);
        
        List<SMS_CreditsAutomationHistory__c> newBrokerCreditsHistory = new List<SMS_CreditsAutomationHistory__c>();
        fileSubIds = new set<string>();
        for(BrokerCredit bc : creditsFromFile){
            fileSubIds.add(bc.subscriptionId);
        }
        
        if(!fileSubIds.isEmpty()){
            map<string, SMS_CreditsAutomationHistory__c> mapExistingCAH = new map<string, SMS_CreditsAutomationHistory__c>();
            for(SMS_CreditsAutomationHistory__c cah : [SELECT Id, FileName__c, CreatedDate, SubscriptionId__c, Status__c, Status_Message__c, Zuora_Rate_Plan__c, Zuora_Rate_Plan_Id__c
                                                       FROM   SMS_CreditsAutomationHistory__c
                                                       WHERE  SubscriptionId__c in: fileSubIds
                                                       //AND    Status__c = 'Success'
                                                       AND    fileName__c = :fileName
                                                      Order by createdDate asc]){
                mapExistingCAH.put(cah.SubscriptionId__c, cah);
            }
            system.debug('---mapExistingCAH--->'+ mapExistingCAH);
            system.debug('---creditsFromFile--->'+ creditsFromFile);
            system.debug('----processedSubscriptionIds--->'+processedSubscriptionIds);
            
            for(BrokerCredit bc : creditsFromFile){
                //if(mapExistingCAH.containsKey(bc.subscriptionId) ){ //&& bc.subscriptionId == mapExistingCAH.get(bc.subscriptionId).SubscriptionId__c){
                if(processedSubscriptionIds.contains(bc.subscriptionId)){
                    bc.notes = 'Record already processed';
                    bc.status = 'Processed'; //mapExistingCAH.get(bc.subscriptionId).status__c;
                    bc.isValid = true;
                    bc.processed = true;
                    if(mapExistingCAH.containsKey(bc.subscriptionId) && mapExistingCAH.get(bc.subscriptionId) != null && mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c != null){
                    	bc.zRatePlanName = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c;
                        bc.zRatePlanId = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan_Id__c;
                    }
                    processedBrokerCredits.add(bc);
                    verifiedBrokerCredits.add(bc);
                }
                else{
                    system.debug('--unprocessed credits-->'+bc);
                    if(mapExistingCAH.containsKey(bc.subscriptionId) && mapExistingCAH.get(bc.subscriptionId) != null && mapExistingCAH.get(bc.subscriptionId).status__c == 'Failed'){
                        
                        newBrokerCreditsHistory.add(mapExistingCAH.get(bc.subscriptionId));
                        bc.status = mapExistingCAH.get(bc.subscriptionId).status__c; // 'Failed';
                        bc.isValid = false;
                        bc.processed = true;
                        bc.notes = mapExistingCAH.get(bc.subscriptionId).Status_Message__c;
                        
                        if(mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c != null){
                            bc.zRatePlanName = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c;
                            bc.zRatePlanId = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan_Id__c;
                        }
                        
                        verifiedBrokerCredits.add(bc);
                        
                    }else if(!mapExistingCAH.containsKey(bc.subscriptionId) || (mapExistingCAH.containsKey(bc.subscriptionId) && mapExistingCAH.get(bc.subscriptionId) != null && mapExistingCAH.get(bc.subscriptionId).status__c != 'Failed')){
                        SMS_CreditsAutomationHistory__c newcah = new SMS_CreditsAutomationHistory__c();
                        newcah.SubscriptionId__c = bc.subscriptionId;
                        newcah.Amount__c = bc.totalCreditAmount;
                        newcah.FileName__c = bc.fileName;
                        newcah.Status__c = 'In Progress';
                        newBrokerCreditsHistory.add(newcah);
                        
                        if(mapExistingCAH.containsKey(bc.subscriptionId) && mapExistingCAH.get(bc.subscriptionId) != null && mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c != null){
                            bc.zRatePlanName = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan__c;
                            bc.zRatePlanId = mapExistingCAH.get(bc.subscriptionId).Zuora_Rate_Plan_Id__c;
                        }
                        
                        bc.status = 'To be Processed';
                        bc.processed = false;
                        verifiedBrokerCredits.add(bc);
                    }
                }
            }
            
            system.debug('---lstRunBC--->'+ verifiedBrokerCredits.size());
            
            if(newBrokerCreditsHistory.size() > 0){
                upsert newBrokerCreditsHistory;
                
                map<string, SMS_CreditsAutomationHistory__c> mapSubIdCAHistory = new map<string, SMS_CreditsAutomationHistory__c>();
                for(SMS_CreditsAutomationHistory__c cah : newBrokerCreditsHistory){
                    mapSubIdCAHistory.put(cah.SubscriptionId__c, cah);
                }
                system.debug('---mapSubIdCAHistory-->'+mapSubIdCAHistory);
                if(mapSubIdCAHistory.size() > 0 ){
                    for(BrokerCredit bc : verifiedBrokerCredits){
                        if(mapSubIdCAHistory.containsKey(bc.subscriptionId))
                            bc.caHistoryId = mapSubIdCAHistory.get(bc.subscriptionId).Id;
                    }
                }
            }
            //validateSubscriptionIds(lstNewCAH);
            if(processedBrokerCredits.Size() > 0)
                processedBrokerCreditsJSON = JSON.serialize(processedBrokerCredits);
            
            
            system.debug('---lstRunBC after add cah id-->'+verifiedBrokerCredits);
            if(verifiedBrokerCredits.size() > 0 )
                verifiedBrokerCreditsJSON = JSON.serialize(verifiedBrokerCredits);
            system.debug('---lstRunBCStr json--->'+ verifiedBrokerCreditsJSON);           
        }
    }
    
    @RemoteAction
    public static boolean checkFile(string fileName){
        if(fileName != null){
            system.debug('===filename==>'+fileName);
            List<SMS_CreditsAutomationHistory__c> creditAutoHistories = [SELECT Id, FileName__c FROM SMS_CreditsAutomationHistory__c
                                                                         WHERE fileName__c =: fileName limit 1
                                                                        ];
            if(creditAutoHistories != null && creditAutoHistories.size() >0 )
                return true;
            else
                return false;
        }
        else
            return false;
    }
    
    @RemoteAction
    public static List<BrokerCredit> validateData(String brokerCreditstr){
        try {
            SMS_ZuoraUtil zApiInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin();
            System.debug('*** brokerCreditstr:' + brokerCreditstr);
            
            String zAccountQuery =  'SELECT Id, Name, SubscriptionID__c FROM Account WHERE ';
            Boolean isFirst = true;
            
            List<BrokerCredit> brokerCredits = (List<BrokerCredit>)JSON.deserialize(brokerCreditstr, List<BrokerCredit>.class);
            System.debug('*** brokerCredits:' + brokerCredits); 
            Map<String,BrokerCredit> subIdBrokerCredits = new Map<String,BrokerCredit>();  
            List<BrokerCredit> validatedCredits = new List<BrokerCredit>();
            
            for(BrokerCredit bc : brokerCredits) {
                subIdBrokerCredits.put(bc.subscriptionId, bc);
                validatedCredits.add(bc);
            }
            for(Subscriptions__c subscription : [SELECT Id,Name, Status__c, Contact__r.Name FROM Subscriptions__c 
                                                 WHERE  Name IN :subIdBrokerCredits.keyset()]){
                
                /****************/
                for(BrokerCredit b : brokerCredits) {
                    if(b.subscriptionId == subscription.Name) {
                        b.status = subscription.Status__c;
                        b.subscriberName = subscription.Contact__r.Name;
                    }
                }
                /****************/
                
                if (!isFirst)
                    zAccountQuery += ' OR ';
                
                zAccountQuery += 'SubscriptionID__c = \'' + subscription.Name + '\'';
                isFirst = false;
            } 
            //System.debug('zAccountQuery:' + zAccountQuery);
            if(!isFirst){
                List<Zuora.zObject> zAccounts = zApiInstance.zquery(zAccountQuery);
                for(Zuora.zObject zAccount : zAccounts) {
                    String subscriptionId = (String)zAccount.getValue('SubscriptionID__c');
                    String zAccountId = (String)zAccount.getValue('Id');
                    
                    for(BrokerCredit b : brokerCredits) {
                        if(b.subscriptionId == subscriptionId) {
                            b.zAccountId = zAccountId;
                        }
                    }                
                }
            } 
           // System.debug('*** brokerCredits:' + brokerCredits);
           list<SMS_CreditsAutomationHistory__c> invalidCreditHistoryUpdate = new list<SMS_CreditsAutomationHistory__c>();
            for(BrokerCredit bc: brokerCredits){
                bc.notes = '';
                if(String.isBlank(bc.status))
                    bc.notes = bc.notes + 'Subscription Id not available.';
                else if(bc.status != 'Active')
                    bc.notes = bc.notes + 'Subscription is Inactive.';
                    
                if(String.isBlank(bc.zAccountId) && String.isBlank(bc.notes))
                    bc.notes = bc.notes + 'Zoura Account details not available.';
                
                SMS_CreditsAutomationHistory__c objInvalidCredit = new SMS_CreditsAutomationHistory__c();
                if(bc.notes == ''){
                    bc.isValid = true;
                    if(bc.caHistoryId != null){
                        objInvalidCredit.Id = bc.caHistoryId;
                        objInvalidCredit.Zuora_Rate_Plan__c = bc.zRatePlanName;
                        objInvalidCredit.Zuora_Rate_Plan_Id__c = bc.zRatePlanId;
                        invalidCreditHistoryUpdate.add(objInvalidCredit);
                    }
                }
                else{
                    bc.isValid = false;
                    if(bc.caHistoryId != null){
                        objInvalidCredit.Id = bc.caHistoryId;
                        objInvalidCredit.Status_Message__c = bc.notes;
                        objInvalidCredit.Status__c = 'Failed';
                        invalidCreditHistoryUpdate.add(objInvalidCredit);
                    }
                }
            }
            
            if(!invalidCreditHistoryUpdate.isEmpty())
                update invalidCreditHistoryUpdate;
            
            return brokerCredits;
        }
        catch(Exception e) {
            return new List<BrokerCredit>();   
        }
    }
    
    @RemoteAction
    public Static List<CreditAdjustResponse> createRatePlan(String brokerCreditstr){

            System.debug('*** brokerCreditstr:' + brokerCreditstr);
            List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
            List<BrokerCredit> brokerCredits = (List<BrokerCredit>)JSON.deserialize(brokerCreditstr, List<BrokerCredit>.class);        
            
            Map<String,BrokerCredit> zAccountIdBrokerCredits= new Map<String,BrokerCredit>();
            list<SMS_CreditsAutomationHistory__c> processedBrokerCreditsHistory = new list<SMS_CreditsAutomationHistory__c>();
            List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
            List<String> zInvoiceIds = new List<String>();
            
            SMS_ZuoraUtil zApiInstance = new SMS_ZuoraUtil(); 
            Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin(); 
            List<CreditAdjustResponse> response = new List<CreditAdjustResponse>();          
            
            for(BrokerCredit bc : brokerCredits) {
                System.debug('*** Subscription:' + bc);
                system.debug('---processedBrokerCreditsHistory in for---'+ processedBrokerCreditsHistory);
                if(bc.isSelected) {
                                        
                    zAccountIdBrokerCredits.put(bc.zAccountId,bc);
                    Zuora.zApi.SubscribeRequest subscriptionRequest = getZuoraSubscriptionRequest(bc.zAccountId, bc.zRatePlanId, bc.zRatePlanChargeId, bc.totalCreditAmount, bc.fileName );
                    subscribeRequests.add(subscriptionRequest);
                    
                    if(subscribeRequests.size() == 50){
                        List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
                        System.debug('*** results:' + results );
                        String exceptionMsg = '';
                        for (Zuora.zApi.SubscribeResult result : results){

                            CreditAdjustResponse res = new CreditAdjustResponse();
                            BrokerCredit brc = zAccountIdBrokerCredits.get(result.AccountId);
                            SMS_CreditsAutomationHistory__c cah = new SMS_CreditsAutomationHistory__c();
                            system.debug('---brc--->'+brc);
                            if(brc != null){
                                cah.Id = brc.caHistoryId;
                                                                
                                if (!result.Success){
                                    Zuora.zObject[] errors = result.errors;
                                    for (Zuora.zObject error : errors)
                                        exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                    
                                    brc.zuoraStatus = exceptionMsg;
                                    brc.isValid = false;
                                    res.status = false;
                                    
                                    cah.Status__c = 'Failed';
                                    cah.Status_Message__c = 'exceptionMsg';
                                } 
                                else{
                                    res.status = true;
                                    res.zAccountId = result.AccountId;
                                    res.zAccountNumber = result.AccountNumber;
                                    res.zInvoiceId = result.InvoiceId; 
                                    res.zInvoiceNumber = result.InvoiceNumber;
                                    res.zSubscriptionId = result.SubscriptionId;
                                    res.zSubscriptionNumber = result.SubscriptionNumber;                              
                                    brc.zuoraStatus = 'Success';
                                    zInvoiceIds.add((String)result.InvoiceId);
                                    
                                    cah.Status__c = 'Success';
                                }
                                                                
                                response.add(res);   
                                zAccountIdBrokerCredits.put(brc.zAccountId,brc);
                                if(cah != null && cah.Id != null)
                                    processedBrokerCreditsHistory.add(cah);
                            }
                        }
                        subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
                    }
                }
            }
            
            if(subscribeRequests.size() > 0){
                system.debug('===subscribeRequests==>'+subscribeRequests);
                system.debug('---lstUpdateCAHistory in if---'+processedBrokerCreditsHistory);
                List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
                System.debug('*** results:' + results );
                String exceptionMsg = '';
                                                
                for (Zuora.zApi.SubscribeResult result : results){
                    
                    CreditAdjustResponse res = new CreditAdjustResponse();
                    BrokerCredit brc = zAccountIdBrokerCredits.get(result.AccountId);
                    SMS_CreditsAutomationHistory__c cah = new SMS_CreditsAutomationHistory__c();
                    cah.Id = brc.caHistoryId;
                       
                    if (!result.Success){
                        Zuora.zObject[] errors = result.errors;
                        for (Zuora.zObject error : errors)
                            exceptionMsg = exceptionMsg + 'zSubscribeCallException: ' + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') + '; ';                                    
                        brc.zuoraStatus = exceptionMsg;
                        brc.isValid = false;
                        res.status = false;
                        
                        cah.Status__c = 'Failed';
                        cah.Status_Message__c = 'exceptionMsg';                        
                    } 
                    else{
                        res.status = true;
                        res.zAccountId = result.AccountId;
                        res.zAccountNumber = result.AccountNumber;
                        res.zInvoiceId = result.InvoiceId; 
                        res.zInvoiceNumber = result.InvoiceNumber;
                        res.zSubscriptionId = result.SubscriptionId;
                        res.zSubscriptionNumber = result.SubscriptionNumber;                     
                        
                        brc.zuoraStatus = 'Success';
                        brc.processed = true;
                        brc.status = 'processed';
                        zInvoiceIds.add((String)result.InvoiceId);
                        
                        cah.Status__c = 'Success';
                        
                    }
                    zAccountIdBrokerCredits.put(brc.zAccountId,brc);
                    response.add(res);
                    processedBrokerCreditsHistory.add(cah);
                }
                subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
            } 
            processZInvoices(zInvoiceIds);
            sendEmail(zAccountIdBrokerCredits.values());          
            
            system.debug('---processedBrokerCreditsHistory-->'+processedBrokerCreditsHistory);
            if(processedBrokerCreditsHistory.size() > 0)
                update processedBrokerCreditsHistory;
                
            return response;
    }
    
    private Static void sendEmail(List<BrokerCredit> brokerCredits){
        List<String> emailAddresses = new List<String>();
        for(SMS_BrokerCredit_Emails__c emailIds : SMS_BrokerCredit_Emails__c.getall().values())
            emailAddresses.add(emailIds.Name);
        
        String header = 'Subscription Id, Subscriber Name, Subscription Status, Rate Plan Name, Total Credit Amount, Zuora Status, Notes \n';
        String finalstr = header ;
        for(BrokerCredit bc : brokerCredits) {
               String bcStr = bc.subscriptionId + ',' + bc.subscriberName + ',' + bc.status + ',' + bc.zRatePlanName + ',';
               bcStr = bcStr + bc.totalCreditAmount + ',' + bc.zuoraStatus + '\n'; 
                              
               finalstr = finalstr + bcStr;
        }
        Messaging.EmailFileAttachment brokerCreditResult = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalstr);
        String csvname= 'BrokerCreditResult.csv';
        brokerCreditResult.setFileName(csvname);
        brokerCreditResult.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = emailAddresses;
        String subject ='Broker Credits Summary';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Broker Credits Summary with zuora result status');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{brokerCreditResult});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       

    }
    
    private Static void processZInvoices(List<String> zInvoiceIds){
        SMS_ZuoraUtil zApiInstance = new SMS_ZuoraUtil(); 
        Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin(); 
            
        String zInvoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount FROM Invoice WHERE ';
        List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
        List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
        Integer i = 0;
        for(String zInvoiceId : zInvoiceIds){
            if(i != 0)
               zInvoiceQuery += ' OR '; 
            
            zInvoiceQuery += 'Id = \'' + zInvoiceId + '\'';
            i++;
            
            if(i == 199){
                List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
                zObjects = zApiInstance.zquery(zInvoiceQuery);
                i = 0;
                zInvoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount FROM Invoice WHERE ';
                zInvoices.addAll(zObjects);
            }
        }
        
        if(i > 0){
            List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
            zObjects = zApiInstance.zquery(zInvoiceQuery);
            i = 0;
            zInvoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount FROM Invoice WHERE ';
            zInvoices.addAll(zObjects);
        }
        String type;
        for(Zuora.zObject zInvoice : zInvoices){
            String zInvoiceId = (String)zInvoice.getValue('Id');
            Decimal balance = (Decimal)zInvoice.getValue('Balance');
            if(balance < 0){
                type = 'Increase';
                creditBalanceAdjustments.add(createCreditBalanceAdjustment(zInvoiceId,-balance,type));
            }            
            if(creditBalanceAdjustments.size() == 50) {
                List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments); 
                creditBalanceAdjustments = new List<Zuora.zObject>();
                system.debug('*** CreditBalance : ' + zSaveResultList );
            } 
        }
        
        if(creditBalanceAdjustments.size() > 0) {
            List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments); 
            creditBalanceAdjustments = new List<Zuora.zObject>();
            system.debug('*** CreditBalance : ' + zSaveResultList );
        } 
    }
    
    private Static Zuora.zObject createCreditBalanceAdjustment(String zInvoiceId, Decimal amount, String type){
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', type);
        adjustment.setValue('Amount', amount);
        
        return adjustment;
    }
    
       
     private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionrequest(String zAccountId, String zProductRatePlanId,
                                                                           String zProductRatePlanChargeId, Decimal Price, String fileName) {
        
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');     
        
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();

        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', zAccountId);
        
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = true;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false; 
        
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', effectiveDate);
        subscription.setValue('ServiceActivationDate', effectiveDate);
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('InitialTerm', '1');
        subscription.setValue('RenewalTerm', '1');
        subscription.setValue('AutoRenew', false);
        subscription.setValue('Notes', fileName);
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
        ratePlanCharge.setValue('Price', -Price);
        //ratePlanCharge.setValue('Description', description);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
        
        ratePlanDataList.add(ratePlanData);                  
        request.SubscriptionData.RatePlanData = ratePlanDataList;            
        
        return request;                 
    }
    
    public class BrokerCredit{
        public String subscriptionId { get; set; }
        public String zRatePlanName { get; set; }
        public String zRatePlanChargeName { get; set; }
        public String zRatePlanId { get; set; }
        public String zRatePlanChargeId { get; set; }
        public Decimal numOfCredits { get; set; }
        public Decimal totalCreditAmount { get; set; }
        public Boolean isSelected { get; set; }
        public Boolean isValid { get; set; }
        public String zAccountId { get; set; }
        public String notes { get; set; } 
        public String status { get; set; } 
        public String subscriberName { get; set; } 
        public String zuoraStatus { get; set; }
        public string fileName {get; set;}
        public boolean processed {get; set;}
        public string caHistoryId {get; set;}
    }
    
    public class BrokerCreditRatePlan{
        public String zProductName { get; set; }
        public String zProductId { get; set; }
        public String zRatePlanName { get; set; } 
        public String zRatePlanId { get; set; }
        public String zRatePlanChargeId { get; set; }
        public Decimal zChargeAmount { get; set; }
    } 
    
    public class CreditAdjustResponse {
        public Boolean status { get; set; }
        public String zAccountId { get; set; }
        public String zAccountNumber{ get; set; }
        public String zInvoiceId{ get; set; }
        public String zInvoiceNumber{ get; set; }
        public String zSubscriptionId{ get; set; }
        public String zSubscriptionNumber{ get; set; }
    }         
    
}