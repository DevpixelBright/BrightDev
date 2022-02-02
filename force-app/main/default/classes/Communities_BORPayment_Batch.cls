global class Communities_BORPayment_Batch implements Database.Batchable<String>,Database.AllowsCallouts,Database.Stateful{
    
    List<String> subscriptionIds;
    Zuora.zApi.LoginResult zLoginResult;
    SMS_ZuoraUtil zApiInstance;
    String BORSubscriptionId;
    String BORPaymentId;
    Boolean processPaymentsError;
    public Map<String,BORPayment> subsMap;
    public SMS_BORPayment__c borPayment;
    Map<String,SMS_BORPayment_Subscriber__c> borSubscribers;
    public List<SMS_BORPayment__c> borpaymentList;
    
    public Communities_BORPayment_Batch(String BORPaymentId){
        subsMap = new Map<String,BORPayment>();
        borpaymentList =  new List<SMS_BORPayment__c>();      
        this.BORPaymentId = BORPaymentId;
        processPaymentsError = false;
        subscriptionIds = new List<String>();
        
        borpayment = new SMS_BORPayment__c();
        borPayment = [SELECT Id,Name, BOR_Subscription__c,BOR_Subscription__r.Service_Jurisdiction__c,BOR_Subscription__r.Name,Private_Email__c, 
                      Status__c, Status_Message__c ,Reference_Id__c,Total_Amount__c
                      FROM   SMS_BORPayment__c
                      WHERE  Id = :BORPaymentId
                     ];                     
        
        BORSubscriptionId = borPayment.BOR_Subscription__r.Name;
        borSubscribers = new Map<String,SMS_BORPayment_Subscriber__c>();
        
        for(SMS_BORPayment_Subscriber__c borSubscriber : [SELECT Id,SF_Subscription__c,SF_Subscription__r.Name,Invoice_Details__c,Invoice_Date__c, Amount__c, Status__c, Status_Message__c
                                                          FROM SMS_BORPayment_Subscriber__c WHERE BOR_Payment__c = :borPaymentId]){
                                                              borSubscribers.put(borSubscriber.SF_Subscription__r.Name, borSubscriber);   
                                                          }
        
        subscriptionIds.addAll(borSubscribers.keyset());
        
    }
    
    global List<String> start(Database.BatchableContext BC){
        return subscriptionIds;
    }
    
    global void execute(Database.BatchableContext BC, List<String> subscriptionIds){
        zApiInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zApiInstance.zlogin();
        List<SMS_BORPayment_Subscriber__c> subscribers = new List<SMS_BORPayment_Subscriber__c>();
        
        system.debug('******************* subscriptionIds *************'+subscriptionIds);
        for(String subscriptionId : subscriptionIds){
            BORPayment borpaymentobj = new BORPayment();
            borpaymentobj.invoiceMap = new Map<String,Decimal>();
            borpaymentobj.invoiceDatesMap = new Map<String,Date>();
            
            SMS_BORPayment_Subscriber__c borSubscriber = borSubscribers.get(subscriptionId);
            
            try{
                Zuora.zObject zAccount = new Zuora.zObject('Account');
                zAccount = getZAccount(subscriptionId);
                String zAccountId = (String)zAccount.getValue('Id');
                Decimal balance = (Decimal)zAccount.getvalue('Balance');                
                
                borSubscriber.Amount__c = balance.setScale(2) ;
                borSubscriber.Invoice_Details__c = '';
                borSubscriber.Invoice_Date__c = '';
                
                borpaymentobj.sfSubscriptionId = subscriptionId;
                borpaymentobj.invoiceBalance = balance;
                
                List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
                zInvoices = getZInvoices(zAccountId);
                for(Zuora.zObject zInvoice : zInvoices){
                    String zId = (String)zInvoice.getValue('Id');
                    Decimal amount = (Decimal)zInvoice.getValue('Balance');
                    String invoiceName = (String)zInvoice.getValue('InvoiceNumber');
                    Date invoiceDate = (Date)zInvoice.getValue('InvoiceDate');
                    system.debug('*******zInvoice.getValue(InvoiceDate)******* '+zInvoice.getValue('InvoiceDate'));
                    borpaymentobj.invoiceMap.put(invoiceName,amount.setScale(2));
                    borpaymentobj.invoiceDatesMap.put(invoiceName,invoiceDate);
                    borSubscriber.Invoice_Details__c = borSubscriber.Invoice_Details__c + invoiceName + ' - $' + amount.setScale(2)+' ' ;
                    borSubscriber.Invoice_Date__c  = borSubscriber.Invoice_Date__c + invoiceName + ' - ' + invoiceDate.format()+' ';
                    system.debug('*******invoiceName -invoiceDate******* '+invoiceName+'-'+invoiceDate.format());
                }
                
                // if(processPayments){            
                String zInvoiceId = createSubscription(zAccountId, -balance);
                if(String.isNotBlank(zInvoiceId)){ 
                    borSubscriber.Status__c = 'Subscription';                           
                    List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
                    creditBalanceAdjustments.add(createCreditBalanceAdjustment(zInvoiceId, balance, 'Increase'));
                    
                    List<Zuora.zApi.SaveResult> zSaveResultList = new List<Zuora.zApi.SaveResult>();
                    zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments);//Transfer to CreditBalance
                    
                    for(Zuora.zApi.SaveResult result : zSaveResultList){
                        if(!result.Success) {
                            Zuora.zObject[] errors = result.errors;
                            for (Zuora.zObject error : errors) {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message');                                
                                throw new CustomException('Transfer Negative InvoiceBalance to CreditBalance:' + errorCode + '-' + message); 
                            }                                     
                        }                                                       
                    }                  
                    borSubscriber.Status__c = 'Credit Balance - Subscription';
                    
                    creditBalanceAdjustments = new List<Zuora.zObject>();
                    zSaveResultList = new List<Zuora.zApi.SaveResult>();
                    for(Zuora.zObject zInvoice : zInvoices){
                        String zId = (String)zInvoice.getValue('Id');
                        Decimal amount = (Decimal)zInvoice.getValue('Balance');
                        String invoiceName = (String)zInvoice.getValue('InvoiceNumber');                            
                        creditBalanceAdjustments.add(createCreditBalanceAdjustment(zId, amount, 'Decrease'));                          
                    }
                    
                    zSaveResultList = zApiInstance.zcreate(creditBalanceAdjustments);//Apply CreditBalance to Invoice
                    for(Zuora.zApi.SaveResult result : zSaveResultList){
                        if(!result.Success) {
                            Zuora.zObject[] errors = result.errors;
                            for (Zuora.zObject error : errors) {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message');                                
                                throw new CustomException('Apply CreditBalance to Invoice:' + errorCode + '-' + message); 
                            }                                     
                        }                                
                    }
                    borSubscriber.Status__c = 'Credit Balance - Invoices';                 
                }
                borpaymentobj.status = 'Success';
                subsMap.put(subscriptionId, borpaymentobj);
                
                borSubscriber.Status__c = 'Success';
                borSubscribers.put(subscriptionId,borSubscriber);
                subscribers.add(borSubscriber);                    
                
                /* } else {
                borpaymentobj.status = 'Failed';
                borpaymentobj.statusMessage = 'BOR Payment Failed';
                subsMap.put(subscriptionId, borpaymentobj);
                
                borSubscriber.Status_Message__c = 'BOR Payment Failed';
                borSubscribers.put(subscriptionId,borSubscriber); 
                subscribers.add(borSubscriber); 
                }*/
            }
            catch(Exception e){
                system.debug('********* exception****'+e.getMessage() + '--' + e.getStackTraceString());
                processPaymentsError = true;
                
                borpaymentobj.status = 'Failed';
                borpaymentobj.statusMessage = e.getMessage() + '--' + e.getStackTraceString();
                subsMap.put(subscriptionId, borpaymentobj);
                
                borSubscriber.Status__c = 'Failed';
                borSubscriber.Status_Message__c = e.getMessage();
                borSubscribers.put(subscriptionId,borSubscriber);
                subscribers.add(borSubscriber);     
            }          
        } 
        
        
        update subscribers; 
    }
    
    global void finish(Database.BatchableContext BC){
        // sendEmail();
        system.debug('in finish method processPaymentsError ' +  processPaymentsError);
        if(processPaymentsError){
            createCase();
            borpayment.Status__c = 'Failed';
            borpayment.Status_Message__c = 'Payments have not been successfully completed for all or few invoices of the agents';
            
        }else{
            //createCase();
            borpayment.Status__c = 'Success';
            borpayment.Status_Message__c = 'Payments have  been successfully completed for all invoices of the agents';
            
        }
        system.debug('in finish method borpayment ' +  borpayment);
        
        if(borpayment!=null)
            update borpayment;
        
        //update borSubscribers.values();
    }
    
    private String createSubscription(String zAccountId, Decimal amount){
        SMS_CreditsTranfer__c subscriber = SMS_CreditsTranfer__c.getInstance('Subscriber');
        String zInvoiceId = null;
        
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        subscribeRequests.add(getZuoraSubscriptionRequest(zAccountId, subscriber.zProductRatePlanId__c, subscriber.zProductRatePlanChargeId__c, amount));
        List<Zuora.zApi.SubscribeResult> results = zApiInstance.zsubscribe(subscribeRequests);
        
        for(Zuora.zApi.SubscribeResult result : results){
            if(result.Success){
                zInvoiceId = (String)result.InvoiceId;                                              
            } 
            else{
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');                                
                    throw new CustomException('Failed to create negative subscription:' + errorCode + '-' + message); 
                } 
            }                  
        }
        
        return zInvoiceId;
    }
    
    private Zuora.zObject getZAccount(String subscriptionId){
        String zAccountQuery = 'SELECT Id, Name, Balance, CreditBalance, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE SubscriptionID__c = \'' + subscriptionId + '\'';
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
        zAccounts = zApiInstance.zquery(zAccountQuery );
        
        return zAccounts[0];
    }
    
    private List<Zuora.zObject> getZInvoices(String zAccountId){
        String zInvoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount,InvoiceNumber,InvoiceDate FROM Invoice WHERE AccountId = \'' + zAccountId + '\' AND Balance > 0';
        List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
        zInvoices = zApiInstance.zquery(zInvoiceQuery);
        
        return zInvoices;
        
    }
    
    public Zuora.zObject createCreditBalanceAdjustment(String zInvoiceId, Decimal amount, String type){ 
        
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', type);
        adjustment.setValue('Amount', amount);
        
        return adjustment;        
    }
    
    private Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId, String zProductRatePlanChargeId, Decimal amount) {
        
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
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
        
        ratePlanDataList.add(ratePlanData);                  
        request.SubscriptionData.RatePlanData = ratePlanDataList;            
        
        return request;                 
    }
    
    private void createCase(){
        
        Decimal TotalInvoiceAmount = 0;
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.DeveloperName = 'Email_Support_Analysts'
                                      ];
        
        String description ='[ Subscription ID ] - [ Invoice Details ] - [ Status ] - [ Status Message ]\n';
        
        for(BORPayment payments : subsMap.values()){
            TotalInvoiceAmount += payments.invoiceBalance;
            description += '[ '+payments.sfSubscriptionId +' ]- ';
            for(String invoicemapkey : payments.invoiceMap.keySet() ){
                description += '[ '+invoicemapkey+'- $'+ payments.invoiceMap.get(invoicemapkey)+','; 
            }
            
            description +=' ] - [ '+payments.status+' ] - [ '+payments.statusMessage+' ]\n';
        }
        
        
        Case c = new Case();
        c.OwnerId = queueIds[0].QueueId;
        c.Subscription_ID__c = borpayment.BOR_Subscription__c;
        c.Subject = borpayment.BOR_Subscription__r.Name + ' : '+ borpayment.Name +' - Office online broker payment Failed ';
        c.Description = description;
        c.Origin = borpayment.BOR_Subscription__r.service_jurisdiction__c+' Connect';
        insert c;
    }
    
    
    public class BORPayment{
        public String status { get; set; } 
        public String statusMessage { get; set; }
        public Decimal invoiceBalance { get; set; }
        public String sfSubscriptionId { get; set; } 
        public Map<String,Decimal> invoiceMap { get; set; }
        public Map<String,Date> invoiceDatesMap { get; set; }
    }
    
    public Class CustomException extends Exception {} 
}