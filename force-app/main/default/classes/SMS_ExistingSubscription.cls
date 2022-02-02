public class SMS_ExistingSubscription {

    public String mrisSubscription { get; set; }
    public String accId { get; set; }
    public String accName { get; set; }
    public String zAccId { get; set; }
    public String zAccName { get; set; }
    public String zSubNumber { get; set; }
    
    public Boolean personAccountStatus { get; set; }
    public String personAccountState { get; set; }
    public String personAccountLable { get; set; }

    public Boolean zuoraAccountStatus { get; set; }
    public String zuoraAccountState { get; set; }
    public String zuoraAccountLable { get; set; } 
    
    public Boolean zuoraSubStatus1 { get; set; } 
    public Boolean zuoraSubStatus2 { get; set; } 
    public String zuoraSubState { get; set; }
    public String zuoraSubLable { get; set; }       
    
    public String CFDate { get; set; }
    public String SADate { get; set; }
    public Boolean autoRenew { get; set; }
    
    public List<Subscriptions__c> subscription { get; set;}
    public List<Account> acc { get; set;}
    private static SMS_ZuoraUtil zUtilInstance;
    private Static Zuora.zApi.SaveResult zSaveResult;    
    
    public SMS_ExistingSubscription() {
        defaultValues();
    }
    
    public void defaultValues() {
        accName = '';
        
        personAccountStatus = false;
        personAccountState = 'disabled';
        personAccountLable = 'primary';
        
        zuoraAccountStatus = false;
        zuoraAccountState = 'disabled';
        zuoraAccountLable = 'primary'; 
        
        zuoraSubStatus1 = false;
        zuoraSubStatus2 = false;
        zuoraSubState = 'disabled'; 
        zuoraSubLable = 'primary';      

        CFDate = Datetime.Now().format('yyyy-MM-dd','PST');
        SADate = Datetime.Now().format('yyyy-MM-dd','PST');
        autoRenew = false; 
        System.debug('*** resetted default values');   
    }
    
    public PageReference verifySubscription() {
        defaultValues();
        try {
            if(String.isNotBlank(mrisSubscription)) {
                subscription = new List<Subscriptions__c>();
                subscription = [SELECT Id, Name, Contact__c, Status__c, Contact__r.Contact_Key__c FROM Subscriptions__c WHERE Name = :mrisSubscription]; 
                
                if(subscription.Size() == 1) {
                    acc = new List<Account>();
                    acc = [SELECT Id, Name, Contact__c FROM Account WHERE Contact__c = :subscription[0].Contact__c];
                    if(acc.Size() > 0) {
                        accName = acc[0].Name;
                        accId = acc[0].Id;
                        personAccountLable = 'primary';                        
                    }
                    else {
                        createPersonAccount();
                        personAccountLable = 'success';                                              
                    }
                    
                    personAccountStatus = true;
                    personAccountState = 'complete';
                }
                else
                    personAccountState = 'Invalid MRIS Subscription Id';           
            }
            else
               personAccountState = 'Please enter MRIS Subscription Id';
        }
        catch(Exception e) {
            personAccountState = e.getMessage();
        } 
          
        return null;
    }
    
    public PageReference createZuoraSubscription() {
        try {
        
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();        
        
            /* subscription details */
            Subscriptions__c sub = [SELECT Id, Contact_Type__c, Subscription_Type__c, Date_Terminated__c, Primary__c, Contact__c, Status__c, Name, Billing_Jurisdiction__c FROM Subscriptions__c WHERE Name = :mrisSubscription];
            
            /* Zuora account details */
            String zAccountsQuery = 'SELECT Id, ParentId FROM Account WHERE SubscriptionID__c = \'' + sub.Name + '\'';                       
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
            System.debug('***' + zAccountsQuery);
            if (zAccounts.Size() == 1) {
                String zChildAccountId = (String)zAccounts[0].getValue('Id');
                
                if(String.isBlank(sub.Billing_Jurisdiction__c))
                    sub.Billing_Jurisdiction__c = 'MRIS';
                
                List<SMS_CoreMapping__c> productRatePlans = [
                    SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c, Term_Duration__c
                    FROM   SMS_CoreMapping__c
                    WHERE  Type__c = :sub.Contact_Type__c
                    AND    SubType__c = :sub.Subscription_Type__c
                    AND    Status__c = 'New'
                    AND    IsPrimaryFlag__c = :sub.Primary__c
                    AND    Billing_Jurisdiction__c = :sub.Billing_Jurisdiction__c];
                
                if(productRatePlans.Size() > 0  && String.isNotBlank(productRatePlans[0].ZuoraRecurringProductRatePlanId__c)) {
                    String termDuration = String.valueOf(productRatePlans[0].Term_Duration__c);
                    List<String> zProductRatePlanIds = new List<String>();
                    zProductRatePlanIds.add(productRatePlans[0].ZuoraRecurringProductRatePlanId__c);
                    
                    if(String.IsNotBlank(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c))
                        zProductRatePlanIds.add(productRatePlans[0].ZuoraOnetimeProductRatePlanId__c); 
                    

                    String effectiveDate = CFDate;// + 'T00:00:00';  
                    String serviceActivationDate = SADate;// + 'T00:00:00';    
                    
                    Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
                    
                    request.ZAccount = new Zuora.zObject('Account');
                    request.ZAccount.setValue('Id', zChildAccountId);
                    
                    request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
                    request.SubscribeOptions.GenerateInvoice = true;
                    request.SubscribeOptions.ProcessPayments = false;
                    
                    request.PreviewOptions = new Zuora.zApi.PreviewOptions();
                    request.PreviewOptions.EnablePreviewMode = false;
                    
                    request.SubscriptionData = new Zuora.zApi.SubscriptionData();
                    
                    Zuora.zObject subscription = new Zuora.zObject('Subscription');
                    subscription.setValue('ContractEffectiveDate', serviceActivationDate);
                    subscription.setValue('ServiceActivationDate', serviceActivationDate);
                    subscription.setValue('TermType', 'TERMED');
                    subscription.setValue('InitialTerm', termDuration);
                    subscription.setValue('RenewalTerm', termDuration);
                    subscription.setValue('AutoRenew', autoRenew);
                    subscription.setValue('IsCore__c', true);
                    
                    request.SubscriptionData.Subscription = subscription;
                    List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
                    for (String zProductRatePlanId : zProductRatePlanIds) {
                        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
                        
                        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                        ratePlanData.setValue('RatePlan', ratePlan);
                        ratePlanDataList.add(ratePlanData);
                    }
                    
                    request.SubscriptionData.RatePlanData = ratePlanDataList; 
                     
                    List<Zuora.zApi.SubscribeRequest> requestList = new List<Zuora.zApi.SubscribeRequest>();
                    requestList.add(request);
                    System.debug('*** requestList' + requestList);
                    List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(requestList);
                    System.debug('*** results ' + results );
                    for (Zuora.zApi.SubscribeResult result : results) {
                        if (result.Success) {
                            zuoraSubStatus1 = false;
                            zuoraSubStatus2 = true;
                            zuoraSubState = 'complete'; 
                            zSubNumber = result.SubscriptionNumber;
                            zuoraSubLable = 'success';
                        } 
                        else {
                            throw new CustomException('Failed to create zuora subscription');                      
                        }                           
                    }           
                }
                else
                    throw new CustomException('Product core mapping does not exist.');
                
            }
            else
                throw new CustomException('Zuora child account does not exist');
            
        }
        catch(Exception e) {
            zuoraSubState = 'Zuora Subscription: ' + e.getMessage() + e.getStackTraceString();
        }        
        return null;
    }
    
    public void createZuoraAccounts() {
        try {
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
            
            String zAccountsQuery = 'SELECT Id, ParentId, Name FROM Account WHERE SubscriptionID__c = \'' + subscription[0].Name + '\'';                       
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
            if (zAccounts.Size() > 0) { 
                zuoraAccountLable = 'primary';
                zAccName = (String)zAccounts[0].getValue('Name');
                zAccId = (String)zAccounts[0].getValue('Id');
                verifyZuoraSubscription();    
            } 
            else {
                String status = SMS_ZuoraAccountsCreation.createParentOrChildAccount(subscription[0].Id);
                
                if(status == 'success') {
                    zAccounts = zUtilInstance.zquery(zAccountsQuery);
                    zuoraAccountLable = 'success';
                    if (zAccounts.Size() > 0) { 
                        zAccName = (String)zAccounts[0].getValue('Name');
                        zAccId = (String)zAccounts[0].getValue('Id');
                        verifyZuoraSubscription();  
                    } 
                } 
                else
                    throw new CustomException(status);           
            } 
            zuoraAccountStatus = true;
            zuoraAccountState = 'complete';
            
            if(subscription[0].Status__c == 'Active') 
                 autoRenew = true;                    
        }
        catch(Exception e) {
            zuoraAccountState = e.getMessage();
        }
    }
    
    public void createPersonAccount() {
        try {
            List<Contact> contacts = [SELECT Id, Name, FirstName, LastName, Phone, QAS_Mailing_Street_Type__c, Zip__c, 
                                             Zip_4__c, City__c, State__c, QAS_Mailing_Country__c, QAS_Mailing_County__c 
                                      FROM   Contact
                                      WHERE  id = :subscription[0].Contact__c];
                                      
            System.Debug('***** contacts - ' + contacts);
                              
            List<Account> personAccounts = new List<Account>();
            List<RecordType> personRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Zuora Integration Account'];
            
            for(Contact c : contacts) {
    
                Account personAccount = new Account();
                
                personAccount.RecordTypeId = personRecordType[0].id;
                personAccount.Contact__c = c.id;
                personAccount.Account_Name__c = c.LastName + ' ' + c.FirstName;
                personAccount.LastName = c.LastName;
                personAccount.FirstName = c.FirstName;
                personAccount.Type = 'Billing Account';
                personAccount.Status__c = 'Active';
                personAccount.Phone = c.Phone;
                personAccount.QAS_Mailing_Street_Type__c = c.QAS_Mailing_Street_Type__c;
                personAccount.Zip__c = c.Zip__c;
                personAccount.Zip_4__c = c.Zip_4__c ;
                personAccount.City__c = c.City__c;
                personAccount.State__c = c.State__c;
                personAccount.QAS_Mailing_Country__c = c.QAS_Mailing_Country__c ;
                personAccount.QAS_Mailing_County__c = c.QAS_Mailing_County__c ;
                
                personAccounts.add(personAccount); 
            }
            insert personAccounts;
            accId = personAccounts[0].Id;
            accName = personAccounts[0].Account_Name__c;
        }
        catch(Exception e) {
            throw new CustomException('Failed to create Person Account: ' + e.getMessage());
        }                   
    }
    
    
    public void verifyZuoraSubscription() {
        try {
        
        zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
         
        String mrisSubscription = subscription[0].Name;
        String zMappingRatePlanId;
        Boolean matchingProduct = false;
        
        Subscriptions__c sub = [SELECT Id, Contact_Type__c, Subscription_Type__c, Date_Terminated__c,
                                       Primary__c, Contact__c, Status__c, Name, Billing_Jurisdiction__c 
                                FROM   Subscriptions__c 
                                WHERE  Name = :mrisSubscription];
        
        if(sub.Status__c != 'Active')
            throw new CustomException('Subscription is not Active');
                
        if(String.isBlank(sub.Billing_Jurisdiction__c))
            sub.Billing_Jurisdiction__c = 'MRIS';
                    
        List<SMS_CoreMapping__c> productRatePlans = [
            SELECT ZuoraProductId__c, ZuoraOnetimeProductRatePlanId__c, ZuoraRecurringProductRatePlanId__c
            FROM   SMS_CoreMapping__c
            WHERE  Type__c = :sub.Contact_Type__c
            AND    SubType__c = :sub.Subscription_Type__c
            AND    Status__c = 'New'
            AND    IsPrimaryFlag__c = :sub.Primary__c
            AND    Billing_Jurisdiction__c = :sub.Billing_Jurisdiction__c];
        
        zMappingRatePlanId = productRatePlans[0].ZuoraRecurringProductRatePlanId__c;
        system.debug('*** zMappingRatePlanId: ' + zMappingRatePlanId);
        
        // Zuora account details 
        String zAccountsQuery = 'SELECT Id, ParentId FROM Account WHERE SubscriptionID__c = \'' + sub.Name + '\'';                       
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);
        System.debug('*** zAccountsQuery: ' + zAccountsQuery);
        String zChildAccountId = (String)zAccounts[0].getValue('Id');
        System.debug('*** zChildAccountId: ' + zChildAccountId);
        
        // Query Zuora Subcription for Existing Product Rate Plan Id
        List<Zuora.zObject> zSubscriptions = new List<Zuora.zObject>();
        Map<String, String> zSubNames = new Map<String, String>();
        String subscriptionQuery = 'SELECT Id,AccountId,AutoRenew,Status,TermEndDate,TermStartDate,TermType,Name FROM Subscription WHERE ';
        subscriptionQuery += 'AccountId = \'' + zChildAccountId + '\' AND Status = \'Active\' AND TermType = \'TERMED\' AND IsCore__c = true';
        
        zSubscriptions = zUtilInstance.zquery(subscriptionQuery);
        String matchingSubscription;
        if(zSubscriptions.size() > 0){
            Boolean isNotFirst = false;
            String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
            for (Zuora.zObject zSubscription : zSubscriptions) {
                String zSubscriptionId = (String)zSubscription.getValue('Id');
                if (isNotFirst)
                    ratePlansQuery += ' OR ';        
                
                ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
                isNotFirst = true;
                
                zSubNames.put((String)zSubscription.getValue('Id'), (String)zSubscription.getValue('Name'));
            }
            if(isNotFirst){
                List<Zuora.zObject> zRatePlans = new List<Zuora.zObject>();
                zRatePlans = zUtilInstance.zquery(ratePlansQuery);        
                for (Zuora.zObject zRatePlan : zRatePlans) {
                    String zProductRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                    system.debug('*** zProductRatePlanId: ' + zProductRatePlanId);
                    if( zMappingRatePlanId == zProductRatePlanId){
                        matchingProduct = true;
                        matchingSubscription = zSubNames.get((String)zRatePlan.getValue('SubscriptionId'));
                        system.debug('*** matchingProduct found ');
                        break;
                    }
                }
                
            }
        }
        else
            system.debug('*** No Active CORE Zuora Subscription found');
        
        if(matchingProduct) {
            system.debug('*** Do not create zuora subscription');
            zuoraSubStatus1 = false;
            zuoraSubStatus2 = true;
            zuoraSubState = 'complete';
            zuoraSubLable = 'primary';  
            zSubNumber = matchingSubscription;        
        }else  {
            zuoraSubStatus1 = true;
        }
        }
        catch(Exception e) {
            zuoraSubState = 'Zuora Subscription: ' + e.getMessage();
        }    
    }
    
    public Class CustomException extends Exception {} 
}