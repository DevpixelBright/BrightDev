global class SMS_OutstandingBalanceInvoiceResults implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    private List<Id> billingAccountIds;
    private Set<String> emailSentSubscriptions;
    private Set<String> emailNotSentSubscriptions;
    private Set<String> subscriptionIds;
    
    global SMS_OutstandingBalanceInvoiceResults(List<Id> billingAccountIds) {       
        // Execute this batch class with batch size 15
        
        this.billingAccountIds = new List<Id>();
        this.billingAccountIds = billingAccountIds;
        
        emailSentSubscriptions = new Set<String>();
        emailNotSentSubscriptions = new Set<String>();
        subscriptionIds = new Set<String>();
        
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        String query = 'SELECT Id,Zuora__Zuora_Id__c,Invoice_REST_Response__c,Email_Invoice_PDF__c,Subscription__r.Name FROM Zuora__CustomerAccount__c WHERE  Zuora__Balance__c > 0 AND Id IN :billingAccountIds';
        if(Test.isRunningtest())
                      query += ' LIMIT 2 ';
        return Database.getQueryLocator(query);
    
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){      
        system.debug('*** Callouts Allowed for this Batch: ' + Limits.getLimitCallouts());
        List<Zuora__CustomerAccount__c> billingAcounts = new List<Zuora__CustomerAccount__c>();
        
        try{
            for(sObject ba : scope){
                Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
                billingAccount = (Zuora__CustomerAccount__c)ba;
                
                String billId = String.ValueOf(billingAccount.get('Id'));
                billingAccount.Invoice_REST_Response__c = SMS_UpdateZInvoice.updateZInvoice(billingAccount.Id); 
                billingAccount.Email_Invoice_PDF__c = true;
                
                billingAcounts.add(billingAccount);
                system.debug('*** billingAccount:' + billingAccount);
                
                subscriptionIds.add(billingAccount.Subscription__r.Name);           
            }
            
            update billingAcounts;   
            
            
        }
        catch(Exception e){
            for(sObject ba : scope){
                Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
                billingAccount = (Zuora__CustomerAccount__c)ba;
                subscriptionIds.remove(billingAccount.Subscription__r.Name);
            }
            SMS_ZuoraHistory.createError(e,'SMS_OutstandingBalanceInvoiceResults',null);
        }   
    }
    
    
    global void finish(Database.BatchableContext BC){
        /*
        List<Task> tasks = [SELECT Id,What.Name
                                FROM   Task WHERE What.Name IN :subscriptionIds
                                AND    Createddate = TODAY 
                                AND    Subject LIKE '%Statement of Account%'];
                                
                
            for(String subId : subscriptionIds){
                Boolean emailSent = false;
                for(Task t : tasks){
                    if(subId == t.What.Name)
                        emailSent = true;
                }
                
                if(emailSent)
                    emailSentSubscriptions.add(subId); 
                else
                    emailNotSentSubscriptions.add(subId); 
            } 
            
        String sentIds = '';
        for(String subId : emailSentSubscriptions)
            sentIds += subId + '\n';        
        
        String notSentIds = '';
        for(String subId : emailNotSentSubscriptions)
            notSentIds += subId + '\n';
        */
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                 TotalJobItems, CreatedBy.Email, CreatedBy.Name
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()
                         ];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('SMS OutstandingBalance Notifications - Invoice PDF');
        
        String sentIds = '';
        for(String subId : subscriptionIds)
            sentIds += subId + '\n'; 
        
        mail.setPlainTextBody('Dear ' + a.CreatedBy.Name + ',\n\nThe OutstandingBalance Notifications job has processed ' + billingAccountIds.size() + 
                              ' subscriptions where ' + subscriptionIds.size() +  ' emails have been initiated.Below are the list of subscription ids ' + 
                              'for which emails have been initiated\n\nSubscription Ids: \n\n' +  sentIds);
                              
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }    
    
    public class CustomException extends Exception {} 
    
}