global class SMS_LateFees_Zuora implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    /*
    1. Query Zuora for the list of account for which the balance is greater than $50 and active(ListA)
    2. Query SF for the list of billing accounts for which the oldest invoice date is more than threshold days,
    Late Fees Charge Date is null and Zuora Id in ListA (ListB)
    4. Query SF for Zuora Subscription object for which IsCore__c = true and zAccountid in ListB (ListC)
    5. Create zuora amendments (add a product) to add the late fee to the core subscriptions.
    6. Insert SMS Late Fees History object and update Billing Account for which the amendments were successful.
    */
    
    List<SMS_Late_Fee_History__c> lateFeeHistories;    
    List<Zuora__CustomerAccount__c> lateFeesAppliedAccounts;
    
    String batchId;	
    Integer lateFeeCount;
    Date dueDate;  
    
    Integer maximumAccounts;
    Double amount;
    Integer days;
    
    Zuora.zApi zApiInstance;
    Zuora.zApi.LoginResult zLoginResult;
    
    public SMS_LateFees_Zuora(String maximumAccounts, String amount, String days){
        this.maximumAccounts = Integer.ValueOf(maximumAccounts);  
        this.amount = Double.ValueOf(amount);  
        this.days = Integer.ValueOf(days);
        
        dueDate = Date.today().addDays(-this.days);
        batchId = 'LFS - ' + system.now();
        
        system.debug('*** maximumAccounts : ' + maximumAccounts + '*** amount :' + amount + '*** days :' + days );     
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        SMS_LateFees_Status__c setting = SMS_LateFees_Status__c.getValues('Late Fees');
        Set<String> includedBillingJurisdictions = new Set<String>();
        //Set<String> includedServiceJurisdictions = new Set<String>();


        
        //Including billing jurisdictions
        if(String.isNotBlank(setting.IncludedBillingJurisdictions__c)){
            includedBillingJurisdictions.addAll(setting.IncludedBillingJurisdictions__c.split(','));
            
        }
        
        // Including service jurisdictions
        /*if(String.isNotBlank(setting.IncludedServiceJurisdictions__c)){
            includedServiceJurisdictions.addAll(setting.IncludedServiceJurisdictions__c.split(','));
            
        }*/
        
        if(setting.IsActive__c) {
            system.debug('************** Late Fee setting is active******');
            lateFeeCount = 0;
            
            String query = 'SELECT Id, Zuora__Zuora_Id__c, Private_Email__c, SubscriptionID__c, Zuora__Account__r.Name, Subscription__r.Billing_Jurisdiction__c, Subscription__r.Service_Jurisdiction__c, ';
            query += 'LateFees_ChargeDate__c, Oldest_Invoice_Due__c';
            query += ' FROM   Zuora__CustomerAccount__c'; 
            query += ' WHERE  Oldest_Invoice_Due__c < :dueDate';
            query += ' AND    Subscription__r.Status__c = \'Active\'';
            query += ' AND    Subscription__r.IsExcludedFromAutomatedSuspension__c = false';
            query += ' AND    LateFees_ChargeDate__c = null';
            query += ' AND    Zuora__Balance__c > :amount';
            
         
            
            if(includedBillingJurisdictions.size() > 0){
                Boolean isNotFirst= false;
                String jurisdictions = ' AND Subscription__r.Billing_Jurisdiction__c  IN (';
                for(String jurisdiction : includedBillingJurisdictions){
                    if (isNotFirst) 
                        jurisdictions = jurisdictions + ',';
                    
                    jurisdictions = jurisdictions + '\'' + jurisdiction + '\'';
                    if(jurisdiction == 'MRIS')
                        jurisdictions = jurisdictions + ', NULL';
                    isNotFirst = true;
                }
                jurisdictions = jurisdictions + ')';
                query += jurisdictions;
            }
            
           /* if(includedServiceJurisdictions.size() > 0){
                Boolean isNotFirst= false;
                String jurisdictions = ' AND Subscription__r.Service_Jurisdiction__c  IN (';
                for(String jurisdiction : includedServiceJurisdictions){
                    if (isNotFirst) 
                        jurisdictions = jurisdictions + ',';
                    
                    jurisdictions = jurisdictions + '\'' + jurisdiction + '\'';
                    if(jurisdiction == 'MRIS')
                        jurisdictions = jurisdictions + ', NULL';
                    isNotFirst = true;
                }
                jurisdictions = jurisdictions + ')';
                query += jurisdictions;
            }*/ 
            query += ' ORDER BY Oldest_Invoice_Due__c ';
             system.debug('*** query :' + query);
             system.debug('*** Database.getQueryLocator(query):' + Database.getQueryLocator(query));
            return Database.getQueryLocator(query);
            

        }
        else
            return null;
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){ 
        
        system.debug('*** Batch Execute Method');
        Map<String,Zuora__CustomerAccount__c> lateFeesAppliedAccounts = new Map<String,Zuora__CustomerAccount__c>(); //Map by billing account recordId to avoid duplicates
        List<SMS_Late_Fee_History__c> lateFeeHistories = new List<SMS_Late_Fee_History__c>(); 
        
        zApiInstance = new Zuora.zApi();
        zLoginResult = zApiInstance.zlogin();       
        
        String zLateFeeProductName = SMS_LateFees_Status__c.getall().values()[0].Name;
        String zLateFeeRatePlanId = SMS_LateFees_Status__c.getValues(zLateFeeProductName).Zuora_ProductRatePlan_Id__c;
        
        try {        
            for(sObject ba : scope){
                if(lateFeeCount < maximumAccounts){
                    Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
                    billingAccount = (Zuora__CustomerAccount__c)ba;
                    
                    system.debug('*** billingAccount:' + lateFeeCount + '--' +billingAccount);
                    
                    LateFeeDetail lateFeeDetail = new LateFeeDetail();
                    lateFeeDetail = findLateFeeDetails(billingAccount.Zuora__Zuora_Id__c,zLateFeeProductName);
                    
                    if(lateFeeDetail.canLateFeesBeApplied){
                        Zuora.zApi.AmendResult zAmendResult = new Zuora.zApi.AmendResult();
                        
                        zAmendResult = zApiInstance.zamend(new List<Zuora.zApi.AmendRequest> { getNewProductAmendmentRequest(lateFeeDetail.zSubscriptionId,zLateFeeRatePlanId)}); 
                        
                        system.debug('*** zAmendResult :' + zAmendResult );
                        
                        SMS_Late_Fee_History__c lateFeeHistory = new SMS_Late_Fee_History__c();
                        lateFeeHistory.Contact_Private_Email__c  = billingAccount.Private_Email__c;
                        lateFeeHistory.Customer_Name__c = billingAccount.Zuora__Account__r.Name;
                        lateFeeHistory.Date_of_Assessment__c = system.today();
                        lateFeeHistory.Day_of_Assessment__c = system.now().format('EEEE');
                        lateFeeHistory.Subscription_ID__c = billingAccount.SubscriptionID__c;
                        lateFeeHistory.Total_Amount_Due__c = lateFeeDetail.zAccountBalance;
                        lateFeeHistory.Zuora_Account_Id__c = billingAccount.Zuora__Zuora_Id__c;
                        lateFeeHistory.Late_Fees_Batch_ID__c = batchId;
                        lateFeeHistory.Service_Jurisdiction__c = billingAccount.Subscription__r.Service_Jurisdiction__c;                        
                        lateFeeHistory.Billing_Jurisdiction__c = billingAccount.Subscription__r.Billing_Jurisdiction__c;
                        if (zAmendResult.Success){                        
                            lateFeeHistory.Status__c = 'Charged';
                            lateFeeHistories.add(lateFeeHistory);
                            billingAccount.LateFees_ChargeDate__c = system.today(); 
                            lateFeesAppliedAccounts.put(billingAccount.Id,billingAccount);
                            lateFeeCount++;                        
                        }
                        else {       
                            
                            Zuora.zObject[] errors = zAmendResult.errors;
                            String errorMsg = 'Failed : ';
                            for (Zuora.zObject error : errors)
                                errorMsg = errorMsg + (String)error.getValue('Code') + '-' + (String)error.getValue('Message') ;
                            
                            lateFeeHistory.Status__c = 'Failed';
                            lateFeeHistory.Status_Message__c = errorMsg;
                            //system.debug('*** lateFeeHistory :' + lateFeeHistory');
                            
                            lateFeeHistories.add(lateFeeHistory);
                        }                                
                    } 
                    else if(lateFeeDetail.isLateFeeNotPaid && billingAccount.LateFees_ChargeDate__c == null){
                        //Late fee was charged but did not get updated in salesforce. So update LateFeeChargeDate field on Billing Account
                        billingAccount.LateFees_ChargeDate__c = lateFeeDetail.lateFeeChargeDate.date(); 
                        lateFeesAppliedAccounts.put(billingAccount.Id,billingAccount);
                    }             
                }                
            } 
            
            system.debug('*** lateFeeHistories.size() :' + lateFeeHistories.size());
            insert lateFeeHistories;
            
            system.debug('*** lateFeesAppliedAccounts.size() :' + lateFeesAppliedAccounts.size());
            update lateFeesAppliedAccounts.values();
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_LateFees_Zuora',null);
        } 
        
        system.debug('*** FINAL Limits.getCallouts():' + Limits.getCallouts() );                                      
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    private LateFeeDetail findLateFeeDetails(String zAccountId, String zLateFeeProductName){
        LateFeeDetail lateFeeDetail = new LateFeeDetail();
        lateFeeDetail.isLateFeeNotPaid = false;
        lateFeeDetail.canLateFeesBeApplied = false;
        
        Boolean isNotFirst = false;       
        Date todayDate = (datetime.valueOf(DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST'))).date();
        
        String zAccountQuery = 'SELECT Id, Name, Balance, Status FROM Account WHERE Id = \'' + zAccountId + '\' AND Status = \'Active\''; 
        List<Zuora.zObject> zAccounts = zApiInstance.zquery(zAccountQuery);
        
        if(zAccounts.size() != 1)
            throw new CustomException('No Zuora Account found OR Multiple Accounts found for zAccountId: ' + zAccountId);
        
        lateFeeDetail.zAccountBalance = (Double)zAccounts[0].getValue('Balance');
        
        if(lateFeeDetail.zAccountBalance > amount){
            
            String zInvoiceQuery = 'SELECT Id,AccountId,Status,Balance,Amount,Status,CreatedById,InvoiceNumber,InvoiceDate,DueDate,PaymentAmount,TargetDate FROM Invoice WHERE Balance > 0 AND AccountId = \'' + zAccountId + '\'';
            List<Zuora.zObject> zInvoices = zApiInstance.zquery(zInvoiceQuery);
            system.debug('*** zInvoices.size(): ' + zInvoices.size());
            
            if(zInvoices.size() > 0){        
                Date oldestInvoiceDueDate = ((Date)zInvoices[0].getValue('DueDate'));        
                isNotFirst = false;
                
                String invoiceItemQuery = 'SELECT Id,ChargeAmount,ChargeDate,InvoiceId,ProductName,ProductId FROM InvoiceItem WHERE ';
                
                for(Zuora.zObject zInvoice : zInvoices) { 
                    if (isNotFirst) {
                        invoiceItemQuery += ' OR ';
                        if(((Date)zInvoice.getValue('DueDate')) < oldestInvoiceDueDate) 
                            oldestInvoiceDueDate = ((Date)zInvoice.getValue('DueDate'));
                    }             
                    
                    invoiceItemQuery += 'InvoiceId = \'' + (String)zInvoice.getValue('Id') + '\'';
                    isNotFirst = true;
                }       
                
                system.debug('*** oldestInvoiceDueDate: ' + oldestInvoiceDueDate);
                
                List<Zuora.zObject> zInvoiceItems = zApiInstance.zquery(invoiceItemQuery);                
                
                for(Zuora.zObject zInvoiceItem : zInvoiceItems) {   
                    String zProductName = (String)zInvoiceItem.getValue('ProductName'); 
                    if(zProductName.equals(zLateFeeProductName)){ 
                        lateFeeDetail.isLateFeeNotPaid = true; 
                        // lateFeeDetail.lateFeeChargeDate = ((Date)zInvoiceItem.getValue('ChargeDate'));
                        lateFeeDetail.lateFeeChargeDate = ((DateTime)zInvoiceItem.getValue('ChargeDate'));
                    }     
                }
                
                if (!lateFeeDetail.isLateFeeNotPaid && oldestInvoiceDueDate < dueDate){                        
                    lateFeeDetail.canLateFeesBeApplied = true;
                    
                    List<Zuora.zObject> zSubscriptions = new List<Zuora.zObject>();
                    
                    String subscriptionQuery = 'SELECT Id,AccountId,Name,AutoRenew,Status,TermEndDate,TermStartDate,TermType FROM Subscription WHERE ';
                    subscriptionQuery += 'AccountId = \'' + zAccountId + '\' AND Status = \'Active\' AND TermType = \'TERMED\' AND IsCore__c = \'true\'';
                    
                    zSubscriptions = zApiInstance.zquery(subscriptionQuery);
                    
                    for(Zuora.zObject zSubscription : zSubscriptions) {        
                        if(((Date)zSubscription.getValue('TermStartDate')) <= todayDate && ((Date)zSubscription.getValue('TermEndDate')) >= todayDate) { 
                            lateFeeDetail.zSubscriptionId = (String)zSubscription.getValue('Id');                
                        }        
                    }
                }
            }
        }
        
        system.debug('*** isLateFeeNotPaid: ' + lateFeeDetail.isLateFeeNotPaid);
        system.debug('*** lateFeeChargeDate: ' + lateFeeDetail.lateFeeChargeDate);
        system.debug('*** zSubscriptionId:' + lateFeeDetail.zSubscriptionId); 
        system.debug('*** canLateFeesBeApplied: ' + lateFeeDetail.canLateFeesBeApplied);       
        
        return lateFeeDetail;
    }
    
    private Zuora.zApi.AmendRequest getNewProductAmendmentRequest(String zSubscriptionId,String zProductRatePlanId) {
        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST'); 
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();
        
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId',zProductRatePlanId);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Add Late Fees');
        amendment.setValue('SubscriptionId',zSubscriptionId);
        
        amendment.setValue('Type', 'NewProduct');
        amendment.setValue('RatePlanData',ratePlanData);
        
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', effectiveDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', effectiveDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = true;
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    }
    
    public class LateFeeDetail{
        public DateTime lateFeeChargeDate;
        public Boolean isLateFeeNotPaid;
        public String zSubscriptionId;
        public Boolean canLateFeesBeApplied;
        public Double zAccountBalance;
    }
    
    public class CustomException extends Exception {} 
}