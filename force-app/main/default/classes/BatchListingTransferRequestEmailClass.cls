public class BatchListingTransferRequestEmailClass implements Database.Batchable<Sobject> {
    Map<Id, List<Listing_Transfer_Request__c>> destinationSubListingTransferReqMap;
    Map<Id, List<Listing_Transfer_Request__c>> originationSubListingTransferReqMap;
    Map<Id, List<String>> brokerofrecordEmails;
    Map<Id, List<String>> authorizedsignerEmails;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator([SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c From Listing_Transfer_Request__c 
                                        WHERE LastModifiedDate = YESTERDAY AND IsActive__c = true]);
    }
    public void execute(Database.BatchableContext bc, List<Sobject> ltrequests) {
        List<Id> destinationofficeIdsList = new List<Id>();
        List<Id> originationofficeIdsList = new List<Id>();
        
        for(Listing_Transfer_Request__c ltr : (List<Listing_Transfer_Request__c>)ltrequests) {
             destinationofficeIdsList.add(ltr.DestinationOfficeCode__c);
             originationofficeIdsList.add(ltr.OriginationOfficeCode__c);	
        }
        destinationSubRelatedListingTransferReq(destinationofficeIdsList);
        originationSubscriptionEmails(originationofficeIdsList);
    }
    public void finish(Database.BatchableContext bc) {}
    
    private void destinationSubRelatedListingTransferReq(List<Id> destinationofficeIds) {
        destinationSubListingTransferReqMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        for(Account acc : [SELECT Id, (SELECT Id, Requested_By__c, DestinationDecision__c, StatusCode__c FROM Listing_Transfer_Requests__r 
                                              WHERE LastModifiedDate = YESTERDAY AND IsActive__c = true) FROM Account WHERE Id IN :destinationofficeIds]) {
            destinationSubListingTransferReqMap.put(acc.Id, acc.Listing_Transfer_Requests__r);
        }
        destinationSubscriptionEmails(destinationofficeIds, destinationSubListingTransferReqMap);
    }
    private void destinationSubscriptionEmails(List<Id> destinationofficeIds, Map<Id, List<Listing_Transfer_Request__c>> destinationSubListingTransferReqMap) {       
       brokerofrecordEmails = new Map<Id, List<String>>();
       authorizedsignerEmails = new Map<Id, List<String>>();
       for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   AND  ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   AND  Status__c = 'Active' AND Broker_Office__c IN :destinationofficeIds]) {
                                       if(rel.Relationship_Type__c == 'Broker Of Record') {
                                           brokerofrecordEmails.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                       }
                                       if(rel.Relationship_Type__c == 'Authorized Signer') {
                                        	authorizedsignerEmails.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                       }
                                   }
        collectSingleEmailMessages(brokerofrecordEmails, authorizedsignerEmails, destinationSubListingTransferReqMap);
    }
    private void collectSingleEmailMessages(Map<Id, List<String>> brokerofrecordEmails, Map<Id, List<String>> authorizedsignerEmails, 
                                            Map<Id, List<Listing_Transfer_Request__c>> destinationSubListingTransferReqMap) {
                           		Messaging.SingleEmailMessage msgbrokerpending = new Messaging.SingleEmailMessage();
              					Messaging.SingleEmailMessage msgbrokerapproved = new Messaging.SingleEmailMessage();
              					Messaging.SingleEmailMessage msgbrokerrejected = new Messaging.SingleEmailMessage();
                                Messaging.SingleEmailMessage msgauthorisedpending = new Messaging.SingleEmailMessage();
              					Messaging.SingleEmailMessage msgauthorisedapproved = new Messaging.SingleEmailMessage();
              					Messaging.SingleEmailMessage msgauthorisedrejected = new Messaging.SingleEmailMessage();
                                            }
    
    private void originationSubscriptionEmails(List<Id> originationofficeIds) {
          
    }
}