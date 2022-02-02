public class SMS_GenericPaymentBilling {
    private enum zOperation { zCREATE, zUPDATE, zDELETE, zQUERY }
    
    public PaymentMethodData Payment { get; set; }
    
    private Zuora.zApi.LoginResult zLoginResult;
    
    private SMS_ZuoraUtil zUtilInstance;
    
    public SMS_GenericPaymentBilling(String zAccountId) {
        if (String.isBlank(zAccountId)) 
            throw new CustomException('Invalid Parameters - Zuora Account ID Cannot Be Null'); 

        this.Payment = new PaymentMethodData();
        
        this.Payment.AccountId = zAccountId;
        this.Payment.Selected = new PaymentMethod();
        this.Payment.SelectedACH = new LegacyACH();
        this.Payment.PaymentMethods = new List<PaymentMethod>();
        this.Payment.LegacyACHs = new List<LegacyACH>();
        
        this.zUtilInstance = new SMS_ZuoraUtil();
        this.zLoginResult = zUtilInstance.zLogin();        
        //this.zLoginResult = SMS_ZuoraUtil.zlogin(); 
        
        populatePaymentMethods();
        populateLegacyACHs();
    }
    
    public Boolean selectPaymentMethod(String id) {
        this.Payment.Selected = null;
        this.Payment.SelectedACH = null;

        for (PaymentMethod method : this.Payment.PaymentMethods) {
            if (method.Id != id) continue;
            
            this.Payment.Selected = method;

            return true;
        }       

        for (LegacyACH method : this.Payment.LegacyACHs) {
            if (method.Id != id) continue;
            
            this.Payment.SelectedACH = method;

            return true;
        }                   

        return false;
    }

    public void charge(Decimal amount) {
        if (amount <= 0) return;
        
        if (this.Payment.Selected == null && this.Payment.SelectedACH == null) 
            throw new CustomException('No Payment Method Selected');
        
        String Id;
        Boolean IsNew;
        Boolean Save;

        if (this.Payment.Selected != null) {
            Id = this.Payment.Selected.Id;
            IsNew = this.Payment.Selected.IsNew;
            Save = this.Payment.Selected.Save;
        }
        else {
            Id = this.Payment.SelectedACH.Id;
            IsNew = this.Payment.SelectedACH.IsNew;
            Save = this.Payment.SelectedACH.Save;
        }

        Zuora.zObject zPayment = new Zuora.zObject('Payment');
        
        zPayment.setValue('AccountId', this.Payment.AccountId);
        zPayment.setValue('AppliedCreditBalanceAmount', amount);
        zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST'));
        zPayment.setValue('PaymentMethodId', Id);
        zPayment.setValue('Status', 'Processed');
        zPayment.setValue('Type', 'Electronic');
        
        Zuora.zApi.SaveResult result = callZuora(zOperation.zCREATE, zPayment);
        
        if (result == null || String.isBlank(result.Id))
            throw new CustomException('Failure to create payment');
        
        List<Zuora.zObject> payment = callZuora(zOperation.zQUERY, 'SELECT GatewayResponse, Status, ReferenceId FROM Payment WHERE Id = \'' + result.Id + '\'');
        
        if (payment.get(0).getValue('Status') != 'Processed') {
            if (IsNew)
                callZuora(zOperation.zDELETE, 'PaymentMethod', Id);
            
            throw new CustomException((String) payment.get(0).getValue('GatewayResponse'));
        }
        else {
            if (IsNew && !Save)
                callZuora(zOperation.zDELETE, 'PaymentMethod', Id);

            this.Payment.ReferenceId = (String) payment.get(0).getValue('ReferenceId');
        }
    }
    
    public Zuora.zApi.SaveResult applyCreditBalance() {
        List<Zuora.zObject> account = callZuora(zOperation.zQUERY, 'SELECT CreditBalance FROM Account WHERE Id = \'' + this.Payment.AccountId + '\'');
        
        Decimal creditAmount = ((Decimal) account[0].getValue('CreditBalance')) * -1;

        List<Zuora.zObject> zInvoices = callZuora(zOperation.zQUERY, 'SELECT Id, InvoiceDate, Balance FROM Invoice WHERE AccountId = \'' + this.Payment.AccountId + '\' AND Status = \'Posted\' AND Balance != 0');
        
        if (zInvoices.size() == 0) return null;

        Boolean changed = true;
        
        /* 
        Sort all the invoices by their invoice date from oldest to most recent.
        
        While this sorting algorithm might be inefficient, 1) Apex does not offer a native solution to sort based on field, 2) the maximum
        expected number of items in this list is low, and 3) the algorithm is simple.
        */
        while (changed) {
            changed = false;
            
            for (Integer i = 0; i < zInvoices.size(); i++) {
                if (i + 1 == zInvoices.size()) break;
                
                DateTime a = (Date) ((Zuora.zObject) zInvoices.get(i)).getValue('InvoiceDate');
                DateTime b = (Date) ((Zuora.zObject) zInvoices.get(i + 1)).getValue('InvoiceDate');
                
                if (a > b) {
                    zInvoices.add(i, zInvoices.remove(i + 1));
                    changed = true;
                }
            }
        }
        
        List<Zuora.zObject> credits = new List<Zuora.zObject>();  

        for (Integer i = 0; i < zInvoices.size(); i++) {
            Zuora.zObject zInvoice = zInvoices.get(i);

            Decimal amount = (Decimal) zInvoice.getValue('Balance');

            if (amount > 0) continue;

            creditAmount += amount;
            
            Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
          
            adjustment.setValue('SourceTransactionId', zInvoice.getValue('Id'));
            adjustment.setValue('Amount', math.abs(amount));  
            adjustment.setValue('Type', 'Increase');
                
            credits.add(adjustment);
        }

        if (credits.size() > 0)
            callZuora(zOperation.zCREATE, credits);

        List<Zuora.zObject> charges = new List<Zuora.zObject>();  

        for (Integer i = 0; i < zInvoices.size(); i++) {
            Zuora.zObject zInvoice = zInvoices.get(i);

            Decimal amount = (Decimal) zInvoice.getValue('Balance');

            if (amount < 0) continue;
            
            creditAmount += amount;

            Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
          
            adjustment.setValue('SourceTransactionId', zInvoice.getValue('Id'));
            adjustment.setValue('Type', 'Decrease');

            if (creditAmount > amount) break; // There is no credit left
            
            if (creditAmount > 0) // There isn't enough credit available to cover the entirety of this invoice's balance
                amount -= creditAmount;
                
            adjustment.setValue('Amount', amount);  
            
            charges.add(adjustment);
        }
        
        if (charges.size() == 0) return null;
        
        return callZuora(zOperation.zCREATE, charges);
    }

    public Zuora.zApi.SaveResult updateAutoPayPaymentMethod() {
        if (this.Payment.Selected == null && this.Payment.SelectedACH == null) 
            return null;
        
        String Id;
        Boolean IsNew;
        Boolean IsDefault;
        Boolean UseAsDefault;        
        Boolean Save;
        
        system.debug('*** Payment: ' + this.Payment);

        if (this.Payment.Selected != null) {
            Id = this.Payment.Selected.Id;
            IsNew = this.Payment.Selected.IsNew;
            IsDefault = this.Payment.Selected.IsDefault;
            UseAsDefault = this.Payment.Selected.UseAsDefault;
            Save = this.Payment.Selected.Save;
        }
        else {
            Id = this.Payment.SelectedACH.Id;
            IsNew = this.Payment.SelectedACH.IsNew;
            IsDefault = this.Payment.SelectedACH.IsDefault;
            UseAsDefault = this.Payment.SelectedACH.UseAsDefault;
            Save = this.Payment.SelectedACH.Save;
        }
        
        Boolean updateDefaultPaymentMethod = false;

        if ((!IsNew && !IsDefault && UseAsDefault) || (IsNew && Save && UseAsDefault))
            updateDefaultPaymentMethod = true;

        if (!updateDefaultPaymentMethod) return null;
        
        Zuora.zObject accountChanges = new Zuora.zObject('Account');

        accountChanges.setValue('Id', this.Payment.AccountId);
        accountChanges.setValue('AutoPay', true);
        accountChanges.setValue('DefaultPaymentMethodId', Id);

        return callZuora(zOperation.zUPDATE, accountChanges);
    }
    
    private void populatePaymentMethods() {
        this.Payment.PaymentMethods.clear();

        List<Zuora.zObject> account = callZuora(zOperation.zQUERY, 'SELECT DefaultPaymentMethodId FROM Account WHERE Id = \'' + this.Payment.AccountId + '\' AND AutoPay = true');
        
        List<Zuora.zObject> methods = callZuora(zOperation.zQUERY, 'SELECT Id, CreditCardHolderName, CreditCardType, CreditCardMaskNumber, CreditCardExpirationMonth, CreditCardExpirationYear, LastTransactionDateTime FROM PaymentMethod WHERE AccountId = \'' + this.Payment.AccountId + '\' AND Type = \'CreditCard\' AND PaymentMethodStatus = \'Active\'');
        
        for (Zuora.zObject method : methods) {
            PaymentMethod entry = new PaymentMethod();
            
            entry.Id = (String) method.getValue('Id');
            entry.NameOnCard = (String) method.getValue('CreditCardHolderName');
            entry.Type = (String) method.getValue('CreditCardType');
            entry.LastFourDigits = ((String) method.getValue('CreditCardMaskNumber')).replaceAll('[^0-9]', '');
            entry.ExpirationMonth = Integer.valueOf(method.getValue('CreditCardExpirationMonth'));
            entry.ExpirationYear = Integer.valueOf(method.getValue('CreditCardExpirationYear'));
            entry.LastUsed = (DateTime) method.getValue('LastTransactionDateTime');
            entry.IsNew = false;
            entry.IsDefault = account.size() != 0 && account.get(0).getValue('DefaultPaymentMethodId') == entry.Id;
            entry.Save = false;
            entry.UseAsDefault = false;
            
            if (entry.Expiration < DateTime.now()) 
                continue;
            
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

        List<Zuora.zObject> account = callZuora(zOperation.zQUERY, 'SELECT DefaultPaymentMethodId FROM Account WHERE Id = \'' + this.Payment.AccountId + '\' AND AutoPay = true');

        List<Zuora.zObject> methods = callZuora(zOperation.zQUERY, 'SELECT Id, AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, LastTransactionDateTime FROM PaymentMethod WHERE AccountId = \'' + this.Payment.AccountId + '\' AND Type = \'ACH\' AND PaymentMethodStatus = \'Active\'');
        
        for (Zuora.zObject method : methods) {
            LegacyACH entry = new LegacyACH();
            
            entry.Id = (String) method.getValue('Id');
            entry.HolderName = (String) method.getValue('AchAccountName');
            entry.AccountNumber = ((String) method.getValue('AchAccountNumberMask')).replaceAll('[^0-9]', '');
            entry.ABACode = (String) method.getValue('AchAbaCode');
            entry.BankName = (String) method.getValue('AchBankName');
                        
            entry.AccountType = (String) method.getValue('AchAccountType');
            if (entry.AccountType == 'BusinessChecking') entry.AccountType = 'Business Checking';

            entry.LastUsed = (DateTime) method.getValue('LastTransactionDateTime');
            entry.IsNew = false;
            entry.IsDefault = account.size() != 0 && account.get(0).getValue('DefaultPaymentMethodId') == entry.Id;
            entry.Save = false;
            entry.UseAsDefault = false;
            
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
            
        return !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
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
        public String ReferenceId { get; set; }
        public PaymentMethod Selected { get; set; }
        public LegacyACH SelectedACH { get; set; }
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
        public DateTime LastUsed { get; set; }
        public Boolean IsNew { get; set; }
        public Boolean IsDefault { get; set; }
        public String DisplayText {
            get {
                return this.NameOnCard + ' - ' + this.Type + ': ' + this.LastFourDigits + (this.IsDefault ? ' (Default)' : '');
            }
        }
        public Boolean Save { get; set; }
        public Boolean UseAsDefault { get; set; }
    }

    public class LegacyACH {
        public String Id { get; set; }
        public String HolderName { get; set; }
        public String AccountNumber { get; set; }
        public String ABACode { get; set; }
        public String BankName { get; set; }
        public String AccountType { get; set; }
        public DateTime LastUsed { get; set; }
        public Boolean IsNew { get; set; }
        public Boolean IsDefault { get; set; }
        public String DisplayText {
            get {
                return this.HolderName + ' - ' + this.BankName + ': ' + this.AccountNumber + (this.IsDefault ? ' (Default)' : '');
            }
        }
        public Boolean Save { get; set; }
        public Boolean UseAsDefault { get; set; }
    }    

    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}