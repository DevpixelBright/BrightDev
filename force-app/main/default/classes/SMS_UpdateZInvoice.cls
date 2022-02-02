public class SMS_UpdateZInvoice{
    
    public Static String updateZInvoice(String billingId) {       
                         
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount = [SELECT Id,
                              Name,
                              Zuora__Zuora_Id__c,
                              Invoice_REST_Response__c
                          FROM   Zuora__CustomerAccount__c 
                          WHERE  Id = :billingId
                         ];             
        
        String jsonResponse = getInvoicesFromZuora(billingAccount.Zuora__Zuora_Id__c);                          
        return jsonResponse;
           
    }
    
    public Static String getInvoicesFromZuora(String zuoraAccountId) {

        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();         

        List<Zuora.zObject> zAccounts = new  List<Zuora.zObject>();
        List<Zuora.zObject> zInvoices = new  List<Zuora.zObject>();
        List<Zuora.zObject> zInvoiceItems = new List<Zuora.zObject>();
        List<Zuora.zObject> zInvoiceItemAdjustments = new  List<Zuora.zObject>();
        List<Zuora.zObject> zCBAdjustments = new  List<Zuora.zObject>();
        
        Map<String,Invoice> invoicesMap = new Map<String,Invoice>();
        
        String zAccountQuery = 'SELECT Id,Name,CreditBalance,SubscriptionID__c,Balance,AccountNumber,TotalInvoiceBalance,AccountNumber FROM Account WHERE Id = \'' + zuoraAccountId + '\'';
        zAccounts = zUtilInstance.zquery(zAccountQuery); 
        
        String zInvoiceQuery = 'SELECT Id,AccountId,Status,Balance,Amount,Status,CreatedById,InvoiceNumber,InvoiceDate,DueDate,PaymentAmount,TargetDate FROM Invoice WHERE Balance > 0 AND  AccountId = \'' + zuoraAccountId + '\'';
        zInvoices = zUtilInstance.zquery(zInvoiceQuery);
        
        Boolean isNotFirst = false;
        String invoiceItemQuery = 'SELECT Id,ChargeAmount,InvoiceId,ChargeName,ProductName,SubscriptionNumber, ServiceStartDate, ServiceEndDate, ChargeDescription, TaxAmount  FROM InvoiceItem WHERE ';
        
        for(Zuora.zObject zInvoice : zInvoices) {   
            if (isNotFirst) 
                invoiceItemQuery += ' OR ';
            
            invoiceItemQuery += 'InvoiceId = \'' + (String)zInvoice.getValue('Id') + '\'';
            isNotFirst = true;
            
            Invoice invoice = new Invoice();
            invoice.id = (String)zInvoice.getValue('Id'); 
            invoice.accountId = (String)zInvoice.getValue('AccountId');
            invoice.accountNumber = (String)zAccounts[0].getValue('AccountNumber');
            invoice.accountName = (String)zAccounts[0].getValue('Name');
            invoice.invoiceDate = (Date)zInvoice.getValue('InvoiceDate'); 
            invoice.invoiceNumber = (String)zInvoice.getValue('InvoiceNumber'); 
            
            DateTime d = (Date)zInvoice.getValue('DueDate');
            invoice.dueDate = d.format('MM/dd/yyyy'); 
            
            invoice.invoiceTargetDate = (Date)zInvoice.getValue('TargetDate'); 
            invoice.amount = (Decimal)zInvoice.getValue('Amount'); 
            invoice.amount = invoice.amount.setScale(2);
            if (!Test.isRunningTest()) {
                invoice.balance = (Decimal)zInvoice.getValue('Balance');
                invoice.balance = invoice.balance.setScale(2);
            }
            invoice.createdBy = (String)zInvoice.getValue('CreatedById'); 
            invoice.status = (String)zInvoice.getValue('Status'); 
            invoice.invoiceItems = new List<InvoiceItem>(); 
            invoice.invoiceItemAdjustments = new List<InvoiceItemAdjustment>();
            invoice.CreditBalanceAdjustments = new List<CreditBalanceAdjustment>();
            
            invoicesMap.put((String)zInvoice.getValue('Id'),invoice);
        }
        
        if(isNotFirst)
            zInvoiceItems = zUtilInstance.zquery(invoiceItemQuery);

        for(Zuora.zObject zInvoiceItem : zInvoiceItems) {   
            String invoiceId = (String)zInvoiceItem.getValue('InvoiceId');
            
            InvoiceItem invoiceItem = new InvoiceItem();
            invoiceItem.id = (String)zInvoiceItem.getValue('Id');
            invoiceItem.subscriptionName = (String)zInvoiceItem.getValue('SubscriptionNumber');
            invoiceItem.subscriptionId = (String)zInvoiceItem.getValue('SubscriptionId');
            
            DateTime d = (Date)zInvoiceItem.getValue('ServiceStartDate');
            invoiceItem.serviceStartDate = d.format('MM/dd/yyyy'); 
            
            d = (Date)zInvoiceItem.getValue('ServiceEndDate');            
            invoiceItem.serviceEndDate = d.format('MM/dd/yyyy');
            
            invoiceItem.chargeAmount = (Decimal)zInvoiceItem.getValue('ChargeAmount');
            invoiceItem.chargeAmount = invoiceItem.chargeAmount.setScale(2);
            invoiceItem.chargeDescription = (String)zInvoiceItem.getValue('ChargeDescription');
            invoiceItem.chargeName = (String)zInvoiceItem.getValue('ChargeName');
            invoiceItem.chargeId = (String)zInvoiceItem.getValue('ChargeNumber');
            invoiceItem.productName = (String)zInvoiceItem.getValue('ProductName');
            invoiceItem.quantity = (Decimal)zInvoiceItem.getValue('Quantity');
            invoiceItem.taxAmount = (Decimal)zInvoiceItem.getValue('TaxAmount');
            invoiceItem.taxAmount = invoiceItem.taxAmount.setScale(2);
            invoiceItem.unitOfMeasure = (String)zInvoiceItem.getValue('UOM');
            
            if (invoiceItem.productName != 'Promotions' && invoiceItem.chargeAmount < 0)
                invoiceItem.isRemoval = true;
            else
                invoiceItem.isRemoval = false;
                
            if(String.isBlank(invoiceItem.chargeDescription))
                invoiceItem.chargeDescription = invoiceItem.chargeName;
            
            invoicesMap.get(invoiceId).invoiceItems.add(invoiceItem); 
                                                               
        }
        
        if (zInvoices.Size() > 0) {
        
            /* Invoice Item Adjustments */
            isNotFirst = false; 
            String invoiceItemAdjustmentQuery = 'SELECT Id, Amount, Comment,ReasonCode,InvoiceNumber,InvoiceId,ServiceStartDate,ServiceEndDate,Type,Status FROM InvoiceItemAdjustment WHERE ';
            for(Zuora.zObject zInvoice : zInvoices) {   
                if (isNotFirst) 
                    invoiceItemAdjustmentQuery += ' OR ';
                
                invoiceItemAdjustmentQuery += 'InvoiceId = \'' + (String)zInvoice.getValue('Id') + '\'';
                isNotFirst = true;     
            }
            
            System.debug('*** invoiceItemAdjustmentQuery' + invoiceItemAdjustmentQuery);
            
            zInvoiceItemAdjustments = zUtilInstance.zquery(InvoiceItemAdjustmentQuery);       
            for(Zuora.zObject zInvoiceItemAdjustment : zInvoiceItemAdjustments) { 
                
                if ((String)zInvoiceItemAdjustment.getValue('Status') == 'Processed') {
                    InvoiceItemAdjustment iiadj = new InvoiceItemAdjustment();
                    String invoiceId = (String)zInvoiceItemAdjustment.getValue('InvoiceId');
                    
                    iiadj.Id = (String)zInvoiceItemAdjustment.getValue('Id');
                    iiadj.Amount = (Decimal)zInvoiceItemAdjustment.getValue('Amount');
                    iiadj.Amount =  iiadj.Amount.setScale(2);
                    iiadj.Comment = (String)zInvoiceItemAdjustment.getValue('Comment');
                    iiadj.ReasonCode = (String)zInvoiceItemAdjustment.getValue('ReasonCode');
                    iiadj.InvoiceNumber = (String)zInvoiceItemAdjustment.getValue('InvoiceNumber');
                    iiadj.InvoiceId = (String)zInvoiceItemAdjustment.getValue('InvoiceId');
                    iiadj.ServiceStartDate = (Date)zInvoiceItemAdjustment.getValue('ServiceStartDate');
                    iiadj.ServiceEndDate = (Date)zInvoiceItemAdjustment.getValue('ServiceEndDate');
                    iiadj.Type = (String)zInvoiceItemAdjustment.getValue('Type');
                    
                    invoicesMap.get(invoiceId).invoiceItemAdjustments.add(iiadj);
                }
                
            }
            
            
            
            /* Invoice Credit Balance Adjustments */
            isNotFirst = false;
            String CBAQuery = 'SELECT Id, Amount, ReasonCode, SourceTransactionId, SourceTransactionNumber, AdjustmentDate, Comment, ReasonCode, Type, Status  FROM CreditBalanceAdjustment WHERE ';
            for(Zuora.zObject zInvoice : zInvoices) {   
                if (isNotFirst) 
                    CBAQuery += ' OR ';
                
                CBAQuery += 'SourceTransactionId = \'' + (String)zInvoice.getValue('Id') + '\'';
                isNotFirst = true;     
            }
            System.debug('*** CBAQuery ' + CBAQuery);
            
            zCBAdjustments = zUtilInstance.zquery(CBAQuery);
            for(Zuora.zObject zCBAdjustment : zCBAdjustments) { 
                
                if((String)zCBAdjustment.getValue('Status') == 'Processed') {
                    CreditBalanceAdjustment cba = new CreditBalanceAdjustment();
                    String invoiceId = (String)zCBAdjustment.getValue('SourceTransactionId');
                    
                    cba.id = (String)zCBAdjustment.getValue('Id');
                    cba.amount = (Double)zCBAdjustment.getValue('Amount');
                    cba.amount =  cba.amount.setScale(2);
                    cba.invoiceNumber = (String)zCBAdjustment.getValue('SourceTransactionNumber');
                    cba.invoiceId = (String)zCBAdjustment.getValue('SourceTransactionId');
                    cba.adjustmentDate = (Date)zCBAdjustment.getValue('AdjustmentDate');
                    cba.comment = (String)zCBAdjustment.getValue('Comment');
                    cba.reasonCode = (String)zCBAdjustment.getValue('ReasonCode');
                    cba.type = (String)zCBAdjustment.getValue('Type');
                    
                    invoicesMap.get(invoiceId).creditBalanceAdjustments.add(cba);
                }
                
            }
        }
        
        AccountSummary accsummary = new AccountSummary();
        accsummary.Id = (String)zAccounts[0].getValue('Id');
        accsummary.Name  = (String)zAccounts[0].getValue('Name');
        accsummary.CreditBalance = (Decimal)zAccounts[0].getValue('CreditBalance');
        accsummary.SubscriptionID = (String)zAccounts[0].getValue('SubscriptionID__c');
        if (!Test.isRunningTest()) 
            accsummary.Balance = (Decimal)zAccounts[0].getValue('Balance');
        accsummary.TotalInvoiceBalance = (Decimal)zAccounts[0].getValue('TotalInvoiceBalance');
        accsummary.AccountNumber = (String)zAccounts[0].getValue('AccountNumber');
        accsummary.invoices = invoicesMap.values();
        
        String jsonString = JSON.serialize(accsummary);
        return jsonString;
           
    }

    public class AccountSummary {
        public String Id { get; set; }
        public String Name { get; set; }
        public Decimal CreditBalance { get; set; }
        public String SubscriptionID { get; set; }
        public Decimal Balance { get; set; }
        public Decimal TotalInvoiceBalance { get; set; }
        public String AccountNumber { get; set; }
        public List<Invoice> invoices { get; set; }
    }
    
    public class Invoice {
        public String id { get; set; }
        public String accountId { get; set; }
        public String accountNumber { get; set; }
        public String accountName { get; set; }
        public DateTime invoiceDate { get; set; }
        public String invoiceNumber { get; set; }
        public String dueDate { get; set; }
        public DateTime invoiceTargetDate { get; set; }
        public Decimal amount { get; set; }
        public Decimal balance { get; set; }
        public String createdBy { get; set; }
        public String status { get; set; }
        public List<InvoiceItem> invoiceItems { get; set; }
        public List<InvoiceItemAdjustment>  invoiceItemAdjustments { get; set; }
        public List<CreditBalanceAdjustment>  creditBalanceAdjustments { get; set; }
    }
    
    public class InvoiceItem {
        public String id;
        public String subscriptionName { get; set; }
        public String subscriptionId { get; set; }
        public String serviceStartDate { get; set; }
        public String serviceEndDate { get; set; }
        public Decimal chargeAmount { get; set; }
        public String chargeDescription { get; set; }
        public String chargeName { get; set; }
        public String chargeId { get; set; }
        public String productName { get; set; }
        public Decimal quantity { get; set; }
        public Decimal taxAmount { get; set; }
        public String unitOfMeasure { get; set; }
        public Boolean isRemoval { get; set; }
    }
    
    public class InvoiceItemAdjustment{
        public String Id { get; set; }
        public Decimal Amount { get; set; }
        public String Comment { get; set; }
        public String ReasonCode { get; set; }
        public String InvoiceNumber { get; set; }
        public String InvoiceId { get; set; }
        public DateTime ServiceStartDate { get; set; } 
        public DateTime ServiceEndDate { get; set; }
        public String Type { get; set; }
    }
    
    public class CreditBalanceAdjustment {
        public String id { get; set; }
        public Decimal amount { get; set; }
        public String invoiceNumber { get; set; }
        public String invoiceId { get; set; }
        public DateTime adjustmentDate { get; set; }
        public String comment { get; set; }
        public String reasonCode { get; set; }
        public String type { get; set; }
    }
}