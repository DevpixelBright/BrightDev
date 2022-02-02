public class Communities_PayMyBalances_Controller {
    private enum zOperation { zUPDATE, zGENERATE, zQUERY }
    
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public Boolean hasBalance { get; private set; }
    public String id { get; private set; }
    public String iframeDomain { get; private set; }
    public String iframeUrl { get; private set; }
    public String redirectUrl { get; private set; }
    public String cancelUrl { get; private set; }
    public String displayName { get; private set; } // To capture the value for markUserId
    
    
    
    //private Zuora.zApi zApiInstance;
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    public Communities_PayMyBalances_Controller() {
        initialLoad = true;
    }
    
    public void initPaymentPortal() {
        initialLoad = false;
        hasError = false;
        hasBalance = true;
        
        try {
            id = ApexPages.currentPage().getParameters().get('id');
            
            String token = getOrderToken(id);
            
            if (String.isBlank(token)) {
                hasError = true;
            }
            else {
                token = EncodingUtil.urlEncode(token, 'UTF-8');
                
                iframeDomain = Label.MRIS_SMS_URL.replace('/SMS/', '');
                
                String path = Label.MRIS_Communities_URL + 'Communities_PayMyBalances';        
                path = EncodingUtil.urlEncode(path, 'UTF-8');
                
                //iframeUrl = Label.MRIS_SMS_URL + 'SMS_GenericPaymentWrapper?token=' + token + '#' + path;
                iframeUrl = Label.MRIS_SMS_URL + 'SMS_GenericPaymentWrapper?id='+id+'&token=' + token + '#' + path ;
            }
            
            redirectUrl = Label.MRIS_Communities_URL + 'Communities_Subscription';
            cancelUrl = Label.MRIS_Communities_URL + 'Communities_Subscription';
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            hasError = true;
        }
    }
    
    private String getOrderToken(String id) {
        String zAccountId;
        String mSubscriptionId = id;
        String sSubscriptionId;
        
        try {
            if (String.isBlank(mSubscriptionId)) return null;
            
            //zApiInstance = new Zuora.zApi();
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();               
            
            List<Subscriptions__c> sSubscriptions = [
                SELECT  Id, Name, Service_Jurisdiction__c, Billing_Jurisdiction__c, TREND_Login_Name__c,BRIGHT_LoginName__c     
                FROM    Subscriptions__c 
                WHERE   Name = :mSubscriptionId 
            ];
            
            if (sSubscriptions.Size() == 0) return null;
            
            /* Capture display user id for TREND */
            if(sSubscriptions[0].Service_Jurisdiction__c != null && sSubscriptions[0].Service_Jurisdiction__c == 'TREND' && sSubscriptions[0].TREND_Login_Name__c != null)
                displayName = 'TREND: ' + sSubscriptions[0].TREND_Login_Name__c + ' - ' + sSubscriptions[0].Name;
            else if(sSubscriptions[0].Service_Jurisdiction__c != null && sSubscriptions[0].Service_Jurisdiction__c == 'BRIGHT' && sSubscriptions[0].BRIGHT_LoginName__c != null)
                displayName = 'BRIGHT: ' + sSubscriptions[0].BRIGHT_LoginName__c + ' - ' + sSubscriptions[0].Name;
            else
                displayName = sSubscriptions[0].Name;              
            
            String accountQuery = 'SELECT Id FROM Account WHERE Status = \'Active\' AND SubscriptionID__c = \'' + mSubscriptionId + '\'';
            
            List<Zuora.zObject> zAccounts = callZuora(zOperation.zQUERY, accountQuery);
            
            //if (zAccounts.Size() == 0) return null;
            
            if (zAccounts.Size() > 1){
                //hasErrorMessage = true;
                hasbalance = false;
                log('Multiple zuora accounts linked to this brokerage');
                return null;
            }else if (zAccounts.Size() <1){
                //hasErrorMessage = true;
                hasbalance = false;
                log('Zuora Account does not exist');
                return null;
            }
            
            zAccountId = (String)zAccounts[0].getValue('Id');
            
            generateBaselineInvoice(zAccountId);
            
            String balanceQuery = 'SELECT Balance FROM Account WHERE Id = \'' + zAccountId + '\'';
            
            List<Zuora.zObject> zAccountBalances = callZuora(zOperation.zQUERY, balanceQuery);
            
            hasBalance = (Decimal)zAccountBalances[0].getValue('Balance') > 0;
            
            if (!hasBalance) return null;
            
            sSubscriptionId = sSubscriptions[0].Id;
            
            SMS_Order__c order = new SMS_Order__c();                
            order.Name = 'Order Id';
            order.Token__c = '';
            order.Zuora_Account_Id__c = zAccountId;
            order.MRIS_Subscription_Id__c = sSubscriptionId;
            order.Status__c = 'Active';
            order.Bypass_Payment__c = false;
            
            insert order;
            
            String salt = String.valueOf(order.id);
            String secretKey = 'secret_key';
            String algorithmName = 'HmacSHA256';
            
            Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
            string token = EncodingUtil.base64Encode(hmacData);
            
            order.Token__c = token;
            order.Name = order.id;
            update order;
            
            SMS_ZuoraHistory.createSuccess('Communities_PayMyBalances', mSubscriptionId);
            system.debug('mSubscriptionId');
            return token;
        }
        catch(Exception ex) {
            SMS_ZuoraHistory.createError(ex, 'Communities_PayMyBalances', mSubscriptionId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            
            return null;
        }
    }
    
    private void generateBaselineInvoice(String accountId) {
        Zuora.zObject invoice = new Zuora.zObject('Invoice');
        
        invoice.setValue('AccountId', accountId);
        invoice.setValue('InvoiceDate', DateTime.now().format('yyyy-MM-dd','PST'));
        invoice.setValue('TargetDate', DateTime.now().format('yyyy-MM-dd','PST'));
        
        Zuora.zApi.SaveResult result = callZuora(zOperation.zGENERATE, invoice);
        
        if (result == null) return;
        
        invoice = new Zuora.zObject('Invoice');
        
        invoice.setValue('Id', result.Id);
        invoice.setValue('Status', 'Posted');
        
        result = callZuora(zOperation.zUPDATE, invoice);
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
        
        if (operation == zOperation.zUPDATE)
            zSaveResultList = zUtilInstance.zupdate(zObjectList);
        else if (operation == zOperation.zGENERATE)
            zSaveResultList = zUtilInstance.zgenerate(zObjectList);
        else
            throw new CustomException('Illegal Zuora Operation');
        
        return !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
    }  
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    
    public class CustomException extends Exception {}
}