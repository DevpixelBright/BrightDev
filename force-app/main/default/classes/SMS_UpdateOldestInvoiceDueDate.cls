public class SMS_UpdateOldestInvoiceDueDate{
    @future
    public static void updateInvoiceDueDate(Set<String> sBillingAccountIds) {
        System.debug('*** sBillingAccountIds:' + sBillingAccountIds);
        if(sBillingAccountIds.size() > 0) {
            Map<String,Zuora__CustomerAccount__c> sBillAccId = new Map<String,Zuora__CustomerAccount__c>(); 
            List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>();
            Map<String, Zuora__CustomerAccount__c> sBillingAccountsMap = new Map<String, Zuora__CustomerAccount__c>();
            
            for(Zuora__CustomerAccount__c billingAccount : [SELECT Id,Oldest_Invoice_Due__c,Zuora__Balance__c 
                                                            FROM   Zuora__CustomerAccount__c 
                                                            WHERE  Id in :sBillingAccountIds]) {
                sBillAccId.put(billingAccount.id,billingAccount);
                if(billingAccount.Zuora__Balance__c <= 0) {
                    billingAccount.Oldest_Invoice_Due__c = null;
                    billingAccount.LateFees_ChargeDate__c = null;
                    //sBillingAccounts.add(billingAccount);
                    sBillingAccountsMap.put(billingAccount.Id, billingAccount);
                }    
            }        
            System.debug('*** sBillingAccountsMap:' + sBillingAccountsMap);   
                                 
            for(AggregateResult result : [SELECT   Min(Zuora__DueDate__c) dueDate,
                                                   Zuora__BillingAccount__c billAccId
                                          FROM     Zuora__ZInvoice__c
                                          WHERE    Zuora__Balance2__c > 0
                                          AND      Zuora__BillingAccount__c in :sBillingAccountIds
                                          GROUP BY Zuora__BillingAccount__c
                                         ]) {
                //system.debug('*** Invoice Result : ' + result);
                Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
                //system.debug('*** Before Update : ' + billingAccount);
                billingAccount = sBillAccId.get(String.ValueOf(result.get('billAccId')));
                billingAccount.Oldest_Invoice_Due__c = Date.ValueOf(result.get('dueDate'));
                //system.debug('*** After Update : ' + billingAccount);
                //sBillingAccounts.add(billingAccount);
                sBillingAccountsMap.put(billingAccount.Id, billingAccount);
            }
            
            for(Zuora__CustomerAccount__c zBillingAccount: sBillingAccountsMap.values()) {
                sBillingAccounts.add(zBillingAccount);
            }
            System.debug('*** sBillingAccountsMap:' + sBillingAccountsMap);
            System.debug('*** sBillingAccounts:' + sBillingAccounts);
            update sBillingAccounts;
        }
    }
    
    /*
    @future
    public static void clearInvoiceDueDate(Set<String> sBillingAccountIds) {
        if(sBillingAccountIds.size() > 0) {
            List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>();
            
            for(Zuora__CustomerAccount__c billingAccount : [SELECT Id,Oldest_Invoice_Due__c 
                                                            FROM   Zuora__CustomerAccount__c 
                                                            WHERE  Id in :sBillingAccountIds]) {
                billingAccount.Oldest_Invoice_Due__c = null;
                sBillingAccounts.add(billingAccount);     
            } 
            
            update sBillingAccounts;
        }
    }
    */
}