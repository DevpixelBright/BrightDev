public class SMS_OutstandingInvoices_Controller {
    public Integer outstandingCount { get; set; }
    public Boolean showButton { get; set; }
    public Map<Id,Zuora__CustomerAccount__c> outstandingAccounts { get; set; }
    
    public SMS_OutstandingInvoices_Controller(){
        outstandingAccounts = new Map<Id,Zuora__CustomerAccount__c>([SELECT Id
                               FROM   Zuora__CustomerAccount__c 
                               WHERE Zuora__Balance__c > 0 AND Email_Invoice_PDF__c = false
                              ]);
        
        outstandingCount = outstandingAccounts.size();

        if(outstandingCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'There are no billing accout with an outstanding balance'));
            showButton = false;
        }
        else 
            showButton = true;
    }
    
    public void generateInvoicePdfs(){        
        List<Id> billingAccountIds = new List<Id>(outstandingAccounts.keyset());
        
        if(billingAccountIds.size() > 0){
            SMS_OutstandingBalanceInvoiceResults batchJob = new SMS_OutstandingBalanceInvoiceResults(billingAccountIds);
            Database.executeBatch(batchJob, 15);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'A Batch process has been initiated'));
            showButton = false;
        }
    }
}