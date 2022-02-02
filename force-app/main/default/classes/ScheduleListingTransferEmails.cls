public class ScheduleListingTransferEmails {
    
    public void scenarioOne() {
		List<Id> destinationofficeIdsList = new List<Id>();
        List<Id> originationofficeIdsList = new List<Id>();
        List<Id> subscriptionEmails = new List<Id>();
         
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c From Listing_Transfer_Request__c 
                                               WHERE CreatedDate = YESTERDAY 
                                               AND IsActive__c = true AND StatusCode__c = 'Pending']) {
            									originationofficeIdsList.add(ltr.OriginationOfficeCode__c);
                                                subscriptionEmails.add(ltr.Requested_By__r.Private_Email__c);   
        } 
        List<String> origination_brokerEmails = new List<String>();
        List<String> origination_authorizedSignerEmails = new List<String>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   					WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   					AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   					AND  Status__c = 'Active' AND Broker_Office__c IN :originationofficeIdsList]) {
                                            if(rel.Relationship_Type__c == 'Broker Of Record') 
                                                origination_brokerEmails.add(rel.Subscription__r.Private_Email__c);      
                                             if(rel.Relationship_Type__c == 'Authorized Signer') 
                                                origination_authorizedSignerEmails.add(rel.Subscription__r.Private_Email__c); 
                                   }
        Messaging.SingleEmailMessage msgPendingoriginationBroker = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAuthorised = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAgent = new Messaging.SingleEmailMessage();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LT_Agent_New_Request_Email'];
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];       
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<Listing_Transfer_Request__c> reqs = [SELECT Id FROM Listing_Transfer_Request__c LIMIT 1];
        
        msgPendingoriginationBroker.setTemplateId(template.Id);
        msgPendingoriginationBroker.setwhatId(reqs[0].Id);
        msgPendingoriginationBroker.setTargetObjectId(con[0].Id);
        msgPendingoriginationBroker.setToAddresses(origination_brokerEmails);
        msgPendingoriginationBroker.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationBroker.setSaveAsActivity(false);
        msgPendingoriginationBroker.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAuthorised.setTemplateId(template.Id);
        msgPendingoriginationAuthorised.setwhatid(reqs[0].Id);
        msgPendingoriginationAuthorised.setTargetObjectId(con[0].Id);
        msgPendingoriginationAuthorised.setToAddresses(origination_authorizedSignerEmails);
        msgPendingoriginationAuthorised.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAuthorised.setSaveAsActivity(false);
        msgPendingoriginationAuthorised.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAgent.setTemplateId(template.Id);
        msgPendingoriginationAgent.setwhatid(reqs[0].Id);
        msgPendingoriginationAgent.setTargetObjectId(con[0].Id);
        msgPendingoriginationAgent.setToAddresses(subscriptionEmails);
        msgPendingoriginationAgent.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAgent.setSaveAsActivity(false);
        msgPendingoriginationAgent.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msgPendingoriginationBroker, msgPendingoriginationAuthorised, msgPendingoriginationAgent});
    } 
    
    public void scenarioTwo() {
        List<Id> originationofficeIdsList = new List<Id>();
        List<Id> subscriptionEmails = new List<Id>();
        
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c From Listing_Transfer_Request__c 
                                               WHERE ExpirationDate__c = LAST_N_DAYS:3 AND OriginationDecision__c != null 
                                               AND IsActive__c = true AND StatusCode__c = 'Pending']) {
            									originationofficeIdsList.add(ltr.OriginationOfficeCode__c);
                                                subscriptionEmails.add(ltr.Requested_By__r.Private_Email__c);   
        }
        List<String> origination_brokerEmails = new List<String>();
        List<String> origination_authorizedSignerEmails = new List<String>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   					WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   					AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   					AND  Status__c = 'Active' AND Broker_Office__c IN :originationofficeIdsList]) {
                                            if(rel.Relationship_Type__c == 'Broker Of Record') 
                                                origination_brokerEmails.add(rel.Subscription__r.Private_Email__c);      
                                             if(rel.Relationship_Type__c == 'Authorized Signer') 
                                                origination_authorizedSignerEmails.add(rel.Subscription__r.Private_Email__c); 
                                   }
        Messaging.SingleEmailMessage msgPendingoriginationBroker = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAuthorised = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAgent = new Messaging.SingleEmailMessage();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LT_Agent_New_Request_Email'];
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];       
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<Listing_Transfer_Request__c> reqs = [SELECT Id FROM Listing_Transfer_Request__c LIMIT 1];
        
        msgPendingoriginationBroker.setTemplateId(template.Id);
        msgPendingoriginationBroker.setwhatId(reqs[0].Id);
        msgPendingoriginationBroker.setTargetObjectId(con[0].Id);
        msgPendingoriginationBroker.setToAddresses(origination_brokerEmails);
        msgPendingoriginationBroker.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationBroker.setSaveAsActivity(false);
        msgPendingoriginationBroker.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAuthorised.setTemplateId(template.Id);
        msgPendingoriginationAuthorised.setwhatid(reqs[0].Id);
        msgPendingoriginationAuthorised.setTargetObjectId(con[0].Id);
        msgPendingoriginationAuthorised.setToAddresses(origination_authorizedSignerEmails);
        msgPendingoriginationAuthorised.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAuthorised.setSaveAsActivity(false);
        msgPendingoriginationAuthorised.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAgent.setTemplateId(template.Id);
        msgPendingoriginationAgent.setwhatid(reqs[0].Id);
        msgPendingoriginationAgent.setTargetObjectId(con[0].Id);
        msgPendingoriginationAgent.setToAddresses(subscriptionEmails);
        msgPendingoriginationAgent.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAgent.setSaveAsActivity(false);
        msgPendingoriginationAgent.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msgPendingoriginationBroker, msgPendingoriginationAuthorised, msgPendingoriginationAgent});
    }
    
    public void scenarioThree() {
        List<Id> originationofficeIdsList = new List<Id>();
        List<Id> subscriptionEmails = new List<Id>();
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c From Listing_Transfer_Request__c 
                                               WHERE ExpirationDate__c = YESTERDAY AND OriginationDecision__c != null 
                                               AND IsActive__c = true AND StatusCode__c = 'Pending']) {
            									originationofficeIdsList.add(ltr.OriginationOfficeCode__c);
                                                subscriptionEmails.add(ltr.Requested_By__r.Private_Email__c);
                                                ltr.StatusCode__c = 'Expired';
                                                requests.add(ltr);   
        }
        update requests;
        List<String> origination_brokerEmails = new List<String>();
        List<String> origination_authorizedSignerEmails = new List<String>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   					WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   					AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   					AND  Status__c = 'Active' AND Broker_Office__c IN :originationofficeIdsList]) {
                                            if(rel.Relationship_Type__c == 'Broker Of Record') 
                                                origination_brokerEmails.add(rel.Subscription__r.Private_Email__c);      
                                             if(rel.Relationship_Type__c == 'Authorized Signer') 
                                                origination_authorizedSignerEmails.add(rel.Subscription__r.Private_Email__c);                                                        
                                   }
        Messaging.SingleEmailMessage msgPendingoriginationBroker = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAuthorised = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingoriginationAgent = new Messaging.SingleEmailMessage();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LT_Agent_New_Request_Email'];
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];       
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<Listing_Transfer_Request__c> reqs = [SELECT Id FROM Listing_Transfer_Request__c LIMIT 1];
        
        msgPendingoriginationBroker.setTemplateId(template.Id);
        msgPendingoriginationBroker.setwhatId(reqs[0].Id);
        msgPendingoriginationBroker.setTargetObjectId(con[0].Id);
        msgPendingoriginationBroker.setToAddresses(origination_brokerEmails);
        msgPendingoriginationBroker.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationBroker.setSaveAsActivity(false);
        msgPendingoriginationBroker.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAuthorised.setTemplateId(template.Id);
        msgPendingoriginationAuthorised.setwhatid(reqs[0].Id);
        msgPendingoriginationAuthorised.setTargetObjectId(con[0].Id);
        msgPendingoriginationAuthorised.setToAddresses(origination_authorizedSignerEmails);
        msgPendingoriginationAuthorised.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAuthorised.setSaveAsActivity(false);
        msgPendingoriginationAuthorised.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingoriginationAgent.setTemplateId(template.Id);
        msgPendingoriginationAgent.setwhatid(reqs[0].Id);
        msgPendingoriginationAgent.setTargetObjectId(con[0].Id);
        msgPendingoriginationAgent.setToAddresses(subscriptionEmails);
        msgPendingoriginationAgent.setTreatTargetObjectAsRecipient(false);
        msgPendingoriginationAgent.setSaveAsActivity(false);
        msgPendingoriginationAgent.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msgPendingoriginationBroker, msgPendingoriginationAuthorised, msgPendingoriginationAgent});
    }
	    
    public void scenarioFour() {
        List<Id> destinationofficeIdsList = new List<Id>();
        List<Id> subscriptionEmails = new List<Id>();
        
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c From Listing_Transfer_Request__c 
                                               WHERE OriginationDecisionOn__c = YESTERDAY AND OriginationDecision__c = 'Approved' 
                                               AND IsActive__c = true AND StatusCode__c = 'Pending']) {
            									destinationofficeIdsList.add(ltr.DestinationOfficeCode__c);
                                                subscriptionEmails.add(ltr.Requested_By__r.Private_Email__c);   
        }
        List<String> destination_brokerEmails = new List<String>();
        List<String> destination_authorizedSignerEmails = new List<String>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   					WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   					AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   					AND  Status__c = 'Active' AND Broker_Office__c IN :destinationofficeIdsList]) {
                                            if(rel.Relationship_Type__c == 'Broker Of Record') 
                                                destination_brokerEmails.add(rel.Subscription__r.Private_Email__c);      
                                             if(rel.Relationship_Type__c == 'Authorized Signer') 
                                                destination_authorizedSignerEmails.add(rel.Subscription__r.Private_Email__c); 
                                   }
        
        Messaging.SingleEmailMessage msgPendingdestinationBroker = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingdestinationAuthorised = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msgPendingdestinationAgent = new Messaging.SingleEmailMessage();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LT_Agent_New_Request_Email'];
        List<OrgWideEmailAddress> orgWideAddresses = [select Id from OrgWideEmailAddress where DisplayName = 'BRIGHT MLS'];       
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<Listing_Transfer_Request__c> reqs = [SELECT Id FROM Listing_Transfer_Request__c LIMIT 1];
        
        msgPendingdestinationBroker.setTemplateId(template.Id);
        msgPendingdestinationBroker.setwhatId(reqs[0].Id);
        msgPendingdestinationBroker.setTargetObjectId(con[0].Id);
        msgPendingdestinationBroker.setToAddresses(destination_brokerEmails);
        msgPendingdestinationBroker.setTreatTargetObjectAsRecipient(false);
        msgPendingdestinationBroker.setSaveAsActivity(false);
        msgPendingdestinationBroker.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingdestinationAuthorised.setTemplateId(template.Id);
        msgPendingdestinationAuthorised.setwhatid(reqs[0].Id);
        msgPendingdestinationAuthorised.setTargetObjectId(con[0].Id);
        msgPendingdestinationAuthorised.setToAddresses(destination_authorizedSignerEmails);
        msgPendingdestinationAuthorised.setTreatTargetObjectAsRecipient(false);
        msgPendingdestinationAuthorised.setSaveAsActivity(false);
        msgPendingdestinationAuthorised.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        msgPendingdestinationAgent.setTemplateId(template.Id);
        msgPendingdestinationAgent.setwhatid(reqs[0].Id);
        msgPendingdestinationAgent.setTargetObjectId(con[0].Id);
        msgPendingdestinationAgent.setToAddresses(subscriptionEmails);
        msgPendingdestinationAgent.setTreatTargetObjectAsRecipient(false);
        msgPendingdestinationAgent.setSaveAsActivity(false);
        msgPendingdestinationAgent.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msgPendingdestinationBroker, msgPendingdestinationAuthorised, msgPendingdestinationAgent});
    }
    public void scenarioFive() {
        List<Id> subscriptionEmails = new List<Id>();
        
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c, Requested_By__r.Private_Email__c From Listing_Transfer_Request__c 
                                               WHERE OriginationDecisionOn__c = YESTERDAY AND OriginationDecision__c = 'Approved' 
                                               AND IsActive__c = true AND StatusCode__c = 'Pending']) {
            								   subscriptionEmails.add(ltr.Requested_By__r.Private_Email__c);   
        }
    }
}