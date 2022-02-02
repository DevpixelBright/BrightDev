public class SMS_OutstandingNotification_Controller {
    
    public String subId { get; set; }
    public Zuora__CustomerAccount__c zAcct { get; set; }
    public String prevEmail;
    public Boolean showSendButton { get; set; }
    
    public SMS_OutstandingNotification_Controller() {
        subId = ApexPages.currentpage().getparameters().get('id');
        showSendButton = true;

        try {
            zAcct = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__Balance__c, MRIS_Subscription_Record__c, SubscriptionID__c, Private_Email__c 
                     FROM Zuora__CustomerAccount__c 
                     WHERE MRIS_Subscription_Record__c = :subId]; 
                     
            if(!(zAcct.Zuora__Balance__c > 0)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Account does not have outstanding balance'));
                showSendButton = false;
            } 
            else
               prevEmail = zAcct.Private_Email__c; 
                                  
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Billing Account does not exist'));
            showSendButton = false;
        } 
                                                                                                 
    }
    
    public void invoiceResult() {
        if(showSendButton) {
            zAcct.Invoice_REST_Response__c = SMS_UpdateZInvoice.updateZInvoice(zAcct.Id);
            zAcct.Email_Invoice_PDF__c = false; 
            update zAcct;
        }      
    }
    
    public pagereference previewInvoiceSummary() {
        return null;
    }
    
    public pagereference sendInvoiceSummary() {
        zAcct.Invoice_REST_Response__c = SMS_UpdateZInvoice.updateZInvoice(zAcct.Id);
        zAcct.Email_Invoice_PDF__c = false;
        update zAcct;
        
        zAcct.Email_Invoice_PDF__c = true;
        update zAcct;
        
        zAcct.Private_Email__c = prevEmail; 
        update zAcct;      
                 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Notification sent successfully'));                       
        return null;
    }    
    
}