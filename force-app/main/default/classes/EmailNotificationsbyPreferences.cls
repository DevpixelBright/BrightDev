public class EmailNotificationsbyPreferences{
    
    private MRIS_Application__c mrisApplication;
    private String orgWideAddress;
    private Contact c;
    private Contact BORContact;
    private Contact ASContact;
    private List<Messaging.SingleEmailMessage> finalMails;
    private Map<String,Id> templateIdMap;
    private Map<String,EmailTemplate> templateIdBodyMap;
    private Map<string, list<Relationship__c>> bORRelationsMap = new Map<string, list<Relationship__c>>();
    private Map<string, list<Relationship__c>> aSRelationsMap = new Map<string, list<Relationship__c>>();
    
    private String brokerOfficeCode;
    private String BOREmailId;
    private Set<String> ASEmailIds;
    private set<String> ASFirstNames;
    private Map<String, String> mASEmailIds;
    private Set<String> OMEmailIds;
    private Set<String> PAEmailIds;   
    
    private String BORTemplateId;
    private String ASTemplateId;
    private String OMTemplateId;
    private String PATemplateId;    
    
    public void sendNotificationEmail(List<MRIS_Application__c> applications){
        system.debug('*** New Notification');
        c = [SELECT Id,Name,FirstName FROM Contact LIMIT 1];
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        for(MRIS_Application__c application : applications){
            mrisApplication = new MRIS_Application__c();
            mrisApplication = application;        
            findTemplateIds(application, 'New');            
            if(application.Application_Type__c == 'Agent Transfer')
                brokerOfficeCode = application.Destination_Broker_Office__c;
            else  
                brokerOfficeCode = application.Company_Code__c;
            findASEmailIds();
            findBOREmailId(application.Application_Type__c);
            if(application.Application_Type__c == 'Agent Transfer')
                findPAEmailIds();
            sendEmail();
        }
        system.debug('finalMails -size '+finalMails.size());
        system.debug('finalMails'+finalMails);
        Messaging.sendEmail(finalMails);
    }
    
    public void sendReminderEmail(List<MRIS_Application__c> applications){
        system.debug('*** Reminder Notification method is called');
        c = [SELECT Id,Name,FirstName  FROM Contact LIMIT 1];
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        for(MRIS_Application__c application : applications){
            mrisApplication = new MRIS_Application__c();
            mrisApplication = application;        
            findTemplateIds(application, 'Reminder');            
            if(application.Application_Type__c == 'Agent Transfer')
                brokerOfficeCode = application.Destination_Broker_Office__c;
            else  
                brokerOfficeCode = application.Company_Code__c;
            findASEmailIds();
            findBOREmailId(application.Application_Type__c);
            sendEmail();
        }
        system.debug('finalMails---size-remider--'+finalMails.size());
        Messaging.sendEmail(finalMails);
        
    }
    
    public void sendExpiryEmail(List<MRIS_Application__c> applications){
        system.debug('*** Expiry Notification');
        c = [SELECT Id,Name,FirstName  FROM Contact LIMIT 1];
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        list<Id> brokerOffCodeList = new list<Id>();
        for(MRIS_Application__c application : applications){
            brokerOffCodeList.add(application.Company_Code__c);
        }
        fetchRelations(brokerOffCodeList);
        
        if(applications != null)
        system.debug('applications---size---'+applications.size());
        
        for(MRIS_Application__c application : applications){
            mrisApplication = new MRIS_Application__c();
            mrisApplication = application;        
            findTemplateIds(application, 'Expiry');            
            
            brokerOfficeCode = application.Company_Code__c;
            //findASEmailIds();
            findASEmailIdsNew();
            //findBOREmailId(application.Application_Type__c);
            findBOREmailIdNew(application.Application_Type__c);
            sendEmail();
        }
        system.debug('finalMails--Expiry -size--'+finalMails.size());
        Messaging.sendEmail(finalMails);
    }   
    
    public void sendApprovedEmail(List<MRIS_Application__c> applications){
        system.debug('*** Reminder Notification');
        c = [SELECT Id,Name,FirstName  FROM Contact LIMIT 1];
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        for(MRIS_Application__c application : applications){
            mrisApplication = new MRIS_Application__c();
            mrisApplication = application;        
            findTemplateIds(application, 'Approved');            
            brokerOfficeCode = application.Company_Code__c;
            system.debug('&&&&: ' + brokerOfficeCode);
            findASEmailIds();
            findBOREmailId(application.Application_Type__c);
            findOfficeManagerEmailIds();
            sendEmailAll();	
        }
        system.debug('&&&&: ' + finalMails);
        Messaging.sendEmail(finalMails);
        
    }
    
    public void sendCompletedEmail(List<MRIS_Application__c> applications){
        system.debug('*** Reminder Notification');
        c = [SELECT Id,Name,FirstName  FROM Contact LIMIT 1];
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        for(MRIS_Application__c application : applications){
            mrisApplication = new MRIS_Application__c();
            mrisApplication = application;        
            findTemplateIds(application, 'Completed');            
            
            brokerOfficeCode = application.Destination_Broker_Office__c;
            findASEmailIds();
            findBOREmailId(application.Application_Type__c);
            findOfficeManagerEmailIds();
            sendEmailAll();
        }
        
        Messaging.sendEmail(finalMails);
        
    }
    
    private void findASEmailIds(){
        system.debug('***findASEmailIds');
        ASEmailIds = new Set<String>();
        ASFirstNames = new Set<String>();
        mASEmailIds = new Map<String, String>();
        for(Relationship__c relationship : [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, Subscription__r.Contact__r.FirstName, Subscription__r.Contact__r.Name,
                                            Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c 
                                            FROM   Relationship__c 
                                            WHERE  Broker_Office__c = :brokerOfficeCode
                                            AND    Relationship_Type__c  = 'Authorized Signer'
                                            AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                           ]){
                                               if(!relationship.Subscription__r.ApplicationNotificationOptOut__c){
                                                   ASEmailIds.add(relationship.Subscription__r.Private_Email__c);                        
                                                   mASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__r.Contact__r.Name);
                                                   if(String.isNotBlank(relationship.Subscription__r.Contact__r.FirstName)){
                                                       ASFirstNames.add(relationship.Subscription__r.Contact__r.FirstName);
                                                   }
                                                   ASContact = new Contact(Id=relationship.Subscription__r.Contact__c);
                                               }
                                           }
        system.debug('***ASEmailIds: ' + ASEmailIds);
        
    }
    
    private void findASEmailIdsNew(){
        system.debug('***findASEmailIds-New');
        ASEmailIds = new Set<String>();
        ASFirstNames = new Set<String>();
        mASEmailIds = new Map<String, String>();
        if(aSRelationsMap.containskey(brokerOfficeCode))
        for(Relationship__c relationship : aSRelationsMap.get(brokerOfficeCode))
        {
            if(!relationship.Subscription__r.ApplicationNotificationOptOut__c){
                ASEmailIds.add(relationship.Subscription__r.Private_Email__c);                        
                mASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__r.Contact__r.Name);
                if(String.isNotBlank(relationship.Subscription__r.Contact__r.FirstName)){
                    ASFirstNames.add(relationship.Subscription__r.Contact__r.FirstName);
                }
                ASContact = new Contact(Id=relationship.Subscription__r.Contact__c);
            }
        }
        system.debug('***ASEmailIds: New ' + ASEmailIds);
    }
    
    private void setTemplateIds(){
        system.debug('***setTemplateIds');
        templateIdMap = new Map<String,String>();
        templateIdBodyMap = new Map<String, EmailTemplate>();
        List<String> templateNames = new List<String>{
            'Broker_Authorization_Request_Remainder_Email_to_Agent',
                'IDX_VOW_Declined_Email_to_Agent_cc_Broker',   
                'IDX_VOW_Broker_Reminder_Letter',
                'BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review_TREND',
                'BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review',
                'BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review_TREND',
                'BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review',
                'BRIGHT_Broker_Application_to_MLS_Expired',
                'BRIGHT_Broker_To_Authorized_Signer_MLS_Application_Expired',
                'Agent_Transfer_Review_Application_AS',
                'Agent_Transfer_Review_Application_BOR',
                'Agent_Transfer_Pending_Requests_AS',
                'Agent_Transfer_Pending_Requests_BOR',
                'Agent_Transfer_Completed_Request_BOR',
                'Agent_Transfer_Approved_To_Previous_BOR',
                'Agent_Transfer_Request_to_PA',
                'Bright_AT_Completed_App_BOR_AS_OM',
                'Bright_AT_Review_App_AS',
                'Bright_AT_Review_App_BOR',
                'Bright_AT_Pending_App_BOR',
                'Bright_AT_Pending_App_AS',
                'Bright_AT_Approved_To_Previous_broker',
                'Bright_AT_Submission_To_PA',
                'BRIGHT_MLS_to_Broker_AS_Pending_MLS_Application_to_Review',
                'BRIGHT_MLS_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review',
                'BRIGHT_New_Application_Expired_To_BOR',
                'BRIGHT_New_Application_Expired_To_AS',
                'IDX_VOW_Agent_Expired_Email',
                'IDX_VOW_AS_Reminder_Letter',
                //'BRIGHT_Broker_authorization_Request'
                'IDX_VOW_BOR_Submission_Email',
                'IDX_VOW_AS_Submission_Email'
                               
                };
                    for(EmailTemplate et : [SELECT Id, DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName IN :templateNames]){
                        templateIdMap.put(et.DeveloperName, et.Id);
                        templateIdBodyMap.put(et.Id, et);
                    }
        system.debug('***templateNames'+templateNames);
    }
    
    private void findTemplateIds(MRIS_Application__c application, String status){
        system.debug('***findTemplateIds');
        
        if(status == 'Reminder'){
            if(application.Application_Type__c == 'Agent Transfer'){
                
                if(application.Service_Jurisdiction__c == 'BRIGHT'){
                    BORTemplateId = templateIdMap.get('Bright_AT_Pending_App_BOR');
                    ASTemplateId = templateIdMap.get('Bright_AT_Pending_App_AS');
                }else{
                    BORTemplateId = templateIdMap.get('Agent_Transfer_Pending_Requests_BOR');
                    ASTemplateId = templateIdMap.get('Agent_Transfer_Pending_Requests_AS'); 
                }
            }
            else if(application.Application_Type__c == 'IDX and VOW Agent Request'){
                // BORTemplateId = templateIdMap.get('Broker_Authorization_Request_Remainder_Email_to_Agent');
                // ASTemplateId = templateIdMap.get('Broker_Authorization_Request_Remainder_Email_to_Agent');
                
               BORTemplateId = templateIdMap.get('IDX_VOW_Broker_Reminder_Letter');                
               ASTemplateId = templateIdMap.get('IDX_VOW_AS_Reminder_Letter');
                system.debug('******  Reminder template assigned Broker_Authorization_Request_Remainder_Email_to_Agent');
                 system.debug('***IDX_VOW_Broker_Reminder_Letter');
            }
            else{
                if(application.Service_Jurisdiction__c == 'BRIGHT') {
                    BORTemplateId = templateIdMap.get('BRIGHT_MLS_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review');
                    ASTemplateId = templateIdMap.get('BRIGHT_MLS_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review');
                }
                else if(application.Service_Jurisdiction__c == 'TREND') {
                    BORTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review_TREND');
                    ASTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review_TREND');
                }            
                else{
                    BORTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review');
                    ASTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Reminder_of_a_Pending_MLS_Application_to_Review');
                }
            }            
        }        
        else if(status == 'New'){            
            if(application.Application_Type__c == 'Agent Transfer'){
                
                if(application.Service_Jurisdiction__c == 'BRIGHT'){
                    BORTemplateId = templateIdMap.get('Bright_AT_Review_App_BOR');
                    ASTemplateId = templateIdMap.get('Bright_AT_Review_App_AS');
                    PATemplateId = templateIdMap.get('Bright_AT_Submission_To_PA'); 
                }
                else{
                    BORTemplateId = templateIdMap.get('Agent_Transfer_Review_Application_BOR');
                    ASTemplateId = templateIdMap.get('Agent_Transfer_Review_Application_AS'); 
                    PATemplateId = templateIdMap.get('Agent_Transfer_Request_to_PA'); 
                }
            }else if(application.Application_Type__c == 'IDX and VOW Agent Request' && application.Service_Jurisdiction__c == 'BRIGHT'){
                BORTemplateId = templateIdMap.get('IDX_VOW_BOR_Submission_Email');
                ASTemplateId = templateIdMap.get('IDX_VOW_AS_Submission_Email'); 
                //  PATemplateId = templateIdMap.get('IDX_VOW_Broker_Reminder_Letter'); 
                
            }else{
                if(application.Service_Jurisdiction__c == 'BRIGHT') {
                    BORTemplateId = templateIdMap.get('BRIGHT_MLS_to_Broker_AS_Pending_MLS_Application_to_Review');
                    ASTemplateId = templateIdMap.get('BRIGHT_MLS_to_Broker_AS_Pending_MLS_Application_to_Review');           
                }
                else if(application.Service_Jurisdiction__c == 'TREND') {
                    BORTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review_TREND');
                    ASTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review_TREND');           
                }
                else {
                    BORTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review');
                    ASTemplateId = templateIdMap.get('BRIGHT_Broker_to_Broker_AS_Pending_MLS_Application_to_Review');
                }
            }
        }
        else if(status == 'Expiry'){
            if(application.Service_Jurisdiction__c == 'BRIGHT'){
                if(application.Application_Type__c == 'IDX and VOW Agent Request'){
                    BORTemplateId = templateIdMap.get('IDX_VOW_Agent_Expired_Email');
                    ASTemplateId = templateIdMap.get('IDX_VOW_Agent_Expired_Email');
                    system.debug('****** IDX_VOW_BOR_AS_Expired_Email');
                }else{
                    BORTemplateId = templateIdMap.get('BRIGHT_New_Application_Expired_To_BOR');
                    ASTemplateId = templateIdMap.get('BRIGHT_New_Application_Expired_To_AS');
                }
            }
            else {
                BORTemplateId = templateIdMap.get('BRIGHT_Broker_Application_to_MLS_Expired');
                ASTemplateId = templateIdMap.get('BRIGHT_Broker_To_Authorized_Signer_MLS_Application_Expired');
            }
        }  
        
        else if(status == 'Approved'){
            if(application.Service_Jurisdiction__c == 'BRIGHT'){
                BORTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');//ORG office
                ASTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');
                OMTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');
            }
            else{
                BORTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
                ASTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
                OMTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
            }
        }   
        
        /* else if(status == 'Approved'){
if(application.Service_Jurisdiction__c == 'BRIGHT'){
if(application.Application_Type__c == 'Broker Authorization Request'){
BORTemplateId = templateIdMap.get('');
}  ASTemplateId = templateIdMap.get('IDX_Approval_Letter');
OMTemplateId = templateIdMap.get('IDX_Approval_Letter'); 
system.debug('******  email send after approval IDX_Approval_Letter');
}else{                

BORTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');
ASTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');
OMTemplateId = templateIdMap.get('Bright_AT_Approved_To_Previous_broker');

}
}
else{
BORTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
ASTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
OMTemplateId = templateIdMap.get('Agent_Transfer_Approved_To_Previous_BOR');
}
} */  
        
        /* else if(status == 'Approved'){
system.debug('email send after approval');
if(application.Application_Type__c == 'Broker Authorization Request' && application.Service_Jurisdiction__c == 'BRIGHT'){
BORTemplateId = templateIdMap.get('IDX_Approval_Letter');
ASTemplateId = templateIdMap.get('IDX_Approval_Letter');
OMTemplateId = templateIdMap.get('IDX_Approval_Letter'); 
system.debug('******  email send after approval IDX_Approval_Letter');
}
}*/
        else if(status == 'Completed'){
            if(application.Service_Jurisdiction__c == 'BRIGHT'){
                BORTemplateId = templateIdMap.get('Bright_AT_Completed_App_BOR_AS_OM');
                ASTemplateId = templateIdMap.get('Bright_AT_Completed_App_BOR_AS_OM');
                OMTemplateId = templateIdMap.get('Bright_AT_Completed_App_BOR_AS_OM');
            }else{
                BORTemplateId = templateIdMap.get('Agent_Transfer_Completed_Request_BOR');
                ASTemplateId = templateIdMap.get('Agent_Transfer_Completed_Request_BOR');
                OMTemplateId = templateIdMap.get('Agent_Transfer_Completed_Request_BOR');    
            }
        } 
    }
    
    private void findBOREmailId(string applicationtype){      
        system.debug('***findBOREmailId');
        List<Account> relatedAccounts = new List<Account>(); 
        relatedAccounts = [SELECT Id, Name, ParentId
                           FROM   Account
                           WHERE  (ParentId = :brokerOfficeCode OR Id = :brokerOfficeCode) AND Status__c = 'Active' 
                          ];
        
        List<String> officeIds = new List<String>();                        
        for(Account a : relatedAccounts){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        relatedAccounts = new List<Account>();
        relatedAccounts = [SELECT Id, Name, ParentId
                           FROM   Account
                           WHERE  (ParentId = :officeIds OR Id = :officeIds) AND Status__c = 'Active'
                          ];
        for(Account a : relatedAccounts){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        List<Relationship__c> relationships = [SELECT Id,Name,Relationship_Type__c, Relationship_End_Date__c, Subscription__r.Contact__c,Subscription__r.Contact__r.FirstName, 
                                               Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c,
                                               Contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c, Contact__r.BRIGHT_email_preferences_APPLICATION__c
                                               FROM   Relationship__c 
                                               WHERE  Broker_Office__c IN :officeIds
                                               AND    Relationship_Type__c = 'Broker Of Record'
                                               AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                              ];
        system.debug('**** relationships: BOR ' +  relationships.size());
        if(relationships.size() > 0){
            if(applicationtype == 'Agent Transfer' && relationships[0].Contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c == true){
                BOREmailId = relationships[0].Subscription__r.Private_Email__c;   
                BORContact = new Contact(id=relationships[0].Subscription__r.Contact__c);
            }
            if((applicationtype == 'New Agent' || applicationtype == 'Reinstatement') && relationships[0].Contact__r.BRIGHT_email_preferences_APPLICATION__c == true) {
                BOREmailId = relationships[0].Subscription__r.Private_Email__c; 
                BORContact = new Contact(id= relationships[0].Subscription__r.Contact__c);
            }
            if(applicationtype == 'IDX and VOW Agent Request'){
                BOREmailId = relationships[0].Subscription__r.Private_Email__c;
                BORContact = new Contact(id= relationships[0].Subscription__r.Contact__c);
            }
            //else if(ASEmailIds.size() == 0)
            //    BOREmailId = relationships[0].Subscription__r.Private_Email__c;
        }
        system.debug('**** BOREmailId: ' +  BOREmailId);
    }     
    
    //Balakrishna April 6, 2021
    public void fetchRelations(list<Id> brokerOfficeIdList){
        system.debug('fetchRelations---');
        if(brokerOfficeIdList != null && brokerOfficeIdList.size()>0){
            List<Account> relatedAccounts = new List<Account>();
            Map<Id,set<Id>> brokerOfficesMap = new Map<Id, set<Id>>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId IN :brokerOfficeIdList OR Id IN :brokerOfficeIdList) AND Status__c = 'Active' 
                              ];
            
            List<String> officeIds = new List<String>();                        
            for(Account a : relatedAccounts)
            {
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);
            }
            relatedAccounts = new List<Account>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId IN :officeIds OR Id IN :officeIds) AND Status__c = 'Active'
                              ];
            for(Account a : relatedAccounts){
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);                
            }
            List<Relationship__c> relationships = [SELECT Id,Name,Relationship_Type__c, Relationship_End_Date__c, Subscription__r.Contact__c,Subscription__r.Contact__r.FirstName, 
                                                   Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c,Broker_Office__c, 
                                                   Contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c, Contact__r.BRIGHT_email_preferences_APPLICATION__c
                                                   FROM   Relationship__c 
                                                   WHERE  Broker_Office__c IN :officeIds
                                                   AND    Relationship_Type__c = 'Broker Of Record'
                                                   AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                  ];
            //BOR Email
            for(Relationship__c relationship : relationships){
                if(brokerOfficesMap.containskey(relationship.Broker_Office__c)){
                    for(Id brokerOffId : brokerOfficesMap.get(relationship.Broker_Office__c)){
                        if(!bORRelationsMap.containskey(brokerOffId)){
                            bORRelationsMap.put(brokerOffId, new list<Relationship__c>());
                        }
                        bORRelationsMap.get(brokerOffId).add(relationship);
                    }
                }
            }
            //AS Email
            for(Relationship__c relationship : 
                [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, Subscription__r.Contact__r.FirstName, Subscription__r.Contact__r.Name,
                 Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c, Broker_Office__c 
                 FROM   Relationship__c 
                 WHERE  Broker_Office__c IN :brokerOfficeIdList
                 AND    Relationship_Type__c  = 'Authorized Signer'
                 AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )])
            {
                if(!aSRelationsMap.containsKey(relationship.Broker_Office__c)){
                    aSRelationsMap.put(relationship.Broker_Office__c, new list<Relationship__c>());
                }
                aSRelationsMap.get(relationship.Broker_Office__c).add(relationship);
            }
        }
    }
    private void findBOREmailIdNew(string applicationtype){      
        system.debug('***findBOREmailId Temp');
        
        List<Relationship__c> relationships = bORRelationsMap.get(brokerOfficeCode);
        system.debug('**** relationships: BOR New ');
        if(relationships != null && relationships.size() > 0){
            if(applicationtype == 'Agent Transfer' && relationships[0].Contact__r.BRIGHT_email_preferences_AGENT_TRANSFER__c == true){
                BOREmailId = relationships[0].Subscription__r.Private_Email__c;   
                BORContact = new Contact(id=relationships[0].Subscription__r.Contact__c);
            }
            if((applicationtype == 'New Agent' || applicationtype == 'Reinstatement') && relationships[0].Contact__r.BRIGHT_email_preferences_APPLICATION__c == true) {
                BOREmailId = relationships[0].Subscription__r.Private_Email__c; 
                BORContact = new Contact(id= relationships[0].Subscription__r.Contact__c);
            }
            if(applicationtype == 'IDX and VOW Agent Request'){
                BOREmailId = relationships[0].Subscription__r.Private_Email__c;
                BORContact = new Contact(id= relationships[0].Subscription__r.Contact__c);
            }
            //else if(ASEmailIds.size() == 0)
            //    BOREmailId = relationships[0].Subscription__r.Private_Email__c;
        }
        system.debug('**** BOREmailId: ' +  BOREmailId);
    }
    
    private void findPAEmailIds(){
        system.debug('***findPAEmailIds');
        system.debug('***mrisApplication.Comments__c'+mrisApplication.Comments__c);
        Set<String> selectedPASet = (Set<String>) JSON.Deserialize(mrisApplication.Comments__c, Set<String>.class);
        
        system.debug('selectedPASet********'+selectedPASet);
        PAEmailIds = new Set<String>(); 
        List<Subscriptions__c> personalAssistants = new List<Subscriptions__c>();
        personalAssistants = [SELECT Id,
                              Name,
                              Private_email__c
                              FROM   Subscriptions__c
                              WHERE  ID IN : selectedPASet];
        
        for(Subscriptions__c PA : personalAssistants )
            PAEmailIds.add(PA.Private_email__c);
        
    }
    
    private void findOfficeManagerEmailIds(){
        system.debug('***findOfficeManagerEmailIds');
        OMEmailIds = new Set<String>();      
        
        for(Relationship__c relationship : [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                                            Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                                            FROM   Relationship__c 
                                            WHERE  Broker_Office__c = :brokerOfficeCode
                                            AND    Relationship_Type__c  = 'Office Manager'
                                            AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                           ]){
                                               if(!relationship.Subscription__r.ApplicationNotificationOptOut__c)
                                                   OMEmailIds.add(relationship.Subscription__r.Private_Email__c);                        
                                           }
        
    } 
    
    private void sendEmailAll(){
        system.debug('***sendEmailAll');
        List<String> toAddresses = new List<String>();
        if(String.isNotBlank(BOREmailId) && BOREmailId != null)
            toAddresses.add(BOREmailId);
        
        if(ASEmailIds.size() > 0){
            for(String aSEmailId : ASEmailIds) {
                if(aSEmailId != null)
                    toAddresses.add(ASEmailId);
            }
        }
        
        if(OMEmailIds != null && OMEmailIds.size() > 0){
            for(String omEmailId : OMEmailIds) {
                if(omEmailId != null)
                    toAddresses.add(omEmailId);
            }
        }
        if(String.isNotBlank(BORTemplateId)){        
            Messaging.SingleEmailMessage allMail = new Messaging.SingleEmailMessage();
            allMail.setTemplateID(BORTemplateId);
            allMail.setWhatId(mrisApplication.Id); 
            allMail.setToAddresses(toAddresses);
            allMail.setSaveAsActivity(false);
            allMail.setTargetObjectId(c.Id);
            allMail.setTreatTargetObjectAsRecipient(false);
            allMail.setOrgWideEmailAddressId(orgWideAddress);
            allMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            finalMails.add(allMail);
        }
        
    } 
    
    private void sendEmail(){
        system.debug('***sendEmail');
        if(String.isNotBlank(BOREmailId) && BOREmailId != null && String.isNotBlank(BORTemplateId)){
            List<String> toAddresses = new List<String>();
            toAddresses.add(BOREmailId);
            system.debug('*** toAddresses if BOR:'+ BORTemplateId + '--' + mrisApplication.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage BORMail = new Messaging.SingleEmailMessage();
            BORMail.setTemplateID(BORTemplateId);
            BORMail.setWhatId(mrisApplication.Id); 
            BORMail.setToAddresses(toAddresses);
            BORMail.setTargetObjectId(BORContact?.Id);
            BORMail.setTreatTargetObjectAsRecipient(false);
            BORMail.setSaveAsActivity(false);
            BORMail.setOrgWideEmailAddressId(orgWideAddress);
            BORMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            system.debug('TargetObjectId---'+BORMail.getTargetObjectId());
            system.debug('getBody---'+BORMail.getPlainTextBody());
            finalMails.add(BORMail);
        }
        
        if(ASEmailIds.size() > 0 && String.isNotBlank(ASTemplateId)){
            List<String> toAddresses = new List<String>();            
            for(String aSEmailId : ASEmailIds) {
                if(aSEmailId != null)
                    toAddresses.add(ASEmailId);
            }
            system.debug('*** toAddresses is AS:'+ ASTemplateId + '--' +  mrisApplication.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage ASmail = new Messaging.SingleEmailMessage();
            ASmail.setTemplateID(ASTemplateId); 
            ASmail.setWhatId(mrisApplication.Id);
            ASmail.setToAddresses(toAddresses);
            ASmail.setTargetObjectId(ASContact?.Id);
            ASmail.setTreatTargetObjectAsRecipient(false);
            ASmail.setSaveAsActivity(false);
            ASmail.setOrgWideEmailAddressId(orgWideAddress);
            ASmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            
            //Replace Contact merge field with coma seperated First Names of multiple Contacts - start //Bala March 12, 2021
            //EmailTemplate eTemp = [SELECT Id, HtmlValue,Subject,Body FROM EmailTemplate WHERE Id=:ASTemplateId];
            EmailTemplate eTemp = templateIdBodyMap.get(ASTemplateId).clone();
            eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!MRIS_Application__c.Id}', mrisApplication.Id).replace('{!$Label.Email_Template_Register_Bright_Logo}', Label.Email_Template_Register_Bright_Logo);
            eTemp.Body = eTemp?.Body?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!MRIS_Application__c.Id}', mrisApplication.Id);
            
            ASmail.setSubject(eTemp.Subject);
            ASmail.setHtmlBody(eTemp.HtmlValue);
            ASmail.setPlainTextBody(eTemp.Body);
            //Replace Contact merge field with coma seperated First Names of multiple Contacts - end
            system.debug('ASmail----'+ASmail);
            finalMails.add(ASmail);
        }  
        
        if(OMEmailIds != null && OMEmailIds.size() > 0 && String.isNotBlank(OMTemplateId)){
            List<String> toAddresses = new List<String>();            
            for(String omEmailId : OMEmailIds) {
                if(omEmailId != null)
                    toAddresses.add(omEmailId);
            }
            
            system.debug('*** toAddresses:'+ OMTemplateId + '--' +  mrisApplication.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage OMmail = new Messaging.SingleEmailMessage();
            OMmail.setTemplateID(OMTemplateId); 
            OMmail.setWhatId(mrisApplication.Id);
            OMmail.setToAddresses(toAddresses);
            OMmail.setTargetObjectId(c.Id);
            OMmail.setTreatTargetObjectAsRecipient(false);
            OMmail.setSaveAsActivity(false);
            OMmail.setOrgWideEmailAddressId(orgWideAddress);
            OMmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            finalMails.add(OMmail);
        } 
        
        if(PAEmailIds !=null &&PAEmailIds.size() > 0){
            List<String> toAddresses = new List<String>();            
            for(String paEmailId : PAEmailIds) {
                if(paEmailId != null)
                    toAddresses.add(paEmailId);
            }
            
            system.debug('*** toAddresses:'+ PATemplateId + '--' +  mrisApplication.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage PAmail = new Messaging.SingleEmailMessage();
            PAmail.setTemplateID(PATemplateId); 
            PAmail.setWhatId(mrisApplication.Id);
            PAmail.setToAddresses(toAddresses);
            PAmail.setTargetObjectId(c.Id);
            PAmail.setTreatTargetObjectAsRecipient(false);
            PAmail.setSaveAsActivity(false);
            PAmail.setOrgWideEmailAddressId(orgWideAddress);
            PAmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            system.debug('PAmail'+PAmail); 
            finalMails.add(PAmail);
        }  
        
    }
    
    public class CustomException extends Exception{}
    
}