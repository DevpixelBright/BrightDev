public class GovernmentAgency_Class {
    private static SMS_ZuoraUtil zUtilInstance;
    public static  Zuora.zApi.LoginResult zLoginResult;
    private Static Zuora.zApi.SaveResult zSaveResult;
    private enum zOperation { zCREATE, zUPDATE }
    public static List<Zuora.zApi.AmendRequest> amendRequestList;
    public static List<Zuora.zApi.SubscribeRequest> subRequestList;
    
    
    public static List<Aggregateresult> actCount {get; set;}
    public static Subscriptions__c sub {get;set;}
    public static String zAccId {get;set;}
    public static String zSubId {get;set;}
    public static Integer subCount {get;set;}
    public static Decimal term {get;set;}
    
    public static String setupfeeRatePlanId {get;set;}
    public static String productRatePlanId {get;set;}
    private Static List<String> zSubscriptionIDs;
    public static String zRateplanId {get;set;}
    
    
    
    @future(callout=true)
    public Static void setupZuoraGovtAgency(String accountId){
        Account sAccount;
        try{
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            sAccount = [SELECT Id, Name, FirstName, Billing_Period__c, LastName, Account_Name__c, ParentId, State__c, City__c, Zip__c, Company_Type__c, Type,
                        Street_Number_Suffix__c, Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Zip_4__c,QAS_Mailing_Unit_Type__c,
                        Street_Number__c, Street_Name__c, QAS_Mailing_Street_Type__c ,QAS_Mailing_Street_Direction__c, QAS_Mailing_County__c,
                        QAS_Mailing_Country__c
                        FROM   Account
                        WHERE  Id = :accountId 
                        AND    Type = 'Government Agency'
                       ];
            
            String zAccountId = findZAccountId(sAccount.Id);   
            
            if(String.isBlank(zAccountId)){
                zAccountId = createZuoraAccount(sAccount, true);
                createZuoraSubscription(zAccountId, sAccount.Billing_Period__c);
            }
            
        }
        catch(Exception e){
            SMS_ZuoraHistory.createError(e, 'GovernmentAgency_Class,' + sAccount.Name, null);
        }    
    }
    
    
    @TestVisible private static Integer updateActivecount(Subscriptions__c subscription){
        
        List<Aggregateresult> actCount = [SELECT count(id)
                                          from 	Subscriptions__c 
                                          WHERE  Status__c = 'Active' 
                                          AND    Contact_Type__c = 'Government Agency'
                                          AND 	Related_Location_Broker_Office__c = :subscription.Related_Location_Broker_Office__c
                                         ];
        if(!actCount.isEmpty()){
            return (Integer)actCount[0].get('expr0');
        }
        return 0;
        
    }
    
    @Future(callout = true)
    Public static void createOrUpdateGASubscription(String subscriptionId, Boolean addSetupFee){
        system.debug('****subscriptionId'+subscriptionId);
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin();
        zSubscriptionIDs = new List<String>();
        subRequestList  = new List<Zuora.zApi.SubscribeRequest>();
        amendRequestList = new List<Zuora.zApi.AmendRequest>();
        
        try{
            Subscriptions__c subs = [SELECT Id,Name, Related_Location_Broker_Office__c, Billing_Period__c 
                                     FROM Subscriptions__c WHERE Id =:subscriptionId];
            Integer subCount = updateActivecount(subs); 
            
            Subscriptions__c subUpdate = new Subscriptions__c();
            
            productRatePlanId = Government_Agency_Rateplans__c.getInstance(subs.Billing_Period__c).Zuora_Product_Rate_Plan_Id__c;
            
            subUpdate.Id = subscriptionId;        
            zAccId = subs.Related_Location_Broker_Office__c;
            
            String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00');
            
            String zProdID = '';
            String zProductRatePlanId = ''; 
            String zProductRatePlanChargeId='';
            String description = '';  
            String prefix_string = '';
            ID crmId = subs.Related_Location_Broker_Office__c;
            
            getZuoraDetails(crmId);
            
            if(subCount == 0){
                prefix_string = 'No products';
            }else if(subCount == 1){
                prefix_string = subCount + ' Government Agency Subscription';
            }else if(subCount > 1){
                prefix_string = subCount + ' Government Agency Subscriptions';                          
            }
            
            description = prefix_string;
            
            zProdID = Government_Agency_Rateplans__c.getInstance(subs.Billing_Period__c).Zuora_Product_Id__c;
        	zProductRatePlanId = Government_Agency_Rateplans__c.getInstance(subs.Billing_Period__c).Zuora_Product_Rate_Plan_Id__c;
        	zProductRatePlanChargeId = Government_Agency_Rateplans__c.getInstance(subs.Billing_Period__c).Zuora_Product_Rate_Plan_Charge_Id__c;
            Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zsubID,zProductRatePlanId,zProductRatePlanChargeId,subCount,description ,effectiveDate, 'UpdateProduct');
                system.debug('Product update amendRequest :' + amendrequest );
                amendRequestList.add(amendrequest);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                system.debug('amendResults :' + amendResults );
                amendRequestList.clear();
            if(addSetupFee){
                createSetupfeeSubscription(subscriptionId);
            }
                
            
        }catch (Exception e){
            system.debug('error message '+e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'GovernmentAgency_Class, Account: ' + subscriptionId, null);
        }
    }
    
   // @Future(callout = true) 
    Public static void createSetupfeeSubscription(String subscriptionId){
        
        system.debug('****subscriptionId'+subscriptionId);
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin();
        zSubscriptionIDs = new List<String>();
        subRequestList  = new List<Zuora.zApi.SubscribeRequest>();
        amendRequestList = new List<Zuora.zApi.AmendRequest>();
        
        try{
            Subscriptions__c subs = [SELECT Id,Name, Related_Location_Broker_Office__c, Billing_Period__c 
                                     FROM Subscriptions__c WHERE Id =:subscriptionId];
            Integer subCount = updateActivecount(subs); 
            
            productRatePlanId = Government_Agency_Rateplans__c.getInstance('Setup Fee').Zuora_Product_Rate_Plan_Id__c;
            zAccId = subs.Related_Location_Broker_Office__c;           
            String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00');
            
            String zProdID = '';
            String zProductRatePlanId = ''; 
            String zProductRatePlanChargeId='';
            String description = '';  
            String prefix_string = '';
            ID crmId = subs.Related_Location_Broker_Office__c;
            
            getZuoraDetails(crmId);
             
            zProdID = Government_Agency_Rateplans__c.getInstance('Setup Fee').Zuora_Product_Id__c;
            zProductRatePlanId = Government_Agency_Rateplans__c.getInstance('Setup Fee').Zuora_Product_Rate_Plan_Id__c;
            zProductRatePlanChargeId = Government_Agency_Rateplans__c.getInstance('Setup Fee').Zuora_Product_Rate_Plan_Charge_Id__c;
            system.debug('zProductRatePlanId :' + zProductRatePlanId );
            system.debug('zProductRatePlanChargeId :' + zProductRatePlanChargeId );
            String BillingPeriod = 'Setup Fee' ;
            description = 'Set up Fee'; 

                Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccId,zProductRatePlanId,zProductRatePlanChargeId,BillingPeriod,description);
                system.debug('Product update amendRequest :' + request );
                subRequestList.add(request);
                system.debug('Product update amendRequest :' + request );
                List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subRequestList); 
                system.debug('Product update amendRequest :' + results );
 
        }catch (Exception e){
            system.debug('error message '+e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'GovernmentAgency_Class, Account: ' + subscriptionId, null);
        }
    }
    
    @TestVisible 
    
    private static void getZuoraDetails(String uniqueid){
        String accountQuery = 'SELECT Id,Name FROM Account WHERE ';
        accountQuery += ' CrmId LIKE \'%'+ uniqueid + '%\'';
        
        system.debug('***accountQuery'+accountQuery);
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        if (!(zAccounts.Size() == 1)) 
            throw new CustomException('Zuora account does not exist'); 
        
        Integer a = 0;
        zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        String currentDate = DateTime.now().format('yyyy-MM-dd');
        
        String subQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, Status FROM Subscription WHERE AccountId = \'' + zAccId + '\' AND IsCore__c = false AND AutoRenew = true AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            system.debug('****'+zSubscription.getValue('Id'));
            zSubscriptionIDs.add(String.valueOf(zSubscription.getValue('Id')));
        }
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        system.debug('****ratePlansQuery'+ratePlansQuery);
        for (String zSubscriptionId : zSubscriptionIDs) {
            if (a != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            a++;
        }
        system.debug('***Rate plan qury is '+ratePlansQuery);
        if(a != 0){
            
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);
            if (!(zRateplans.Size() > 0)) 
                throw new CustomException('Zuora Rateplan not found');
            system.debug('***zRatePlans '+zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {
                if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == productRatePlanId ){
                    zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                    zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                    break;
                }
            }
            system.debug('****zRateplanId  '+zRateplanId);
            system.debug('***zsubID   '+zsubID);
        }
    }
    
    @TestVisible 
    private Static Zuora.zApi.AmendRequest getProductAmendmentRequest(String zSubscriptionId,String zProductRatePlanId,String zProductRatePlanChargeId,Decimal quantity,String description, String effectiveDate, String reqType) {
        
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
        
        amendment.setValue('Type', reqType);
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
    
    private Static String findZAccountId(String sAccountId){
        String query = 'SELECT Id, Status FROM Account WHERE CrmId LIKE \'' + sAccountId + '%\'';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(query); //will be used while writing test classes
        system.debug('*** zAccounts :' + zAccounts );
        
        if(zAccounts.size() > 0)
            return (String)zAccounts[0].getValue('Id');
        else
            return null;            
    }
    
    private Static void createZuoraSubscription(String zAccountId, String billingPeriod){
        String zProductId = Government_Agency_Rateplans__c.getInstance(billingPeriod).Zuora_Product_Id__c;
        String zProductRatePlanId = Government_Agency_Rateplans__c.getInstance(billingPeriod).Zuora_Product_Rate_Plan_Id__c;
        String zProductRatePlanChargeId = Government_Agency_Rateplans__c.getInstance(billingPeriod).Zuora_Product_Rate_Plan_Charge_Id__c;        
        String description = 'No products';
        Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanId, zProductRatePlanChargeId,billingPeriod,description);
        List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(new List<Zuora.zApi.SubscribeRequest>{request}); 
    }  
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId,
                                                                           String zProductRatePlanChargeId, String billingPeriod, String description) {   
                                                                               
                                                                               String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST'); 
                                                                               Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
                                                                               
                                                                               request.ZAccount = new Zuora.zObject('Account');
                                                                               request.ZAccount.setValue('Id', zAccountId);
                                                                               
                                                                               request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
                                                                               request.SubscribeOptions.GenerateInvoice = false;
                                                                               request.SubscribeOptions.ProcessPayments = false;
                                                                               
                                                                               request.PreviewOptions = new Zuora.zApi.PreviewOptions();
                                                                               request.PreviewOptions.EnablePreviewMode = false;
                                                                               
                                                                               request.SubscriptionData = new Zuora.zApi.SubscriptionData();
                                                                               
                                                                               Zuora.zObject subscription = new Zuora.zObject('Subscription');
                                                                               subscription.setValue('ContractEffectiveDate', effectiveDate);
                                                                               subscription.setValue('ServiceActivationDate', effectiveDate);
                                                                               subscription.setValue('TermType', 'TERMED');    
                                                                               subscription.setValue('AutoRenew', true);
                                                                               subscription.setValue('IsCore__c', false);
                                                                               
                                                                               if(billingPeriod == 'Annual'){
                                                                                   subscription.setValue('InitialTerm', '12');
                                                                                   subscription.setValue('RenewalTerm', '12');
                                                                               }else if(billingPeriod == 'Quarterly'){
                                                                                   subscription.setValue('InitialTerm', '3');
                                                                                   subscription.setValue('RenewalTerm', '3');
                                                                               }else if(billingPeriod == 'Setup Fee'){
                                                                                   subscription.setValue('InitialTerm', '1');
                                                                                   subscription.setValue('RenewalTerm', '1');
                                                                                   subscription.setValue('AutoRenew', false);
                                                                               }
                                                                               
                                                                               request.SubscriptionData.Subscription = subscription;
                                                                               
                                                                               List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
                                                                               Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');       
                                                                               ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);       
                                                                               
                                                                               Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
                                                                               ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
                                                                               ratePlanCharge.setValue('Description', description);
                                                                               if(billingPeriod == 'Setup Fee'){
                                                                               ratePlanCharge.setValue('Quantity', '1');
                                                                               }
                                                                               else{
                                                                                   ratePlanCharge.setValue('Quantity', '0');
                                                                               }
                                                                               
                                                                               Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                                                                               ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
                                                                               
                                                                               Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                                                                               ratePlanData.setValue('RatePlan', ratePlan);
                                                                               ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
                                                                               
                                                                               ratePlanDataList.add(ratePlanData);
                                                                               request.SubscriptionData.RatePlanData = ratePlanDataList;           
                                                                               
                                                                               return request;                 
                                                                           }
    
    private Static Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject> { content };
            List<Zuora.zApi.SaveResult> zSaveResultList;
        zSaveResult = new Zuora.zApi.SaveResult();
        
        system.debug('** content :' + content );
        
        if (operation == zOperation.zCREATE) {
            zSaveResultList = zUtilInstance.zcreate(zObjectList); //will be used while writing test classes
        }
        else if (operation == zOperation.zUPDATE){
            zSaveResultList = zUtilInstance.zupdate(zObjectList); //will be used while writing test classes
        }
        else
            throw new CustomException('Illegal Zuora Operation');
        
        system.debug('*** zSaveResultList : ' + zSaveResultList);
        zSaveResult = !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
        
        return zSaveResult;
    }
    
    private Static String createZuoraAccount(Account sAccount, Boolean isGovt){
        /* Populate Zuora Account object */
        Zuora.zObject zAccount = new Zuora.zObject('Account');
        
        zAccount.setValue('CrmId', sAccount.Id);
        zAccount.setValue('Name', sAccount.Account_Name__c);
        zAccount.setValue('Currency', 'USD');
        zAccount.setValue('BillCycleDay', '1');
        zAccount.setValue('PaymentTerm', 'Due upon receipt');
        
        zAccount.setValue('Batch', 'Batch1');
        if(isGovt)
            zAccount.setValue('Batch', 'Batch11');
        
        zAccount.setValue('Status', 'Draft');
        zAccount.setValue('AccountNumber', sAccount.Name);        
        
        /* Create Zuora Account in draft status */
        callZuora(zOperation.zCREATE, zAccount);
        
        if (zSaveResult == null)
            throw new CustomException('Error Creating Zuora Account');    
        
        String zAccountId = zSaveResult.Id;       
        
        /* Populate Zuora Contact object */
        Zuora.zObject zContact = new Zuora.zObject('Contact');
        
        zContact.setValue('FirstName', sAccount.Name);
        zContact.setValue('LastName', sAccount.Account_Name__c);
        zContact.setValue('County', sAccount.QAS_Mailing_County__c);
        
        string addr1 = '';
        if(sAccount.Street_Number__c != null )
            addr1 = sAccount.Street_Number__c+' ';
        if(sAccount.Street_Number_Suffix__c != null )
            addr1 += sAccount.Street_Number_Suffix__c+' ';
        if(sAccount.Street_Name__c != null )
            addr1 += sAccount.Street_Name__c+' ';
        if(sAccount.QAS_Mailing_Street_Type__c != null )
            addr1 += sAccount.QAS_Mailing_Street_Type__c+' ';
        if(sAccount.QAS_Mailing_Street_Direction__c != null )
            addr1 += sAccount.QAS_Mailing_Street_Direction__c;
        
        string addr2 = '';
        if(sAccount.QAS_Mailing_Unit_Type__c != null )
            addr2 = sAccount.QAS_Mailing_Unit_Type__c+' ';
        if(sAccount.Unit__c != null )
            addr2 += sAccount.Unit__c;
        
        
        zContact.setValue('Address1', addr1 );
        zContact.setValue('Address2', addr2 );
        
        system.debug('---addr1-->'+addr1+'---addr2--'+addr2);
        
        zContact.setValue('State', sAccount.State__c);
        zContact.setValue('City', sAccount.City__c);
        zContact.setValue('Country', 'United States');
        zContact.setValue('AccountId', zAccountId);
        
        
        string pstCode;
        if(sAccount.Zip__c != null )
            pstCode = sAccount.Zip__c ;
        if(sAccount.Zip_4__c != null )
            pstCode += '-'+sAccount.Zip_4__c ;
        zContact.setValue('PostalCode', pstCode);
        
        String zContactId;        
        callZuora(zOperation.zCREATE, zContact);        
        if (zSaveResult == null)
            throw new CustomException('Error Creating Zuora Contact');
        
        zContactId = zSaveResult.Id;
        
        Zuora.zObject zUpdateAccount = new Zuora.zObject('Account');
        zUpdateAccount.setValue('Id', zAccountId);
        zUpdateAccount.setValue('BillToId', zContactId);
        zUpdateAccount.setValue('SoldToId', zContactId);
        zUpdateAccount.setValue('Status', 'Active'); 
        
        /* Activate Zuora Account */
        callZuora(zOperation.zUPDATE, zUpdateAccount);
        
        if (zSaveResult == null)
            throw new CustomException('Error Activating Zuora Account');
        
        return zAccountId;
    }
    public class CustomException extends Exception {}
    
}