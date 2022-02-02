public class Communities_OfficeBillingInformation {
    public String relationshipType { get; set; }
    public String contactName { get; set; }
    public String officeId { get; set; } 
    public Map<String,String> officeIds { get; set; }
    public List<Zuora__CustomerAccount__c> billingAccounts { get; set; }
    public Map<String, Zuora__Subscription__c> subNextRenewalDateMap { get; set; }
    public String displayType { get; set; }
    public String displayName{get;set;}
    public Map<Id, Zuora__CustomerAccount__c> selectedAccounts { get; set; } 
    public Map<Id, List<Zuora__ZInvoice__c>> zInvoicesMap { get; set; }
    public Subscriptions__c subscription { get; set; } 
    public Integer zInvoiceCount { get; set; }   
    public Decimal totalAmountPayable { get; set; } 
    public String iframeDomain { get; private set; }
    public String iframeUrl { get; private set; }
    public String redirectUrl { get; private set; }
    public String cancelUrl { get; private set; }
    public String brokerSubId; 
    public String zAccountId;
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public Boolean hasBalance { get; private set; }
    public String selectedSubids {get;set;}
    public String paymentMethodId {get;set;}
    public String BORsubscriptionId {get;set;}
    public Boolean isPaymentMade {get;set;}
    public  string contactId {get; set;}
    public String errorMesg {get; set;}		
    
    public Boolean showPaymentOptions { get; set; }
    public Boolean showExistingPayment { get; set; }
    public Boolean showNewPayment { get; set; }
    public PaymentMethod selectedPaymentMethod { get; set; }
    public String selectedPaymentMethodId { get; set; }
    
    public List<PaymentMethod> paymentMethods { get; set; } 
    public Boolean isSavePaymentMethod { get; set; }
    public Boolean isExistingPaymentMethod { get; set; }
    public String errorString { get; set; }
    public String error { get; set; }
    
    public Boolean hasCreateNewPaymentMethodError { get; set; }
    public String getCreateNewPaymentMethodError { get; set; }
    
    public Boolean hasChargeNewPaymentMethodError { get; set; }
    public String getChargeNewPaymentMethodError { get; set; }
    
    public Boolean hasUnspecifiedError { get; set; }
    public String getUnspecifiedError { get; set; }
    private SMS_BORPayment__c borPayment;
    
    private Map<String,Subscriptions__c> agentSubscriptionsMap {get; set;}
    private List<Subscriptions__c> agentSubscriptionsList {get; set;}
    
    
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
    public Boolean hasPaymentError {set; get;}
    public Communities_OfficeBillingInformation() {
        
        displayType = 'Unpaid';
        zInvoiceCount = 0;
        initialLoad = true;
        hasError = true;
        hasBalance= true;
        totalAmountPayable = 0;
        isPaymentMade = true;
        isSavePaymentMethod = false;
        isExistingPaymentMethod = false;
        showPaymentOptions = false;
        showExistingPayment = false;
        showNewPayment = false;   
        hasPaymentError = false;
        errorMesg = '';
        
        try {
            List<User> currentUser = [
                SELECT   FederationIdentifier, Name 
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()
            ];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
            
            /* String subscriptionId = currentUser[0].FederationIdentifier;*/
            
            String subscriptionId = ApexPages.currentPage().getParameters().get('id');
            BORsubscriptionId = subscriptionId;
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Federated ID found >> ' + currentUser);  
            
            brokerSubId = subscriptionId;
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                             Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Contact__r.Id
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subscriptionId 
                            ];
            
            List<String> parentIds = new List<String>();
            Map<String,String> asOffices = new Map<String,String>();
            Map<String,String> omOffices = new Map<String,String>();
            Boolean isBOR = false;
            
            for(Relationship__c relationship : relationships){
                system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
                
                if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                    isBOR = true;
                    
                    relationshipType = relationship.Relationship_Type__c;
                    contactName = relationship.Subscription__r.Contact__r.Name;
                    officeId = relationship.Broker_Office__c;  
                    
                } 
                else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                }
                else if(relationship.Relationship_Type__c == 'Office Manager'){
                    omOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                }
            }  
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new Map<String,String>(asOffices);
                    relationshipType = 'Authorized Signer';
                    contactName = currentUser[0].Name;
                }
                else if(omOffices.size() > 0){
                    officeIds = new Map<String,String>(omOffices);
                    relationshipType = 'Office Manager';
                    contactName = currentUser[0].Name;
                }
            } 
            else{
                List<Account> relatedAccounts = new List<Account>(); 
                relatedAccounts = [SELECT Id, Name
                                   FROM   Account
                                   WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                  ];
                
                officeIds = new Map<String,String>();
                
                for(Account a : relatedAccounts){
                    officeIds.put(a.Id, a.Name);
                    system.debug('*** Office Name: ' + a.Id + '---' + a.Name);
                }
            }
            
            /* Load all subscriptions on page load */
            
            officeId = 'All';
            
            subscriptions();             
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin(); 
            zAccountOfBroker(); 
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }      
    }
    
    public void zAccountOfBroker() 
    {
        
        String accountQuery = 'SELECT Id, AutoPay, DefaultPaymentMethodId FROM Account WHERE Status = \'Active\' AND SubscriptionID__c = \'' + BORsubscriptionId + '\'';
        List<Zuora.zObject> account = zUtilInstance.zquery(accountQuery); 
        if(account.size() == 0 ){
            throw new CustomException('Zuora account does not exist');
        }
        zAccountId = String.valueOf(account[0].getValue('Id'));  
        
    }
    
    public integer totalBillingCount {get; set;}
    public Datetime balanceNextoffset {get; set;}
    public Datetime balancePreviousoffset {get; set;}
    public void subscriptions() {
        system.debug('*** officeId : ' + officeId );
        totalAmountPayable = 0;
        /*
Set<String> selectedOffices = new Set<String>();
if(officeId == 'All')
selectedOffices = officeIds.keyset();
else if(officeId == 'None')
selectedOffices = new Set<String>();    
else {
selectedOffices.addAll(officeId.split(','));
if(selectedOffices.Size() == 0)
selectedOffices.add(officeId);     
}
system.debug('*** selectedOffices: ' + selectedOffices);
system.debug('*** displayType: ' + displayType );

Set<String> Status = new Set<String> {'Active','Inactive'};

Date thresholdate = date.valueOf(system.today());
billingAccounts = new List<Zuora__CustomerAccount__c>();
*/
        totalCount = 0;
        serachNext(null);
        /*
if(displayType == 'Unpaid') {
billingAccounts = [SELECT Id,
Email_Invoice_PDF__c,
Oldest_Invoice_Due__c,
Zuora__Balance__c,
Subscription__r.Name,
Subscription__r.Contact__r.Name,
Subscription__r.Related_Location_Broker_Office__r.Name,
Zuora__Zuora_Id__c,
SubscriptionID__c, createdDate
FROM   Zuora__CustomerAccount__c 
WHERE  Zuora__Balance__c > 0 
//AND    Oldest_Invoice_Due__c <= :thresholdate 
AND    SubscriptionID__c != null
AND    Subscription__r.Status__c IN :status
AND    Subscription__r.Related_Location_Broker_Office__c = :selectedOffices order by createdDate desc LIMIT 500];

serachNext(null);
checkZuoraBalance(billingAccounts,'Unpaid');

}
else {

billingAccounts = [SELECT Id,
Email_Invoice_PDF__c,
Oldest_Invoice_Due__c,
Zuora__Balance__c,
Subscription__r.Name,
Subscription__r.Contact__r.Name,
Subscription__r.Related_Location_Broker_Office__r.Name,
Zuora__Zuora_Id__c,
SubscriptionID__c, createdDate
FROM   Zuora__CustomerAccount__c 
WHERE  Zuora__Balance__c = 0 
//AND    Oldest_Invoice_Due__c <= :thresholdate 
AND    SubscriptionID__c != null
AND    Subscription__r.Status__c IN :status
AND    Subscription__r.Related_Location_Broker_Office__c = :selectedOffices order by createdDate desc LIMIT 500];

serachNext(null);                    
checkZuoraBalance(billingAccounts,'paid');
}
*/
        /*
if(billingAccounts.size() > 0){
balanceoffset = billingAccounts[billingAccounts.size() - 1].createdDate;
balancePreviousoffset = billingAccounts[0].createdDate;
system.debug('---balanceoffset--->>'+balanceoffset);
}
*/
    }
    
    public integer totalCount {get; set;}
    public void serachNext(string resultsCond){
        try{
            
            Set<String> selectedOffices = new Set<String>();
            if(officeId == 'All')
                selectedOffices = officeIds.keyset();
            else if(officeId == 'None')
                selectedOffices = new Set<String>();    
            else {
                selectedOffices.addAll(officeId.split(','));
                if(selectedOffices.Size() == 0)
                    selectedOffices.add(officeId);     
            }
            Set<String> Status = new Set<String> {'Active','Inactive'};
                Date thresholdate = date.valueOf(system.today());
            billingAccounts = new List<Zuora__CustomerAccount__c>();
            subNextRenewalDateMap = new Map<string, Zuora__Subscription__c>();
            
            system.debug('---resultsCond--->>'+resultsCond);
            system.debug('---balanceNextoffset--->>'+balanceNextoffset);
            //system.debug('---balancePreviousoffset--->>'+balancePreviousoffset);
            system.debug('---displayType--->>'+displayType);
            system.debug('---selectedOffices--->>'+selectedOffices);
            
            if(displayType == 'Unpaid' ) {
                totalCount = [SELECT count() FROM   Zuora__CustomerAccount__c 
                              WHERE  Zuora__Balance__c > 0 
                              AND    SubscriptionID__c != null
                              AND    Subscription__r.Status__c IN :status
                              AND    Subscription__r.Related_Location_Broker_Office__c = :selectedOffices Limit 10000];
            }
            else {
                totalCount = [SELECT count() FROM   Zuora__CustomerAccount__c 
                              WHERE  Zuora__Balance__c = 0 
                              AND    SubscriptionID__c != null
                              AND    Subscription__r.Status__c IN :status
                              AND    Subscription__r.Related_Location_Broker_Office__c = :selectedOffices Limit 10000];
            }
            
            /*
totalCount = [SELECT count() FROM   Zuora__CustomerAccount__c 
WHERE  Zuora__Balance__c > 0 
AND    SubscriptionID__c != null
AND    Subscription__r.Status__c IN :status
AND    Subscription__r.Related_Location_Broker_Office__c = :selectedOffices ];
*/
            Subscriptions__c BORsubscription = [SELECT Id, Name, Private_Email__c, Contact__c
                                                FROM   Subscriptions__c
                                                WHERE  Name = :BORsubscriptionId];
            
            system.debug('--totalcount-->'+totalCount);
            
            string query = 'SELECT Id, Email_Invoice_PDF__c, Oldest_Invoice_Due__c, Zuora__Balance__c, Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Related_Location_Broker_Office__r.Name, Zuora__Zuora_Id__c, SubscriptionID__c, createdDate FROM Zuora__CustomerAccount__c';
            query += ' WHERE SubscriptionID__c != null AND Subscription__r.Contact__c != \''+ BORsubscription.Contact__c+'\' AND Subscription__r.Status__c IN :status AND Subscription__r.Related_Location_Broker_Office__c = :selectedOffices';
            
            if(displayType == 'Unpaid')
                query += ' And Zuora__Balance__c > 0';
            else
                query += ' And Zuora__Balance__c = 0';
            
            if(resultsCond != null && resultsCond == 'next')
                query += ' AND createdDate <: balanceNextoffset';
            /*else if(resultsCond != null && resultsCond == 'previous'){
query += ' AND createdDate >: balancePreviousoffset';
system.debug('---prev--'+balancePreviousoffset);
}*/
            query += ' order by createdDate desc LIMIT 500';
            
            system.debug('---query--->>'+query);
            billingAccounts = Database.query(query);
            
            for(Zuora__CustomerAccount__c zca : billingAccounts){
                subNextRenewalDateMap.put(zca.Subscription__r.Name , new Zuora__Subscription__c());
            }
            //if(resultsCond == null || resultsCond == 'next'){
            if(displayType == 'Unpaid' ) {
                checkZuoraBalance(billingAccounts,'Unpaid');
            }
            else {
                checkZuoraBalance(billingAccounts,'paid');
            }
            //}
            system.debug('---billingAccounts--->'+billingAccounts);
            if(billingAccounts.size() > 0){
                balanceNextoffset = billingAccounts[billingAccounts.size() - 1].createdDate;
                //balancePreviousoffset = billingAccounts[0].createdDate;
                system.debug('---balanceNextoffset-next meth-->>'+balanceNextoffset);
            }
            //Subscription Next Renewal Date Query
            string query1 ='SELECT Id, Zuora__CustomerAccount__r.SubscriptionID__c, Zuora__NextRenewalDate__c FROM Zuora__Subscription__c';
            query1 += ' WHERE IsCore__c = \'true\' AND Zuora__AutoRenew__c = true AND Zuora__Status__c=\'Active\' AND Zuora__CustomerAccount__r.SubscriptionID__c != null ';
            query1 += 'AND Zuora__CustomerAccount__r.Subscription__r.Contact__c != \''+ BORsubscription.Contact__c+'\' AND Zuora__CustomerAccount__r.Subscription__r.Status__c IN :status AND Zuora__CustomerAccount__r.Subscription__r.Related_Location_Broker_Office__c = :selectedOffices';
            system.debug('---query1--->>'+query1);
            //billingAccounts = Database.query(query1);
            for(Zuora__Subscription__c zs : Database.query(query1)){
                subNextRenewalDateMap.put(zs.Zuora__CustomerAccount__r.SubscriptionID__c , zs);
            }
            system.debug('subNextRenewalDateMap------'+subNextRenewalDateMap);
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }
    }
    
    public void advSearchNextResults(){
        try{
            serachNext('next');
            /*
if(billingAccounts.size() > 0){
balanceNextoffset = billingAccounts[billingAccounts.size() - 1].createdDate;
balancePreviousoffset = billingAccounts[0].createdDate;
system.debug('---balanceNextoffset-next meth-->>'+balanceNextoffset);
system.debug('---balancePreviousoffset- next meth-->>'+balancePreviousoffset);
}*/
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }
    }
    /*
public void advSearchPreviousResults(){
try{
serachNext('previous');

if(billingAccounts.size() > 0){
balanceNextoffset = billingAccounts[billingAccounts.size() - 1].createdDate;
balancePreviousoffset = billingAccounts[0].createdDate;
system.debug('---balanceNextoffset-prev meth-->>'+balanceNextoffset);
system.debug('---balancePreviousoffset-prev meth-->>'+balancePreviousoffset);
}
}
catch(Exception e) {
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
}
}    
*/
    
    /* Method to procced and display payment method options */
    public void proceedToPayment() { 
        
        clearErrors();
        showExistingPayment = false;
        showNewPayment = false;
        showPaymentOptions = false;
        error=null;
        errorString=null;
        try {  
            hasPaymentError = false;
            
            List <SMS_BORPayment__c> checkstatus= [select id,Status__c,Reference_Id__c,BOR_Subscription__c from SMS_BORPayment__c where BOR_Subscription__r.Name =: BORsubscriptionId
                                                   AND Status__c IN ('Credit Balance')];
            system.debug('$$$$$$ checkstatus ****'+checkstatus);
            if(checkstatus.Size() != 0 ){ 
                system.debug('$$$$$$ checkstatus.Size() ****'+checkstatus.Size());
                throw new CustomException('Warning: A previous payment is still in progress. You can initiate a new payment once the previous payment is completed. You should be receiving an email about the payment completion which might take few minutes. Please check your email and refresh the page to continue with your next payment. Thanks for your patience!');  
            }
            
            populatePaymentMethods();
            if(paymentMethods.size() <= 0) {
                system.debug('&&&& '+paymentMethods.size());
                showPaymentOptions = false;
                showNewPayment = true;
                generateHpmUrl();             
            }
            else 
                showPaymentOptions = true;
        }
        catch(Exception e){
            hasPaymentError = true;
            system.debug('**************** Exception is '+ e.getMessage());
            errorMesg = e.getMessage();
            system.debug('**************** Exception  errorMesg is '+ errorMesg);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }
    
    public void showExistingPaymentMethods() {
        showExistingPayment = true;
        showNewPayment = false;
    }
    
    public void showNewPaymentMethod() {
        showExistingPayment = false;
        showNewPayment = true;
        generateHpmUrl(); 
    }
    
    public void selectPaymentMethod() {
        
        String selectedId = Apexpages.currentPage().getParameters().get('pmid');
        system.debug('***' + selectedId);
        for(PaymentMethod pm : paymentMethods) {
            if(pm.Id == selectedId)
                selectedPaymentMethod = pm;
        }
    }   
    
    /* Method to find existing payment methods */
    public void populatePaymentMethods() {
        
        
        clearErrors();
        String pmQuery = 'SELECT Id,  CreditCardHolderName, CreditCardType, CreditCardMaskNumber, CreditCardExpirationMonth, CreditCardExpirationYear FROM PaymentMethod WHERE AccountId = \'' + zAccountId + '\' AND Type = \'CreditCard\' AND PaymentMethodStatus = \'Active\'';
        List<Zuora.zObject> methods = zUtilInstance.zquery(pmQuery);
        paymentMethods = new List<PaymentMethod>();
        
        for (Zuora.zObject method : methods) {
            PaymentMethod entry = new PaymentMethod();
            
            entry.Id = (String) method.getValue('Id');
            entry.NameOnCard = (String) method.getValue('CreditCardHolderName');
            entry.Type = (String) method.getValue('CreditCardType');
            entry.LastFourDigits = ((String) method.getValue('CreditCardMaskNumber')).replaceAll('[^0-9]+', '********');
            entry.ExpirationMonth = (Integer) method.getValue('CreditCardExpirationMonth');
            entry.ExpirationYear = (Integer) method.getValue('CreditCardExpirationYear');
            
            entry.HasExpired = entry.Expiration < DateTime.now();
            if(!entry.HasExpired)
                paymentMethods.add(entry);
        }
        
    }    
    
    public PageReference getSOAPDF() {
        try {
            List<User> currentUser = [
                SELECT   FederationIdentifier, Name 
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()
            ]; 
            String subscriptionId = currentUser[0].FederationIdentifier;   
            
            subscription = [SELECT Id, 
                            Name, 
                            Contact__c, 
                            Contact__r.Name, 
                            Contact__r.Street_Number__c, 
                            Contact__r.Street_Name__c, 
                            Contact__r.City__c,
                            Contact__r.State__c,
                            Contact__r.County__c,
                            Contact__r.Zip__c
                            FROM   Subscriptions__c
                            WHERE  Name = :subscriptionId];    
            
            selectedAccounts = new Map<Id, Zuora__CustomerAccount__c >();
            zInvoicesMap = new Map<Id, List<Zuora__ZInvoice__c>>();
            
            for(Zuora__CustomerAccount__c a : billingAccounts) {
                if(a.Email_Invoice_PDF__c)
                    selectedAccounts.put(a.Id, a);
            }
            
            if(selectedAccounts.Size() > 0) {                   
                List<Zuora__ZInvoice__c> zInvoices = [SELECT  Id, 
                                                      Name,
                                                      Zuora__Balance2__c,
                                                      Zuora__TotalAmount__c,
                                                      Zuora__BillingAccount__c,
                                                      Zuora__DueDate__c,
                                                      Zuora__InvoiceDate__c
                                                      FROM    Zuora__ZInvoice__c       
                                                      WHERE   Zuora__BillingAccount__c IN :selectedAccounts.keySet()
                                                      AND     Zuora__Balance2__c > 0];
                
                for(Zuora__ZInvoice__c zInvoice : zInvoices) {
                    if(zInvoicesMap.get(zInvoice.Zuora__BillingAccount__c) != null && zInvoicesMap.get(zInvoice.Zuora__BillingAccount__c).Size() > 0) {
                        List<Zuora__ZInvoice__c> zInvoiceTemp = zInvoicesMap.get(zInvoice.Zuora__BillingAccount__c);
                        zInvoiceTemp.add(zInvoice);
                        zInvoicesMap.put(zInvoice.Zuora__BillingAccount__c, zInvoiceTemp);
                    }
                    else 
                        zInvoicesMap.put(zInvoice.Zuora__BillingAccount__c, new List<Zuora__ZInvoice__c> {zInvoice});
                }                                                  
                System.debug('***' + zInvoicesMap);
                zInvoiceCount = zInvoicesMap.Size();
                
                String csvData = 'Payment Voucher\n\n';
                csvData += 'Name, Subscription Id, Office Id, Oldest Invoice Date, Balance Due \n';
                Double totalBalance = 0;
                for(String key : selectedAccounts.keySet()) {
                    csvData += selectedAccounts.get(key).Subscription__r.Contact__r.Name + ', ' + selectedAccounts.get(key).Subscription__r.Name + ', ' + selectedAccounts.get(key).Subscription__r.Related_Location_Broker_Office__r.Name + ', ' + selectedAccounts.get(key).Oldest_Invoice_Due__c + ', $' + selectedAccounts.get(key).Zuora__Balance__c + '\n';
                    totalBalance = totalBalance + selectedAccounts.get(key).Zuora__Balance__c;
                }
                csvData += ',,, Total, $' + String.valueOf(totalBalance);
                
                /* create the new attachment */ 
                Attachment attach = new Attachment();
                attach.Body = Blob.valueOf(csvData);
                attach.ContentType = 'application/csv';
                attach.Name = 'PaymentVoucher.csv';
                attach.IsPrivate = false;
                attach.ParentId = subscription.Id;
                insert attach;                            
                
                PageReference pdf = new PageReference('/apex/Communities_TrendOfficeStatement_PDF');
                pdf.setRedirect(false);
                return pdf;        
            }
            else
                throw new CustomException('Please select subscriber');
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));         
        }
        
        return null;
    } 
    
    public void checkZuoraBalance(List<Zuora__CustomerAccount__c> vBillingAccounts,String type){
        List<Zuora__CustomerAccount__c> sBillingAccounts = new List<Zuora__CustomerAccount__c>();
        sBillingAccounts.addAll(vBillingAccounts);
        
        system.debug('*******billing accounts before sync********* '+sBillingAccounts);
        try{
            Map<String,Zuora__CustomerAccount__c> scustAccounts = new Map<String,Zuora__CustomerAccount__c>();            
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
            for(Zuora__CustomerAccount__c sBillingAccount : sBillingAccounts){
                Zuora.zObject invoice = new Zuora.zObject('Invoice');
                
                invoice.setValue('AccountId', sBillingAccount.Zuora__Zuora_Id__c);
                invoice.setValue('InvoiceDate', DateTime.now().format('yyyy-MM-dd','PST'));
                invoice.setValue('TargetDate', DateTime.now().format('yyyy-MM-dd','PST'));
                zInvoices.add(invoice);
                
                if(zInvoices.size() == 49){
                    List<Zuora.zApi.SaveResult> zSaveResultList = new List<Zuora.zApi.SaveResult>();
                    zSaveResultList = zUtilInstance.zgenerate(zInvoices);
                    zInvoices = new List<Zuora.zObject>();
                    for(Zuora.zApi.SaveResult result : zSaveResultList){
                        if(result.Success) {
                            invoice = new Zuora.zObject('Invoice');
                            invoice.setValue('Id', result.Id);
                            invoice.setValue('Status', 'Posted'); 
                            zInvoices.add(invoice); 
                            system.debug('======= Generate Invoices===='+invoice);
                        }                        
                    }
                    if(zInvoices.size() > 0){
                        zSaveResultList = new List<Zuora.zApi.SaveResult>();
                        zSaveResultList = zUtilInstance.zupdate(zInvoices);
                        system.debug('=======Post Invoices===='+zSaveResultList);
                    }
                    zInvoices = new List<Zuora.zObject>(); 
                }
            } 
            
            if(zInvoices.size() > 0){
                List<Zuora.zApi.SaveResult> zSaveResultList = new List<Zuora.zApi.SaveResult>();
                zSaveResultList = zUtilInstance.zgenerate(zInvoices);
                zInvoices = new List<Zuora.zObject>();
                for(Zuora.zApi.SaveResult result : zSaveResultList){
                    if(result.Success) {
                        Zuora.zObject invoice = new Zuora.zObject('Invoice');
                        invoice.setValue('Id', result.Id);
                        invoice.setValue('Status', 'Posted'); 
                        zInvoices.add(invoice);  
                        system.debug('======= Generate Invoices===='+invoice);
                    }                        
                }
                if(zInvoices.size() > 0){
                    zSaveResultList = new List<Zuora.zApi.SaveResult>();
                    zSaveResultList = zUtilInstance.zupdate(zInvoices);
                    system.debug('=======Post Invoices===='+zSaveResultList);
                }
                zInvoices = new List<Zuora.zObject>(); 
            }           
            
            List<Zuora.zObject> zAllAccounts = new List<Zuora.zObject>();            
            String zQuery = 'SELECT Id,Balance,Name,SubscriptionID__c,ParentId FROM Account WHERE ';
            Integer i = 0;
            
            for(Zuora__CustomerAccount__c sBillingAccount : sBillingAccounts){
                
                if (i != 0)
                    zQuery += ' OR ';
                
                zQuery += 'Id = \'' + sBillingAccount.Zuora__Zuora_Id__c + '\'';
                i++;                
                
                if(i == 199) {
                    List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zQuery);
                    zAllAccounts.addAll(zAccounts);
                    zQuery = 'SELECT Id,Balance,Name,SubscriptionID__c,ParentId FROM Account WHERE ';
                    i=0;
                }
            }
            
            if(i!=0) {
                List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zQuery);
                zAllAccounts.addAll(zAccounts);
            }
            
            system.debug('*****zAllAccounts********'+zAllAccounts);
            for(Zuora.zObject zAccount : zAllAccounts) {
                if(type == 'Unpaid'){                
                    if((Decimal)zAccount.getValue('Balance') > 0){
                        system.debug('*****unpaid********'+zAccount);
                        Zuora__CustomerAccount__c scustAccount = new Zuora__CustomerAccount__c();
                        scustAccount.Zuora__Balance__c = (Decimal)zAccount.getValue('Balance');                    
                        scustAccounts.put((String)zAccount.getValue('SubscriptionID__c'),scustAccount);
                        system.debug('*****scustAccounts********'+scustAccounts);
                    }
                }
                else if(type == 'paid'){
                    if((Decimal)zAccount.getValue('Balance') == 0){
                        Zuora__CustomerAccount__c scustAccount = new Zuora__CustomerAccount__c();
                        scustAccount.Zuora__Balance__c = (Decimal)zAccount.getValue('Balance');                     
                        scustAccounts.put((String)zAccount.getValue('SubscriptionID__c'),scustAccount);
                    }
                }   
            }
            system.debug('*****scustAccounts********'+scustAccounts);
            billingAccounts.clear();                
            system.debug('*******subscription keyset********* '+scustAccounts.keySet());
            system.debug('*******sBillingAccounts********* '+sBillingAccounts);
            
            for(Zuora__CustomerAccount__c bAccount : sBillingAccounts){
                system.debug('*******bAccount.SubscriptionID__c ********* '+bAccount.SubscriptionID__c );
                if(scustAccounts!=null && scustAccounts.containsKey(bAccount.SubscriptionID__c )){
                    Zuora__CustomerAccount__c qualifiedBillingAccount = new Zuora__CustomerAccount__c();
                    qualifiedBillingAccount = bAccount;
                    qualifiedBillingAccount.Zuora__Balance__c = scustAccounts.get(bAccount.SubscriptionID__c).Zuora__Balance__c;
                    billingAccounts.add(qualifiedBillingAccount);
                }
            }
            
            system.debug('*******billing accounts after sync********* '+billingAccounts);
        }
        catch(Exception e){
            system.debug('**************** Exception is '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getStackTraceString() + e.getMessage()));
        }    
    }
    
    public PageReference calculatePayableAmount(){
        selectedAccounts = new Map<Id, Zuora__CustomerAccount__c >();
        for(Zuora__CustomerAccount__c  billingAccs : billingAccounts) {
            if(billingAccs.Email_Invoice_PDF__c)
                totalAmountPayable = totalAmountPayable + billingAccs.Zuora__Balance__c;
            selectedAccounts.put(billingAccs.Id, billingAccs);
        }  
        return null;
    }
    
    public void agentPayments(){
        system.debug('****** selected subscribers ****'+selectedSubids);
        system.debug('****** paymentMethodId ****'+paymentMethodId);
        system.debug('****** BORsubscriptionId ****'+BORsubscriptionId);
        hasPaymentError = false;
        
        
        agentSubscriptionsMap = new Map<String,Subscriptions__c>();
        Subscriptions__c BORsubscription = [SELECT Id, Name, Private_Email__c
                                            FROM   Subscriptions__c
                                            WHERE  Name = :BORsubscriptionId];
        
        borPayment = new SMS_BORPayment__c();
        borPayment.BOR_Subscription__c = BORsubscription.Id;
        borPayment.Private_Email__c = BORsubscription.Private_Email__c;
        borPayment.Status__c = 'In Progress';
        borPayment.Status_Message__c = 'Transaction has started';
        borPayment.Total_Amount__c = totalAmountPayable; 
        
        List<SMS_BORPayment_Subscriber__c> borSubscribers = new List<SMS_BORPayment_Subscriber__c>();             
        
        List<String> selectedSubscribers = new List<String>();
        
        if(selectedSubids!=null){
            
            selectedSubscribers.addAll(selectedSubids.split(','));
            if(selectedSubscribers.Size() == 0)
                selectedSubscribers.add(selectedSubids);
        }
        
        agentSubscriptionsList = [select ID,Name,contact__r.Name from subscriptions__c where name in :selectedSubscribers];
        
        for(Subscriptions__c sub : agentSubscriptionsList){
            agentSubscriptionsMap.put(sub.Name, sub);
        }
        
        system.debug('******agentSubscriptionsMap****'+agentSubscriptionsMap);
        for(String sid : selectedSubscribers){
            SMS_BORPayment_Subscriber__c bors = new SMS_BORPayment_Subscriber__c();
            bors.Status__c = 'In Progress';
            if(!agentSubscriptionsMap.containsKey(sid))
                throw new CustomException('Invalid agent subscription '+sid);
            bors.SF_Subscription__c = agentSubscriptionsMap.get(sid).ID;
            borSubscribers.add(bors);
        }
        
        try{            
            system.debug('****** selected subscribers ****'+selectedSubscribers);
            system.debug('****** zAccountId ****'+zAccountId);
            makeBORPayment(zAccountId,paymentMethodId,totalAmountPayable);
            
            insert borPayment;
            
            for(SMS_BORPayment_Subscriber__c bors : borSubscribers){
                bors.BOR_Payment__c = borPayment.Id;               
            }            
            insert borSubscribers; 
            
        }
        catch(Exception e){
            hasPaymentError = true;
            //paymentMethodFailed();
            system.debug('***** error message *****'+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            borPayment.Status_Message__c = e.getMessage(); 
            
            insert borPayment;
            
            for(SMS_BORPayment_Subscriber__c bors : borSubscribers){
                bors.BOR_Payment__c = borPayment.Id;               
            }            
            insert borSubscribers;           
        }   
        
        if(!hasPaymentError)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'Applying payment initiated successfully. Results will be emailed once the payment process is complete.'));
        Database.executeBatch(new Communities_BORPayment_Batch(borPayment.Id),15);    
        
    }
    
    private String createSubscription(String zAccountId, Decimal amount){
        
        SMS_CreditsTranfer__c broker = SMS_CreditsTranfer__c.getInstance('Broker');
        String zInvoiceId = null;
        
        List<Zuora.zApi.SubscribeRequest> subscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        subscribeRequests.add(getZuoraSubscriptionRequest(zAccountId, broker.zProductRatePlanId__c, broker.zProductRatePlanChargeId__c, amount));
        List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(subscribeRequests);
        
        for(Zuora.zApi.SubscribeResult result : results){
            if(result.Success){
                system.debug('********* createSubscription result is Success***');
                zInvoiceId = (String)result.InvoiceId;
                borPayment.Status__c = 'Subscription'; 
                borPayment.Status_Message__c = 'Zuora subscription with negative balance has been created'; 
            }
            else{
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');
                    system.debug('********Create Subscription******** '+ errorCode + '-' + message);
                    throw new CustomException('Create Subscription for BOR:' + errorCode + '-' + message); 
                } 
            }                   
        }
        
        return zInvoiceId;
    }
    
    private void createCreditBalanceAdjustment(String zInvoiceId, Decimal amount, String type){
        List<Zuora.zObject> creditBalanceAdjustments = new List<Zuora.zObject>();
        Boolean isSuccess = false; 
        
        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
        adjustment.setValue('SourceTransactionId', zInvoiceId);
        adjustment.setValue('Type', type);
        adjustment.setValue('Amount', amount);
        
        creditBalanceAdjustments.add(adjustment);
        List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zcreate(creditBalanceAdjustments);
        
        for(Zuora.zApi.SaveResult result : zSaveResultList){
            if(!result.Success){
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');
                    throw new CustomException('Apply Credit Balance to BOR Invoice:' + errorCode + '-' + message); 
                } 
            }
            else
                borPayment.Status__c = 'Credit Balance'; 
            borPayment.Status_Message__c = 'Credit balance has been applied to the negative invoice';
        }        
    }
    
    private Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, String zProductRatePlanId, 
                                                                    String zProductRatePlanChargeId, Decimal amount) {
                                                                        
                                                                        String effectiveDate = DateTime.now().format('yyyy-MM-dd','PST');     
                                                                        
                                                                        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
                                                                        
                                                                        request.ZAccount = new Zuora.zObject('Account');
                                                                        request.ZAccount.setValue('Id', zAccountId);
                                                                        
                                                                        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
                                                                        request.SubscribeOptions.GenerateInvoice = true;
                                                                        request.SubscribeOptions.ProcessPayments = false;
                                                                        
                                                                        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
                                                                        request.PreviewOptions.EnablePreviewMode = false; 
                                                                        
                                                                        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
                                                                        
                                                                        Zuora.zObject subscription = new Zuora.zObject('Subscription');
                                                                        subscription.setValue('ContractEffectiveDate', effectiveDate);
                                                                        subscription.setValue('ServiceActivationDate', effectiveDate);
                                                                        subscription.setValue('TermType', 'TERMED');
                                                                        subscription.setValue('InitialTerm', '1');
                                                                        subscription.setValue('RenewalTerm', '1');
                                                                        subscription.setValue('AutoRenew', false);
                                                                        
                                                                        system.debug('********** zuora subscription **********'+subscription);
                                                                        system.debug('********** request.SubscriptionData.Subscription **********'+request.SubscriptionData.Subscription);
                                                                        
                                                                        request.SubscriptionData.Subscription = subscription;
                                                                        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
                                                                        
                                                                        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                                                                        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);
                                                                        
                                                                        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
                                                                        ratePlanCharge.setValue('ProductRatePlanChargeId', zProductRatePlanChargeId);
                                                                        ratePlanCharge.setValue('Price', amount);
                                                                        
                                                                        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                                                                        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
                                                                        
                                                                        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                                                                        ratePlanData.setValue('RatePlan', ratePlan);
                                                                        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
                                                                        
                                                                        ratePlanDataList.add(ratePlanData);                  
                                                                        request.SubscriptionData.RatePlanData = ratePlanDataList;         
                                                                        system.debug('********** request **********'+request);                                                                     
                                                                        
                                                                        return request;                 
                                                                    }
    
    public void generateHpmUrl() {
        SMS_HPM_Settings__c hpmSettings = SMS_HPM_Settings__c.getAll().get('MyPaymentMethods');
        
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
        
        iframeUrl= getHpmUrlBase() + '?method=requestPage&' + toQueryString(parameterMap, true) + '&field_accountId=' + zAccountId + '&field_creditCardCountry=USA';
        
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
    
    private void makeBORPayment(String zAccountId, String paymentMethodId, Decimal amount){
        
        Zuora.zObject zPayment = new Zuora.zObject('Payment');
        
        zPayment.setValue('AccountId', zAccountId);
        zPayment.setValue('AppliedCreditBalanceAmount', amount);
        zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST'));
        zPayment.setValue('PaymentMethodId', paymentMethodId);
        zPayment.setValue('Status', 'Processed');
        zPayment.setValue('Type', 'Electronic');        
        zPayment.setValue('Comment', 'Broker of Record Payment for ' + Datetime.now().format('yyyy-MM-dd','PST'));
        List<Zuora.zObject> zPayments = new List<Zuora.zObject>();    
        zPayments.add(zPayment);
        System.debug('*** zPayments: ' + zPayments);
        List<Zuora.zApi.SaveResult> zSaveResultPayment = zUtilInstance.zcreate(zPayments);
        
        if(!isSavePaymentMethod){                
            List<Zuora.zApi.DeleteResult> zDeleteResults;
            zDeleteResults = zUtilInstance.zdelete('PaymentMethod', new List<String> { paymentMethodId });                
        }
        
        for (Zuora.zApi.SaveResult result : zSaveResultPayment ) {
            system.debug('*** Payment result: ' + result);
            if(!result.Success) {
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error : errors) {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message');
                    system.debug('*************Create BOR Payment:' + errorCode + '-' + message);
                    throw new CustomException('Create BOR Payment:' + errorCode + '-' + message); 
                }               
            }
            else {
                List<Zuora.zObject> payment = zUtilInstance.zquery('SELECT GatewayResponse, Status, ReferenceId FROM Payment WHERE Id = \'' + result.Id + '\'');
                if (payment.get(0).getValue('Status') != 'Processed')
                    throw new CustomException('Create BOR Payment:' + (String) payment.get(0).getValue('GatewayResponse'));
                else{                   
                    borPayment.Reference_Id__c = (String) payment.get(0).getValue('ReferenceId');
                    borPayment.Status__c = 'Payment';
                    borPayment.Status_Message__c = 'Payment has been collected from Broker and added to account’s credit balance';
                }
            }
        }            
        
        String zInvoiceId = createSubscription(zAccountId, amount); 
        
        createCreditBalanceAdjustment(zInvoiceId, amount, 'Decrease');        
    }
    
    public PageReference paymentMethodFailed() {
        clearErrors();
        
        this.hasCreateNewPaymentMethodError = true;
        //String error = Apexpages.currentPage().getParameters().get('message');
        system.debug('error is ************ '+error);
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
        errorString = text;
        system.debug('Error is *************'+errorString);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorString));
        
        return null;
    }
    
    public void clearErrors() {
        this.hasCreateNewPaymentMethodError = false;
        this.getCreateNewPaymentMethodError = '';
        
        this.hasChargeNewPaymentMethodError = false;
        this.getChargeNewPaymentMethodError = '';
        
        this.hasUnspecifiedError = false;
        this.getUnspecifiedError = '';
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
        public Boolean HasExpired { get; set; }
    }
    
    public class CustomException extends Exception {}
}