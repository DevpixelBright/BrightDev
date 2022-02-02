public class LT_EmailNotifications {
    
    //Set<String> agentEmailIds;
    Set<String> originationOfficeIds;
    Set<String> destinationOfficeIds;
    
    
    /* Set<String> originationBrokerEmailIds;
    Set<String> originationASEmailIds;
    Set<String> destinationBrokerEmailIds;
    Set<String> destinationASEmailIds; */
    
    Map<String, Id> agentEmailIds;
    Map<String, Id> originationBrokerEmailIds;
    Map<String, Id> originationASEmailIds;
    Map<String, Id> destinationBrokerEmailIds;
    Map<String, Id> destinationASEmailIds;
    
   /* List<Set<String>> agentEmailIds100Each;
    List<Set<String>> originationBrokerEmailIds100Each;
    List<Set<String>> originationASEmailIds100Each;
    List<Set<String>> destinationBrokerEmailIds100Each;
    List<Set<String>> destinationASEmailIds100Each; */
    
    Map<String, String> templateIds;
    String agentTemplateId;
    String originationBrokerTemplateId;
    String originationASTemplateId;
    String destinationBrokerTemplateId;
    String destinationASTemplateId;
    
    String orgWideAddress;
    List<Messaging.SingleEmailMessage> finalMails;
    Contact c;
    
    private void setDetails(){
        agentEmailIds = new Map<String, Id>();
        originationOfficeIds = new Set<String>();
        destinationOfficeIds = new Set<String>();
        
        originationBrokerEmailIds = new Map<String, Id>();
        originationASEmailIds = new Map<String, Id>();
        destinationBrokerEmailIds = new Map<String, Id>();
        destinationASEmailIds = new Map<String, Id>();
        
       /* agentEmailIds100Each = new List<Set<String>>();
        originationBrokerEmailIds100Each = new List<Set<String>>();
        originationASEmailIds100Each = new List<Set<String>>();
        destinationBrokerEmailIds100Each = new List<Set<String>>();
        destinationASEmailIds100Each = new List<Set<String>>(); */
        
        templateIds = new Map<String, String>();
        List<String> templateNames = new List<String>{
            'LT_AgentNewRequestEmail',
                'LT_AgentReminderEmail',
                'LT_AgentExpiryEmail',
                'LT_OriginationBrokerAuthorizedSignerNewRequestEmail',
                'LT_OriginationBrokerAuthorizedSignerReminderEmail',
                'LT_OriginationBrokerAuthorizedExpiryEmail',
                'LT_AgentOriginationApprovedEmail',
                'LT_AgentOriginationRejectedEmail',
                'LT_AgentDestinationApprovedEmail',
                'LT_AgentDestinationRejectedEmail',
                'LT_OriginationBrokerAuthorizedSignerDestinationApprovedEmail',
                'LT_OriginationBrokerAuthorizedSignerDestinationRejectedEmail',
                'LT_DestinationBrokerAuthorizedExpiryEmail',
                'LT_DestinationBrokerAuthorizedNewRequestEmail',
                'LT_DestinationBrokerAuthorizedReminderEmail',
                'LT_DestinationBrokerAuthorizedSignerDestinationApprovedEmail'
                };
                    
        for(EmailTemplate et : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :templateNames])
            templateIds.put(et.DeveloperName, et.Id);

        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];    
        orgWideAddress = orgWideAddresses[0].Id;
        
        finalMails = new List<Messaging.SingleEmailMessage>();
        
        c = [SELECT Id,Name,FirstName FROM Contact LIMIT 1];
        
    }
    
    public void sendSubmissionEmails(){
        
        setDetails();
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, OriginationDecision__c, DestinationDecision__c, 
                           Requested_By__r.Private_Email__c, ExpirationDate__c, StatusCode__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c 
                    FROM   Listing_Transfer_Request__c 
                    WHERE  IsActive__c = true 
                    AND    StatusCode__c = 'Pending'
                    AND    CreatedDate = YESTERDAY
                    //AND    Requested_By__r.Name = '4554475'
                    ];
        
        if(requests.size() > 0){
            for(Listing_Transfer_Request__c request : requests) {
                if(request.Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c)
                    agentEmailIds.put(request.Requested_By__r.Private_Email__c, request.Requested_By__c);
               /* if(agentEmailIds.size() == 100){
                    agentEmailIds100Each.add(agentEmailIds); 
                    agentEmailIds = new Set<String>();   
                }*/
                
               /* if(request.DestinationDecision__c == null)                
                    destinationOfficeIds.add(request.DestinationOfficeCode__c); */
                    
                if(request.OriginationDecision__c == null) 
                    originationOfficeIds.add(request.OriginationOfficeCode__c);            
            }
            
            findBrokernASEmailIds();
            /*if(agentEmailIds.size() > 0){
                agentEmailIds100Each.add(agentEmailIds.keySet()); 
                agentEmailIds = new Map<String, Id>();   
            }*/
            
            findTemplateIds('sendSubmissionEmails');
            
            setEmailMessages(requests[0].Id, agentTemplateId, agentEmailIds);
            setEmailMessages(requests[0].Id, originationBrokerTemplateId, originationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, originationASTemplateId, originationASEmailIds);
           /*setEmailMessages(requests[0].Id, destinationBrokerTemplateId, destinationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, destinationASTemplateId, destinationASEmailIds); */
                system.debug(finalMails);
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails);
        }
    }
    
    
    public void sendSubmissionEmailsforDestinationofc(){
        
        setDetails();
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, OriginationDecisionOn__c, OriginationDecision__c, DestinationDecision__c, 
                           Requested_By__r.Private_Email__c, ExpirationDate__c, StatusCode__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c 
                    FROM   Listing_Transfer_Request__c 
                    WHERE  IsActive__c = true 
                    AND    StatusCode__c = 'Pending'
                    AND    OriginationDecision__c = 'Approved'
                    AND    OriginationDecisionOn__c = YESTERDAY
                   ];
        
        if(requests.size() > 0){
            for(Listing_Transfer_Request__c request : requests) {
             
             if(request.DestinationDecision__c == null)                
                    destinationOfficeIds.add(request.DestinationOfficeCode__c);
                   
            }
            
            findBrokernASEmailIds();
        
            findTemplateIds('sendSubmissionEmailsforDestinationofc');
            
            setEmailMessages(requests[0].Id, destinationBrokerTemplateId, destinationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, destinationASTemplateId, destinationASEmailIds);
            
            system.debug(finalMails);
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails);
            
        }
    }    
      
    public void sendReminderEmails() {
        setDetails();
        date RemindDate = date.today().addDays(3);
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, OriginationDecision__c, DestinationDecision__c,  
                           Requested_By__r.Private_Email__c, ExpirationDate__c, StatusCode__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c
                    FROM   Listing_Transfer_Request__c                               
                    WHERE  ExpirationDate__c =: RemindDate
                    AND    IsActive__c = true 
                    AND    StatusCode__c = 'Pending'
                    //AND    Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c = true
                    ];                             
        
        if(requests.size() > 0){
            for(Listing_Transfer_Request__c request : requests) {
                if(request.Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c)
                    agentEmailIds.put(request.Requested_By__r.Private_Email__c, request.Requested_By__c);
               /* if(agentEmailIds.size() == 100){
                    agentEmailIds100Each.add(agentEmailIds); 
                    agentEmailIds = new Set<String>();   
                } */               
                
                if(request.DestinationDecision__c == null)                
                    destinationOfficeIds.add(request.DestinationOfficeCode__c);
                    
                if(request.OriginationDecision__c == null) 
                    originationOfficeIds.add(request.OriginationOfficeCode__c);            
            }
            
          /*  if(agentEmailIds.size() > 0){
                agentEmailIds100Each.add(agentEmailIds.keySet()); 
                agentEmailIds = new Map<String, Id>();   
            } */
            
            findBrokernASEmailIds(); 
            findTemplateIds('sendReminderEmails');
            
            setEmailMessages(requests[0].Id, agentTemplateId, agentEmailIds);
            setEmailMessages(requests[0].Id, originationBrokerTemplateId, originationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, originationASTemplateId, originationASEmailIds);
            setEmailMessages(requests[0].Id, destinationBrokerTemplateId, destinationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, destinationASTemplateId, destinationASEmailIds);
            
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails); 
        }
    }
  
    public void sendApprovedEmails() {
        setDetails();
        
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, 
                           Requested_By__r.Private_Email__c, ExpirationDate__c, StatusCode__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c 
                    FROM   Listing_Transfer_Request__c                               
                   WHERE  (DestinationDecisionOn__c = YESTERDAY OR OriginationDecisionOn__c = YESTERDAY)  
                    AND    OriginationDecision__c = 'Approved'
                    AND    DestinationDecision__c = 'Approved'
                    AND    IsActive__c = true 
                    AND    StatusCode__c = 'Approved'
                    //AND    Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c = true
                   ];
                   
        if(requests.size() > 0){
            findDetails(requests); 
            findBrokernASEmailIds(); 
            findTemplateIds('sendApprovedEmails');
            
            setEmailMessages(requests[0].Id, agentTemplateId, agentEmailIds);
            setEmailMessages(requests[0].Id, destinationBrokerTemplateId, destinationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, destinationASTemplateId, destinationASEmailIds);
            setEmailMessages(requests[0].Id, originationBrokerTemplateId, originationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, originationASTemplateId, originationASEmailIds); 
            
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails);
        }
    }
    
    public void sendRejectedEmails() {
        setDetails();
        
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, 
                           Requested_By__r.Private_Email__c , ExpirationDate__c, StatusCode__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c
                    FROM   Listing_Transfer_Request__c                               
                   WHERE  (DestinationDecisionOn__c = YESTERDAY OR OriginationDecisionOn__c = YESTERDAY) 
                    AND    (OriginationDecision__c = 'Rejected' OR DestinationDecision__c = 'Rejected')
                    AND    IsActive__c = true 
                    AND    StatusCode__c = 'Rejected'
                    //AND    Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c = true
                   ];
        
        if(requests.size() > 0){           
            findDetails(requests); 
            findTemplateIds('sendRejectedEmails');
            setEmailMessages(requests[0].Id, agentTemplateId, agentEmailIds);
            
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails);
        }
    }
    
    public void sendExpiredEmails() {
        setDetails();
        
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        requests = [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c, ExpirationDate__c, StatusCode__c, 
                    IsActive__c, Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c FROM   Listing_Transfer_Request__c                               
                    WHERE  ExpirationDate__c = YESTERDAY
                    AND    IsActive__c = true 
                    AND    StatusCode__c = 'Pending'
                    //AND    Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c = true             
                   ];
        
        if(requests.size() > 0){
            List<Listing_Transfer_Request__c> expiredRequests = new List<Listing_Transfer_Request__c>();
            for(Listing_Transfer_Request__c request : requests){
               if(request.ExpirationDate__c == System.today().addDays(-1) && request.StatusCode__c == 'Pending' && request.IsActive__c == true) {
                   request.StatusCode__c = 'Expired';
                   expiredRequests.add(request);
                }
            }
            
            if(!expiredRequests.isEmpty())
                update expiredRequests;  
                      
            findDetails(requests); 
            findBrokernASEmailIds(); 
            findTemplateIds('sendExpiredEmails');
            
            setEmailMessages(requests[0].Id, agentTemplateId, agentEmailIds);
            setEmailMessages(requests[0].Id, destinationBrokerTemplateId, destinationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, destinationASTemplateId, destinationASEmailIds);
            setEmailMessages(requests[0].Id, originationBrokerTemplateId, originationBrokerEmailIds); 
            setEmailMessages(requests[0].Id, originationASTemplateId, originationASEmailIds);
            
            if(finalMails.size() > 0)
                Messaging.sendEmail(finalMails);        
        } 
    }
    
    private void findDetails(List<Listing_Transfer_Request__c> requests){
       
        for(Listing_Transfer_Request__c request : requests){
            if(request.Requested_By__r.contact__r.BRIGHT_email_preferences_Listings__c)
                agentEmailIds.put(request.Requested_By__r.Private_Email__c, request.Requested_By__c);
           /* if(agentEmailIds.size() == 100){
                agentEmailIds100Each.add(agentEmailIds); 
                agentEmailIds = new Set<String>();   
            } */
            originationOfficeIds.add(request.OriginationOfficeCode__c);
            destinationOfficeIds.add(request.DestinationOfficeCode__c);              
        }
        
       /* if(agentEmailIds.size() > 0)
            agentEmailIds100Each.add(agentEmailIds.keySet()); */
        
    }
    
    private void findBrokernASEmailIds(){
        for(Relationship__c relationship : [SELECT Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c, 
                                            Subscription__r.contact__r.BRIGHT_email_preferences_Listings__c FROM  Relationship__c
                                            WHERE  Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                            AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                            AND    Status__c = 'Active' 
                                            AND    (Broker_Office__c IN :originationOfficeIds OR Broker_Office__c IN :destinationOfficeIds)
                                            AND    Subscription__r.Status__c = 'Active'
                                           ]){
           if(relationship.Relationship_Type__c == 'Broker Of Record' && originationOfficeIds.contains(relationship.Broker_Office__c)
              && relationship.Subscription__r.contact__r.BRIGHT_email_preferences_Listings__c){ 
               originationBrokerEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__c);
              /* if(originationBrokerEmailIds.size() == 100){
                    originationBrokerEmailIds100Each.add(originationBrokerEmailIds); 
                    originationBrokerEmailIds = new Set<String>();   
               } */
           }     
           else if(relationship.Relationship_Type__c == 'Authorized Signer' && originationOfficeIds.contains(relationship.Broker_Office__c)
                  && relationship.Subscription__r.contact__r.BRIGHT_email_preferences_Listings__c){
               originationASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__c);
              /* if(originationASEmailIds.size() == 100){
                    originationASEmailIds100Each.add(originationASEmailIds); 
                    originationASEmailIds = new Set<String>();   
               } */
           }    
           
           if(relationship.Relationship_Type__c == 'Broker Of Record' && destinationOfficeIds.contains(relationship.Broker_Office__c)
             && relationship.Subscription__r.contact__r.BRIGHT_email_preferences_Listings__c){ 
               destinationBrokerEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__c);
              /* if(destinationBrokerEmailIds.size() == 100){
                    destinationBrokerEmailIds100Each.add(destinationBrokerEmailIds); 
                    destinationBrokerEmailIds = new Set<String>();   
               } */     
           }
           else if(relationship.Relationship_Type__c == 'Authorized Signer' && destinationOfficeIds.contains(relationship.Broker_Office__c)
                  && relationship.Subscription__r.contact__r.BRIGHT_email_preferences_Listings__c && relationship.Subscription__r.Private_Email__c != Null){
               destinationASEmailIds.put(relationship.Subscription__r.Private_Email__c, relationship.Subscription__c);
              /* if(destinationASEmailIds.size() == 100){
                    destinationASEmailIds100Each.add(destinationASEmailIds); 
                    destinationASEmailIds = new Set<String>();   
               } */
           } 
       }
       
      /* if(originationBrokerEmailIds.size() > 0)
            originationBrokerEmailIds100Each.add(originationBrokerEmailIds); 
            
       if(originationASEmailIds.size() > 0)
            originationASEmailIds100Each.add(originationASEmailIds); 
            
       if(destinationBrokerEmailIds.size() > 0)
            destinationBrokerEmailIds100Each.add(destinationBrokerEmailIds); 
            
       if(destinationASEmailIds.size() > 0)
            destinationASEmailIds100Each.add(destinationASEmailIds);       */             
        
    }
    
    private void findTemplateIds(String type){
        if(type == 'sendSubmissionEmails') {
            agentTemplateId= templateIds.get('LT_AgentNewRequestEmail');
            originationBrokerTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerNewRequestEmail');
            originationASTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerNewRequestEmail');
            //destinationBrokerTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedNewRequestEmail');
            //destinationASTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedNewRequestEmail');
        }
        else if(type == 'sendReminderEmails') {
            agentTemplateId = templateIds.get('LT_AgentReminderEmail');
            destinationBrokerTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedReminderEmail');
            destinationASTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedReminderEmail');
            originationBrokerTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerReminderEmail');
            originationASTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerReminderEmail');
        }
        else if(type == 'sendApprovedEmails') {
            agentTemplateId = templateIds.get('LT_AgentOriginationApprovedEmail');
            originationBrokerTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerDestinationApprovedEmail');
            originationASTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedSignerDestinationApprovedEmail');
            destinationBrokerTemplateId= templateIds.get('LT_DestinationBrokerAuthorizedSignerDestinationApprovedEmail');
            destinationASTemplateId= templateIds.get('LT_DestinationBrokerAuthorizedSignerDestinationApprovedEmail');
        }        
        else if(type == 'sendSubmissionEmailsforDestinationofc'){
             destinationBrokerTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedNewRequestEmail');
             destinationASTemplateId = templateIds.get('LT_DestinationBrokerAuthorizedNewRequestEmail');
        }       
        else if(type == 'sendRejectedEmails') {
            agentTemplateId = templateIds.get('LT_AgentDestinationRejectedEmail');
        }
        else if(type == 'sendExpiredEmails') {
            agentTemplateId = templateIds.get('LT_AgentExpiryEmail');
            originationBrokerTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedExpiryEmail');
            originationASTemplateId = templateIds.get('LT_OriginationBrokerAuthorizedExpiryEmail');
            destinationBrokerTemplateId= templateIds.get('LT_DestinationBrokerAuthorizedExpiryEmail');
            destinationASTemplateId= templateIds.get('LT_DestinationBrokerAuthorizedExpiryEmail');
        }   
    }
    
    private void setEmailMessages(String requestId, String templateId, Map<String, Id> allAddresses){
        system.debug('---allAddresses' +allAddresses);
        if(String.isNotBlank(templateId) && allAddresses.size() > 0){            
            for(String addresses : alladdresses.keySet()){
                List<String> toAddresses = new List<String>{addresses};
                if(toAddresses.size() > 0){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId); 
                    mail.setWhatId(allAddresses.get(addresses));
                    mail.setToAddresses(toAddresses);
                    mail.setBccAddresses(new List<String>{Label.Email_to_Salesforce_Id});
                    mail.setTargetObjectId(c.Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(orgWideAddress);
                    finalMails.add(mail); 
                    system.debug('---finalMails---' + finalMails);
                } 
            }
        }   
    }
}