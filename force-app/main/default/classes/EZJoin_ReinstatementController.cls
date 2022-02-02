/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Class contains Reinstatement Process methods for EZJOIN application
*
* SAL- 2118
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Usha
* @version        1.0
* @created        2020-04-14
* @modified       2020-04-17
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Usha
* 2020-04-20      Updated the code in getSubscriptionDetails method for checking the Application if
already exists for given subscription. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public without sharing class EZJoin_ReinstatementController {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return Subscription and Related agents details
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    subscriptionId			    To fetch the Subscription details
    * @return   wrap                        Return with details of Subscription and Related agents.
    *                                       Used Wrapper class to return the details. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */    
    @AuraEnabled
    public static wrapperClass getSubscriptionDetails(String subscriptionId) {
        try {
            wrapperClass wrap = new wrapperClass();
            if(subscriptionId != Null && subscriptionId != '') {
                
                List<MRIS_Application__c> lApplications = [SELECT Id, Name,Application_Expire_Date__c  
                                                           FROM   MRIS_Application__c
                                                           WHERE  Agent_Subscription_ID__r.Name =: subscriptionId
                                                           AND Application_Type__c = 'Reinstatement'
                                                           AND Status__c IN ('New','Approved') Order By CreatedDate DESC];
                
                if(!lApplications.isEmpty()) {
                    wrap.application = lApplications[0];
                }
                
                List<Subscriptions__c> subscriptions =  [SELECT Id, 
                                                         Name,
                                                         Status__c, 
                                                         Date_Terminated__c, 
                                                         Status_Change_Reason__c, 
                                                         Contact__r.Name,
                                                         Contact__r.FirstName, 
                                                         Contact__r.LastName, 
                                                         Contact__r.Middle_Name__c, 
                                                         Contact__r.Suffix__c, 
                                                         Contact__r.Salutation, 
                                                         Contact__r.Nickname__c,
                                                         Related_Location_Broker_Office__c,
                                                         Related_Location_Broker_Office__r.Name,
                                                         Related_Location_Broker_Office__r.Account_Name__c,
                                                         Related_Location_Broker_Office__r.Type,
                                                         Subscription_Type__c,
                                                         Contact_Type__c, 
                                                         Mobile_Phone__c,
                                                         Primary_Phone__c, 
                                                         Private_Email__c, 
                                                         City__c,
                                                         State__c,
                                                         County__c,
                                                         Zip__c,
                                                         Service_Jurisdiction__c,
                                                         Billing_Jurisdiction__c,
                                                         NRDS_ID__c FROM Subscriptions__c where Name =: subscriptionId];
                
                if(!subscriptions.isEmpty()) {
                    wrap.subscription = subscriptions[0];
                }
                
                wrap.agents = [SELECT Id,
                               Personal_Assistant_Sub_ID__c,
                               Assistant_to__c, Subscription__c, Subscription__r.Name, Subscription__r.Contact__c, Subscription__r.Contact__r.Name, 
                               Personal_Assistant__c 
                               FROM Related_Agent__c 
                               WHERE Personal_Assistant_Sub_ID__r.Name =: subscriptionId 
                               AND Status__c = 'Active'];
                
                List<Subscription_License__c> subLics= [SELECT Id, Name, License__c, License__r.Name, License__r.License_State__c, License__r.License_Type__c, License__r.License_Expiration_Date__c 
                                                        FROM Subscription_License__c 
                                                        WHERE Subscription__r.Name = :subscriptionId];
                if(!subLics.isEmpty()){
                    wrap.sublicense = subLics[0];
                }
                
                List<Related_Association__c> relAssocs= [SELECT Id, Association__c, Association__r.Name,Association_Name__c, Subscription__c, Status__c 
                                                         FROM Related_Association__c 
                                                         WHERE Subscription__r.Name = :subscriptionId 
                                                         AND Primary__c = true 
                                                         AND Status__c = 'Active'];
                if(!relAssocs.isEmpty()){
                    wrap.relAssociation = relAssocs[0];
                }
            }
            
            return wrap;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString() + e.getTypeName() + e.getCause());
            
        } 
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to insert MRIS Application
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    application			    MRIS application object with all fields information
    * @return	MRIS_application__c		Returns the newly created application object reference
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    @AuraEnabled
    public static MRIS_application__c submitApplication(MRIS_Application__c application) {
        try {
            if(application == null)
                throw new CustomException('Invalid application');
            
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            application.application_Expire_Date__c = system.now().AddDays(maxDays);
           
            insert application;
            
            //Query to return MRIS application id (Name - Auto Number)
            //MRIS_application__c app = [SELECT Id,Application_Expire_Date__c,Name, Nickname__c FROM MRIS_application__c WHERE Id=: application.Id];
            string query = 'SELECT Id, Name, Nickname__c FROM MRIS_application__c WHERE Id =\'' + application.Id + '\'';
            List <SObject> applications = EzjoinHelper.getApplicationDetails(query);
            if(!applications.isEmpty()){
                return (MRIS_application__c)applications[0];
            }
            return null;        
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }   
    
    
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
    public static List<EZJoin_NewapplicationController.wrapper> getPicklistValues(String fieldName, String objectName) {
        return EZJoin_NewapplicationController.getPicklistValues(fieldName, objectName);
    }    
    
    public class wrapperClass {
        @AuraEnabled public Subscriptions__c subscription;
        @AuraEnabled public List<Related_Agent__c> agents;
        @AuraEnabled public MRIS_Application__c application;
        @AuraEnabled public Subscription_License__c sublicense;
        @AuraEnabled public Related_Association__c relAssociation;
        
        public wrapperClass() {
            subscription = new Subscriptions__c();
            agents = new List<Related_Agent__c>();
            application = new MRIS_Application__c();
            sublicense = new Subscription_License__c();
            relAssociation = new Related_Association__c();
        }
    }   
    
    public class CustomException extends Exception {}
    
}