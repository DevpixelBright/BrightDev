public class NewApplicationStatus {
    
    public String applicationId { get; set; }
    public MRIS_Application__c application { get; set; }
    public Subscriptions__c subscription { get; set; }
    public Boolean isValid { get; set; }
    public Boolean isSubExist { get; set; }
    public Boolean showcontinue { get; set; } 
    public Boolean showPaymentButton { get; set; }
    public String hpmUrl { get; private set; }
    public String zAccountId { get; set; }
    public String paymentMethodId { get; set; }
    public Decimal amount { get; set; }
    public Boolean subActivated { get; set; }
    public Boolean isPaymentSuccess { get; set; }
    public String paymentError { get; set; }
    public String wrapperUrl { get; set; } 
    public String orderId { get; set; }
    public Boolean showPayment { get; set; } 
    public String redirectUrl { get; private set; }
    public String cancelUrl { get; private set; }
    public String iframeDomain { get; private set; } 
     
    public Boolean isActivateNoPayment { get; set; }
    
    private SMS_ZuoraUtil zUtilInstance;
    private Zuora.zApi.LoginResult zLoginResult;    
    
    public BillingAndPayment_Settings__c billAndPaymentSettings;
    public String trendLoginName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }
    
    public NewApplicationStatus() {
        try {
            applicationId = ApexPages.currentPage().getParameters().get('Id');
            if(String.isBlank(applicationId))
                throw new CustomException('Invalid application id');
            
            isValid = false;
            showPaymentButton = false;
            showcontinue = false;
            isSubExist = false;
            isActivateNoPayment = false;
            isLoginNameAvailable = false;
            loginErrorMessage = 'Please enter a login name';
            if(ApexPages.currentPage().getParameters().get('Type') != null && ApexPages.currentPage().getParameters().get('Type') == 'New'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Application submitted successfully'));
            }
            
            List<MRIS_Application__c> applications = [SELECT Id, Name, Status__c, Application_Expire_Date__c, CreatedDate, Application_Type__c,                                                             
                                                      Salutation__c, Suffix__c, First_Name__c, Last_Name__c, Middle_Name__c, Nickname__c,
                                                      Service_Jurisdiction__c, Billing_Jurisdiction__c, City__c, State__c, County__c, Zip__c,
                                                      Mobile_Phone__c, Primary_Phone__c, Private_Phone__c, Private_Email__c,  Public_Email__c,  
                                                      Voicemail__c, VM_Ext__c, Home_Fax__c, Website__c , NRDS_ID__c, Professional_Designations__c , Disabilities__c, 
                                                      Agent_Office_Fax__c, Agent_Office_Phone__c, Agent_Subscription_ID__c, Agent_Subscription_ID__r.Name, 
                                                      Company_code__c, Company_Code__r.Name, Company_Code__r.City__c, Company_Code__r.Zip__c, 
                                                      Company_Code__r.County__c, Company_Code__r.State__c, Company_Code__r.QAS_Mailing_County__c, Company_Code__r.Id, 
                                                      Subscription_Type__c, Type__c, Association_Board_Affiliation__c,
                                                      License_Number__c, License_Expiration_Date__c, License_State__c, License_Type__c                                                             
                                                      FROM  MRIS_Application__c
                                                      WHERE Id = :applicationId];
            if(applications.Size() != 1)
                throw new CustomException('Application id does not exist');
            
            isValid = true;
            application = applications[0];
            if(application.Billing_Jurisdiction__c != null)
                billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(application.Billing_Jurisdiction__c);
            
            if(application.Status__c == 'Approved'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your application has been approved.'));
                if(billAndPaymentSettings != null){
                    if(billAndPaymentSettings.Bypass_Payment__c)                        
                        isActivateNoPayment = true;
                    else
                        showContinue = true;
                }
                else
                    showContinue = true;             
            }
            
            List<Subscriptions__c> subs = new List<Subscriptions__c>() ;
            
            if(application.Application_Type__c == 'Reinstatement') {
                subs = [SELECT Id, Name, Contact_Type__c, Subscription_Type__c, Status__c,
                        Contact__c, Contact__r.Name, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name, 
                        City__c, State__c, QAS_Mailing_County__c, Zip__c,
                        Private_Email__c, Primary_Phone__c, Mobile_Phone__c,
                        Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, Contact__r.Suffix__c,
                        Date_Terminated__c, Service_Jurisdiction__c, Billing_Jurisdiction__c, BRIGHT_LoginName__c, TREND_Login_Name__c
                        FROM  Subscriptions__c 
                        WHERE Id = :application.Agent_Subscription_ID__c
                       ];
                
                if(application.Status__c == 'New' && subs[0].Status__c == 'Inactive')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Any request for change in details will be updated once the approver approves it.'));            
            }
            else {
                subs = [SELECT Id, Name, Contact_Type__c, Subscription_Type__c, Status__c,
                        Contact__c, Related_Location_Broker_Office__c,
                        City__c, State__c, QAS_Mailing_County__c, Zip__c,
                        Private_Email__c, Primary_Phone__c, Mobile_Phone__c,
                        Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, Contact__r.Suffix__c,
                        Date_Terminated__c, Service_Jurisdiction__c, Billing_Jurisdiction__c, BRIGHT_LoginName__c, TREND_Login_Name__c
                        FROM   Subscriptions__c 
                        WHERE  SFDC_Application__c = :application.Id
                       ];
            } 
            if(subs.size() == 1) {
                isSubExist = true;
                subscription = subs[0];
                showContinue = false;
                isLoginNameAvailable = true;
                if((subscription.Status__c == 'In Progress' || subscription.Status__c == 'Inactive') && !isActivateNoPayment)
                    showPaymentButton = true;
                
                if(subscription.Service_Jurisdiction__c == 'TREND') 
                    trendLoginName = subscription.TREND_Login_Name__c;   
                if(subscription.Service_Jurisdiction__c == 'BRIGHT') 
                    trendLoginName = subscription.BRIGHT_LoginName__c;            
            }
            else if(subs.size() > 1) 
                throw new CustomException('Multiple subscriptions associated with this application');
            else {
                isSubExist = false;                
            }
        }
        catch(Exception e) {
            isValid = false;
            isSubExist = false; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));   
        }  
    }    
    
    public void validateLoginName(){
        isLoginNameAvailable = true;
        loginErrorMessage = trendLoginName;
        //trendLoginName = trendLoginName.trim();
        trendLoginName = trendLoginName.normalizeSpace();
        try{           
            if(String.isBlank(trendLoginName))
                throw new CustomException('Please enter Login Name');
                
            LoginName.isAvailable(null, trendLoginName);       
                      
        }
        catch(Exception e){
            isLoginNameAvailable = false; 
            loginErrorMessage = e.getMessage() ;
        }
        
    }
    
    
    public void createSubcription() {
        Boolean isLoginNameAvailable = true;
        String loginNameError = null;
        try{
            if(application.Service_Jurisdiction__c == 'TREND' || application.Service_Jurisdiction__c == 'BRIGHT'){
                if(String.isBlank(trendLoginName))
                    throw new CustomException('Please enter Login Name');
                    
                LoginName.isAvailable(null, trendLoginName);
            }
                      
        }
        catch(Exception e){
            isLoginNameAvailable = false; 
            loginNameError = e.getMessage() ;
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            if(!isLoginNameAvailable){ 
                throw new CustomException(loginNameError);
            }
            List<Subscriptions__c> subs = new List<Subscriptions__c>() ;
            subs = [SELECT Id,Name, Status__c FROM Subscriptions__c WHERE SFDC_Application__c = :application.Id]; 
            
            if(subs.size() > 0)
                subscription = subs[0];  
            else if(application.Status__c == 'Approved' && subs.size() == 0) {
                
                /*if(application.Service_Jurisdiction__c == 'TREND' && String.isBlank(trendLoginName))
                    throw new CustomException('Please enter TREND login name');
                
                if(application.Service_Jurisdiction__c == 'TREND' && String.isNotBlank(trendLoginName)) {
                    List<Subscriptions__c> trendUsers = [SELECT Id FROM Subscriptions__c WHERE TREND_Login_Name__c = :trendLoginName];
                    if(trendUsers.Size() > 0)
                        throw new CustomException('TREND login name already taken. Please enter different one.');    
                }
                */
                
                
                //Get Mailing and Billing address from account object
                Account acct = [Select a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type,
                                a.QAS_Billing_Country__c, a.QAS_Mailing_Country__c, a.QAS_Billing_County__c, a.QAS_Mailing_County__c, 
                                a.QAS_Billing_Street_Direction__c, a.QAS_Mailing_Street_Direction__c, a.QAS_Billing_Street_Type__c, a.QAS_Mailing_Street_Type__c, 
                                a.QAS_Billing_Unit_Type__c, a.QAS_Mailing_Unit_Type__c, a.QAS_Mailing_Record_Type__c, a.QAS_Mailing_POBox__c,
                                a.QAS_Billing_Record_Type__c, a.QAS_Billing_POBox__c,  
                                a.Trading_As__c, a.TickerSymbol, a.SystemModstamp, a.Street_Type__c, a.Street_Number__c, 
                                a.Street_Number_Suffix__c, a.Street_Name__c, a.Street_Direction__c, a.Status__c, a.State__c, 
                                a.SicDesc, a.Shareholder_Board__c, a.Rating, a.PrismCompanyOffice__c, a.PrismCompanyCode__c, 
                                a.PrismAddressID__c, a.PrismAccountID__c, a.Phone, a.ParentId, a.PIN__c, a.OwnerId, a.OfficeKey__c, 
                                a.Num_Active_Subs__c, a.Num_Active_Office_Sec_NC__c, a.Name, a.NRDS_ID__c, a.MasterRecordId, 
                                a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.JigsawCompanyId, a.Jigsaw, a.IsDeleted, 
                                a.IsCustomerPortal, a.Industry, a.Id, a.Fax, a.Description, a.Date_Terminated__c, a.Date_Joined__c, 
                                a.CreatedDate, a.CreatedById, a.County__c, a.Country__c, a.Copy_Address_to_Billing__c,
                                a.Company_Type__c, a.City__c, a.BrokerAddress__c, a.Box__c, a.Billing_Zip__c, a.Billing_Zip_4__c, 
                                a.Billing_Unit_Type__c, a.Billing_Unit_Number__c, a.Billing_Street_Type__c, a.Billing_Street_Number__c,
                                a.Billing_Street_Number_Suffix__c, a.Billing_Street_Name__c, a.Billing_Street_Direction__c,
                                a.Billing_State__c, a.Billing_County__c, a.Billing_Country__c, a.Billing_City__c, a.Billing_Box__c, 
                                a.Billing_Addl_Display_Name__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry,
                                a.BillingCity, a.Addl_Display_Name__c, a.Account_Name__c, a.AccountSource 
                                From Account a 
                                where a.id=:application.Company_code__c
                               ];
                
                //Set Application Status to Approved after creating the contact
                Contact c = new Contact();
                
                c.FirstName = application.First_Name__c;
                c.LastName = application.Last_Name__c;
                c.Middle_Name__c = application.Middle_Name__c;
                c.Suffix__c = application.Suffix__c;
                c.Phone = application.Primary_Phone__c;
                c.MobilePhone = application.Mobile_Phone__c;
                c.Salutation = application.Salutation__c;
                c.Voicemail__c = application.Voicemail__c;
                c.VM_Ext__c = application.VM_Ext__c;
                c.Nickname__c = application.Nickname__c;
                c.Home_Fax__c = application.Home_Fax__c;
                c.AccountId = application.Company_Code__c;
                c.Email = application.Private_Email__c;
                c.Public_Email__c = application.Public_Email__c;
                c.Website__c = application.Website__c;
                c.NRDS_ID__c = application.NRDS_ID__c;
                c.Professional_Designations__c = application.Professional_Designations__c;
                c.Disabilities__c = application.Disabilities__c;
                c.Status__c = 'In Progress';
                c.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
                
                c.City__c = application.Company_Code__r.City__c;
                c.Zip__c = application.Company_Code__r.Zip__c;
                c.County__c = application.Company_Code__r.County__c;
                c.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
                
                //insert Mailing address of Account to Contact
                c.Street_Number__c = acct.Street_Number__c;
                c.Street_Name__c = acct.Street_Name__c;
                c.Street_Type__c = acct.Street_Type__c;
                c.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;
                c.Street_Direction__c = acct.Street_Direction__c;
                c.Unit_Type__c = acct.Unit_Type__c;
                c.Unit__c = acct.Unit__c;
                c.Addl_Display_Name__c = acct.Addl_Display_Name__c;
                c.Box__c = acct.Box__c;
                c.Zip__c = acct.Zip__c;
                c.Zip_4__c = acct.Zip_4__c;
                c.Fax = application.Agent_Office_Fax__c;
                c.Home_Fax__c = application.Home_Fax__c;
                c.City__c = acct.City__c;
                c.State__c = acct.State__c;
                c.County__c = acct.County__c;
                c.Country__c = acct.Country__c;
                c.QAS_Mailing_Country__c = acct.QAS_Mailing_Country__c; 
                c.QAS_Mailing_County__c = acct.QAS_Mailing_County__c; 
                c.QAS_Mailing_Street_Direction__c = acct.QAS_Mailing_Street_Direction__c; 
                c.QAS_Mailing_Street_Type__c = acct.QAS_Mailing_Street_Type__c; 
                c.QAS_Mailing_Unit_Type__c = acct.QAS_Mailing_Unit_Type__c; 
                c.QAS_Mailing_POBox__c = acct.QAS_Mailing_POBox__c;
                c.QAS_Mailing_Record_Type__c = acct.QAS_Mailing_Record_Type__c;
                
                //insert Billing address of Account to Contact
                c.Billing_Street_Number__c = acct.Billing_Street_Number__c;
                c.Billing_Street_Name__c = acct.Billing_Street_Name__c;
                c.Billing_Street_Type__c = acct.Billing_Street_Type__c; 
                c.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;               
                c.Billing_Street_Direction__c = acct.Billing_Street_Direction__c;
                c.Billing_Unit_Type__c = acct.Billing_Unit_Type__c;
                c.Billing_Box__c = acct.Billing_Box__c;
                c.Billing_Addl_Display_Name__c = acct.Billing_Addl_Display_Name__c;
                c.Billing_Zip__c = acct.Billing_Zip__c;
                c.Billing_Zip_4__c = acct.Billing_Zip_4__c;
                c.Zip_4__c = acct.Zip_4__c;
                c.Billing_City__c = acct.Billing_City__c;
                c.Billing_State__c = acct.Billing_State__c;
                c.Billing_County__c = acct.Billing_County__c;
                c.Billing_Country__c = acct.Billing_Country__c;
                c.QAS_Billing_Country__c = acct.QAS_Billing_Country__c; 
                c.QAS_Billing_County__c = acct.QAS_Billing_County__c;
                c.QAS_Billing_Street_Direction__c = acct.QAS_Billing_Street_Direction__c;
                c.QAS_Billing_Street_Type__c = acct.QAS_Billing_Street_Type__c;
                c.QAS_Billing_Unit_Type__c = acct.QAS_Billing_Unit_Type__c;
                c.QAS_Billing_POBox__c = acct.QAS_Billing_POBox__c;
                c.QAS_Billing_Record_Type__c = acct.QAS_Billing_Record_Type__c;
                
                c.Service_Jurisdiction__c = application.Service_Jurisdiction__c;                
                c.AddressValidationStatus__c = 'Not Required';
                
                insert c;       
                
                Subscriptions__c s = new Subscriptions__c();
                s.Contact__c = c.Id;
                s.SFDC_Application__c = application.Id;
                s.City__c = application.Company_Code__r.City__c;
                s.Zip__c = application.Company_Code__r.Zip__c;
                s.County__c = application.Company_Code__r.County__c;
                s.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
                s.Related_Location_Broker_Office__c = application.Company_Code__r.Id;
                s.Subscription_Type__c = application.Subscription_Type__c;
                s.Contact_Type__c = application.Type__c;
                s.Public_Email__c = application.Public_Email__c;
                s.Primary_Phone__c = application.Primary_Phone__c;
                s.Home_Fax__c = application.Home_Fax__c;
                s.Voicemail__c = application.Voicemail__c;
                s.VM_Ext__c = application.VM_Ext__c;
                s.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
                s.Fax__c = application.Agent_Office_Fax__c;
                s.Home_Fax__c = application.Home_Fax__c;
                s.Mobile_Phone__c = application.Mobile_Phone__c;
                s.Home_Fax__c = application.Home_Fax__c;              
                s.Website__c = application.Website__c;
                s.Related_Location_Broker_Office__c = application.Company_Code__c;
                s.Status__c = 'In Progress';
                s.NRDS_ID__c = application.NRDS_ID__c;
                
                
                //insert Mailing address of Account to Subscription
                s.Street_Number__c = acct.Street_Number__c;
                s.Street_Name__c = acct.Street_Name__c;
                s.Street_Type__c = acct.Street_Type__c;
                s.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;
                s.Street_Direction__c = acct.Street_Direction__c;
                s.Unit_Type__c = acct.Unit_Type__c;
                s.Unit__c = acct.Unit__c;
                s.Addl_Display_Name__c = acct.Addl_Display_Name__c;
                s.Box__c = acct.Box__c;
                s.Zip__c = acct.Zip__c;
                s.Zip_4__c = acct.Zip_4__c;
                s.City__c = acct.City__c;
                s.Private_Email__c = application.Private_Email__c;
                s.State__c = acct.State__c;
                s.County__c = acct.County__c;
                s.Country__c = acct.Country__c;
                s.QAS_Mailing_Country__c = acct.QAS_Mailing_Country__c; 
                s.QAS_Mailing_County__c = acct.QAS_Mailing_County__c; 
                s.QAS_Mailing_Street_Direction__c = acct.QAS_Mailing_Street_Direction__c; 
                s.QAS_Mailing_Street_Type__c = acct.QAS_Mailing_Street_Type__c; 
                s.QAS_Mailing_Unit_Type__c = acct.QAS_Mailing_Unit_Type__c; 
                s.QAS_Mailing_POBox__c = acct.QAS_Mailing_POBox__c;
                s.QAS_Mailing_Record_Type__c = acct.QAS_Mailing_Record_Type__c; 
                
                
                //insert Billing address of Account to Subscription
                s.Billing_Street_Number__c = acct.Billing_Street_Number__c;
                s.Billing_Street_Name__c = acct.Billing_Street_Name__c;
                s.Billing_Street_Type__c = acct.Billing_Street_Type__c; 
                s.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;               
                s.Billing_Street_Direction__c = acct.Billing_Street_Direction__c;
                s.Billing_Unit_Type__c = acct.Billing_Unit_Type__c;
                s.Billing_Box__c = acct.Billing_Box__c;
                s.Billing_Addl_Display_Name__c = acct.Billing_Addl_Display_Name__c;
                s.Billing_Zip__c = acct.Billing_Zip__c;
                s.Billing_Zip_4__c = acct.Billing_Zip_4__c;
                s.Zip_4__c = acct.Zip_4__c;
                s.Billing_City__c = acct.Billing_City__c;
                s.Billing_State__c = acct.Billing_State__c;
                s.Billing_County__c = acct.Billing_County__c;
                s.Billing_Country__c = acct.Billing_Country__c;
                s.QAS_Billing_Country__c = acct.QAS_Billing_Country__c; 
                s.QAS_Billing_County__c = acct.QAS_Billing_County__c;
                s.QAS_Billing_Street_Direction__c = acct.QAS_Billing_Street_Direction__c;
                s.QAS_Billing_Street_Type__c = acct.QAS_Billing_Street_Type__c;
                s.QAS_Billing_Unit_Type__c = acct.QAS_Billing_Unit_Type__c;
                s.QAS_Billing_POBox__c = acct.QAS_Billing_POBox__c;
                s.QAS_Billing_Record_Type__c = acct.QAS_Billing_Record_Type__c;
                s.AddressValidationStatus__c = 'Not Required';
                s.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
                s.Billing_Jurisdiction__c = application.Billing_Jurisdiction__c;
                
                if(application.Service_Jurisdiction__c == 'TREND' && String.isNotBlank(trendLoginName))                                 
                    s.TREND_Login_Name__c = trendLoginName;
                
                if(application.Service_Jurisdiction__c == 'BRIGHT' && String.isNotBlank(trendLoginName))
                    s.BRIGHT_LoginName__c = trendLoginName;
                
                insert s;    
                
                //Insert Association if exists
                if (application.Association_Board_Affiliation__c != null) {
                    Related_Association__c ra = new Related_Association__c();
                    ra.Association__c = application.Association_Board_Affiliation__c;
                    ra.Primary__c  = true;
                    ra.Subscription__c = s.id;
                    ra.Status__c = 'Active';
                    insert ra;
                }              
                
                License__c l = new License__c();
                l.Name = application.License_Number__c;
                l.License_Expiration_Date__c = application.License_Expiration_Date__c;
                l.License_State__c = application.License_State__c;
                l.License_Type__c = application.License_Type__c;
                l.Contact__c = c.id;
                if (!((null == application.License_Number__c) || ''.equals(application.License_Number__c))) {
                    insert l;
                    System.debug('application.License_Number__c -->' + application.License_Number__c);
                    
                    Subscription_License__c sl = new Subscription_License__c(); 
                    sl.License__c = l.id;
                    sl.Subscription__c = s.id;  
                    
                    insert sl;                   
                }
                
                subscription = [SELECT   Id, 
                                Name,
                                Contact__c,
                                Contact__r.Name,
                                Contact_Type__c,
                                Subscription_Type__c,
                                Status__c,
                                Related_Location_Broker_Office__c,
                                Related_Location_Broker_Office__r.Name,
                                Related_Location_Broker_Office__r.IsPersonAccount,
                                City__c,
                                State__c,
                                QAS_Mailing_County__c,
                                Zip__c,
                                Private_Email__c,
                                Primary_Phone__c,
                                Mobile_Phone__c,
                                Contact__r.FirstName,
                                Contact__r.LastName,
                                Contact__r.Middle_Name__c,
                                Contact__r.Nickname__c,
                                Contact__r.Suffix__c,
                                Service_Jurisdiction__c,
                                Billing_Jurisdiction__c,
                                BRIGHT_LoginName__c, 
                                TREND_Login_Name__c   
                                FROM Subscriptions__c 
                                WHERE Id = :s.Id];
                
                application.Agent_Subscription_ID__c = s.Id;
                //application.Status__c = 'Completed';
                update application;
                
                isSubExist = true;
                showcontinue = false;
                showPaymentButton = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Subscription setup completed'));
                
                if(isActivateNoPayment){
                    showPaymentButton = false; 
                    activateSubscription();                
                }                
            }
            
        }
        Catch(Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        
        
    }   
    
    public void createOrder() {
        try {
            List<SMS_CoreMapping__c> productRatePlans = new List<SMS_CoreMapping__c>();
            
            if(String.isBlank(subscription.Billing_Jurisdiction__c))
                subscription.Billing_Jurisdiction__c = 'MRIS';
            
            if(subscription.Status__c == 'In Progress') {
                productRatePlans = [SELECT  ZuoraProductId__c, 
                                    ZuoraOnetimeProductRatePlanId__c, 
                                    ZuoraRecurringProductRatePlanId__c,
                                    Term_Duration__c
                                    FROM   SMS_CoreMapping__c
                                    WHERE  Type__c = :subscription.Contact_Type__c
                                    AND    SubType__c = :subscription.Subscription_Type__c
                                    AND    Status__c = 'New'
                                    AND    IsPrimaryFlag__c = true
                                    AND    Billing_Jurisdiction__c = :subscription.Billing_Jurisdiction__c];
            }
            else if(subscription.Status__c == 'Inactive') {
                Integer reinstateDiff = 0;
                String mapStatus = 'Reinstatement > 30';
                if(subscription.Date_Terminated__c != null && Date.Today().daysBetween(subscription.Date_Terminated__c) >= -30)
                    mapStatus = 'Reinstatement <= 30';
                
                productRatePlans = [SELECT  ZuoraProductId__c, 
                                    ZuoraOnetimeProductRatePlanId__c, 
                                    ZuoraRecurringProductRatePlanId__c,
                                    Term_Duration__c
                                    FROM   SMS_CoreMapping__c
                                    WHERE  Type__c = :subscription.Contact_Type__c
                                    AND    SubType__c = :subscription.Subscription_Type__c
                                    AND    Status__c = :mapStatus
                                    AND    IsPrimaryFlag__c = true
                                    AND    Billing_Jurisdiction__c = :subscription.Billing_Jurisdiction__c];            
            }
            
            if(productRatePlans.Size() > 0 && String.isNotBlank(productRatePlans[0].ZuoraRecurringProductRatePlanId__c)) {           
                
                zUtilInstance = new SMS_ZuoraUtil();
                zLoginResult = zUtilInstance.zlogin();         
                
                String accountQuery = 'SELECT Id, AutoPay, DefaultPaymentMethodId FROM Account WHERE Status = \'Active\' AND SubscriptionID__c = \'' + subscription.Name + '\'';
                List<Zuora.zObject> account = zUtilInstance.zquery(accountQuery);
                if(account.Size() == 0)
                    throw new CustomException('Zuora account not found. Please contact Customer Support for more details');
                
                zAccountId = (String)account[0].getValue('Id');
                generateHpmUrl();             
                
                SMS_Order__c order = new SMS_Order__c();                
                order.Name = 'Order Id';
                order.Token__c = '';
                order.Zuora_Account_Id__c = zAccountId;
                order.MRIS_Subscription_Id__c = subscription.id;
                order.Status__c = 'Active';
                order.Bypass_Payment__c = false;
                order.Private_Email__c = 'test@test.com';
                order.IsEzJoinApplication__c = true;
                insert order;
                
                String salt = String.valueOf(order.id);
                String secretKey = 'secret_key';
                String algorithmName = 'HmacSHA256';
                
                Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
                string token = EncodingUtil.base64Encode(hmacData);
                
                order.Token__c = token;
                order.Name = order.id;
                update order;
                DateTime effectiveDate = System.Now();
                
                SMS_OrderItem__c orderItem = new SMS_OrderItem__c();
                orderItem.Zuora_Product_Id__c = productRatePlans[0].ZuoraProductId__c;
                orderItem.Zuora_Product_Name__c = '';
                orderItem.OneTimeProductRatePlanId__c = productRatePlans[0].ZuoraOnetimeProductRatePlanId__c;
                orderItem.OneTimeProductRatePlanName__c = '';
                orderItem.RecurringProductRatePlanId__c = productRatePlans[0].ZuoraRecurringProductRatePlanId__c;
                orderItem.RecurringProductRatePlanName__c = '';
                
                
                if(subscription.Status__c == 'In Progress' && billAndPaymentSettings != null && billAndPaymentSettings.Bypass_Initial_Fee__c )
                    orderItem.OneTimeProductRatePlanId__c = null;
                else if(subscription.Status__c == 'Inactive' && billAndPaymentSettings != null && billAndPaymentSettings.Bypass_Reinstatement__c) 
                    orderItem.OneTimeProductRatePlanId__c = null;
                
                
                orderItem.Initial_Term__c = productRatePlans[0].Term_Duration__c;
                orderItem.Renewal_Term__c = productRatePlans[0].Term_Duration__c;
                orderItem.Contract_Effective_Date__c = effectiveDate;
                orderItem.Service_Activation_Date__c = effectiveDate; 
                orderItem.IsCore__c = true;
                orderItem.Order_Id__c = order.Id;
                orderItem.Bundle_Id__c = '';
                orderItem.Bundle_Name__c = '';
                orderItem.DiscountProductRatePlanId__c = '';
                orderItem.DiscountProductRatePlanName__c = '';
                orderItem.TermDuration__c = 3;
                orderItem.IsDiscountOnly__c = false;                    
                insert orderItem;
                
                //Schedule batch apex  will execute after ten minutes  after insert 
                
                String query = 'SELECT Id,Status__c FROM SMS_Order__c WHERE Token__c =  \'' + token + '\'';              
                String jobName = 'SMS Order Update -' + String.ValueOf(Math.random());
                
                SMS_OrderBatch updateOrder = new SMS_OrderBatch(query);
                String cronID = System.scheduleBatch(updateOrder, jobName, 10);
                
                String encodedToken = EncodingUtil.urlEncode(order.Token__c, 'UTF-8');
                iframeDomain = URL.getSalesforceBaseUrl().toExternalForm();
                
                String path = Label.Generic_Payment_Wrapper + '/eProcess/NewApplicationStatus?Id=' + applicationId;
                redirectUrl = path;
                cancelUrl = path;
                
                wrapperUrl = Label.Generic_Payment_Wrapper + '/SMS/SMS_GenericPaymentWrapper?token=' + encodedToken  + '#' + path;
                orderId = order.Id;
                showPayment = true;
                showcontinue = false;
            }
            else
                throw new CustomException('Core mapping not found');
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }                     
    }
    
    private void generateHpmUrl() {
        SMS_HPM_Settings__c hpmSettings = SMS_HPM_Settings__c.getAll().get('Default');
        
        String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        
        
        Map<String, String> parameterMap = new Map<String, String> {
            'id' => '2c92c0f958aa45650158b04a50f72cc7',
                'tenantId' => '11693',
                'timestamp' => String.valueOf(DateTime.now().getTime()),
                'token' => token + 'VzOYpPZFP4d8jDNPvRrQgX-rZunvrZeoTxtXtqdzVYg='
                };        
                    
                    String queryParametersToHash = toQueryString(parameterMap, false);
        String queryParametersMd5Hash = EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryParametersToHash)))));
        
        String signature = queryParametersMd5Hash.replace('+', '/').replace('-', '_');
        
        parameterMap.put('token', token);
        parameterMap.put('signature', signature);
        
        hpmUrl = getHpmUrlBase() + '?method=requestPage&' + toQueryString(parameterMap, true) + '&field_accountId=' + zAccountId + '&field_creditCardCountry=USA';       
        
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
    
    public void makePayment(){
        try {
            if(String.IsBlank(paymentMethodId))
                throw new CustomException('Invalid payment method id');
            
            zUtilInstance = new SMS_ZuoraUtil();
            zLoginResult = zUtilInstance.zlogin();
            
            Zuora.zObject zPayment = new Zuora.zObject('Payment');
            zPayment.setValue('AccountId', zAccountId);
            zPayment.setValue('AppliedCreditBalanceAmount', 579);
            zPayment.setValue('EffectiveDate', DateTime.now().format('yyyy-MM-dd','PST'));
            zPayment.setValue('PaymentMethodId', paymentMethodId);
            zPayment.setValue('Status', 'Processed');
            zPayment.setValue('Type', 'Electronic');
            
            List<Zuora.zApi.SaveResult> results = zUtilInstance.zcreate(new List<Zuora.zObject>{zPayment}); 
            
            for(Zuora.zApi.SaveResult result : results) {
                system.debug('*** payment result: ' + result);
                if(result.Success) {                    
                    List<Zuora.zObject> payment = zUtilInstance.zQUERY('SELECT GatewayResponse, Status, ReferenceId FROM Payment WHERE Id = \'' + result.Id + '\'');
                    
                    if (payment.get(0).getValue('Status') != 'Processed') {
                        List<Zuora.zApi.DeleteResult> zDeleteResults;
                        zDeleteResults = zUtilInstance.zdelete('PaymentMethod', new List<String> { paymentMethodId }); 
                    }
                    else {               
                        List<Zuora.zApi.DeleteResult> zDeleteResults;
                        zDeleteResults = zUtilInstance.zdelete('PaymentMethod', new List<String> { paymentMethodId });              
                    }
                }
                else
                    throw new CustomException('Payment Creation Failed');
            }
            
            isPaymentSuccess = true;
        }
        catch(Exception e) {
            isPaymentSuccess = false;
            paymentError = e.getMessage();
        } 
    }
    
    public void updateTrendSub(){
        try{
            if(subscription.Service_Jurisdiction__c == 'TREND')
                subscription.TREND_Login_Name__c = trendLoginName;
            
            
            update subscription;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Login name already exists. Please enter a new one'));
        }
    }
    
    public void activateWithOutPayment(){
        if(application.Application_Type__c == 'Reinstatement'){
            activateSubscription();    
        }
        else
            createSubcription();            
    } 
    
    public void activateSubscription() {
        try {
            
            subscription.ZuoraIntegrationWorkflowBypass__c = true;
            subscription.AddressValidationStatus__c = 'To be verify';
            
            if(isActivateNoPayment)
                subscription.ZuoraIntegrationWorkflowBypass__c = false;
            
            if(subscription.Status__c == 'In Progress')
                subscription.Status__c = 'Active';
            
            if(subscription.Status__c == 'Inactive') {
                subscription.Status__c = 'Active';
                subscription.Status_Change_Reason__c = 'Reinstate';
                subscription.Date_Reinstated__c = Date.today();
                if(isActivateNoPayment){
                    subscription.Status_Change_Fee__c = 'No Charge';
                }
            }
            
            //completing the application if the subcription is activated.
            if(application.Status__c != 'Completed'){
                application.Status__c = 'Completed';
                update application;
            }            
            
            update subscription;
            //updateTrendSub();
            
            showPayment = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Subscription activated successfully'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));    
        }
    }
    
    
    public class CustomException extends Exception{}
}