public class Communities_AgentListings {
    public String query { get; set; }
    public String subscriptionId { get; set; }
    public Subscriptions__c subscription { get; set; }
    public String serviceJurisdiction { get; set; }
    public Boolean isAgentActive { get; set; }   
    public String selectedStatus { get; set; }
    public List<ListingDetail> listingDetails { get; set; }
    
    public List<SelectOption> getListingStatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Listing Status'));
        
        options.add(new SelectOption('ACTIVE UNDER CONTRACT','ACTIVE UNDER CONTRACT'));
        options.add(new SelectOption('ACTIVE','ACTIVE'));
        options.add(new SelectOption('CANCELED','CANCELED'));
        options.add(new SelectOption('CLOSED','CLOSED'));
        options.add(new SelectOption('COMING SOON','COMING SOON'));
        options.add(new SelectOption('DELETED','DELETED'));
        options.add(new SelectOption('EXPIRED','EXPIRED'));
        options.add(new SelectOption('PENDING','PENDING'));
        options.add(new SelectOption('TEMP OFF MARKET','TEMP OFF MARKET'));
        options.add(new SelectOption('WITHDRAWN','WITHDRAWN'));
        
        return options;
    }
    
    public Communities_AgentListings(){
        subscriptionId = Apexpages.currentPage().getParameters().get('id');
        system.debug('---subId--->' + subscriptionId);
        if(String.isBlank(subscriptionId))
            throw new CustomException('Invalid Subscription ID');
                
        subscription = [Select id, name, Service_Jurisdiction__c, Private_Email__c, 
                        Contact__c, Contact__r.Name, Contact__r.phone, Contact__r.Email, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Name, 
                        Related_Location_Broker_Office__r.Street_Number__c, Related_Location_Broker_Office__r.Street_Number_Suffix__c, Related_Location_Broker_Office__r.Street_Name__c, 
                        Related_Location_Broker_Office__r.Street_Type__c, Related_Location_Broker_Office__r.Street_Direction__c,
                        Related_Location_Broker_Office__r.Unit_Type__c, Related_Location_Broker_Office__r.Unit__c, 
                        Related_Location_Broker_Office__r.City__c, Related_Location_Broker_Office__r.State__c, 
                        Related_Location_Broker_Office__r.Zip__c, Related_Location_Broker_Office__r.Zip_4__c 
                        From Subscriptions__c
                        WHERE Name = :subscriptionId                                           
                        ];
                                            
    }
    
     public void validateListingRequests(){
        Map<String, Listing_Transfer_Request__c> listingKeys = new Map<String, Listing_Transfer_Request__c>();
        List<Listing_Transfer_Request__c> canceledRequests = new List<Listing_Transfer_Request__c>();       
        for(Listing_Transfer_Request__c request : [SELECT Id, Name, CanceledOn__c, IsActive__c, ListingKey__c,
                                                          DestinationOfficeCode__c, DestinationOfficeCode__r.Status__c,                                                                                                                       
                                                          OriginationOfficeCode__c, OriginationOfficeCode__r.Status__c,                                                                                                                      
                                                          Requested_By__c, Requested_By__r.Name, Requested_By__r.Status__c, 
                                                          Requested_By__r.Related_Location_Broker_Office__c,
                                                          StatusCode__c, ExpirationDate__c
                                                   FROM   Listing_Transfer_Request__c 
                                                   WHERE  IsActive__c = true
                                                   AND    Requested_By__r.Name = :subscriptionId
                                                   AND    ExpirationDate__c >= today
                                                   AND    StatusCode__c = 'Pending'
                                                  ]){
            
            Boolean isCanceled = false;
            String canceledReason = null;
            
            if(request.OriginationOfficeCode__c == request.Requested_By__r.Related_Location_Broker_Office__c){
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
                if(listingKeys.size() == 200)                   
                    canceledRequests.addAll(findCanceledRequestMDS(listingKeys)); 
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
            canceledRequests.addAll(findCanceledRequestMDS(listingKeys));         
        
        if(canceledRequests.size() > 0){
            update canceledRequests;
        }
    }
    
    public List<Listing_Transfer_Request__c> findCanceledRequestMDS(Map<String, Listing_Transfer_Request__c> listingKeys){
        List<Listing_Transfer_Request__c> canceledRequests = new List<Listing_Transfer_Request__c>();
        
        String fieldNames = 'ListAgentMlsId,ListingKey,MlsStatus,ComparableYN';
        String agentIdFieldName = 'ListAgentMlsId';
        String statusFieldName = 'MlsStatus';
        String comparableFieldName = 'ComparableYN';
        Set<String> ineligibleStatuses = new Set<String>{'CLOSED', 'EXPIRED', 'WITHDRAWN', 'DELETED', 'CANCELED'};
        
        Map<String, Map<String, String>> listingDetails = LT_MDS.getListingDetailsfromMDS(fieldNames, new List<String> (listingKeys.keyset()));
            for(String listingKey : listingDetails.keyset()){
                system.debug('^^^listingKeyMDS:' + listingKey);
                Listing_Transfer_Request__c lr = listingKeys.get(listingKey);
                Boolean isMDSCanceled = false;
                String mdsCanceledReason = null;
                String agentId = listingDetails.get(listingKey).get(agentIdFieldName);
                String comparable = listingDetails.get(listingKey).get(comparableFieldName);                        
                String status = listingDetails.get(listingKey).get(statusFieldName);
                
                system.debug('^^^agentId:' + agentId);
                system.debug('^^^lr:' + lr);
                
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
    public Static Set<String> getListingKeys(String statuses, String subscriptionId, String type){
        
        Subscriptions__c subscription = [SELECT Id, Name, Service_Jurisdiction__c, Related_Location_Broker_Office__r.Name
                                         FROM   Subscriptions__c
                                         WHERE  Name = :subscriptionId
                                        ];
        
        String statusFieldName = 'MlsStatus';
        String comparableFieldName = 'ComparableYN';
        String agentIdFieldName = 'ListAgentMlsId';
        String officeFieldName = 'ListOfficeMlsId';       
        
        
        Set<String> listingKeysResponse = new Set<String>();
        
        Set<String> pendingRequests = new Set<String>();
        
        for(Listing_Transfer_Request__c request : [SELECT Id, ListingKey__c                                                            
                                                       FROM   Listing_Transfer_Request__c 
                                                       WHERE  IsActive__c = true
                                                       AND    Requested_By__r.Name = :subscriptionId
                                                       AND    ExpirationDate__c >= today
                                                       AND    StatusCode__c = 'Pending'
                                                    ]){
                pendingRequests.add(request.ListingKey__c);                
        }
        
        Set<String> requestsOneMonthAgo = new Set<String>();
        for(Listing_Transfer_Request__c request : [SELECT Id, ListingKey__c                                                            
                                                       FROM   Listing_Transfer_Request__c 
                                                       WHERE  IsActive__c = true
                                                       AND    Requested_By__r.Name = :subscriptionId
                                                       AND    createdDate > LAST_N_DAYS:30
                                                    ]){
                requestsOneMonthAgo.add(request.ListingKey__c);                
        }
        
        
        system.debug('---pendingRequests--->'+pendingRequests);
        if(type == 'pending'){
            system.debug('---type --->'+type);
            listingKeysResponse.addAll(pendingRequests);
        }
        else if(type == 'recentRequests'){
            
            system.debug('---type --->'+type);
            Set<String> recentRequests = new Set<String>();
            for(Listing_Transfer_Request__c request : [SELECT Id, ListingKey__c                                                            
                                                       FROM   Listing_Transfer_Request__c 
                                                       WHERE  IsActive__c = true
                                                       AND    Requested_By__r.Name = :subscriptionId
                                                       AND    createdDate = LAST_N_DAYS:90
                                                    ]){
                recentRequests.add(request.ListingKey__c);                
            }
            
            listingKeysResponse.addAll(recentRequests);
            system.debug('---listingKeysResponse-->'+listingKeysResponse.size());
        }
        else{
            String query = '';
            if(type == 'eligible'){
                system.debug('---type--->'+type);
                query =  '(' + statusFieldName + ' IN '+ statuses +') AND ';
                query += '(' + comparableFieldName + ' EQ 0) AND ';
                query += '(' + agentIdFieldName + ' EQ \'' + subscriptionId + '\') AND ';
                query += '(' + officeFieldName + ' NEQ \'' + subscription.Related_Location_Broker_Office__r.Name + '\')';
                //query = '(MlsStatus IN \'ACTIVE-BRIGHT\',\'COMING SOON-BRIGHT\',\'TEMP OFF MARKET-BRIGHT\')';
                //query += '(' + lastModifiedFieldName + ' GTE ' + effectiveDate + ')';
            }
            else if(type == 'all'){
                system.debug('---type--->'+type);
                query  = '(' + agentIdFieldName + ' EQ \'' + subscriptionId + '\')'; 
                //query += '(' + lastModifiedFieldName + ' GTE ' + effectiveDate + ')';
            }
            else if(type == 'ineligible'){
                system.debug('---type--->'+type);
                query =  '((' + statusFieldName + ' IN '+ statuses +') OR ';
                query += '(' + comparableFieldName + ' EQ 1) OR ';
                query += '(' + officeFieldName + ' EQ \'' + subscription.Related_Location_Broker_Office__r.Name + '\')) AND ';
                query += '(' + agentIdFieldName + ' EQ \'' + subscriptionId + '\')';                
                //query += '(' + lastModifiedFieldName + ' GTE ' + effectiveDate + ')';        
            }
            
            system.debug('---query get listing method before encoding69 -->'+query);
            query = EncodingUtil.urlEncode(query, 'UTF-8');
            
            system.debug('---query get listing method -->'+query);
            listingKeysresponse = LT_MDS.queryListingKeys(query);
            
            if(type == 'eligible'){
                listingKeysresponse.removeAll(pendingRequests);
                listingKeysresponse.removeAll(requestsOneMonthAgo);
            }
        }
        
        system.debug('---listingKeysresponse---->'+listingKeysresponse);
        return listingKeysresponse;
    }
    
    
    @RemoteAction
    public Static List<ListingDetail> getProperties(List<String> listingKeys, String type, String subscriptionId){
        
        system.debug('---listingKeys--->'+listingKeys.size());
        if(listingKeys != null){
            Subscriptions__c subscription = [SELECT Id, Name, Service_Jurisdiction__c, Related_Location_Broker_Office__r.Name
                                            FROM   Subscriptions__c
                                            WHERE  Name = :subscriptionId
                                            ];
      
            Map<String, Listing_Transfer_Request__c> pendingRequests = new Map<String, Listing_Transfer_Request__c>();
            for(Listing_Transfer_Request__c request : [SELECT Id, ListingKey__c, OriginationDecision__c, DestinationDecision__c, ExpirationDate__c                                                           
                                                        FROM   Listing_Transfer_Request__c 
                                                        WHERE  IsActive__c = true
                                                        AND    ListingKey__c IN :listingKeys
                                                        AND    ExpirationDate__c >= today
                                                        AND    StatusCode__c = 'Pending'
                                                        ]){
                pendingRequests.put(request.ListingKey__c, request);
            }
        
        Map<String, Listing_Transfer_Request__c> recentRequests = new Map<String, Listing_Transfer_Request__c>();
        if(type == 'recentRequests'){
            for(Listing_Transfer_Request__c request : [SELECT Id, ListingKey__c, OriginationDecision__c, DestinationDecision__c, ExpirationDate__c, StatusCode__c                                                            
                                                        FROM   Listing_Transfer_Request__c 
                                                        WHERE  IsActive__c = true
                                                        AND  ListingKey__c IN :listingKeys
                                                        //AND  ExpirationDate__c >= today
                                                        AND  createdDate = LAST_N_DAYS:90
                                                        Order by createdDate desc
                                                        ]){
                recentRequests.put(request.ListingKey__c, request);
            }
        }
        system.debug('---recentRequests size--'+recentRequests.size());
        
        String fieldNames = 'ListingKey,ListingId,ListOfficeMlsId,ListAgentMlsId,MlsStatus,BathroomsTotalInteger,BathroomsFull,BathroomsHalf,BedroomsTotal,ListPrice,FullStreetAddress,City,StateOrProvince,PostalCode,PostalCodePlus4,ListPictureURL,ListPicture2URL,ModificationTimestamp';
        String statusFieldName = 'MlsStatus';
        String comparableFieldName = 'ComparableYN';
        String officeFieldName = 'ListOfficeMlsId';
        String lastModifiedFieldName = 'ModificationTimestamp';
        Set<String> ineligibleStatuses = new Set<String>{'CLOSED', 'EXPIRED', 'WITHDRAWN', 'DELETED', 'CANCELED'};
        Date effectiveDate = Date.today().addMonths(-6);    
      
       
        EncodingUtil.urlEncode(fieldNames, 'UTF-8');  
        Map<String, Map<String, String>> listingDetailsMDS = LT_MDS.getListingDetailsfromMDS(fieldNames, listingKeys);
        
        if(listingDetailsMDS == null)
          throw new CustomException('Listings are not Available');
        
        List<ListingDetail> listingDetails = new List<ListingDetail>();
        
        List<ListingDetail> sfdcListingDetails = new List<ListingDetail>();
        List<ListingDetail> mdsListingDetails = new List<ListingDetail>();
        
        for(String listingKey : listingDetailsMDS.keySet()){
            Map<String,String> listingDetailMDS = listingDetailsMDS.get(listingKey); 
            
            String lastModified = listingDetailMDS.get('ModificationTimestamp');
            Date lastModifiedDate;
            if(lastModified != null)
                lastModifiedDate = Date.valueOf(lastModified) ;
            
            if(lastModifiedDate != null && (effectiveDate < lastModifiedDate)){
                ListingDetail detail = new ListingDetail();   
                detail.isChecked = false;
                detail.ListingKey = listingDetailMDS.get('ListingKey');
                detail.ListingId = listingDetailMDS.get('ListingId');
                detail.ListPrice = listingDetailMDS.get('ListPrice');
                detail.imageURL = listingDetailMDS.get('ListPicture2URL');
                detail.status = 'eligible';
                detail.statusMessage = 'eligible';
                system.debug('---detail.ListingId-->'+detail.ListingId);       
                
                detail.ListOfficeCode = listingDetailMDS.get('ListOfficeMlsId');
                detail.agentId = listingDetailMDS.get('ListAgentMlsId');
                detail.ListingStatus = listingDetailMDS.get('MlsStatus');
                detail.BathsFull = listingDetailMDS.get('BathroomsFull') != null ? Integer.valueOf(listingDetailMDS.get('BathroomsFull')) : 0;
                detail.BathsHalf = listingDetailMDS.get('BathroomsHalf') != null ? Integer.valueOf(listingDetailMDS.get('BathroomsHalf')) : 0;
                detail.Beds = listingDetailMDS.get('BedroomsTotal') != null ? Integer.valueOf(listingDetailMDS.get('BedroomsTotal')) : 0;
                detail.address = listingDetailMDS.get('FullStreetAddress') + ', ' + listingDetailMDS.get('City') + ', ' + listingDetailMDS.get('StateOrProvince') + ' '  + listingDetailMDS.get('PostalCode');
                
                //system.debug('^^^'+ detail);
                if(type == 'all'){
                    Boolean isIneligible = false;
                    String comparable = listingDetailMDS.get(comparableFieldName);                        
                    String status = listingDetailMDS.get(statusFieldName); 
                    String officeName = listingDetailMDS.get(officeFieldName);            
                    if(comparable == '1')
                        isIneligible = true;
                    else if(ineligibleStatuses.contains(status))
                        isIneligible = true;
                    else if(officeName == subscription.Related_Location_Broker_Office__r.Name)
                        isIneligible = true;
                    
                    if(isIneligible){
                        detail.status = 'ineligible';
                        detail.statusMessage = 'Ineligible';
                    }
                }
                else if(type == 'ineligible' ){
                    detail.status = 'ineligible';
                    detail.statusMessage = 'Ineligible';
                }
                
                
                boolean checkPending = false;
                if(pendingRequests.containskey(detail.ListingKey)){
                    Listing_Transfer_Request__c request = pendingRequests.get(detail.ListingKey);
                    Integer days = System.today().daysbetween(request.ExpirationDate__c);              
                    
                    detail.status = 'pending';
                    detail.statusMessage = 'Pending Broker Approval' + '(Expires in ' + String.valueOf(days) + ' days)';
                    checkPending = true;
                }
                
                if(type == 'recentRequests'){
                    detail.status = 'Recent Request';
                    if(recentRequests.containsKey(detail.ListingKey)){
                        system.debug('--entered if condition--'+string.valueOf(recentRequests.get(detail.ListingKey).StatusCode__c));
                        detail.status = string.valueOf(recentRequests.get(detail.ListingKey).StatusCode__c).toLowerCase();
                        detail.statusMessage = recentRequests.get(detail.ListingKey).StatusCode__c;
                    }
                    else{
                        detail.statusMessage = 'Recent Request';
                    }
                }
                
                if(type == 'eligible' && checkPending == true){}
                else
                    listingDetails.add(detail);
                
            }
        }
        return listingDetails;
      }
      else
        return null;
    }
    
    @RemoteAction
    public static Account getOriginationOfficeDetails(String officeCode){
        Account originationOffice = new Account();
        if(officeCode != null){
            officeCode.unescapeHtml4();
            originationOffice = [Select Id, Name,
                                    Street_Number__c, Street_Number_Suffix__c, Street_Name__c, 
                                    Street_Type__c, Street_Direction__c,
                                    Unit_Type__c, Unit__c, 
                                    City__c, State__c, 
                                    Zip__c, Zip_4__c 
                                    From Account 
                                    Where Name =: officeCode];
        }
        return originationOffice;
    }
    
    @RemoteAction
    public static String submitListingTransferRequest(List<ListingRequest> requestsWrap) {
        
        try{
          List<String> subscriptionNames = new List<String>();
          list<String> originOffices = new list<String>();
          for(ListingRequest lr : requestsWrap) {
              subscriptionNames.add(lr.agentId);
              originOffices.add(lr.originatingOffice);
          }
          system.debug('originOffices-->'+originOffices);
          Map<String, Subscriptions__c> subscriptionMap = new Map<String, Subscriptions__c>();
          for(Subscriptions__c sub : [SELECT Id, Name, Related_Location_Broker_Office__c 
                                      FROM   Subscriptions__c 
                                      WHERE  Name IN :subscriptionNames 
                                      AND    Status__c = 'Active']) {
              subscriptionMap.put(sub.Name, sub);
          }
          system.debug('--subscriptionMap--->'+subscriptionMap);
          Map<String, Account> originOfficeMap = new Map<String, Account>();
          for(Account acc : [SELECT Id, Name from Account Where Name in :originOffices]){
              originOfficeMap.put(acc.Name, acc);
          }
          system.debug('---originOfficeMap--->'+originOfficeMap);
          String expiryDays = Listing_Transfer__c.getValues('Expiry Days').Value__c;
          Date expirationDate = Date.today().addDays(Integer.valueOf(expiryDays));
          
          List<Listing_Transfer_Request__c> ltRequests = new List<Listing_Transfer_Request__c>();
          for(ListingRequest lr : requestsWrap) {
              Listing_Transfer_Request__c ltRequest = new Listing_Transfer_Request__c();
              ltRequest.StatusCode__c = 'Pending';
              ltRequest.IsActive__c = true;
              ltRequest.RequestedOn__c = System.today();
              ltRequest.DestinationOfficeCode__c = subscriptionMap.get(lr.agentId).Related_Location_Broker_Office__c;
              ltRequest.Requested_By__c = subscriptionMap.get(lr.agentId).Id;
              ltRequest.ListingKey__c = lr.listingKey;
              ltRequest.ListingId__c = lr.listingId;
              ltRequest.OriginationOfficeCode__c = originOfficeMap.get(lr.originatingOffice).Id;
              ltRequest.ExpirationDate__c = expirationDate;
              ltRequest.Listing_Agent_ID__c= lr.agentId ;
              ltRequests.add(ltRequest);
          }
          insert ltRequests;
          return 'success';
        }
        catch(exception ex){
          return ex.getMessage();
        }
    } 
    
    // wrapper to display listings on page 
    public class ListingDetail {
        public Boolean isChecked { get; set; }
        public String ListingKey { get; set; }
        public String ListingId { get; set; }
        public String agentId { get; set; }
        public String ListOfficeCode { get; set; }
        public String ListingStatus { get; set; }
        public Integer BathsFull { get; set; }
        public Integer BathsHalf { get; set; }
        public Integer Beds { get; set; }
        public String ListPrice { get; set; }
        public String address { get; set; }
        public String imageURL { get; set; }
        public String status { get; set; }
        public String statusMessage { get; set; }
        
    }
    
    public class ListingRequest {
        public String listingKey { get; set; }
        public String listingId { get; set; }
        public String agentId { get; set; }
        public String originatingOffice { get; set; }
        
    }
    
    public Class CustomException extends Exception {}
}