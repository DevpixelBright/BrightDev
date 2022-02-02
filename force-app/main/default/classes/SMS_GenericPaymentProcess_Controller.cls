public class SMS_GenericPaymentProcess_Controller { 
    private enum Steps { LOADING, PREVIEW, EXISTINGPAYMENT, EXISTINGPAYMENTDETAILS, NEWPAYMENT, NEWPAYMENTONLY, CONFIRMATION }
    
    private Map<String, String> ErrorKey = new Map<String, String> {
        'errorField_creditCardType'             =>  'Card Type', 
            'errorField_creditCardNumber'           =>  'Card Number', 
            'errorField_creditCardExpirationMonth'  =>  'Expiration Month', 
            'errorField_creditCardExpirationYear'   =>  'Expiration Year', 
            'errorField_cardSecurityCode'           =>  'CVV',
            'errorField_creditCardHolderName'       =>  'Cardholder Name',
            'errorField_creditCardPostalCode'       =>  'Postal Code'
            };
                
                private Map<String, String> ErrorValue = new Map<String, String> {
                    'NullValue'                             =>  'is missing',
                        'InvalidFormat'                         =>  'is invalid',
                        'ExceededMaxLength'                     =>  'is too long'
                        };
                            
                            public SMS_GenericPaymentProcess_Controller self { get { return this; } }
    
    public Boolean showLoading { get; set; }
    public Boolean showPreview { get; set; }
    public Boolean showPaymentOptions { get; set; }
    public Boolean showExistingPayment { get; set; }
    public Boolean showExistingPaymentDetails { get; set; }
    public Boolean showNewPayment { get; set; }
    public Boolean showConfirmation { get; set; }
    public Boolean selectedCredit { get { return Payment.Selected != null; } }
    public Boolean selectedACH { get { return Payment.SelectedACH != null; } }
    public Boolean showSavePayment{get; set;}
    
    public Boolean debugMode { get; private set; }
    public Boolean previewOnlyMode { get { return Invoicing.hasDraftInvoices; } }
    
    public Boolean hasError { 
        get {
            return  this.hasCreateNewPaymentMethodError || 
                this.hasChargeNewPaymentMethodError ||
                this.hasUnspecifiedError;
        }
    }
    
    public String getError { 
        get {
            String e = '';
            String x;
            
            x = this.getCreateNewPaymentMethodError;
            
            if (String.isNotBlank(x))
                e += (String.isNotBlank(e) ? '<br />' : '') + x;
            
            x = this.getChargeNewPaymentMethodError;
            
            if (String.isNotBlank(x))
                e += (String.isNotBlank(e) ? '<br />' : '') + x;
            
            x = this.getUnspecifiedError;
            
            if (String.isNotBlank(x))
                e += (String.isNotBlank(e) ? '<br />' : '') + x;
            
            return e;
        }
    }
    
    public Boolean hasCreateNewPaymentMethodError { get; set; }
    public String getCreateNewPaymentMethodError { get; set; }
    
    public Boolean hasChargeNewPaymentMethodError { get; set; }
    public String getChargeNewPaymentMethodError { get; set; }
    
    public Boolean hasUnspecifiedError { get; set; }
    public String getUnspecifiedError { get; set; }
    
    public Boolean manuallyChargePayment { get; set; }
    public Boolean finalizeOrder { get; set; }
    public Boolean checkForBaselineInvoice { get; set; }
    
    public String hpmUrl { get; set; }
    
    public SMS_GenericPaymentInvoicing.InvoiceData Invoice { get { return Invoicing.Invoice; } }
    public SMS_GenericPaymentBilling.PaymentMethodData Payment { get { return Billing.Payment; } }
    
    private SMS_GenericPaymentInvoicing Invoicing { get; set; } 
    private SMS_GenericPaymentBilling Billing { get; set; } 
    private List<SMS_Order__c> Orders { get; set; }
    
    private Boolean paymentPageLoaded { get; set; }
    
    private Zuora.zApi zApiInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    
    public SMS_GenericPaymentProcess_Controller() {
        try {
            
            String debug = ApexPages.currentPage().getParameters().get('debug');
            
            debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
            
            clearErrors();
            
            String token = ApexPages.CurrentPage().getParameters().get('token');
            
            if (String.isBlank(token))
                throw new CustomException('Invalid Request');
            
            this.manuallyChargePayment = false;
            this.checkForBaselineInvoice = false;
            this.paymentPageLoaded = false;
            
            setStep(Steps.LOADING);
            
            this.zApiInstance = new Zuora.zApi();  
            
            this.Orders = [
                SELECT  Id,
                Zuora_Account_Id__c,
                MRIS_Subscription_Id__r.Status__c, 
                Bypass_Payment__c,
                (
                    SELECT  Bundle_Id__c,
                    Bundle_Name__c,
                    Zuora_Product_Id__c,
                    Zuora_Product_Name__c,
                    OneTimeProductRatePlanId__c,
                    OneTimeProductRatePlanName__c,
                    RecurringProductRatePlanId__c,
                    RecurringProductRatePlanName__c,
                    DiscountProductRatePlanId__c,
                    DiscountProductRatePlanName__c,
                    TermDuration__c,
                    IsCore__c,
                    Initial_Term__c,
                    Renewal_Term__c,
                    Service_Activation_Date__c,
                    Contract_Effective_Date__c
                    FROM    SMS_OrderItems__r
                )
                FROM    SMS_Order__c 
                WHERE   Token__c = :token AND 
                Status__c = 'Active'
            ];
            
            if (this.Orders.size() == 0) throw new CustomException('No Active Orders Associated With Token');
            
            SMS_GenericPaymentInvoicing.InputData data = new SMS_GenericPaymentInvoicing.InputData();
            
            data.OrderId = this.Orders[0].Id;
            data.AccountId = this.Orders[0].Zuora_Account_Id__c;
            data.BypassPayment = this.Orders[0].Bypass_Payment__c;
            if(this.Orders[0].MRIS_Subscription_Id__r.Status__c == 'Inactive'){
                showSavePayment = false;
            }else{
                showSavePayment = true; 
            }
            
            for (SMS_OrderItem__c oi : this.Orders[0].SMS_OrderItems__r) {
                SMS_GenericPaymentInvoicing.InputItem i = new SMS_GenericPaymentInvoicing.InputItem();
                
                i.BundleId = oi.Bundle_Id__c;
                i.BundleName = oi.Bundle_Name__c;
                i.ProductId = oi.Zuora_Product_Id__c;
                i.ProductName = oi.Zuora_Product_Name__c;
                i.OneTimeProductRatePlanId = oi.OneTimeProductRatePlanId__c;
                i.OneTimeProductRatePlanName = oi.OneTimeProductRatePlanName__c;
                i.RecurringProductRatePlanId = oi.RecurringProductRatePlanId__c;
                i.RecurringProductRatePlanName = oi.RecurringProductRatePlanName__c;
                i.DiscountProductRatePlanId = oi.DiscountProductRatePlanId__c;
                i.DiscountProductRatePlanName = oi.DiscountProductRatePlanName__c;
                i.TermDuration = Integer.valueOf(oi.TermDuration__c);
                i.IsCore = Boolean.valueOf(oi.IsCore__c);
                
                i.ServiceActivationDate = oi.Service_Activation_Date__c.format('yyyy-MM-dd','PST');
                i.ContractEffectiveDate = oi.Contract_Effective_Date__c.format('yyyy-MM-dd','PST');
                i.InitialTerm = Integer.valueOf(oi.Initial_Term__c);
                i.RenewalTerm = Integer.valueOf(oi.Renewal_Term__c);
                
                data.Contents.add(i);
            }
            
            this.Invoicing = new SMS_GenericPaymentInvoicing(data);            
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            setStep(Steps.PREVIEW);
        }   
    }
    
    public void clearErrors() {
        this.hasCreateNewPaymentMethodError = false;
        this.getCreateNewPaymentMethodError = '';
        
        this.hasChargeNewPaymentMethodError = false;
        this.getChargeNewPaymentMethodError = '';
        
        this.hasUnspecifiedError = false;
        this.getUnspecifiedError = '';
    }
    
    public PageReference previewInvoice() {
        try {
            clearErrors();
            
            this.Invoicing.previewInvoice();
            
            setStep(Steps.PREVIEW);
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }  
    
    public PageReference loadPreviewPage() {
        try {
            clearErrors();
            
            setStep(Steps.PREVIEW);
            
            PageReference page;
            
            page = new PageReference('/apex/SMS_GenericPaymentProcess');
            page.setRedirect(false);
            
            return page;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }   
    }
    
    public PageReference loadPaymentPage() {
        try {
            clearErrors();
            
            setStep(Steps.LOADING);
            
            if (!this.paymentPageLoaded) {
                this.Billing = new SMS_GenericPaymentBilling(this.Invoice.AccountId);           
                this.paymentPageLoaded = true;
            }
            
            if ((this.Payment.PaymentMethods.size() + this.Payment.LegacyACHs.size()) == 0)
                setStep(Steps.NEWPAYMENTONLY);
            
            PageReference page;
            
            if (this.Invoice.BalanceDue > 0 && !this.Invoice.BypassPayment) {
                this.hpmUrl = generateHpmUrl();
                
                page = new PageReference('/apex/SMS_GenericPayment_HPM');
                page.setRedirect(false);
            }
            else
                page = completeOrder();
            
            return page;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            setStep(Steps.PREVIEW);
            
            return null;
        }   
    }
    
    public PageReference chooseExistingPaymentMethod() {
        setStep(Steps.EXISTINGPAYMENT);
        return null;
    }
    
    public PageReference enterNewPaymentMethod() {
        setStep(Steps.NEWPAYMENT);
        
        return null;
    }
    
    public PageReference selectPaymentMethod() {
        try {
            clearErrors();
            
            if (this.Billing.selectPaymentMethod(Apexpages.currentPage().getParameters().get('id')))
                setStep(Steps.EXISTINGPAYMENTDETAILS);
            else
                setStep(Steps.EXISTINGPAYMENT);
            
            return null;
        }
        catch(Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }  
    
    public PageReference chargePayment() {
        try {
            clearErrors();
            
            if (!this.manuallyChargePayment) {
                Boolean d = Boolean.valueOf(Apexpages.currentPage().getParameters().get('use_as_default'));
                
                if (Payment.Selected != null)
                    Payment.Selected.UseAsDefault = d;
                else
                    Payment.SelectedACH.UseAsDefault = d;
            }
            
            this.manuallyChargePayment = false;
            
            this.Billing.charge(this.Invoice.BalanceDue); 
            this.Invoice.AmountPaid = this.Invoice.BalanceDue;
            
            this.finalizeOrder = true;
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            this.showExistingPaymentDetails = false;
            
            return null;
        }
    }  
    
    public PageReference chargeNewPaymentMethod() {
        try {
            clearErrors();
            
            this.Payment.Selected = new SMS_GenericPaymentBilling.PaymentMethod();
            
            this.Payment.Selected.Id = Apexpages.currentPage().getParameters().get('id');
            this.Payment.Selected.IsNew = true;
            this.Payment.Selected.Save = Boolean.valueOf(Apexpages.currentPage().getParameters().get('save'));
            this.Payment.Selected.UseAsDefault = this.Payment.Selected.Save && Boolean.valueOf(Apexpages.currentPage().getParameters().get('use_as_default'));
            
            this.manuallyChargePayment = true;
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            system.debug('******************Exception *******************'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }
    
    public PageReference completeOrder() {
        try {
            clearErrors();
            
            this.finalizeOrder = false;
            
            setStep(Steps.LOADING);
            
            this.Invoicing.commitInvoice();
            
            markOrderAsPaid();
            
            PageReference page = new PageReference('/apex/SMS_GenericPayment_Success');
            page.setRedirect(false);
            
            return page;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }
    
    public PageReference paymentMethodFailed() {
        clearErrors();
        
        this.hasCreateNewPaymentMethodError = true;
        
        String error = Apexpages.currentPage().getParameters().get('message');
        String text = '';
        
        List<String> es = error.split('<br>', 0);
        
        try {
            String code = es.get(0).split('=', 0).get(1);
            
            String mssg = es.get(1).split('=', 0).get(1);
            
            if (code == 'HostedPageFieldValidationError') {
                for (Integer i = 2; i < es.size(); i++) {
                    List<String> kv = es.get(i).split('=', 0);
                    
                    String k = this.ErrorKey.get(kv.get(0));
                    if (k == null) k = kv.get(0);
                    
                    String v = this.ErrorValue.get(kv.get(1));
                    if (v == null) v = kv.get(1);
                    
                    text += (String.isNotBlank(text) ? '<br />' : '') + '<b>' + k + '</b> ' + v + '.';
                }
            }
            else if (code == 'GatewayTransactionError') {
                text = 'Your transaction cannot be completed as entered. Please check with your financial institution and try again.';
            }
            else if (code == 'Invalid_Security') {
                text = 'Your session has been terminated for security reasons. Please refresh the page and try again.';
            }
            else {
                text = mssg;
            }
        }
        catch (Exception e) {
            text = error;
        }
        
        this.getCreateNewPaymentMethodError = text;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
        
        return null;
    }
    
    public PageReference updateAutoPayPaymentMethod() {
        try {
            clearErrors();
            
            this.Billing.updateAutoPayPaymentMethod();
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }  
    
    public void markOrderAsPaid() {
        successOnDemandSync(this.Invoice.AccountId);
        this.Orders[0].Status__c = 'Completed';
        this.Orders[0].Reference_Id__c = this.Payment.ReferenceId;
        this.Orders[0].Amount_Due__c = this.Invoice.BalanceDue;
        this.Orders[0].Amount_Collected__c = this.Invoice.AmountPaid;
        update this.Orders[0];
        
        SMS_BadWorkflowMitigation.updateStatusChangeFee(this.Invoice.OrderId);
        
        
        
    }
    
    public void markOrderAsCancelled() {
        this.Orders[0].Status__c = 'Cancelled';
        update this.Orders[0];
    }
    public void successOnDemandSync(String zAccountsId){
        
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        
        syncManager.emailNotificationEnabled = false;
        syncManager.syncZuoraObjectIdSet = new set<String>{zAccountsId};               
        
        List<Zuora.SyncResult> syncResults = syncManager.sendRequest();
        for(Zuora.SyncResult syncResult : syncResults){
            system.debug(syncResult);
        }
    }
    
    public PageReference generateBaselineInvoice() {
        try {
            clearErrors();
            
            this.Invoicing.generateBaselineInvoice();
            
            this.checkForBaselineInvoice = true;
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }  
    
    public PageReference confirmBaselineInvoice() {
        try {
            clearErrors();
            
            this.checkForBaselineInvoice = true;
            
            if (Invoicing.confirmBaselineInvoice()) {
                this.checkForBaselineInvoice = false;
                
                this.Billing.applyCreditBalance();
                
                setStep(Steps.CONFIRMATION);
            }
            
            return null;
        }
        catch (Exception e) {
            this.hasUnspecifiedError = true;
            this.getUnspecifiedError = e.getMessage();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.getUnspecifiedError)); 
            
            return null;
        }
    }  
    
    public PageReference printReceipt() {
        PageReference printPage = new PageReference('/apex/SMS_GenericPayment_Print');
        printPage.setRedirect(false);
        
        return printPage;
    } 
    
    private String generateHpmUrl() {
        SMS_HPM_Settings__c hpmSettings = SMS_HPM_Settings__c.getAll().get('Default');
        
        String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        
        Map<String, String> parameterMap = new Map<String, String> {
            'id' => hpmSettings.Page_ID__c,
                'tenantId' => hpmSettings.Tenant_ID__c,
                'timestamp' => String.valueOf(DateTime.now().getTime()),
                'token' => token + hpmSettings.API_Security_Key__c
                };
                    
                    String queryParametersToHash = toQueryString(parameterMap, false);
        String queryParametersMd5Hash = EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryParametersToHash)))));
        
        String signature = queryParametersMd5Hash.replace('+', '/').replace('-', '_');
        
        parameterMap.put('token', token);
        parameterMap.put('signature', signature);
        parameterMap.put('retainValues', 'true');
        
        return getHpmUrlBase() + '?method=requestPage&' + toQueryString(parameterMap, true) + '&field_accountId=' + this.Invoice.AccountId + '&field_creditCardCountry=USA';
    }
    
    private String getHpmUrlBase() {
        SMS_HPM_Settings__c hpmSettings = SMS_HPM_Settings__c.getAll().get('Default');  
        
        return hpmSettings.Domain__c + '/PublicHostedPage.do'; 
    }
    
    private String toQueryString(Map<String, String> parameterMap, Boolean urlEncoded) {
        List<String> parameters = new List<String>();
        
        for (String key : parameterMap.keySet()) {
            if (urlEncoded)
                parameters.add(key + '=' + EncodingUtil.urlEncode(parameterMap.get(key), 'UTF-8'));        
            else
                parameters.add(key + '=' + parameterMap.get(key));
        }
        
        return String.join(parameters, '&');
    }
    
    private void setStep(Steps step) {
        this.showLoading = step == Steps.LOADING;
        this.showPreview = step == Steps.PREVIEW;
        this.showPaymentOptions = step != Steps.NEWPAYMENTONLY;
        this.showExistingPayment = step == Steps.EXISTINGPAYMENT || step == Steps.EXISTINGPAYMENTDETAILS; 
        this.showExistingPaymentDetails = step == Steps.EXISTINGPAYMENTDETAILS; 
        this.showNewPayment = step == Steps.NEWPAYMENT || step == Steps.NEWPAYMENTONLY;
        this.showConfirmation = step == Steps.CONFIRMATION;
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    public class CustomException extends Exception {}
}