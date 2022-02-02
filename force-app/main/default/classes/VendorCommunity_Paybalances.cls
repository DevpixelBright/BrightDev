public with sharing class VendorCommunity_Paybalances {
    

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
    
    
     public list<SelectOption> options {get; set;}
     public Map<String,String> officeIds { get; set; }
     public String officeId { get; set; } 
     public String recordID {get; set;}
    public String sSubscriptionId {get; set;}
    
    //private Zuora.zApi zApiInstance;
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    public VendorCommunity_Paybalances() {
        id = ApexPages.currentPage().getParameters().get('id');
        initialLoad = true;
        getOfficeDetails(id);
    }
        
    public void initPaymentPortal() {
        initialLoad = false;
        hasError = false;
        hasBalance = true;
                
        try {
            id = ApexPages.currentPage().getParameters().get('id');
            displayName = id;
            String token = getOrderToken(id);
            if (String.isBlank(token)) {
                hasError = true;
            }
            else {
                token = EncodingUtil.urlEncode(token, 'UTF-8');
                iframeDomain = Label.MRIS_SMS_URL.replace('/SMS/', '');
                        
                String path = Label.Vendor_Communities_URL + 'VendorCommunity_Paybalances';        
                path = EncodingUtil.urlEncode(path, 'UTF-8');
                
                iframeUrl = Label.MRIS_SMS_URL + 'SMS_GenericPaymentWrapper?id='+id+ '&type=vendor&token=' + token + '#' + path ;
            }
            
            redirectUrl = Label.Vendor_Communities_URL + 'VendorCommunity_ManageVendor';
            cancelUrl = Label.Vendor_Communities_URL + 'VendorCommunity_PaybalanceTab';
        }
        catch(Exception ex) {
            system.debug('---error--'+ex.getLineNumber()+'--'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            hasError = true;
        }
    }
    
    private String getOrderToken(String id) {
        String zAccountId;     
        try {
            
            system.debug('---id--'+id);
            list<Account> vendorAccounts = [Select Id, Name From Account Where Name =: id];
            
            //zApiInstance = new Zuora.zApi();
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();               
            system.debug('---vendorAccounts-->'+vendorAccounts);
            
            String accountQuery = 'SELECT Id FROM Account WHERE Status = \'Active\' AND CrmID  like  \'' +vendorAccounts[0].id+ '%\' OR ParentId like \''+vendorAccounts[0].id+'%\'';
            List<Zuora.zObject> zAccounts = callZuora(zOperation.zQUERY, accountQuery);
            system.debug('---accounts size-->'+zAccounts.size());
            system.debug('---accountQuery-->'+zAccounts);
            
            if (zAccounts.Size() > 1){
                //hasErrorMessage= true;
                hasbalance = false;
                log('Multiple zuora accounts exist');
                return null;
            }else if (zAccounts.Size() <1){
                //hasErrorMessage= true;
                hasbalance = false;
                log('Zuora Account does not exist');
                return null;
            }
            
            zAccountId = (String)zAccounts[0].getValue('Id');
            generateBaselineInvoice(zAccountId);
            
            String balanceQuery = 'SELECT Balance FROM Account WHERE Id = \'' + zAccountId + '\'';
            List<Zuora.zObject> zAccountBalances = callZuora(zOperation.zQUERY, balanceQuery);
            hasBalance = (Decimal)zAccountBalances[0].getValue('Balance') > 0;
            if (!hasBalance) 
                return null;
            
            
            SMS_Order__c order = new SMS_Order__c();                
            order.Name = 'Order Id';
            order.Token__c = '';
            order.Zuora_Account_Id__c = zAccountId;
            //order.MRIS_Subscription_Id__c = sSubscriptionId;
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
             
            //SMS_ZuoraHistory.createSuccess('VendorCommunity_Paybalances', Id);
            
            return token;
        }
        catch(Exception ex) {
            system.debug('---error--'+ex.getLineNumber()+'--'+ex.getMessage()+ex.getStackTraceString());
            SMS_ZuoraHistory.createError(ex, 'VendorCommunity_Paybalances', Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getStackTraceString()));
            return null;
        }
    }
    
    private void generateBaselineInvoice(String accountId) {
        Zuora.zObject invoice = new Zuora.zObject('Invoice');
        invoice.setValue('AccountId', accountId);
        invoice.setValue('InvoiceDate', DateTime.now().format('yyyy-MM-dd','PST'));
        invoice.setValue('TargetDate', DateTime.now().format('yyyy-MM-dd','PST'));
        
        Zuora.zApi.SaveResult result = callZuora(zOperation.zGENERATE, invoice);
        
        if (result == null) 
            return;
                
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
    
    public void getOfficeDetails(String subname){   
         String accountId = subname;        
        try {
            if (String.isBlank(accountId)) 
                throw new CustomException('Invalid Account ID');            
            
            list<Account> vendorAccounts = [Select Id, Name From Account Where Name =: accountId];
            
            if(vendorAccounts == null || vendorAccounts.size() == 0 ) 
                throw new CustomException('Invalid Vendor ID');
            
            for(Account acc : vendorAccounts) { 
                officeIds.put(acc.Id, acc.Name);
            }
            
            options = new list<SelectOption>();     
            for(String key : officeIds.keySet()){
                    options.add(new SelectOption(key, officeIds.get(key)));               
            }
            
     
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
      public void reloadBrokerages() {
        try {
            System.debug('***officeId'+ officeId);
            recordID = officeId;
            //displayName = officeIds.get(officeId);
            initPaymentPortal();
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        }                  
    }

    public class CustomException extends Exception {}
}