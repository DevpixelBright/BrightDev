public class SMS_SendOutstandNotification_Controller {
    public Integer outstandingCount { get; set; }
    //public Integer activeOutstandingCount { get; set; }
    //public Integer inactiveOutstandingCount { get; set; }
    
    public Decimal minimumBalance { get; set; }
    public Integer invoiceAge { get; set; }
    
    //transient public Boolean showButton { get; set; }
    //transient public Boolean active { get; set; }
    //transient public Boolean inactive { get; set; }
    //private Set<String> Status;
    
    transient public List<BillingAccount> finalBillingAccounts { get; set; }
    transient public String finalAccounts { get; set; }
    
    public List<Zuora__CustomerAccount__c> billingAccounts { get; set; }
    transient public String activeOutstandingAccountsStr { get; set; }    
    transient public String batchStatus { get; set; }
    transient public String batchStatusMsg { get; set; }
    
    public String offsetId;
    //public string statusSelected {get; set;}
    
    public List<String> selectedBJs {get; set;}
    public List<SelectOption> BJOptions { get; set;}    
    public List<String> selectedSJs { get; set;}
    public List<SelectOption> SJOptions { get; set;}   
    public Date thresholdate ;
    
    public SMS_SendOutstandNotification_Controller(){
        
        checksSelected = new list<string>{'Active', 'Inactive'};
        minimumBalance = 0;
        invoiceAge = 0;
        selectedSJs = new List<String>();
        
        Schema.DescribeFieldResult SJfield = Subscriptions__c.Service_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> SJvalues = SJfield.getPicklistValues();        
        SJOptions = new List<SelectOption>();        
        for(Schema.PicklistEntry e : SJvalues) {
            SJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        
        selectedBJs = new List<String>();        
        Schema.DescribeFieldResult BJfield = Subscriptions__c.Billing_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> BJvalues = BJfield.getPicklistValues();
        BJOptions = new List<SelectOption>();
        
        for(Schema.PicklistEntry e : BJvalues) {
            BJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
                
        billingAccounts = new List<Zuora__CustomerAccount__c>();
        //activeOutstandingCount = 0;
        //inactiveOutstandingCount = 0; 
        
        //activeInactiveAccounts();
        findOutstandingSubscriptions();
        if(outstandingCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'There are no subscriptions with an outstanding balance'));
        }
    }
    
    
    /*
    public void activeInactiveAccounts(){
        
        thresholdate = date.valueOf(system.today().addDays(-invoiceAge)); 
        string query = 'SELECT count() FROM Zuora__CustomerAccount__c WHERE Zuora__Balance__c > '+ minimumBalance;
        query += ' AND Email_Invoice_PDF__c = false';  //AND Oldest_Invoice_Due__c <= '+ thresholdate
        query += ' AND SubscriptionID__c != null';
        
        string activequery = query + ' AND Subscription__r.Status__c = \'Active\'';
        activeOutstandingCount = getTotalRecordsCount(activequery);
        
        string inactivequery = query + ' AND Subscription__r.Status__c = \'Inactive\'';
        inactiveOutstandingCount = getTotalRecordsCount(inactivequery);
        
    }
    */
    
    public void findOutstandingSubscriptions(){
        
        thresholdate = date.valueOf(system.today().addDays(-invoiceAge));
        billingAccounts = new List<Zuora__CustomerAccount__c>();
        
        string query = 'SELECT Id, Name, SubscriptionID__c, Oldest_Invoice_Due__c, Zuora__Balance__c, Subscription__r.Status__c, Subscription__r.Service_Jurisdiction__c, Subscription__r.Billing_Jurisdiction__c FROM Zuora__CustomerAccount__c';
        query += ' WHERE Zuora__Balance__c > '+minimumBalance;
        query += ' AND Email_Invoice_PDF__c = false ';
        query += ' AND SubscriptionID__c != null';
        query += ' AND Subscription__r.Status__c IN :checksSelected';
        
        if(offsetId != null && offsetId != '')
            query += ' AND Id <: offsetId';
        else{
            query += ' AND Oldest_Invoice_Due__c <= :thresholdate';
        }
        
        if(selectedSJs != null && !selectedSJs.isEmpty()){
            query += ' AND Subscription__r.Service_Jurisdiction__c in : selectedSJs';
        }
        if(selectedBJs != null && !selectedBJs.isEmpty()){
            query += ' AND Subscription__r.Billing_Jurisdiction__c in : selectedBJs';
        }
        
        query += ' Order by Id desc limit 25000';
        billingAccounts = database.query(query);
        //system.debug('---query-->'+query);
        //system.debug('----billingAccounts--->'+billingAccounts);
        
        finalBillingAccounts = new List<BillingAccount>();
        for(Zuora__CustomerAccount__c zca : billingAccounts ){
            BillingAccount ba = new BillingAccount(zca);
            finalBillingAccounts.add(ba);
        }
        
        if(!billingAccounts.isEmpty() ){
            offsetId = billingAccounts[billingAccounts.size()-1].Id;
        }
        
        outstandingCount = billingAccounts.size();
        /* Convert result list into JSON format for Angular JS output */
        activeOutstandingAccountsStr = JSON.serialize(finalBillingAccounts);
        billingAccounts.clear();  
    }
    
    public list<string> checksSelected {get; set;}
    public void statusFilter(){
        offsetId = null;
        findOutstandingSubscriptions();
    }
    
    public void NextResult(){
        findOutstandingSubscriptions();  
    }
        
    public void serviceBillingFilter(){
        offsetId = null;
        findOutstandingSubscriptions();
    }
    /*
    public Static integer getTotalRecordsCount(String query) {
        integer totalRecordsCount = 0;
        if(query != null && query != ''){
            String encoded = EncodingUtil.urlEncode(query, 'UTF-8');
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v20.0/query/?q='+encoded);
            req.setMethod('GET');
            system.debug('---endoded--->'+encoded);
            system.debug('----endoint--->'+URL.getSalesforceBaseUrl().getHost());
            string autho = 'Bearer '+ userInfo.getsessionId();
            req.setHeader('Authorization', autho);
            
            try{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                string response = res.getBody();
                System.debug(response);
                totalRecordsCount = integer.valueOf(response.substring(response.indexOf('totalSize":') + 11, response.indexOf(',')));
                //system.debug('----totalRecordsCount--->>'+totalRecordsCount);
            }catch(Exception e){
                
                system.debug('---exception-->>'+e.getMessage());
            }
        }
        return totalRecordsCount;
    }
    */
    
    public PageReference generateInvoicePdfs(){ 
        System.debug('*** finalAccounts: ' + finalAccounts); 
        
        batchStatusMsg = '';
        batchStatus = '';
        List<String> billingAccountIds = new List<String>();
        
        billingAccountIds = (List<String>)JSON.deserialize(finalAccounts, List<String>.class);
        System.debug('*** billingAccountIds : ' + billingAccountIds);         
        
        if(billingAccountIds.size() > 0){
            SMS_OutstandingBalanceInvoiceResults batchJob = new SMS_OutstandingBalanceInvoiceResults(billingAccountIds);
            Database.executeBatch(batchJob, 15);
            batchStatusMsg += 'Batch process has been initiated for (' + billingAccountIds.size() + ') subscriptions. Please allow few minutes to run the batch processes';
            batchStatusMsg += ' and check your mail for the list of subscriptions for which emails have been initiated.';
            batchStatus = 'Success';
        }
        else{
            batchStatus = 'Failed';
            batchStatusMsg += 'Select either active or inactive or both subscriptions';
        }
        
        return null;
    }
    
    public class BillingAccount{
        public String Id { get; set; }
        public String name { get; set; }
        public String subscriptionId { get; set; }
        //public String zuoraId { get; set; }
        public Decimal accountBalance { get; set; }
        public String status { get; set; }
        public Date oldestInvoiceDate { get; set; }
        public Boolean isSelected { get; set; }
        //public String emailId { get; set; }
        public string billJurisdiction {get; set;}
        public string servJurisdiction {get; set;}
        
        public BillingAccount(Zuora__CustomerAccount__c billingAccount){
            id = billingAccount.Id;
            name = billingAccount.Name;
            subscriptionId = billingAccount.SubscriptionID__c;
            //zuoraId = billingAccount.Zuora__Zuora_Id__c;
            accountBalance = billingAccount.Zuora__Balance__c.setScale(2);
            status = billingAccount.Subscription__r.Status__c;
            oldestInvoiceDate = billingAccount.Oldest_Invoice_Due__c;
            isSelected = true;
            //emailId = billingAccount.Subscription__r.Private_Email__c;
            billJurisdiction = billingAccount.Subscription__r.Billing_Jurisdiction__c;
            servJurisdiction = billingAccount.Subscription__r.Service_Jurisdiction__c;
                
        }
    }
}