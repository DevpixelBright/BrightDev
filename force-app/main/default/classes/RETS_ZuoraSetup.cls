public class RETS_ZuoraSetup{
    private static SMS_ZuoraUtil zUtilInstance;
    private Static Zuora.zApi.SaveResult zSaveResult;
    private enum zOperation { zCREATE, zUPDATE }
    
    @future(callout=true)
    public Static void setupZuoraBrokerage(String accountId){
        Account sAccount;
        try{
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            sAccount = [SELECT Id, Name, FirstName, LastName, Account_Name__c, RETS_Billing_Type__c, ParentId,
                        RETS_BillingHasFullDiscount__c, State__c, City__c, Zip__c, Company_Type__c, Type,
                        Street_Number_Suffix__c, Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Zip_4__c,QAS_Mailing_Unit_Type__c,
                        Street_Number__c, Street_Name__c, QAS_Mailing_Street_Type__c ,QAS_Mailing_Street_Direction__c, QAS_Mailing_County__c, QAS_Mailing_Country__c
                        FROM   Account
                        WHERE  Id = :accountId                  
                       ];
                               
            String zAccountId = findZAccountId(sAccount.Id);   
                    
            if(String.isBlank(zAccountId)) 
                zAccountId = createZuoraAccount(sAccount, true);
            
            //SMS_ZuoraHistory.createSuccess('RETS_ZuoraSetup,' + sAccount.Name, null);
        }
        catch(Exception e){
            SMS_ZuoraHistory.createError(e, 'RETS_ZuoraSetup,' + sAccount.Name, null);
        }    
    }
    
    @future(callout=true)
    public static void setupZuoraVendor(String accountId) {
        Account sAccount;
        try{
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            sAccount = [SELECT Id, Name, FirstName, LastName, Account_Name__c, RETS_Billing_Type__c, ParentId,
                        RETS_BillingHasFullDiscount__c, State__c, City__c, Zip__c, Company_Type__c, Type, 
                        Street_Number_Suffix__c, Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Zip_4__c, QAS_Mailing_Unit_Type__c,
                        Street_Number__c, Street_Name__c, QAS_Mailing_Street_Type__c ,QAS_Mailing_Street_Direction__c, QAS_Mailing_County__c, QAS_Mailing_Country__c
                        FROM   Account
                        WHERE  Id = :accountId                  
                       ];
                               
            /*if(!((sAccount.Type == 'RETS') || (sAccount.Type == 'Residential' && sAccount.Company_Type__c == 'Broker Office')))
                throw new CustomException('Account is neither a Vendor Product nor a Brokerage');*/
            
            String zAccountId = findZAccountId(sAccount.Id);   
                    
            if(String.isBlank(zAccountId)){                     
                zAccountId = createZuoraAccount(sAccount, false);            
                createZuoraSubscription(zAccountId, sAccount.RETS_Billing_Type__c, sAccount.RETS_BillingHasFullDiscount__c);
              }
              else{
                  String zProductRatePlanId = RETS_Rate_Plan__c.getInstance(sAccount.RETS_Billing_Type__c).Zuora_ProductRatePlanId__c;
                  String zSubscriptionId = findZSubscription(zAccountId, zProductRatePlanId);
                  if(String.isBlank(zSubscriptionId))                  
                      createZuoraSubscription(zAccountId, sAccount.RETS_Billing_Type__c, sAccount.RETS_BillingHasFullDiscount__c);                                    
              }
          }
          catch(Exception e){
              SMS_ZuoraHistory.createError(e, 'RETS_ZuoraSetup,' + sAccount.Name, null);
          }             
    }
    
    /*
    @future(callout=true)
    public Static void changeBillingType(String accountId, String oldBillingType){
        zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        
        Account sAccount = [SELECT Id, Name, FirstName, LastName, Account_Name__c, RETS_Billing_Type__c,
                                   RETS_BillingHasFullDiscount__c, State__c, City__c, Zip__c, Company_Type__c, Type
                            FROM   Account
                            WHERE  Id = :accountId                  
                           ];
                           
        String zAccountId = findZAccountId(sAccount.Id);               
        
        String zOldRatePlanId = RETS_Rate_Plan__c.getInstance(oldBillingType).Zuora_ProductRatePlanId__c;              
        String zNewRatePlanId = RETS_Rate_Plan__c.getInstance(sAccount.RETS_Billing_Type__c).Zuora_ProductRatePlanId__c;
        
        String zOldSubscriptionId = findZSubscription(zAccountId, zOldRatePlanId);
        String zNewSubscriptionId = findZSubscription(zAccountId, zNewRatePlanId);
        
        if(String.isBlank(zNewSubscriptionId))                  
            createZuoraSubscription(zAccountId, sAccount.RETS_Billing_Type__c, sAccount.RETS_BillingHasFullDiscount__c);                                    
        else
            createZuoraAmendment(zNewSubscriptionId, true);
           
        if(String.isNotBlank(zOldSubscriptionId))                  
            createZuoraAmendment(zOldSubscriptionId, false);  
    }
    
    /*
    public Static void changeDiscount(String accountId, Boolean hasDiscount){
        zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        
        Account sAccount = [SELECT Id, Name, FirstName, LastName, Account_Name__c, RETS_Billing_Type__c,
                                   RETS_BillingHasFullDiscount__c, State__c, City__c, Zip__c, Company_Type__c, Type
                            FROM   Account
                            WHERE  Id = :accountId                  
                           ];
                           
        String zAccountId = findZAccountId(sAccount.Id);               

        String zDiscountRatePlanId = RETS_Rate_Plan__c.getInstance('Discount').Zuora_ProductRatePlanId__c;
        
        String zFoundDiscountRatePlanId = findZSubscription(zAccountId, zDiscountRatePlanId);
        
        if(hasDiscount){
            if(String.isBlank(zFoundDiscountRatePlanId)){
               // add discount
        }    }
        else{
            if(String.isNotBlank(zFoundDiscountRatePlanId))
            { // remove discount
            }
        }
    }*/
    
    /*private Static void createZuoraAmendment(String zSubscriptionId, Boolean autoRenew){
        Zuora.zApi.AmendRequest amendrequest = getAutoRenewAmendmentRequest(zSubscriptionId, autoRenew);
        List<Zuora.zApi.AmendRequest> amendRequestList = new List<Zuora.zApi.AmendRequest>();
        amendRequestList.add(amendrequest);
        Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
        amendRequestList.clear();
        system.debug('Amend Results :' + amendResults);
    }*/
    
    private Static String createZuoraAccount(Account sAccount, Boolean isBrokerage){
        /* Populate Zuora Account object */
        Zuora.zObject zAccount = new Zuora.zObject('Account');
        
        zAccount.setValue('CrmId', sAccount.Id);
        zAccount.setValue('Name', sAccount.Account_Name__c);
        zAccount.setValue('Currency', 'USD');
        zAccount.setValue('BillCycleDay', '1');
        zAccount.setValue('PaymentTerm', 'Due upon receipt');
        
        zAccount.setValue('Batch', 'Batch1');
        if(isBrokerage)
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
        if(isBrokerage){
            //get BOR contact
            Set<String> officeIds = new Set<String>();
            officeIds.add(sAccount.Id);
            if(String.isNotBlank(sAccount.ParentId))
                officeIds.add(sAccount.ParentId);
            
            Set<String> allOfficeIds = new Set<String>();
            for(Account a : [SELECT Id,Name,ParentId FROM Account WHERE Id IN :officeIds]){
                allOfficeIds.add(a.Id);
                if(String.isNotBlank(a.ParentId))
                    allOfficeIds.add(a.ParentId);
            }
            
            for(Relationship__c relationship : [SELECT  Id, Relationship_Type__c, Subscription__r.Contact__r.FirstName, Subscription__r.Contact__r.LastName 
                                                FROM    Relationship__c
                                                WHERE   Relationship_Type__c IN ('Broker Of Record')
                                                AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                AND     Broker_Office__c IN :allOfficeIds
                                                AND     Status__c = 'Active'
                                               ]){
                zContact.setValue('FirstName', relationship.Subscription__r.Contact__r.FirstName );
                zContact.setValue('LastName', relationship.Subscription__r.Contact__r.LastName);            
            }
        }
            
            //zContact.setValue('Address1', sAccount.Street_Number__c);
            //zContact.setValue('Address2', sAccount.Street_Name__c);
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
            
        //}
        
        zContact.setValue('State', sAccount.State__c);
        zContact.setValue('City', sAccount.City__c);
        //zContact.setValue('PostalCode', sAccount.Zip__c);  
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
    
    private Static void createZuoraSubscription(String zAccountId, String billingType, Boolean hasFullDiscount){
        String zProductRatePlanId = RETS_Rate_Plan__c.getInstance(billingType).Zuora_ProductRatePlanId__c;
        String zProductRatePlanChargeId = RETS_Rate_Plan__c.getInstance(billingType).Zuora_ProductRatePlanChargeId__c;
        String zDiscountRatePlanId = null;
        if(hasFullDiscount)
          zDiscountRatePlanId = RETS_Rate_Plan__c.getInstance('Discount').Zuora_ProductRatePlanId__c;
        
        Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanId, zProductRatePlanChargeId, zDiscountRatePlanId);
        List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(new List<Zuora.zApi.SubscribeRequest>{request}); 
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
    
    private Static String findZSubscription(String zAccountId, String zProductRatePlanId){
        String currentDate = DateTime.now().format('yyyy-MM-dd','PST');
        String zSubId = null;
        String subQuery = 'SELECT Id, Name, Status FROM Subscription WHERE AccountId = \'' + zAccountId + '\' AND IsCore__c = false AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        if (zSubscriptions.Size() == 0) 
            return null;
        
        Integer i = 0;
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        for (Zuora.zObject zSubscription : zSubscriptions) {
            String zSubscriptionId = (String)zSubscription.getValue('Id');

            if (i != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            i++;
        }
        
        system.debug('***Rate plan qury is '+ratePlansQuery);
        if(i != 0){
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);            
            system.debug('***zRatePlans ' + zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {                
                if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == zProductRatePlanId){
                    zSubId = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                    break;
                }                    
             }                     
         }
         
         return zSubId;
    }    
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId,
                                                                           String zProductRatePlanChargeId, String zDiscountRatePlanId) {   
        
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
        
        subscription.setValue('InitialTerm', '12');
        subscription.setValue('RenewalTerm', '12');
        
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', false);
        
        request.SubscriptionData.Subscription = subscription;
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');       
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);       
               
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
        ratePlanCharge.setValue('Quantity', '0');
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 

        ratePlanDataList.add(ratePlanData);
        
        if(String.isNotBlank(zDiscountRatePlanId)){
            Zuora.zObject discountPlan = new Zuora.zObject('RatePlan');
            discountPlan.setValue('ProductRatePlanId', zDiscountRatePlanId);
            Zuora.zObject discountRatePlanData = new Zuora.zObject('RatePlanData');
            discountRatePlanData.setValue('RatePlan', discountPlan);
            ratePlanDataList.add(discountRatePlanData);
         }
        
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
        
        return request;                 
    }
    /*
    private Static Zuora.zApi.AmendRequest getAutoRenewAmendmentRequest(String zSubscriptionId, Boolean autoRenew){
        
        String effectiveDate = Datetime.now().format('yyyy-MM-dd\'T\'00:00:00','PST'); 
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
        request.AmendOptions.generateInvoice = false;        
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    } 
    */
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
    
    public class CustomException extends Exception {}

}