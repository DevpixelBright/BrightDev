global class SMS_ComplinaneFine_Zuora implements Database.Batchable<Compliance_Fine__c>,Database.AllowsCallouts,Database.Stateful{
    /*
        This class is used generate an invoice in Zuora for Compliance Fine records which have "Ready to Bill" status
        
        Input to this class is the list of Compliance Fine record Ids
        1. Query Complaince Fine record for all the data that is to be sent to Zuora for billing
        2. Query Zuora for child account
        3. Query Zuora for the related core subscription.
        4. Create an amendment(add a product) to add the compliance fine
    */
    private enum zOperation { zCREATE, zUPDATE, zDELETE, zQUERY } 
    List<String> complianceFineIds;
    List<Compliance_Fine__c> complianceFines;
    Zuora.zApi.LoginResult zLoginResult;
    SMS_ZuoraUtil zUtilInstance;
    
    public SMS_ComplinaneFine_Zuora(List<String> complianceFineIds){
        this.complianceFineIds = new List<String>();
        this.complianceFineIds = complianceFineIds;
        
    }
    
    global List<Compliance_Fine__c> start(Database.BatchableContext BC){
        zUtilInstance = new SMS_ZuoraUtil();
        zLoginResult = zUtilInstance.zLogin();        
        
        complianceFines = [SELECT Id, Name, Subscription_ID__c, Fine_Amount__c, Zuora_Status__c,
                                  MLS_Number__c,Date_of_Fine__c,Compliance_Violation__r.Name,Violation__c
                           FROM   Compliance_Fine__c
                           WHERE  Id in :complianceFineIds];
        return complianceFines;
    }
    
    global void execute(Database.BatchableContext BC, List<Compliance_Fine__c> cFines){
        
        for (Compliance_Fine__c cFine : cFines) {
            
            try {
                
                String sSubscriptionId = cFine.Subscription_ID__c;
                String zProductId = SMS_Compliance_RatePlan__c.getInstance('Compliance Fine').Zuora_Product_Id__c;
                String zProductRatePlanId = SMS_Compliance_RatePlan__c.getInstance('Compliance Fine').Zuora_ProductRatePlan_Id__c;
                String zProductRatePlanChargeId = SMS_Compliance_RatePlan__c.getInstance('Compliance Fine').Zuora_ProductRatePlanCharge_Id__c;
                
                String accountQuery = 'SELECT Id,Name,AutoPay,SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + sSubscriptionId + '\'';
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);

                if (!(zAccounts.Size() == 1)) 
                    throw new CustomException('Zuora account does not exist'); 
                
                String zAccId = String.valueOf(zAccounts[0].getValue('Id'));
                try{
                    /***** SAL-2408 ****/
                    if(cFine.Fine_Amount__c >= 1000 && Boolean.valueOf(zAccounts[0].getValue('AutoPay'))){
                        Zuora.zObject accountChanges = new Zuora.zObject('Account');
    
                        accountChanges.setValue('Id', zAccId);
                        accountChanges.setValue('AutoPay', false);
            			system.debug('inside if before call');
                        callZuora(zOperation.zUPDATE, accountChanges);
                        system.debug('inside if after call');
                    }
                    system.debug('outside if');
                }catch(Exception ex){
                    system.debug(ex);
                }
                
                String currentDate = DateTime.now().format('yyyy-MM-dd','PST');
              //  String currentDate = datetime.newInstance((datetime.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss','PST'))).date(), time.newInstance(0,0,0,0)).format('yyyy-MM-dd\'T\'HH:mm:ss'); 
                String subQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, TermEndDate, Status FROM Subscription WHERE AccountId = \'' + zAccId + '\' AND IsCore__c = true AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
                List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);

                if (!(zSubscriptions.Size() > 0)) 
                    throw new CustomException('Zuora core interm subscription not found');                
                
                Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
                request.Amendments = new List <Zuora.zObject>();
                
                Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
                
                String description = 'MLS #: ' + cFine.MLS_Number__c + ' // ' +                                      
                                     'Date: ' + datetime.newInstance(cFine.Date_of_Fine__c, time.newInstance(0,0,0,0)).format('MM/dd/yyyy')  + ' // ' +  
                                     'Description: ' + cFine.Violation__c;                
                
                Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
                ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
                ratePlanCharge.setValue('Price', cFine.Fine_Amount__c);
                ratePlanCharge.setValue('Description', description);
                
                Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
                
                Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                ratePlanData.setValue('RatePlan', ratePlan);
                ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
                                      
                Zuora.zObject amendment = new Zuora.zObject('Amendment');
                amendment.setValue('Name', 'Add a New Product');
                amendment.setValue('SubscriptionId', String.valueOf(zSubscriptions[0].getValue('Id')));
                amendment.setValue('Type', 'NewProduct');
                amendment.setValue('RatePlanData',ratePlanData);
                
                amendment.setValue('ContractEffectiveDate', currentDate);
                amendment.setValue('ServiceActivationDate', currentDate);            
                
                request.Amendments.add(amendment);
                
                request.AmendOptions = new Zuora.zApi.AmendOptions();
                request.AmendOptions.generateInvoice = true;
                request.AmendOptions.processPayments = false;
                    
                
                List<Zuora.zApi.AmendRequest> amendRequestList  = new List<Zuora.zApi.AmendRequest>();  
                amendRequestList.add(request);
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);                                
                System.Debug('*** amendResults : '+ amendResults);
                
                SMS_ZuoraHistory.processZResults(amendResults,'SMS_ComplinaneFine_Zuora',cFine.Subscription_ID__c);
                cFine.Zuora_Status__c = 'Success'; 
                cFine.Status__c = 'Billed';
                SMS_ZuoraHistory.createSuccess('SMS_ComplinaneFine_Zuora',cFine.Subscription_ID__c);                
            }
            catch(Exception e) {
                cFine.Zuora_Status__c = 'Failed';
                cFine.Zuora_ErrorMessage__c = e.getMessage();
                
                system.debug('*** e.getMessage(): ' + e.getMessage());
                SMS_ZuoraHistory.createError(e,'SMS_ComplinaneFine_Zuora',cFine.Subscription_ID__c);
            } 
            system.debug('*** cFine : ' + cFine);
            update cFine;           
        }
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        return callZuora(operation, new List<Zuora.zObject> { content });
    }  
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, List<Zuora.zObject> zObjectList) {
        List<Zuora.zApi.SaveResult> zSaveResultList;
        
        if (operation == zOperation.zCREATE)
            zSaveResultList = zUtilInstance.zcreate(zObjectList);
        else if (operation == zOperation.zUPDATE)
            zSaveResultList = zUtilInstance.zupdate(zObjectList);
        else
            throw new CustomException('Illegal Zuora Operation');

        return !zSaveResultList.isEmpty() ? zSaveResultList[0] : null;
    }
    
    public Class CustomException extends Exception {}    
}