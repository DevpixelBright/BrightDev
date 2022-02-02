public class VendorCommunity_PaymentMethods {
	
  
    private enum zOperation { zCREATE, zUPDATE, zDELETE, zQUERY }
    
    public String id { get; private set; }
    
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public Boolean edited { get; private set; }
    public Boolean editSuccess { get; private set; }
    public String editErrorMessage { get; private set; }
    public String cancelUrl { get; private set; }
    public Boolean loadHPM { get; private set; }
    public String hpmUrl { get; private set; }
    public String paymentSetting { get; set; }
    public String displayName { get; private set; } // To capture the value for markUserId
    public Boolean debugMode { get; private set; }

    public PaymentMethodData Payment { get; set; }
    public list<SelectOption> options {get; set;}
    public String officeId { get; set; } 
     
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    
    private Boolean retainValues;

    public VendorCommunity_PaymentMethods() {
        initialLoad = true;
        edited = false;
        loadHPM = false;
        retainValues = false;

        String debug = ApexPages.currentPage().getParameters().get('debug');
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        cancelUrl = Label.Vendor_Communities_URL + 'VendorCommunity_ManageVendor';
    }
    

    public void initPaymentMethodPortal() {
        initialLoad = false;
        hasError = false;

        try {
            id = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(id)) 
                throw new CustomException('Invalid Account ID'); 
            
            list<Account> vendorAccounts = [Select Id, Name 
                                            From Account 
                                            Where Name =: id
                                           And Type = 'RETS'];
            
			if(vendorAccounts == null || vendorAccounts.size() == 0 ) 
                throw new CustomException('Invalid Vendor ID');
			
			officeId = vendorAccounts[0].id;
			
			system.debug('---officeId-->'+officeId);
			displayName = vendorAccounts[0].Name;
			

			options = new list<SelectOption>();
            for(Account acc : vendorAccounts){
				options.add(new SelectOption(acc.Id, acc.Name));
			}
            
            this.Payment = new PaymentMethodData();
            this.Payment.sfdcAccountId = vendorAccounts[0].Name;
            this.Payment.PaymentMethods = new List<PaymentMethod>();
            this.Payment.LegacyACHs = new List<LegacyACH>();
            
            zUtilInstance = new SMS_ZuoraUtil(); 
            this.zLoginResult = zUtilInstance.zlogin();              
            
            reloadPaymentMethods();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public void reloadPaymentMethods() {
        try {
            edited = false;
            
            populatePaymentMethods();
            populateLegacyACHs();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public void initHPM() {
        try {
            retainValues = false;
            paymentSetting = ApexPages.currentPage().getParameters().get('paymentOption');
            reloadHPM();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public void reloadHPM() {
        try {
            loadHPM = true;

            hpmUrl = generateHpmUrl();
            retainValues = true;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public void removeHPM() {
        loadHPM = false;
    }

    public void updatePaymentMethod() {
        try {
            edited = true;
            editSuccess = true;
            
            Zuora.zObject pmChanges = new Zuora.zObject('PaymentMethod');

            pmChanges.setValue('Id', ApexPages.currentPage().getParameters().get('pmId'));
            pmChanges.setValue('CreditCardExpirationMonth', ApexPages.currentPage().getParameters().get('month'));
            pmChanges.setValue('CreditCardExpirationYear', ApexPages.currentPage().getParameters().get('year'));
            pmChanges.setValue('CreditCardHolderName', ApexPages.currentPage().getParameters().get('name'));
            pmChanges.setValue('CreditCardAddress1', ApexPages.currentPage().getParameters().get('add1'));
            pmChanges.setValue('CreditCardAddress2', ApexPages.currentPage().getParameters().get('add2'));
            pmChanges.setValue('CreditCardCity', ApexPages.currentPage().getParameters().get('city'));
            pmChanges.setValue('CreditCardState', ApexPages.currentPage().getParameters().get('state'));
            pmChanges.setValue('CreditCardPostalCode', ApexPages.currentPage().getParameters().get('zip'));
            
            /* ACH Values */
            pmChanges.setValue('AchBankName', ApexPages.currentPage().getParameters().get('bank'));
           

            Zuora.zApi.SaveResult result = callZuora(zOperation.zUPDATE, pmChanges);
            
            if (!result.Success) {
                editSuccess = false;
                editErrorMessage = '';
                
                Zuora.zObject[] errors = result.Errors;
                Boolean first = true;
                
                for (Zuora.zObject error : errors) {
                    if (first)
                        first = false;
                    else
                        editErrorMessage += '<br />';
                        
                    editErrorMessage += (String)error.getValue('Message');
                }
            }
        }
        catch(Exception ex) {
            editSuccess = false;
            editErrorMessage = ex.getMessage();
        }
    }
    
    public void updateACHPaymentMethod() {
        try {
            edited = true;
            editSuccess = true;
            
            Zuora.zObject pmChanges = new Zuora.zObject('PaymentMethod');

            pmChanges.setValue('Id', ApexPages.currentPage().getParameters().get('pmId'));
            pmChanges.setValue('AchAbaCode', ApexPages.currentPage().getParameters().get('aba'));
            if(ApexPages.currentPage().getParameters().get('type') == 'Business Checking')
                pmChanges.setValue('AchAccountType', 'BusinessChecking');
            else
                pmChanges.setValue('AchAccountType', ApexPages.currentPage().getParameters().get('type'));
            pmChanges.setValue('AchBankName', ApexPages.currentPage().getParameters().get('bank'));
            pmChanges.setValue('AchAccountName', ApexPages.currentPage().getParameters().get('holder'));
            pmChanges.setValue('CreditCardAddress1', ApexPages.currentPage().getParameters().get('address1'));
            pmChanges.setValue('CreditCardAddress2', ApexPages.currentPage().getParameters().get('address2'));
           

            Zuora.zApi.SaveResult result = callZuora(zOperation.zUPDATE, pmChanges);

            if (!result.Success) {
                editSuccess = false;
                editErrorMessage = '';
                
                Zuora.zObject[] errors = result.Errors;
                Boolean first = true;
                
                for (Zuora.zObject error : errors) {
                    if (first)
                        first = false;
                    else
                        editErrorMessage += '<br />';
                        
                    editErrorMessage += (String)error.getValue('Message');
                }
            }
        }
        catch(Exception ex) {
            editSuccess = false;
            editErrorMessage = ex.getMessage() + ApexPages.currentPage().getParameters().get('bank');
        }
    }    

    public void clearDefaultPaymentMethod() {
        try {
            if (String.IsBlank(this.Payment.CheckId)) {
                List<Zuora.zObject> check = callZuora(zOperation.zQUERY, 'SELECT Id FROM PaymentMethod WHERE Type = \'Check\'');
                this.Payment.CheckId = (String)check[0].getValue('Id');
            }
            
            Zuora.zObject accountChanges = new Zuora.zObject('Account');

            accountChanges.setValue('Id', this.Payment.AccountId);
            accountChanges.setValue('AutoPay', false);
            accountChanges.setValue('DefaultPaymentMethodId', this.Payment.CheckId);

            callZuora(zOperation.zUPDATE, accountChanges);
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }

    public void setDefaultPaymentMethod() {
        try {
            String id = ApexPages.currentPage().getParameters().get('pmId');

            Zuora.zObject accountChanges = new Zuora.zObject('Account');

            accountChanges.setValue('Id', this.Payment.AccountId);
            accountChanges.setValue('AutoPay', true);
            accountChanges.setValue('DefaultPaymentMethodId', id);
            
            callZuora(zOperation.zUPDATE, accountChanges);

            reloadPaymentMethods();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }

    public void removeDefaultPaymentMethod() {
        try {
            clearDefaultPaymentMethod();
            reloadPaymentMethods();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }
    
    public void deletePaymentMethod() {
        try {
            String id = ApexPages.currentPage().getParameters().get('pmId');

            Boolean isDefault = false;
            
            for (Integer i = 0; i < this.Payment.PaymentMethods.size(); i++) {
                PaymentMethod x = this.Payment.PaymentMethods.get(i);
                
                if (x.Id == id) {
                    isDefault = x.IsDefault;
                    
                    break;
                }
            }

            for (Integer i = 0; i < this.Payment.LegacyACHs.size(); i++) {
                LegacyACH x = this.Payment.LegacyACHs.get(i);
                
                if (x.Id == id) {
                    isDefault = x.IsDefault;
                    
                    break;
                }
            }
            
            if (isDefault)
                clearDefaultPaymentMethod();
                
            callZuora(zOperation.zDELETE, 'PaymentMethod', id);

            reloadPaymentMethods();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }

    private void populatePaymentMethods() {
        this.Payment.PaymentMethods.clear();

  
        List<Account> lstAccounts = [
            SELECT  Id
            FROM    Account 
            WHERE   Name = :this.Payment.sfdcAccountId AND
                    Status__c = 'Active'
        ];
        
        if (lstAccounts.Size() == 0)
            throw new CustomException('Invalid MRIS Account ID'); 
		
		system.debug('---officeId-->'+officeId);
        String accountQuery = 'SELECT Id, AutoPay, DefaultPaymentMethodId FROM Account WHERE Status = \'Active\' AND CrmID like \'' + officeId + '%\'';
        

        List<Zuora.zObject> account = zUtilInstance.zquery(accountQuery);

        if (account.Size() != 1)
            throw new CustomException('Invalid Account ID');
            
        this.Payment.AccountId = (String)account[0].getValue('Id');
        
        Boolean autoPay = (Boolean)account[0].getValue('AutoPay');
        String defaultPaymentMethodId = (String)account[0].getValue('DefaultPaymentMethodId');
        
        if (!autoPay && String.IsNotBlank(defaultPaymentMethodId) && defaultPaymentMethodId != this.Payment.CheckId)
            clearDefaultPaymentMethod();
        
        List<Zuora.zObject> methods = callZuora(zOperation.zQUERY, 'SELECT Id, CreditCardHolderName, CreditCardType, CreditCardMaskNumber, CreditCardExpirationMonth, CreditCardExpirationYear, CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardState, CreditCardPostalCode, LastTransactionDateTime FROM PaymentMethod WHERE AccountId = \'' + this.Payment.AccountId + '\' AND Type = \'CreditCard\' AND PaymentMethodStatus = \'Active\'');

        for (Zuora.zObject method : methods) {
            PaymentMethod entry = new PaymentMethod();
            
            entry.Id = (String) method.getValue('Id');
            entry.NameOnCard = (String) method.getValue('CreditCardHolderName');
            entry.Type = (String) method.getValue('CreditCardType');
            entry.LastFourDigits = ((String) method.getValue('CreditCardMaskNumber')).replaceAll('[^0-9]+', '********');
            entry.ExpirationMonth = (Integer) method.getValue('CreditCardExpirationMonth');
            entry.ExpirationYear = (Integer) method.getValue('CreditCardExpirationYear');
            entry.Address1 = (String) method.getValue('CreditCardAddress1');
            entry.Address2 = (String) method.getValue('CreditCardAddress2');
            entry.City = (String) method.getValue('CreditCardCity');
            entry.State = (String) method.getValue('CreditCardState');
            entry.PostalCode = (String) method.getValue('CreditCardPostalCode');
            entry.LastUsed = (DateTime) method.getValue('LastTransactionDateTime');

            entry.IsDefault = autoPay && account.get(0).getValue('DefaultPaymentMethodId') == entry.Id;
            entry.HasExpired = entry.Expiration < DateTime.now();
            
            if (this.Payment.PaymentMethods.size() == 0)
                this.Payment.PaymentMethods.add(entry);
            else {  
                for (Integer i = 0; i < this.Payment.PaymentMethods.size(); i++) {
                    PaymentMethod x = this.Payment.PaymentMethods.get(i);
                    
                    if (entry.Expiration > x.Expiration) {
                        this.Payment.PaymentMethods.add(i , entry);
                        
                        break;
                    }
                    
                    if (entry.Expiration == x.Expiration && entry.LastUsed > x.LastUsed) {
                        this.Payment.PaymentMethods.add(i, entry);
                        
                        break;
                    }
                    
                    if (i + 1 == this.Payment.PaymentMethods.size()) {
                        this.Payment.PaymentMethods.add(entry);
                        
                        break;
                    }
                }
            }
        }
    }

    private void populateLegacyACHs() {
        this.Payment.LegacyACHs.clear();

        List<Zuora.zObject> account = callZuora(zOperation.zQUERY, 'SELECT AutoPay, DefaultPaymentMethodId FROM Account WHERE Id = \'' + this.Payment.AccountId + '\'');
        
        Boolean autoPay = (Boolean)account[0].getValue('AutoPay');
        String defaultPaymentMethodId = (String)account[0].getValue('DefaultPaymentMethodId');

        if (!autoPay && String.IsNotBlank(defaultPaymentMethodId) && defaultPaymentMethodId != this.Payment.CheckId)
            clearDefaultPaymentMethod();

        List<Zuora.zObject> methods = callZuora(zOperation.zQUERY, 'SELECT Id, AchAbaCode,CreditCardAddress1, CreditCardAddress2, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, LastTransactionDateTime FROM PaymentMethod WHERE AccountId = \'' + this.Payment.AccountId + '\' AND Type = \'ACH\' AND PaymentMethodStatus = \'Active\'');
        
        for (Zuora.zObject method : methods) {
            LegacyACH entry = new LegacyACH();
            
            entry.Id = (String) method.getValue('Id');
            entry.HolderName = (String) method.getValue('AchAccountName');
            entry.AccountNumber = ((String) method.getValue('AchAccountNumberMask')).replaceAll('[^0-9]+', '********');
            entry.ABACode = (String) method.getValue('AchAbaCode');
            entry.BankName = (String) method.getValue('AchBankName');
            entry.Address1 = (String) method.getValue('CreditCardAddress1');
            entry.Address2 = (String) method.getValue('CreditCardAddress2');
                        
            entry.AccountType = (String) method.getValue('AchAccountType');
            if (entry.AccountType == 'BusinessChecking') entry.AccountType = 'Business Checking';

            entry.LastUsed = (DateTime) method.getValue('LastTransactionDateTime');

            entry.IsDefault = autoPay && account.get(0).getValue('DefaultPaymentMethodId') == entry.Id;
            
            if (this.Payment.LegacyACHs.size() == 0)
                this.Payment.LegacyACHs.add(entry);
            else {  
                for (Integer i = 0; i < this.Payment.LegacyACHs.size(); i++) {
                    LegacyACH x = this.Payment.LegacyACHs.get(i);
                    
                    if (entry.LastUsed > x.LastUsed) {
                        this.Payment.LegacyACHs.add(i, entry);
                        
                        break;
                    }
                    
                    if (i + 1 == this.Payment.LegacyACHs.size()) {
                        this.Payment.LegacyACHs.add(entry);
                        
                        break;
                    }
                }
            }
        }
    }

    private String generateHpmUrl() {
    
        SMS_HPM_Settings__c hpmSettings = new SMS_HPM_Settings__c();
        
        if(paymentSetting.equals('Direct Debit'))
            hpmSettings = SMS_HPM_Settings__c.getAll().get('VendorACHPaymentMethods');
        else
            hpmSettings = SMS_HPM_Settings__c.getAll().get('VendorPaymentMethods');   
        
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
        parameterMap.put('retainValues', String.valueOf(retainValues));
         
        return getHpmUrlBase() + '?method=requestPage&' + toQueryString(parameterMap, true) + '&field_accountId=' + this.Payment.AccountId + '&field_creditCardCountry=USA';       
    }
    
    private String getHpmUrlBase() {
        SMS_HPM_Settings__c hpmSettings = SMS_HPM_Settings__c.getAll().get('MyPaymentMethods');  
        
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
    
    private List<Zuora.zObject> callZuora(zOperation operation, String query) {
        List<Zuora.zObject> zQueryResult;
        
        if (operation != zOperation.zQUERY)
            throw new CustomException('Illegal Zuora Operation');

        zQueryResult = zUtilInstance.zquery(query);
        
        return zQueryResult;
    }
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        return callZuora(operation, new List<Zuora.zObject> { content });
    }  
    
    private Zuora.zApi.SaveResult callZuora(zOperation operation, List<Zuora.zObject> zObjectList) {
        List<Zuora.zApi.SaveResult> zSaveResultList;
        
        if (operation == zOperation.zCREATE)
            zSaveResultList = zUtilInstance.zcreate(zObjectList);
        else if (operation == zOperation.zUPDATE)
            zSaveResultList = zUtilInstance.zupdate(zObjectList);
        else
            throw new CustomException('Illegal Zuora Operation');

        return !zSaveResultList.isEmpty() ? zSaveResultList[0] : null;
    }  

    private List<Zuora.zApi.DeleteResult> callZuora(zOperation operation, String type, String id) {
        List<Zuora.zApi.DeleteResult> zDeleteResults;
        
        if (operation != zOperation.zDELETE)
            throw new CustomException('Illegal Zuora Operation');

        zDeleteResults = zUtilInstance.zdelete(type, new List<String> { id });
            
        return zDeleteResults;
    }  
  
    
    public class PaymentMethodData {
        public String AccountId { get; set; }
        public String sfdcAccountId { get; set; }
        public String CheckId { get; set; }
        public List<PaymentMethod> PaymentMethods { get; set; }
        public List<LegacyACH> LegacyACHs { get; set; }
    }    
    
    public class PaymentMethod {
        public String Id { get; set; }
        public String NameOnCard { get; set; }
        public String Type { get; set; }
        public String LastFourDigits { get; set; }
        public Integer ExpirationMonth { get; set; }
        public Integer ExpirationYear { get; set; }
        public DateTime Expiration {
            get {
                DateTime e = DateTime.newInstance(this.ExpirationYear, this.ExpirationMonth + 1, 1);
                return e.addSeconds(-1);
            }
        }
        public String ExpirationFormated {
            get {
                return this.Expiration.format('MM/yyyy');
            }
        }
        public String Address1 { get; set; }
        public String Address2 { get; set; }
        public Boolean HasAddress2 {
            get {
                return String.isNotBlank(this.Address2);
            }
        }
        public String City { get; set; }
        public String State { get; set; }
        public String PostalCode { get; set; }
        public DateTime LastUsed { get; set; }
        public Boolean IsDefault { get; set; }
        public Boolean HasExpired { get; set; }
    }

    public class LegacyACH {
        public String Id { get; set; }
        public String HolderName { get; set; }
        public String AccountNumber { get; set; }
        public String ABACode { get; set; }
        public String BankName { get; set; }
        public String AccountType { get; set; }
        public DateTime LastUsed { get; set; }
        public String Address1 { get; set; }
        public String Address2 { get; set; }        
        public Boolean IsDefault { get; set; }
    }    
    
    /*private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }*/
     private void logError(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }
    
    public class CustomException extends Exception {}
}