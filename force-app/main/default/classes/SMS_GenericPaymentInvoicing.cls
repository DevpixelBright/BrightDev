public class SMS_GenericPaymentInvoicing {
    private enum zOperation { zSUBSCRIBE, zCREATE, zUPDATE, zAMEND, zDELETE, zGENERATE, zQUERY }
    
    public InvoiceData Invoice { get; set; }

    public Boolean hasDraftInvoices { get; private set; }
    
    //private Zuora.zApi zApiInstance;
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    
    private String DiscountProductId;
    private String LastSubscribedProductId;
    private String LastGeneratedInvoiceId;

    private Boolean testBundles { get { return false; } }
    
    public SMS_GenericPaymentInvoicing(InputData data) {
        //zApiInstance = new Zuora.zApi();  
        //zLoginResult = zApiInstance.zlogin();
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin(); 
        
        validateInputData(data);
        constructInvoiceStructure(data);

        generateBaselineInvoice();
        
        populateDiscountProductId();
        populateExistingBalance();
        populateConflictingSubscriptions();
        //populatePremiumSubscriptionReinstatementCandidates();
        populateExistingInvoices();
        checkForDraftInvoices();
    }
    
    public void previewInvoice() {
        try {
            this.Invoice.Preview = true;

            for (Bundle b : this.Invoice.Additions)
                for (Product p : b.Contents)
                    p.Preview.clear();

            for (Bundle b : this.Invoice.Removals)
                for (Product p : b.Contents)
                    p.Preview.clear();
            
            List<Zuora.zApi.SubscribeRequest> additions = getSubscribeRequests();

            if (additions.size() != 0) {
                List<Zuora.zApi.SubscribeResult> results = callZuora(zOperation.zSUBSCRIBE, additions);

                for (Zuora.zApi.SubscribeResult result: results) {
                    if (!result.Success) throw new CustomException('Subscribe Failed');
                   
                    if (result.InvoiceDatas == null) continue;
                    
                    for (Zuora.zObject invoiceData : result.InvoiceDatas) {
                       List<Object> source = invoiceData.getArrayValue('InvoiceItem');

                       importInvoiceCharges(source, this.Invoice.Additions);
                    }
                }       
            }
            
            List<List<Zuora.zApi.AmendRequest>> amendments = getAmendRequests();

            for (List<Zuora.zApi.AmendRequest> request : amendments) {
                String type = (String) request.get(0).Amendments.get(0).getValue('Type');

                Zuora.zApi.AmendResult result = callZuora(zOperation.zAMEND, request);

                if (!result.Success) {
                    log('REQUEST: ' + request);
                    log('RESULT:' + result);
                    
                    throw new CustomException('Amendment Failed');
                }

                if (type == 'TermsAndConditions') continue;
                
                if (result.InvoiceDatas == null) continue;
                
                for (Zuora.zObject invoiceData : result.InvoiceDatas) {
                   List<Object> source = invoiceData.getArrayValue('InvoiceItem');
                                  
                   importInvoiceCharges(source, type == 'NewProduct' ? this.Invoice.Additions : this.Invoice.Removals);
                }
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString())); 
        }
    }
    
    public void commitInvoice() {
        try {
            this.Invoice.Preview = false;

            List<Zuora.zApi.SubscribeRequest> additions = getSubscribeRequests();
            
            if (additions.size() != 0) {
                List<Zuora.zApi.SubscribeResult> subscribeResults = callZuora(zOperation.zSUBSCRIBE, additions);
                
                for (Zuora.zApi.SubscribeResult result: subscribeResults)
                   if (!result.Success) throw new CustomException('Subscribe Failed');
            }
            
            List<List<Zuora.zApi.AmendRequest>> amendments = getAmendRequests();

            for (List<Zuora.zApi.AmendRequest> request : amendments) {
                Zuora.zApi.AmendResult result = callZuora(zOperation.zAMEND, request);
                
                if (!result.Success) {
                    log('REQUEST: ' + request);
                    log('RESULT:' + result);
                    
                    throw new CustomException('Amendment Failed');
                }
            }      

            List<String> deletions = getDeleteRequests();
            
            if (deletions.size() == 0) return;
            
            List<Zuora.zApi.DeleteResult> deleteResults = callZuora(zOperation.zDELETE, deletions);
            
            for (Zuora.zApi.DeleteResult result: deleteResults)
               if (!result.Success) throw new CustomException('Delete Failed');
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()  + e.getStackTraceString())); 
        }
    }
    
    public void generateBaselineInvoice() {
        generateBaselineInvoice(this.Invoice.EffectiveDate);
    }
    
    public Boolean confirmBaselineInvoice() {
        if (this.LastGeneratedInvoiceId == null) return true;
        
        List<Zuora.zObject> zInvoices = callZuora(zOperation.zQUERY, 'SELECT Id FROM Invoice WHERE Id = \'' + this.LastGeneratedInvoiceId + '\' AND Status = \'Posted\'');
        
        return zInvoices.size() != 0;
    }
    
    private void validateInputData(InputData data) {
        Boolean hasCore = false;
        Boolean hasPremium = false;
        
        Boolean isNewCoreAllowed = newCoreSubscriptionAllowed(data.AccountId);
        
        for (InputItem i : data.Contents)
            if (i.IsCore) {
                hasCore = true;
                
                i.IsNew = isNewCoreAllowed;
            }
            else {
                hasPremium = true;
            }
                
        if (hasCore && hasPremium)
            throw new CustomException('Invoicing: Input data contains both core and premium subscription changes. Only one type can be included');
    }
    
    private Boolean newCoreSubscriptionAllowed(String accountId) {
        /* Retrieve all core Subscriptions of Account */
        String query = 'SELECT Id FROM Subscription WHERE AccountId = \'' + accountId + '\' AND IsCore__c = true';
       
        List<Zuora.zObject> results = callZuora(zOperation.zQUERY, query);
        
        return results.size() == 0;
    }
    
    private void constructInvoiceStructure(InputData data) {
        this.Invoice = new InvoiceData();
        
        this.Invoice.OrderId = data.OrderId;
        this.Invoice.AccountId = data.AccountId;
        this.Invoice.BypassPayment = data.BypassPayment;
        this.Invoice.ExistingBalance = 0;
        this.Invoice.AmountPaid = 0;
        this.Invoice.Additions = new List<Bundle>();
        this.Invoice.Removals = new List<Bundle>();
        this.Invoice.AutoRenews = new Set<String>();
        this.Invoice.EffectiveDate = DateTime.now().format('yyyy-MM-dd','PST');
        this.Invoice.Preview = true;

        Boolean changed = true;
        
        /* 
        Sort all the input items so all the pure discount entries are at the end. This ensures that the products that the discounts are supposed to be applied to exist.
        
        While this sorting algorithm might be inefficient, 1) Apex does not offer a native solution to sort based on field and 2) the algorithm is simple.
        */
        while (changed) {
            changed = false;
            
            for (Integer i = 0; i < data.Contents.size(); i++) {
                if (i + 1 == data.Contents.size()) break;
                
                Boolean a = data.Contents.get(i).IsDiscountOnly;
                Boolean b = data.Contents.get(i + 1).IsDiscountOnly;
                
                if (a && !b) {
                    data.Contents.add(i, data.Contents.remove(i + 1));
                    changed = true;
                }
            }
        }
                
        // Build up the initial structure for the invoice object. Only bundle, product, and product rate plan levels are filled in. Some information will still be missing and need to be filled at a later time
        Map<String, String> productsAdded = new Map<String, String>();
        
        for (InputItem i : data.Contents) {
            Bundle b;           
            String bId = String.isNotBlank(i.BundleId) ? i.BundleId : 'PROD-' + i.ProductId;
            
            for (Bundle x : this.Invoice.Additions) {               
                if (x.Id != bId) continue;
                
                b = x;
                
                break;
            }
            
            if (b == null) {
                b = new Bundle();
                
                b.Id = bId;
                b.Name = i.BundleName;
                b.IsBundle = String.isNotBlank(i.BundleId) || testBundles;
                
                b.Contents = new List<Product>();
                
                this.Invoice.Additions.add(b);
            }
            
            Product p;
            
            if (!i.IsDiscountOnly && productsAdded.containsKey(i.ProductId))
                throw new CustomException('Duplicated Products Detected');
            else if (i.IsDiscountOnly && !productsAdded.containsKey(i.ProductId))
                throw new CustomException('Orphan Discount Detected');
            else
                productsAdded.put(i.ProductId, i.ProductName);

            for (Product x : b.Contents) {
                if (x.Id != i.ProductId) continue;
                
                p = x;
                
                break;
            }

            if (p == null) {
                p = new Product();
                
                p.Id = i.ProductId;
                p.Name = i.ProductName;
                p.TermDuration = i.TermDuration;
                p.IsCore = i.IsCore;
                p.IsNew = i.IsNew;
                
                p.ContractEffectiveDate = i.ContractEffectiveDate;
                p.ServiceActivationDate = i.ServiceActivationDate;
                p.InitialTerm = i.InitialTerm;
                p.RenewalTerm = i.RenewalTerm;
                
                p.Discounts = new List<ProductRatePlan>();
                p.Preview = new List<ProductRatePlanCharge>();
                
                b.Contents.add(p);
            }

            if (String.isNotBlank(i.OneTimeProductRatePlanId)) {
                p.OneTime = new ProductRatePlan();
                p.OneTime.Id = i.OneTimeProductRatePlanId;
                p.OneTime.Name = i.OneTimeProductRatePlanName;
            }

            if (String.isNotBlank(i.RecurringProductRatePlanId)) {
                p.Recurring = new ProductRatePlan();
                p.Recurring.Id = i.RecurringProductRatePlanId;
                p.Recurring.Name = i.RecurringProductRatePlanName;
            }

            if (String.isNotBlank(i.DiscountProductRatePlanId)) {
                ProductRatePlan r = new ProductRatePlan();
                r.Id = i.DiscountProductRatePlanId;
                r.Name = i.DiscountProductRatePlanName;
                
                p.Discounts.add(r);
            }
        }
    }
    
    private void generateBaselineInvoice(String invoiceDate) {
        Zuora.zObject invoice = new Zuora.zObject('Invoice');

        invoice.setValue('AccountId', this.Invoice.AccountId);
        invoice.setValue('InvoiceDate', invoiceDate);
        invoice.setValue('TargetDate', invoiceDate);
        
        Zuora.zApi.SaveResult result = callZuora(zOperation.zGENERATE, invoice);

        if (result == null) {
            this.LastGeneratedInvoiceId = null;
            
            return;
        }
        else
            this.LastGeneratedInvoiceId = result.Id;
        
        invoice = new Zuora.zObject('Invoice');

        invoice.setValue('Id', result.Id);
        invoice.setValue('Status', 'Posted');

        result = callZuora(zOperation.zUPDATE, invoice);
    }
    
    private void populateDiscountProductId() {
        List<Zuora.zObject> discount = callZuora(zOperation.zQUERY, 'SELECT Id FROM Product WHERE Name = \'' + Label.MRIS_Zuora_Discount_Product_Name + '\'');
        
        DiscountProductId = (String) discount[0].getValue('Id');
    }

    private void populateExistingBalance() {
        List<Zuora.zObject> account = callZuora(zOperation.zQUERY, 'SELECT Balance FROM Account WHERE Id = \'' + this.Invoice.AccountId + '\'');
        
        this.Invoice.ExistingBalance = (Decimal) account[0].getValue('Balance');
    }
    
    /*
    This operation locates all the subscriptions that need to be removed in order for the new product rate plans to be added. The business rule here is "only one instance of a product per account"; in other words, no account should have two subscriptions to the same product.

    Zuora does not make finding conflicts easy due to lack of join operations and the use of parenthesis for the WHERE clause for their querying language. So, we need the perform the following operations for each subscription:
    
    1. Find the rate plans it contains. Note that we only care about recurring rate plans. There's no reason to use one-time charges; in fact, that would cause a lot of problems with fines and fees down the road. In order to find out whether a rate plan contains a recurring charge, we need to drill down to the rate plan charge level and check to see if at least one of the charges is of type "Recurring"
    2. For each rate plan found, find the corresponding product rate plan
    3. Using the product rate plan, find the product it is a part of
    4. If this product matches one of the new products we are trying to add, we have a conflict. So, back trace all the way to the subscription and record its ID as a removal
    
    This is the general concept here. The actual implementation is different to increase the algorithm's efficiency. However, keeping the general concept in mind while going through the code will make the code much easier to understand.
    */
    private void populateConflictingSubscriptions() {
        if (this.Invoice.Additions.size() == 0) return;

        String query;
        Boolean first;
        List<Zuora.zObject> results;
        List<Zuora.zObject> rawResults;
        
        /* Retrieve all active AND in-term Subscriptions of Account */
        query = 'SELECT Id, ServiceActivationDate, TermEndDate, IsCore__c FROM Subscription WHERE AccountId = \'' + this.Invoice.AccountId + '\' AND Status = \'Active\' AND TermEndDate >= \'' + DateTime.now().format('yyyy-MM-dd', 'PST') + '\'';
       
        results = callZuora(zOperation.zQUERY, query);
        
        if (results.size() == 0) return;

        Map<String, Zuora.zObject> subscriptions = new Map<String, Zuora.zObject>();

        for (Zuora.zObject result : results)
            subscriptions.put((String) result.getValue('Id'), result);
            
        /* Get the mapping between ProductRatePlanId and SubscriptionId through RatePlans */
        query = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        
        first = true;
        
        for (String key : subscriptions.keySet()) {
            if (first)
                first = false;
            else
                query += ' OR ';
                
            query += 'SubscriptionId = \'' + subscriptions.get(key).getValue('Id') + '\'';
        }

        results = callZuora(zOperation.zQUERY, query);

        if (results.size() == 0) return;

        Map<String, Zuora.zObject> ratePlans = new Map<String, Zuora.zObject>();

        for (Zuora.zObject result : results)
            ratePlans.put((String) result.getValue('Id'), result);

        /* Remove the RatePlans that are either discounts or one-time charges */
        query = 'SELECT RatePlanId, ApplyDiscountTo, ChargeType FROM RatePlanCharge WHERE ';
        
        first = true;
        
        for (String key : ratePlans.keySet()) {
            if (first)
                first = false;
            else
                query += ' OR ';
                
            query += 'RatePlanId = \'' + ratePlans.get(key).getValue('Id') + '\'';
        }
        
        results.clear();
        rawResults = callZuora(zOperation.zQUERY, query);
        
        for (Zuora.zObject result : rawResults) {
            if (result.getValue('ApplyDiscountTo') == null && result.getValue('ChargeType') == 'Recurring')
                results.add(result);
        }
        
        if (results.size() == 0) return;

        Set<String> relevantRatePlanIds = new Set<String>();

        for (Zuora.zObject result : results)
            relevantRatePlanIds.add((String) result.getValue('RatePlanId'));

        for (String key : ratePlans.keySet()) {
            if (!relevantRatePlanIds.contains(key))
                ratePlans.remove(key);
        }
        
        /* Remove the RatePlans that are not in conflict with the new products */
        query = 'SELECT Id, ProductId FROM ProductRatePlan WHERE ';

        first = true;
        
        for (String key : ratePlans.keySet()) {
            if (first)
                first = false;
            else
                query += ' OR ';
                
            query += 'Id = \'' + ratePlans.get(key).getValue('ProductRatePlanId') + '\'';
        }

        results.clear();
        rawResults = callZuora(zOperation.zQUERY, query);

        Set<String> relevantProductIds = new Set<String>();
        
        for (Bundle bundle : this.Invoice.Additions) {
            for (Product product : bundle.Contents)
                relevantProductIds.add(product.Id);
        }
        
        for (Zuora.zObject result : rawResults) {
            if (relevantProductIds.contains((String) result.getValue('ProductId')))
                results.add(result);
        }   

        if (results.size() == 0) return;

        Map<String, Zuora.zObject> productRatePlans = new Map<String, Zuora.zObject>();

        for (Zuora.zObject result : results)
            productRatePlans.put((String) result.getValue('Id'), result);

        for (String key : ratePlans.keySet()) {
            if (!productRatePlans.containsKey((String) ratePlans.get(key).getValue('ProductRatePlanId')))
                ratePlans.remove(key);
        }

        /* At this point, all the rate plans remaining are conflicting ones */
        Set<String> conflictingSubscriptions = new Set<String>();

        for (String key : ratePlans.keySet())
            conflictingSubscriptions.add((String) ratePlans.get(key).getValue('SubscriptionId'));
        
        for (String key : subscriptions.keySet()) {
            if (!conflictingSubscriptions.contains((String) subscriptions.get(key).getValue('Id')))
                subscriptions.remove(key);
        }
        
        for (String subscriptionId : subscriptions.keySet()) {
            Zuora.zObject subscription = subscriptions.get(subscriptionId);
            String recurringRatePlanId;
            
            for (Zuora.zObject ratePlan : ratePlans.values()) {
                if (ratePlan.getValue('SubscriptionId') != subscriptionId)
                    continue;
                else {
                    recurringRatePlanId = (String) ratePlan.getValue('ProductRatePlanId');
                    
                    break;
                }
            }

            if ((Date) subscription.getValue('ServiceActivationDate') <= DateTime.now().date()) {
                // Test to see if this subscription actually contains the same thing as one of our additions. If so, use auto-renew instead
                Boolean useAutoRenew = false;
                
                for (Bundle bundle : this.Invoice.Additions) {
                    for (Product product : bundle.Contents) {
                        if (product.Recurring == null) continue;
                        if (product.Recurring.Id != recurringRatePlanId) continue;
                        
                        product.SubscriptionId = subscriptionId;
                        useAutoRenew = true;

                        this.Invoice.AutoRenews.add(subscriptionId);
                        
                        break;
                    }
                    
                    if (useAutoRenew) break;
                }
                
                if (useAutoRenew) continue;
            }
            
            // Since we cannot use auto-renew, we have to mark this as a removal
            Bundle b = new Bundle();
            b.Contents = new List<Product>();
            
            Product p = new Product();
            p.Id = (String) productRatePlans.get(recurringRatePlanId).getValue('ProductId');
            p.Preview = new List<ProductRatePlanCharge>();

            p.EffectiveDate = ((DateTime) subscription.getValue('ServiceActivationDate')).format('yyyy-MM-dd', 'PST');
            p.TermEndDate = ((DateTime) subscription.getValue('TermEndDate')).format('yyyy-MM-dd', 'PST');
            p.IsCore = Boolean.valueOf(subscription.getValue('IsCore__c'));
            p.SubscriptionId = subscriptionId;

            for (String ratePlanId : ratePlans.keySet()) {
                Zuora.zObject ratePlan = ratePlans.get(ratePlanId);
                
                if ((String) ratePlan.getValue('SubscriptionId') == subscriptionId) {
                    p.Name = (String) ratePlan.getValue('Name');
                    
                    break;
                }
            }

            b.Contents.add(p);
            
            this.Invoice.Removals.add(b);
        }
    }

    /*
    This operation is only relevant when trying to reinstate a core product. The business rule here is "when reinstating a core product, any premium product that is still in-term, i.e., has not expired, shall be reinstated as well."
    
    When we suspend a core product, we do not cancel the premium products, since users have already paid for them and business rules disallow refunds in this case. We simply turn auto-renew on the subscription to false; so when the current term ends, the product ends with it and will no longer be charged for.
    
    Therefore, to "reinstate" a premium product that has not expired, all we have to do is turn auto-renew back on.
    */
    private void populatePremiumSubscriptionReinstatementCandidates() {
        if (this.Invoice.Additions.size() == 0) return;

        /* Retrieve all active premium Subscriptions of Account */
        String query = 'SELECT Id FROM Subscription WHERE AccountId = \'' + this.Invoice.AccountId + '\' AND Status = \'Active\' AND IsCore__c = false AND AutoRenew = false AND ServiceActivationDate <= ' + DateTime.now().addDays(1).format('yyyy-MM-dd');
       
        List<Zuora.zObject> results = callZuora(zOperation.zQUERY, query);
        
        if (results.size() == 0) return;

        for (Zuora.zObject result : results)
            this.Invoice.AutoRenews.add((String) result.getValue('Id'));
        
        /*
        This should never ever happen, since mixing core and premium subscriptions when calling Invoicing is strictly prohibited, i.e., an exception would be thrown during input data validation. What this means is that (1) the only time we would deal with auto-renews is when we are trying to reinstate a core product, and (2) there should not be anything for removal, since we do not cancel existing core subscriptions
        */
        for (Bundle b : this.Invoice.Removals) {
            for (Product p : b.Contents)
                this.Invoice.AutoRenews.remove(p.SubscriptionId);
        }
    }
    
    private void populateExistingInvoices() {
        this.Invoice.ExistingInvoices = new List<ExistingInvoice>();
        
        if (this.Invoice.Additions.size() != 0) return;
        
        String query;
        Boolean first;
        Boolean changed;
        List<Zuora.zObject> results;

        query = 'SELECT Id, InvoiceNumber, PostedDate, Balance, TaxAmount FROM Invoice WHERE AccountId = \'' + this.Invoice.AccountId + '\' AND Status = \'Posted\' AND Balance > 0 AND DueDate <= ' + DateTime.now().addDays(1).format('yyyy-MM-dd');
       
        results = callZuora(zOperation.zQUERY, query);
        
        if (results.size() == 0) return;

        changed = true;
        
        /* 
        Sort all the invoices by their posted date.
        
        While this sorting algorithm might be inefficient, 1) Apex does not offer a native solution to sort based on field, 2) the maximum
        expected number of items in this list is low, and 3) the algorithm is simple.
        */
        while (changed) {
            changed = false;
            
            for (Integer i = 0; i < results.size(); i++) {
                if (i + 1 == results.size()) break;
                
                DateTime a = (DateTime) ((Zuora.zObject) results.get(i)).getValue('PostedDate');
                DateTime b = (DateTime) ((Zuora.zObject) results.get(i + 1)).getValue('PostedDate');
                
                if (a < b) {
                    results.add(i, results.remove(i + 1));
                    changed = true;
                }
            }
        }
        
        query = 'SELECT InvoiceId, ChargeAmount, ChargeDescription, ChargeName, ProductName, ServiceEndDate FROM InvoiceItem WHERE ';
        
        first = true;
        
        for (Zuora.zObject result : results) {
            ExistingInvoice ei = new ExistingInvoice();
            
            ei.Id = (String) result.getValue('Id');
            ei.InvoiceNumber = (String) result.getValue('InvoiceNumber');
            ei.PostedDate = ((DateTime) result.getValue('PostedDate')).format('MM/dd/yyyy');
            ei.Balance = (Decimal) result.getValue('Balance');
            ei.Tax = (Decimal) result.getValue('TaxAmount');
            ei.Items = new List<ExistingInvoiceItem>();
            
            this.Invoice.ExistingInvoices.add(ei);

            if (first)
                first = false;
            else
                query += ' OR ';
                
            query += 'InvoiceId = \'' + ei.Id + '\'';
        }

        results = callZuora(zOperation.zQUERY, query);

        changed = true;
        
        /* 
        Sort all the invoice items by their service end date. This is to prioritize one-time fees over recurring fees. 
        Instead of comparing charge names, which can easily change, the service end date for one-time fees is the same as 
        the service start date. This guarantees that the end date for one-time will always be earlier than the end date 
        for recurring.
        
        While this sorting algorithm might be inefficient, 1) Apex does not offer a native solution to sort based on field, 2) the maximum
        expected number of items in this list is small, and 3) the algorithm is simple.
        */
        while (changed) {
            changed = false;
            
            for (Integer i = 0; i < results.size(); i++) {
                if (i + 1 == results.size()) break;
                
                Date a = (Date) ((Zuora.zObject) results.get(i)).getValue('ServiceEndDate');
                Date b = (Date) ((Zuora.zObject) results.get(i + 1)).getValue('ServiceEndDate');
                
                if (a > b) {
                    results.add(i, results.remove(i + 1));
                    changed = true;
                }
            }
        }
        
        for (Zuora.zObject result : results) {
            ExistingInvoiceItem eii = new ExistingInvoiceItem();
            
            String description = (String) result.getValue('ChargeDescription');
            
            if (String.isBlank(description))
                description = result.getValue('ProductName') + ' ' + result.getValue('ChargeName');
                
            eii.Description = description;
            
            eii.Amount = (Decimal) result.getValue('ChargeAmount');

            String id = (String) result.getValue('InvoiceId');
            
            for (ExistingInvoice ei : this.Invoice.ExistingInvoices)
                if (ei.Id == id) {
                    ei.Items.add(eii);
                    
                    break;
                }
        }
    }
    
    private void checkForDraftInvoices() {
        String query = 'SELECT Id FROM Invoice WHERE AccountId = \'' + this.Invoice.AccountId + '\' AND Status = \'Draft\'';
       
        List<Zuora.zObject> results = callZuora(zOperation.zQUERY, query);
        
        this.hasDraftInvoices = results.size() > 0;
    }
    
    private List<Zuora.zApi.SubscribeRequest> getSubscribeRequests() {   
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();

        for (Bundle b : this.Invoice.Additions) {
            for (Product p : b.Contents) {
                Zuora.zApi.SubscribeRequest request = getSubscribeRequest(p);
                
                if (request != null)
                    subscribeRequests.add(request);
            }
        }
        
        return subscribeRequests;
    }
    
    private Zuora.zApi.SubscribeRequest getSubscribeRequest(Product product) {
        if (String.isNotBlank(product.SubscriptionId)) return null;
        
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
         
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', this.Invoice.AccountId);
         
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = this.Invoice.Preview; // We only want to generate individual invoices for each subscription when previewing the transaction. For the actual one, we want a single invoice covering everything
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = this.Invoice.Preview;
                
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('TermType', 'TERMED');
        subscription.setValue('AutoRenew', 'true');
        subscription.setValue('InitialTerm', product.InitialTerm);
        subscription.setValue('RenewalTerm', product.RenewalTerm);
        //subscription.setValue('IsInvoiceSeparate', 'false');

        /*
        This portion marks a crucial distinction between core and premium products: 
        
        - Core products start on the term end date of the existing core product. If there isn't an existing core product, i.e., new MRIS subscription or the previous core product has expired, then they start immediately
        - Premium products always start immediately
        */
        String effectiveDate;
        Boolean futureActivation = false;
        
        if (product.IsCore) {
            subscription.setValue('IsCore__c', 'true');
            
            for (Bundle b : this.Invoice.Removals) {
                for (Product p : b.Contents) {
                    if (p.IsCore && !p.IsFutureSubscription) {
                        String d = p.TermEndDate.replace('T', ' ');                        
                       // effectiveDate = DateTime.valueOf(d).addDays(1).format('yyyy-MM-dd', 'PST');
                        effectiveDate = d;
                        futureActivation = true;
                        
                        break;
                    }
                }
                
                if (effectiveDate != null) break;
            }
        }
        
        if (effectiveDate == null){
            effectiveDate = this.Invoice.EffectiveDate;
            subscription.setValue('ContractEffectiveDate', product.ContractEffectiveDate);
            subscription.setValue('ServiceActivationDate', product.ServiceActivationDate);
        } 
        else {   
            subscription.setValue('ContractEffectiveDate', effectiveDate);
            subscription.setValue('ServiceActivationDate', effectiveDate);
        }
        
        request.SubscriptionData.Subscription = subscription;
        
        List<String> zProductRatePlanIds = new List<String>();
        
        /* 
        Only add one-time product rate plans if the subscription is being activated immediately, or being activated in the future and the one-time plan is not a reinstatement fee. Reinstatement fees get charged immediately regardless of the scenario. Note that this is coded to cover all bases. The scenario of future activation with a one-time setup fee should never happen. The only scenario where future activation is required is for reinstating core products. In that case, product.IsNew will be false 
        */
        if (product.OneTime != null && (!futureActivation || product.IsNew))
            zProductRatePlanIds.add(product.OneTime.Id);

        if (product.Recurring != null)
            zProductRatePlanIds.add(product.Recurring.Id);
            
        for (ProductRatePlan p : product.Discounts)
            zProductRatePlanIds.add(p.Id);
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        
        for (String id : zProductRatePlanIds) {
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', id);
                        
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            ratePlanData.setValue('RatePlan', ratePlan);
            
            ratePlanDataList.add(ratePlanData);
        }
        
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
            
        return request;
    }   

    /*
    There are three types of amendment requests:
    1. Amendment for an existing, non-expired core product to add a reinstatement fee. Remember, initial setup fees are charged along with the new core product; reinstatement fees are charged immediately
    2. Amendments to turn auto-renew back on for premium products. This can only happen when we are reinstating a core subscription
    3. Amendments to cancel premium products or take core products off of auto-renew
    */
    private List<List<Zuora.zApi.AmendRequest>> getAmendRequests() {   
        List<List<Zuora.zApi.AmendRequest>> amendRequests = new List<List<Zuora.zApi.AmendRequest>>();

        List<Zuora.zApi.AmendRequest> reinstate = getReinstatementFeeRequest();
        
        if (reinstate != null)
            amendRequests.add(reinstate);

        Boolean allowAutoRenews = false;
        
        for (Bundle b : this.Invoice.Additions) {
            for (Product p : b.Contents) {
                if (p.IsCore && !p.IsNew)
                    allowAutoRenews = true;
            }
        }
        
        if (allowAutoRenews) {
            for (String subscriptionId : this.Invoice.AutoRenews)
                amendRequests.add(getAutoRenewRequest(subscriptionId));
        }
        else {
            for (Bundle b : this.Invoice.Additions) {
                for (Product p : b.Contents) {
                    if (p.IsCore) continue;
                    if (String.isBlank(p.SubscriptionId)) continue;
                    
                    amendRequests.add(getAutoRenewRequest(p.SubscriptionId));
                }
            }
        }
                    
        for (Bundle b : this.Invoice.Removals) {
            for (Product p : b.Contents) {
                if (!p.IsFutureSubscription) {
                    List<Zuora.zApi.AmendRequest> request = getAmendRequest(p);
                    
                    if (request != null)
                        amendRequests.add(request);
                }
            }
        }
        
        return amendRequests;
    }

    private List<Zuora.zApi.AmendRequest> getReinstatementFeeRequest() {
        Product source;
        String target;
        
        /*
        If there is a reinstatement fee and there is an existing core subscription, then we need to split out the reinstatement fee and add it to the existing core subscription. Reinstatement fees must be charged immediately, whereas initial setup fees are charged when the new core subscription comes into term.
        */
        for (Bundle b : this.Invoice.Additions) {
            for (Product p : b.Contents) {
                if (!p.IsCore) continue;
                
                if (p.IsNew) return null;
                
                if (p.OneTime == null) return null;
                
                source = p;
                
                break;
            }
            
            if (source != null) break;
        }
        
        if (source == null) return null;
        
        if (String.isNotBlank(source.SubscriptionId))
            target = source.SubscriptionId;
        else {
            for (Bundle b : this.Invoice.Removals) {
                for (Product p : b.Contents) {
                    if (p.IsCore && !p.IsFutureSubscription) {
                        target = p.SubscriptionId;
                        
                        break;
                    }
                }
                
                if (String.isNotBlank(target)) break;
            }
        }
        
        if (String.isBlank(target)) return null;
                
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        
        request.Amendments = new List <Zuora.zObject>();
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('SubscriptionId', target);
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('ServiceActivationDate', this.Invoice.EffectiveDate);
        amendment.setValue('EffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('Type', 'NewProduct');
        amendment.setValue('Name', 'Reinstatement Fee');
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', source.OneTime.Id);

        ratePlanData.setValue('RatePlan', ratePlan);

        amendment.setValue('RatePlanData', ratePlanData);
    
        request.Amendments.add(amendment);
                
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.GenerateInvoice = this.Invoice.Preview; // We only want to generate individual invoices for each subscription when previewing the transaction. For the actual one, we want a single invoice covering everything
        request.AmendOptions.ProcessPayments = false;
                
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = this.Invoice.Preview;

        return new List<Zuora.zApi.AmendRequest> { request };
    }   

    private List<Zuora.zApi.AmendRequest> getAutoRenewRequest(String subscriptionId) {
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        
        request.Amendments = new List <Zuora.zObject>();
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', 'TermsAndConditions');
        amendment.setValue('AutoRenew', 'true');
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('ServiceActivationDate', this.Invoice.EffectiveDate);
        amendment.setValue('EffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('Name', 'Product Reinstatement');

        request.Amendments.add(amendment);
                
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.GenerateInvoice = this.Invoice.Preview; // We only want to generate individual invoices for each subscription when previewing the transaction. For the actual one, we want a single invoice covering everything
        request.AmendOptions.ProcessPayments = false;
                
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = this.Invoice.Preview;

        return new List<Zuora.zApi.AmendRequest> { request };
    }
        
    private List<Zuora.zApi.AmendRequest> getAmendRequest(Product product) {
        if (product.IsFutureSubscription) return null;
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        
        request.Amendments = new List <Zuora.zObject>();
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('SubscriptionId', product.SubscriptionId);
        amendment.setValue('Status', 'Completed');
        amendment.setValue('ContractEffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('ServiceActivationDate', this.Invoice.EffectiveDate);
        amendment.setValue('EffectiveDate', this.Invoice.EffectiveDate);
        amendment.setValue('Name', 'Product Removal Due To Conflict');

        /*
        This portion marks a crucial distinction between core and premium products: 
        
        - Core products must run its term, i.e., there is no refund for core products. That's why we are simply turning auto-renew off
        - Premium products always terminate immediately
        */
        if (product.IsCore) {
            amendment.setValue('Type', 'TermsAndConditions');
            amendment.setValue('AutoRenew', 'false');
        }
        else
            amendment.setValue('Type', 'Cancellation');
        
        request.Amendments.add(amendment);
                
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.GenerateInvoice = this.Invoice.Preview; // We only want to generate individual invoices for each subscription when previewing the transaction. For the actual one, we want a single invoice covering everything
        request.AmendOptions.ProcessPayments = false;
                
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = this.Invoice.Preview;

        return new List<Zuora.zApi.AmendRequest> { request };
    }    

    private List<String> getDeleteRequests() {   
        List<String> deleteRequests = new List<String>();

        for (Bundle b : this.Invoice.Removals) {
            for (Product p : b.Contents) {
                if (p.IsFutureSubscription)
                    deleteRequests.add(p.SubscriptionId);
            }
        }
        
        return deleteRequests;
    }
    
    private void importInvoiceCharges(List<Object> source, List<Bundle> target) {
        if (source == null) return;       
        
        Map<String, List<ProductRatePlanCharge>> mapping = new Map<String, List<ProductRatePlanCharge>>();
        
        Boolean changed = true;
        
        /* 
        Sort all the invoice items by their service end date. This is to prioritize one-time fees over recurring fees. 
        Instead of comparing charge names, which can easily change, the service end date for one-time fees is the same as 
        the service start date. This guarantees that the end date for one-time will always be earlier than the end date 
        for recurring.
        
        While this sorting algorithm might be inefficient, 1) Apex does not offer a native solution to sort based on field, 2) the maximum
        expected number of items in this list is 3, and 3) the algorithm is simple.
        */
        while (changed) {
            changed = false;
            
            for (Integer i = 0; i < source.size(); i++) {
                if (i + 1 == source.size()) break;
                
                DateTime a = (Date) ((Zuora.zObject) source.get(i)).getValue('ServiceEndDate');
                DateTime b = (Date) ((Zuora.zObject) source.get(i + 1)).getValue('ServiceEndDate');
                
                if (a > b) {
                    source.add(i, source.remove(i + 1));
                    changed = true;
                }
            }
        }

        for (Object item : source) {
            Zuora.zObject zInvoiceItem = (Zuora.zObject) item;

            String pid = (String) zInvoiceItem.getValue('ProductId');
            
            if (pid == DiscountProductId) continue;

            LastSubscribedProductId = pid;

            break;
        }
        
        for (Object item : source) {
            Zuora.zObject zInvoiceItem = (Zuora.zObject) item;

            ProductRatePlanCharge charge = new ProductRatePlanCharge();
            charge.Name = (String) zInvoiceItem.getValue('ChargeName');
            charge.Amount = (Decimal) zInvoiceItem.getValue('ChargeAmount');
            charge.Tax = (Decimal) zInvoiceItem.getValue('TaxAmount');
            
            String pid = (String) zInvoiceItem.getValue('ProductId');

            if (pid == DiscountProductId) pid = LastSubscribedProductId;
            
            if (mapping.get(pid) == null)
                mapping.put(pid, new List<ProductRatePlanCharge>());            
            
            mapping.get(pid).add(charge);
        }
        
        for (Bundle b : target) {
            for (Product p : b.Contents) {
                if (!mapping.containsKey(p.Id)) continue;
                
                p.Preview.addAll(mapping.get(p.Id));
            }
        }
    }

    private List<Zuora.zObject> callZuora(zOperation operation, String query) {
        List<Zuora.zObject> zQueryResult;
        
        if (operation != zOperation.zQUERY)
            throw new CustomException('Illegal Zuora Operation');

        //zQueryResult = zApiInstance.zquery(query);
        zQueryResult = zUtilInstance.zquery(query);
        
        return zQueryResult;
    }
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        return callZuora(operation, new List<Zuora.zObject> { content });
    }  
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, List<Zuora.zObject> zObjectList) {
        List<Zuora.zApi.SaveResult> zSaveResultList;
        
        if (operation == zOperation.zCREATE)
            zSaveResultList = zUtilInstance.zcreate(zObjectList); //zSaveResultList = zApiInstance.zcreate(zObjectList);
        else if (operation == zOperation.zUPDATE)
            zSaveResultList = zUtilInstance.zupdate(zObjectList); //zSaveResultList = zApiInstance.zupdate(zObjectList);
        else if (operation == zOperation.zGENERATE)
            zSaveResultList = zUtilInstance.zgenerate(zObjectList); //zSaveResultList = zApiInstance.zgenerate(zObjectList);
        else
            throw new CustomException('Illegal Zuora Operation');
            
        return !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
    }  

    private List<Zuora.zApi.SubscribeResult> callZuora(zOperation operation, List<Zuora.zApi.SubscribeRequest> requests) {
        List<Zuora.zApi.SubscribeResult> zSubscribeResultList;
        
        if (operation != zOperation.zSUBSCRIBE)
            throw new CustomException('Illegal Zuora Operation');

        zSubscribeResultList = zUtilInstance.zsubscribe(requests); //zSubscribeResultList = zApiInstance.zsubscribe(requests);
            
        return zSubscribeResultList;
    }  

    private Zuora.zApi.AmendResult callZuora(zOperation operation, List<Zuora.zApi.AmendRequest> requests) {
        Zuora.zApi.AmendResult zAmendResult;
        
        if (operation != zOperation.zAMEND)
            throw new CustomException('Illegal Zuora Operation');

        zAmendResult = zUtilInstance.zamend(requests); //zAmendResult = zApiInstance.zamend(requests);
            
        return zAmendResult;
    }  

    private List<Zuora.zApi.DeleteResult> callZuora(zOperation operation, List<String> ids) {
        List<Zuora.zApi.DeleteResult> zDeleteResults;
        
        if (operation != zOperation.zDELETE)
            throw new CustomException('Illegal Zuora Operation');

        zDeleteResults = zUtilInstance.zdelete('Subscription', ids); //zDeleteResults = zApiInstance.zdelete('Subscription', ids);
            
        return zDeleteResults;
    }  

    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    public class InputData {
        public String OrderId { get; set; }
        public String AccountId { get; set; }
        public Boolean BypassPayment { get; set; }
        public List<InputItem> Contents { get; set; }
        
        public InputData() {
            this.OrderId = '';
            this.AccountId = '';
            this.BypassPayment = false;
            this.Contents = new List<InputItem>();
        }
    }

    public class InputItem {
        public String BundleId { get; set; }
        public String BundleName { get; set; }
        public String ProductId { get; set; }
        public String ProductName { get; set; }
        public String OneTimeProductRatePlanId { get; set; }
        public String OneTimeProductRatePlanName { get; set; }
        public String RecurringProductRatePlanId { get; set; }
        public String RecurringProductRatePlanName { get; set; }
        public String DiscountProductRatePlanId { get; set; }
        public String DiscountProductRatePlanName { get; set; }
        public Integer TermDuration { get; set; }
        public Boolean IsCore { get; set; }
        public Boolean IsNew { get; set; }
        public Boolean IsDiscountOnly {
            get {
                return String.isBlank(this.OneTimeProductRatePlanId) && String.isBlank(this.RecurringProductRatePlanId) && String.isNotBlank(this.DiscountProductRatePlanId);
            }
        }
        
        public String ContractEffectiveDate { get; set; }
        public String ServiceActivationDate { get; set; }
        public Integer InitialTerm { get; set; }
        public Integer RenewalTerm { get; set; }

        public InputItem() {
            this.BundleId = '';
            this.BundleName = '';
            this.ProductId = '';
            this.ProductName = '';
            this.OneTimeProductRatePlanId = '';
            this.OneTimeProductRatePlanName = '';
            this.RecurringProductRatePlanId = '';
            this.RecurringProductRatePlanName = '';
            this.DiscountProductRatePlanId = '';
            this.DiscountProductRatePlanName = '';
            this.TermDuration = 0;
            this.IsCore = true;
            this.IsNew = true;
            
            this.ContractEffectiveDate = '';
            this.ServiceActivationDate = '';
            this.InitialTerm = 0;
            this.RenewalTerm = 0;

        }
    }
    
    public class InvoiceData {
        public String OrderId { get; set; }
        public String AccountId { get; set; }
        public Boolean BypassPayment { get; set; }
        public Decimal ExistingBalance { get; set; }
        public Decimal InvoiceBalance {
            get {
                return this.ChargeFromAdditions + this.CreditFromRemovals;
            }
        }
        public Decimal TaxBalance { 
            get {
                Decimal sum = 0;
                
                for (Bundle i : this.Additions)
                    sum += i.Tax;

                for (Bundle i : this.Removals)
                    sum += i.Tax;
                    
                return sum;
            }
        }
        public Decimal BalanceDue {
            get {
                Decimal net = this.InvoiceBalance + this.TaxBalance + this.ExistingBalance;
                
                return net > 0 ? net : 0;
            }
        }
        public Decimal ChargeFromAdditions { 
            get {
                Decimal sum = 0;
                
                for (Bundle i : this.Additions)
                    sum += i.Amount;
                    
                return sum;
            }
        }
        public Decimal CreditFromRemovals { 
            get {
                Decimal sum = 0;
                
                for (Bundle i : this.Removals)
                    sum += i.Amount;
                    
                return sum;
            }
        }
        public Decimal AmountPaid { get; set; }
        public List<Bundle> Additions { get; set; }
        public List<Bundle> Removals { get; set; }
        public List<ExistingInvoice> ExistingInvoices { get; set; }
        public Set<String> AutoRenews { get; set; }
        public String EffectiveDate { get; set; }
        public Boolean Preview { get; set; }
        public Boolean PayBalanceDueOnly { 
            get {
                return this.Additions.size() == 0;
            }
        }
        public Boolean HasOutstandingInvoices { 
            get {
                return this.ExistingInvoices.size() != 0;
            }
        }
    }    
    
    public class Bundle {
        public String Id { get; set; }
        public String Name { get; set; }
        public Boolean IsBundle { get; set; }
        public Decimal Amount { 
            get {
                Decimal sum = 0;
                
                for (Product i : this.Contents)
                    sum += i.Amount;
                    
                return sum;
            }
        }
        public Decimal Tax { 
            get {
                Decimal sum = 0;
                
                for (Product i : this.Contents)
                    sum += i.Tax;
                    
                return sum;
            }
        }
        public List<Product> Contents { get; set; }
    }
    
    public class Product {
        public String Id { get; set; }
        public String Name { get; set; }
        public String EffectiveDate { get; set; }
        public String TermEndDate { get; set; }
        public Integer TermDuration { get; set; }
        public Boolean IsCore { get; set; }
        public Boolean IsNew { get; set; }
        
        public String ServiceActivationDate { get; set; }
        public String ContractEffectiveDate { get; set; }
        public Integer InitialTerm { get; set; }
        public Integer RenewalTerm { get; set; }
        
        public Boolean IsFutureSubscription {
            get {
                return Date.valueOf(EffectiveDate.replace('T', ' ')) > DateTime.now().date();
            }
        }
        public Decimal Amount { 
            get {
                Decimal sum = 0;
                
                for (ProductRatePlanCharge i : this.Preview)
                    sum += i.Amount;
                    
                return sum;
            }
        }
        public Decimal Tax { 
            get {
                Decimal sum = 0;
                
                for (ProductRatePlanCharge i : this.Preview)
                    sum += i.Tax;
                    
                return sum;
            }
        }
        public ProductRatePlan OneTime { get; set; }
        public ProductRatePlan Recurring { get; set; }
        public List<ProductRatePlan> Discounts { get; set; }
        public List<ProductRatePlanCharge> Preview { get; set; }
        public String SubscriptionId { get; set; }
    }
    
    public class ProductRatePlan {
        public String Id { get; set; }
        public String Name { get; set; }
    }
    
    public class ProductRatePlanCharge {
        public String Name { get; set; }
        public Decimal Amount { get; set; }
        public Decimal Tax { get; set; }
    }
    
    public class ExistingInvoice {
        public String Id { get; set; }
        public String InvoiceNumber { get; set; }
        public String PostedDate { get; set; }
        public Decimal Balance { get; set; }
        public Decimal Tax { get; set; }
        public List<ExistingInvoiceItem> Items { get; set; }
    }

    public class ExistingInvoiceItem {
        public String Description { get; set; }
        public Decimal Amount { get; set; }
    }

    public class CustomException extends Exception {}
}