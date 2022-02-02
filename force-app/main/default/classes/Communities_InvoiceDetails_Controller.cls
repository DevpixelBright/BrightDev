public class Communities_InvoiceDetails_Controller { 
    private enum zOperation { zQUERY }
    private enum SOALineType { SOAInvoice, SOAPayment, SOARefund, SOACreditRefundApplied, SOACreditAdjustment, SOAInvoiceItemAdjustment, SOAInvoiceItemOneTime, SOAInvoiceItemRecurring, SOAInvoiceItemDiscount}
    
    public String id { get; private set; }
    public String invoiceId { get; private set; }
    public String returnUrl { get; private set; }
    public String returnText { get; private set; }
    public Boolean hasReturnUrl { get; private set; }
    public Boolean debugMode { get; private set; }
    
    public Boolean initialLoad { get; private set; }

    public Boolean hasError { get; private set; }
    public Boolean hasInvoiceError { get; private set; }
    public Boolean hasPaymentError { get; private set; }
            
    public ZuoraAccountData myZuoraAccountData { get; private set; }

    public ZuoraInvoiceSummary outputInvoiceSummary { get; private set;}

    public DateFilter dateLimits { get; private set; }

    public List<Integer> yearOptions {
        get {
            Integer newest = DateTime.now().year();
            Integer oldest = DateTime.now().addMonths(-18).year();
            
            List<Integer> options = new List<Integer>();
            
            for (Integer i = newest; i >= oldest; i--)
                options.add(i);
            
            return options;
        }
    }
    
    public Boolean currentYearTruncated {
        get {
            if (DateTime.now().month() == 6) return false;
            
            return dateLimits.maxYear == yearOptions[yearOptions.Size() - 1];
        }
    }
    
    public DateTime truncationDate {
        get {
            DateTime d = DateTime.now().addMonths(-18);
            
            return DateTime.newInstance(d.year(), d.month(), 1);
        }
    }

    //from here, it's all private variables. 
    private InvoiceItemsSummariesMappedByInvoiceId myInvoiceItemsSummariesMappedByInvoiceId { get; private set; }

    private ZuoraInvoiceObjectMappedByInvoiceId myZuoraInvoiceObjectMappedByInvoiceId { get; private set; }

    private Subscriptions__c mySFSubscription { get; private set; }

    private Account myOfficeAccount { get; private set; } // This will get the information of the office name which is the subscrtipion's Related_Location_Broker_Office__c
    
    private Contact mySFSubcriptionContact { get; private set;}
    
    private InvoiceData myInvoiceData { get; private set; }
    
    private InvoiceItemData myInvoiceItemData { get; private set; }
    
    private InvoiceItemsMappedByInvoiceId myInvoiceItemsMappedByInvoiceId { get; set; }

    private ZuoraSubscriptionData myZuoraSubscriptionData { get; private set; }

    private String DiscountProductId {get; private set; }

    private map<String, String> feeNames {get; private set; }
    
    private Zuora.zApi zApiInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    
    private SMS_ZuoraUtil zUtilInstance;

    public Communities_InvoiceDetails_Controller() {
        initialLoad = true;

        id = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(id)) 
            throw new CustomException('Invalid MRIS Subscription ID'); 

        invoiceId = ApexPages.currentPage().getParameters().get('invoiceId');
        if (String.isBlank(invoiceId)) 
            throw new CustomException('Invalid MRIS Invoice ID'); 

        returnUrl = ApexPages.currentPage().getParameters().get('returnUrl');
        if (String.isNotBlank(returnUrl)) {
            hasReturnUrl = true;
            returnText = ApexPages.currentPage().getParameters().get('returnText');
        }
        else 
            hasReturnUrl = false;

        String debug = ApexPages.currentPage().getParameters().get('debug');            
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
    }
    
    public void init() {
        initialLoad = false;
        hasError = false;
        
        try {
            myInvoiceData = new InvoiceData();
            myInvoiceItemData = new InvoiceItemData();
            myInvoiceItemsMappedByInvoiceId = new InvoiceItemsMappedByInvoiceId();
            myInvoiceItemsSummariesMappedByInvoiceId = new InvoiceItemsSummariesMappedByInvoiceId();
            myZuoraInvoiceObjectMappedByInvoiceId = new ZuoraInvoiceObjectMappedByInvoiceId();
            myZuoraSubscriptionData = new ZuoraSubscriptionData();
            
            outputInvoiceSummary = new ZuoraInvoiceSummary();

            myInvoiceData.SubscriptionId = id;
            
            myInvoiceData.InvoicesMappedByInvoiceId = new Map<String, Invoice>();
            
            myInvoiceItemData.InvoiceItems = new List<InvoiceItem>();

            myInvoiceItemsMappedByInvoiceId.invoiceItemsMappedByInvoiceId = new Map<String, List<InvoiceItem>>();

            myInvoiceItemsSummariesMappedByInvoiceId.Summaries = new map<String, InvoiceItemsSummaryByInvoiceId>();
            myInvoiceItemsSummariesMappedByInvoiceId.SummariesBySubID = new map<String, InvoiceItemsSummaryBySubIdByInvoiceId>();

            myZuoraInvoiceObjectMappedByInvoiceId.ZuoraInvoicesMappedByInvoiceId = new map<String, Zuora__ZInvoice__c>();
            
            this.zUtilInstance = new SMS_ZuoraUtil();
            this.zLoginResult = zUtilInstance.zLogin();
            
            dateLimits = new DateFilter();
            dateLimits.SetMaxDateToNow();
            dateLimits.SetMinDate(2000, 4, 1);
            
            populateSFSubscription();
            populateInvoices();
            populateSubscriptionsRelatedToZuroaAccount();
            
            String query = 'SELECT Id FROM Product WHERE Name = \'' + Label.MRIS_Zuora_Discount_Product_Name + '\'';
            List<Zuora.zObject> discount = callZuora(zOperation.zQuery, query);

            if (discount.size() > 0)
                DiscountProductId = (String) discount[0].getValue('Id');

            String feeQuery = 'SELECT Id, Name FROM Product WHERE ';

            List<String> names = Label.MRIS_Zuora_Fee_Product_Names.split(',');

            Boolean first = true;

            for (String name : names) {
                if (!first) feeQuery += ' OR ';

                feeQuery += 'Name = \'' + name.trim() + '\'';

                first = false;
            }

            List<Zuora.zObject> fees = callZuora(zOperation.zQuery, feeQuery);

            feeNames = new Map<String, String>();

            for (Zuora.zObject fee : fees) {
                String id = (String) fee.getValue('Id');
                String name = (String) fee.getValue('Name');

                feeNames.put(id, name);
            }

            getSOAInvoiceSummary();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }

    public void getSOAInvoiceSummary() {      
        hasInvoiceError = false;
        
        try {
            outputInvoiceSummary.InvoiceId = invoiceId;   

            //If Invoice Items Mapped by Invoice Id and Summary of Invoice Items mapped by Invoice Id already has the invoice Id
            if (myInvoiceItemsMappedByInvoiceId.InvoiceIdExists(outputInvoiceSummary.InvoiceId)) {
                //Do nothing
            }
            else {
                //Load that specific set of the invoice items for that invoice Id. 
                populateInvoiceItemsByInvoiceId(outputInvoiceSummary.InvoiceId);
                populateSFInvoiceObjectByInvoiceId(outputInvoiceSummary.InvoiceId);
                populateInvoiceItemSummaryMappedByInvoiceId();
                populateInvoiceItemSummaryMappedBySubIdByInvoiceId();
                
            }

            outputInvoiceSummary.invoiceSummary = myInvoiceItemsSummariesMappedByInvoiceId.Summaries.get(outputInvoiceSummary.invoiceId);
            outputInvoiceSummary.invoiceSummaryBySubId = myInvoiceItemsSummariesMappedByInvoiceId.SummariesBySubID.get(outputInvoiceSummary.invoiceId);
            sortOutputInvoiceItemsByNameAndDate();
            markOutputInvoiceItemsByActiveSubscription();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasInvoiceError = true;
        }
    }
  
    public PageReference getInvoicePDF() {
        PageReference pdf = new PageReference('/apex/Communities_InvoiceDetails_PDF');
        pdf.setRedirect(false);
        
        return pdf;
    }
    
    private void populateInvoiceItemSummaryMappedBySubIdByInvoiceId() {

        myInvoiceItemsSummariesMappedByInvoiceId.SummariesBySubID.clear();
        for (String InvoiceIdKey: myInvoiceItemsSummariesMappedByInvoiceId.Summaries.keySet()) {
            InvoiceItemsSummaryByInvoiceId itemsSummaryByInvoiceId = myInvoiceItemsSummariesMappedByInvoiceId.Summaries.get(InvoiceIdKey);
            InvoiceItemsSummaryBySubIdByInvoiceId itemsSummaryBySubIdByInvoiceId = new InvoiceItemsSummaryBySubIdByInvoiceId(itemsSummaryByInvoiceId, this.feeNames);
            myInvoiceItemsSummariesMappedByInvoiceId.SummariesBySubID.put(InvoiceIdKey, itemsSummaryBySubIdByInvoiceId);
        }        
    }

    private void markOutputInvoiceItemsByActiveSubscription() {
        ZuoraSubscription zSubscription = null;
        Boolean IsActive = false;

        for (String subIdKey: outputInvoiceSummary.invoiceSummaryBySubId.invoiceItemSummariesBySubIdByInvoiceId.keySet()) {
            IsActive = false;
            if (myZuoraSubscriptionData.Subscriptions.containsKey(subIdKey)) {
                zSubscription = myZuoraSubscriptionData.Subscriptions.get(subIdKey);
                if (zSubscription.IsActive) {
                    IsActive = true;
                }
            }
            //To have compliance fines always active. 
            if (subIdKey.contains('CMPFINE')) {
                IsActive = true;
            }
            InvoiceItemSummariesBySubId itemSummariesBySubId = outputInvoiceSummary.invoiceSummaryBySubId.invoiceItemSummariesBySubIdByInvoiceId.get(subIdKey);
            itemSummariesBySubId.IsActive = IsActive;
        }
    }
    
    private void sortOutputInvoiceItemsByNameAndDate() {
        map<String, InvoiceItemSummary> keyInvoiceSummaryList = new map<String, InvoiceItemSummary>();

        List<String> newSortOrder = new List<String>(); 
        for (String subIdKey: outputInvoiceSummary.invoiceSummaryBySubId.invoiceItemSummariesBySubIdByInvoiceId.keySet()) {
            InvoiceItemSummariesBySubId itemSummariesBySubId = outputInvoiceSummary.invoiceSummaryBySubId.invoiceItemSummariesBySubIdByInvoiceId.get(subIdKey);
            InvoiceItemSummary summary = itemSummariesBySubId.KeyInvoice;
            keyInvoiceSummaryList.put(subIdKey, summary);
            newSortOrder.add(subIdKey);
        }
            
        String swap;
        Boolean toSwap = false;
        Integer len = newSortOrder.size();
        for (Integer i = 0; i<len; i++) {
            for (Integer j = 0; j< len - i - 1; j++) {
                //Name in ascending order A to Z
                //Within same name, dates in ascending order early to late
                toSwap = false;
                InvoiceItemSummary summary_j = keyInvoiceSummaryList.get(newSortOrder.get(j));
                InvoiceItemSummary summary_j_plus = keyInvoiceSummaryList.get(newSortOrder.get(j+1));
                
                Integer stringCompare = summary_j.ProductName.compareTo(summary_j_plus.ProductName);
                if (stringCompare == -1) {
                    //Do nothing
                }else if (stringCompare == 0) {
                    if (summary_j.StartDate < summary_j_plus.StartDate) {
                        //Do nothing
                    }else {
                        toSwap = true;
                    }
                }
                else //stringCompare == 1  
                {
                    toSwap = true;
                }
                if(toSwap) {
                    swap = newSortOrder.get(j);
                    newSortOrder.set(j, newSortOrder.get(j+1));
                    newSortOrder.set(j+1, swap);
                }
            }
        }
        outputInvoiceSummary.invoiceSummaryBySubIdSortOrder = newSortOrder;
    }

    private void populateInvoiceItemSummaryMappedByInvoiceId() {
        myInvoiceItemsMappedByInvoiceId.ClearAllInvoiceItems();
        for (InvoiceItem invoiceItem: myInvoiceItemData.InvoiceItems) {
            //myInvoiceItemsMappedByInvoiceId.invoiceItemsMappedByInvoiceId.put(invoiceItem.InvoiceId, NULL);
            myInvoiceItemsMappedByInvoiceId.AddInvoiceItem(invoiceItem);
        }

        myInvoiceItemsSummariesMappedByInvoiceId.Summaries.clear();
        for (String key: myInvoiceItemsMappedByInvoiceId.invoiceItemsMappedByInvoiceId.KeySet()) {
            InvoiceItemsSummaryByInvoiceId itemsSummaryByInvoiceId = new InvoiceItemsSummaryByInvoiceId();
            itemsSummaryByInvoiceId.InvoiceItemSummaries = new List<InvoiceItemSummary>();

            Invoice invoice = myInvoiceData.GetInvoiceByInvoiceId(key);
            List<InvoiceItem> items = myInvoiceItemsMappedByInvoiceId.invoiceItemsMappedByInvoiceId.get(key);

            Zuora__ZInvoice__c zuoraInvoice = myZuoraInvoiceObjectMappedByInvoiceId.GetZuoraInvoiceByInvoiceId(key);

            Decimal subTotal = 0;
            Decimal tax = 0;
            Decimal total = 0;

            Map<String, List<InvoiceItem> > itemsMappedByBundleName = new Map<String, List<InvoiceItem>>();
            for (InvoiceItem item: items) {
                String bundleName; 
                if (String.isNotBlank(item.ChargeDescription) && item.ChargeDescription.startsWith('#')) {
                    //These are bundle items, which we will use special processing for. 
                    bundleName = item.ChargeDescription;
                    List<InvoiceItem> itemsInBundle;
                    if(itemsMappedByBundleName.containsKey(bundleName)) { 
                        itemsInBundle = itemsMappedByBundleName.get(bundleName);
                        itemsInBundle.add(item);
                        itemsMappedByBundleName.put(bundleName, itemsInBundle);
                    } else {
                        itemsInBundle = new List<InvoiceItem>();
                        itemsInBundle.add(item);
                        itemsMappedByBundleName.put(bundleName, itemsInBundle);
                    }
                    
                } else {
                    
                    //These are single items (not in bundles)
                    InvoiceItemSummary invoiceItemSummary = item.GenerateInvoiceItemSummary();
                    itemsSummaryByInvoiceId.InvoiceItemSummaries.add(invoiceItemSummary);
                }

                subTotal = subTotal + item.ChargeAmount;
                tax = tax + item.TaxAmount;
            }
            
            String firstStringFilter = '^([a-zA-Z]+)';
            Pattern firstStringPattern = Pattern.compile(firstStringFilter);
            String subsequentStringsFilter = '[ ]([a-zA-Z]+)';
            Pattern subsequentStringsPattern = Pattern.compile(subsequentStringsFilter);

            for (String bundleName: itemsMappedByBundleName.keySet()) {
                List<InvoiceItem> itemsInBundle = itemsMappedByBundleName.get(bundleName);
                Decimal bundleTotal = 0;
                InvoiceItemSummary bundleSummary = new InvoiceItemSummary();
                bundleSummary.ProductName = 'Bundle';


                String bundleNameforRegex = bundleName; 
                System.debug ('bundleNameforRegex: ' + bundleNameforRegex);

                String finishedBundleName = '';

                Matcher firstStringMatcher = firstStringPattern.matcher(bundleNameforRegex);

                List<String> filteredStrings = new List<String>();

                while (firstStringMatcher.find()) {
                    filteredStrings.add(firstStringMatcher.group(1));
                    System.debug('firstStringMatcher: ' + firstStringMatcher.group(1));
                }

                Matcher subsequentStringsMatcher = subsequentStringsPattern.matcher(bundleNameforRegex);
                while (subsequentStringsMatcher.find()) {
                    filteredStrings.add(subsequentStringsMatcher.group(1));
                    System.debug('subsequentStringsMatcher: ' + subsequentStringsMatcher.group(1));
                }

                for (String subString: filteredStrings) {
                    finishedBundleName = finishedBundleName + ' ' + subString;
                }
                
                
                for (InvoiceItem item: itemsInBundle) {
                    bundleTotal = bundleTotal + item.ChargeAmount;
                    bundleSummary.StartDate = item.ServiceStartDate;
                    bundleSummary.EndDate = item.ServiceEndDate;
                    bundleSummary.lineType = SOALineType.SOAInvoiceItemRecurring;
                    bundleSummary.ProductId = item.ProductId;
                }

                bundleSummary.Comments = finishedBundleName;
                List<String> splittedComments = bundleSummary.Comments.split(' // ');
                String combinedComments = String.join(splittedComments, '<br />');
                bundleSummary.Comments = combinedComments;
                
                bundleSummary.Price = bundleTotal;
                bundleSummary.StartDateString = bundleSummary.StartDate.format('MM/dd/yyyy','GMT');
                bundleSummary.EndDateString = bundleSummary.EndDate.format('MM/dd/yyyy','GMT');

                //Now put that bundle summary into the invoice item summaries like a normal summary
                itemsSummaryByInvoiceId.InvoiceItemSummaries.add(bundleSummary);
            }

            total = subTotal + tax;
            itemsSummaryByInvoiceId.SortInvoiceItemSummaries();
            itemsSummaryByInvoiceId.SubTotal = subTotal;
            itemsSummaryByInvoiceId.TaxAmount = tax;
            itemsSummaryByInvoiceId.Total = total;
            itemsSummaryByInvoiceId.InvoiceNumber = invoice.InvoiceNumber;
            itemsSummaryByInvoiceId.InvoiceDate = invoice.InvoiceDate;
            itemsSummaryByInvoiceId.InvoiceDateString = invoice.InvoiceDate.format('MM/dd/yyyy','GMT');
            itemsSummaryByInvoiceId.MRIS_Id = mySFSubscription.Name; 
            //itemsSummaryByInvoiceId.Office_ID = mySFSubscription.NATIONALACCOUNTID__c;
            itemsSummaryByInvoiceId.BillTo = mySFSubscription.CUSTOMERNAME__c;
            //itemsSummaryByInvoiceId.Email = mySFSubscription.Private_email__c;

            //Logic for filling out the Office_ID: 
            if (zuoraInvoice != null) {
                if (zuoraInvoice.Email__c == null) {
                    itemsSummaryByInvoiceId.Email = '';
                } else {
                    itemsSummaryByInvoiceId.Email = zuoraInvoice.Email__c;
                }
                if (zuoraInvoice.Office__c == null) {
                    itemsSummaryByInvoiceId.Office_ID = '';
                } else {
                    itemsSummaryByInvoiceId.Office_ID = zuoraInvoice.Office__c;
                }  
            } else { //zuoraInvoice == null
                itemsSummaryByInvoiceId.Office_ID = myOfficeAccount.Account_Name__c; //mySFSubscription.Related_Location_Broker_Office__c;
                itemsSummaryByInvoiceId.Email = mySFSubscription.Private_email__c;
            }  

            myInvoiceItemsSummariesMappedByInvoiceId.Summaries.put(key, itemsSummaryByInvoiceId);
        }
    }

    private void populateSubscriptionsRelatedToZuroaAccount() {
        List<Zuora.zObject> subscriptionObjects; 

        String subscriptionQueryString = 'SELECT Id, AccountId, AutoRenew, CancelledDate, Name, Notes, Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate, TermType FROM Subscription WHERE AccountId = \'' + this.myInvoiceData.AccountId + '\'';
        System.debug('subscriptionQueryString: ' + subscriptionQueryString);
        subscriptionObjects = callZuora(zOperation.zQuery, subscriptionQueryString);

        if (subscriptionObjects.size() == 0) {
            throw new CustomException('There does not exist any Zuora Subscriptions');
        }

        myZuoraSubscriptionData.QueryString = subscriptionQueryString;
        myZuoraSubscriptionData.AccountId = this.myInvoiceData.AccountId;

        for (Zuora.zObject result: subscriptionObjects) {
            ZuoraSubscription zSubscription = new ZuoraSubscription(result);

            this.myZuoraSubscriptionData.Subscriptions.put(zSubscription.Id, zSubscription);
        }
    }

    private void populateSFSubscription () {
        List<Subscriptions__c> SubscriptionList; // = new List<Subscriptions__c>();

        //The AccountId in question is the one that links back the SF Account, which leads back to the home office
        //of this contact. 
        SubscriptionList = [SELECT id, 
                                   Name, 
                                   Contact__c, CUSTOMERNAME__c, NATIONALACCOUNTID__c, 
                                   Street_Number__c, Street_Name__c, QAS_Mailing_Street_Type__c, QAS_Mailing_Street_Direction__c, QAS_Mailing_Unit_Type__c, Unit__c, Addl_Display_Name__c, City__c, State__c, Zip__c, Zip_4__c, QAS_Mailing_Country__c, 
                                   //(
                                   //     SELECT Name 
                                   //     FROM Subscriptions__c.Contact__r
                                   //)
                                   Private_email__c,
                                   Public_email__c,
                                   Related_Location_Broker_Office__c
            FROM Subscriptions__c
            WHERE Name = :ApexPages.currentPage().getParameters().get('id') AND 
                            Status__c = 'Active'
        ];
        
        //mySFSubscription = new Subscriptions__c(); 
        if (SubscriptionList.size() == 0) throw new CustomException('No Active Subscription Associated With the Subscription ID');
        if (SubscriptionList.size() > 1) throw new CustomException('There should not be more than one Subscription with the same Subscrtipion ID');

        this.mySFSubscription = SubscriptionList[0];  
        
        for (Contact contact: SubscriptionList[0].Contacts__r) {
            this.mySFSubcriptionContact = contact;
        }

        List<Account> AccountList;
        AccountList  = [SELECT id, 
                            Account_Name__c, 
                            Billing_City__c, 
                            Billing_Country__c,
                            Billing_State__c,
                            BrokerAddress__c
                        FROM Account
                        WHERE Id = :this.mySFSubscription.Related_Location_Broker_Office__c 
                        ];
        if (AccountList.size()==0) throw new CustomException('No Office Account is associated with Subscription' + mySFSubscription.Name );
        if (AccountList.size()> 1) throw new CustomException('There are more than 1 Account associated with Subscriptiont' + mySFSubscription.Name);
        this.myOfficeAccount = AccountList[0];   
    }

    private void populateInvoices() {
        this.myInvoiceData.ClearInvoices();

        List<Subscriptions__c> sSubscriptions = [
            SELECT  Id
            FROM    Subscriptions__c 
            WHERE   Name = :this.myInvoiceData.SubscriptionId AND
                    Status__c = 'Active'
        ];
        
        if (sSubscriptions.Size() == 0)
            throw new CustomException('Invalid MRIS Subscription ID'); 

        String accountQuery = 'SELECT Id, AccountNumber, AutoPay, Balance, BillToId, CreatedById, CreatedDate, CreditBalance, Currency, DefaultPaymentMethodId, LastInvoiceDate, Name, Notes, PurchaseOrderNumber, Status, TotalInvoiceBalance, UpdatedById, UpdatedDate FROM Account WHERE Status = \'Active\' AND SubscriptionID__c = \'' + this.myInvoiceData.SubscriptionId + '\'';

        List<Zuora.zObject> account = callZuora(zOperation.zQuery, accountQuery);

        if (account.Size() == 0)
            throw new CustomException('Invalid MRIS Subscription ID');
            
        this.myInvoiceData.AccountId = (String)account[0].getValue('Id');

        this.myZuoraAccountData = new ZuoraAccountData(account[0]);

        List<Zuora.zObject> results;

        //String invoiceQuery = 'SELECT Id, Balance, Comments, DueDate, InvoiceNumber, IncludesOneTime, IncludesRecurring, IncludesUsage, PostedDate, RefundAmount, Status FROM Invoice WHERE AccountId = \'' + this.myInvoiceData.AccountId + '\'';
       
        String invoiceQuery = 'SELECT Id, AccountId, AdjustmentAmount, Amount, AmountWithoutTax, Balance, Comments, CreatedById, CreatedDate, DueDate, IncludesOneTime, IncludesRecurring, IncludesUsage, InvoiceDate, InvoiceNumber, PaymentAmount, PostedDate, RefundAmount, Source, SourceId, Status, TargetDate, TaxAmount, TaxExemptAmount, UpdatedById, UpdatedDate FROM Invoice WHERE AccountId = \'' + this.myInvoiceData.AccountId + '\' AND Status = \'Posted\'';
        //invoiceQuery = invoiceQuery + ' AND CreatedDate > \'' + dateLimits.MinDateString() +'\' AND CreatedDate < \'' + dateLimits.MaxDateString() + '\'';

        myInvoiceData.QueryString = invoiceQuery;
        results = callZuora(zOperation.zQUERY, invoiceQuery);
        
        for (Zuora.zObject result : results) {
            this.myInvoiceData.AddInvoice( new Invoice(result) );
        }
    }
   
    private void populateSFInvoiceObjectByInvoiceId(String InvoiceId) {

        List<Zuora__ZInvoice__c> zuoraInvoices = [
            SELECT 
               Contact_Name__c,
               CreatedById,
               CreatedDate,
               Email__c,
               Id,
               IsDeleted,
               LastModifiedById,
               LastModifiedDate,
               Name,
               Office__c,
               OwnerId,
               State__c,
               SystemModstamp,
               Zuora__Account__c,
               Zuora__AdjustmentAmount__c,
               Zuora__Age_Bucket__c,
               Zuora__AmountWithoutTax__c,
               Zuora__Balance2__c,
               Zuora__Balance__c,
               Zuora__BillingAccount__c,
               Zuora__BillToId__c,
               Zuora__Description__c,
               Zuora__DueDate__c,
               Zuora__External_Id__c,
               Zuora__GeneratedDate__c,
               Zuora__InvoiceDate__c,
               Zuora__PaymentAmount__c,
               Zuora__PaymentTerm__c,
               Zuora__Payment_Term__c,
               Zuora__PostedDate__c,
               Zuora__RefundedAmount__c,
               Zuora__SoldToId__c,
               Zuora__Status__c,
               Zuora__TargetDate__c,
               Zuora__TaxAmount__c,
               Zuora__TaxExemptAmount__c,
               Zuora__TotalAmount__c,
               Zuora__ZuoraId__c,
               Zuora__Zuora_Id__c 
               FROM Zuora__ZInvoice__c WHERE Zuora__External_Id__c = :InvoiceId AND
               Zuora__Status__c = 'Posted' AND
               CreatedDate > :dateLimits.minDate AND
               CreatedDate < :dateLimits.maxDate
            ];
        if (zuoraInvoices.Size() > 1)
            throw new CustomException('There should not exist more than 1 invoices with the same invoice ID'); 
        else if (zuoraInvoices.Size() == 0) {
            //do nothing 
        } else // zuoraInvoice.Size() == 1
        {
            myZuoraInvoiceObjectMappedByInvoiceId.AddZuoraInvoice(zuoraInvoices[0]);
        }
    }

    private void populateInvoiceItemsByInvoiceId(String InvoiceId) {
        String invoiceItemsQuery;

        invoiceItemsQuery = 'SELECT Id, AccountingCode, AppliedToInvoiceItemId, ChargeAmount, ChargeDate, ChargeDescription, ChargeName, ChargeNumber, CreatedById, CreatedDate, InvoiceId, ProcessingType, ProductDescription, ProductId, ProductName, Quantity, RatePlanChargeId, RevRecCode, RevRecTriggerCondition, ServiceEndDate, ServiceStartDate, SubscriptionId, SubscriptionNumber, TaxAmount, TaxCode, TaxExemptAmount, UnitPrice, UOM, UpdatedById, UpdatedDate FROM InvoiceItem WHERE InvoiceId = \'' + InvoiceId + '\'';
        //invoiceItemsQuery = invoiceItemsQuery + ' AND CreatedDate > \'' + dateLimits.MinDateString() +'\' AND CreatedDate < \'' + dateLimits.MaxDateString() + '\'';

        myInvoiceItemData.QueryString = invoiceItemsQuery; 

        System.debug('Invoice Item by Invoice Id Query: ' + invoiceItemsQuery);

        List <Zuora.zObject> results = callZuora(zOperation.zQUERY, invoiceItemsQuery);

        for (Zuora.zObject result: results) {
            InvoiceItem newInvoiceItem = new InvoiceItem(result);
            newInvoiceItem.DetermineLineItemType(this.DiscountProductId);
            this.myInvoiceItemData.InvoiceItems.add(newInvoiceItem);
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
    
    public class ZuoraAccountData {
        //This contains Default Payment methods
        public String Id { get; set; }
        public String AccountNumber { get; set; }
        public Boolean AutoPay { get; set; }
        public Decimal Balance { get; set; }
        public String BillToId { get; set; }
        public String CreatedById { get; set; }
        public DateTime CreatedDate { get; set; }
        public Decimal CreditBalance { get; set; }
        public String CurrencyType { get; set; } // The corresponding field in Zuora is actually "Currency"
        public String DefaultPaymentMethodId { get; set; }
        public DateTime LastInvoiceDate { get; set; }
        public String Name { get; set; }
        public String Notes { get; set; }
        public String PurchaseOrderNumber { get; set; }
        public String Status { get; set; }
        public Decimal TotalInvoiceBalance { get; set; }
        public String UpdatedById { get; set; }
        public DateTime UpdatedDate { get; set; }
        public ZuoraAccountData(Zuora.zObject zAccountData) {
            this.Id = (String) zAccountData.getValue('Id');
            this.AccountNumber = (String) zAccountData.getValue('AccountNumber');
            this.AutoPay = (Boolean) zAccountData.getValue('AutoPay');
            this.Balance = (Decimal) zAccountData.getValue('Balance');
            this.BillToId = (String) zAccountData.getValue('BillToId');
            this.CreatedById = (String) zAccountData.getValue('CreatedById');
            this.CreatedDate = (Date) zAccountData.getValue('CreatedDate');
            this.CreditBalance = (Decimal) zAccountData.getValue('CreditBalance');
            this.CurrencyType = (String) zAccountData.getValue('Currency');
            this.DefaultPaymentMethodId = (String) zAccountData.getValue('DefaultPaymentMethodId');
            this.LastInvoiceDate = (Date) zAccountData.getValue('LastInvoiceDate');
            this.Name = (String) zAccountData.getValue('Name');
            this.Notes = (String) zAccountData.getValue('Notes');
            this.PurchaseOrderNumber = (String) zAccountData.getValue('PurchaseOrderNumber');
            this.Status = (String) zAccountData.getValue('Status');
            this.TotalInvoiceBalance = (Decimal) zAccountData.getValue('TotalInvoiceBalance');
            this.UpdatedById = (String) zAccountData.getValue('UpdatedById');
            this.UpdatedDate = (Date) zAccountData.getValue('UpdatedDate');
        }
    }
    
    public class ZuoraInvoiceObjectMappedByInvoiceId {
        public map<String, Zuora__ZInvoice__c> ZuoraInvoicesMappedByInvoiceId { get; set; }

        public Zuora__ZInvoice__c GetZuoraInvoiceByInvoiceId (String InvoiceId)  { 
            return ZuoraInvoicesMappedByInvoiceId.get(InvoiceId);
        }
        public void ClearZuoraInvoices() {
            ZuoraInvoicesMappedByInvoiceId.clear();
        }
        public void AddZuoraInvoice(Zuora__ZInvoice__c ZuoraInvoice) {
            ZuoraInvoicesMappedByInvoiceId.put(ZuoraInvoice.Zuora__External_Id__c, ZuoraInvoice);
        }
    }

    public class InvoiceData {
        public String AccountId { get; set; }
        public String SubscriptionId { get; set; }
        public String QueryString { get; set; }
        //This is referenced by the Id Parameter of the invoice. 
        public Map<String, Invoice> InvoicesMappedByInvoiceId { get; set; }

        public Boolean InvoiceIdExists(String InvoiceId) {
            return InvoicesMappedByInvoiceId.containsKey(InvoiceId);
        }
        public void AddInvoice(Invoice invoice) {
            InvoicesMappedByInvoiceId.put(invoice.Id, invoice);
        }
        public Invoice GetInvoiceByInvoiceId(String InvoiceId) {
            return InvoicesMappedByInvoiceId.get(InvoiceId);
        }
        public List<Invoice> AllInvoices() {
            return InvoicesMappedByInvoiceId.values();
        }
        public void ClearInvoices() {
            InvoicesMappedByInvoiceId.clear();
        }
    }

    public class Invoice {
        public String Id { get; set; }
        public String AccountId { get; set; }
        public Decimal AdjustmentAmount { get; set; }
        public Decimal Amount { get; set; }
        public Decimal AmountWithoutTax { get; set; }
        public Decimal Balance { get; set; }
        public String Comments {get; set; }
        public String CreatedById { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime DueDate { get; set; }
        public Boolean IncludesOneTime { get; set; }
        public Boolean IncludesRecurring { get; set; }
        public Boolean IncludesUsage { get; set; }
        public DateTime InvoiceDate { get; set; }
        public String InvoiceNumber { get; set; }
        public Decimal PaymentAmount { get; set; }
        public DateTime PostedDate { get; set; }
        public Decimal RefundAmount { get; set; }
        public String Source { get; set; }
        public String SourceId { get; set; }
        public String Status { get; set; }
        public DateTime TargetDate { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal TaxExemptAmount { get; set; }
        public String UpdatedById { get; set; }
        public DateTime UpdatedDate { get; set; }


        public Invoice(Zuora.zObject zInvoice) {
            this.Id = (String) zInvoice.getValue('Id');
            this.AccountId = (String) zInvoice.getValue('AccountId');
            this.AdjustmentAmount = (Decimal) zInvoice.getValue('AdjustmentAmount');
            this.Amount = (Decimal) zInvoice.getValue('Amount');
            this.AmountWithoutTax = (Decimal) zInvoice.getValue('AmountWithoutTax');
            this.Balance = (Decimal) zInvoice.getValue('Balance');
            this.Comments = (String) zInvoice.getValue('Comments');
            this.CreatedById = (String) zInvoice.getValue('CreatedById');
            this.CreatedDate = (Date) zInvoice.getValue('CreatedDate');
            this.DueDate = (Date) zInvoice.getValue('DueDate');
            this.IncludesOneTime = (Boolean) zInvoice.getValue('IncludesOneTime');
            this.IncludesRecurring = (Boolean) zInvoice.getValue('IncludesRecurring');
            this.IncludesUsage = (Boolean) zInvoice.getValue('IncludesUsage');
            this.InvoiceDate = (Date) zInvoice.getValue('InvoiceDate');
            this.InvoiceNumber = (String) zInvoice.getValue('InvoiceNumber');
            this.PaymentAmount = (Decimal) zInvoice.getValue('PaymentAmount');
            this.PostedDate = (Date) zInvoice.getValue('PostedDate');
            this.RefundAmount = (Decimal) zInvoice.getValue('RefundAmount');
            this.Source = (String) zInvoice.getValue('Source');
            this.SourceId = (String) zInvoice.getValue('SourceId');
            this.Status = (String) zInvoice.getValue('Status');
            this.TargetDate = (Date) zInvoice.getValue('TargetDate');
            this.TaxAmount = (Decimal) zInvoice.getValue('TaxAmount');
            this.TaxExemptAmount = (Decimal) zInvoice.getValue('TaxExemptAmount');
            this.UpdatedById = (String) zInvoice.getValue('UpdatedById');
            this.UpdatedDate = (Date) zInvoice.getValue('UpdatedDate');
        }
    } 

    public class InvoiceItemsMappedByInvoiceId {
        public Map<String, List<InvoiceItem>> invoiceItemsMappedByInvoiceId { get; set; }
        //public Map<String, InvoiceItemsSummary> InvoiceItemsSummary { get; set; }
        public InvoiceItemsMappedByInvoiceId() {
            //this.invoiceItemsMappedByInvoiceId = new Map<String, List<InvoiceItem>>();
        }
        public void ClearAllInvoiceItems() {
            this.invoiceItemsMappedByInvoiceId.clear();
        }
        public void AddInvoiceItem(InvoiceItem invoiceItem) {
            String InvoiceId = invoiceItem.InvoiceId;
            List<InvoiceItem> invoiceItemList;
            if (invoiceItemsMappedByInvoiceId.containsKey(InvoiceId)) {
                //Update the corresponding list. 
                invoiceItemList = invoiceItemsMappedByInvoiceId.get(InvoiceId);
                invoiceItemList.add(invoiceItem);
            } else {
                //Add a new list, and update the new list. 
                invoiceItemList = new List<InvoiceItem>();
                invoiceItemList.add(invoiceItem);
                invoiceItemsMappedByInvoiceId.put(InvoiceId, invoiceItemList);
            }
        }
        public boolean InvoiceIdExists(String invoiceId) {
            return invoiceItemsMappedByInvoiceId.containsKey(invoiceId);
        }
    }

    public class InvoiceItemSummary implements Comparable{
        public String ProductId { get; set; }
        public String ProductName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public String StartDateString { get; set; }
        public String EndDateString { get; set; }
        public String Comments { get; set; }
        public Decimal Price { get; set; }
        public SOALineType lineType { get; set; }
        public String SubscriptionID { get; set;}

        public Integer compareTo (Object compareTo) {
            InvoiceItemSummary compareToItemSummary = (InvoiceItemSummary) compareTo;
            if(this.StartDate == compareToItemSummary.StartDate) return 0;
            if(this.StartDate <  compareToItemSummary.StartDate) return 1;
            return -1;
        }
    }

    //This is the Summary object for a single invoice, which would have multiple invoice item objects. 
    //
    public class InvoiceItemsSummaryByInvoiceId {
        public String InvoiceNumber { get; set; }
        public DateTime InvoiceDate { get; set; }
        public String InvoiceDateString { get; set; }
        public String MRIS_ID { get; set; }
        public String Office_ID { get; set; }

        public String BillTo { get; set; }
        public String Email { get; set; }

        public Decimal SubTotal { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal Total { get; set; }

        public List <InvoiceItemSummary> InvoiceItemSummaries { get; set; }

        public void SortInvoiceItemSummaries() {
            this.InvoiceItemSummaries.sort();
        }
    }

    public class InvoiceItemsSummaryBySubIdByInvoiceId {
        public String InvoiceNumber { get; set; }
        public DateTime InvoiceDate { get; set; }
        public String InvoiceDateString { get; set; }
        public String MRIS_ID { get; set; }
        public String Office_ID { get; set; }

        public String BillTo { get; set; }
        public String Email { get; set; }

        public Decimal SubTotal { get; set; }
        public Decimal TaxAmount { get; set; }
        public Decimal Total { get; set; }
        //This invoiceItemSummariesBySubId is mapped by Subscription ID.  
        //multiple Subscription IDs may exist in invoice items in a single invoice.  This 
        public Map<String, InvoiceItemSummariesBySubId> invoiceItemSummariesBySubIdByInvoiceId { get; set; }


        public InvoiceItemsSummaryBySubIdByInvoiceId(InvoiceItemsSummaryByInvoiceId itemsSummaryByInvoiceId, map<String, String> ComplianceFineMap) {
            this.InvoiceNumber = itemsSummaryByInvoiceId.InvoiceNumber;
            this.InvoiceDate = itemsSummaryByInvoiceId.InvoiceDate;
            this.InvoiceDateString = itemsSummaryByInvoiceId.InvoiceDateString;
            this.MRIS_ID = itemsSummaryByInvoiceId.MRIS_ID;
            this.Office_ID = itemsSummaryByInvoiceId.Office_ID;

            this.BillTo = itemsSummaryByInvoiceId.BillTo;
            this.Email = itemsSummaryByInvoiceId.Email;

            this.SubTotal = itemsSummaryByInvoiceId.SubTotal;
            this.TaxAmount = itemsSummaryByInvoiceId.TaxAmount;
            this.Total = itemsSummaryByInvoiceId.Total;

            invoiceItemSummariesBySubIdByInvoiceId = new Map<String, InvoiceItemSummariesBySubId>();

            for(InvoiceItemSummary summary: itemsSummaryByInvoiceId.InvoiceItemSummaries) {
                InvoiceItemSummariesBySubId invoiceItemSummariesBySubId;

                if (ComplianceFineMap.containsKey(summary.ProductId)) {
                    if(!summary.SubscriptionId.contains('CMPFINE')) {
                        summary.SubscriptionId = summary.SubscriptionId + 'CMPFINE';
                    }
                }
                if (invoiceItemSummariesBySubIdByInvoiceId.containsKey(summary.SubscriptionId)) {
                    invoiceItemSummariesBySubId = invoiceItemSummariesBySubIdByInvoiceId.get(summary.SubscriptionId);
                }else {
                    invoiceItemSummariesBySubId = new InvoiceItemSummariesBySubId();
                    invoiceItemSummariesBySubId.SubId = summary.SubscriptionId;
                    invoiceItemSummariesBySubIdByInvoiceId.put(summary.SubscriptionID, invoiceItemSummariesBySubId);
                }
                invoiceItemSummariesBySubId.AddInvoiceItemSummary(summary);
            }
            for (String subId : invoiceItemSummariesBySubIdByInvoiceId.keySet()) {
                InvoiceItemSummariesBySubId invoiceItemSummariesBySubId = null;
                invoiceItemSummariesBySubId = invoiceItemSummariesBySubIdByInvoiceId.get(subId);
                invoiceItemSummariesBySubId.GroupAndSortInvoiceItemSummaries();
            }

        }    
    }

    public class InvoiceItemSummariesBySubId {
        public String SubId { get; set; }
        public Decimal NetPrice { get; private set; }
        public Boolean HasDiscount { get; private set; }
        public Boolean IsActive { get; private set; }
        public List <InvoiceItemSummary> InvoiceItemSummaries { get; private set; }
        public Integer lengthOfSummaries {
            get {
                return InvoiceItemSummaries.size();
            }
        }

        public InvoiceItemSummary KeyInvoice {
            get {

                InvoiceItemSummary retVal = null;
                for (InvoiceItemSummary x : this.InvoiceItemSummaries) {
                    if (x.LineType == SOALineType.SOAInvoiceItemRecurring) {
                        retVal = x;
                    }
                }
                //don't have a recurring item, pick out a one time item
                if (retVal == null) {
                    for (InvoiceItemSummary x: this.InvoiceItemSummaries) {
                        if(x.LineType == SOALineType.SOAInvoiceItemOneTime) {
                            retVal = x;
                        }
                    }
                }
                return retVal;
            }
        }

        public InvoiceItemSummariesBySubId() {
            this.InvoiceItemSummaries = new List<InvoiceItemSummary>();
            this.NetPrice = 0.0;
            this.HasDiscount = false;
        }
        public void AddInvoiceItemSummary(InvoiceItemSummary summary) {
            InvoiceItemSummaries.add(summary);
        }
        //2 operations: 
        //Grouping Invoice Item Summaries by sub groups: one time charge, recurring charge, discounts
        //each groups will be sorted by date.  
        public void GroupAndSortInvoiceItemSummaries() {
            if(this.InvoiceItemSummaries == null) return;

            List <InvoiceItemSummary> onetimeGroup = new List<InvoiceItemSummary>();
            List <InvoiceItemSummary> recurGroup = new List<InvoiceItemSummary>();
            List <InvoiceItemSummary> discountGroup = new List<InvoiceItemSummary> ();

            for(InvoiceItemSummary summary: this.InvoiceItemSummaries) {
                if (summary.lineType == SOALineType.SOAInvoiceItemOneTime) {
                    oneTimeGroup.add(summary);
                }else if(summary.lineType == SOALineType.SOAInvoiceItemRecurring) {
                    recurGroup.add(summary);
                }else if(summary.lineType == SOALineType.SOAInvoiceItemDiscount) {
                    discountGroup.add(summary);
                    this.HasDiscount = true;
                }
            }
            oneTimeGroup.sort();
            recurGroup.sort();
            discountGroup.sort();

            InvoiceItemSummaries.clear();
            InvoiceItemSummaries.addAll(oneTimeGroup);
            InvoiceItemSummaries.addAll(recurGroup);
            InvoiceItemSummaries.addAll(discountGroup);

            this.NetPrice = 0.0;
            for (InvoiceItemSummary summary: this.InvoiceItemSummaries) {
                this.NetPrice = this.NetPrice + summary.Price;
            }
        }
    }

    public class InvoiceItemsSummariesMappedByInvoiceId {
        public map<String, InvoiceItemsSummaryByInvoiceId> Summaries {get; private set;}
        public map<String, InvoiceItemsSummaryBySubIdByInvoiceId> SummariesBySubID { get; private set; }        
    }

    public class InvoiceItemData {
        public String QueryString { set; get; }
        //This is the map for all the invoice items that belong to a particular Invoice. 
        public List<InvoiceItem> InvoiceItems { set; get; }
    }
    
    public class InvoiceItem {
        public String Id { get; set; }
        public String AccountingCode { get; set; }
        public String AppliedToInvoiceItemId { get; set; }
        public Decimal ChargeAmount { get; set; }
        public DateTime ChargeDate { get; set; }
        public String ChargeDescription { get; set; }
        public String ChargeName { get; set; }
        public String ChargeNumber { get; set; }
        public String CreatedById { get; set; }
        public DateTime CreatedDate { get; set; }
        public String InvoiceId { get; set; }
        public Decimal ProcessingType { get; set; }
        public String ProductDescription { get; set; }
        public String ProductId { get; set; }
        public String ProductName { get; set; }
        public Decimal Quantity { get; set; }
        public String RatePlanChargeId { get; set; }
        public DateTime ServiceEndDate { get; set; }
        public DateTime ServiceStartDate { get; set; }
        public String SubscriptionId { get; set; }
        public String SubscriptionNumber { get; set; }
        public Decimal TaxAmount { get; set; }
        public String TaxCode { get; set; }
        public Decimal TaxExemptAmount { get; set; }
        public Decimal UnitPrice { get; set; }
        public String UOM { get; set; }
        public String UpdatedById { get; set; }
        public DateTime UpdatedDate { get; set; }
        public SOALineType lineType { get; set; }

        public InvoiceItem (Zuora.zObject zInvoiceItem) {
            this.Id = (String) zInvoiceItem.getValue('Id');
            this.AccountingCode = (String) zInvoiceItem.getValue('AccountingCode');
            this.AppliedToInvoiceItemId = (String) zInvoiceItem.getValue('AppliedToInvoiceItemId');
            this.ChargeAmount = (Decimal) zInvoiceItem.getValue('ChargeAmount');
            this.ChargeDate = (Date) zInvoiceItem.getValue('ChargeDate');
            this.ChargeDescription = (String) zInvoiceItem.getValue('ChargeDescription');
            this.ChargeName = (String) zInvoiceItem.getValue('ChargeName');
            this.ChargeNumber = (String) zInvoiceItem.getValue('ChargeNumber');
            this.CreatedById = (String) zInvoiceItem.getValue('CreatedById');
            this.CreatedDate = (Date) zInvoiceItem.getValue('CreatedDate');
            this.InvoiceId = (String) zInvoiceItem.getValue('InvoiceId');
            this.ProcessingType = (Decimal) zInvoiceItem.getValue('ProcessingType');
            this.ProductDescription = (String) zInvoiceItem.getValue('ProductDescription');
            this.ProductId = (String) zInvoiceItem.getValue('ProductId');
            this.ProductName = (String) zInvoiceItem.getValue('ProductName');
            this.Quantity = (Decimal) zInvoiceItem.getValue('Quantity');
            this.RatePlanChargeId = (String) zInvoiceItem.getValue('RatePlanChargeId');
            this.ServiceEndDate = (Date) zInvoiceItem.getValue('ServiceEndDate');
            this.ServiceStartDate = (Date) zInvoiceItem.getValue('ServiceStartDate');
            this.SubscriptionId = (String) zInvoiceItem.getValue('SubscriptionId');
            this.SubscriptionNumber = (String) zInvoiceItem.getValue('SubscriptionNumber');
            this.TaxAmount = (Decimal) zInvoiceItem.getValue('TaxAmount');
            this.TaxCode = (String) zInvoiceItem.getValue('TaxCode');
            this.TaxExemptAmount = (Decimal) zInvoiceItem.getValue('TaxExemptAmount');
            this.UnitPrice = (Decimal) zInvoiceItem.getValue('UnitPrice');
            this.UOM = (String) zInvoiceItem.getValue('UOM');
            this.UpdatedById = (String) zInvoiceItem.getValue('UpdatedById');
            this.UpdatedDate = (Date) zInvoiceItem.getValue('UpdatedDate');
        }

        public void DetermineLineItemType (String DiscountProductId) {
            if (this.ServiceStartDate == this.ServiceEndDate) {
                this.lineType = SOALineType.SOAInvoiceItemOneTime;
            }else if (this.ServiceStartDate < this.ServiceEndDate) {
                this.lineType = SOALineType.SOAInvoiceItemRecurring;
            }

            if (this.ProductId.equals(DiscountProductId)) {
                this.lineType = SOALineType.SOAInvoiceItemDiscount;
            }
        }

        public InvoiceItemSummary GenerateInvoiceItemSummary() {
            InvoiceItemSummary summary = new InvoiceItemSummary();
            summary.ProductId = this.ProductId;
            summary.ProductName = this.ProductName;
            summary.StartDate = this.ServiceStartDate;
            summary.StartDateString = this.ServiceStartDate.format('MM/dd/yyyy','GMT');
            summary.EndDate = this.ServiceEndDate;
            summary.EndDateString = this.ServiceEndDate.format('MM/dd/yyyy', 'GMT');
            summary.lineType = this.lineType;
            summary.SubscriptionId = this.SubscriptionId;

            if (this.ChargeDescription != null) {
                summary.Comments = this.ChargeDescription;
            }else {
                summary.Comments = this.ChargeName;
            }
            
            List<String> splittedComments = summary.Comments.split(' // ');
            String combinedComments = String.join(splittedComments, '<br />');
            summary.Comments = combinedComments;
            summary.Price = this.ChargeAmount;

            return summary;
        }
    }

    public class InvoiceItemAdjustmentData {
        public String AccountId {get; set;}
        public String QueryString {get; set;}
        public List<InvoiceItemAdjustment> ItemAdjustments { get; set; }
    }

    public class InvoiceItemAdjustment {
        public String Id { get; set; }
        public DateTime AdjustmentDate { get; set; }
        public String AdjustmentNumber { get; set; }
        public Decimal Amount { get; set; }
        public String CancelledById { get; set; }
        public DateTime CancelledDate { get; set; }
        public String Comment { get; set; }
        public String CreatedById { get; set; }
        public DateTime CreatedDate { get; set; }
        public String CustomerName { get; set; }
        public String CustomerNumber { get; set; }
        public String InvoiceId { get; set; }
        public String InvoiceItemName { get; set; }
        public String ReasonCode { get; set; }
        public DateTime ServiceEndDate { get; set; }
        public DateTime ServiceStartDate { get; set; }
        public String SourceId { get; set; }
        public String Status { get; set; }
        public String TransferredToAccounting { get; set;}
        public String Type { get; set; }
        public String UpdatedById { get; set; }
        public DateTime UpdatedDate { get; set; }

        public InvoiceItemAdjustment (Zuora.zObject zItemAdjustment) {
            this.Id = (String) zItemAdjustment.getValue('Id');
            this.AdjustmentDate = (Date) zItemAdjustment.getValue('AdjustmentDate');
            this.AdjustmentNumber = (String) zItemAdjustment.getValue('AdjustmentNumber');
            this.Amount = (Decimal) zItemAdjustment.getValue('Amount');
            this.CancelledById = (String) zItemAdjustment.getValue('CancelledById');
            this.CancelledDate = (Date) zItemAdjustment.getValue('CancelledDate');
            this.Comment = (String) zItemAdjustment.getValue('Comment');
            this.CreatedById = (String) zItemAdjustment.getValue('CreatedById');
            this.CreatedDate = (Date) zItemAdjustment.getValue('CreatedDate');
            this.CustomerName =  (String) zItemAdjustment.getValue('CustomerName');
            this.CustomerNumber = (String) zItemAdjustment.getValue('CustomerNumber');
            this.InvoiceId = (String) zItemAdjustment.getValue('InvoiceId');
            this.InvoiceItemName = (String) zItemAdjustment.getValue('InvoiceItemName');
            this.ReasonCode = (String) zItemAdjustment.getValue('ReasonCode');
            this.ServiceEndDate = (Date) zItemAdjustment.getValue('ServiceEndDate');
            this.ServiceStartDate = (Date) zItemAdjustment.getValue('ServiceStartDate');
            this.SourceId = (String) zItemAdjustment.getValue('SourceId');
            this.Status = (String) zItemAdjustment.getValue('Status');
            this.TransferredToAccounting = (String) zItemAdjustment.getValue('TransferredToAccounting');
            this.Type = (String) zItemAdjustment.getValue('Type');
            this.UpdatedById = (String) zItemAdjustment.getValue('UpdatedById');
            this.UpdatedDate = (Date) zItemAdjustment.getValue('UpdatedDate');
        }
    }

    public class ZuoraSubscriptionData {
        public String AccountId { get; private set; }
        public String QueryString {get; private set; }

        //using Id of Subscription to map Zuora Subscriptions. 
        public map<String, ZuoraSubscription> Subscriptions{ get; private set;}

        public ZuoraSubscriptionData() {
            Subscriptions = new map<String, ZuoraSubscription>();
        }
    }

    public class ZuoraSubscription {
        public String Id { get; set; }
        public String AccountId { get; set; }
        public Boolean AutoRenew { get; set; }
        public DateTime CancelledDate { get; set; }
        public String Name { get; set; }
        public String Notes { get; set; }
        public String Status { get; set; }
        public DateTime SubscriptionEndDate { get; set; }
        public DateTime SubscriptionStartDate { get; set; }
        public DateTime TermEndDate { get; set; }
        public DateTime TermStartDate { get; set; }
        public String TermType { get; set; }

        public ZuoraSubscription (Zuora.zObject zZuoraSubscription) {
            this.Id = (String) zZuoraSubscription.getValue('Id');
            this.AccountId = (String) zZuoraSubscription.getValue('AccountId');
            this.AutoRenew = (Boolean) zZuoraSubscription.getValue('AutoRenew');
            this.CancelledDate = (Date) zZuoraSubscription.getValue('CancelledDate');
            this.Name = (String) zZuoraSubscription.getValue('Name');
            this.Notes = (String) zZuoraSubscription.getValue('Notes');
            this.Status = (String) zZuoraSubscription.getValue('Status');
            this.SubscriptionEndDate = (Date) zZuoraSubscription.getValue('SubscriptionEndDate');
            this.SubscriptionStartDate = (Date) zZuoraSubscription.getValue('SubscriptionStartDate');
            this.TermEndDate = (Date) zZuoraSubscription.getValue('TermEndDate');
            this.TermStartDate = (Date) zZuoraSubscription.getValue('TermStartDate');
            this.TermType = (String) zZuoraSubscription.getValue('TermType');
        }

        public Boolean IsActive {
            get {
                //System.debug('IsActive Test: SubId: ' + this.Id + ' Status: ' + this.Status);
                return !this.Status.equalsIgnoreCase('cancelled');
            }
        }        
    }

    public class ZuoraInvoiceSummary {
        public String InvoiceId {get; set;}
        public InvoiceItemsSummaryByInvoiceId invoiceSummary { get; private set; }
        public InvoiceItemsSummaryBySubIdByInvoiceId invoiceSummaryBySubId { get; private set; }
        public List<String> invoiceSummaryBySubIdSortOrder {get; private set; }
    }

    //This DateFilter will use EST by default. 
    public class DateFilter {
        public DateTime maxDate { get; private set; }
        public DateTime minDate { get; private set; }
        
        public Integer maxYear { get { return this.maxDate.year(); } }
        public Integer minYear { get { return this.minDate.year(); } }

        public void SetMaxDateToNow() {
            maxDate = DateTime.now();
        }
        public void SetMaxDate (Integer year, Integer month, Integer day)
        {
            maxDate = DateTime.newInstance(year, month, day, 23, 59, 59);
        }
        public void SetMinDate (Integer year, Integer month, Integer day)
        {
            minDate = DateTime.newInstance(year, month, day, 0, 0, 0);
        }

        //This string will be used for search bracketing. 
        public String MaxDateString()
        {
            String retVal = maxDate.format('YYYY-MM-dd', 'America/New_York');
            retVal = retVal + 'T' + '00:00:00'; //maxDate.format('hh:mm:ss', 'America/New_York');
            retVal = retVal + '-05:00';
            System.Debug('MaxDateString: ' + retVal);
            return retVal;
        }

        //This string will be used for search bracketing. 
        public String MinDateString()
        {
            String retVal = minDate.format('YYYY-MM-dd', 'America/New_York');
            retVal = retVal + 'T' + '00:00:00'; //minDate.format('hh:mm:ss', 'America/New_York');
            retVal = retVal + '-05:00';
            System.Debug('MinDateString: ' + retVal);
            return retVal;
        }
    }

    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}