global class SMS_EmailNotifications implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          String emailSubject = email.subject;
         
          if(String.IsNotBlank(emailSubject)) {
            Integer startIndex = emailSubject.indexOf('ID#');
            Integer endIndex = emailSubject.length();
            
            String sSubscriptionId = emailSubject.substring(startIndex + 3, endIndex);
            system.debug('*** Subscription Id : ' + sSubscriptionId); 
            sSubscriptionId = sSubscriptionId.deleteWhitespace();
            
            List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
            subscriptions = [SELECT id,Name 
                             FROM   Subscriptions__c
                             WHERE  Name = :sSubscriptionId 
                            ];
                        
            if(subscriptions.size() == 1) {
                Task tsk =new Task();  
                tsk.Subject = email.Subject;  
                tsk.OwnerId = UserInfo.getUserId();  
                tsk.Description = email.plainTextBody;  
                tsk.WhatId = subscriptions[0].id; 
                tsk.status = 'Completed'; 
                insert tsk;
            }            
          }
          return result;
      }
  }