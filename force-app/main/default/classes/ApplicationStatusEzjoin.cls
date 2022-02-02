public class ApplicationStatusEzjoin {
    public String applicationId { get; set; }
    public MRIS_Application__c application { get; set; }
    public Boolean isValid { get; set; }
    
    public BillingAndPayment_Settings__c billAndPaymentSettings;
    public String trendLoginName { get; set; }
    public String loginErrorMessage { get; set; }
    public Boolean isLoginNameAvailable { get; set; }
    
    public ApplicationStatusEzjoin() {
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
    
    public class CustomException extends Exception{}    
}