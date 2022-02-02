public class Communities_ListingTransferRequests {
    
    public Map<String,ListingTransferRequest> incomingListingTransferRequestsbySubscriptionId { get; set; }
    public Map<String,ListingTransferRequest> outgoingListingTransferRequestsbySubscriptionId { get; set; }
    public Map<String,String> officeIds { get; set; }
    public String subscriptionId { get; set; }
    public String status { get; set; }
    public String type  { get; set; }
    public List<Listing_Transfer_Request__c> displayedListingTransfers { get; set; }
    public Subscriptions__c subscription { get; set; }
    
    public String incomingListingsStr { get; Set; }
    public String outgoingListingsStr { get; Set; }
    public Boolean isBOR { get; set; }     
    public Boolean hasError { get; set; } 
    Map<String,String> asOffices = new Map<String,String>();
    public Communities_ListingTransferRequests(){
        officeIds = new Map<String,String>();
        try{
            incomingListingTransferRequestsbySubscriptionId = new Map<String, ListingTransferRequest>();
            outgoingListingTransferRequestsbySubscriptionId = new Map<String, ListingTransferRequest>();
            displayedListingTransfers = new List<Listing_Transfer_Request__c>(); 
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.IsBlank(subscriptionId )){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Subscription ID: No subscription ID found'));
            }
            subscription = new Subscriptions__c();
            subscription = [SELECT Id, Name, Service_Jurisdiction__c FROM Subscriptions__c WHERE Name = :subscriptionId];        
            
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
                             Subscription__r.Name, Subscription__r.Contact__r.Name ,Broker_Office__r.Name
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subscriptionId
                             AND     Status__c = 'Active' 
                            ];
            if(relationships.size() == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'We are sorry. You do not have authority to access this process. Please contact your Broker for assistance.'));
                hasError = true;
            }
            
            List<String> parentIds = new List<String>();
            
            isBOR = false;
            
            for(Relationship__c relationship : relationships){
                system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
                
                if(relationship.Relationship_Type__c == 'Broker Of Record'){
                    isBOR = true;
                }
                else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                }
            }
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new Map<String,String>(asOffices);
                }
            }
            else{
                List<Account> relatedAccounts = new List<Account>();
                relatedAccounts = [SELECT  Id, Name
                                   FROM   Account
                                   WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active'
                                  ];
                
                officeIds = new Map<String,String>();
                
                for(Account a : relatedAccounts)
                    officeIds.put(a.Id, a.Name);
            }
            
            for(Listing_Transfer_Request__c outgoingRequest : [SELECT Id,Name,
                                                               DestinationDecision__c,DestinationOfficeCode__c, DestinationOfficeCode__r.Name,
                                                               OriginationDecision__c, OriginationOfficeCode__c, OriginationOfficeCode__r.Name,
                                                               Requested_By__c,Requested_By__r.Contact__r.FirstName, Requested_By__r.Contact__r.LastName,
                                                               StatusCode__c, ExpirationDate__c,Listing_Agent_ID__c
                                                               FROM Listing_Transfer_Request__c 
                                                               WHERE IsActive__c = true
                                                               AND OriginationOfficeCode__c IN :officeIds.keyset() 
                                                               AND ExpirationDate__c >= today
                                                               AND Requested_By__c != NULL
                                                              ]){
                                                                  system.debug('----outrequest---'+outgoingRequest.Listing_Agent_ID__c);
                                                                  ListingTransferRequest wrap = new ListingTransferRequest();
                                                                  if(!outgoingListingTransferRequestsbySubscriptionId.containsKey(outgoingRequest.Requested_By__c) ){
                                                                      outgoingListingTransferRequestsbySubscriptionId.put(outgoingRequest.Requested_By__c, new ListingTransferRequest());
                                                                      wrap = outgoingListingTransferRequestsbySubscriptionId.get(outgoingRequest.Requested_By__c);
                                                                      //wrap.expirationDate = outgoingRequest.ExpirationDate__c;
                                                                      wrap.subscriptionId = outgoingRequest.Requested_By__c;
                                                                      wrap.firstName = outgoingRequest.Requested_By__r.Contact__r.FirstName;
                                                                      wrap.lastName = outgoingRequest.Requested_By__r.Contact__r.LastName;
                                                                      wrap.officeName = outgoingRequest.DestinationOfficeCode__r.Name;
                                                                      wrap.ListingAgentID= outgoingRequest.Listing_Agent_ID__c;
                                                                  }
                                                                  
                                                                  wrap = outgoingListingTransferRequestsbySubscriptionId.get(outgoingRequest.Requested_By__c);
                                                                  
                                                                  if(outgoingRequest.OriginationDecision__c == null && outgoingRequest.StatusCode__c == 'Pending'){
                                                                      
                                                                      if(wrap.expirationDate == null || (wrap.expirationDate != null && wrap.expirationDate > outgoingRequest.ExpirationDate__c)){
                                                                          wrap.expirationDate = outgoingRequest.ExpirationDate__c;
                                                                          Integer days = System.today().daysbetween(wrap.expirationDate);
                                                                          wrap.expirationText = String.valueOf(days) + ' Days Remaining';
                                                                      }
                                                                  }
                                                                  
                                                                  wrap.totalCount = wrap.totalCount + 1;
                                                                  if(officeIds.containskey(outgoingRequest.DestinationOfficeCode__c))
                                                                      wrap.isSameOffice = true;
                                                                  
                                                                  if(outgoingRequest.OriginationDecision__c == null && outgoingRequest.StatusCode__c == 'Pending'){                
                                                                      wrap.openCount = wrap.openCount + 1;
                                                                      wrap.openRequests.add(outgoingRequest);                                 
                                                                  }
                                                                  else{                
                                                                      wrap.closedCount = wrap.closedCount + 1;
                                                                      wrap.closedRequests.add(outgoingRequest);
                                                                  }
                                                                  
                                                                  outgoingListingTransferRequestsbySubscriptionId.put(outgoingRequest.Requested_By__c, wrap);             
                                                              }
            
            system.debug('--officeIds-->'+officeIds);
            date pendinExpiration;
            string daysRemaining;
            for(Listing_Transfer_Request__c incomingRequest : [SELECT Id,Name,
                                                               DestinationDecision__c,DestinationOfficeCode__c, DestinationOfficeCode__r.Name,
                                                               OriginationDecision__c, OriginationOfficeCode__c, OriginationOfficeCode__r.Name,
                                                               Requested_By__c,Requested_By__r.Contact__r.FirstName, Requested_By__r.Contact__r.LastName,
                                                               StatusCode__c, ExpirationDate__c,Listing_Agent_ID__c
                                                               FROM Listing_Transfer_Request__c 
                                                               WHERE IsActive__c = true
                                                               AND DestinationOfficeCode__c IN :officeIds.keyset()
                                                               AND ExpirationDate__c >= today
                                                               AND Requested_By__c != NULL
                                                              ])
            {
                system.debug('---incomerequest'+incomingRequest.Listing_Agent_ID__c);
                ListingTransferRequest wrap = new ListingTransferRequest();
                if(!incomingListingTransferRequestsbySubscriptionId.containsKey(incomingRequest.Requested_By__c) ){
                    incomingListingTransferRequestsbySubscriptionId.put(incomingRequest.Requested_By__c, new ListingTransferRequest());
                    wrap = incomingListingTransferRequestsbySubscriptionId.get(incomingRequest.Requested_By__c);
                    //wrap.expirationDate = incomingRequest.ExpirationDate__c;
                    wrap.subscriptionId = incomingRequest.Requested_By__c;
                    wrap.firstName = incomingRequest.Requested_By__r.Contact__r.FirstName;
                    wrap.lastName = incomingRequest.Requested_By__r.Contact__r.LastName;
                    wrap.officeName = incomingRequest.OriginationOfficeCode__r.Name;
                    wrap.ListingAgentID= incomingRequest.Listing_Agent_ID__c;
                }
                
                wrap = incomingListingTransferRequestsbySubscriptionId.get(incomingRequest.Requested_By__c);
                
                if(incomingRequest.DestinationDecision__c == null && incomingRequest.StatusCode__c == 'Pending'){
                    
                    if(wrap.expirationDate == null || (wrap.expirationDate != null && wrap.expirationDate > incomingRequest.ExpirationDate__c)){
                        wrap.expirationDate = incomingRequest.ExpirationDate__c;
                        Integer days = System.today().daysbetween(wrap.expirationDate);
                        wrap.expirationText = String.valueOf(days) + ' Days Remaining';
                    }
                }
                
                wrap.totalCount = wrap.totalCount + 1;
                if(officeIds.containskey(incomingRequest.OriginationOfficeCode__c))
                    wrap.isSameOffice = true;
                
                if(incomingRequest.DestinationDecision__c == null && incomingRequest.StatusCode__c == 'Pending'){
                    wrap.openCount = wrap.openCount + 1;
                    wrap.openRequests.add(incomingRequest);             
                }
                else{
                    wrap.closedCount = wrap.closedCount + 1;
                    wrap.closedRequests.add(incomingRequest);
                }
                
                system.debug('---incomingRequest-->'+incomingRequest);
                incomingListingTransferRequestsbySubscriptionId.put(incomingRequest.Requested_By__c, wrap);
            }
            
            outgoingListingsStr = JSON.serialize(outgoingListingTransferRequestsbySubscriptionId);
            incomingListingsStr = JSON.serialize(incomingListingTransferRequestsbySubscriptionId);
            
            system.debug( '^^^outgoingListingsStr' + outgoingListingsStr);
            system.debug( '^^^incomingListingsStr' + incomingListingsStr);
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getStackTraceString()));
        }
        
    }
    
    public void validateListingRequests(){
        if(hasError == true){
            return;
        }
        Map<String, Listing_Transfer_Request__c> listingKeys = new Map<String, Listing_Transfer_Request__c>();
        List<Listing_Transfer_Request__c> canceledRequests = new List<Listing_Transfer_Request__c>();       
        for(Listing_Transfer_Request__c request : [SELECT Id,Name, 
                                                   CanceledOn__c, IsActive__c, ListingKey__c,
                                                   DestinationOfficeCode__c, DestinationOfficeCode__r.Status__c, 
                                                   OriginationOfficeCode__c, OriginationOfficeCode__r.Status__c, 
                                                   Requested_By__c, Requested_By__r.Status__c, Requested_By__r.Name,
                                                   Requested_By__r.Related_Location_Broker_Office__c,
                                                   StatusCode__c,
                                                   ExpirationDate__c
                                                   FROM   Listing_Transfer_Request__c 
                                                   WHERE  IsActive__c = true
                                                   AND    (DestinationOfficeCode__c IN :officeIds.keyset() OR OriginationOfficeCode__c IN :officeIds.keyset())
                                                   AND    ExpirationDate__c >= today
                                                   AND    StatusCode__c = 'Pending'
                                                  ]){                            
                                                      
                                                      Boolean isCanceled = false;
                                                      String canceledReason = null;
                                                      
                                                      if(request.Requested_By__r.Status__c != 'Active'){
                                                          isCanceled = true;
                                                          canceledReason = 'Listing Agent is not active';
                                                      }
                                                      else if(request.OriginationOfficeCode__c == request.Requested_By__r.Related_Location_Broker_Office__c){
                                                          isCanceled = true; 
                                                          canceledReason = 'Listing Agent and the property belong to the same office.';
                                                      } 
                                                      else if(request.OriginationOfficeCode__r.Status__c != 'Active'){
                                                          isCanceled = true; 
                                                          canceledReason = 'Listing Office is not active';
                                                      }
                                                      else if(request.DestinationOfficeCode__r.Status__c != 'Active'){
                                                          isCanceled = true; 
                                                          canceledReason = 'Listing Office is not active';
                                                      }
                                                      else{
                                                          listingKeys.put(request.ListingKey__c, request);
                                                          if(listingKeys.size() == 200){                  
                                                              canceledRequests.addAll(findCancelledRequestMDS(listingKeys));
                                                              listingKeys = new Map<String, Listing_Transfer_Request__c>();
                                                          }
                                                      }
                                                      
                                                      if(isCanceled){
                                                          request.IsActive__c = false;
                                                          request.CanceledReason__c = canceledReason;
                                                          request.CanceledOn__c = system.today();
                                                          request.StatusCode__c = 'Canceled';
                                                          canceledRequests.add(request);
                                                      }                                           
                                                  }
        
        if(listingKeys.size() > 0)                
            canceledRequests.addAll(findCancelledRequestMDS(listingKeys));  
        
        if(canceledRequests.size() > 0){
            update canceledRequests;
        }
    }
    
    public List<Listing_Transfer_Request__c> findCancelledRequestMDS(Map<String, Listing_Transfer_Request__c> listingKeys){
        List<Listing_Transfer_Request__c> canceledRequests = new List<Listing_Transfer_Request__c>();
        
        String fieldNames = 'ListAgentMlsId,ListingKey,MlsStatus,ComparableYN';
        String agentIdFieldName = 'ListAgentMlsId';
        String statusFieldName = 'MlsStatus';
        String comparableFieldName = 'ComparableYN';
        Set<String> ineligibleStatuses = new Set<String>{'CLOSED', 'EXPIRED', 'WITHDRAWN', 'DELETED', 'CANCELED'};
            
            Map<String, Map<String, String>> listingDetails = LT_MDS.getListingDetailsfromMDS(fieldNames, new List<String> (listingKeys.keyset()));
        for(String listingKey : listingDetails.keyset()){
            Listing_Transfer_Request__c lr = listingKeys.get(listingKey);
            Boolean isMDSCanceled = false;
            String mdsCanceledReason = null;
            String agentId = listingDetails.get(listingKey).get(agentIdFieldName);
            String comparable = listingDetails.get(listingKey).get(comparableFieldName);                        
            String status = listingDetails.get(listingKey).get(statusFieldName);
            
            if(comparable == '1'){
                isMDSCanceled = true;
                mdsCanceledReason = 'Listing is Comparable';
            }
            else if(ineligibleStatuses.contains(status)){
                isMDSCanceled = true;
                mdsCanceledReason = 'Listing has an ineligible status: ' + status;
            }
            else if(agentId != lr.Requested_By__r.Name){
                isMDSCanceled = true;
                mdsCanceledReason = 'Listing Agent has been changed';
            }
            
            if(isMDSCanceled){
                lr.IsActive__c = false;
                lr.CanceledReason__c = mdsCanceledReason;
                lr.CanceledOn__c = system.today();
                lr.StatusCode__c = 'Canceled';
                canceledRequests.add(lr);
            }
        }  
        return canceledRequests;
    }
    
    @RemoteAction
    public Static List<ListingDetail> getListingRequestDetails(List<String> requestIds, String requestType){
        
        List<Listing_Transfer_Request__c> requests = new List<Listing_Transfer_Request__c>();
        List<ListingDetail> listingDetails = new List<ListingDetail>();
        Boolean isIncoming = false;
        if(requestType == 'incoming')
            isIncoming = true;
        
        system.debug('--requestIds-->'+requestIds);    
        requests = [SELECT Id, Name, ExpirationDate__c, ListingKey__c, OriginationDecision__c,OriginationOfficeCode__r.BRIGHT_Office_Key__c,
                    DestinationDecision__c, DestinationOfficeCode__r.BRIGHT_Office_Key__c, DestinationOfficeCode__r.OfficeKey__c
                    FROM   Listing_Transfer_Request__c
                    WHERE  Id IN:requestIds
                   ]; 
        system.debug('---requests-->'+requests);
        if(requests.size() > 0){
            
            String fieldNames =  'ListingKey,ListingId,ListAgentKey,ListOfficeMlsId,ListAgentMlsId,MlsStatus,BathroomsTotalInteger,BathroomsFull,BathroomsHalf,BedroomsTotal,';
            fieldNames += 'ListPrice,FullStreetAddress,City,StateOrProvince,PostalCode,PostalCodePlus4,ListPicture2URL';
            
            EncodingUtil.urlEncode(fieldNames, 'UTF-8');
            
            Map<String, Listing_Transfer_Request__c> listingKeyRequests = new Map<String, Listing_Transfer_Request__c>();
            for(Listing_Transfer_Request__c request : requests){
                system.debug('---request--->'+request);
                listingKeyRequests.put(request.ListingKey__c, request);
                if(listingKeyRequests.size() == 200){
                    listingDetails.addAll(getListingDetailsMDS(fieldNames, listingKeyRequests, isIncoming));
                    listingKeyRequests = new Map<String, Listing_Transfer_Request__c>();
                }
            }
            if(listingKeyRequests.size() > 0){
                listingDetails.addAll(getListingDetailsMDS(fieldNames, listingKeyRequests, isIncoming));
                listingKeyRequests = new Map<String, Listing_Transfer_Request__c>();
            }           
        }
        system.debug('---listingDetails-->'+listingDetails);
        return listingDetails;    
    }
    
    public Static List<ListingDetail> getListingDetailsMDS(String fieldNames, Map<String, Listing_Transfer_Request__c> listingKeys, Boolean isIncoming){
        List<ListingDetail> listingDetails = new List<ListingDetail>();
        Map<String, Map<String, String>> listingDetailsMDS = LT_MDS.getListingDetailsfromMDS(fieldNames, new List<String>(listingKeys.keyset()));
        
        map<String, Subscriptions__c> subscriptionMap = new map<String, Subscriptions__c>();
        
        for(String listingKey : listingDetailsMDS.keySet()){
            system.debug('----listingKey---'+listingKey);
            Map<String,String> listingDetailMDS = listingDetailsMDS.get(listingKey);
            system.debug('---listingDetailMDS--'+listingDetailMDS); 
            ListingDetail detail = new ListingDetail();
            detail.isChecked = false;
            system.debug('---listingDetailMDS.get(ListingKey)-->'+listingDetailMDS.get('ListingKey'));
            detail.ListingId = listingDetailMDS.get('ListingId');
            detail.ListingKey = listingDetailMDS.get('ListingKey');
            detail.ListPrice = listingDetailMDS.get('ListPrice');
            detail.imageURL = listingDetailMDS.get('ListPicture2URL');
            detail.decision = null;
            detail.reassignedAgentId = null;
            
            detail.expirationDate = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).ExpirationDate__c : null;
            system.debug('--listingKey--->'+listingKey+'---listingKeys.get(listingKey)-->'+listingKeys.get(listingKey));
            detail.requestId = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).Id : null;
            if(detail.expirationDate != null){
                Integer days = System.today().daysbetween(detail.expirationDate);
                detail.expirationText = 'Expires in ' + String.valueOf(days) + ' days';
            }
            detail.isIncoming = isIncoming;
            detail.agentKey = listingDetailMDS.get('ListAgentKey');
            detail.originationDecision = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).OriginationDecision__c : null;
            detail.destinationDecision = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).DestinationDecision__c : null;
            
            detail.ListOfficeCode = listingDetailMDS.get('ListOfficeMlsId');
            detail.ListingStatus = listingDetailMDS.get('MlsStatus');
            detail.BathsFull = listingDetailMDS.get('BathroomsFull') != null ? integer.valueOf(listingDetailMDS.get('BathroomsFull')) : 0;
            detail.BathsHalf = listingDetailMDS.get('BathroomsHalf') != null ? integer.valueOf(listingDetailMDS.get('BathroomsHalf')) : 0;
            detail.Beds = listingDetailMDS.get('BedroomsTotal') != null ? integer.valueOf(listingDetailMDS.get('BedroomsTotal')) : 0;
            detail.subscriptionId = listingDetailMDS.get('ListAgentMlsId');
            detail.desinationOfficeKey = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).DestinationOfficeCode__r.BRIGHT_Office_Key__c : null;  
            detail.originationOfficeKey = listingKeys.containsKey(listingKey) ? listingKeys.get(listingKey).OriginationOfficeCode__r.BRIGHT_Office_Key__c: null;            
            detail.address = listingDetailMDS.get('FullStreetAddress') + ',' + listingDetailMDS.get('City') + ',' + listingDetailMDS.get('StateOrProvince') + ' '  + listingDetailMDS.get('PostalCode');
            detail.ListingAgentID=listingDetailMDS.get('ListAgentMlsId');
            
            system.debug('^^^'+ detail);
            listingDetails.add(detail);   
        }
        return listingDetails;
        
    }
    @RemoteAction
    public static String submitBrokerDecisions(List<ListingDetail> decidedListingDetails, Boolean isBOR, String decisionMadeBy, Boolean isSameBroker){
        try{
            system.debug('--isSameBroker--->'+isSameBroker+'--decidedListingDetails--->'+decidedListingDetails);
            Subscriptions__c subscription = new Subscriptions__c();
            subscription = [SELECT Id, Name, Service_Jurisdiction__c FROM Subscriptions__c WHERE Name = :decisionMadeBy];
            
            List<Listing_Transfer_Request__c> updatedRequests = new List<Listing_Transfer_Request__c>();
            for(ListingDetail detail : decidedListingDetails){
                String listingAgentId = detail.subscriptionId;
                String listingKey = detail.listingKey;
                String listingId = detail.listingId;
                String fieldName,fieldValue;
                
                Listing_Transfer_Request__c request = new Listing_Transfer_Request__c();
                request.Id = detail.requestId;
                
                if(isSameBroker){
                    request.DestinationDecision__c = detail.decision;
                    request.StatusCode__c = detail.decision;                
                    request.DestinationDecisionOn__c = system.today();
                    if(!isBOR)
                        request.DestinationDecisionImpersonatedBy__c = decisionMadeBy;
                    else
                        request.DestinationDecisionBy__c = decisionMadeBy;
                    
                    request.OriginationDecision__c = detail.decision;                
                    request.OriginationDecisionOn__c = system.today();
                    if(!isBOR)
                        request.OriginationDecisionImpersonatedBy__c = decisionMadeBy;
                    else
                        request.OriginationDecisionBy__c = decisionMadeBy; 
                    
                    system.debug('--sameBroker---request-->'+request);
                }                    
                else if(detail.isIncoming){
                    request.DestinationDecision__c = detail.decision;                                   
                    request.DestinationDecisionOn__c = system.today();
                    if(!isBOR)
                        request.DestinationDecisionImpersonatedBy__c = decisionMadeBy;
                    else
                        request.DestinationDecisionBy__c = decisionMadeBy;                            
                    
                    if(request.DestinationDecision__c == 'Rejected'){
                        request.StatusCode__c = detail.decision;
                    }
                    else if(String.isNotBlank(detail.originationDecision) && detail.originationDecision == 'Approved'){
                        request.StatusCode__c = detail.decision;                       
                    }
                    system.debug('--incoming--request-->'+request);
                }
                else{
                    request.OriginationDecision__c = detail.decision;                
                    request.OriginationDecisionOn__c = system.today();
                    if(!isBOR)
                        request.OriginationDecisionImpersonatedBy__c = decisionMadeBy;
                    else
                        request.OriginationDecisionBy__c = decisionMadeBy; 
                    
                    if(request.OriginationDecision__c == 'Rejected'){
                        request.StatusCode__c = detail.decision;
                    }
                    else if(String.isNotBlank(detail.destinationDecision) && detail.destinationDecision == 'Approved'){
                        request.StatusCode__c = detail.decision;                       
                    }
                    system.debug('--outgoing--request-->'+request);
                }
                
                if(detail.reassignedAgentId != null && detail.reassignedAgentId != ''){
                    request.Reassigned_To__c = detail.reassignedRId;
                }   
                
                updatedRequests.add(request);
            } 
            
            system.debug('---updatedRequests--->'+updatedRequests);
            
            update updatedRequests;
            
            return 'success';
        }
        catch(exception e){
            return e.getMessage() + e.getStackTraceString();
        }
    }
    
    @RemoteAction
    public Static Subscriptions__c getSubDetails(String subscriptionId){
        Subscriptions__c subscription = new Subscriptions__c();
        subscription = [SELECT Id, Name, Contact__c, Contact__r.Name, Contact__r.phone, Contact__r.Email, Related_Location_Broker_Office__c, 
                        Related_Location_Broker_Office__r.Name,
                        Related_Location_Broker_Office__r.Street_Number__c, Related_Location_Broker_Office__r.Street_Number_Suffix__c, Related_Location_Broker_Office__r.Street_Name__c, 
                        Related_Location_Broker_Office__r.Street_Type__c, Related_Location_Broker_Office__r.Street_Direction__c,
                        Related_Location_Broker_Office__r.Unit_Type__c, Related_Location_Broker_Office__r.Unit__c, 
                        Related_Location_Broker_Office__r.City__c, Related_Location_Broker_Office__r.State__c, 
                        Related_Location_Broker_Office__r.Zip__c, Related_Location_Broker_Office__r.Zip_4__c 
                        FROM Subscriptions__c
                        WHERE Name = :subscriptionId                                           
                       ];
        
        return subscription;
    }
    
    @RemoteAction
    public Static Account getOfficeDetails(String officeId){
        Account office = new Account();
        if(officeId != null){
            officeId = officeId.unescapeHtml4();
        office = [SELECT Id, Name,
                  Street_Number__c, Street_Number_Suffix__c, Street_Name__c, 
                  Street_Type__c, Street_Direction__c,
                  Unit_Type__c, Unit__c, 
                  City__c, State__c, 
                  Zip__c, Zip_4__c 
                  FROM   Account
                  WHERE  Name = :officeId                                           
                 ];
        }
        return office;
    }
    
    @RemoteAction
    public Static String validateSubscription(String subscriptionId, String officeId){
        Subscriptions__c subscription = new Subscriptions__c();
        subscription = [SELECT Id, Name, Bright_Agent_Key__c 
                        FROM   Subscriptions__c
                        WHERE  Status__c = 'Active'
                        AND    Name = :subscriptionId 
                        AND    Related_Location_Broker_Office__r.Name = :officeId                      
                       ];
        return subscription.Id + ',' + subscription.Bright_Agent_Key__c;
    }
    
    public class ListingDetail {
        public String subscriptionId { get; set; }
        public String listingAgentId { get; set; }
        public Boolean isChecked {get; set;}
        public String ListingKey {get; set;}
        public String ListingId {get; set;}
        public String ListOfficeCode {get; set;}
        public String ListingStatus {get; set;}
        public Integer BathsFull {get; set;}
        public Integer BathsHalf {get; set;}
        public Integer Beds {get; set;}
        public String ListPrice {get; set;}
        public String address { get; set; }
        public String imageURL { get; set;}
        public String decision { get; set;}
        
        public Date expirationDate { get; set; }
        public String expirationText { get; set; }
        public String requestId { get; set; }
        public Boolean isIncoming { get; set; }
        public Boolean canMakeDecision { get; set; }
        public String desinationOfficeKey { get; set; }
        public String originationOfficeKey { get; set; }
        public String destinationDecision { get; set; }
        public String originationDecision { get; set; }
        public String reassignedAgentId { get; set; }
        public String reassignedAgentKey { get; set; }
        public String reassignedRId {get; set;}
        public Boolean reassign {get; set;}
        public Boolean reassignError {get; set;}
        public String agentKey {get; set;}
    }    
    
    public class ListingTransferRequest{
        public Id subscriptionId { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String officeName { get; set; }
        public Integer openCount { get; set; }
        public Integer closedCount { get; set; }
        public Integer totalCount { get; set; }
        public List<Listing_Transfer_Request__c> openRequests { get; set; }
        public List<Listing_Transfer_Request__c> closedRequests { get; set; }
        public Date expirationDate { get; set; }
        public String expirationText { get; set; } 
        public Boolean isSameOffice { get; set; }
        public String ListingAgentID{ get; set; }
        
        public ListingTransferRequest() {
            openCount = 0;
            closedCount = 0;
            totalCount = 0;
            openRequests = new List<Listing_Transfer_Request__c>();
            closedRequests = new List<Listing_Transfer_Request__c>(); 
            isSameOffice = false;           
        }
    }
}