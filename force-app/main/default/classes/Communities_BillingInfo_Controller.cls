public class Communities_BillingInfo_Controller{

    private enum zTermStatus { PastTerm, Current, FutureTerm, UNDEF } 
 
    public String id { get; private set; }
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public String cancelUrl { get; private set; }
    public Boolean debugMode { get; private set; }
    public String displayName { get; private set; } // To capture the value for markUserId
    
    public List<SubSummary> bundledCoreSummaries { get; private set; }
    public List<SubSummary> bundledPremiumSummaries { get; private set; }
    public List<SubSummary> expiredBundledSummaries { get; private set; }
    public List<SubSummary> cancelledBundledSummaries { get; private set; }
    public List<SubSummary> futureBundledSummaries { get; private set; }

    //private variables from here: 

    public Map<String, SubSummary> nonBundledSummariesMappedBySubId { get; private set; }
    public List<SubSummary> bundledSummaries { get; private set; }
    public Map<String, Zuora__Subscription__c> zuoraSubscriptionsMappedById;
    
    private Subscriptions__c s;
    private Contact c;
    private Account glue;
    private Set<String> zAccountIds;
        
    private List<Id> zuora_accounts;
    public Boolean isBillingInfo{set; get;}
    
    public Communities_BillingInfo_Controller() {
        initialLoad = true;
        hasError = false;
        
        zuora_accounts = new List<Id>();
        zAccountIds = new Set<String>();

        String debug = ApexPages.currentPage().getParameters().get('debug');
            
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        
        cancelUrl = Label.MRIS_Communities_URL + 'Communities_Subscription';
        
        //initBillingInfoPortal(); <-- do not uncomment this!!! If you need to test something, make sure you comment this out afterward! 
    }

    public void initBillingInfoPortal() {
        initialLoad = false;
        hasError = false;

        try {
            id = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(id)) 
                throw new CustomException('Invalid MRIS Subscription ID'); 

            System.debug('id: ' + id);
            List<Subscriptions__c> subs = [select Id, Contact__c, Name, Service_Jurisdiction__c, Billing_Jurisdiction__c, TREND_Login_Name__c,BRIGHT_LoginName__c from Subscriptions__c where Name = :id];
            if(subs != null && subs.size() > 0) {
                s = subs.get(0);
            }
    
            if(s == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid subscription id'));
                return;
            }
            
            /* Capture display user id for TREND */
            if(s.Service_Jurisdiction__c != null && s.Service_Jurisdiction__c == 'TREND' && s.TREND_Login_Name__c != null)
                displayName = 'TREND: ' + s.TREND_Login_Name__c + ' - ' + s.Name;
            else if(s.Service_Jurisdiction__c != null && s.Service_Jurisdiction__c == 'BRIGHT' && s.BRIGHT_LoginName__c != null)
                displayName = 'BRIGHT: ' + s.BRIGHT_LoginName__c + ' - ' + s.Name;
            else
                displayName = s.Name;             
            
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sync')) && Boolean.valueOf(ApexPages.currentPage().getParameters().get('sync'))) {
                isBillingInfo = false;
                subscriptionOnDemandSync(s.Id);
            }
            else {
                isBillingInfo = true;   
            }     
            
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
                        
            for(Zuora__CustomerAccount__c billingAccount : [select Id,Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c = :glue.Id]){
                zuora_accounts.add(billingAccount.Id);
                zAccountIds.add(billingAccount.Zuora__Zuora_Id__c);
                System.debug('Zuora Account: ' + billingAccount.Id);
            }

            nonBundledSummariesMappedBySubId = getNonBundledSummariesMappedBySubId();
            bundledSummaries = getBundledSummaries();
            bundledSummaries.sort();
            bundledCoreSummaries = getBundledCoreSummaries();
            bundledPremiumSummaries = getBundledPremiumSummaries();
            expiredBundledSummaries = getExpiredBundledSummaries();
            cancelledBundledSummaries = getCancelledBundledSummaries();
            futureBundledSummaries = getFutureBundledSummaries();
            
        }
        catch (Exception e) {
            isBillingInfo = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
            hasError = true;
        }
    }

    //In Zuora, the relationship between Subscription to RatePlan is 1 to 1. And the relationship between RatePlan to RatePlanCharge is 1 to many. 
    //So then, we should have 1 recurring charge in one single Subscription, and that recurring charge may have many RatePlanCharges. 
    //Therefore, the map should have the Subscription ID as the key, and a list of RatePlanCharges as the data. 

    public Map<String, SubSummary> getNonBundledSummariesMappedBySubId() {
         //List<SubSummary> summary_list = new List<SubSummary>();
         List<Zuora__SubscriptionProductCharge__c> RecurringCharges = getRecurringProductChargeList();
         zuoraSubscriptionsMappedById = getZuoraSubscriptionsMappedById;
         
         Map<String, List<Zuora__SubscriptionProductCharge__c> > ChargesMappedBySubscriptionID = new Map <String, List<Zuora__SubscriptionProductCharge__c> >();
         Map<String, Zuora__SubscriptionProductCharge__c> LatestChargeMappedBySubscriptionID = new Map <String, Zuora__SubscriptionProductCharge__c> ();
         Map<String, SubSummary> SubSummaryMappedBySubId = new Map<String, SubSummary>();

         if(RecurringCharges.size() > 0) {
             for (Zuora__SubscriptionProductCharge__c RecurringCharge : RecurringCharges) {
                 String SubscriptionId = RecurringCharge.Zuora__Subscription__c;
                 if (ChargesMappedBySubscriptionID.containsKey(SubscriptionId) ) {
                     List<Zuora__SubscriptionProductCharge__c> Charges = ChargesMappedBySubscriptionID.get(SubscriptionId);
                     Charges.add(RecurringCharge);
                     ChargesMappedBySubscriptionID.put(SubscriptionId, Charges);
                 } else {
                     List<Zuora__SubscriptionProductCharge__c> Charges = new List<Zuora__SubscriptionProductCharge__c> ();
                     Charges.add(RecurringCharge);
                     ChargesMappedBySubscriptionID.put(SubscriptionId, Charges);
                 }
             }

             for (String SubId : ChargesMappedBySubscriptionID.keySet()) {
                 List<Zuora__SubscriptionProductCharge__c> Charges = ChargesMappedBySubscriptionID.get(SubId);
                 Zuora__SubscriptionProductCharge__c NewestCharge = Charges[0];

                 for (Zuora__SubscriptionProductCharge__c Charge: Charges) {
                     if(Charge.CreatedDate > NewestCharge.CreatedDate) {
                         NewestCharge = Charge;
                     }
                 }
                 LatestChargeMappedBySubscriptionID.put(SubId, NewestCharge);
             }

             for (String SubId : LatestChargeMappedBySubscriptionID.keySet()) {
                 SubSummary sum;
                 
                 if (zuoraSubscriptionsMappedById.containsKey(subId)) {
                     Zuora__Subscription__c zSub = zuoraSubscriptionsMappedById.get(subId);
                     Zuora__SubscriptionProductCharge__c zLatestCharge = LatestChargeMappedBySubscriptionID.get(subId);

                     sum = SummarizeSubscription(zLatestCharge);
                     sum.ProductName = zLatestCharge.Zuora__ProductName__c;
                     
                     sum.ZuoraSubId = subId;
                     sum.ZuoraSubName = zSub.Name;
                     
                     if(zsub.Zuora__TermStartDate__c <= Date.today() && zsub.Zuora__TermEndDate__c >= Date.today()) {
                        sum.flags.termStatus = zTermStatus.Current;
                     }
                     else if (zSub.Zuora__TermEndDate__c < Date.today()) {
                        sum.flags.termStatus = zTermStatus.PastTerm;
                     }
                     else if (zSub.Zuora__TermStartDate__c > Date.Today()) {
                        sum.flags.termStatus = zTermStatus.FutureTerm;
                     }

                     if(zsub.Zuora__AutoRenew__c) {
                         AddFutureDetails(sum, zLatestCharge);
                         sum.NextRewnalDate = zSub.Zuora__NextRenewalDate__c;
                         sum.NextRewnalDateString = formatDate(zsub.Zuora__NextRenewalDate__c);
                     }
                     else {
                        //the AutoRenew flag is not set
                        //And if both autorenew flag and termStatus flag is not Current, this sub should be expired
                        //TODO: decide what to do for expired subscriptions. 

                     }
                     sum.IsCoreString = zSub.isCore__c;
                     if (zSub.isCore__c != null && !String.isBlank(zSub.isCore__c)) {
                        sum.flags.isCore = Boolean.valueOf(zSub.isCore__c);
                     }
                    
                     //sum.flags.isCore = Boolean.valueOf(zSub.isCore__c);
                     //sum.flags.isPrimary = sum.flags.isCore && zSub.Zuora__CustomerAccount__r.Subscription__r.Primary__c;

                     sum.flags.hasAutoRenew = zSub.Zuora__AutoRenew__c;
                     sum.flags.isActive = (zSub.Zuora__Status__c == 'Active');
                     //sum.flags.isPremium = (zSub.Zuora__ProductName__c != 'Promotions');
                     sum.flags.isSuspended = false;
                     sum.core_sub_status = zSub.Zuora__CustomerAccount__r.Subscription__r.Status__c;
                     sum.core_sub_id = zSub.Zuora__CustomerAccount__r.Subscription__r.Name;

                     
                     //These following lines of logic imported from another Salesforce controller seem to be wrong, and I'm merely keeping them here
                     //for reference. 
                     //sum.flags.hasAutoPay = zSub.Zuora__CustomerAccount__r.Zuora__AutoPay__c;
                     //sum.flags.isSuspended = (zSub.Zuora__CustomerAccount__r.Subscription__r.Status_Change_Reason__c == 'Suspended');
                     //sum.flags.isActive = (zSub.Zuora__CustomerAccount__r.Subscription__r.Status__c == 'Active');
                     //sum.core_sub_status = zSub.Zuora__CustomerAccount__r.Subscription__r.Status__c;
                     //sum.core_sub_id = zSub.Zuora__CustomerAccount__r.Subscription__r.Name;

                     SubSummaryMappedBySubId.put(subId, sum);                        

                 }
                 else {
                     throw new CustomException('Zuora Subscription Id ' + SubId + ' does not exist in zuoraSubscriptionsMappedById');
                 }
             }

 

             return SubSummaryMappedBySubId;
         } 
         else {
             return null;
         }
        
    }

    public List<SubSummary> getCancelledBundledSummaries() {
        if (this.bundledSummaries == null) {
            return null;
        }
        List<SubSummary> cancelledBundledSummaries  = new List<SubSummary>();
        for (SubSummary individualSubSummary: this.bundledSummaries) {
            if(!individualSubSummary.flags.isActive) {
                cancelledBundledSummaries.add(individualSubSummary);
            }
        }

        return cancelledBundledSummaries;
    }
    public List<SubSummary> getExpiredBundledSummaries() {
        if(this.bundledSummaries == null) {
            return null;
        }
        List<SubSummary> expiredBundledSummaries = new List<SubSummary>();
        for (SubSummary individualSubSummary: this.bundledSummaries) {
            if(individualSubSummary.flags.termStatus == zTermStatus.PastTerm && !individualSubSummary.flags.hasAutoRenew && individualSubSummary.flags.isActive) {
                individualSubSummary.flags.isActive = false;
                expiredBundledSummaries.add(individualSubSummary);
            }
        } 

        return expiredBundledSummaries;
    }

    public List<SubSummary> getFutureBundledSummaries() {
        if(this.bundledSummaries == null) {
            return null;
        }
        List<SubSummary> futureBundledSummaries = new List<SubSummary>();
        for (SubSummary individualSubSummary: this.bundledSummaries) {
            if(individualSubSummary.flags.termStatus == zTermStatus.FutureTerm && individualSubSummary.flags.isActive) {
                futureBundledSummaries.add(individualSubSummary);
            }
        }
        return futureBundledSummaries;
    }

    public List<SubSummary> getBundledCoreSummaries() {
        if(this.bundledSummaries == null) {
            return null;
        }
        List <SubSummary> bundledCoreSummaries = new List<SubSummary>();
        for (SubSummary individualSubSummary: this.bundledSummaries) {
            if(individualSubSummary.flags.isCore && individualSubSummary.flags.termStatus == zTermStatus.Current && individualSubSummary.flags.isActive) {
                bundledCoreSummaries.add(individualSubSummary);
            }
        }
        return bundledCoreSummaries;
    }

    public List<SubSummary> getBundledPremiumSummaries() {
        if(this.bundledSummaries == null) {
            return null;
        }
        List <SubSummary> bundledPremiumSummaries = new List<SubSummary>();
        for (SubSummary individualSubSummary: this.bundledSummaries) {
            if(!individualSubSummary.flags.isCore && individualSubSummary.flags.termStatus == zTermStatus.Current && individualSubSummary.flags.isActive) {
                bundledPremiumSummaries.add(individualSubSummary);
            }
        }
        return bundledPremiumSummaries;
    }

    public List<SubSummary> bundledExpiredSummaries() {
        return null;
    }

    //Bundle is determined by the content of Rate Plan Description. 
    //For example, the following 3 items belong to a single bundle: 
    // 1. #bundlea RealPing Montly
    // 2. #bundlea Montly XactSite Select
    // 3. #bundlea Monthly 
    public List<SubSummary> getBundledSummaries() {
        //If a bundle does not exist, the List <String> will only have one element. 
        //If a bundle does exist, the List <String> will have the subscriptions Ids that belong under the bundle 
        Map<String, List<String> > existingBundles = new Map <String, List<String> >();
        List < SubSummary > bundledSums = new List<SubSummary> ();

        for (SubSummary individualSubSummary: this.nonBundledSummariesMappedBySubId.values()) {
            //System.Debug('RatePlanDescription: ' + individualSubSummary.RatePlanDescription);
            if (individualSubSummary.RatePlanDescription != null && individualSubSummary.RatePlanDescription.startsWith('#bundle')) { 
                String [] subStrings = individualSubSummary.RatePlanDescription.split(' ', 3);
                String bundleKey = subStrings[0];
                if (existingBundles.containsKey(bundleKey)) {
                    List<String> bundle = existingBundles.get(bundleKey);
                    bundle.add(individualSubSummary.ZuoraSubId);
                    existingBundles.put(bundleKey, bundle);
                } else {
                    List<String> bundle  = new List<String>();
                    bundle.add(individualSubSummary.ZuoraSubId);
                    existingBundles.put(bundleKey, bundle);
                }
            } else {
                //Not in a bundle 
                bundledSums.add(individualSubSummary);
            }
        }

        
        for (String bundleKey: existingBundles.keySet()) {
            List<String> subscriptionIdsInBundle = existingBundles.get(bundleKey);
            SubSummary bundleSummary = new SubSummary();
            bundleSummary.Price = (Decimal) (0.0);
            bundleSummary.future_rate = (Decimal) (0.0);
            
            for (String subscriptionId : subscriptionIdsInBundle) {
                SubSummary subSummary = nonBundledSummariesMappedBySubId.get(subscriptionId);
                bundleSummary.ZuoraSubId = subSummary.ZuoraSubId;
                bundleSummary.ZuoraSubName = 'Bundle';
                bundleSummary.RatePlanName = 'Bundle'; 
                bundleSummary.ProductName = 'Bundle';
                bundleSummary.Price = bundleSummary.Price + subSummary.Price;
                bundleSummary.RatePlanDescription = bundleKey;
                bundleSummary.StartDate = subSummary.StartDate;
                bundleSummary.StartDateString = subSummary.StartDateString;
                bundleSummary.EndDate = subSummary.EndDate;
                bundleSummary.EndDateString = subSummary.EndDateString;
                bundleSummary.NextRewnalDate = subSummary.NextRewnalDate;
                bundleSummary.NextRewnalDateString = subSummary.NextRewnalDateString;
                bundleSummary.NextBillDate = subSummary.NextBillDate;
                bundleSummary.NextBillDateString = subSummary.NextBillDateString;
                bundleSummary.future_type = subSummary.future_type;
                bundleSummary.future_rate = bundleSummary.future_rate + subSummary.future_rate;
                bundleSummary.future_renewal_date = subSummary.future_renewal_date;
                bundleSummary.core_sub_status = subSummary.core_sub_status;
                bundleSummary.core_sub_id = subSummary.core_sub_id;
                bundleSummary.NextRewnalDate = subSummary.NextRewnalDate;

                //bundleSummary.flags.termStatus = subSummary.flags.termStatus;
                bundleSummary.flags.hasAutoRenew = subSummary.flags.hasAutoRenew;
                bundleSummary.flags.isSuspended = subSummary.flags.isSuspended;
                bundleSummary.flags.isActive = subSummary.flags.isActive;

            }
            bundledSums.add(bundleSummary);
        }
        
        for (SubSummary subSum: bundledSums) {
            System.Debug('bundled RatePlanDescription: ' + subSum.RatePlanDescription);
        }
        return bundledSums;
    }
    
    //A map of the Zuora__Subscription__c by the Zuora__Subscription__c's ID field. 
    public Map<String, Zuora__Subscription__c> getZuoraSubscriptionsMappedById {
        get {
            List<Zuora__Subscription__c> zsubs = 
                [select Id, Name, IsCore__c, Zuora__CustomerAccount__c, Zuora__ContractEffectiveDate__c, Zuora__External_Id__c, Zuora__AutoRenew__c, Zuora__InitialTerm__c, 
                            Zuora__RenewalTerm__c, Zuora__ServiceActivationDate__c, Zuora__Status__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                            Zuora__NextChargeDate__c, Zuora__NextRenewalDate__c, Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__MRR__c, Zuora__Zuora_Id__c, 
                            Zuora__CustomerAccount__r.Subscription__c, Zuora__CustomerAccount__r.Subscription__r.Primary__c, Zuora__CustomerAccount__r.Zuora__AutoPay__c,
                            Zuora__CustomerAccount__r.Subscription__r.Status_Change_Reason__c, Zuora__CustomerAccount__r.Subscription__r.Status__c,
                            Zuora__CustomerAccount__r.Subscription__r.Name
                        from 
                            Zuora__Subscription__c where Zuora__CustomerAccount__c in :zuora_accounts order by Zuora__SubscriptionStartDate__c];

            for (Zuora__Subscription__c zsub: zsubs) {
                System.Debug('Name: ' + zsub.Name + ' Initial Term: ' + zsub.Zuora__InitialTerm__c + ' MRR__c: ' + zsub.Zuora__MRR__c  + ' Status: ' + zsub.Zuora__Status__c + ' StartDate: ' + formatDate(zsub.Zuora__SubscriptionStartDate__c));
            }

            Map<String, Zuora__Subscription__c> SubsMappedById = new Map<String, Zuora__Subscription__c> ();
            for (Zuora__Subscription__c zsub:zsubs) {
                SubsMappedById.put(zsub.Id, zsub);
            }
            return SubsMappedById;
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
    
    public List<Zuora__Payment__c> PaymentList {
        get {
            List<Zuora__Payment__c> zpay = 
                [select Id, 
                        Name, Zuora__BillingAccount__r.SubscriptionID__c, Zuora__Amount__c, Zuora__PaymentMethod__c, 
                        Zuora__Status__c, Zuora__SubmittedOn__c
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
        SubSummary sum = new SubSummary();
        sum.RatePlanName = chg.Zuora__RatePlanName__c;
        sum.RatePlanDescription = chg.Zuora__RatePlanDescription__c;
        sum.Price = (Decimal) chg.Zuora__Price__c;
        sum.StartDate = (Date) chg.Zuora__EffectiveStartDate__c;
        sum.StartDateString = formatDate(chg.Zuora__EffectiveStartDate__c);
        sum.EndDate = (Date) chg.Term_End_Date__c;
        sum.EndDateString = formatDate(chg.Term_End_Date__c);
        if (chg.Next_Charge_Date__c != null) {
            sum.NextBillDate = (Date) chg.Next_Charge_Date__c;
            sum.NextBillDateString = formatDate(chg.Next_Charge_Date__c);
        }
        return sum;       
    }
    
    private void AddFutureDetails(SubSummary sum, Zuora__SubscriptionProductCharge__c chg) {
        sum.future_type = chg.Zuora__RatePlanName__c;
        sum.future_rate = (Decimal)(chg.Zuora__Price__c);
    }
    private List<Zuora__SubscriptionProductCharge__c> getRecurringProductChargeList()
    {
        List<Zuora__SubscriptionProductCharge__c> RecurringProductChargeList = [SELECT CreatedById, CreatedDate, IsDeleted, Id, MRIS_Subscription_Id__c, Name, 
                Next_Charge_Date__c, Term_End_Date__c, Zuora__Account__c, Zuora__BillingPeriodStartDay__c, Zuora__BillingPeriod__c, Zuora__ChargeNumber__c, Zuora__Description__c, 
                Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c, Zuora__ExtendedAmount__c, Zuora__External_Id__c, Zuora__Model__c, Zuora__MonthlyRecurringRevenue__c, 
                Zuora__Price__c, Zuora__ProductDescription__c, Zuora__ProductEffectiveEndDate__c, Zuora__ProductName__c, Zuora__ProductSKU__c, Zuora__Quantity__c, 
                Zuora__RatePlanDescription__c, Zuora__RatePlanEffectiveEndDate__c, Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__TotalContractValue__c, 
                Zuora__Type__c, Zuora__Zuora_Id__c
            FROM Zuora__SubscriptionProductCharge__c 
            WHERE Zuora__Account__c = :glue.Id and Zuora__Type__c = 'Recurring' and Zuora__ProductName__c != 'Promotions'];
        return RecurringProductChargeList;
    }
    private Map<Id,Zuora__SubscriptionProductCharge__c> getSubProductChargeMap() {
        Map<Id,Zuora__SubscriptionProductCharge__c> zsub_charges = new Map<Id,Zuora__SubscriptionProductCharge__c>();
        if (glue == null)
            return zsub_charges;
            
        List<Zuora__SubscriptionProductCharge__c> charges = [select Id, Name, Zuora__Subscription__c, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Price__c, Next_Charge_Date__c, Zuora__EffectiveStartDate__c, Term_End_Date__c from Zuora__SubscriptionProductCharge__c where Zuora__Account__c = :glue.Id and Zuora__Type__c = 'Recurring'];
        for(Zuora__SubscriptionProductCharge__c chg : charges) {
            zsub_charges.put(chg.Zuora__Subscription__c,chg);
        }
        return zsub_charges;
    }
    
    private String formatDate(DateTime dt) {
        return dt.format('MM/dd/yyyy', 'GMT');
    }
    
    public void onDemandSync(){
        
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncZuoraObjectIdSet = zAccountIds;
        List<Zuora.SyncResult> syncResults = syncManager.sendRequest();
        
        for(Zuora.SyncResult syncResult : syncResults){
            if(syncResult.success)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The sync request has been submitted successfully.Please allow a few minutes for the request to be processed.'));
        }
        
        System.debug( 'Sync results = ' + syncResults );  
        
    }
    
    public void subscriptionOnDemandSync(String subId) {
        set<String> zAccountsId = new Set<String>();
        set<Id> billingAccountIds = new Set<Id>();
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(syncResult)));
            }
        }
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No related data found with this subscription id.'));             
    }
    
    public class SubSummary implements Comparable {

        public String ZuoraSubId { get; set; }
        public String ZuoraSubName { get; set; }
        public String RatePlanName { get; set; }
        public String ProductName { get; set; }
        public Decimal Price { get; set; }

        public String RatePlanDescription { get; set; }
        //public DateTime CreatedDate { get; set; }
        public Date StartDate { get; set; }
        public String StartDateString { get; set; }
        public Date EndDate { get; set; }
        public String EndDateString { get; set; }
        public Date NextRewnalDate { get; set; }
        public String NextRewnalDateString { get; set; }
        //public DateTime LastBillDate {get; set; }
        //public String last_bill_date { get; set; }
        public Date NextBillDate { get; set; }
        public String NextBillDateString { get; set; }
        //public Date LastPaymentDate { get; set; }
        //public String last_payment_date { get; set; }
        //public String current_balance { get; set; }
        public String future_type { get; set; }
        public Decimal future_rate { get; set; }
        public String future_renewal_date { get; set; }
        public String core_sub_status { get; set; }
        public String core_sub_id { get; set; }
        public String IsCoreString { get; set; }
        
        public SubFlags flags { get; set; }
        
        public SubSummary() {
            flags = new SubFlags();
        }
        
        public Integer compareTo(object compareTo) {
            SubSummary other = (SubSummary)compareTo;
            if(this.StartDate == other.StartDate) return 0;
            if(this.StartDate <  other.StartDate) return 1;
            return -1;
            
        }
        
    }
    
    public class SubFlags {
        
        public zTermStatus termStatus { get; set; }
        public Boolean hasAutoRenew { get; set; }
        public Boolean isSuspended { get; set; }
        public Boolean isCore { get; set; }
        //public Boolean isPrimary { get; set; }
        public Boolean isActive { get; set; }
		public Boolean isPremium { get; set; }
        
        public SubFlags() {
            termStatus = zTermStatus.UNDEF;
            hasAutoRenew = false;
            isSuspended = false;
            isCore = false;
        //    isPrimary = false;
            isActive = false;
            isPremium = false;
        }
    }

    public Class CustomException extends Exception {}
}