public without sharing class Communities_NewApplications {
    
    public List<MRIS_Application__c> applications { get; set; }
    public Map<String,String> officeIds { get; set; }
    
    public String applicationId { get; set; }
    public MRIS_Application__c application { get; set; }
    public Boolean isViewApplication { get; set; }
    public List<String> statusOptions { get; set; }
    public List<String> roleOptions { get; set; }
    public String statusSelectedStr { get; set; }
    public String roleSelectedStr { get; set; }
    public String errorMsg { get; set; }
    public List<Object> agents {get;set;}
    
    public Communities_NewApplications() {
        try{
            
            String subscriptionId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No subscription ID found');   
            
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
                             Subscription__r.Name, Subscription__r.Contact__r.Name ,Broker_Office__r.Name 
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subscriptionId
                            ];
            
            List<String> parentIds = new List<String>();
            Map<String,String> asOffices = new Map<String,String>();
            Boolean isBOR = false;
            
            for(Relationship__c relationship : relationships){
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
                
                if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                    isBOR = true;
                } 
                else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                }
            } 
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new Map<String,String>(asOffices);
                }                
            }
            else{
                List<Account> relatedAccounts = new List<Account>(); 
                relatedAccounts = [SELECT Id, Name
                                   FROM   Account
                                   WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                  ];
                
                officeIds = new Map<String,String>();
                
                for(Account a : relatedAccounts)
                    officeIds.put(a.Id, a.Name);
            }
            
            statusSelectedStr = 'New';    
            roleSelectedStr = 'All';    
            isViewApplication = false;
            
            statusOptions = new List<String>();        
            Schema.DescribeFieldResult fieldResult = MRIS_Application__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
                statusOptions.add(f.getValue());
            
            roleOptions = new List<String>();        
            roleOptions.add('Licensee/Non Realtor');
            roleOptions.add('Office Secretary');
            roleOptions.add('Office Secretary - NC');
            roleOptions.add('Personal Assistant');
            roleOptions.add('Personal Assistant to Appraiser');
            roleOptions.add('Realtor/Non Shareholder');
            roleOptions.add('Realtor/Shareholder');
            
            getApplications();
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }  
    }
    
    public void getApplications() {
        isViewApplication = false;
        Set<String> statusSelected = new Set<String>();
        Set<String> roleSelected = new Set<String>();
        if(statusSelectedStr == 'All')
            statusSelected.addAll(statusOptions); 
        else if(statusSelectedStr == 'None')
            statusSelected = new Set<String>();   
        else
            statusSelected.addAll(statusSelectedStr.split(','));
        
        if(roleSelectedStr == 'All')
            roleSelected.addAll(roleOptions); 
        else if(roleSelectedStr == 'None')
            roleSelected = new Set<String>();   
        else
            roleSelected.addAll(roleSelectedStr.split(','));
        
        
        applications = [SELECT Id, Name, Status__c, Application_Expire_Date__c, Association_Board_Affiliation__r.Name,
                        Comments__c, License_Number__c, License_Expiration_Date__c, License_State__c, License_Type__c,
                        NRDS_ID__c, Company_Code__c, Company_Code__r.Name, Subscription_Type__c, Type__c, 
                        Agent_Name__c, Agent_Subscription_ID__r.Name, Application_Type__c, Approved_Rejected_Status_Message__c, 
                        Company_Code__r.City__c, Company_Code__r.Zip__c, Company_Code__r.County__c, 
                        Company_Code__r.State__c, Company_Code__r.QAS_Mailing_County__c, Company_Code__r.Id, Service_Jurisdiction__c, Billing_Jurisdiction__c
                        FROM   MRIS_Application__c 
                        WHERE  Company_Code__c IN :officeIds.keyset() AND Application_Type__c IN ('New Agent', 'Reinstatement') AND Status__c =: statusSelected AND Subscription_Type__c =: roleSelected limit 4000];
        
    }
    
    public void viewApplication(){
        agents = new List<object>();
        application = [SELECT Id,Name, Status__c, Application_Expire_Date__c, Association_Board_Affiliation__c, Association_Board_Affiliation__r.Name, City__c, State__c, Zip__c, County__c,Primary_Phone__c, 
                       Comments__c, License_Number__c, License_Expiration_Date__c, License_State__c, License_Type__c, Service_Jurisdiction__c, 
                       NRDS_ID__c, Company_Code__c, Company_Code__r.Name, Company_Code__r.Account_Name__c, Middle_Name__c,Nickname__c,Suffix__c,
                       Company_Code__r.City__c, Company_Code__r.State__c, Company_Code__r.Zip__c, Subscription_Type__c, Type__c, Related_Agents__c,Agent_Subscription_ID__r.Mobile_Phone__c,
                       Agent_Name__c, Agent_Subscription_ID__c, Agent_Subscription_ID__r.Name, Agent_Subscription_ID__r.Related_Location_Broker_Office__c, First_Name__c, Last_Name__c, Salutation__c, Private_Email__c, 
                       Mobile_Phone__c, Application_Type__c, Agent_Subscription_ID__r.Contact__c, Agent_Subscription_ID__r.City__c, Agent_Subscription_ID__r.State__c, Agent_Subscription_ID__r.Zip__c,
                       Agent_Subscription_ID__r.Primary_Phone__c, Agent_Subscription_ID__r.Private_Email__c, Agent_Subscription_ID__r.QAS_Mailing_County__c,
                       Agent_Subscription_ID__r.Contact__r.FirstName, Agent_Subscription_ID__r.Contact__r.LastName, Agent_Subscription_ID__r.Contact__r.Salutation,
                       Agent_Subscription_ID__r.Contact__r.Suffix__c, Agent_Subscription_ID__r.Contact__r.Middle_Name__c, Agent_Subscription_ID__r.Contact__r.Nickname__c,
                       Agent_Subscription_ID__r.Nickname__c, Agent_Subscription_ID__r.NRDS_ID__c,Company_Code__r.County__c,Company_Code__r.QAS_Mailing_County__c, Billing_Jurisdiction__c
                       FROM   MRIS_Application__c 
                       WHERE  Id = :applicationId];
        try{
            if(String.isNotBlank(application.Related_Agents__c))
        		agents = (List<object>)JSON.deserializeUntyped(application.Related_Agents__c);    
        }catch(Exception ex){
            agents = new list<Object>();
        }
        isViewApplication = true;
    }
    
    public void approve() { 
        errorMsg = null;
        try {
            viewApplication();
            System.debug('***' + application);
            
            String oldStatus = application.Status__c;
            System.debug('**** Contact Start');
            if(application.Application_Type__c  == 'Reinstatement' && oldStatus == 'New') {
                
                Contact c = new Contact();
                c.Id = application.Agent_Subscription_ID__r.Contact__c;
                if(application.Agent_Subscription_ID__r.Contact__r.FirstName != application.First_Name__c)
                    c.FirstName = application.First_Name__c;
                if(application.Agent_Subscription_ID__r.Contact__r.LastName != application.Last_Name__c)    
                    c.LastName = application.Last_Name__c;
                if(application.Agent_Subscription_ID__r.Contact__r.Middle_Name__c != application.Middle_Name__c)    
                    c.Middle_Name__c = application.Middle_Name__c;
                if(application.Agent_Subscription_ID__r.Contact__r.Nickname__c != application.Nickname__c)    
                    c.Nickname__c = application.Nickname__c;
                if(application.Agent_Subscription_ID__r.Contact__r.Salutation != application.Salutation__c)    
                    c.Salutation = application.Salutation__c;
                if(application.Agent_Subscription_ID__r.Contact__r.Suffix__c != application.Suffix__c)     
                    c.Suffix__c = application.Suffix__c;
                update c;
                
                Subscriptions__c sub = new Subscriptions__c();
                sub.Id = application.Agent_Subscription_ID__c;  
                
                if(application.Mobile_Phone__c != null && application.Mobile_Phone__c != application.Agent_Subscription_ID__r.Mobile_Phone__c)
                    sub.Mobile_Phone__c = application.Mobile_Phone__c; 
                if(application.Primary_Phone__c != application.Agent_Subscription_ID__r.Primary_Phone__c)
                    sub.Primary_Phone__c = application.Primary_Phone__c;   
                if(application.Private_Email__c != application.Agent_Subscription_ID__r.Private_Email__c)
                    sub.Private_Email__c = application.Private_Email__c;
                if(application.Company_Code__c != null && application.Company_Code__c != application.Agent_Subscription_ID__r.Related_Location_Broker_Office__c)
                    sub.Related_Location_Broker_Office__c = application.Company_Code__c;
                if(application.Agent_Subscription_ID__r.Nickname__c != application.Nickname__c)    
                    sub.Nickname__c = application.Nickname__c;  
                if(application.Agent_Subscription_ID__r.NRDS_ID__c != application.NRDS_ID__c)    
                    sub.NRDS_ID__c = application.NRDS_ID__c;                                       
                update sub;
                
                Related_Association__c ra = new Related_Association__c();
                List<Related_Association__c> relAssociations = [SELECT Id, Association__c, Subscription__c, Status__c FROM Related_Association__c WHERE Subscription__c = :application.Agent_Subscription_ID__c AND Primary__c = true AND Status__c = 'Active'];
                if(relAssociations.Size() > 0) {
                    ra = relAssociations[0];
                    if(application.Association_Board_Affiliation__c != ra.Association__c) {
                        ra.Association__c = application.Association_Board_Affiliation__c;
                        update ra;
                    }
                }
                else {
                    if(application.Association_Board_Affiliation__c != null) {
                        ra.Association__c = application.Association_Board_Affiliation__c;
                        ra.Subscription__c = application.Agent_Subscription_ID__c;
                        ra.Start_Date__c = Date.today();
                        ra.Broker_Code__c = application.Company_Code__c;
                        ra.Status__c = 'Sent';
                        ra.Primary__c = true;
                        insert ra; 
                    }               
                } 
            }                        
            
            application.Approved_Rejected_Status_Message__c = 'Approved by ' + userInfo.getName() + ' on ' + DateTime.Now().format('MM/dd/yyyy HH:mm:ss');
            application.Status__c = 'Approved';
            
            
            if(application.Billing_Jurisdiction__c != null){
                BillingAndPayment_Settings__c billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(application.Billing_Jurisdiction__c);
                if(billAndPaymentSettings != null && billAndPaymentSettings.Bypass_Billing__c == true)
                    application.Send_Auto_approved_Email__c = true;
            }
            
            
            update application;
            
            /*
            string temp = application.Billing_Jurisdiction__c;
            system.debug('--temp--'+temp);
            BillingAndPayment_Settings__c billAndPaymentSettings;
            if(application.Billing_Jurisdiction__c != null)
            billAndPaymentSettings = BillingAndPayment_Settings__c.getValues(temp);
            
            
            system.debug('---billAndPaymentSettings-->'+billAndPaymentSettings);
            if(application.Application_Type__c  != 'Reinstatement' && billAndPaymentSettings != null ){
            
            string trendLoginName;
            Subscriptions__c subscription = SubscriptionSetup.subscriptionCreation(application, trendLoginName);
            //SubscriptionSetup.activateSubscription(application, subscription);
            
            //SubscriptionSetup.test(application.Id);
            }
            */
            
            isViewApplication = false;  
            getApplications();
        }
        catch(Exception e) {
            system.debug('*************** error message************'+e.getMessage());
            errorMsg = e.getMessage(); 
        } 
    } 
    
    public void reject() {
        application.Approved_Rejected_Status_Message__c = 'Rejected by ' + userInfo.getName() + ' on ' + DateTime.Now().format('MM/dd/yyyy HH:mm:ss');
        application.Status__c = 'Reject';
        update application;
        
        isViewApplication = false;
        getApplications();  
    }            
    
    public class CustomException extends Exception {}    
}