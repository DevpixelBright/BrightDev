public class ScheduleEmailClass implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        List<Id> destinationofficeIdsList = new List<Id>();
        List<Id> sourceofficeIdsList = new List<Id>();
        for(Listing_Transfer_Request__c ltr : [SELECT Id, DestinationOfficeCode__c, OriginationOfficeCode__c From Listing_Transfer_Request__c WHERE LastModifiedDate = YESTERDAY AND IsActive__c = true]) {
            destinationofficeIdsList.add(ltr.DestinationOfficeCode__c);
            sourceofficeIdsList.add(ltr.OriginationOfficeCode__c);
        }        
        Map<Id, List<Listing_Transfer_Request__c>> destination_officeIdListingTransferRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        Map<Id, List<Listing_Transfer_Request__c>> origination_officeIdListingTransferRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        for(Account acc : [SELECT Id, (SELECT Id, Requested_By__c, DestinationDecision__c, StatusCode__c FROM Listing_Transfer_Requests__r WHERE LastModifiedDate = YESTERDAY AND IsActive__c = true) FROM Account WHERE Id IN :destinationofficeIdsList]) {
            destination_officeIdListingTransferRequestMap.put(acc.Id, acc.Listing_Transfer_Requests__r);
        }
        for(Account acc : [SELECT Id, (SELECT Id, Requested_By__c, DestinationDecision__c FROM Listing_Transfer_Requests__r WHERE LastModifiedDate = YESTERDAY AND IsActive__c = true) FROM Account WHERE Id IN :sourceofficeIdsList]) {
            origination_officeIdListingTransferRequestMap.put(acc.Id, acc.Listing_Transfer_Requests__r);
        }
        //List<Id> destination_brokerOfRecordIds = new List<Id>();
        //List<Id> destination_authorizedSignerIds = new List<Id>();
        Map<Id, List<Listing_Transfer_Request__c>> destination_brokersubscriptionListingRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        Map<Id, List<String>> destination_brokersubIdEmail = new Map<Id, List<String>>();
        Map<Id, List<Listing_Transfer_Request__c>> destination_authorisedsubscriptionListingRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        Map<Id, List<String>> destination_authorisedsubIdEmail = new Map<Id, List<String>>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c, Broker_Office__c FROM  Relationship__c
                                   WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   AND     Status__c = 'Active' AND Broker_Office__c IN :destinationofficeIdsList]) {
                                       if(destination_officeIdListingTransferRequestMap.containskey(rel.Broker_Office__c)) {
                                           if(rel.Relationship_Type__c == 'Broker Of Record')  {
                                               destination_brokersubscriptionListingRequestMap.put(rel.Subscription__c, destination_officeIdListingTransferRequestMap.get(rel.Broker_Office__c));
                                               destination_brokersubIdEmail.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                           }
                                           if(rel.Relationship_Type__c == 'Authorized Signer') {
                                               destination_authorisedsubscriptionListingRequestMap.put(rel.Subscription__c, destination_officeIdListingTransferRequestMap.get(rel.Broker_Office__c));
                                               destination_authorisedsubIdEmail.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                           }
                                       }
                                       
                                   }
        Map<Id, List<Listing_Transfer_Request__c>> origination_brokersubscriptionListingRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        Map<Id, List<String>> origination_brokersubIdEmail = new Map<Id, List<String>>();
        Map<Id, List<Listing_Transfer_Request__c>> origination_authorisedsubscriptionListingRequestMap = new Map<Id, List<Listing_Transfer_Request__c>>();
        Map<Id, List<String>> origination_authorisedsubIdEmail = new Map<Id, List<String>>();
        //List<Id> origination_brokerOfRecordIds = new List<Id>();
        //List<Id> origination_authorizedSignerIds = new List<Id>();
        for(Relationship__c rel : [SELECT  Id, Relationship_Type__c, Subscription__c, Subscription__r.Private_Email__c FROM  Relationship__c
                                   WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                                   AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                   AND     Status__c = 'Active' AND Broker_Office__c IN :sourceofficeIdsList 
                                  ]) {
                                      if(origination_officeIdListingTransferRequestMap.containskey(rel.Broker_Office__c)) {
                                          if(rel.Relationship_Type__c == 'Broker Of Record')  {
                                              origination_brokersubscriptionListingRequestMap.put(rel.Subscription__c, destination_officeIdListingTransferRequestMap.get(rel.Broker_Office__c));
                                              origination_brokersubIdEmail.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                          }
                                          if(rel.Relationship_Type__c == 'Authorized Signer') {
                                              origination_authorisedsubscriptionListingRequestMap.put(rel.Subscription__c, destination_officeIdListingTransferRequestMap.get(rel.Broker_Office__c));
                                              origination_authorisedsubIdEmail.put(rel.Subscription__c, new List<String>{rel.Subscription__r.Private_Email__c});
                                          }
                                      }
                                  }
          for(Subscriptions__c sub : [SELECT Id FROM Subscriptions__c WHERE Id IN :destination_brokersubscriptionListingRequestMap.keySet()]) {
              Messaging.SingleEmailMessage msgbrokerpending = new Messaging.SingleEmailMessage();
              Messaging.SingleEmailMessage msgbrokerapproved = new Messaging.SingleEmailMessage();
              Messaging.SingleEmailMessage msgbrokerrejected = new Messaging.SingleEmailMessage();
              msgbrokerpending.setSubject('Listing transfer Request Pending Email');
              msgbrokerapproved.setSubject('Listing transfer Request Approved Email');
              msgbrokerrejected.setSubject('Listing transfer Request Rejected Email');
              List<String> brokerpendingRequest = new List<String>();
              List<String> brokerapprovedRequest = new List<String>();
              List<String> brokerrejectedRequest = new List<String>();
              for(Listing_Transfer_Request__c ltr : destination_brokersubscriptionListingRequestMap.get(sub.Id)) {
                  if(ltr.DestinationDecision__c == null) {
                      msgbrokerpending.setToAddresses(destination_brokersubIdEmail.get(sub.Id));
                      brokerpendingRequest.add(ltr.Name);
                      msgbrokerpending.setPlainTextBody('The Listing Transfer Request are '+ String.join(brokerpendingRequest, ','));
                  }
                  //else if(ltr.DestinationDecision__c )
              }
          }                        
        
    }
}