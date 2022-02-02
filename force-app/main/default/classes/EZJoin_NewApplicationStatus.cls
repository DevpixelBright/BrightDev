public class EZJoin_NewApplicationStatus {
    public String applicationId { get; set; }
    public MRIS_Application__c application { get; set; }
    public Subscriptions__c subscription { get; set; }
    public Boolean isValid { get; set; }
    public List<wrapper> wrapperList { get; set;}

    public BillingAndPayment_Settings__c billAndPaymentSettings;
    public String trendLoginName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }
    
    
    public EZJoin_NewApplicationStatus() {
        wrapperList = new List<wrapper>();
      
        try {
            applicationId = ApexPages.currentPage().getParameters().get('Id');
            if(String.isBlank(applicationId))
                throw new CustomException('Invalid application id');
            
            isValid = false;
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
            }
            
            List<Subscriptions__c> subs = new List<Subscriptions__c>() ;
            subs = [SELECT Id, Name, Contact_Type__c, Subscription_Type__c, Status__c,
                    Contact__c, Contact__r.Name, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name, 
                    City__c, State__c, QAS_Mailing_County__c, Zip__c,
                    Private_Email__c, Primary_Phone__c, Mobile_Phone__c,
                    Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, Contact__r.Suffix__c,
                    Date_Terminated__c, Service_Jurisdiction__c, Billing_Jurisdiction__c, BRIGHT_LoginName__c, TREND_Login_Name__c
                    FROM  Subscriptions__c 
                    WHERE Id = :application.Agent_Subscription_ID__c
                   ];
        }
        catch(Exception e) {
            isValid = false; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));   
        }  
    }
    
    
    public void validateLoginName(){
        isLoginNameAvailable = true;
        loginErrorMessage = trendLoginName;
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
    
    
    public void createSubscription(){
        Boolean isLoginNameAvailable = true;
        String loginNameError = null;
        try{
            if(application.Service_Jurisdiction__c == 'BRIGHT' || application.Service_Jurisdiction__c == 'Trend'){
                if(string.isBlank(trendLoginName))
                    throw new CustomException('Please enter Login Name');
                LoginName.isAvailable(null, trendLoginName);
            }
        }
        catch(Exception e){
            isLoginNameAvailable = true;
            loginNameError = e.getMessage();
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            if(!isLoginNameAvailable){
                throw new CustomException (loginNameError);
            }
            List<Subscriptions__c> subs = new List<Subscriptions__c>();
            subs = [SELECT ID, Name, Status__c FROM Subscriptions__c WHERE SFDC_Application__c =: application.Id];
            
            if(subs.size() > 0)
                subscription = subs[0];
            else if(application.Status__c == 'Approved' && subs.size() == 0){
                
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
                
                Contact c  = new Contact();
                
                c.FirstName = application.First_Name__c;
                c.LastName = application.Last_Name__c;
                c.Middle_Name__c = application.Middle_Name__c;
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
                c.Agent_Office_Phone__c = Application.Agent_Office_Phone__c;
                
                c.city__c = application.Company_Code__r.City__c;
                c.Zip__c = application.Zip__c;
                c.County__c = application.Company_Code__r.zip__c;
                c.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
                
                //Mailing Address
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
                
                //Billing Address
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
                
                //Mailing Address Account to Subscription
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
                
                //Billing Address Account to Subscription
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
                
                if(application.Subscription_Type__c == 'Personal Assistant' || application.Subscription_Type__c == 'Personal Assistant to Appraiser'){
                    Related_Agent__c ra = new Related_Agent__c();
                    ra.Personal_Assistant_Sub_ID__c = s.Id;
                    ra.Personal_Assistant__c = s.Contact__c;
                    ra.Status__c = 'In Progress';
                    insert ra; 
                }
                

            }
        }
        
        Catch(Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
    @AuraEnabled
    public static String method1() {
        try {
            Contact c = new Contact();
            c.FirstName = 'Srini';
            c.LastName = 'Vas';
            c.Salutation = 'Mr.';
            c.accountId = '001J000001TjvQEIAZ';
            c.County__c = 'Fairfax';
            insert c;
            
            return c.Id;
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class wrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String SubId;
        public list<Subscriptions__c> sub {get; set;}
        public list<Contact> con {get; set;}
        //public wrapper(String name, String value){
        public wrapper( Contact Con, Subscriptions__c Sub){
            this.name = Con.name;
            this.SubId = Sub.Id;
        }
    }
    
    
    public class CustomException extends Exception{}    
}