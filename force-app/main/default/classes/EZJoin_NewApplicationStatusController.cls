/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Class contains Check Application Status Process
*
* SAL- 2576, 2577
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Usha
* @version        1.0
* @created        2020-04-21
* @modified       2020-04-22
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Usha
* 2020-04-22      Added List of MRIS Application when Id is Entered 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class EZJoin_NewApplicationStatusController {
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to return MRIS Application details, Subscription details and Related Agents details
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    applicationId		Name of the MRIS application
* @return	wrapperClass		Returns a wrapper class contains application and subscription details
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    @AuraEnabled
    public Static wrapperClass getApplicationDetails(String applicationId) {
        try {
            if(String.isBlank(applicationId))
                throw new AuraHandledException('Invalid Application Id');
            
            MRIS_Application__c app = new MRIS_Application__c(); 
            List<MRIS_Application__c> applications = [SELECT Id, Name, CreatedDate, Status__c, Application_Expire_Date__c, Type__c, Subscription_Type__c,                                                            
                                                      Suffix__c, Salutation__c, First_Name__c, Last_Name__c, Middle_Name__c, Nickname__c, Mobile_Phone__c,
                                                      Company_Code__r.Name, Company_Code__r.Account_Name__c, Agent_Subscription_ID__c,
                                                      City__c, State__c, Zip__c, Primary_Phone__c, Private_Email__c, Related_Agents__c, Application_Type__c,
                                                      License_Expiration_Date__c,License_State__c,License_Type__c,License_Number__c
                                                      FROM  MRIS_Application__c
                                                      WHERE Name = :applicationId];
            wrapperClass wc = new wrapperClass();
            if(!applications.isEmpty()) {
                wc.application = applications[0];
            }
            else {
                throw new AuraHandledException('Invalid Application Id');
            }
            
            if(wc.application.Agent_Subscription_ID__c != null) {
                List<Subscriptions__c> subscriptions = [SELECT 	Id, Name, Contact_Type__c, Subscription_Type__c, Status__c,
                                                        Contact__c, Contact__r.Name, Related_Location_Broker_Office__c, 
                                                        Related_Location_Broker_Office__r.Name, City__c, State__c, QAS_Mailing_County__c, Zip__c,
                                                        Private_Email__c, Primary_Phone__c, Mobile_Phone__c, SFDC_Application__c,
                                                        Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, 
                                                        Contact__r.Suffix__c, Date_Terminated__c, Service_Jurisdiction__c, Billing_Jurisdiction__c, BRIGHT_LoginName__c, TREND_Login_Name__c
                                                        FROM  	Subscriptions__c
                                                        WHERE 	Id = :wc.application.Agent_Subscription_ID__c];
                if(!subscriptions.isEmpty()) {
                    wc.subscription = subscriptions[0];
                    
                    wc.agents = [SELECT Id,
                                 Personal_Assistant_Sub_ID__c,
                                 Assistant_to__c, Subscription__c, Subscription__r.Name, Subscription__r.Contact__c, Subscription__r.Contact__r.Name, 
                                 Personal_Assistant__c FROM Related_Agent__c WHERE Personal_Assistant_Sub_ID__c =: wc.application.Agent_Subscription_ID__c AND Status__c = 'Active'];
                }
                
                
            }
            
            return wc;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to validate Login Name
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    loginNameStr		Login Name which is provided
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    
    @AuraEnabled
    public static void validateLoginName(String loginNameStr) {
        try {
            loginNameStr = loginNameStr.normalizeSpace();
            if(String.isBlank(loginNameStr))
                throw new AuraHandledException('Please enter Login Name');
            LoginName.isAvailable(null, loginNameStr);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to Create Contact, Subscription and Update MRIS Application.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    applicationId		Name of the MRIS application
* @param    loginName		    Login Name which is provided
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    
    @AuraEnabled
    public static void createSubscription(String applicationId, String loginName) {
        try {
            if(String.isBlank(applicationId))
                throw new AuraHandledException('Invalid Application');
            
            if(String.isBlank(loginName))
                throw new AuraHandledException('Invalid Login Name');
            
            Account acct = new Account();
            Subscriptions__c subscription = new Subscriptions__c(); 
            MRIS_application__c application = new MRIS_application__c();
            List<MRIS_Application__c> applications = [SELECT Id, Name, CreatedDate, Status__c, Application_Expire_Date__c, Type__c, Subscription_Type__c,                                                            
                                                      Suffix__c, Salutation__c, First_Name__c, Last_Name__c, Middle_Name__c, Nickname__c, Mobile_Phone__c,
                                                      Company_Code__r.Name, Company_Code__r.Account_Name__c,Voicemail__c, VM_Ext__c, Home_Fax__c,
                                                      City__c, State__c, Zip__c, Primary_Phone__c, Related_Agents__c, Company_Code__c,Agent_Office_Fax__c,Billing_Jurisdiction__c,
                                                      Private_Email__c, Public_Email__c, Website__c,NRDS_ID__c, Professional_Designations__c, Disabilities__c,Service_Jurisdiction__c,
                                                      Agent_Office_Phone__c, Company_Code__r.City__c, Company_Code__r.Zip__c, Company_Code__r.County__c,Company_Code__r.QAS_Mailing_County__c,
                                                      License_Number__c, License_Type__c, License_State__c, License_Expiration_Date__c, Association_Board_Affiliation__c
                                                      FROM  MRIS_Application__c
                                                      WHERE Name = :applicationId AND Status__c = 'Approved'];
            if(!applications.isEmpty()) {
                application = applications[0];
            }else{
                throw new AuraHandledException('Invalid Application');
            }
            
            acct = [Select id, a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type,
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
                    a.IsCustomerPortal, a.Industry, a.Fax, a.Description, a.Date_Terminated__c, a.Date_Joined__c, 
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
            c.VM_Ext__c = application.VM_Ext__c;
            c.Nickname__c = application.Nickname__c;
            c.Home_Fax__c = application.Home_Fax__c;
            c.AccountId = application.Company_code__c;
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
            subscription.Related_Location_Broker_Office__c = application.Company_Code__r.Id;
            subscription.Subscription_Type__c = application.Subscription_Type__c;
            subscription.Contact_Type__c = application.Type__c;
            subscription.Public_Email__c = application.Public_Email__c;
            subscription.Primary_Phone__c = application.Primary_Phone__c;
            subscription.Home_Fax__c = application.Home_Fax__c;
            subscription.VM_Ext__c = application.VM_Ext__c;
            subscription.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
            subscription.Fax__c = application.Agent_Office_Fax__c;
            subscription.Mobile_Phone__c = (application.Mobile_Phone__c != null)?application.Mobile_Phone__c:application.Primary_Phone__c;
            subscription.Website__c = application.Website__c;
            subscription.Related_Location_Broker_Office__c = application.Company_Code__c;
            subscription.Status__c = 'In Progress';
            subscription.NRDS_ID__c = application.NRDS_ID__c;
            subscription.BRIGHT_LoginName__c = loginName;
            
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
            
            //Insert Association if exists
            if (application.Association_Board_Affiliation__c != null) {
                Related_Association__c ra = new Related_Association__c();
                ra.Association__c = application.Association_Board_Affiliation__c;
                ra.Primary__c  = true;
                ra.Subscription__c = subscription.id;
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
                sl.Subscription__c = subscription.id;  
                insert sl; 
            }
            
            handleAgents(application, subscription, true);
            
            if(application.Billing_Jurisdiction__c != null){
                BillingAndPayment_Settings__c billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(application.Billing_Jurisdiction__c);
                if(billAndPaymentSettings != null && billAndPaymentSettings.Bypass_Payment__c) {                    
                    activateSubscription(subscription.Id, true, application.Id);
                }    
            }
            
            application.Agent_Subscription_ID__c = subscription.Id;
            update application;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handles when there is no Application for Agent
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscription		Name of the subscription
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    
    /*  public static void handleAgentWithoutApplication(Subscriptions__c subscription){
if(subscription.Id != null){
MRIS_Application__c  application = [SELECT id, Related_Agents__c FROM MRIS_Application__c 
WHERE Agent_Subscription_ID__c =: subscription.Id 
AND Status__c = 'Approved'
AND Application_Type__c NOT IN ('IDX and VOW Agent Request', 'Agent Transfer')];
handleAgents(application, subscription, false);
}
}*/
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to Create Related Agents.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    application		        Variable for MRIS_Application_c
* @param    subscription		    Variable for Subscriptions__c
* @param    isNew		            Checks whether the Related agent is New or Old
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    
    public static void handleAgents(MRIS_Application__c  application, Subscriptions__c subscription, Boolean isNew){
        if(application.Related_Agents__c != null){
            List<object> agents = (List<object>)JSON.deserializeUntyped(application.Related_Agents__c);
            List<Related_Agent__c> newAgents = new List<Related_Agent__c>();
            Set<String> subscriptionStrings = new Set<String>();
            
            try{
                for(object ra : agents) {
                    map<String,Object> m = (map<String,Object>) ra;
                    subscriptionStrings.add(String.valueOf(m.get('agentId')));
                }
                List<Subscriptions__c> subcriptionAgents = [SELECT Id, Name, Contact__c FROM Subscriptions__c WHERE Name IN: subscriptionStrings];
                if(!isNew){
                    List<Related_Agent__c> lAgentsToUpdate = new List<Related_Agent__c>();
                    List<Related_Agent__c> lRelatedAgents = [SELECT Id, Status__c, Subscription__c, Subscription__r.name FROM Related_Agent__c WHERE (Status__c = 'Active' OR Status__c = 'In Progress') AND Personal_Assistant_Sub_ID__c =: subscription.Id];
                    for(Related_Agent__c oRelatedAgents: lRelatedAgents){
                        if(oRelatedAgents.Status__c == 'In Progress'){
                            oRelatedAgents.Status__c = 'Active';
                        }else if(oRelatedAgents.Status__c == 'Active' && !subscriptionStrings.contains(oRelatedAgents.Subscription__r.name)){
                            oRelatedAgents.Status__c = 'Inactive';
                        }
                        subscriptionStrings.remove(oRelatedAgents.Subscription__r.name);
                        lAgentsToUpdate.add(oRelatedAgents);
                    }
                    if(!lAgentsToUpdate.isEmpty()){
                        update lAgentsToUpdate;
                    }
                    
                }
                for(Subscriptions__c sub : subcriptionAgents) {
                    if(isNew || subscriptionStrings.contains(sub.Name)){
                        Related_Agent__c rAgents = new Related_Agent__c();
                        rAgents.Personal_Assistant_Sub_ID__c = subscription.Id;
                        rAgents.Personal_Assistant__c = subscription.Contact__c;
                        rAgents.Status__c = isNew?'In Progress':'Active';
                        rAgents.Subscription__c = sub.Id;
                        rAgents.Assistant_to__c = sub.Contact__c;
                        newAgents.add(rAgents);
                    }
                } 
                
                if(!newAgents.isEmpty())
                    insert newAgents;
            }catch(Exception e){
                throw new AuraHandledException('Invalid Related Agents');
            }
            
        }
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to Create Order.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscriptionId		Gets the Subscription details when this subscriptionId is provided
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    
    @AuraEnabled
    public static String createOrder(String subscriptionId) {
        try {
            if(String.isBlank(subscriptionId)) {
                throw new AuraHandledException('Subscription not found');
            }
            
            List<SMS_CoreMapping__c> productRatePlans = new List<SMS_CoreMapping__c>();
            List<Subscriptions__c> subscriptionList = [SELECT 	Id, Name, Billing_Jurisdiction__c, Contact_Type__c, Contact__c,
                                                       Subscription_Type__c, Status__c, SFDC_Application__c, Private_Email__c,
                                                       SFDC_Application__r.Name, Date_Terminated__c, Related_Location_Broker_Office__c  
                                                       FROM 	Subscriptions__c 
                                                       WHERE 	Id =: subscriptionId];
            if(subscriptionList.isEmpty()) {
                throw new AuraHandledException('Subscription not found');
            }
            String oldSubType = subscriptionList[0].Subscription_Type__c;
            Subscriptions__c subscription = subscriptionList[0];
            
            if(oldSubType == 'Office Secretary' || oldSubType == 'Office Secretary - NC')
                subscription = officeSecretaryCount(subscriptionList[0]);
            
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
                Reinstatement_Waiver_Range__c waiver = Reinstatement_Waiver_Range__c.getValues('Reinstatement waiver');
                
                System.debug(waiver);
                
                Date waiver1 = waiver.Cut_off_Start_Date__c;
                Date waiver2 = waiver.Cut_off_End_Date__c;
                
                System.debug(waiver1);
                System.debug(waiver2);
                
                if (subscription.Date_Terminated__c != null && (subscription.Subscription_Type__c == 'Realtor/Shareholder'  || subscription.Subscription_Type__c == 'Licensee/Non Realtor' || subscription.Subscription_Type__c == 'Realtor/Non Shareholder') &&
                    subscription.Date_Terminated__c > waiver1 && subscription.Date_Terminated__c < waiver2){
                        mapStatus = 'Reinstatement <= 30'; 
                        System.debug(mapStatus);
                    }
                else if(subscription.Date_Terminated__c != null && subscription.Date_Terminated__c.daysBetween(date.valueof(Date.today())) <= 30)
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
                SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
                Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();         
                
                String accountQuery = 'SELECT Id, AutoPay, DefaultPaymentMethodId FROM Account WHERE Status = \'Active\' AND SubscriptionID__c = \'' + subscription.Name + '\'';
                List<Zuora.zObject> account = new List<Zuora.zObject>();
                account = zUtilInstance.zquery(accountQuery);
                
                
                if(account.Size() == 0)
                    throw new CustomException('Zuora account not found. Please contact Customer Support for more details');
                
                String zAccountId = (String)account[0].getValue('Id');           
                if(oldSubType != subscription.Subscription_Type__c){
                    system.debug('before update');
                    update subscription;
                    system.debug('after update');
                }
                SMS_Order__c order = new SMS_Order__c();                
                order.Name = 'Order Id';
                order.Token__c = '';
                order.Zuora_Account_Id__c = zAccountId;
                order.MRIS_Subscription_Id__c = subscription.id;
                order.Status__c = 'Active';
                order.Bypass_Payment__c = false;
                order.Private_Email__c = subscription.Private_Email__c ;
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
                
                BillingAndPayment_Settings__c billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(subscription.Billing_Jurisdiction__c);
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
                String iframeDomain = URL.getSalesforceBaseUrl().toExternalForm();
                String path = Label.Generic_Payment_Wrapper + '/eProcess/NewApplicationStatus?Id=' + subscription.SFDC_Application__r.Name;
                String iframeUrl = Label.Generic_Payment_Wrapper + '/SMS/SMS_GenericPaymentWrapper?token=' + encodedToken  + '#' + path;
                
                return iframeUrl;
            }
            else
                throw new CustomException('Core mapping not found');
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to Activate the Reinstated Applications
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscriptionId		        Get values of Subscriptions__c when subscriptionId is given
* @param    isActivateNoPayment		    Boolean variable to check whether it is payable or not
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    
    @AuraEnabled
    public static String activateSubscription(String subscriptionId, Boolean isActivateNoPayment, String applicationId) {
        try {
            if(String.isBlank(subscriptionId)) {
                throw new AuraHandledException('Subscription not found');
            }
            MRIS_Application__c app = new MRIS_Application__c();
            Subscriptions__c subscription = new Subscriptions__c();

            app = [SELECT Id, 
                   Name, 
                   Status__c, 
                   Related_Agents__c,
                   Application_Type__c,
                   Agent_Subscription_ID__c, 
                   Agent_Subscription_ID__r.Name, 
                   Agent_Subscription_ID__r.Related_Location_Broker_Office__c, 
                   Agent_Subscription_ID__r.Status__c,
                   Agent_Subscription_ID__r.Contact__c
                   FROM MRIS_Application__c
                   WHERE Id =:applicationId 
                   AND Status__c = 'Approved'
                   AND  Application_Type__c NOT IN ('IDX and VOW Agent Request', 'Agent Transfer')];
            
            subscription.ZuoraIntegrationWorkflowBypass__c = true;
            subscription.AddressValidationStatus__c = 'To be verify';
            subscription.Id = app.Agent_Subscription_ID__c;
            if(isActivateNoPayment)
                subscription.ZuoraIntegrationWorkflowBypass__c = false;
            
            if(app.Agent_Subscription_ID__r.Status__c == 'In Progress'){
                // handleAgentWithoutApplication(subscription);
                 handleAgents(app, subscription, false);
                subscription.Status__c = 'Active';
            }
            
            
            if(app.Agent_Subscription_ID__r.Status__c == 'Inactive') {
                // handleAgentWithoutApplication(subscription);
                handleAgents(app, subscription, false);
                subscription.Status__c = 'Active';
                subscription.Status_Change_Reason__c = 'Reinstate';
                subscription.Date_Reinstated__c = Date.today();
                if(isActivateNoPayment) {
                    subscription.Status_Change_Fee__c = 'No Charge';
                }
            }
            //subscription.add(app.Agent_Subscription_ID__r);
            update subscription;          
            
            //completing the application if the subcription is activated.
           /* MRIS_Application__c application = [SELECT Id, 
                                               Status__c 
                                               FROM MRIS_Application__c 
                                               WHERE Agent_Subscription_ID__c =: app.Agent_Subscription_ID__c 
                                               AND Status__c = 'Approved' 
                                               AND  Application_Type__c NOT IN ('IDX and VOW Agent Request', 'Agent Transfer')
                                               ORDER BY CREATEDDATE DESC limit 1];*/
            if(app.Status__c != 'Completed') {
                app.Status__c = 'Completed';
                update app;
            }
            
            return 'Success';            
        }
        catch(exception e) {
            system.debug('***' +  e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    /**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to Count the Office Secretary to check whether the amount is payable or no 
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    subscription		        Get values of Subscriptions__c when subscription is given
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    
    public static Subscriptions__c officeSecretaryCount(Subscriptions__c subscription) {
        if(subscription.Related_Location_Broker_Office__c == null){
            throw new AuraHandledException('Invalid Subscription');
        }
        
        List<String> subTypes = new List<String>();
        subTypes.add('Licensee/Non Realtor');
        subTypes.add('Realtor/Non Shareholder');
        subTypes.add('Realtor/Shareholder');
        subTypes.add('Office Secretary');
        subTypes.add('Office Secretary - NC');
        
        List<Aggregateresult> subGrpCountAggr = [SELECT Subscription_Type__c, count(id) from Subscriptions__c WHERE Related_Location_Broker_Office__c =: subscription.Related_Location_Broker_Office__c AND Subscription_Type__c IN: subTypes AND Status__c = 'Active' group by Subscription_Type__c];
        Integer officeSecretary = 0;
        Integer agents = 0;
        for(Aggregateresult aggr : subGrpCountAggr){
            if(aggr.get('Subscription_Type__c') == 'Licensee/Non Realtor' 
               || aggr.get('Subscription_Type__c') == 'Realtor/Non Shareholder' 
               || aggr.get('Subscription_Type__c') == 'Realtor/Shareholder'){
                   agents += (Integer)aggr.get('expr0');
               }else if(aggr.get('Subscription_Type__c') == 'Office Secretary' 
                        || aggr.get('Subscription_Type__c') == 'Office Secretary - NC'){
                            officeSecretary += (Integer)aggr.get('expr0');
                        }
        }
        subscription.Subscription_Type__c = 'Office Secretary';
        if(agents <= 30 && officeSecretary == 0){
            subscription.Subscription_Type__c = 'Office Secretary - NC';
        }else if(agents > 30 && agents <= 60 && officeSecretary < 2){
            subscription.Subscription_Type__c = 'Office Secretary - NC';
        }else if(agents > 60 && officeSecretary < 3){
            subscription.Subscription_Type__c = 'Office Secretary - NC';
        }
        return subscription;
    }
    
    public class wrapperClass {
        @AuraEnabled public MRIS_Application__c application;
        @AuraEnabled public Subscriptions__c subscription;
        @AuraEnabled public List<Related_Agent__c> agents;
        
        public wrapperClass() {
            subscription = new Subscriptions__c();
            application = new MRIS_Application__c();
            agents = new List<Related_Agent__c>();
        }
    }
    
    public class CustomException extends Exception {}
    
}