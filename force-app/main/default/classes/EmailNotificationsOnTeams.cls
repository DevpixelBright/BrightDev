public class EmailNotificationsOnTeams {
    private Teams__c teams;
    private String orgWideAddress;
    private Contact BORContact;
    private Contact ASContact;
    private String BORName = '';
    
    private List<Messaging.SingleEmailMessage> finalMails;
    private Map<String,Id> templateIdMap;
    private Map<String,EmailTemplate> templateIdBodyMap;
    Map<Id,set<Id>> brokerOfficesMap = new Map<Id, set<Id>>();
    private Map<string, list<Relationship__c>> bORRelationsMap = new Map<string, list<Relationship__c>>();
    private Map<string, list<Relationship__c>> aSRelationsMap = new Map<string, list<Relationship__c>>();
    
    private String brokerOfficeCode;
    private String teamLeadName;
    private String myDate;
    private String myDate2;
    private String yr;
    private String teamName;
    private String DisbandDate;
    private String DisbandByName;
    private String StatusReason;
    private String remainderEmail;
    private String teamId;
    private String teamRequestId;
    private String BOREmailId;
    private String teamOption;
    
    private Set<String> ASEmailIds;
    private set<String> ASFirstNames;
    private Map<String, String> mASEmailIds;
    
    private String BORTemplateId;
    private String ASTemplateId;
    
    public void sendNotificationEmail(List<Teams__c> teamRequests){
        system.debug('*** New Notification');
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        list<Id> brokerOffCodeList = new list<Id>();
        for(Teams__c team : teamRequests){
            if(team.Office_ID__c != null)
                brokerOffCodeList.add(team.Office_ID__c);
        }
        fetchRelations(brokerOffCodeList);   
        
        for(Teams__c team : [SELECT Id,Team_Request_ID__c,Remainder_Email__c,Invitation_Status__c, Team_Lead__r.Name,Team_Lead_Email__c, Team_Name__c,Office_ID__c, Team_Option__c FROM Teams__c WHERE Id IN :teamRequests AND Office_ID__c IN :brokerOffCodeList]){
            teams = new Teams__c();
            teams = team;        
            findTemplateIds('Requested');
            //findTemplateIds2('Requested', teams.Remainder_Email__c);            
            brokerOfficeCode = team.Office_ID__c;
            teamLeadName = team.Team_Lead__r.Name;
            teamRequestId = team.Team_Request_ID__c;
            teamId = team.Id;
            teamOption = team.Team_Option__c;
            teamName = team.Team_Name__c;
            
            findASEmailIds();
            findBOREmailId();
            System.debug('---->'+teams.Remainder_Email__c);
            sendEmail('Requested');
			//sendEmail2('Requested',teams.Remainder_Email__c);
        }
        system.debug('finalMails -size '+finalMails.size());
        system.debug('finalMails'+finalMails);
        Messaging.sendEmail(finalMails);
    }
    
    public void disbandNotificationEmail(List<Teams__c> teamRequests){
        system.debug('*** Disband Notification');
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        list<Id> brokerOffCodeList = new list<Id>();
        for(Teams__c team : teamRequests){
            if(team.Office_ID__c != null)
                brokerOffCodeList.add(team.Office_ID__c);
        }
        fetchRelations(brokerOffCodeList);   
        
        for(Teams__c team : [SELECT Id,Team_Request_ID__c, Status_Reason__c, Remainder_Email__c,Team_Lead_Email__c,Team_Lead__r.Name,Team_Name__c, Office_ID__c, Disband_Date__c, Disbanded_By_Name__c FROM Teams__c WHERE Id IN :teamRequests]){
            teams = new Teams__c();
            teams = team;        
            StatusReason = team.Status_Reason__c;
			remainderEmail = team.Remainder_Email__c;
            brokerOfficeCode = team.Office_ID__c;
            teamLeadName = team.Team_Lead__r.Name;
            teamRequestId = team.Team_Request_ID__c;
            teamId = team.Id;
            DisbandByName = team.Disbanded_By_Name__c;
            
            findTemplateIds(StatusReason); 
            //findTemplateIds2(StatusReason,remainderEmail);
            
            if(team.Disband_Date__c != null){
                DisbandDate = String.valueOf(team.Disband_Date__c.month())+'/'+String.valueOf(team.Disband_Date__c.day())+'/'+String.valueOf(team.Disband_Date__c.year());//format(MM/DD/YYYY)
            }
            teamName = team.Team_Name__c;
            
            findASEmailIds();
            findBOREmailId();
            
            sendEmail(StatusReason);
			//sendEmail2(StatusReason,remainderEmail);
        }
        system.debug('finalMails -size '+finalMails.size());
        system.debug('finalMails'+finalMails);
        Messaging.sendEmail(finalMails);
    }
    
    private void setTemplateIds(){
        system.debug('***setTemplateIds');
        templateIdMap = new Map<String,String>();
        templateIdBodyMap = new Map<String, EmailTemplate>();
        List<String> templateNames = new List<String>{
            'Team_Lead_submit_request_sent_to_AS',
                'Team_Lead_submit_request_sent_to_BOR',
                'Email_to_AS_when_team_is_disbanded',
                'Email_to_BOR_when_team_is_disbanded',
                'Email_to_BOR_when_team_is_disbanded_by_BOR_AS',
                'Email_to_AS_when_team_is_disbanded_by_BOR_AS',
                'Team_Lead_submit_request_7_day_reminder_sent_to_AS',
                'Team_Lead_submit_request_7_day_reminder_sent_to_BOR',
                'Teams_Request_3_Day_Final_reminder_to_email_BOR',
                'Teams_Request_3_Day_Final_reminder_to_email_AS'
                };
                    for(EmailTemplate et : [SELECT Id, DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName IN :templateNames])
                {
                    templateIdMap.put(et.DeveloperName, et.Id);
                    templateIdBodyMap.put(et.Id, et);
                }
        system.debug('***templateNames'+templateNames);
    }
    
    private void findTemplateIds(String status){
        system.debug('***findTemplateIds');
        if(status == 'Requested'){
            BORTemplateId = templateIdMap.get('Team_Lead_submit_request_sent_to_BOR');
            ASTemplateId = templateIdMap.get('Team_Lead_submit_request_sent_to_AS');
            system.debug('**** BORTemplateId: ' +  BORTemplateId);
            system.debug('**** ASTemplateId: ' +  ASTemplateId);
        } 
        if(status == 'System Disband'){
            BORTemplateId = templateIdMap.get('Email_to_BOR_when_team_is_disbanded');
            ASTemplateId = templateIdMap.get('Email_to_AS_when_team_is_disbanded');
            system.debug('**** BORTemplateId: ' +  BORTemplateId);
            system.debug('**** ASTemplateId: ' +  ASTemplateId);
        }
        else if(status == 'Broker Disband'){
            BORTemplateId = templateIdMap.get('Email_to_BOR_when_team_is_disbanded_by_BOR_AS');
            ASTemplateId = templateIdMap.get('Email_to_AS_when_team_is_disbanded_by_BOR_AS');
            system.debug('**** BORTemplateId: ' +  BORTemplateId);
            system.debug('**** ASTemplateId: ' +  ASTemplateId);
        }
    }
    private void findTemplateIds2(String status, String remainderEmail){
        system.debug('***findTemplateIds2');
        if(status == 'Requested' && remainderEmail == '7 Day Reminder'){
            BORTemplateId = templateIdMap.get('Team_Lead_submit_request_7_day_reminder_sent_to_BOR');
            ASTemplateId = templateIdMap.get('Team_Lead_submit_request_7_day_reminder_sent_to_AS');
            system.debug('**** BORTemplateId2: ' +  BORTemplateId);
            system.debug('**** ASTemplateId2: ' +  ASTemplateId);
        } 
    }
private void findTemplateIds3(String status, String remainderEmail){
        system.debug('***findTemplateIds3');
        if(status == 'Requested' && remainderEmail == '11 Day Reminder'){
            BORTemplateId = templateIdMap.get('Teams_Request_3_Day_Final_reminder_to_email_BOR');
            ASTemplateId = templateIdMap.get('Teams_Request_3_Day_Final_reminder_to_email_AS');
            system.debug('**** BORTemplateId3: ' +  BORTemplateId);
            system.debug('**** ASTemplateId3: ' +  ASTemplateId);
        } 
    }    
    private void findASEmailIds(){
        system.debug('***findASEmailIds');
        ASEmailIds = new Set<String>();
        ASFirstNames = new Set<String>();
        mASEmailIds = new Map<String, String>();
        if(aSRelationsMap.containskey(brokerOfficeCode)){
            for(Relationship__c relationship : aSRelationsMap.get(brokerOfficeCode)){
                if(!relationship.Subscription__r.ApplicationNotificationOptOut__c){
                    ASEmailIds.add(relationship.Subscription__r.Private_Email__c);                        
                    mASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__r.Contact__r.Name);
                    if(String.isNotBlank(relationship.Subscription__r.Contact__r.FirstName)){
                        ASFirstNames.add(relationship.Subscription__r.Contact__r.FirstName);
                    }
                    ASContact = new Contact(Id=relationship.Subscription__r.Contact__c);
                }
            }
        }
        system.debug('***ASEmailIds: ' + ASEmailIds);
    }
    
    private void findBOREmailId(){      
        system.debug('***findBOREmailId');
        List<Relationship__c> relationships = new List<Relationship__c>(); 
        if(brokerOfficesMap.containsKey(brokerOfficeCode)){
            for(Id officeId : brokerOfficesMap.get(brokerOfficeCode)){
                if(bORRelationsMap.containskey(officeId)){
                    relationships.addAll(bORRelationsMap.get(officeId));
                }
            }
        }
        //List<Relationship__c> relationships = bORRelationsMap.get(brokerOfficeCode);        
        if(relationships.size() > 0){
            BOREmailId = relationships[0].Subscription__r.Private_Email__c;   
            BORContact = new Contact(id=relationships[0].Subscription__r.Contact__c);
            BORName = relationships[0].Subscription__r.Contact__r.FirstName;
        }
        system.debug('**** BOREmailId: ' +  BOREmailId);
    }
    
    public void fetchRelations(list<Id> brokerOfficeIdList){
        system.debug('fetchRelations---');
        if(brokerOfficeIdList != null && brokerOfficeIdList.size()>0){
            
            
            List<Account> relatedAccounts = new List<Account>();
            brokerOfficesMap = new Map<Id, set<Id>>();
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
            system.debug('****brokerOfficesMap'+brokerOfficesMap);
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
    
    private void sendEmail(String status){
        system.debug('**** BOREmailId: ' +  BOREmailId);
        system.debug('**** BORTemplateId: ' +  BORTemplateId);
        String Subject;
        if(String.isNotBlank(BOREmailId) && BOREmailId != null && String.isNotBlank(BORTemplateId)){
            
            system.debug('***sendEmail');
            EmailTemplate eTemp = templateIdBodyMap.get(BORTemplateId).clone();
            
            // process the merge fields
            String htmlBody = eTemp.HtmlValue;
            String plainBody = eTemp.Body;
            if(status == 'Requested'){
                Subject = eTemp.Subject; 
                htmlBody = htmlBody.replace('{!TLName}', teamLeadName);
                htmlBody = htmlBody.replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink);
                htmlBody = htmlBody.replace('{!teamRequestId}', teamRequestId);
                htmlBody = htmlBody.replace('{!teamName}', teamName);
                htmlBody = htmlBody.replace('{!teamOption}', teamOption);
                plainBody = plainBody.replace('{!TLName}', teamLeadName);
                plainBody = plainBody.replace('{!teamRequestId}', teamRequestId);
                plainBody = plainBody.replace('{!teamName}', teamName);
                plainBody = plainBody.replace('{!teamOption}', teamOption);
                
            }else if(status == 'System Disband' || status == 'Broker Disband'){
                Subject = eTemp.Subject.replace('{!teamName}', teamName);
                if(!string.isBlank(DisbandDate)){
                    htmlBody = htmlBody.replace('{!DisbandDate}', DisbandDate);
                    plainBody = plainBody.replace('{!DisbandDate}', DisbandDate);
                }
                htmlBody = htmlBody.replace('{!teamName}', teamName).replace('{!YEAR(TODAY())}', ''+system.today().year());
                plainBody = plainBody.replace('{!teamName}', teamName).replace('{!YEAR(TODAY())}', ''+system.today().year());
            }
            
            if(status == 'Broker Disband' && !string.isBlank(DisbandByName)){
                htmlBody = htmlBody.replace('{!DisbandByName}', DisbandByName);
                plainBody = plainBody.replace('{!DisbandByName}', DisbandByName);
            }
            
            htmlBody = htmlBody.replace('{!BORName}', BORName);
            htmlBody = htmlBody.replace('{!teamId}', teamId);
            
            plainBody = plainBody.replace('{!BORName}', BORName);
            plainBody = plainBody.replace('{!teamId}', teamId);
            
            List<String> toAddresses = new List<String>();
            toAddresses.add(BOREmailId);
            system.debug('*** toAddresses if BOR:'+ BORTemplateId + '--' + teams.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage BORMail = new Messaging.SingleEmailMessage();
            BORMail.setTemplateID(BORTemplateId);            
            BORMail.setWhatId(teams.Id); 
            BORMail.setToAddresses(toAddresses);
            BORMail.setTargetObjectId(BORContact?.Id);
            BORMail.setTreatTargetObjectAsRecipient(false);
            BORMail.setSaveAsActivity(false);
            BORMail.setHtmlBody(htmlBody);
            BORMail.setSubject(Subject);
            BORMail.setPlainTextBody(plainBody);
            BORMail.setOrgWideEmailAddressId(orgWideAddress);
            BORMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            finalMails.add(BORMail);
        }
        if(ASEmailIds != null && ASEmailIds.size() > 0 &&  String.isNotBlank(ASTemplateId)){
            List<String> toAddresses = new List<String>();            
            for(String aSEmailId : ASEmailIds) {
                if(aSEmailId != null)
                    toAddresses.add(ASEmailId);
            }
            system.debug('*** toAddresses is AS:'+ ASTemplateId + '--' +  teams.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage ASmail = new Messaging.SingleEmailMessage();
            ASmail.setTemplateID(ASTemplateId); 
            ASmail.setWhatId(teams.Id);
            ASmail.setToAddresses(toAddresses);
            ASmail.setTargetObjectId(ASContact?.Id);
            ASmail.setTreatTargetObjectAsRecipient(false);
            ASmail.setSaveAsActivity(false);
            ASmail.setOrgWideEmailAddressId(orgWideAddress);
            ASmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            
            EmailTemplate eTemp = templateIdBodyMap.get(ASTemplateId).clone();
            if(status == 'Requested'){
                eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.Email_Template_Register_Bright_Logo}', Label.Email_Template_Register_Bright_Logo).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName);
                eTemp.Body = eTemp?.Body?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName);
                ASmail.setSubject(eTemp.Subject);
           
           }
            else if(status == 'System Disband' || status == 'Broker Disband'){
                eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!$Label.Email_Template_Register_Bright_Logo}', Label.Email_Template_Register_Bright_Logo).replace('{!teamName}', teamName).replace('{!YEAR(TODAY())}', ''+system.today().year());
                eTemp.Body = eTemp?.Body?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamName}', teamName).replace('{!YEAR(TODAY())}', ''+system.today().year());
                if(!string.isBlank(DisbandDate)){
                    eTemp.Body = eTemp?.Body?.replace('{!DisbandDate}', DisbandDate);
                    eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!DisbandDate}', DisbandDate);
                }
                if(status == 'Broker Disband' && !string.isBlank(DisbandByName)){
                    eTemp.Body = eTemp?.Body?.replace('{!DisbandByName}', DisbandByName);
                    eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!DisbandByName}', DisbandByName);
                }
            	 ASmail.setSubject(eTemp.Subject.replace('{!teamName}', teamName));
            }
            
            ASmail.setHtmlBody(eTemp.HtmlValue);
            ASmail.setPlainTextBody(eTemp.Body);
            finalMails.add(ASmail);
        }  
    }
    private void sendEmail2(String status, String remainderEmail){
        system.debug('**** BOREmailId: ' +  BOREmailId);
        system.debug('**** BORTemplateId: ' +  BORTemplateId);
        String Subject;
        
        if(String.isNotBlank(BOREmailId) && BOREmailId != null && String.isNotBlank(BORTemplateId)){
            
            system.debug('***sendEmail2');
            EmailTemplate eTemp = templateIdBodyMap.get(BORTemplateId).clone();
            
            // process the merge fields
            String htmlBody = eTemp.HtmlValue;
            String plainBody = eTemp.Body;
            if(status == 'Requested' && remainderEmail == '7 Day Reminder'){
                Subject = eTemp.Subject; 
                htmlBody = htmlBody.replace('{!TLName}', teamLeadName);
                htmlBody = htmlBody.replace('{!ApprovalLinkExpDate}', myDate);
                htmlBody = htmlBody.replace('{!ReqDate}', myDate2);
                htmlBody = htmlBody.replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink);
                htmlBody = htmlBody.replace('{!teamRequestId}', teamRequestId);
                htmlBody = htmlBody.replace('{!teamName}', teamName);
                htmlBody = htmlBody.replace('{!teamOption}', teamOption);
                htmlBody = htmlBody.replace('{!year}', yr);
                plainBody = plainBody.replace('{!TLName}', teamLeadName);
                plainBody = plainBody.replace('{!teamRequestId}', teamRequestId);
                plainBody = plainBody.replace('{!teamName}', teamName);
                plainBody = plainBody.replace('{!teamOption}', teamOption);
                plainBody = plainBody.replace('{!ApprovalLinkExpDate}', myDate);
                plainBody = plainBody.replace('{!ReqDate}', myDate2);
                plainBody = plainBody.replace('{!year}', yr);
                
           }
            
            htmlBody = htmlBody.replace('{!BORName}', BORName);
            htmlBody = htmlBody.replace('{!teamId}', teamId);
            
            plainBody = plainBody.replace('{!BORName}', BORName);
            plainBody = plainBody.replace('{!teamId}', teamId);
            
            List<String> toAddresses = new List<String>();
            toAddresses.add(BOREmailId);
            system.debug('*** toAddresses if BOR:'+ BORTemplateId + '--' + teams.Id + '--' + toAddresses);
            List<String> ccAddresses = new List<String>();
            ccAddresses.add(teams.Team_Lead_Email__c);
            
            Messaging.SingleEmailMessage BORMail = new Messaging.SingleEmailMessage();
            BORMail.setTemplateID(BORTemplateId);            
            BORMail.setWhatId(teams.Id); 
            BORMail.setToAddresses(toAddresses);
            BORMail.setCcAddresses(ccAddresses);
            BORMail.setTargetObjectId(BORContact?.Id);
            BORMail.setTreatTargetObjectAsRecipient(false);
            BORMail.setSaveAsActivity(true);
            BORMail.setHtmlBody(htmlBody);
            BORMail.setSubject(Subject);
            BORMail.setPlainTextBody(plainBody);
            BORMail.setOrgWideEmailAddressId(orgWideAddress);
            BORMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            finalMails.add(BORMail);
        }
        if(ASEmailIds != null && ASEmailIds.size() > 0 &&  String.isNotBlank(ASTemplateId)){
            List<String> toAddresses = new List<String>();            
            for(String aSEmailId : ASEmailIds) {
                if(aSEmailId != null)
                    toAddresses.add(ASEmailId);
            }
            system.debug('*** toAddresses is AS:'+ ASTemplateId + '--' +  teams.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage ASmail = new Messaging.SingleEmailMessage();
            ASmail.setTemplateID(ASTemplateId); 
            ASmail.setWhatId(teams.Id);
            ASmail.setToAddresses(toAddresses);
            ASmail.setTargetObjectId(ASContact?.Id);
            ASmail.setTreatTargetObjectAsRecipient(false);
            ASmail.setSaveAsActivity(true);
            ASmail.setOrgWideEmailAddressId(orgWideAddress);
            ASmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            
            EmailTemplate eTemp = templateIdBodyMap.get(ASTemplateId).clone();
            if(status == 'Requested' && remainderEmail == '7 Day Reminder'){
                eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.Email_Template_Register_Bright_Logo}', Label.Email_Template_Register_Bright_Logo).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName).replace('{!TLName}', teamLeadName).replace('{!ApprovalLinkExpDate}', myDate).replace('{!ReqDate}', myDate2).replace('{!year}', yr);
                eTemp.Body = eTemp?.Body?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName).replace('{!TLName}', teamLeadName).replace('{!ApprovalLinkExpDate}', myDate).replace('{!ReqDate}', myDate2).replace('{!year}', yr);
                ASmail.setSubject(eTemp.Subject);
           
           }
            
            ASmail.setHtmlBody(eTemp.HtmlValue);
            ASmail.setPlainTextBody(eTemp.Body);
            finalMails.add(ASmail);
        }
    }
    public void sendNotificationEmail2(List<Teams__c> teamRequests){
        system.debug('*** New Notification');
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        list<Id> brokerOffCodeList = new list<Id>();
        for(Teams__c team : teamRequests){
            if(team.Office_ID__c != null)
                brokerOffCodeList.add(team.Office_ID__c);
        }
        fetchRelations(brokerOffCodeList);   
        
        for(Teams__c team : [SELECT Id,Team_Request_ID__c,Remainder_Email__c,Broker_Approval_Link_Expiry_Date__c,Requested_Date__c,
                             Invitation_Status__c, Team_Lead__r.Name,Team_Lead_Email__c, Team_Name__c,Office_ID__c, Team_Option__c FROM Teams__c WHERE Id IN :teamRequests AND Office_ID__c IN :brokerOffCodeList]){
            teams = new Teams__c();
            teams = team;        
            //findTemplateIds('Requested');
            findTemplateIds2('Requested', '7 Day Reminder');            
            brokerOfficeCode = team.Office_ID__c;
            teamLeadName = team.Team_Lead__r.Name;
            Datetime newmyDate = team.Broker_Approval_Link_Expiry_Date__c;
            Datetime newmyDate2 = team.Requested_Date__c;
             myDate = newmyDate.format('MM-dd-yyyy');
             myDate2 = newmyDate2.format('MM-dd-yyyy');
             Datetime newyr = system.now();
                        yr = newyr.format('yyyy');
        
            teamRequestId = team.Team_Request_ID__c;
            teamId = team.Id;
            teamOption = team.Team_Option__c;
            teamName = team.Team_Name__c;
            
            findASEmailIds();
            findBOREmailId();
            System.debug('---->'+teams.Remainder_Email__c);
            //sendEmail('Requested');
			sendEmail2('Requested',teams.Remainder_Email__c);
        }
        system.debug('finalMails -size '+finalMails.size());
        system.debug('finalMails'+finalMails);
        Messaging.sendEmail(finalMails);
    }
