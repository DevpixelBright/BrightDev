public class LT_ValidateListingRequests{
    
    public Static void validateOffices(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> accountIds = new Set<Id>();
        for(Id accountId : newMap.keyset()) {
            if (oldMap.get(accountId).Status__c == 'Active' && newMap.get(accountId).Status__c == 'Inactive'){
                accountIds.add(newMap.get(accountId).Id);
            }
        }
        
        List<Listing_Transfer_Request__c> invalidRequests = new List<Listing_Transfer_Request__c>() ; 
        
        for(Listing_Transfer_Request__c request : [SELECT Id, IsActive__c, StatusCode__c, DestinationOfficeCode__c,
                                                          CanceledReason__c, CanceledOn__c, OriginationOfficeCode__c                                                                       
                                                   FROM   Listing_Transfer_Request__c 
                                                   WHERE  (OriginationOfficeCode__c IN : accountIds OR DestinationOfficeCode__c IN : accountIds)
                                                   AND    StatusCode__c = 'Pending'
                                                  ]){
                                                      
            if(accountIds.contains(request.DestinationOfficeCode__c)){         
                if(oldMap.get(request.DestinationOfficeCode__c).Status__c == 'Active' && newMap.get(request.DestinationOfficeCode__c).Status__c == 'Inactive'){ 
                    request.isActive__c = false;
                    request.StatusCode__c = 'Canceled';
                    request.CanceledReason__c = 'Destination Office ' + oldMap.get(request.DestinationOfficeCode__c).Name + ' is inactivated.';
                    request.CanceledOn__c = system.today();
                    invalidRequests.add(request);
                }
            }
            if(accountIds.contains(request.OriginationOfficeCode__c)){           
                if(oldMap.get(request.OriginationOfficeCode__c).Status__c == 'Active' && newMap.get(request.OriginationOfficeCode__c).Status__c == 'Inactive') {
                    request.isActive__c = false;
                    request.StatusCode__c = 'Canceled';
                    request.CanceledReason__c =  'Originating Office ' + oldMap.get(request.OriginationOfficeCode__c).Name + ' is inactivated.';
                    request.CanceledOn__c = system.today();
                    invalidRequests.add(request);
                } 
            }
        }
        
        if(invalidRequests.size() > 0)
            update invalidRequests;

    }    
    
    public Static void validateSubscriptions(Map<Id, Subscriptions__c> oldMap, Map<Id, Subscriptions__c> newMap){
                     
        List<Id> subscriptionIds = new List<Id>();
        for(Id subscriptionId : newMap.keyset()) {
            if ((oldMap.get(subscriptionId).Status__c != newMap.get(subscriptionId).Status__c) || (oldMap.get(subscriptionId).Related_Location_Broker_Office__c != newMap.get(subscriptionId).Related_Location_Broker_Office__c)){
                subscriptionIds.add(newMap.get(subscriptionId).Id);
            }
        } 
        
        List<Listing_Transfer_Request__c> invalidRequests = new List<Listing_Transfer_Request__c>() ; 
        
        for(Listing_Transfer_Request__c request : [SELECT Id, IsActive__c, StatusCode__c, Requested_By__c,
                                                          CanceledReason__c, CanceledOn__c                                                                       
                                                   FROM   Listing_Transfer_Request__c 
                                                   WHERE  Requested_By__c IN :subscriptionIds
                                                   AND    StatusCode__c = 'Pending'
                                              ]){
                                                  System.debug(request.Requested_By__c + ' ****** '+ oldMap.get(request.Requested_By__c));
            if(oldMap.get(request.Requested_By__c).Status__c == 'Active' && newMap.get(request.Requested_By__c).Status__c == 'Inactive'){ 
                request.isActive__c = false;
                request.StatusCode__c = 'Canceled';
                request.CanceledReason__c = 'Subscription is inactivated.';
                request.CanceledOn__c = system.today();
                invalidRequests.add(request);
            }
            else if(oldMap.get(request.Requested_By__c).Related_Location_Broker_Office__c != newMap.get(request.Requested_By__c).Related_Location_Broker_Office__c) {
                request.isActive__c = false;
                request.StatusCode__c = 'Canceled';
                request.CanceledReason__c = 'Subscription\'s Office changed from ' + oldMap.get(request.Requested_By__c).Related_Broker_Code__c + ' to ' + newMap.get(request.Requested_By__c).Related_Broker_Code__c ;
                request.CanceledOn__c = system.today();
                invalidRequests.add(request);
            } 
        }
        
        if(invalidRequests.size() > 0)
            update invalidRequests;
                                 
    }       
}