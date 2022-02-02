public class SMS_SecondaryCredits{
    /*
        Query Zuora__ZInvoice__c with negative balance.
        query zuora for invoice ids 
        transfer negative amount to credit balance
    */
    
    List<Zuora__ZInvoice__c> zNegativeInvoices;
    Set<String> secondarySubscriptionIds;
    Map<String,Subscriptions__c> subscriptions;
    public String errorMessage { get; set; }
    public Map<String,SecondaryCredit> secondaryCreditsMap  { get; set; }
    public List<SecondaryCredit> secondaryCredits { get; set; }
    public String secondaryCreditsJson { get; set; }
    Map<String,List<Zuora__ZInvoice__c>> subscriptionIdZInvoices ;
    Set<String> contactIds;
    SMS_ZuoraUtil zApiInstance;
    Zuora.zApi.LoginResult zLoginResult;
    Map<String,SecondaryCredit> zAccountIdSecondaryCredits;
    List<String> zInvoiceIds;

    public SMS_SecondaryCredits(){
        errorMessage = 'No Error';
        zAccountIdSecondaryCredits = new Map<String,SecondaryCredit>();
        zNegativeInvoices = new List<Zuora__ZInvoice__c>();
        secondarySubscriptionIds = new Set<String>();
        secondaryCreditsMap = new Map<String,SecondaryCredit>();
        subscriptionIdZInvoices = new Map<String,List<Zuora__ZInvoice__c>>();
        contactIds = new Set<String>();        
        secondaryCredits = new List<SecondaryCredit>();
        zApiInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zApiInstance.zlogin();
        subscriptions = new Map<String,Subscriptions__c>();
        
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>(); 
        Map<String,Zuora.zObject> subscriptionIdZAccount = new Map<String,Zuora.zObject>();      
        
        Map<String,String> secondaryPrimaryIds = new Map<String,String>();
        Map<String,String> subscriptionContactIds = new Map<String,String>();                
        
        Map<String,String> contactPrimarySubscriptionIds = new Map<String,String>();
        Map<String,Set<String>> contactSecondarySubscriptionIds = new Map<String,Set<String>>();
        
        findSubscriptionsWithCreditBalances();
        findSubscriptionsWithNegativeInvoices();
            
        if(secondarySubscriptionIds.size() > 0){
            for(Subscriptions__c subscription : [SELECT Id, Name, Status__c, Contact__c, Contact__r.Name, Primary__c 
                                                 FROM   Subscriptions__c
                                                 WHERE  Contact__c IN :contactIds limit 10
                                                ]){
                subscriptions.put(subscription.Name, subscription);            
                system.debug('*** subscription.Name : ' + subscription);
                system.debug('*** subscription.Name : ' + secondarySubscriptionIds);
                if(subscription.Primary__c)
                    contactPrimarySubscriptionIds.put(subscription.Contact__c,subscription.Name);
                else {
                    if(secondarySubscriptionIds.contains(subscription.Name)){
                        if(!contactSecondarySubscriptionIds.keyset().contains(subscription.Contact__c)) 
                            contactSecondarySubscriptionIds.put(subscription.Contact__c, new Set<String>()) ; 
                                
                        contactSecondarySubscriptionIds.get(subscription.Contact__c).add(subscription.Name);
                    }
                }                                           
            }
            
            for(String contactId : contactSecondarySubscriptionIds.keyset()){
                for(String subscriptionId : contactSecondarySubscriptionIds.get(contactId)){
                    if(secondarySubscriptionIds.contains(subscriptionId))
                        secondaryPrimaryIds.put(subscriptionId,contactPrimarySubscriptionIds.get(contactId));
                }
            }
            
            String zAccountQuery = 'SELECT Id, Name, Balance, CreditBalance, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE ';
            Integer i = 0;
            zAccounts = new List<Zuora.zObject>();
                
            for(String subscriptionId : subscriptions.keyset()){
                 if(i != 0)
                    zAccountQuery += ' OR '; 
                
                zAccountQuery += 'SubscriptionID__c = \'' + subscriptionId + '\'';
                i++;
                
                if(i == 199){
                    List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
                    zObjects = zApiInstance.zquery(zAccountQuery);
                    i = 0;
                    zAccountQuery = 'SELECT Id, Name, Balance, CreditBalance, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE ';
                    zAccounts.addAll(zObjects);
                }
            }
            
            if(i != 0){
                List<Zuora.zObject> zObjects = new List<Zuora.zObject>();
                zObjects = zApiInstance.zquery(zAccountQuery);
                zAccounts.addAll(zObjects);
            }
            
            for(Zuora.zObject zAccount : zAccounts){
                String subscriptionId = (String)zAccount.getValue('SubscriptionID__c');
                subscriptionIdZAccount.put(subscriptionId, zAccount);
                try{
                    SecondaryCredit sc = secondaryCreditsMap.get(subscriptionId);
                    sc.creditBalance = (Decimal)zAccount.getValue('CreditBalance');
                    sc.credits = sc.creditBalance + sc.invoiceBalance;
                }
                catch(Exception e){}            
            }
            
            for(String secondarySubscriptionId : secondaryCreditsMap.keyset()){
                SecondaryCredit sc = secondaryCreditsMap.get(secondarySubscriptionId);
                String primarySubscriptionId = secondaryPrimaryIds.get(secondarySubscriptionId);  
                
                if(String.isNotBlank(primarySubscriptionId)){        
                    Subscriptions__c primarySubscription = subscriptions.get(primarySubscriptionId);                              
                    Zuora.zObject zPrimaryAccount = subscriptionIdZAccount.get(primarySubscriptionId);                        
                    
                    sc.primaryId = primarySubscription.Name;
                    sc.primaryStatus = primarySubscription.Status__c;
                    sc.primaryContact = primarySubscription.Contact__r.Name;
                    sc.isSelected = true;
                    sc.isValid = true;
                    try{
                        sc.zPrimaryAccountId = (String)zPrimaryAccount.getValue('Id');
                        zAccountIdSecondaryCredits.put(sc.zPrimaryAccountId ,sc);
                    }
                    catch(Exception e){
                        sc.isSelected = false;
                        sc.isValid = false;
                    }
                }                    
                secondaryCreditsMap.put(secondarySubscriptionId,sc);
                zAccountIdSecondaryCredits.put(sc.zSecondaryAccountId ,sc);
            }                
            secondaryCredits.addAll(secondaryCreditsMap.values());
        }
        
        if(secondaryCredits.Size() > 0)
            secondaryCreditsJson = JSON.Serialize(secondaryCredits);
        else
            secondaryCreditsJson = '[]';      
    }
    
    public void findSubscriptionsWithCreditBalances(){
                       
        for(Zuora__CustomerAccount__c ba : [SELECT Id, Name, SubscriptionID__c, Zuora__Credit_Balance__c, Zuora__Zuora_Id__c,
                                                   Subscription__r.Contact__r.Name, Subscription__r.Status__c,
                                                   Subscription__r.Primary__c,Subscription__r.Contact__c 
                                            FROM   Zuora__CustomerAccount__c
                                            WHERE  Subscription__r.Primary__c = false
                                            AND    Zuora__Credit_Balance__c > 0
                                            AND    SubscriptionID__c != null limit 10
                                           ]){                                    
                    
            String secondarySubscriptionId = ba.SubscriptionID__c;
            secondarySubscriptionIds.add(secondarySubscriptionId);
            contactIds.add(ba.Subscription__r.Contact__c);
            System.debug('*** contact Id: ' + ba.Subscription__r.Contact__c);
            SecondaryCredit sc = new SecondaryCredit();
            if(secondaryCreditsMap.keyset().contains(secondarySubscriptionId)){
                sc = secondaryCreditsMap.get(secondarySubscriptionId);
                sc.creditBalance = ba.Zuora__Credit_Balance__c;
            }
            else{
                sc.secondaryId = secondarySubscriptionId;
                sc.secondaryStatus = ba.Subscription__r.Status__c;
                sc.secondaryContact = ba.Subscription__r.Contact__r.Name;
                sc.zSecondaryAccountId = ba.Zuora__Zuora_Id__c;
                sc.creditBalance = ba.Zuora__Credit_Balance__c;
            }
            secondaryCreditsMap.put(secondarySubscriptionId,sc);             
        }
    }
    
    public void findSubscriptionsWithNegativeInvoices(){
               
        for(Zuora__ZInvoice__c zInvoice : [SELECT Zuora__Zuora_Id__c, Zuora__Balance2__c,Zuora__TotalAmount__c ,
                                                  Zuora__BillingAccount__r.SubscriptionID__c, Zuora__BillingAccount__r.Zuora__Zuora_Id__c,
                                                  Zuora__BillingAccount__r.Subscription__r.Name, Zuora__BillingAccount__r.Subscription__r.Primary__c, 
                                                  Zuora__BillingAccount__r.Subscription__r.Contact__c, Zuora__BillingAccount__r.Subscription__r.Contact__r.Name, 
                                                  Zuora__BillingAccount__r.Subscription__r.Status__c                                    
                                           FROM   Zuora__ZInvoice__c 
                                           WHERE  Zuora__Balance2__c < 0
                                          ]){
            if(String.isNotBlank(zInvoice.Zuora__BillingAccount__r.SubscriptionID__c)){
                if(!subscriptionIdZInvoices.keyset().contains(zInvoice.Zuora__BillingAccount__r.SubscriptionID__c))
                    subscriptionIdZInvoices.put(zInvoice.Zuora__BillingAccount__r.SubscriptionID__c, new List<Zuora__ZInvoice__c >());
                
                subscriptionIdZInvoices.get(zInvoice.Zuora__BillingAccount__r.SubscriptionID__c).add(zInvoice); 
                               
                if(!zInvoice.Zuora__BillingAccount__r.Subscription__r.Primary__c){
                    String secondarySubscriptionId = zInvoice.Zuora__BillingAccount__r.SubscriptionID__c;
                    secondarySubscriptionIds.add(secondarySubscriptionId);
                    contactIds.add(zInvoice.Zuora__BillingAccount__r.Subscription__r.Contact__c);
                    
                    SecondaryCredit sc = new SecondaryCredit();
                    if(secondaryCreditsMap.keyset().contains(secondarySubscriptionId)){
                        sc = secondaryCreditsMap.get(secondarySubscriptionId);
                        sc.invoiceBalance = sc.invoiceBalance - zInvoice.Zuora__Balance2__c;
                    }
                    else{
                        sc.secondaryId = secondarySubscriptionId;
                        sc.secondaryStatus = zInvoice.Zuora__BillingAccount__r.Subscription__r.Status__c;
                        sc.secondaryContact = zInvoice.Zuora__BillingAccount__r.Subscription__r.Contact__r.Name;
                        sc.zSecondaryAccountId = zInvoice.Zuora__BillingAccount__r.Zuora__Zuora_Id__c;
                        sc.invoiceBalance = -zInvoice.Zuora__Balance2__c;
                    }
                    secondaryCreditsMap.put(secondarySubscriptionId,sc);
                } 
            }               
        }    
    }
    
    public void test(){
        System.debug('*** secondaryCreditsJson: ' + secondaryCreditsJson);
        secondaryCredits = (List<SecondaryCredit>)JSON.deserialize(secondaryCreditsJson, List<SecondaryCredit>.class);   
        for(SecondaryCredit sc : secondaryCredits){
            if(sc.isSelected)
                system.debug(sc.secondaryId);
        } 
        transferToCreditBalance();   
    }
    
    public void transferToCreditBalance(){
        String type = 'Increase';
        List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
        for(SecondaryCredit sc : secondaryCredits){
            if(sc.isSelected){
                String primarySubscriptionId = sc.primaryId;
                String secondarySubscriptionId = sc.secondaryId;
                System.debug('*** subscriptionIdZInvoices:' + subscriptionIdZInvoices);
                System.debug('*** secondarySubscriptionId:' + secondarySubscriptionId);
                if(subscriptionIdZInvoices.keyset().contains(secondarySubscriptionId)){
                    for(Zuora__ZInvoice__c zInvoice : subscriptionIdZInvoices.get(secondarySubscriptionId)){
                        creditBalanceAdjustments.add(createCreditBalanceAdjustment(zInvoice.Zuora__Zuora_Id__c, -zInvoice.Zuora__Balance2__c ,type));
                        if(creditBalanceAdjustments.size() == 50) {
                            List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments);                            
                            system.debug('*** CreditBalance : ' + zSaveResultList ); 
                            String exceptionMsg;
                            for (Zuora.zApi.SaveResult result : zSaveResultList){                            
                                if (!result.Success){
                                    //SecondaryCredit src = zAccountIdSecondaryCredits.get(result.AccountId);       
                                    //src.isConverted = false;
                                    //zAccountIdSecondaryCredits.put(result.AccountId,src);
                                }            
                            }
                            creditBalanceAdjustments = new List<Zuora.zObject>();
                        }                        
                    }
                }
                
                if(subscriptionIdZInvoices.keyset().contains(primarySubscriptionId)){
                    for(Zuora__ZInvoice__c zInvoice : subscriptionIdZInvoices.get(primarySubscriptionId)){
                        creditBalanceAdjustments.add(createCreditBalanceAdjustment(zInvoice.Zuora__Zuora_Id__c, -zInvoice.Zuora__Balance2__c ,type));
                        if(creditBalanceAdjustments.size() == 50) {
                            List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments); 
                            creditBalanceAdjustments = new List<Zuora.zObject>();
                            system.debug('*** CreditBalance : ' + zSaveResultList );
                        }                        
                    }
                }                             
            }
        }
        if(creditBalanceAdjustments.size() > 0) {
            List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments); 
            creditBalanceAdjustments = new List<Zuora.zObject>();
            system.debug('*** CreditBalance : ' + zSaveResultList );
        } 
        transferCreditBalance();    
    }
    
    public void transferCreditBalance(){
        //decrease credit balance by amount equal to credits transferred from negative invoices in secondary subscriptions
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        SMS_CreditsTranfer__c primary = SMS_CreditsTranfer__c.getInstance('Primary');
        SMS_CreditsTranfer__c secondary = SMS_CreditsTranfer__c.getInstance('Secondary'); 
        
        zInvoiceIds = new List<String>();
        List<Zuora.zApi.SubscribeResult> zSubscribeResults = new List<Zuora.zApi.SubscribeResult>();
        
        for(SecondaryCredit sc : secondaryCredits){
            if(sc.isSelected){
                system.debug(sc.credits);
                subscribeRequests.add(getZuoraSubscriptionRequest(sc.zPrimaryAccountId,primary.zProductRatePlanId__c, primary.zProductRatePlanChargeId__c, -sc.credits));
                subscribeRequests.add(getZuoraSubscriptionRequest(sc.zSecondaryAccountId,secondary.zProductRatePlanId__c, secondary.zProductRatePlanChargeId__c, sc.credits));
                
                if(subscribeRequests.size() >= 49){
                    List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
                    zSubscribeResults.addAll(results);
                    System.debug('*** results:' + results );
                    subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
                }
            }            
        }
        
        if(subscribeRequests.size() > 0){
            List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
            System.debug('*** results:' + results );
            zSubscribeResults.addAll(results);                
            subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        }
        
        processZSubscribeResults(zSubscribeResults);
        processZInvoices();
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        secondaryCreditsMap = new Map<String,SecondaryCredit>();
        for(SecondaryCredit sc : secondaryCredits){
            SecondaryCredit src = new SecondaryCredit();
            if(sc.isSelected){
                src = zAccountIdSecondaryCredits.get(sc.zSecondaryAccountId);
                if(src.isTransfered)
                    src.notes = src.notes + 'Secondary credit transfered to primary.';
                else
                    src.notes = src.notes + 'Secondary credit not transfered to primary.';
                if(src.isReceived)
                    src.notes = src.notes + 'Secondary credit received by primary.';
                else
                    src.notes = src.notes + 'Secondary credit not received by primary.';
            }
            secondaryCreditsMap.put(sc.zSecondaryAccountId,src);
        }
        
        secondaryCredits = new List<SecondaryCredit>();
        secondaryCredits.addAll(secondaryCreditsMap.values());
    }
    
    public void processZInvoices(){
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
            else{
                type = 'Decrease';
                creditBalanceAdjustments.add(createCreditBalanceAdjustment(zInvoiceId,balance,type));
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
    
    public void processZSubscribeResults(List<Zuora.zApi.SubscribeResult> zSubscribeResults){
        for(Zuora.zApi.SubscribeResult result : zSubscribeResults){
            String zAccountId = result.AccountId;
            SecondaryCredit src = zAccountIdSecondaryCredits.get(zAccountId); 
            if(result.Success){
                zInvoiceIds.add((String)result.InvoiceId);
                if(src.zPrimaryAccountId == zAccountId)
                    src.isReceived = true;
                else if(src.zSecondaryAccountId == zAccountId)
                    src.isTransfered =  true;
            } 
            zAccountIdSecondaryCredits.put(zAccountId,src);                      
        }
    }
    
    public Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId, 
                                                                          String zProductRatePlanChargeId, Decimal amount) {
        
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
        
        request.SubscriptionData.Subscription = subscription;
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
        ratePlanCharge.setValue('Price', amount);
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
    
    public Zuora.zObject createCreditBalanceAdjustment(String zInvoiceId, Decimal amount, String type){
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', type);
        adjustment.setValue('Amount', amount);
        
        return adjustment;
    }
    
    public class SecondaryCredit{
        public String primaryId { get; set; }
        public String primaryStatus { get; set; }
        public String primaryContact { get; set; } 
        public String secondaryId { get; set; }
        public String secondaryStatus { get; set; }
        public String secondaryContact { get; set; }
        public String zPrimaryAccountId { get; set; }
        public String zSecondaryAccountId { get; set; }
        public Decimal credits { get; set; }
        public Decimal creditBalance { get; set; }
        public Decimal invoiceBalance { get; set; }
        public Boolean isValid { get; set; }
        public Boolean isSelected { get; set; }
        public Boolean isTransfered { get; set; }
        public Boolean isReceived { get; set; }
        public Boolean isConverted { get; set; }
        public String zPrimaryInvoiceId { get; set; }
        public String zSecondaryInvoiceId { get; set; }
        public String notes { get; set; }
        
        public SecondaryCredit(){
            primaryId = 'Primary Id not Available';
            primaryStatus = 'Status not Available';
            primaryContact = 'Contact not Available';
            secondaryId = 'Secondary Id not Available';
            secondaryStatus = 'Status not Available';
            secondaryContact = 'Contact not Available';
            zPrimaryAccountId = 'Zuora Account not available';
            zSecondaryAccountId = 'Zuora Account not available';
            credits = 0;
            creditBalance = 0;
            invoiceBalance = 0;
            isSelected = false;
            isValid = false;
            isTransfered = false;//secondary credit transfered to primary
            isReceived = false;//secondary credit received by primary
            isConverted = false;//negative invoice converted to credit balance
            notes = '';
        } 
    }
}