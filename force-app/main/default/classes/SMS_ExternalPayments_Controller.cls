public class SMS_ExternalPayments_Controller
{
    public string nameFile { get;set; }
    public Blob contentFile { get;set; }
    String[] filelines = new String[]{};
    public String paymentsListStr { get; set; }
    public String paymentsProcessed { get; set; }
    public String paymentsFailed { get; set; }
    
    public Boolean showUploadBlock { get; set; }
    public Boolean saveUploadBlock { get; set; }
    public Boolean hasValidPayments { get; set; }
    public Boolean showInvalidPaymentsBlock { get; set; }
    public Boolean isSaved { get; set; }
    
    public List<payment> paymentsList;
    public List<String> subIds;
    
    
    public SMS_ExternalPayments_Controller() {
        paymentsProcessed = '';
        paymentsFailed = '';
        paymentsListStr = '[]';
        hasValidPayments = false;
        showInvalidPaymentsBlock = false;
        showUploadBlock = true;
        saveUploadBlock = false;
        isSaved = false;
        System.debug('*** paymentsListStr controller:' + paymentsListStr);
    }
    
    public Pagereference ReadFile()
    {
        nameFile=contentFile.toString();
        filelines = nameFile.split('\n');
        paymentsList = new List<payment>();
        subIds = new List<String>();
        
        Integer j = 1;
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            
            if(String.isNotBlank(inputvalues[0])) {
                payment obj = new payment();
                obj.subscriptionId = inputvalues[0];
                obj.checkNumber = inputvalues[1];
                obj.amount = inputvalues[2];
                obj.valid = false;
                obj.selected = false;
                obj.recordId = String.valueOf(j);
                obj.processed = false;
                
                paymentsList.add(obj);
                subIds.add(inputvalues[0]);
                j++;
            }
        }
        
        validateSubscriptionIds();
        isSaved = false; 
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
            showUploadBlock = false;
            saveUploadBlock = true;    
        }
   
    }
    
    public Pagereference validate() {
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);
        validateSubscriptionIds();        
        return null;
    }
    
    public PageReference createPayments() {
        System.debug('*** paymentsListStr' + paymentsListStr);
        Zuora.zApi zApiInstance = new Zuora.zApi();
        Zuora.zApi.LoginResult zLoginResult = zApiInstance.zlogin();   
    
        paymentsList = new List<payment>();
        paymentsList  = (List<payment>)JSON.deserialize(paymentsListStr, List<payment>.class);
        
        Boolean isNotFirst = false;
        String zInvoiceQuery = 'SELECT Id, AccountId, Status, Balance, Amount, Status, InvoiceNumber, InvoiceDate, DueDate, PaymentAmount FROM Invoice WHERE ';
        for(payment record : paymentsList) {   
            if (isNotFirst) 
                zInvoiceQuery += ' OR ';
            
            zInvoiceQuery += 'AccountId = \'' + record.zuoraAcctId + '\'';
            isNotFirst = true;            
        }        
        
        List<Zuora.zObject> zInvoices = zApiInstance.zquery(zInvoiceQuery);
        System.debug('*** zInvoices :' + zInvoices);        
            
        for(payment record : paymentsList) {          
            List<Zuora.zObject> zPayments = new List<Zuora.zObject>();
            /* Create payment object in draft status */
            Zuora.zObject zPayment = new Zuora.zObject('Payment');
            zPayment.setValue('AccountId', record.zuoraAcctId);
            zPayment.setValue('Amount', Double.valueOf(record.amount));
            zPayment.setValue('PaymentMethodId', '2c92c0f83f215c2f013f39f3caba01aa');     
            zPayment.setValue('Status', 'Draft');
            zPayment.setValue('Type', 'External');
            zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST'));
            zPayment.setValue('Comment', 'LOCKBOX DEPOSIT FOR ' + Datetime.now().format('yyyy-MM-dd','PST'));
            zPayment.setValue('ReferenceId', 'LB-' + record.checkNumber);
            
            Double totalInvoiceBalance = 0;
            Boolean invoiceFlag = false;
            for(Zuora.zObject zInvoice : zInvoices) {
                if ((String)zInvoice.getValue('AccountId') == record.zuoraAcctId && (Decimal)zInvoice.getValue('Balance') > 0) {                
                    if((Decimal)zInvoice.getValue('Balance') <= Double.valueOf(record.amount)) {
                        invoiceFlag = true;
                        totalInvoiceBalance += (Decimal)zInvoice.getValue('Balance');
                    }
                }
            } 
            
            if(!invoiceFlag) {
               zPayment.setValue('AppliedCreditBalanceAmount', Double.valueOf(record.amount));
               zPayment.setValue('Status', 'Processed');
            }
            else {
                zPayment.setValue('AppliedCreditBalanceAmount', Double.valueOf(record.amount) - totalInvoiceBalance);
            }            
            
            zPayments.add(zPayment);
            System.debug('*** record' + record);
            System.debug('*** zPayments: ' + zPayments);
            List<Zuora.zApi.SaveResult> zSaveResultList = zApiInstance.zcreate(zPayments);
            try {
                String paymentId = '';
                for (Zuora.zApi.SaveResult result : zSaveResultList) {
                    if (result.Success) {
                        paymentId = result.Id;
                        
                        if(invoiceFlag) {
                            /* Create invoice payment */
                            List<Zuora.zObject> zInvoicePayments = new List<Zuora.zObject>();
                            for(Zuora.zObject zInvoice : zInvoices) {
                                if ((String)zInvoice.getValue('AccountId') == record.zuoraAcctId && (Decimal)zInvoice.getValue('Balance') > 0) {
                                    if((Decimal)zInvoice.getValue('Balance') <= Double.valueOf(record.amount)) {
                                        Zuora.zObject zInvoicePayment = new Zuora.zObject('InvoicePayment');
                                        zInvoicePayment.setValue('InvoiceId', (String)zInvoice.getValue('Id'));
                                        zInvoicePayment.setValue('Amount', (Decimal)zInvoice.getValue('Balance'));
                                        zInvoicePayment.setValue('PaymentId', paymentId);
                                        zInvoicePayments.add(zInvoicePayment);
                                        record.amount = String.valueOf(Double.valueOf(record.amount) - (Decimal)zInvoice.getValue('Balance'));                               
                                    }
                                }
                            }
                            
                            if(zInvoicePayments.Size() > 0) {
                                System.debug('*** zInvoicePayments: ' + zInvoicePayments);
                                List<Zuora.zApi.SaveResult> zInvoicePaymentResultList = zApiInstance.zcreate(zInvoicePayments);
                                System.debug('*** zInvoicePaymentResultList ' + zInvoicePaymentResultList ); 
                                for (Zuora.zApi.SaveResult result1 : zInvoicePaymentResultList) {
                                    if (result1.Success) {
                                        /* Update payment status to processed */
                                        List<Zuora.zObject> zPayments1 = new List<Zuora.zObject>();
                                        Zuora.zObject zPayment1 = new Zuora.zObject('Payment');
                                        zPayment1.setValue('Id', paymentId);
                                        zPayment1.setValue('Status', 'Processed');                              
                                        zPayments1.add(zPayment1);
                                        List<Zuora.zApi.SaveResult> zSaveResultList2 = zApiInstance.zupdate(zPayments1); 
                                        System.debug('*** zSaveResultList2 ' + zSaveResultList2);
                                        for (Zuora.zApi.SaveResult result2 : zSaveResultList2) {
                                            if (result2.Success) {
                                            
                                            }
                                            else {
                                                throw new CustomException('');
                                            }
                                        }                               
                                    }
                                    else {
                                        throw new CustomException('');
                                    }
                                }
                            }
                        } 
                                            
                    }
                    else {
                        throw new CustomException('');
                    }
                }
                
                paymentsProcessed += record.recordId + ',';

            } 
            catch(Exception e) {
                paymentsFailed += record.recordId + ',';
            }         
        }
        
        if(isSaved) {
            //SMS_ExistingPaymentsStatus_Future.updateStatus(paymentsProcessed, paymentsFailed);
        }
        
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
            externalPayments.add(ep);
        }
        insert externalPayments;
        return null;
    }
    
    public PageReference loadSavedPayments() {
        List<SMS_ExternalPayments__c> externalPayments = [SELECT Amount__c, CheckDate__c, CheckNumber__c, Status__c, SubscriptionId__c FROM SMS_ExternalPayments__c WHERE Status__c = 'Unprocessed'];
        paymentsList = new List<payment>();
        subIds = new List<String>();
        for(SMS_ExternalPayments__c ep : externalPayments) {
            payment p = new payment();
            p.subscriptionId = ep.SubscriptionId__c;
            p.checkNumber  = ep.CheckNumber__c;
            p.amount = ep.Amount__c;
            p.valid = false;
            p.selected = false;
            p.recordId = ep.Id;
            p.processed = false;
            paymentsList.add(p);
            subIds.add(ep.SubscriptionId__c);            
        }
        validateSubscriptionIds(); 
        isSaved = true;
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
    }          
    
    public Class CustomException extends Exception {}          
}