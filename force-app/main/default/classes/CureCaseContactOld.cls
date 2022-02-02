public class CureCaseContactOld {
    
    public static void linkCureContactwithCase(list<case> newCases){
        try{
            system.debug('--newCases--->'+newCases);
            if(newCases != null && !newCases.isEmpty()){
                list<string> lstFromAddresses = new list<string>();
                map<string, string> mapFromAddUserId = new map<string, string>();
                
                for(case c : newCases){
                    if(c.Origin == 'CURE Community' && c.SuppliedEmail != null)
                        lstFromAddresses.add(c.SuppliedEmail);
                }
                system.debug('---lstFromAddresses-->'+lstFromAddresses);
                
                if(!lstFromAddresses.isEmpty()){
                    user objuser = new user();
                    for(user u : [Select Id, Name, Profile.Name, ContactId, Contact.Email From User 
                                  Where Email in: lstFromAddresses
                                  And Profile.Name = 'CURE Customer']){     // Where ContactId in (SELECT Id FROM Contact WHERE Email in: lstFromAddresses And Email != null) 
                                      
                        mapFromAddUserId.put(u.Email, u.ContactId);     // u.Contact.Email
                        objuser = u;
                    }
                    
                    system.debug('---mapFromAddUserId-->'+mapFromAddUserId);
                    map<string, CureTechnicalSupportEmails__c> mapTechEmails = CureTechnicalSupportEmails__c.getAll();
                    
                    //if(!mapFromAddUserId.isEmpty()){
                    
                    list<string> lstCases = new list<string>(); // cases to be deleted
                    list<Messaging.SingleEmailMessage> lstAllEmails = new list<Messaging.SingleEmailMessage>();
                    list<EmailTemplate> textTemplate = [Select Id, Name, Subject, Body From EmailTemplate 
                                                        Where Name = 'Cure Unregistered User template'];
                    list<OrgWideEmailAddress> owa = [Select id, displayname, Address From OrgWideEmailAddress 
                                                     Where displayname = 'Bright MLS' 
                                                     And Address like '%no-reply@brightmls.com'];
                    
                    for(case c : newCases){
                        if(!mapFromAddUserId.isEmpty() && mapFromAddUserId.containsKey(c.SuppliedEmail) ){
                            c.ContactId = mapFromAddUserId.get(c.SuppliedEmail);
                        }
                        else if(mapTechEmails != null && mapTechEmails.size() > 0 && mapTechEmails.containsKey(c.SuppliedEmail)){
                            System.debug('---CureTechnicalSupportEmails__c has value---'+mapTechEmails.get(c.SuppliedEmail));
                        }
                        else{
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            if(textTemplate != null && textTemplate.size() > 0){
                                system.debug('---templage--->'+textTemplate[0].Id);
                                mail.setTemplateId(textTemplate[0].Id);
                            }
                            mail.setWhatId(c.Id);
                            mail.setTargetObjectId(c.Id);
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.setSaveAsActivity(false);
                            if(owa != null && owa.size() >0)
                                mail.setOrgWideEmailAddressId(owa[0].Id);
                            
                            mail.setToAddresses(lstFromAddresses);
                            mail.setSubject(c.Subject);
                                                       
                            /*
                            if(c.description != null)
                                mail.setPlainTextBody(c.description.left(400).replace('\n', ' ').trim()+' '+textTemplate[0].body);
                            else 
                                mail.setPlainTextBody(textTemplate[0].body);
                            */
                            system.debug('---mail-->'+mail);
                            lstAllEmails.add(mail);
                            c.subject = 'delete';
                            lstCases.add(c.subject);
                            
                        }
                    }
                    
                    if(!lstAllEmails.isEmpty()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstAllEmails);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: ' + results[0].errors[0].message);
                        }
                    }
                    if(!lstCases.isEmpty()){
                        //throw new CustomException('Failed: to create case as requested from unauthorized Cure user');
                        CurecaseFutureDelete.deleteCase(lstCases);
                    }
                    // }
                }
            }
        }catch(Exception e){
            system.debug('---exception---'+e);
        }
    }
    public Class CustomException extends Exception {}
}