public class CureCaseContact {
    
    public static void linkCureContactwithCase(list<case> newCases){
        try{
            system.debug('--newCases--->'+newCases);
            if(newCases != null && !newCases.isEmpty()){
                List<String> incomingEmailIds = new List<String>();
                
                
                Map<String, String> incomingEmailIdContactId = new Map<String, String>();
                map<String, CureTechnicalSupportEmails__c> mapTechEmails = CureTechnicalSupportEmails__c.getAll();

                
                for(case c : newCases){
                    if(c.Origin == 'CURE Community' && c.SuppliedEmail != null)
                        incomingEmailIds.add(c.SuppliedEmail);
                }
                system.debug('---incomingEmailIds-->'+incomingEmailIds);
                
                if(incomingEmailIds.size() > 0){
                    for(User u : [SELECT Id, Name, Email, Profile.Name, ContactId, Contact.Email 
                                  FROM   User 
                                  Where  Email IN :incomingEmailIds
                                  And    Profile.Name = 'CURE Customer']){    // Where ContactId in (SELECT Id FROM Contact WHERE Email in: incomingEmailIds And Email != null) 
                                      
                      incomingEmailIdContactId.put(u.Email, u.ContactId);    // u.Contact.Email
                    }
                    
                    system.debug('---incomingEmailIdContactId-->' + incomingEmailIdContactId);                    
                    
                    for(case c : newCases){
                        if(!incomingEmailIdContactId.isEmpty() && incomingEmailIdContactId.containsKey(c.SuppliedEmail) ){
                            c.ContactId = incomingEmailIdContactId.get(c.SuppliedEmail);
                            system.debug('-------c.ContactId------>'+c.ContactId);
                        }
                        else if(mapTechEmails != null && mapTechEmails.size() > 0 && mapTechEmails.containsKey(c.SuppliedEmail)){
                            System.debug('---CureTechnicalSupportEmails__c has value---'+mapTechEmails.get(c.SuppliedEmail));
                        }
                        else{                           
                            c.Import_Source__c = 'CURE delete';
                        }
                        system.debug('-------case------>'+c);
                    }                    
                }
            }
            
        }catch(Exception e){
            system.debug('---exception---'+e);
        }
    }
    
    public static void handleFailureCases(List<Case> newCases){
        list<Messaging.SingleEmailMessage> failureNoticeEmails = new list<Messaging.SingleEmailMessage>();
                    list<EmailTemplate> failureEmailTemplate = [Select Id, Name, Subject, Body From EmailTemplate 
                                                        Where Name = 'Cure Unregistered User template'];
                    list<OrgWideEmailAddress> fromAddress = [Select id, displayname, Address From OrgWideEmailAddress 
                                                     Where displayname = 'Bright MLS' 
                                                     And Address like '%no-reply@brightmls.com'];
                                                     
                                                  Contact   mailContact = [SELECT Id,Name,FirstName FROM Contact LIMIT 1];
        
        
            list<String> delCaseIds = new List<String>();
            for(Case failureCase : newCases){
                if(failureCase.Import_Source__c == 'CURE delete'){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                            
                
                mail.setTemplateId(failureEmailTemplate[0].Id);                         
                mail.setWhatId(failureCase.Id);
                mail.setTargetObjectId(mailContact.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false);
                if(fromAddress != null && fromAddress.size() >0)
                    mail.setOrgWideEmailAddressId(fromAddress[0].Id);
                
                mail.setToAddresses(new List<String> {failureCase.SuppliedEmail});                                                       
                failureNoticeEmails.add(mail);
                delCaseIds.add(failureCase.Id);
               }
            }
            if(!failureNoticeEmails.isEmpty())
                Messaging.sendEmail(failureNoticeEmails);

            if(delCaseIds != null && !delCaseIds.isEmpty()){
                CurecaseFutureDelete.deleteCase(delCaseIds);
                 
                }
                
        }
    
    
    public Class CustomException extends Exception {}
}