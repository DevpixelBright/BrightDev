public class ScheduleListingTransferReqEmailClass implements Schedulable {
    
    public void execute(SchedulableContext sc) {
       
        /* Map<Id, Map<Id, String>> subscriptionMap = new Map<Id, Map<Id, String>>();
Map<Id, String> ltreqMap = new Map<Id, String>(); */
        List<Id> subscriptionIds = new List<Id>();
        for(Listing_Transfer_Request__c req : [SELECT Requested_By__c FROM Listing_Transfer_Request__c 
                                               WHERE (CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY) AND StatusCode__c IN ('Pending', 'Approved', 'Rejected')]) {
                                                   /*      Date createdDate = req.CreatedDate.date();
                                                            Date modifiedDate = req.LastModifiedDate.date();                                      
                                                            if(req.StatusCode__c == 'Pending' && createdDate == System.today().addDays(-1))
                                                            
                                                            if(modifiedDate == System.today().addDays(-1)) {
                                                            if(req.StatusCode__c == 'Approved')
                                                            approvedRequest.add(req.Name); 
                                                            if(req.StatusCode__c == 'Rejected')
                                                            rejectedRequest.add(req.Name); 
                                                            }
                                                            ltreqMap.put(req.Id, req.StatusCode__c);                                       
                                                            subscriptionMap.put(req.Requested_By__c, ltreqMap); */
                                                   subscriptionIds.add(req.Requested_By__c);                                       
                                               }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Subscriptions__c sub : [SELECT Id, Private_Email__c, (SELECT Id, StatusCode__c FROM Listing_Transfer_Requests__r 
                                                                  WHERE (CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY) AND StatusCode__c IN ('Pending', 'Approved', 'Rejected')) FROM 
                                    Subscriptions__c WHERE Id IN :subscriptionIds AND Status__c = 'Active']) {
                                         List<String> pending_subscriptionemails = new List<String>();
                                         List<String> approved_subscriptionemails = new List<String>();
                                         List<String> rejection_subscriptionemails = new List<String>();
                                         List<String> pendingRequest = new List<String>();
                                         List<String> approvedRequest = new List<String>();
                                         List<String> rejectedRequest = new List<String>();
                                        Messaging.SingleEmailMessage msgpending = new Messaging.SingleEmailMessage();
                                        Messaging.SingleEmailMessage msgapproved = new Messaging.SingleEmailMessage();
                                        Messaging.SingleEmailMessage msgrejected = new Messaging.SingleEmailMessage();
                                        msgpending.setSubject('Listing transfer Request Pending Email');
                                        msgapproved.setSubject('Listing transfer Request Approved Email');
                                        msgrejected.setSubject('Listing transfer Request Rejected Email');
                                        for(Listing_Transfer_Request__c ltr : sub.Listing_Transfer_Requests__r) { 
                                            Date createdDate = ltr.CreatedDate.date();
                                            Date modifiedDate = ltr.LastModifiedDate.date(); 
                                            if(ltr.StatusCode__c == 'Pending' && createdDate == System.today().addDays(-1)) {
                                                pendingRequest.add(ltr.Name);
                                                pending_subscriptionemails.add(sub.Private_Email__c);
                                                msgpending.setToAddresses(pending_subscriptionemails);
                                                msgpending.setPlainTextBody('The Listing Transfer Request are '+ String.join(pendingRequest, ','));
                                            }
                                            if(modifiedDate == System.today().addDays(-1)) {
                                                if(ltr.StatusCode__c == 'Approved') {
                                                    approvedRequest.add(ltr.Name); 
                                                    approved_subscriptionemails.add(sub.Private_Email__c);
                                                    msgapproved.setToAddresses(approved_subscriptionemails);
                                                    msgapproved.setPlainTextBody('The Listing Transfer Request are '+ String.join(approvedRequest, ','));
                                                } 
                                                if(ltr.StatusCode__c == 'Rejected') {
                                                    rejectedRequest.add(ltr.Name);
                                                    rejection_subscriptionemails.add(sub.Private_Email__c);
                                                    msgrejected.setToAddresses(rejection_subscriptionemails);
                                                    msgrejected.setPlainTextBody('The Listing Transfer Request are '+ String.join(rejectedRequest, ','));
                                                }                           
                                            }
                                        }
                                        emails.add(msgpending);
                                        emails.add(msgapproved);
                                        emails.add(msgrejected);
               }  
         Messaging.sendEmail(emails);
    }
}