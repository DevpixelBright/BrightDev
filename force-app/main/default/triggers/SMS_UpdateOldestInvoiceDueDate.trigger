trigger SMS_UpdateOldestInvoiceDueDate on Zuora__ZInvoice__c (after insert, after update) {

    Set<String> sUpdateDueDateBillAccIds = new Set<String>();
    
    if(trigger.IsInsert){
        for(Zuora__ZInvoice__c zInvoice : trigger.new)  
            sUpdateDueDateBillAccIds.add(zInvoice.Zuora__BillingAccount__c);
    }
    else {
        for(Zuora__ZInvoice__c zInvoice : trigger.new) {
            if(zInvoice.Zuora__Balance2__c != trigger.oldMap.get(zInvoice.id).Zuora__Balance2__c )              
                sUpdateDueDateBillAccIds.add(zInvoice.Zuora__BillingAccount__c);  
        }
    }        
    
    if(sUpdateDueDateBillAccIds.size() > 0) 
        SMS_UpdateOldestInvoiceDueDate.updateInvoiceDueDate(sUpdateDueDateBillAccIds);    
        
    
    /*
    if(sBillingAccountIds.size() > 0) {
        Map<String,Zuora__CustomerAccount__c> sBillAccId = new Map<String,Zuora__CustomerAccount__c>(); 
        List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>();
        
        for(Zuora__CustomerAccount__c billingAccount : [SELECT id,Oldest_Invoice_Due__c FROM Zuora__CustomerAccount__c WHERE id in :sBillingAccountIds]) {
            sBillAccId.put(billingAccount.id,billingAccount);     
        }        
                 
        for(AggregateResult result : [SELECT   Min(Zuora__DueDate__c) dueDate,
                                               Zuora__BillingAccount__c billAccId
                                      FROM     Zuora__ZInvoice__c
                                      WHERE    Zuora__Balance2__c > 0
                                      AND      Zuora__BillingAccount__c in :sBillingAccountIds
                                      GROUP BY Zuora__BillingAccount__c
                                     ]) {
            system.debug('*** Invoice Result : ' + result);
            Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
            system.debug('*** Before Update : ' + billingAccount);
            billingAccount = sBillAccId.get(String.ValueOf(result.get('billAccId')));
            billingAccount.Oldest_Invoice_Due__c = Date.ValueOf(result.get('dueDate'));
            system.debug('*** After Update : ' + billingAccount);
            sBillingAccounts.add(billingAccount);
        }
        
        update sBillingAccounts;
    }
    */
    
}