global class SubscriptionRoleProcessingUtility {

   //  mrk (7/12/13) - methods added to check future thread state 
   //  and prevent multiple asynchronous calls.

    global static void createSubscriptionRole(Map<Id,String> subscriptionRoleJSONs) {
       System.debug('Inside createSubscriptionRole');
       if(!System.isFuture()) 
          createSubscriptionRoleFuture(subscriptionRoleJSONs);
       else
          createSubscriptionRoleOrig(subscriptionRoleJSONs);
    }

    @future (callout=true)
    global static void createSubscriptionRoleFuture(Map<Id,String> subscriptionRoleJSONs) {
       System.debug('Inside createSubscriptionRoleFuture');
       createSubscriptionRoleOrig(subscriptionRoleJSONs);
    }
    
    global static void createSubscriptionRoleOrig( Map<Id,String> subscriptionRoleJSONs) {
        //Process each relationship
        System.debug('Entered createSubscriptionRoleOrig');
        
        List<String> subscriptionIds = new List<String>();
        List<String> accountIds = new List<String>();
        
        Map<String,Subscription_Role__c> subscriptionRoles = new Map<String,Subscription_Role__c>();
        Map<String,Subscriptions__c> subscriptions = new Map<String,Subscriptions__c>();
        
        for (Id subscriptionRoleID : subscriptionRoleJSONs.keySet()){
            String subscriptionRoleJSON = subscriptionRoleJSONs.get(subscriptionRoleID);
            Subscription_Role__c subscriptionRole = (Subscription_Role__c)System.JSON.deserialize(subscriptionRoleJSON,sObject.class);
            subscriptionRoles.put(subscriptionRole.Id, subscriptionRole);
            
            subscriptionIds.add(subscriptionRole.Subscription__c);          
        }
                
        for(Subscriptions__c subscription : [SELECT Id, AgentKey__C,PrimarySubNum__c,Related_Location_Broker_Office__c FROM Subscriptions__c WHERE  Id IN :subscriptionIds]){
            subscriptions.put(subscription.Id, subscription);
            accountIds.add(subscription.Related_Location_Broker_Office__c);
        }
        
        Map<String,Account> accounts = new Map<String,Account>([SELECT Id, OfficeKey__c, Type, Company_Type__C, Name FROM Account WHERE Id IN :accountIds]);
        
        for(Id subscriptionRoleId : subscriptionRoles.keyset()){
            Map<String, Subscription_Role__c> relationshipIds = new Map<String,Subscription_Role__c>();
            
            Subscription_Role__c subscriptionRole = subscriptionRoles.get(subscriptionRoleId);
            Subscriptions__c subscription = subscriptions.get(subscriptionRole.Subscription__c);
            Account account = accounts.get(subscription.Related_Location_Broker_Office__c);         
            
            typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
            QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE26');
            
            Set<String> roleNames = new Set<String>();
            if(Utils.isNull(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c)))
                roleNames.add(subscriptionRole.Role__c);  
            else
                roleNames.add(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c));
            
            Map<ID,CornerstoneMappings__c> cornerstoneMappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
            if (cornerstoneMappings.keySet().size() > 0) {
                Map<String,String> tempRoleListMappings = new Map<String,String>();
                Map<String,String> roleListMappings = new Map<String,String>();  
                    
                for (Id cornerstoneId : cornerstoneMappings.keySet()){
                    CornerstoneMappings__c cm = cornerstoneMappings.get(cornerstoneId);
                    tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
                }
                
                //Swap the maps to get the correct order
                for (String roleName : roleNames){
                    System.debug('roleName ---> ' + roleName);
                    System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
                    roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
                }
                
                String sysrole = '' + subscription.PrimarySubNum__c;
                Integer i = 1;
                Map<String,String> roleNamesMap = new Map<String,String>();
                if ('RETS'.equals(account.Type) || 'Vendor'.equals(account.Type) || 'Virtual Tour Vendor'.equals(account.Type)) {
                    sysRole = Utils.splitByDigits(account.Name);
                    if(Utils.isNull(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c))) 
                         roleNamesMap.put(subscriptionRole.role__c,'');
                    else 
                         roleNamesMap.put(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c),'');
                                        
                    genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,cornerstoneMappings,roleListMappings,account.OfficeKey__c,sysrole,i));
                } 
                else {
                    if(Utils.isNull(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c))) 
                         roleNamesMap.put(subscriptionRole.role__c,account.OfficeKey__c);
                    else 
                         roleNamesMap.put(SubscriptionUtility.role2Mapping.get(subscriptionRole.Role__c),account.OfficeKey__c);                     
                    
                    genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,cornerstoneMappings,roleListMappings,subscription.AgentKey__c,sysrole,i));
                }
                    
                QPRequest.requests  = genericRequestTypes;                
                relationshipIds.put(roleListMappings.get(subscriptionRole.role__c), subscriptionRole);                    
                                 
                callQP(subscriptionRole.role__c, relationshipIds, QPRequest, true, roleListMappings.get(subscriptionRole.role__c));
            }
        }
    }
    
   //  mrk (7/12/13) - methods added to check future thread state 
   //  and prevent multiple asynchronous calls.

    global static void deleteSubscriptionRole( Map<Id,String> subscriptionRoleJSONs) {   
       System.debug('Inside deleteSubscriptionRole');
       if (!System.isFuture()) {
          deleteSubscriptionRoleFuture(subscriptionRoleJSONs);
       } else {
          deleteSubscriptionRoleOrig(subscriptionRoleJSONs);
       }
    }

    @future (callout=true)
    global static void deleteSubscriptionRoleFuture( Map<Id,String> subscriptionRoleJSONs) {
       System.debug('Inside methodFuture');
       deleteSubscriptionRoleOrig(subscriptionRoleJSONs);
    }

    global static void deleteSubscriptionRoleOrig( Map<Id,String> subscriptionRoleJSONs) {
        
         //Process each relationship
         System.debug('Entered deleteSubscriptionRoleOrig');
         
        List<String> subscriptionIds = new List<String>();        
        Map<String,Subscription_Role__c> subscriptionRoles = new Map<String,Subscription_Role__c>();        
        
        for (Id subscriptionRoleID : subscriptionRoleJSONs.keySet()){
            String subscriptionRoleJSON = subscriptionRoleJSONs.get(subscriptionRoleID);
            Subscription_Role__c subscriptionRole = (Subscription_Role__c)System.JSON.deserialize(subscriptionRoleJSON,sObject.class);
            subscriptionRoles.put(subscriptionRole.Id, subscriptionRole);
            
            subscriptionIds.add(subscriptionRole.Subscription__c);          
        }
                
        Map<String,Subscriptions__c> subscriptions = new Map<String,Subscriptions__c>([SELECT Id, AgentKey__C,PrimarySubNum__c FROM Subscriptions__c WHERE  Id IN :subscriptionIds]);
                 
         for (Id subscriptionRoleID : subscriptionRoles.keySet()){
            Subscription_Role__c subscriptionRole = subscriptionRoles.get(subscriptionRoleID);
            Subscriptions__c subscription = subscriptions.get(subscriptionRole.Subscription__c);
            
            typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
            QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE29');
            
            Set<String> roleNames = new Set<String>();
            roleNames.add(subscriptionRole.role__c);
            
            Map<ID,CornerstoneMappings__c> cornerstoneMappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
            Map<String,String> tempRoleListMappings = new Map<String,String>();
            Map<String,String> roleListMappings = new Map<String,String>();  
                
            for (Id cornerstoneId : cornerstoneMappings.keySet()){
                CornerstoneMappings__c cm = cornerstoneMappings.get(cornerstoneId);
                tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
            }
            
            //Swap the maps to get the correct order
            for (String roleName : roleNames){
                System.debug('roleName ---> ' + roleName);
                System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
                roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
            }
            
            Map<String,String> oldRoleNamesMap = new Map<String,String>();
            oldRoleNamesMap.put(subscriptionRole.role__c,subscriptionRole.SysPrRoleKey__c);
            
            genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap,subscription.AgentKey__c,null, 1));
            QPRequest.requests  = genericRequestTypes;
            Map<String, Subscription_Role__c> relationshipIds = new Map<String, Subscription_Role__c>();
            relationshipIds.put(roleListMappings.get(subscriptionRole.role__c), subscriptionRole);
             //Call QP and insert the messages 
            callQP(subscriptionRole.role__c, relationshipIds,QPRequest,false,roleListMappings.get(subscriptionRole.role__c));
         }
    }
    
    private static void callQP(String typeName, Map<String, Subscription_Role__c> relationshipIds, typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest, Boolean isInsert, String role) {
            
            QPRequest.sfdcMessageId = Utils.getRandomNumber();
            String status = 'Sent';
            String statusMessage = 'Success';
            boolean hasFailedSFQP = false;
            
            typesWebserviceQueueprocessorCrmMris.OutputResponse QPResponse;
            try {
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                stub.inputHttpHeaders_x = new Map<String,String>();
                //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                QPResponse = stub.salesForceRequest(QPRequest);
                System.debug('response code: ' + QPResponse.responseCode);
                if('FAIL'.equals(QPResponse.responseCode)) {
                    status = 'Failed';
                    statusMessage = QPResponse.responseDescription;
                }            
            } 
            catch (Exception ex){
                status = 'Failed';
                hasFailedSFQP = true;
                statusMessage = ex.getMessage()+ ': ' + ex.getStackTraceString();
                System.debug('callQP exception: ' + statusMessage );
                System.debug('callQP exception: ' + ex);
            }
            
            System.debug('QPResponse ---> ' +QPResponse);
            List<SFQPConnector__c> SFQPConnectors = new List<SFQPConnector__c>();
            List<Subscription_Role__c> subscriptionRoles = new List<Subscription_Role__c>();
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType requestType : QPRequest.requests){
                System.debug('requestType.sysParty.sysPRRoleKey -----> ' + requestType.sysParty.sysPRRoleKey);
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                sf.MessageSent__c = JSON.serialize(requestType);
                sf.ObjectType__c = 'Subscription_Role__c';
                sf.SFMessageID__c = requestType.sysParty.uuid;
                sf.relatedid__c = relationshipIds.get(role).Id;
                if (hasFailedSFQP) {
                    sf.QPStatus__c = 'Failed-SFQP';
                } else {
                    sf.QPStatus__c = status;
                }
                sf.QPMessage__c = statusMessage;
                SFQPConnectors.add(sf);
                
                Subscription_Role__c subscriptionRole = relationshipIDs.get(role);
                if (isInsert) {
                    subscriptionRole.MDS_Status__c = 'Sent';
                    subscriptionRole.Role_Start_Date__c = Date.today();
                    subscriptionRole.Role_End_Date__c = null;
                } else {
                    subscriptionRole.MDS_Status__c = 'Sent';
                    subscriptionRole.Role_End_Date__c = Date.today();                   
                }
                subscriptionRoles.add(subscriptionRole);
            }
            
            upsert SFQPConnectors;
            upsert subscriptionRoles;
    }
}