private void sendEmail3(String status, String remainderEmail){
        system.debug('**** BOREmailId3: ' +  BOREmailId);
        system.debug('**** BORTemplateId3: ' +  BORTemplateId);
        String Subject;
        if(String.isNotBlank(BOREmailId) && BOREmailId != null && String.isNotBlank(BORTemplateId)){
            
            system.debug('***sendEmail3');
            EmailTemplate eTemp = templateIdBodyMap.get(BORTemplateId).clone();
            
            // process the merge fields
            String htmlBody = eTemp.HtmlValue;
            String plainBody = eTemp.Body;
            if(status == 'Requested' && remainderEmail == '11 Day Reminder'){
                Subject = eTemp.Subject; 
                htmlBody = htmlBody.replace('{!TLName}', teamLeadName);
                htmlBody = htmlBody.replace('{!ApprovalLinkExpDate}', myDate);
                htmlBody = htmlBody.replace('{!ReqDate}', myDate2);
                htmlBody = htmlBody.replace('{!year}', yr);
                htmlBody = htmlBody.replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink);
                htmlBody = htmlBody.replace('{!teamRequestId}', teamRequestId);
                htmlBody = htmlBody.replace('{!teamName}', teamName);
                htmlBody = htmlBody.replace('{!teamOption}', teamOption);
                plainBody = plainBody.replace('{!TLName}', teamLeadName);
                plainBody = plainBody.replace('{!teamRequestId}', teamRequestId);
                plainBody = plainBody.replace('{!teamName}', teamName);
                plainBody = plainBody.replace('{!teamOption}', teamOption);
                plainBody = plainBody.replace('{!ApprovalLinkExpDate}', myDate);
                plainBody = plainBody.replace('{!ReqDate}', myDate2);
                plainBody = plainBody.replace('{!year}', yr);
                
           }
            
            htmlBody = htmlBody.replace('{!BORName}', BORName);
            htmlBody = htmlBody.replace('{!teamId}', teamId);
            
            plainBody = plainBody.replace('{!BORName}', BORName);
            plainBody = plainBody.replace('{!teamId}', teamId);
            
            List<String> toAddresses = new List<String>();
            toAddresses.add(BOREmailId);
            system.debug('*** toAddresses if BOR:'+ BORTemplateId + '--' + teams.Id + '--' + toAddresses);
            List<String> ccAddresses = new List<String>();
            ccAddresses.add(teams.Team_Lead_Email__c);
            
            Messaging.SingleEmailMessage BORMail = new Messaging.SingleEmailMessage();
            BORMail.setTemplateID(BORTemplateId);            
            BORMail.setWhatId(teams.Id); 
            BORMail.setToAddresses(toAddresses);
            BORMail.setCcAddresses(ccAddresses);
            BORMail.setTargetObjectId(BORContact?.Id);
            BORMail.setTreatTargetObjectAsRecipient(false);
            BORMail.setSaveAsActivity(true);
            BORMail.setHtmlBody(htmlBody);
            BORMail.setSubject(Subject);
            BORMail.setPlainTextBody(plainBody);
            BORMail.setOrgWideEmailAddressId(orgWideAddress);
            BORMail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            finalMails.add(BORMail);
        }
        if(ASEmailIds != null && ASEmailIds.size() > 0 &&  String.isNotBlank(ASTemplateId)){
            List<String> toAddresses = new List<String>();            
            for(String aSEmailId : ASEmailIds) {
                if(aSEmailId != null)
                    toAddresses.add(ASEmailId);
            }
            system.debug('*** toAddresses is AS:'+ ASTemplateId + '--' +  teams.Id + '--' + toAddresses);
            
            Messaging.SingleEmailMessage ASmail = new Messaging.SingleEmailMessage();
            ASmail.setTemplateID(ASTemplateId); 
            ASmail.setWhatId(teams.Id);
            ASmail.setToAddresses(toAddresses);
            ASmail.setTargetObjectId(ASContact?.Id);
            ASmail.setTreatTargetObjectAsRecipient(false);
            ASmail.setSaveAsActivity(true);
            ASmail.setOrgWideEmailAddressId(orgWideAddress);
            ASmail.setBccAddresses(new String[] {Label.Email_to_Salesforce_Id});
            
            EmailTemplate eTemp = templateIdBodyMap.get(ASTemplateId).clone();
            if(status == 'Requested' && remainderEmail == '11 Day Reminder'){
                eTemp.HtmlValue = eTemp?.HtmlValue?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.Email_Template_Register_Bright_Logo}', Label.Email_Template_Register_Bright_Logo).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName).replace('{!TLName}', teamLeadName).replace('{!ApprovalLinkExpDate}', myDate).replace('{!ReqDate}', myDate2).replace('{!year}', yr);
                eTemp.Body = eTemp?.Body?.replace('{!Contact.FirstName}', String.join(new list<String>(ASFirstNames), ', ')).replace('{!Teams__c.Id}', teams.Id).replace('{!teamLeadName}', teamLeadName).replace('{!$Label.ET_Team_Approvelink}', Label.ET_Team_Approvelink).replace('{!teamRequestId}', teamRequestId).replace('{!teamOption}', teamOption).replace('{!teamName}', teamName).replace('{!TLName}', teamLeadName).replace('{!ApprovalLinkExpDate}', myDate).replace('{!ReqDate}', myDate2).replace('{!year}', yr);
                ASmail.setSubject(eTemp.Subject);
           
           }
            
            ASmail.setHtmlBody(eTemp.HtmlValue);
            ASmail.setPlainTextBody(eTemp.Body);
            finalMails.add(ASmail);
        }
    }
    public void sendNotificationEmail3(List<Teams__c> teamRequests){
        system.debug('*** New Notification3');
        setTemplateIds();
        
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        list<Id> brokerOffCodeList = new list<Id>();
        for(Teams__c team : teamRequests){
            if(team.Office_ID__c != null)
                brokerOffCodeList.add(team.Office_ID__c);
        }
        fetchRelations(brokerOffCodeList);   
        
        for(Teams__c team : [SELECT Id,Team_Request_ID__c,Remainder_Email__c,Broker_Approval_Link_Expiry_Date__c,Requested_Date__c,
                             Invitation_Status__c, Team_Lead__r.Name,Team_Lead_Email__c, Team_Name__c,Office_ID__c, Team_Option__c FROM Teams__c WHERE Id IN :teamRequests AND Office_ID__c IN :brokerOffCodeList]){
            teams = new Teams__c();
            teams = team;        
            //findTemplateIds('Requested');
            findTemplateIds3('Requested', '11 Day Reminder');            
            brokerOfficeCode = team.Office_ID__c;
            teamLeadName = team.Team_Lead__r.Name;
            Datetime newmyDate = team.Broker_Approval_Link_Expiry_Date__c;
            Datetime newmyDate2 = team.Requested_Date__c;
             myDate = newmyDate.format('MM-dd-yyyy');
             myDate2 = newmyDate2.format('MM-dd-yyyy');
                                 Datetime newyr = system.now();
                        yr = newyr.format('yyyy');
            teamRequestId = team.Team_Request_ID__c;
            teamId = team.Id;
            teamOption = team.Team_Option__c;
            teamName = team.Team_Name__c;
            
            findASEmailIds();
            findBOREmailId();
            System.debug('---->'+teams.Remainder_Email__c);
            //sendEmail('Requested');
			sendEmail3('Requested',teams.Remainder_Email__c);
        }
        system.debug('finalMails -size '+finalMails.size());
        system.debug('finalMails'+finalMails);
        Messaging.sendEmail(finalMails);
    }

    public class CustomException extends Exception{}
}