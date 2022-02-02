public class NewAgentApplication {
    
    public String mls { get; set; }
    public list<SelectOption> brokerOffices {get; set;} 

    public MRIS_Application__c newapplication { get; set; }
    public License__c license { get; set; }
    public String brokerCode { get; set; }
    public String nrdsId { get; set; }
    public String association { get; set; }
    public Account brokerOffice { get; set; }
    public Contact agentContact { get; set; }
    //public Contact contact { get; set; }
    public String subscriberId { get; set; }
    public String applicationId { get; set; }
    public String trendLoginName { get; set; }
    
    /* Flag variables */
    public Boolean licenseBlock { get; set; }
    public Boolean brokerBlock { get; set; }
    public Boolean contactBlock { get; set; }
    public Boolean agreementBlock { get; set; }
    public Boolean submitBlock { get; set; }
    public Boolean isNRDSId { get; set; }
    
    public String licenseBlockState { get; set; }
    public String brokerBlockState { get; set; }
    public String contactBlockState { get; set; }
    public String agreementBlockState { get; set; }
    public String submitBlockState { get; set; }
        
    public String licenseStatus { get; set; }
    public Subscriptions__c subscription { get; set; }
    public Integer progressValue { get; set; }
    
    public Boolean isApproved { get; set; }
    public Boolean isExpired { get; set; }
    public Boolean isRejected { get; set; }
    public Boolean isActive { get; set; }
    public String applicationName { get; set; }
    public list<SelectOption> options {get; set;} 
    List<MRIS_Application__c> licenses { get; set; }
    public String searchTerm {get; set;}
    public string associationsStr { get; set; }
    
    public NewAgentApplication() {
       // mls = Apexpages.currentpage().getparameters().get('mls');
        mls = 'BRIGHT';
        //if(String.isBlank(mls))
          //  mls = 'BRIGHT';
        
        license = new License__c();
        agentContact = new Contact();
        subscription = new Subscriptions__c();
        brokerOffice = new Account();
        
        licenseBlock = true;
        brokerBlock = false;
        contactBlock = false;
        agreementBlock = false;
        submitBlock = false;
        isNRDSId = false;
        
        licenseBlockState = 'Started';
        brokerBlockState = 'Not Started';
        contactBlockState = 'Not Started';
        agreementBlockState = 'Not Started';
        submitBlockState = 'Not Started';
        licenseStatus = 'New';
        subscriberId = '';
        progressValue = 0;
        findAllAssociations();
    }
    
    public List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('',' --None-- '));
        //options.add(new SelectOption('','License State'));
        options.add(new SelectOption('DC','DC'));
        options.add(new SelectOption('DE','DE'));
        options.add(new SelectOption('MD','MD'));
        options.add(new SelectOption('NJ','NJ'));
        options.add(new SelectOption('PA','PA'));
        options.add(new SelectOption('VA','VA'));
        options.add(new SelectOption('WV','WV'));
        return options;
    }
    
    public List<SelectOption> getTypes() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('',' --None-- '));
        //options.add(new SelectOption('','License Type'));
        options.add(new SelectOption('Salesperson','Salesperson'));
        options.add(new SelectOption('Associate Broker','Associate Broker'));
        return options;
    }
    
    public List<SelectOption> getSuffix(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Suffix__c.getDescribe();
        
        List<Schema.PicklistEntry> picklists = fieldResult.getPicklistValues();
        //options.add(new SelectOption('','Suffix'));
        for( Schema.PicklistEntry f : picklists)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getSalutation(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> picklists = fieldResult.getPicklistValues();
        //options.add(new SelectOption('','Salutation'));
        for( Schema.PicklistEntry f : picklists)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    @remoteAction     
    public static list<Account> findAllAssociations() {
        list<SelectOption> options = new list<SelectOption>();
        Map<string, string> assocValues = new Map<string, string>();
        List<Account> associationAccounts = [SELECT Id, Name, Account_Name__c 
                                             FROM   Account 
                                             WHERE  Type = 'Association' 
                                             AND    Status__c = 'Active' 
                                             //AND    (Primary_Service_Jurisdiction__c = :mls OR Secondary_Service_Jurisdiction__c = :mls)
                                             ORDER BY Account_Name__c ASC ];
        //options.add(new SelectOption('', '-- Choose --'));
        /*options.add(new SelectOption('', 'Association'));
        for(Account a : associationAccounts) {
            options.add(new SelectOption(a.Id, a.Account_Name__c));
            assocValues.put(a.Id, a.Account_Name__c.replaceAll('/', ''));
            }
            system.debug('----assocValues--->'+assocValues);
            string associationsStr = JSON.serialize(assocValues);
            */
        return associationAccounts;
    }    
    
    public PageReference verifyLicenseDetails() {
        try { 
            licenses = new List<MRIS_Application__c>();
            
            if(String.isBlank(subscriberId) && String.isBlank(applicationId) && String.isNotBlank(license.Name) && String.isNotBlank(license.License_State__c) && String.isNotBlank(license.License_Type__c)) {         
                
                licenses = [SELECT Id, Name 
                            FROM   MRIS_Application__c
                            WHERE  License_Number__c = :license.Name
                            AND    License_State__c = :license.License_State__c
                            AND    License_Type__c = :license.License_Type__c
                            AND Status__c IN ('New','Approved')];
        
                if(licenses.size() > 0) {
                    licenseStatus = 'Existing';                           
                }
                else {
                    licenseStatus = 'New';                   
                    licenseBlockState = 'Completed';
                    licenseBlock = true;
                    if(brokerBlockState == 'Not Started' || brokerBlockState == 'Started') {
                        brokerBlockState = 'Started';
                        brokerBlock = true;
                        progressValue = 20;                
                    }
                    else if(contactBlockState == 'Not Started' || contactBlockState == 'Started')
                        continueBrokerCode();
                    else if(agreementBlockState == 'Not Started' || agreementBlockState == 'Started') 
                        continueContactSave();
                    else if(submitBlockState  == 'Not Started' || submitBlockState == 'Started') 
                        acceptAgreement();
                }
            }
            else if(String.isNotBlank(applicationId) && String.isBlank(subscriberId)) {
                licenses = [SELECT Id, Name 
                            FROM   MRIS_Application__c
                            WHERE  Name = :applicationId];
        
                if(licenses.size() > 0) {
                    licenseStatus = 'Existing';                           
                }
                else
                    throw new CustomException('No application exist for this application id.');                
            }
            else if(String.isBlank(applicationId) && (String.isNotBlank(subscriberId) || String.isNotBlank(trendLoginName))) {
                List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                if(String.isNotBlank(subscriberId))
                    subscriptions = [SELECT Id, Name, Status__c FROM Subscriptions__c WHERE Name = :subscriberId];
                
                if(String.isNotBlank(trendLoginName))
                    subscriptions = [SELECT Id, Name, Status__c FROM Subscriptions__c WHERE TREND_Login_Name__c = :trendLoginName];
                    
                if(subscriptions.Size() > 0) {
                    subscription = subscriptions[0];
                    system.debug('-----------------------> subscription.Status__c'+subscription.Status__c);
                    if(subscription.Status__c == 'Inactive') {
                        licenseStatus = 'Terminated';
                        
                        if(subscriberId != null && String.isNotBlank(subscriberId)) {
                            licenses = [SELECT Id, Name 
                                        FROM   MRIS_Application__c
                                        WHERE  Agent_Subscription_ID__r.Name = :subscriberId
                                        AND    Application_Type__c = 'Reinstatement' 
                                        AND    Status__c IN ('New','Approved')];
                        }
                        else if(trendLoginName != null && String.isNotBlank(trendLoginName)) {
                            licenses = [SELECT Id, Name 
                                        FROM   MRIS_Application__c
                                        WHERE  Agent_Subscription_ID__r.TREND_Login_Name__c = :trendLoginName
                                        AND    Application_Type__c = 'Reinstatement' 
                                        AND    Status__c IN ('New','Approved')];                        
                        }
                        else
                            throw new CustomException('Invalid input for subscriber');
                        
                        if(licenses.size() > 0) {
                            licenseStatus = 'ReinstateExist';                           
                        }
                                
                    }
                    else if(subscription.Status__c == 'In Progress') {
                        licenses = [SELECT Id, Name 
                                    FROM   MRIS_Application__c
                                    WHERE  Agent_Subscription_ID__c = :subscription.Id
                                    AND    Application_Type__c = 'New Agent' 
                                    AND    Status__c IN ('New','Approved')];
                        if(licenses.Size() > 0) 
                            licenseStatus = 'Existing';
                        else
                            licenseStatus = 'Active';                        
                    }
                    else
                        licenseStatus = 'Active'; 
                }
                else{
                    if(String.isNotBlank(trendLoginName))
                        throw new CustomException('Invalid Trend Login Name');
                    else
                        throw new CustomException('Invalid Subscription ID');
                }
            }
            else
                throw new CustomException('Invalid criteria');
 
        }
        catch(Exception e) {
            licenseStatus = 'New';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        } 
      
      return null;
    }
    
    public void loadBrokerTREND(){
        try{
            String searchText = '%'+ brokerCode + '%';    
            brokerOffices = new List<SelectOption>();
            List<Account> accounts = [SELECT Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c  
                                      FROM   Account
                                      WHERE  Account_Name__c LIKE :searchText 
                                      AND    Status__c = 'Active'
                                      AND    (Primary_Service_Jurisdiction__c = :mls OR Secondary_Service_Jurisdiction__c = :mls)
                                    ];
            for(Account a : accounts)
                brokerOffices.add(new SelectOption(a.Id, a.Account_Name__c));
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }    
    
    public void verifyBrokerCode() {
        try {
            if(String.isBlank(brokerCode))
                throw new CustomException('Invalid Broker Code');
                
            brokerBlockState = 'Started';
            brokerOffice = new Account();
            List<Account> account = new List<Account>();
            
            if(mls == 'TREND' || mls == 'BRIGHT') {
                account = [SELECT Id, Name, Account_Name__c, City__c, State__c, County__c,QAS_Mailing_County__c,Zip__c  
                                     FROM   Account 
                                     WHERE  Id = :brokerCode 
                                     AND    Status__c = 'Active'
                                     AND    (Primary_Service_Jurisdiction__c = :mls OR Secondary_Service_Jurisdiction__c = :mls)];
            }
            else {
                account = [SELECT Id, Name, Account_Name__c, City__c, State__c, County__c,QAS_Mailing_County__c,Zip__c  
                                     FROM   Account 
                                     WHERE  Id = :brokerCode 
                                     AND    Status__c = 'Active'];            
            }
            if(account.size() > 0) {
                brokerOffice = account[0];
                brokerBlockState = 'Verified';
                continueBrokerCode();  
            }
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Broker Office Not Available'));
           
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }    
    }
    
    public void continueBrokerCode() {
        if(brokerBlockState == 'Verified') {
            brokerBlockState = 'Completed';
            
            if(contactBlockState == 'Not Started' || contactBlockState == 'Started') {
                contactBlock = true;
                contactBlockState = 'Started';
                progressValue = 40;
            }
            else {
                if(agreementBlockState == 'Started')
                    continueContactSave();
                else if(agreementBlockState == 'Completed')
                    acceptAgreement();    
            }    
        }   
    } 
    
    public void verifyContactDetails(){
        try{
            if(String.isBlank(agentContact.FirstName))
                throw new CustomException('Please');
            if(String.isBlank(agentContact.LastName))
                throw new CustomException('Invalid Broker Code');
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    
    public void continueContactSave() {
        contactBlockState = 'Completed';
        if(agreementBlockState == 'Not Started' || agreementBlockState == 'Started') {
            agreementBlock = true; 
            agreementBlockState = 'Started';
            progressValue = 60;
        }
        else {
            acceptAgreement();
        }
    }
    
    public void acceptAgreement() {
        agreementBlockState = 'Completed';
        submitBlock = true; 
        submitBlockState = 'Started';
        progressValue = 80;    
    }
    
    public PageReference saveApplication(){
        try {
            
            MRIS_Application__c newApplication = new MRIS_Application__c(); 
            
            if(String.isBlank(association)){
                system.debug('+++association'+association);
                newApplication.Subscription_Type__c = 'Licensee/Non Realtor';
                newApplication.Type__c = 'Agent';
            }
            else {
                Account assoc = [SELECT Id,Name, Account_Name__c,Shareholder_Board__c FROM Account WHERE Id = :association];
                  system.debug('+++association'+association);

                if(assoc.Account_Name__c.containsIgnoreCase('None')){
                    newApplication.Subscription_Type__c = 'Licensee/Non Realtor';
                    newApplication.Type__c = 'Agent';
                }
                else {
                    if(assoc.Shareholder_Board__c == 'Yes'){
                    newApplication.Subscription_Type__c = 'Realtor/Shareholder';
                    newApplication.Type__c = 'Agent';
                }
                else if(assoc.Shareholder_Board__c == 'No' || assoc.Shareholder_Board__c == 'None' || assoc.Shareholder_Board__c == '' || assoc.Shareholder_Board__c == NULL){
                     newApplication.Subscription_Type__c = 'Realtor/Non Shareholder';
                     newApplication.Type__c = 'Agent';
                }
                }
                
                
                newApplication.Association_Board_Affiliation__c = association;
                system.debug('+++newApplication.Association_Board_Affiliation__c'+newApplication.Association_Board_Affiliation__c);
            }        
            
            newApplication.City__c = agentContact.City__c;
            newApplication.Country__c = agentContact.Country__c;
            newApplication.County__c = agentContact.County__c;
            
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            newApplication.Application_Expire_Date__c = System.now().AddDays(maxDays);
            newApplication.First_Name__c = agentContact.FirstName;
            newApplication.Last_Name__c = agentContact.LastName;
            newApplication.License_Number__c = license.Name;
            newApplication.License_Expiration_Date__c = license.License_Expiration_Date__c;
            newApplication.License_State__c = license.License_State__c;
            newApplication.License_Type__c = license.License_Type__c;
            newApplication.Middle_Name__c = agentContact.Middle_Name__c;
            newApplication.Mobile_Phone__c = agentContact.Phone;
            if(String.isBlank(agentContact.Nickname__c))
                agentContact.Nickname__c = agentContact.FirstName;
            newApplication.Nickname__c = agentContact.Nickname__c;
            newApplication.Suffix__c= agentContact.Suffix__c;
            newApplication.NRDS_ID__c = nrdsId;
            newApplication.Company_Code__c = brokerCode; //brokerOffice.Id;
            newApplication.Primary_Phone__c = agentContact.Phone;
            newApplication.Private_Email__c = agentContact.Email;
            newApplication.Private_Phone__c = agentContact.Phone;
            newApplication.Public_Email__c = agentContact.Email;
            newApplication.Salutation__c = agentContact.Salutation;
            newApplication.State__c = agentContact.State__c;
            newApplication.Status__c = 'New'; 
            newApplication.Service_Jurisdiction__c = mls; //mls; did based on SAL-1033     
            
            
            newApplication.Zip__c = agentContact.Zip__c;
            newApplication.Application_Type__c = 'New Agent';
          
            
            /* String asContact, borContact, agentContact;// cannot send to agent as he is not an user yet
            

                                                FROM   Relationship__c 
                                                WHERE  Broker_Office__c = :brokerOffice.Id
                                                AND    Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                                AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                               ]){
                if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asContact = relationship.Subscription__r.Contact__c;
                    newApplication.AS_Email__c = relationship.Subscription__r.Private_Email__c;
                }
                else if(relationship.Relationship_Type__c == 'Broker Of Record'){
                    borContact = relationship.Subscription__r.Contact__c;
                    newApplication.BOR_Email__c = relationship.Subscription__r.Private_Email__c;
                }                  
            }*/
            
            /* BRIGHT billing jurisdiction logic based on office County */
            
            brokerOffice = [SELECT Id, Name, Account_Name__c, City__c, State__c, County__c,QAS_Mailing_County__c,Zip__c  
                                     FROM   Account 
                                     WHERE  Id = :brokerCode];
            //brokerOffice = account[0];
           
            newapplication.Billing_Jurisdiction__c=newApplication.Service_Jurisdiction__c;
            system.debug('----Billing-----'+newapplication.Billing_Jurisdiction__c);
                if(newapplication.Service_Jurisdiction__c == 'BRIGHT') {
                if(brokerOffice.County__c!= null) {
                    List<BRIGHT_Billing_Jurisdiction__c> countiesList = new List<BRIGHT_Billing_Jurisdiction__c>();
                    countiesList = [SELECT Id, 
                                           Name, 
                                           County__c, 
                                           State__c, 
                                           Billing_Jurisdiction__c 
                                    FROM   BRIGHT_Billing_Jurisdiction__c 
                                    WHERE  County__c = :brokerOffice.County__c
                                    AND    State__c = :brokerOffice.State__c];
                                             system.debug('-------County__c -----'+ brokerOffice.County__c);
                                             system.debug('-------State__c -----'+ brokerOffice.State__c);
                        
                    if(countiesList.Size() > 0) 
                        newapplication.Billing_Jurisdiction__c = countiesList[0].Billing_Jurisdiction__c;
                                                                          
                } 
                
            }
            system.debug('----Billing1-----'+newapplication.Billing_Jurisdiction__c);
            system.debug('----Billing22-----'+newapplication);
            insert newApplication;
            
            PageReference pageRef = new PageReference('/apex/NewApplicationStatus?Type=New&Id=' + newApplication.Id);
            return pageRef;
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('*** Error in saveApllication:' + e.getStackTraceString() );
            return null;    
        } 
    }
    
    public pageReference redirectToPayment() {
        try{
            verifyLicenseDetails();
            
            PageReference pageRef;
            if(licenses.size() > 0 && licenseStatus != 'Active'){
                pageRef = new PageReference('/apex/NewApplicationStatus?Id=' + licenses[0].Id);
                //return pageRef;
            }
            return pageRef;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('*** Error in saveApllication:' + e.getStackTraceString() );
            return null;
        }
    }
    
    public pageReference redirectToReinstate() {
        try{
            verifyLicenseDetails();
            PageReference pageRef;
            system.debug('subscription--->'+subscription);
            if(subscription != null && subscription.Id != null)
                pageRef = new PageReference('/apex/ReinstateSubscriber?Id=' + subscription.Name);
            return pageRef;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('*** Error in saveApllication:' + e.getStackTraceString() );
            return null;
        }
    }    
    
    
    public pageReference redirectApplication(){
        
        PageReference ref = new PageReference('/apex/ApplicationOrReinstate?mls='+mls+'&app='+true);
        return ref;
    }
    
    public pageReference redirectReinstate(){
        PageReference ref = new PageReference('/apex/ApplicationOrReinstate? mls='+mls+'&app='+false);
        return ref;
    }
    
 
    // JS Remoting action called when searching for a broker code
    @RemoteAction
    public static List<Account> searchBroker(String searchTerm, String mlsName) {
        List<Account> accounts = new List<Account>();
        if(mlsName == 'TREND')
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'TREND\' OR Secondary_Service_Jurisdiction__c = \'TREND\') AND IsPersonAccount = false');
        else if(mlsName == 'BRIGHT')
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'BRIGHT\' OR Secondary_Service_Jurisdiction__c = \'BRIGHT\') AND IsPersonAccount = false');               
        else
            accounts = Database.query('Select Id, Name, Account_Name__c, City__c, State__c, QAS_Mailing_County__c,Zip__c from Account where (name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (Primary_Service_Jurisdiction__c = \'MRIS\' OR Primary_Service_Jurisdiction__c = NULL OR Secondary_Service_Jurisdiction__c = \'MRIS\') AND IsPersonAccount = false');
        
        return accounts;
    }
    
    @RemoteAction
    public static map<string, string> verifyLicense(String licNumber, String state, string type) {
     Map<string, string> response = new Map<string, string>();
        try { 
            List<MRIS_Application__c> licenses = new List<MRIS_Application__c>();
           
            
            if(String.isNotBlank(licNumber) && String.isNotBlank(state) && String.isNotBlank(type)) {                         
                licenses = [SELECT Id, Name 
                            FROM   MRIS_Application__c
                            WHERE  License_Number__c = :licNumber
                            AND    License_State__c = :state
                            AND    License_Type__c = :type
                            AND Status__c IN ('New','Approved')];
        
                if(licenses.size() > 0) {
                    response.put('status', 'Existing'); 
                    response.put('applicationId', licenses[0].Id);                           
                }
                else {
                    response.put('status', 'New'); 
                    response.put('applicationId', null);  
                }            
            }
            else {
                response.put('status', 'Failed'); 
                response.put('msg', 'Missing data');  
            }
        }
        catch(Exception e) {
            response.put('status', 'Failed'); 
            response.put('msg', e.getMessage()); 
        }
        return response;
        //return JSON.serialize(response);
    }    
        
    public class CustomException extends Exception{}
}