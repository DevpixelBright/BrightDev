public class Communities_PayBrokerageBalances_Cls {
	
	private enum zOperation { zUPDATE, zGENERATE, zQUERY }
	public Boolean initialLoad { get; private set; }
	public Boolean hasError { get; private set; }
	public Boolean hasBalance { get; private set; }
    public Boolean hasErrorMessage { get; private set; }
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
    
    
	public Communities_PayBrokerageBalances_Cls() {
        id = ApexPages.currentPage().getParameters().get('id');
        initialLoad = true;
        getOfficeDetails(id);
	}
	    
	public void initPaymentPortal() {
		initialLoad = false;
		hasError = false;
		hasBalance = true;
		        
		try {
			
			String token = getOrderToken(id);
			if (String.isBlank(token)) {
				hasError = true;
			}
			else {
				token = EncodingUtil.urlEncode(token, 'UTF-8');
				iframeDomain = Label.MRIS_SMS_URL.replace('/SMS/', '');
				        
				String path = Label.MRIS_Communities_URL + 'Communities_PayBrokerageBalances';        
				path = EncodingUtil.urlEncode(path, 'UTF-8');
				           
				//iframeUrl = Label.MRIS_SMS_URL + 'SMS_GenericPaymentWrapper?token=' + token + '#' + path;
				iframeUrl = Label.MRIS_SMS_URL + 'SMS_GenericPaymentWrapper?id='+id+ '&type=brokerage&token=' + token + '#' + path ;
			}
			
			redirectUrl = Label.MRIS_Communities_URL + 'Communities_Brokerage';
			cancelUrl = Label.MRIS_Communities_URL + 'Communities_Brokerage';
		}
		catch(Exception ex) {
			system.debug('---error--'+ex.getLineNumber()+'--'+ex.getMessage());
			logError(ex.getMessage());
			hasError = true;
		}
	}
	
	private String getOrderToken(String id) {
		String zAccountId;     
		try {
            if (String.isBlank(recordID)) {
                hasErrorMessage= true;
				logError('No data licensing brokerage found');
				return null;
			}
			
			//zApiInstance = new Zuora.zApi();
			zUtilInstance = new SMS_ZuoraUtil();
			zLoginResult = zUtilInstance.zlogin();               
			
			String accountQuery = 'SELECT Id FROM Account WHERE Status = \'Active\' AND CrmID  like  \'' + recordID+ '%\'';
			List<Zuora.zObject> zAccounts = callZuora(zOperation.zQUERY, accountQuery);
            system.debug('---accounts size-->'+zAccounts.size());
			system.debug('---accountQuery-->'+zAccounts);
			
		    if (zAccounts.Size() > 1){
                hasErrorMessage= true;
                hasbalance = false;
                logError('Multiple zuora accounts linked to this brokerage');
				return null;
            }else if (zAccounts.Size() <1){
                hasErrorMessage= true;
                hasbalance = false;
                logError('Zuora Account does not exist');
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
			 
			SMS_ZuoraHistory.createSuccess('Communities_PayBrokerageBalances', sSubscriptionId);
			
			return token;
		}
		catch(Exception ex) {
			system.debug('---error--'+ex.getLineNumber()+'--'+ex.getMessage());
			SMS_ZuoraHistory.createError(ex, 'Communities_PayBrokerageBalances', sSubscriptionId);
            hasbalance = false;
            hasErrorMessage= true;
			logError(ex.getMessage());
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
	
    
    public void getOfficeDetails(String subname){   
         String mSubscriptionId = subname;        
		try {
			if (String.isBlank(mSubscriptionId)) 
				throw new CustomException('Invalid subscription ID');
        
        list<Relationship__c> lstRelations = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
													Subscription__c, Subscription__r.Name, Subscription__r.Contact__r.Name, Broker_Office__r.Name
													FROM Relationship__c
													WHERE Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
													AND ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                    AND  Broker_office__r.type = 'Residential' AND Broker_Office__r.Company_Type__c = 'Broker Office'
                                                    AND  Subscription_ID__c = :mSubscriptionId];
            officeIds = new Map<String,String>();
            if(lstRelations.size() > 0){
               recordID = lstRelations[0].Broker_Office__c;
               sSubscriptionId = lstRelations[0].Subscription__c;
            }else{
                throw new CustomException('No brokerge found');  
            }
            
            
            for(Relationship__c relation : lstRelations) { 
                officeIds.put(relation.Broker_Office__c, relation.Broker_Office__r.Name);
            }
                     
                options = new list<SelectOption>();     
            
            for(String key : officeIds.keySet()){
                    options.add(new SelectOption(key, officeIds.get(key)));               
            }
            
     
        }catch(Exception e){
           logError(e.getMessage()); 
            hasError = true;
        }
    }
    
      public void reloadBrokerages() {
        try {
            System.debug('***officeId'+ officeId);
            recordID = officeId;
			displayName = officeIds.get(officeId);
            initPaymentPortal();
        }
        catch(Exception e) {
            logError(e.getMessage()); 
              hasError = true;            
        }                  
    }
	private void log(String message) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
	}
    private void logError(String message) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
	}
	public class CustomException extends Exception {}
}