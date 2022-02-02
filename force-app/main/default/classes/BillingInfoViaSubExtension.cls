public class BillingInfoViaSubExtension {

    public class SubSummary implements Comparable {
        public String type { get; set; }
        public String rate { get; set; }
        public String term_start_date { get; set; }
        public String term_end_date { get; set; }
        public String next_renewal_date { get; set; }
        public String last_bill_date { get; set; }
        public String next_bill_date { get; set; }
        public String last_payment_date { get; set; }
        public String current_balance { get; set; }
        public String future_type { get; set; }
        public String future_rate { get; set; }
        public String future_renewal_date { get; set; }
        public Boolean auto_renew { get; set; }
        public String core_sub_status { get; set; }
        public String core_sub_id { get; set; }
        
        public SubFlags flags { get; set; }
        
        public SubSummary() {
            flags = new SubFlags();
        }
        
        public Integer compareTo(object compareTo) {
            SubSummary other = (SubSummary)compareTo;
            
            if(flags.isCore && other.flags.isCore) {
                return flags.isPrimary ? -1 : 1;  
            } else if(flags.isCore) {
                return -1;
            } else if(other.flags.isCore) {
                return 1;
            } else if(flags.inTerm && other.flags.inTerm) {
                return this.type < other.type ? -1 : 1;
            } else if(flags.inTerm) {
                return -1;
            } else {
                return 1;
            }            
        }
        
    }
    
    public class SubFlags {
        public Boolean inTerm { get; set; }
        public Boolean hasAutoPay { get; set; }
        public Boolean isSuspended { get; set; }
        public Boolean isCore { get; set; }
        public Boolean isPrimary { get; set; }
        public Boolean isActive { get; set; }
        
        public SubFlags() {
            inTerm = false;
            hasAutoPay = false;
            isSuspended = false;
            isCore = false;
            isPrimary = false;
            isActive = false;
        }
    }


    private Subscriptions__c s;
    private Contact c;
    private Account glue;
        
    private List<Id> zuora_accounts;
   
    public Boolean isBillingInfo{set; get;}
    
    public BillingInfoViaSubExtension(ApexPages.StandardController controller) {
        try {
            zuora_accounts = new List<Id>();
        
            Subscriptions__c sub = (Subscriptions__c) controller.getRecord();
            List<Subscriptions__c> subs = [select Id, Contact__c from Subscriptions__c where Id = :sub.Id];
            if(subs != null && subs.size() > 0) {
                s = subs.get(0);
            }
    
            if(s == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid subscription id'));
                return;
            }
            
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sync')) && Boolean.valueOf(ApexPages.currentPage().getParameters().get('sync'))) {
                isBillingInfo = false;
                OnDemandSync();
            }
            else
                isBillingInfo = true;        
            
             
            List<Contact> con = [select Id, Status__c from Contact where Id = :s.Contact__c];
            if(con != null && con.size() > 0) {
                c = con.get(0);
            } 
            else
                throw new CustomException('Contact does not exist.');     
              
            List<Account> acc = [select Id from Account where Contact__c = :c.Id];
            if(acc != null && acc.size() > 0) {
                glue = acc.get(0);
            }
            else
                throw new CustomException('Person account does not exist.');  
                        
            for(Zuora__CustomerAccount__c billingAccount : [select Id,Zuora__Zuora_Id__c from Zuora__CustomerAccount__c  where Zuora__Account__c = :glue.Id]){
                zuora_accounts.add(billingAccount.Id);
            }
            if(zuora_accounts.size() == 0)
                throw new CustomException('Billing accounts do not exist.'); 
        }
        catch (Exception e) {
            isBillingInfo = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }


    public List<SubSummary> Summaries {
        get {
            List<SubSummary> summary_list = new List<SubSummary>();
            Map<Id,Zuora__SubscriptionProductCharge__c> charges = getSubProductChargeMap();
            Map<String,SubSummary> subs_by_product = new Map<String,SubSummary>();

            if (charges.Size() > 0) {
                system.debug('*** charges : ' + charges.keyset());
                for(Zuora__Subscription__c zsub : SubsList) {
                    system.debug('*** zsub : ' + zsub );
                    system.debug('*** SubsList size : ' + SubsList.size());
                    String key = zsub.Zuora__CustomerAccount__c + zsub.Zuora__Zuora_Id__c;
                    Zuora__SubscriptionProductCharge__c charge = charges.get(zsub.Id);
                    
                    if(charge != null){
                        SubSummary sum = SummarizeSubscription(charge);
                        subs_by_product.put(key,sum);
                        
                        if(zsub.Zuora__SubscriptionStartDate__c <= Date.today()) {
                            sum.auto_renew = zsub.Zuora__AutoRenew__c;
                            if(zsub.Zuora__TermStartDate__c <= Date.today() && zsub.Zuora__TermEndDate__c >= Date.today()) sum.flags.inTerm = true;
                            if(zsub.Zuora__AutoRenew__c) {
                                AddFutureDetails(sum, charges.get(zsub.Id));
                                sum.next_renewal_date = formatDate(zsub.Zuora__NextRenewalDate__c);
                            }
                            
                        } else {
                            sum = subs_by_product.get(key);
                            AddFutureDetails(sum, charges.get(zsub.Id));
                            sum.auto_renew = zsub.Zuora__AutoRenew__c;
                            sum.next_renewal_date = formatDate(zsub.Zuora__TermStartDate__c);
                        }
                        
                        if(zsub.isCore__c != null)
                            sum.flags.isCore = Boolean.valueOf(zsub.isCore__c);
                        else
                            sum.flags.isCore = false;
                        sum.flags.isPrimary = sum.flags.isCore && zsub.Zuora__CustomerAccount__r.Subscription__r.Primary__c;
                        sum.flags.hasAutoPay = zsub.Zuora__CustomerAccount__r.Zuora__AutoPay__c;
                        sum.flags.isSuspended = (zsub.Zuora__CustomerAccount__r.Subscription__r.Status_Change_Reason__c == 'Suspended');
                        sum.flags.isActive = (zsub.Zuora__CustomerAccount__r.Subscription__r.Status__c == 'Active');
                        sum.core_sub_status = zsub.Zuora__CustomerAccount__r.Subscription__r.Status__c;
                        sum.core_sub_id = zsub.Zuora__CustomerAccount__r.Subscription__r.Name;
                    }
                }
                List<SubSummary> sorted = subs_by_product.values();
                sorted.sort();
                return sorted;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product charges not found')); 
                return null;            
            }
        }
    }
    
    public List<Zuora__Subscription__c> SubsList {
        get {
            List<Zuora__Subscription__c> zsubs = 
                [select Id, Name, Zuora__CustomerAccount__c, Zuora__AutoRenew__c, Zuora__InitialTerm__c, 
                            Zuora__RenewalTerm__c, Zuora__Status__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                            Zuora__NextChargeDate__c, Zuora__NextRenewalDate__c, Zuora__TermStartDate__c, Zuora__TermEndDate__c, isCore__c, 
                            Zuora__CustomerAccount__r.Subscription__c, Zuora__CustomerAccount__r.Subscription__r.Primary__c, Zuora__CustomerAccount__r.Zuora__AutoPay__c,
                            Zuora__CustomerAccount__r.Subscription__r.Status_Change_Reason__c, Zuora__CustomerAccount__r.Subscription__r.Status__c,
                            Zuora__CustomerAccount__r.Subscription__r.Name,Zuora__Zuora_Id__c 
                        from 
                            Zuora__Subscription__c where Zuora__CustomerAccount__c in :zuora_accounts order by IsCore__c desc, Zuora__SubscriptionStartDate__c];
            return zsubs;
        }
    }
    
    public List<Zuora__ZInvoice__c> InvoiceList {
        get {
            List<Zuora__ZInvoice__c> zinv = 
                [select Id,
                        Name, Zuora__Balance2__c, Zuora__TotalAmount__c, Zuora__Status__c, Zuora__DueDate__c, 
                        Zuora__BillingAccount__r.SubscriptionID__c, Zuora__PaymentAmount__c, Zuora__RefundedAmount__c
                    from
                        Zuora__ZInvoice__c where Zuora__BillingAccount__c in :zuora_accounts];
            return zinv;
        }
    }
    
    // em April 17, 2015
         Public Decimal zBalance{
         get{
           Decimal zb=0;
           if(InvoiceList.Size() > 0) {
                for(Zuora__ZInvoice__c zinv : InvoiceList) {
                 zb=zb+zinv.Zuora__Balance2__c;
                 }           
             }
             return zb;
           }
           
         }
         
         
         Public Decimal zBalanceAll{
         get{
           Decimal zba=0;
           //zuora_accounts
           for(Zuora__CustomerAccount__c billingAccount : [select Id,Zuora__Zuora_Id__c, Zuora__Balance__c from Zuora__CustomerAccount__c  where Zuora__Account__c = :glue.Id]){
                zba=zba+billingAccount.Zuora__Balance__c;
            }

           return zba;
                      
           }
         }

       // em end  


    public List<Zuora__Payment__c> PaymentList {
        get {
            List<Zuora__Payment__c> zpay = 
                [select Id, 
                        Name, Zuora__BillingAccount__r.SubscriptionID__c, Zuora__Amount__c, Zuora__PaymentMethod__c, 
                        Zuora__Status__c, Zuora__SubmittedOn__c, Zuora__GatewayResponse__c
                    from
                        Zuora__Payment__c where Zuora__BillingAccount__c in :zuora_accounts];
            return zpay;
        }
    }
    
    public List<Zuora__PaymentMethod__c> MethodList {
        get {
            List<Zuora__PaymentMethod__c> zmethod = [select Id, Name, Zuora__Type__c, Zuora__CreditCardType__c, Zuora__CreditCardHolderName__c, Zuora__CreditCardMaskNumber__c, Zuora__PaymentMethodStatus__c, Zuora__DefaultPaymentMethod__c from Zuora__PaymentMethod__c where Zuora__BillingAccount__c in :zuora_accounts];
            return zmethod;
        }
    }
    

    private SubSummary SummarizeSubscription(Zuora__SubscriptionProductCharge__c chg) {
        system.debug('*** Summerise chg :' + chg);
        SubSummary sum = new SubSummary();
        sum.type = chg.Zuora__RatePlanName__c;
        sum.rate = String.valueOf(chg.Zuora__Price__c);
        sum.term_start_date = formatDate(chg.Zuora__EffectiveStartDate__c);
        sum.term_end_date = formatDate(chg.Term_End_Date__c);
        sum.next_bill_date = formatDate(chg.Next_Charge_Date__c);
        return sum;       
    }
    
    private void AddFutureDetails(SubSummary sum, Zuora__SubscriptionProductCharge__c chg) {
        system.debug('*** Future sum :' + sum);
        system.debug('*** Future chg :' + chg);
        sum.future_type = chg.Zuora__RatePlanName__c;
        sum.future_rate = String.valueOf(chg.Zuora__Price__c);
    }
    
    private Map<Id,Zuora__SubscriptionProductCharge__c> getSubProductChargeMap() {
        Map<Id,Zuora__SubscriptionProductCharge__c> zsub_charges = new Map<Id,Zuora__SubscriptionProductCharge__c>();
        if (glue == null)
            return zsub_charges;
            
        List<Zuora__SubscriptionProductCharge__c> charges = [select Id, Name, Zuora__Subscription__c, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Price__c, Next_Charge_Date__c, Zuora__EffectiveStartDate__c, Term_End_Date__c from Zuora__SubscriptionProductCharge__c where Zuora__Account__c = :glue.Id and Zuora__Type__c = 'Recurring'];
        for(Zuora__SubscriptionProductCharge__c chg : charges) {
            system.debug('*** chg  : ' + chg );
            zsub_charges.put(chg.Zuora__Subscription__c,chg);
        }
        return zsub_charges;
    }
    
    private String formatDate(Date dt) {
        if(dt != null)
            return dt.month() + '/' + dt.day() + '/' + String.valueOf(dt.year()).right(2);
        else 
            return null;
    }
    
    public void OnDemandSync() {
        String subId = s.Id;
        set<String> zAccountsId = new Set<String>();
        set<Id> billingAccountIds = new Set<Id>();
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id, Name, Zuora__Zuora_Id__c, Subscription__c FROM Zuora__CustomerAccount__c WHERE Subscription__c = :subId];     
        
        if (billingAccounts.Size() > 0) {
            for(Zuora__CustomerAccount__c billingAccount : billingAccounts) 
               billingAccountIds.add(billingAccount.Id); 
               
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.syncObjectIdSet = billingAccountIds;                                    
        }
        else {
            Subscriptions__c subscription = [SELECT Id, Name FROM Subscriptions__c WHERE Id = :subId];
            if (String.isNotBlank(subscription.Name)) {
                
                SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
                
                String zAccountsQuery = 'SELECT Id FROM Account WHERE SubscriptionID__c = \'' + subscription.Name + '\'';                       
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
                for (Zuora.zObject zAccount : zAccounts) 
                    zAccountsId.add(String.valueOf(zAccount.getValue('Id')));
                    
                syncManager.syncZuoraObjectIdSet = zAccountsId;               
            } 
        }
        
        if (zAccountsId.Size() > 0 || billingAccountIds.Size() > 0) {
              
            List<Zuora.SyncResult> syncResults = syncManager.sendRequest();
    
            for(Zuora.SyncResult syncResult : syncResults){
                if(syncResult.success)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The sync request has been submitted successfully.Please allow a few minutes for the request to be processed.'));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No related data found with this subscription id.'));             
    }
    
    public PageReference Redirect() {
        String subId =  ApexPages.currentpage().getparameters().get('id');
        PageReference obn = new PageReference('/apex/SMS_OutstandingBalanceNotification?id=' + subId);
        obn.setRedirect(true);
        return obn;    
    
    }
    
    public Class CustomException extends Exception {}
}