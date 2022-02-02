public class SMS_InvoiceSummaryPDF {    
    
    public Id recordId { get; set; }
    public Map<String, Map<String, Decimal>> subTotalMap { get; set; }
    public Subscriptions__c sub { get; set; }
    public String invoiceJsonString {get;set;}

    
    public SMS_InvoiceSummaryPDF(){
    
    }
    
    public String getStatementDate() {
        DateTime d = DateTime.now();
        return d.format('MM/dd/yyyy', 'GMT');    
    }    
    
    public AccountSummary getInvoiceResult(){
        AccountSummary result;
        try {
            system.debug('invoiceJsonString  '+invoiceJsonString);
            system.debug('recordId  '+recordId);
            
            if(recordId != null){
                
            
            Zuora__CustomerAccount__c zAccount = [SELECT Id, Name, Invoice_REST_Response__c, Email_Invoice_PDF__c, MRIS_Subscription_Record__c 
                                                  FROM Zuora__CustomerAccount__c 
                                                  WHERE Id= :recordId];
    
            sub = [SELECT Id, Name, CUSTOMERNAME__c, Street_Number__c, Street_Name__c, City__c, State__c, Zip__c, QAS_Mailing_Country__c  FROM Subscriptions__c WHERE Id = :zAccount.MRIS_Subscription_Record__c];
            
             result = (AccountSummary) JSON.deserialize(zAccount.Invoice_REST_Response__c, AccountSummary.class); 
            
            }else if (invoiceJsonString != null){
                result = (AccountSummary) JSON.deserialize(invoiceJsonString, AccountSummary.class); 
            }
    
            
            
            subTotalMap = new Map<String, Map<String, Decimal>>();
            /* Calculating subscription total */
            for (Invoice invoice : result.invoices) {
                
                Map<String, Decimal> subTotal = new Map<String, Decimal>();
                for (InvoiceItem item : invoice.invoiceItems) {
                    
                    if (!subTotal.keySet().contains(item.subscriptionName)) {
                        subTotal.put(item.subscriptionName, item.chargeAmount);
                    }
                    else {
                        Decimal amount = subTotal.get(item.subscriptionName);
                        subTotal.put(item.subscriptionName, item.chargeAmount + amount);
                    }
                    
                }
                
                subTotalMap.put(invoice.invoiceNumber, subTotal);
                
            } 
        }       
        catch(Exception e) {
            result = new AccountSummary();
        }
        return result;      
           
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