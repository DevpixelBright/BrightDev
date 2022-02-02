/**
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Class contains Personal Assistant navigates to EZJoin once approved to pay methods for 
EZJOIN application.
*
* SAL- 2118
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Usha
* @version        1.0
* @created        2020-04-23
* @modified       2020-04-27
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Usha
* 2020-04-27      Updated the code for creation of Subscription, Order and to activate Subscription.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class EZJoin_PaymentApprovalNavigation {
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to retrieve the picklist values of a field from an object.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @param    fieldName		Field API name
* @param    objectName		Object API name
* @return   List			A list of wrapper class with picklist label and value
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/        
    @AuraEnabled
    public static MRIS_Application__c getApplicationDetails(String applicationId) {
        try {
            if(String.isBlank(applicationId))
                throw new CustomException('Invalid application id');
            
            MRIS_Application__c app = new MRIS_Application__c(); 
            List<MRIS_Application__c> applications = [SELECT Id, Name, CreatedDate,Status__c, Application_Expire_Date__c,                                                            
                                                      Salutation__c, First_Name__c, Last_Name__c,Company_Code__r.Name,Company_Code__r.Account_Name__c,
                                                      City__c, State__c, Zip__c, Primary_Phone__c, Private_Email__c,Related_Agents__c
                                                      FROM  MRIS_Application__c
                                                      WHERE Name = :applicationId];
            if(!applications.isEmpty()) {
                app = applications[0];
            }
            return app;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
        
    }
    
    @AuraEnabled
    public static void validateLoginName(String brightLoginName, Boolean isLoginNameAvailable, String loginErrorMessage) {
        isLoginNameAvailable = true;
        loginErrorMessage = brightLoginName;
        brightLoginName = brightLoginName.normalizeSpace();
        try {
            if(String.isBlank(brightLoginName))
                throw new CustomException('Please enter Login Name');
            LoginName.isAvailable(null, brightLoginName);
        }
        Catch(Exception e) {
            isLoginNameAvailable = false;
            loginErrorMessage = e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static void createSubscription(String applicationId) {
        
        try {
            if(applicationId == null)
                throw new CustomException('Invalid application');
            
            Account acct = new Account();
            Subscriptions__c subscription = new Subscriptions__c(); 
            MRIS_application__c application = new MRIS_application__c();
            List<MRIS_Application__c> applications = [SELECT Id, Name, CreatedDate, Status__c, Application_Expire_Date__c, Type__c, Subscription_Type__c,                                                            
                                                      Suffix__c, Salutation__c, First_Name__c, Last_Name__c, Middle_Name__c, Nickname__c, Mobile_Phone__c,
                                                      Company_Code__r.Name, Company_Code__r.Account_Name__c,Voicemail__c, VM_Ext__c, Home_Fax__c,
                                                      City__c, State__c, Zip__c, Primary_Phone__c, Related_Agents__c, Company_Code__c,Agent_Office_Fax__c,Billing_Jurisdiction__c,
                                                      Private_Email__c, Public_Email__c, Website__c,NRDS_ID__c, Professional_Designations__c, Disabilities__c,Service_Jurisdiction__c,
                                                      Agent_Office_Phone__c, Company_Code__r.City__c, Company_Code__r.Zip__c, Company_Code__r.County__c,Company_Code__r.QAS_Mailing_County__c
                                                      FROM  MRIS_Application__c
                                                      WHERE Name = :applicationId];
            if(!applications.isEmpty()) {
                application = applications[0];
            }
            
            List<Subscriptions__c> subs = new List<Subscriptions__c>() ;
            subs = [SELECT Id,Name, Status__c FROM Subscriptions__c WHERE SFDC_Application__c = :application.Id]; 
            
            acct = [Select a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type,
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
            
            Contact c = new Contact();
            
            c.FirstName = application.First_Name__c;
            c.LastName = application.Last_Name__c;
            c.Middle_Name__c = application.Middle_Name__c;
            c.Suffix__c = application.Suffix__c;
            c.Phone = application.Primary_Phone__c;
            c.MobilePhone = application.Mobile_Phone__c;
            c.Salutation = application.Salutation__c;
            //c.Voicemail__c = application.Voicemail__c;
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
            
            subscription.Contact__c = c.Id;
            subscription.SFDC_Application__c = application.Id;
            subscription.City__c = application.Company_Code__r.City__c;
            subscription.Zip__c = application.Company_Code__r.Zip__c;
            subscription.County__c = application.Company_Code__r.County__c;
            subscription.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
            subscription.Related_Location_Broker_Office__c = application.Company_Code__r.Id;
            subscription.Subscription_Type__c = application.Subscription_Type__c;
            subscription.Contact_Type__c = application.Type__c;
            subscription.Public_Email__c = application.Public_Email__c;
            subscription.Primary_Phone__c = application.Primary_Phone__c;
            subscription.Home_Fax__c = application.Home_Fax__c;
           // subscription.Voicemail__c = application.Voicemail__c;
            subscription.VM_Ext__c = application.VM_Ext__c;
            subscription.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
            subscription.Fax__c = application.Agent_Office_Fax__c;
            subscription.Home_Fax__c = application.Home_Fax__c;
            subscription.Mobile_Phone__c = application.Mobile_Phone__c;
            subscription.Home_Fax__c = application.Home_Fax__c;              
            subscription.Website__c = application.Website__c;
            subscription.Related_Location_Broker_Office__c = application.Company_Code__c;
            subscription.Status__c = 'In Progress';
            subscription.NRDS_ID__c = application.NRDS_ID__c;
            
            
            //insert Mailing address of Account to Subscription
            subscription.Street_Number__c = acct.Street_Number__c;
            subscription.Street_Name__c = acct.Street_Name__c;
            subscription.Street_Type__c = acct.Street_Type__c;
            subscription.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;
            subscription.Street_Direction__c = acct.Street_Direction__c;
            subscription.Unit_Type__c = acct.Unit_Type__c;
            subscription.Unit__c = acct.Unit__c;
            subscription.Addl_Display_Name__c = acct.Addl_Display_Name__c;
            subscription.Box__c = acct.Box__c;
            subscription.Zip__c = acct.Zip__c;
            subscription.Zip_4__c = acct.Zip_4__c;
            subscription.City__c = acct.City__c;
            subscription.Private_Email__c = application.Private_Email__c;
            subscription.State__c = acct.State__c;
            subscription.County__c = acct.County__c;
            subscription.Country__c = acct.Country__c;
            subscription.QAS_Mailing_Country__c = acct.QAS_Mailing_Country__c; 
            subscription.QAS_Mailing_County__c = acct.QAS_Mailing_County__c; 
            subscription.QAS_Mailing_Street_Direction__c = acct.QAS_Mailing_Street_Direction__c; 
            subscription.QAS_Mailing_Street_Type__c = acct.QAS_Mailing_Street_Type__c; 
            subscription.QAS_Mailing_Unit_Type__c = acct.QAS_Mailing_Unit_Type__c; 
            subscription.QAS_Mailing_POBox__c = acct.QAS_Mailing_POBox__c;
            subscription.QAS_Mailing_Record_Type__c = acct.QAS_Mailing_Record_Type__c; 
            
            
            //insert Billing address of Account to Subscription
            subscription.Billing_Street_Number__c = acct.Billing_Street_Number__c;
            subscription.Billing_Street_Name__c = acct.Billing_Street_Name__c;
            subscription.Billing_Street_Type__c = acct.Billing_Street_Type__c; 
            subscription.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;               
            subscription.Billing_Street_Direction__c = acct.Billing_Street_Direction__c;
            subscription.Billing_Unit_Type__c = acct.Billing_Unit_Type__c;
            subscription.Billing_Box__c = acct.Billing_Box__c;
            subscription.Billing_Addl_Display_Name__c = acct.Billing_Addl_Display_Name__c;
            subscription.Billing_Zip__c = acct.Billing_Zip__c;
            subscription.Billing_Zip_4__c = acct.Billing_Zip_4__c;
            subscription.Zip_4__c = acct.Zip_4__c;
            subscription.Billing_City__c = acct.Billing_City__c;
            subscription.Billing_State__c = acct.Billing_State__c;
            subscription.Billing_County__c = acct.Billing_County__c;
            subscription.Billing_Country__c = acct.Billing_Country__c;
            subscription.QAS_Billing_Country__c = acct.QAS_Billing_Country__c; 
            subscription.QAS_Billing_County__c = acct.QAS_Billing_County__c;
            subscription.QAS_Billing_Street_Direction__c = acct.QAS_Billing_Street_Direction__c;
            subscription.QAS_Billing_Street_Type__c = acct.QAS_Billing_Street_Type__c;
            subscription.QAS_Billing_Unit_Type__c = acct.QAS_Billing_Unit_Type__c;
            subscription.QAS_Billing_POBox__c = acct.QAS_Billing_POBox__c;
            subscription.QAS_Billing_Record_Type__c = acct.QAS_Billing_Record_Type__c;
            subscription.AddressValidationStatus__c = 'Not Required';
            subscription.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
            subscription.Billing_Jurisdiction__c = application.Billing_Jurisdiction__c;
            insert subscription;
          
            //List<Related_Agent__c> agents = (List<Related_Agent__c>)JSON.deserializeUntyped(application.Related_Agents__c);
            List<object> agents = (List<object>)JSON.deserializeUntyped(application.Related_Agents__c);
            List<Related_Agent__c> newAgents = new List<Related_Agent__c>();
            List<String> subscriptionStrings = new List<String>();
            for(object ra : agents) {
                map<String,Object> m = (map<String,Object>) ra;
               subscriptionStrings.add(String.valueOf(m.get('agentId')));
            }
           List<Subscriptions__c> subcriptionAgents = [SELECT Id, Contact__c FROM Subscriptions__c WHERE Name IN: subscriptionStrings];
            for(Subscriptions__c sub : subcriptionAgents) {
                Related_Agent__c rAgents = new Related_Agent__c();
                rAgents.Personal_Assistant_Sub_ID__c = subscription.Id;
                rAgents.Personal_Assistant__c = subscription.Contact__c;
                rAgents.Status__c = 'In Progress';
                rAgents.Subscription__c = sub.Id;
                rAgents.Assistant_to__c = sub.Contact__c;
                newAgents.add(rAgents);
            }
            
            insert newAgents;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
        
    }
    
    public static void createOrder(String zAccountId, String iframeDomain, String applicationId, String redirectUrl, String cancelUrl, String wrapperUrl, String orderId) {
        try {
            Subscriptions__c subscription = new Subscriptions__c();
            List<SMS_CoreMapping__c> productRatePlans = new List<SMS_CoreMapping__c>();
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = new Zuora.zApi.LoginResult();
            BillingAndPayment_Settings__c billAndPaymentSettings = new BillingAndPayment_Settings__c();
            
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
                //showPayment = true;
                //showcontinue = false;
            }
            else
                throw new CustomException('Core mapping not found');
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }                     
    }
    
    @AuraEnabled
    public static void activateSubscription(String subscriptionId, String applicationId, Boolean isActivateNoPayment) {
        try {
            Subscriptions__c subscription = new Subscriptions__c();
            subscription =  [SELECT Id, Name, Status__c, Date_Terminated__c, Status_Change_Reason__c, Contact__r.Name,
                             Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Suffix__c, 
                             Contact__r.Salutation, Contact__r.Nickname__c, Related_Location_Broker_Office__c,
                             Related_Location_Broker_Office__r.Name, Related_Location_Broker_Office__r.Account_Name__c,
                             Related_Location_Broker_Office__r.Type, Subscription_Type__c, Contact_Type__c, 
                             Mobile_Phone__c, Primary_Phone__c, Private_Email__c, City__c, State__c,
                             Country__c, Zip__c, Service_Jurisdiction__c, Billing_Jurisdiction__c, NRDS_ID__c 
                             FROM Subscriptions__c where Name =: subscriptionId];
            
            MRIS_Application__c application = new MRIS_Application__c();
            application = [SELECT Id, Name, Status__c, Application_Expire_Date__c, CreatedDate, Application_Type__c,                                                             
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
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    
    
    public static void officeSecretaryCount(Subscriptions__c subscription) {
        if(subscription.Related_Location_Broker_Office__c == null){
            throw new AuraHandledException('Invalid Subscription');
        }
        List<String> subTypes = new List<String>();
        subTypes.add('Licensee/Non Realtor');
        subTypes.add('Realtor/Non Stakeholder');
        subTypes.add('Realtor Shareholder');
        subTypes.add('Office Secretary');
        subTypes.add('Office Secretary - NC');
        
        List<Aggregateresult> subGrpCountAggr = [SELECT Subscription_Type__c, count(id) from Subscriptions__c WHERE Related_Location_Broker_Office__c =: subscription.Related_Location_Broker_Office__c AND Subscription_Type__c IN: subTypes AND Status__c = 'Active' group by Subscription_Type__c];
        Integer officeSecretary = 0;
        Integer agents = 0;
        for(Aggregateresult aggr : subGrpCountAggr){
            if(aggr.get('Subscription_Type__c') == 'Licensee/Non Realtor' 
               || aggr.get('Subscription_Type__c') == 'Realtor/Non Stakeholder' 
               || aggr.get('Subscription_Type__c') == 'Realtor Shareholder'){
                agents += (Integer)aggr.get('expr0');
               }else if(aggr.get('Subscription_Type__c') == 'Office Secretary' 
                        || aggr.get('Subscription_Type__c') == 'Office Secretary - NC'){
                   officeSecretary += (Integer)aggr.get('expr0');
               }
        }
        system.debug('officeSecretary : '+officeSecretary);
        system.debug('agents : '+agents);
        subscription.Subscription_Type__c = 'Office Secretary';
        if(agents <= 30 && officeSecretary == 0){
            subscription.Subscription_Type__c = 'Office Secretary';
        }else if(agents > 30 && agents <= 60 && officeSecretary < 2){
            subscription.Subscription_Type__c = 'Office Secretary';
        }else if(agents > 60 && agents <= 90 && officeSecretary < 3){
            subscription.Subscription_Type__c = 'Office Secretary';
        }
    }
    
    public class wrapperClass {
        @AuraEnabled public string subscriptionId;
        @AuraEnabled public string contactName;   
        @AuraEnabled public string personalAssistantSubId;
        @AuraEnabled public string personalAssistant;
        @AuraEnabled public string status;
        @AuraEnabled public List<Related_Agent__c> relatedAgents;
        
    }   
    
    public class CustomException extends Exception {}
}