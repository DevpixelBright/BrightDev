trigger LT_ListingRequestUpdate on Listing_Transfer_Request__c (after update, before update) {
    
    List<String> approvedRequests = new List<String>();
    List<String> rejectedRequests = new List<String>();
    List<String> reassignedRequests =  new List<String>();
    
    if(trigger.isAfter){        
        for(Listing_Transfer_Request__c request : trigger.new){
            if(trigger.oldMap.get(request.Id).StatusCode__c == 'Pending'){
                if(request.StatusCode__c == 'Rejected'){                          
                    if(request.Reassigned_To__c != null){
                        reassignedRequests.add(request.Id);
                        if(reassignedRequests.size() == 90){
                            LT_UpdateListingMDS.reassignListings(reassignedRequests);
                            reassignedRequests = new List<String>();
                        }
                    }
                    else{
                        rejectedRequests.add(request.Id);
                        if(rejectedRequests.size() == 90){
                            LT_UpdateListingMDS.rejectListings(rejectedRequests);
                            rejectedRequests = new List<String>();
                        }
                   }        
                }
                else if(request.StatusCode__c == 'Approved'){                
                    approvedRequests.add(request.Id);
                    if(approvedRequests.size() == 90){
                        LT_UpdateListingMDS.approveListings(approvedRequests);
                        approvedRequests = new List<String>();
                    }
                }    
            }
        }
    }
    else{
        for(Listing_Transfer_Request__c request : trigger.new){
            system.debug('** Before: ' + trigger.oldMap.get(request.Id).DestinationDecision__c);
            if(trigger.oldMap.get(request.Id).DestinationDecision__c == null){
                if(request.DestinationDecision__c == 'Rejected'){
                    request.StatusCode__c = 'Rejected';
                }
                else if(request.DestinationDecision__c == 'Approved' && request.OriginationDecision__c == 'Approved'){
                    request.StatusCode__c = 'Approved';
                }
            }
            
            if(trigger.oldMap.get(request.Id).OriginationDecision__c == null){
                if(request.OriginationDecision__c == 'Rejected'){
                    request.StatusCode__c = 'Rejected';
                }
                else if(request.OriginationDecision__c == 'Approved' && request.DestinationDecision__c == 'Approved'){
                    request.StatusCode__c = 'Approved';
                }
            }
        }
    }
    
    if(reassignedRequests.size() > 0)
        LT_UpdateListingMDS.reassignListings(reassignedRequests);
        
    if(rejectedRequests.size() > 0)
        LT_UpdateListingMDS.rejectListings(rejectedRequests);
        
    if(approvedRequests.size() > 0)
        
        LT_UpdateListingMDS.approveListings(approvedRequests);
   
}