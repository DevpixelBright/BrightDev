public class Communities_OfficeExclusive {
    public Boolean hasInitialError { get; private set; }
    public Boolean isSuccessMsg { get; private set; }
    public String subscriptionId { get; set; }
    public Boolean hasError { get; set; }
    public Subscriptions__c subscription {get;set;}
    public Office_Exclusive__c oOfficeExclusive {get;set;}
    public String message {get;set;}
    public Date Listing_Agreement_Date {get;set;}
    public Date Listing_Expiration_Date {get;set;}
    public Boolean isOfficeManager {get; set;}
    public Set<String> officeIds {get; set;}
    public Attachment att {get;set;}
        
    public Communities_OfficeExclusive(){ 
        att = new Attachment();
        try{
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found' ); 
            
            List<Subscriptions__c> sSubscriptions = [SELECT id,
                                                     Name,
                                                     Contact_Type__c,
                                                     Private_email__c,
                                                     Public_email__c,
                                                     Related_Location_Broker_Office__c,
                                                     Related_Location_Broker_Office__r.name,
                                                     Related_Location_Broker_Office__r.Account_Name__c,
                                                     Related_Location_Broker_Office__r.ParentId,
                                                     Service_Jurisdiction__c,
                                                     Billing_Jurisdiction__c,
                                                     TREND_Login_Name__c,
                                                     BRIGHT_LoginName__c,
                                                     contact__c,
                                                     contact__r.Name,
                                                     contact__r.FirstName
                                                     FROM  Subscriptions__c
                                                     WHERE Name = :subscriptionId AND Status__c = 'Active'];        
            officeIds = new Set<String>();
            if(sSubscriptions.Size() != 1)  
                throw new CustomException('Invalid MRIS Subscription ID'); 
            else{
                
                subscription = sSubscriptions[0]; 
                oOfficeExclusive = new Office_Exclusive__c();
                oOfficeExclusive.List_Agent_ID__c  = subscription.Id;
                oOfficeExclusive.List_Office_ID__c  = subscription.Related_Location_Broker_Office__c;
                if(String.IsNotBlank(subscription.Related_Location_Broker_Office__r.ParentId))
                        officeIds.add(subscription.Related_Location_Broker_Office__r.ParentId);            
                    
                    if(String.IsNotBlank(subscription.Related_Location_Broker_Office__c))
                        officeIds.add(subscription.Related_Location_Broker_Office__c);
                    
                    for(Account a : [SELECT Id, Name
                                     FROM   Account
                                     WHERE  (ParentId IN :officeIds OR Id IN :officeIds) AND Status__c = 'Active'])
                        officeIds.add(a.Id);
            }
            
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getStackTraceString()));
        }
    }
    
    public void submitOfficeExclusiveForm(){
        system.debug(oOfficeExclusive);
        try{
            if(validateForm()){
                oOfficeExclusive.Address_Verified__c = (oOfficeExclusive.New_Construction__c == true)?false:true;
                insert oOfficeExclusive;
               	Attachment attach = new Attachment(parentId = oOfficeExclusive.Id, name=att.name, body = att.body);
                insert attach;
                att = new Attachment();
                hasError = false;
                isSuccessMsg = true;
                message = '<strong>Success:</strong> Your Office Exclusive Certification form has been submitted to Bright. To print a PDF copy of the form you submitted, click Print in the upper right hand corner of the screen.';
                subscription = [SELECT id,
                                Name,
                                Contact_Type__c,
                                Private_email__c,
                                Public_email__c,
                                Related_Location_Broker_Office__c,
                                Related_Location_Broker_Office__r.name,
                                Related_Location_Broker_Office__r.Account_Name__c,
                                Service_Jurisdiction__c,
                                Billing_Jurisdiction__c,
                                TREND_Login_Name__c,
                                BRIGHT_LoginName__c,
                                contact__c,
                                contact__r.Name,
                                contact__r.FirstName
                                FROM  Subscriptions__c
                                WHERE Id = :oOfficeExclusive.List_Agent_ID__c];       
                 sendEmailToAgent(subscription);
            }
        }catch(Exception ex){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getStackTraceString())); 
            isSuccessMsg = false;
            hasError = true;
            message = '<strong>Error:</strong> ' + ex.getMessage(); 
        }
    }
    
    //Method to send email for Listing Agent as an Acknowledgement
    public void sendEmailToAgent(Subscriptions__c subscription){  
        
        String contactFirstName = subscription.Contact__r.FirstName;
        String subPrivateEmail = subscription.Private_Email__c;
        string propertyAddress = oOfficeExclusive.Property_Address__c.replace('Ste ','Ste. ');
        string unittype = ''; 
        if(oOfficeExclusive.Unit_Type__c != null)
        unittype = oOfficeExclusive.Unit_Type__c.replace('Ste ','Ste. ');
        string city = oOfficeExclusive.City__c;
        string state = oOfficeExclusive.State__c;
        string zip = oOfficeExclusive.ZIP__c;
        String subId = subscription.id;
        string exclusiveId = oOfficeExclusive.Id;
        
        if(oOfficeExclusive.New_Construction__c == false){
            // grab the email template
            string emailBody = 'Confirmation_Email_to_Office_Exclusive_Online_Forms';
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName =: emailBody];
            
            // process the merge fields
            String htmlBody = emailTemplate.HtmlValue;
            String Subject = emailTemplate.Subject;
            htmlBody = htmlBody.replace('{!Contact.FirstName}', contactFirstName);
            htmlBody = htmlBody.replace('{!propertyAddress}', propertyAddress +' '+ unittype);
            htmlBody = htmlBody.replace('{!city}', city);
            htmlBody = htmlBody.replace('{!state}', state);
            htmlBody = htmlBody.replace('{!zip}', zip);
            htmlBody = htmlBody.replace('{!subId}', subId);
            htmlBody = htmlBody.replace('{!exclusiveId}', exclusiveId);
            htmlBody = htmlBody.replace('{!BrightLink}', Label.BRIGHT_Logo_Link);
            htmlBody = htmlBody.replace('{!BrightLogo}', Label.Email_Template_Register_Bright_Logo);
            htmlBody = htmlBody.replace('{!RBLogo}', Label.EmailTemplate_Responsible_Broker);
            
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!Contact.FirstName}', contactFirstName);
            plainBody = plainBody.replace('{!propertyAddress}', propertyAddress +' '+ unittype);
            plainBody = plainBody.replace('{!city}', city);
            plainBody = plainBody.replace('{!state}', state);
            plainBody = plainBody.replace('{!zip}', zip);
            plainBody = plainBody.replace('{!subId}', subId);
            plainBody = plainBody.replace('{!exclusiveId}', exclusiveId);
            
            
            List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
            String orgWideAddress = orgWideAddresses[0].Id;
            
            Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{subPrivateEmail};
                sendMail.setToAddresses(sendingTo);
            sendMail.setTreatTargetObjectAsRecipient(false);
            sendMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            sendMail.setSubject(Subject);
            sendMail.setHtmlBody(htmlBody);
            sendMail.setPlainTextBody(plainBody); 
            sendMail.setOrgWideEmailAddressId(orgWideAddress);
            
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {sendMail});
        }else{
            string emailBody = 'Confirmation_Email_to_Office_Exclusive_Online_Forms_without_Address';
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName =: emailBody];
            
            // process the merge fields
            String htmlBody = emailTemplate.HtmlValue;
            String Subject = emailTemplate.Subject;
            htmlBody = htmlBody.replace('{!Contact.FirstName}', contactFirstName);
            htmlBody = htmlBody.replace('{!subId}', subId);
            htmlBody = htmlBody.replace('{!exclusiveId}', exclusiveId);    
            htmlBody = htmlBody.replace('{!BrightLink}', Label.BRIGHT_Logo_Link);
            htmlBody = htmlBody.replace('{!BrightLogo}', Label.Email_Template_Register_Bright_Logo);
            htmlBody = htmlBody.replace('{!RBLogo}', Label.EmailTemplate_Responsible_Broker);
            
            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!Contact.FirstName}', contactFirstName);
            plainBody = plainBody.replace('{!subId}', subId);
            plainBody = plainBody.replace('{!exclusiveId}', exclusiveId);
            
            List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
            String orgWideAddress = orgWideAddresses[0].Id;
            
            Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{subPrivateEmail};
                sendMail.setToAddresses(sendingTo);
            sendMail.setTreatTargetObjectAsRecipient(false);
            sendMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            sendMail.setSubject(Subject);
            sendMail.setHtmlBody(htmlBody);
            sendMail.setPlainTextBody(plainBody); 
            sendMail.setOrgWideEmailAddressId(orgWideAddress);
            
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {sendMail}); 
        }
        
    }
    
    public Boolean validateForm(){
        
        if(oOfficeExclusive.Seller_Landlord_Name_1__c == null
           || oOfficeExclusive.Property_Address__c == null
           || oOfficeExclusive.City__c == null
           || oOfficeExclusive.ZIP__c == null
           || oOfficeExclusive.List_Agent_ID__c == null
          ){
              isSuccessMsg = false;
              hasError = true;
              message = '<strong>Error:</strong> Required fields must be populated.';
              return false;
          }
        return true;
    }
    
    
    //Agent Listing Ids edit functionality. Added by Mounika
    //Method to result the Agent Listing Ids
    @RemoteAction
    public static List<Subscriptions__c> searchAgentListings(String searchInput, String officeIdsStr) {
        List<String> officeIds = officeIdsStr.split(', ');
        searchInput = String.escapeSingleQuotes(searchInput) + '%';
        List<Subscriptions__c> subscriptions = [SELECT 	Id, Name, Contact__c, Contact__r.Name, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name, 
                                                Related_Location_Broker_Office__r.Account_Name__c, Related_Location_Broker_Office__r.ParentId 
                                                FROM 	Subscriptions__c 
                                                WHERE 	(Name LIKE :searchInput OR Contact__r.Name LIKE :searchInput)
                                                AND 	Status__c = 'Active' AND (Related_Location_Broker_Office__c IN: officeIds 
                                                                                  OR Related_Location_Broker_Office__r.ParentId IN: officeIds)
                                                LIMIT	50];
        return subscriptions;
    }    
    
    public void dummy(){}
    
    
    public class CustomException extends Exception {}
}