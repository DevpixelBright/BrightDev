public Class LT_UpdateListingMDS {

    @Future(callout=true)   
    public Static void reassignListings(List<String> requestIds) {
        List<Listing_Transfer_Request__c> updatedRequests = new List<Listing_Transfer_Request__c>();
        for(Listing_Transfer_Request__c request : [SELECT Id, Name, ListingKey__c,
                                                          Requested_By__c, Requested_By__r.Bright_Agent_Key__c,
                                                          DestinationOfficeCode__c, DestinationOfficeCode__r.Bright_Office_Key__c, 
                                                          OriginationOfficeCode__c, OriginationOfficeCode__r.Bright_Office_Key__c, 
                                                          Reassigned_To__c, Reassigned_To__r.Bright_Agent_Key__c,
                                                          LUSStatus__c, LUSStatusMessage__c 
                                                   FROM   Listing_Transfer_Request__c
                                                   WHERE  Id IN :requestIds
                                                  ]){        
        
            String listingKey = request.ListingKey__c;
            String listingAgentKey = request.Requested_By__r.Bright_Agent_Key__c;
            String reassignedAgentKey = request.Reassigned_To__r.Bright_Agent_Key__c;
            String destinationOfficeKey = request.DestinationOfficeCode__r.Bright_Office_Key__c;
            String originationOfficeKey = request.OriginationOfficeCode__r.Bright_Office_Key__c;        
            
            LT_ListingUpdateService.ListingUpdateResponse lusResponse = new LT_ListingUpdateService.ListingUpdateResponse();              
            lusResponse = LT_ListingUpdateService.reassignAgent(listingKey, Long.valueOf(reassignedAgentKey), Long.valueOf(originationOfficeKey), Long.valueOf(listingAgentKey));      
            
            request.LUSStatus__c = lusResponse.Status;
            request.LUSStatusMessage__c = lusResponse.StatusMessage;
            updatedRequests.add(request);
        }
        
        if(updatedRequests.size() > 0) 
            update updatedRequests;   
    }
    
    @Future(callout=true)   
    public Static void approveListings(List<String> requestIds) {
        List<Listing_Transfer_Request__c> updatedRequests = new List<Listing_Transfer_Request__c>();
        for(Listing_Transfer_Request__c request : [SELECT Id, Name, ListingKey__c,
                                                          Requested_By__c, Requested_By__r.Bright_Agent_Key__c,
                                                          DestinationOfficeCode__c, DestinationOfficeCode__r.Bright_Office_Key__c,                                                          
                                                          LUSStatus__c, LUSStatusMessage__c 
                                                   FROM   Listing_Transfer_Request__c
                                                   WHERE  Id IN :requestIds
                                                  ]){        
        
            String listingKey = request.ListingKey__c;
            String listingAgentKey = request.Requested_By__r.Bright_Agent_Key__c;
            String destinationOfficeKey = request.DestinationOfficeCode__r.Bright_Office_Key__c;
            
            LT_ListingUpdateService.ListingUpdateResponse lusResponse = new LT_ListingUpdateService.ListingUpdateResponse();              
            lusResponse =  LT_ListingUpdateService.transferListing(listingKey, Long.valueOf(listingAgentKey), Long.valueOf(destinationOfficeKey));      
            
            request.LUSStatus__c = lusResponse.Status;
            request.LUSStatusMessage__c = lusResponse.StatusMessage;
            updatedRequests.add(request);
        }
        
        if(updatedRequests.size() > 0) 
            update updatedRequests;   
    }
    
    @Future(callout=true)   
    public Static void rejectListings(List<String> requestIds) {
        List<Listing_Transfer_Request__c> updatedRequests = new List<Listing_Transfer_Request__c>();
        for(Listing_Transfer_Request__c request : [SELECT Id, Name, ListingKey__c,
                                                          Requested_By__c, Requested_By__r.Bright_Agent_Key__c,
                                                          LUSStatus__c, LUSStatusMessage__c 
                                                   FROM   Listing_Transfer_Request__c
                                                   WHERE  Id IN :requestIds
                                                  ]){        
        
            String listingKey = request.ListingKey__c;
            String listingAgentKey = request.Requested_By__r.Bright_Agent_Key__c;        
            
            LT_ListingUpdateService.ListingUpdateResponse lusResponse = new LT_ListingUpdateService.ListingUpdateResponse();              
            lusResponse = LT_ListingUpdateService.withdrawListing(listingKey, Long.valueOf(listingAgentKey));      
            
            request.LUSStatus__c = lusResponse.Status;
            request.LUSStatusMessage__c = lusResponse.StatusMessage;
            updatedRequests.add(request);
        }
        
        if(updatedRequests.size() > 0) 
            update updatedRequests;   
    }

}