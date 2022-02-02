/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Class contains new application creation aura methods.
*
* SAL-1703, SAL-1704, SAL - 1705
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Srini
* @version        1.0
* @created        2020-04-03
* @modified       2020-04-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Srini
* 2020-04-09      Added a method to get picklist values related to field from an object
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public without sharing class EZJoin_NewApplicationController {
    
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
    public static List<wrapper> getPicklistValues(String fieldName, String objectName) {
        List<wrapper> values = new List<wrapper>();
        values.add(new wrapper('Select',''));
        List<String> types = new List<String>();
        if(objectName != '' && objectName != null){
            types.add(objectName);
        }
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()){
                    values.add(new wrapper(entry.getLabel(), entry.getValue()));
                }
            }
        }
        return values;
    }
    
    /*******SAL-2970*****/
    @AuraEnabled
    public static licenseWrapper verifyLicenseDetails(String licenseNumber, String licenseState, String licenseType) {
        try {
            licenseWrapper lw = new licenseWrapper();
            //system.debug('licenseType----'+licenseType);
            //system.debug('licenseNumber----'+licenseNumber);
            //system.debug('licenseState----'+licenseState);
            if(String.isNotBlank(licenseNumber) && String.isNotBlank(licenseState)) {         
                lw.subLicense = [SELECT Id, Name, Subscription__r.Name                           		 
                                 FROM   Subscription_License__c 
                                 WHERE  License__r.Name = :licenseNumber
                                 AND    License__r.License_State__c = :licenseState
                                 AND	License__r.License_Type__c = :licenseType
                                 AND 	SoftDelete__c != 'Yes'];
                
                lw.application = [SELECT Id, Name 
                                  FROM   MRIS_Application__c
                                  WHERE  License_Number__c = :licenseNumber
                                  AND    License_State__c = :licenseState
                                  AND    License_Type__c = :licenseType
                                  AND    Status__c IN ('New','Approved')
                                  AND 	 CreatedDate = LAST_N_DAYS:14];
            }
            
            return lw;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check registered Subscriptions before on matching phone or email
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    phone					Entered phone input
    * @param    email					Entered email input 
    * @return	Subscriptions__c		Returns the array of previous subscriptions with same email or phone 	
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */      
    @AuraEnabled
    public Static list<Subscriptions__c> getDuplicateSubscriptions(string mobileStr, string emailStr) {
        string nondigits = '[^0-9]';
        list<Subscriptions__c> duplicateSubscriptions = new list<Subscriptions__c>();
        list<string> subscriptionTypes = new list<string>{'Agent'};
        list<string> subscriptionSubTypes = new list<string>{'Licensee/Non Realtor'};
        list<string> statusList = new list<string>{'Inactive'};
        list<string> phoneList = new list<string>();
            
        list<string> queryFilters = new list<string>();
        string subQuery = '';
        
        /*if(String.isNotBlank(phoneStr)){
            phoneStr = phoneStr.replaceAll(nondigits,'');
            phoneList.add(phoneStr);
        }*/
        if(String.isNotBlank(mobileStr)){
            mobileStr = mobileStr.replaceAll(nondigits,'');
            phoneList.add(mobileStr);
        }
		
        system.debug('phoneList----'+phoneList);
        if(!phoneList.isEmpty() || String.isNotBlank(emailStr)){
            subQuery = 'SELECT Id FROM Subscriptions__c WHERE Contact_Type__c IN :subscriptionTypes AND Subscription_Type__c IN :subscriptionSubTypes AND Status__c IN :statusList AND ';
            if(!phoneList.isEmpty()){
                queryFilters.add(' Mobile_Phone_Formula__c IN :phoneList ');
            }
            if(String.isNotBlank(emailStr)){
                queryFilters.add(' Private_Email__c	 = :emailStr OR Public_Email__c = :emailStr ');
            }   
            if(queryFilters.size()>0){
                subQuery += '(' + String.join(queryFilters, ' OR ') + ')';
            }
            subQuery = String.escapeSingleQuotes(subQuery);
            system.debug('subQuery----'+subQuery);
            duplicateSubscriptions = Database.query(subQuery);
        }
        return duplicateSubscriptions;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create a new MRIS application
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    application				MRIS application object with all fields information
    * @param    acc						Related account selected for MRIS application
    * @param   	applicationType			Specify MRIS application type 
    * @return	MRIS_application__c		Returns the newly created application object reference	
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */      
    @AuraEnabled
    public Static MRIS_application__c submitApplication(MRIS_application__c application, Account acc, String applicationType) {
        try {

            //Setting application expiry date
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('New Agent').No_Of_Days__c;
            application.application_Expire_Date__c = system.now().AddDays(maxDays);
            
            //Assigning billing jurisdiction
            application.Billing_Jurisdiction__c = 'BRIGHT';
            if(application.Service_Jurisdiction__c == 'BRIGHT') {
                if(acc.County__c != null) {
                    List<BRIGHT_Billing_Jurisdiction__c> countiesList = new List<BRIGHT_Billing_Jurisdiction__c>();
                    countiesList = [SELECT 	Id,
                                    Name,
                                    County__c,
                                    State__c,
                                    Billing_Jurisdiction__c
                                    FROM   	BRIGHT_Billing_Jurisdiction__c
                                    WHERE  	County__c = :acc.County__c
                                    AND    	State__c = :acc.State__c];
                    system.debug('**countiesList**' +countiesList);
                    if(countiesList.Size() > 0)
                        application.Billing_Jurisdiction__c = countiesList[0].Billing_Jurisdiction__c;
                }
            }          
            
            //Deciding type and subscription type based on input application type value
            if(acc.type == 'Appraiser' && applicationType == 'PersonalAssistant') {
                application.Type__c = 'Assistant';
                application.Subscription_Type__c = 'Personal Assistant to Appraiser';
            }
            else if(acc.type != 'Appraiser' && applicationType == 'PersonalAssistant') {
                application.Type__c = 'Assistant';
                application.Subscription_Type__c = 'Personal Assistant';
            }
            else if(applicationType == 'OfficeSecretary') {
                application.Type__c = 'Staff';
                application.Subscription_Type__c = 'Office Secretary';                
            }
            else if(applicationType == 'Agent' || applicationType == 'AssociateBroker') {
                system.debug('+++application.Association_Board_Affiliation__c' + application.Association_Board_Affiliation__c);
                if(String.isBlank(application.Association_Board_Affiliation__c)) {
                    application.Subscription_Type__c = 'Licensee/Non Realtor';
                    application.Type__c = 'Agent';
                }
                else {
                    Account assoc = [SELECT Id,Name, Account_Name__c,Shareholder_Board__c FROM Account WHERE Id = :application.Association_Board_Affiliation__c];
                    
                    if(assoc.Account_Name__c.containsIgnoreCase('None')){
                        application.Subscription_Type__c = 'Licensee/Non Realtor';
                        application.Type__c = 'Agent';
                    }
                    else {
                        if(assoc.Shareholder_Board__c == 'Yes'){
                            application.Subscription_Type__c = 'Realtor/Shareholder';
                            application.Type__c = 'Agent';
                        }
                        else if(assoc.Shareholder_Board__c == 'No' || assoc.Shareholder_Board__c == 'None' || assoc.Shareholder_Board__c == '' || assoc.Shareholder_Board__c == NULL){
                            application.Subscription_Type__c = 'Realtor/Non Shareholder';
                            application.Type__c = 'Agent';
                        }
                    }
                }                
            }            
            
            //Insert new application
            insert application;
            
            //Query to return MRIS application id (Name - Auto Number)
            //MRIS_application__c app = [SELECT Id, Name, Nickname__c FROM MRIS_application__c WHERE Id=: application.Id];
            string query = 'SELECT Id, Name, Nickname__c FROM MRIS_application__c WHERE Id =\'' + application.Id + '\'';
            List <SObject> applications = EzjoinHelper.getApplicationDetails(query);
            if(!applications.isEmpty()){
                return (MRIS_application__c)applications[0];
            }
            return null;
        }
        catch(exception e) {
            system.debug('*** Exception: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    public class wrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public wrapper(String label, String value){
            this.label = label;
            this.value = value;
            
        }
    }

	public class licenseWrapper {
        @AuraEnabled public List<MRIS_Application__c> application;
        @AuraEnabled public List<Subscription_License__c> subLicense;
        public licenseWrapper() {
            application = new List<MRIS_Application__c>();
            subLicense = new List<Subscription_License__c>();
        }
    }    
     
    public class CustomException extends Exception {}
}