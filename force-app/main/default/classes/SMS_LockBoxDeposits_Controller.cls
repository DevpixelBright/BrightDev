public class SMS_LockBoxDeposits_Controller
{
    public string nameFile { get;set; }
    public Blob contentFile { get;set; }
    String[] filelines = new String[]{};
    public String paymentsListStr { get; set; }
    public String failedPaymentsListStr { get; set; }
    public String newPaymentsListStr { get; set; }
    public String paymentsProcessed { get; set; }
    public String paymentsFailed { get; set; }
    
    public Boolean showUploadBlock { get; set; }
    public Boolean saveUploadBlock { get; set; }
    public Boolean hasValidPayments { get; set; }
    public Boolean showInvalidPaymentsBlock { get; set; }
    public Boolean isSaved { get; set; }
    
    public List<payment> paymentsList;
    public List<payment> failedPaymentsList;
    public List<String> subIds;
    
    
    public SMS_LockBoxDeposits_Controller() {
        paymentsProcessed = '';
        paymentsFailed = '';
        paymentsListStr = '[]';
        failedPaymentsListStr = '[]';
        hasValidPayments = true;
        showInvalidPaymentsBlock = true;
        showUploadBlock = true;
        saveUploadBlock = false;
        isSaved = false;
        
        loadSavedPayments();
      
    }
    
    public PageReference fileRecords() {
        System.debug('***newPaymentsListStr ' + newPaymentsListStr );
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(newPaymentsListStr, List<payment>.class);
        failedPaymentsList = new List<payment>();
        failedPaymentsList = (List<payment>)JSON.deserialize(failedPaymentsListStr , List<payment>.class);
        
        List<SMS_ExternalPayments__c> newPaymentsList = new List<SMS_ExternalPayments__c>();        
 
        for(payment p : paymentsList) {     
            List<SMS_ExternalPayments__c> externalPayments = [SELECT Id, FileName__c, CreatedDate, CheckNumber__c, SubscriptionId__c, Status__c FROM SMS_ExternalPayments__c
                                                              WHERE CheckNumber__c = :p.checkNumber 
                                                              AND SubscriptionId__c = :p.subscriptionId
                                                              AND IsVirtual__c = false
                                                              ];
            
            if(externalPayments.size() > 0) {
                p.zuoraAcctName = 'Record already exists';
                failedPaymentsList.add(p);
            }
            else {
                SMS_ExternalPayments__c newPayment = new SMS_ExternalPayments__c();
                newPayment.CheckNumber__c = p.checkNumber;
                newPayment.SubscriptionId__c = p.subscriptionId; 
                newPayment.Amount__c = p.amount;
                newPayment.FileName__c = p.fileName;
                newPayment.IsVirtual__c  = false;
                newPaymentsList.add(newPayment);      
            }        
        }
        insert newPaymentsList; 
        loadSavedPayments();
        if(failedPaymentsList.Size() > 0)
            failedPaymentsListStr = JSON.serialize(failedPaymentsList);  
        return null;
    }
    
    public PageReference loadSavedPayments() {
        List<SMS_ExternalPayments__c> externalPayments = [SELECT Amount__c, CheckDate__c, CheckNumber__c, Status__c, SubscriptionId__c, FileName__c, CreatedDate FROM SMS_ExternalPayments__c WHERE Status__c = 'Unprocessed' AND IsVirtual__c = false];
        paymentsList = new List<payment>();
        subIds = new List<String>();
        for(SMS_ExternalPayments__c ep : externalPayments) {
            if(ep.SubscriptionId__c != '' && String.isNotBlank(ep.SubscriptionId__c)) {
                payment p = new payment();
                p.subscriptionId = ep.SubscriptionId__c;
                p.checkNumber  = ep.CheckNumber__c;
                p.amount = ep.Amount__c;
                p.valid = false;
                p.selected = false;
                p.recordId = ep.Id;
                p.processed = false;
                DateTime dT = ep.CreatedDate;
                Date createdDate = date.newinstance(dT.year(), dT.month(), dT.day());
                p.createdDate = createdDate;
                p.fileName = ep.FileName__c;
                paymentsList.add(p);
                subIds.add(ep.SubscriptionId__c);
            }            
        }
        validateSubscriptionIds();
        isSaved = true;
        return null;
    }    
    
       
    public void validateSubscriptionIds() {
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id, Name, SubscriptionID__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE SubscriptionID__c = :subIds];
        Map<String, String> zAcctIdsMap = new Map<String, String>();
        Map<String, String> zAcctNamesMap = new Map<String, String>();
        
        for(Zuora__CustomerAccount__c billingAccount : billingAccounts) {
            for(payment p : paymentsList) {
                if(billingAccount.SubscriptionID__c == p.subscriptionId) {
                    p.valid = true;
                    p.zuoraAcctId = billingAccount.Zuora__Zuora_Id__c;
                    p.zuoraAcctName = billingAccount.Name;
                }
            }
        } 
               
        if(paymentsList.Size() > 0) {
            paymentsListStr = JSON.serialize(paymentsList);
            hasValidPayments = true;
            showInvalidPaymentsBlock = true;
            showUploadBlock = true;
            saveUploadBlock = true;    
        }
   
    }
    
    public Pagereference validate() {
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);
        subIds = new List<String>();
        List<SMS_ExternalPayments__c> externalPayments = new List<SMS_ExternalPayments__c>();
        for(payment p : paymentsList) {
            subIds.add(p.subscriptionId);
            SMS_ExternalPayments__c ep = new SMS_ExternalPayments__c();
            ep.Id = p.recordId;
            ep.SubscriptionID__c = p.subscriptionId;
            externalPayments.add(ep);
        }
        
        if(externalPayments.Size() > 0)
            update externalPayments;
        
        validateSubscriptionIds();        
        return null;
    }
    
    public Pagereference deletePayments() {
        System.debug('*** paymentsListStr:' + paymentsListStr);
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);
        subIds = new List<String>();
        List<SMS_ExternalPayments__c> externalPayments = new List<SMS_ExternalPayments__c>();
        for(payment p : paymentsList) {
            SMS_ExternalPayments__c ep = new SMS_ExternalPayments__c();
            ep.Id = p.recordId;
            ep.SubscriptionID__c = p.subscriptionId;
            externalPayments.add(ep);
        }
        
        if(externalPayments.Size() > 0)
            delete externalPayments;
        
        loadSavedPayments();        
        return null;
    }
    
    
    public PageReference createPayments() {
        System.debug('*** paymentsListStr' + paymentsListStr);
        
        SMS_ZuoraUtil zApiInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin();        
    
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);
        
        Set<String> successPayments = new  Set<String>();
        Set<String> failedPayments = new  Set<String>();
        paymentsFailed = '';
        paymentsProcessed = '';
        
        List<Zuora.zObject> check = zApiInstance.zquery('SELECT Id FROM PaymentMethod WHERE Type = \'Check\'');        
        String checkId = (String)check[0].getValue('Id');
        
         for(payment record : paymentsList) {          
            List<Zuora.zObject> zPayments = new List<Zuora.zObject>();
            Zuora.zObject zPayment = new Zuora.zObject('Payment');
            zPayment.setValue('AccountId', record.zuoraAcctId);
            zPayment.setValue('AppliedCreditBalanceAmount', Double.valueOf(record.amount));
            zPayment.setValue('Amount', Double.valueOf(record.amount));
            zPayment.setValue('PaymentMethodId', checkId);     
            zPayment.setValue('Status', 'Processed');
            zPayment.setValue('Type', 'External');
            zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST')); //
            zPayment.setValue('Comment', 'LOCKBOX DEPOSIT FOR ' + Datetime.now().format('yyyy-MM-dd','PST'));
            zPayment.setValue('ReferenceId', 'LB-' + record.checkNumber);
            
            zPayments.add(zPayment);
            System.debug('*** record' + record);
            System.debug('*** zPayments: ' + zPayments);
            List<Zuora.zApi.SaveResult> zSaveResultPayment = zApiInstance.zcreate(zPayments);
            
            String paymentId = '';
            
            try {
                for (Zuora.zApi.SaveResult result : zSaveResultPayment ) {
                    if(!result.Success) {
                        Zuora.zObject[] errors = result.errors;
                        for (Zuora.zObject error : errors) {
                            String errorCode = (String)error.getValue('Code');
                            String message = (String)error.getValue('Message');
                            throw new CustomException('Create Payment:' + errorCode + '-' + message); 
                        }               
                    }
                    else
                         paymentId = result.Id;
                }
                /*Query Invoices with balances*/
                String zInvoiceQuery = 'SELECT Id, AccountId, Status, Balance, Amount, Status, InvoiceNumber, InvoiceDate, ';
                zInvoiceQuery += 'DueDate, PaymentAmount FROM Invoice WHERE AccountId = \'' + record.zuoraAcctId + '\' AND Balance > 0';      
                
                List<Zuora.zObject> zInvoices = zApiInstance.zquery(zInvoiceQuery);
                System.debug('*** zInvoices :' + zInvoices); 
                
                if(zInvoices.size() > 0){
                    Boolean changed = true;
                    while (changed) {
                        changed = false;
                        
                        for (Integer i = 0; i < zInvoices.size(); i++) {
                            if (i + 1 == zInvoices.size()) break;
                            
                            DateTime a = (Date) ((Zuora.zObject) zInvoices.get(i)).getValue('InvoiceDate');
                            DateTime b = (Date) ((Zuora.zObject) zInvoices.get(i + 1)).getValue('InvoiceDate');
                            
                            if (a > b) {
                                zInvoices.add(i, zInvoices.remove(i + 1));
                                changed = true;
                            }
                        }
                    }
                     
                    List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
                    /*Apply Credit Balance to the invoices*/
                    Decimal checkAmount = Double.valueOf(record.amount);
                    Decimal fullCheckAmount = Double.valueOf(record.amount);
                    for(Zuora.zObject zInvoice : zInvoices) {
                        Decimal invoiceBalance = (Decimal)zInvoice.getValue('Balance');
                        if(fullCheckAmount == invoiceBalance){
                            checkAmount = checkAmount - invoiceBalance;
                            Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
          
                            adjustment.setValue('SourceTransactionId', zInvoice.getValue('Id'));
                            adjustment.setValue('Amount', invoiceBalance);  
                            adjustment.setValue('Type', 'Decrease');
                            
                            creditBalanceAdjustments = new List<Zuora.zObject>();    
                            creditBalanceAdjustments.add(adjustment);
                            
                            break;
                        }
                        
                        if(checkAmount > 0){
                            if(checkAmount > invoiceBalance){
                                checkAmount = checkAmount - invoiceBalance;
                                Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
              
                                adjustment.setValue('SourceTransactionId', zInvoice.getValue('Id'));
                                adjustment.setValue('Amount', invoiceBalance);  
                                adjustment.setValue('Type', 'Decrease');
                                    
                                creditBalanceAdjustments.add(adjustment);
                            }
                            else{                                
                                Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
              
                                adjustment.setValue('SourceTransactionId', zInvoice.getValue('Id'));
                                adjustment.setValue('Amount', checkAmount);  
                                adjustment.setValue('Type', 'Decrease');
                                    
                                creditBalanceAdjustments.add(adjustment);
                                
                                checkAmount = 0;
                                
                            } 
                        }   
                    }
                    
                    if(creditBalanceAdjustments.size() > 0){
                        List<Zuora.zApi.SaveResult> zSaveResultCB = zApiInstance.zcreate(creditBalanceAdjustments);
                        
                        for (Zuora.zApi.SaveResult result : zSaveResultCB ) {
                            if(!result.Success) {
                                Zuora.zObject[] errors = result.errors;
                                for (Zuora.zObject error : errors) {
                                    String errorCode = (String)error.getValue('Code');
                                    String message = (String)error.getValue('Message');
                                    throw new CustomException('Apply Credit Balance:' + errorCode + '-' + message); 
                                }               
                            }                             
                        }
                    }
                }
                
                if(String.isNotBlank(record.recordId)) {
                    paymentsProcessed += record.recordId + ',';
                    successPayments.add(record.recordId);                  
                }
            }
            catch(Exception e){
                if(String.isNotBlank(record.recordId)) {
                    paymentsFailed += record.recordId + '@@' + e.getMessage() + ',';
                    failedPayments.add(record.recordId);
                }
            }  


        }
        
        SMS_ExistingPaymentsStatus_Future.updateStatus(successPayments, failedPayments);
                
        return null;
    }
    
    public PageReference savePayments() {
        System.debug('*** paymentsListStr' + paymentsListStr);
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);        
        List<SMS_ExternalPayments__c> externalPayments = new List<SMS_ExternalPayments__c>();
        for(payment p : paymentsList) {
            SMS_ExternalPayments__c ep = new SMS_ExternalPayments__c();
            ep.SubscriptionId__c = p.subscriptionId;
            ep.CheckNumber__c = p.checkNumber;
            ep.Amount__c = p.amount;
            ep.Status__c = 'Unprocessed';
            ep.IsVirtual__c = false;
            externalPayments.add(ep);
        }
        insert externalPayments;
        return null;
    }
    

        
    public class payment{
        public String recordId { get; set; }
        public String subscriptionId { get; set;}
        public String paymentMethod { get; set;}
        public String checkNumber { get; set; }
        public String amount { get; set;}
        public Boolean valid { get; set; }
        public String zuoraAcctId { get; set; }
        public String zuoraAcctName { get; set; }
        public Boolean selected { get; set; }
        public Boolean processed { get; set; }
        public String fileName { get; set; }
        public Date createdDate { get; set; }
    }          
    
    public Class CustomException extends Exception {}          
}