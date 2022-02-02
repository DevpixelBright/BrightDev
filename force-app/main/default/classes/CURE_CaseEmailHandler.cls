global class CURE_CaseEmailHandler implements Messaging.InboundEmailHandler {
      
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String fromAddress = email.fromAddress;
        
        try{        
            List<Contact> cureContacts = [SELECT Id, Name, Account.Account_Name__c, Account.Parent.Name FROM Contact WHERE Email = :fromAddress];
            
            if(cureContacts.size() == 0)
                throw new CustomException('Your email id is not registered with CURE. Sorry , the email cannot be processed. To file a ticket please email to rique@mris.net');
            
            List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                           FROM   QueueSobject 
                                           WHERE  SobjectType = 'Case' 
                                           AND    Queue.DeveloperName = 'CURE_Dispatch'
                                          ];
                                          
            List<RecordType> cureRecordType = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'CURE_Case'];
            
            if(cureContacts.size() > 0){
                Case c = new Case();
                c.ContactId = cureContacts[0].Id;
                c.CURE_Group__c = cureContacts[0].Account.Parent.Name;
                c.Subject = email.subject;
                c.Origin = 'CURE Community';
                c.Description = email.plainTextBody;
                c.OwnerId = queueIds[0].QueueId;
                c.RecordTypeId = cureRecordType[0].Id;
                insert c;
                
                List<Attachment> attachments = new List<Attachment>();
                
                if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        Attachment attachment = new Attachment();
                        attachment.ParentId = c.Id;
                        attachment.Name = email.binaryAttachments[i].filename;
                        attachment.Body = email.binaryAttachments[i].body;
                        attachments.add(attachment); 
                    }
                }
                if (email.textAttachments != null && email.textAttachments.size() > 0) {
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        Attachment attachment = new Attachment();
                        attachment.ParentId = c.Id;
                        attachment.Name = email.textAttachments[i].filename;
                        attachment.Body = Blob.valueOf(email.textAttachments[i].body);
                        attachments.add(attachment);
                    }
                }
                
                insert attachments;
                
                EmailMessage newEmail = new EmailMessage();
     
                newEmail.FromAddress = email.fromAddress;
                newEmail.FromName = email.fromName;
                newEmail.ToAddress = email.toAddresses[0];
                newEmail.Subject = email.subject;
                newEmail.TextBody = email.plainTextBody;
                newEmail.HtmlBody = email.htmlBody;
                newEmail.ParentId = c.Id; 
                newEmail.Status = '0';
                 
                insert newEmail;
                
                result.Success = true;
                
            }
        
        }
        catch(Exception e){
            result.Success = false;
            result.Message = e.getMessage();    
        }
        
        return result;
      }
      
      public Class CustomException extends Exception{}
  }