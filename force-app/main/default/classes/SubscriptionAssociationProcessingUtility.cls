global class SubscriptionAssociationProcessingUtility {
    
    @future (callout=true)
    global static void createSubscriptionAssociation( Map<Id,String> subscriptionAssociationJSONs) {
        Map<Integer,Related_Association__c> relationshipMap = new Map<Integer,Related_Association__c>();
        
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        genericRequestTypes = buildCreateAssociationsStr(subscriptionAssociationJSONs,relationshipMap,0); 
        if (genericRequestTypes == null)
            return;
        
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE21');
        QPRequest.requests  = genericRequestTypes;
        
        callQP(relationshipMap,QPRequest,true);
      
    }
    
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>  buildCreateAssociationsStr(Map<Id,String> subscriptionAssociationJSONs, Map<Integer,Related_Association__c> relationshipMap, Integer i){
        Map<Id,Related_Association__c> subscriptionAssociations = new Map<Id,Related_Association__c>();
        Map<Id,Set<Related_Association__c>> subscriptionIds = new Map<Id,Set<Related_Association__c>>();
        
        for (Id subscriptionAssociationID : subscriptionAssociationJSONs.keySet()){
            String subscriptionAssociationJSON = subscriptionAssociationJSONs.get(subscriptionAssociationID);
            Related_Association__c subscriptionAssociation = (Related_Association__c)System.JSON.deserialize(subscriptionAssociationJSON,sObject.class);
            
            if (Utils.isNotNull(subscriptionAssociation.Subscription__c)){
                if(!subscriptionIds.containsKey(subscriptionAssociation.Subscription__c))
                    subscriptionIds.put(subscriptionAssociation.Subscription__c, new Set<Related_Association__c>());
                
                subscriptionIds.get(subscriptionAssociation.Subscription__c).add(subscriptionAssociation); 
            }          
            else
                subscriptionAssociations.put(subscriptionAssociationID,subscriptionAssociation);   
        }
        
        for(Subscriptions__c subscription : [SELECT Id, agentKey__c,PrimarySubNum__c FROM Subscriptions__c WHERE Id IN :subscriptionIds.keyset()]){
            if (Utils.isNotNull(subscription.AgentKey__c)){
                for(Related_Association__c subscriptionAssociation : subscriptionIds.get(subscription.Id))
                    subscriptionAssociations.put(subscriptionAssociation.Id,subscriptionAssociation);
                
            }
        }

        if (subscriptionAssociations.keySet().size() == 0)
            return null;
        
        Map<String,String> roleListMappings = new  Map<String,String>();
        return buildCreateAssociations(subscriptionAssociations, relationshipMap, roleListMappings, i);      
    }
    
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>  buildCreateAssociations(Map<Id,Related_Association__c> subscriptionAssociations,Map<Integer,Related_Association__c>  relationshipMap, 
                                                                                                         Map<String,String> roleListMappings,Integer i){
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Association Member Primary');
        roleNames.add('Association Member');
        
        List<String> subscriptionIds = new List<String>();
        List<String> brokerCodeAccountIds = new List<String>();
        List<String> associationAccountIds = new List<String>();
        
        Map<Id,Map<String,String>> associationDetails = new Map<Id,Map<String,String>>();
        
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        Map<ID,CornerstoneMappings__c> cornerstoneMappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        
        Map<String,String> roleNameCornerstoneIds = new Map<String, String>();
        for (Id cornerstoneId : cornerstoneMappings.keySet()){
            CornerstoneMappings__c cm = cornerstoneMappings.get(cornerstoneId);
            roleNameCornerstoneIds.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        for(Id subscriptionAssociationID : subscriptionAssociations.keySet()){
            Related_Association__c subscriptionAssociation = subscriptionAssociations.get(subscriptionAssociationID);
            
            Map<String,String> details = new Map<String,String>{'agentKey' => '', 
                                                                'associationKey' => '', 
                                                                'officeKey' => '', 
                                                                'sysPrRoleID' => '', 
                                                                'isAgent' => 'false'};
            associationDetails.put(subscriptionAssociation.Id,details);
            
            if(Utils.isNotNull(subscriptionAssociation.Subscription__c))
                subscriptionIds.add(subscriptionAssociation.Subscription__c);
            if(Utils.isNotNull(subscriptionAssociation.Broker_Code__c))
                brokerCodeAccountIds.add(subscriptionAssociation.Broker_Code__c);
            if(Utils.isNotNull(subscriptionAssociation.Association__c))
                associationAccountIds.add(subscriptionAssociation.Association__c);
            
        }
        
        Map<String,Subscriptions__c> subscriptions = new Map<String,Subscriptions__c>([SELECT Id, agentKey__c, PrimarySubNum__c FROM Subscriptions__c WHERE Id IN :subscriptionIds]);
        Map<String,Account> brokerCodeAccounts = new Map<String,Account>([SELECT Id, officeKey__c, Name FROM Account WHERE Id IN :brokerCodeAccountIds]);
        Map<String,Account> associationAccounts = new Map<String,Account>([SELECT Id, officeKey__c FROM Account WHERE Id IN :associationAccountIds]);
        
        for (Id subscriptionAssociationID : subscriptionAssociations.keySet()){
            Related_Association__c subscriptionAssociation = subscriptionAssociations.get(subscriptionAssociationID);
            Map<String, String> associationDetail = associationDetails.get(subscriptionAssociationID);
            
            try{
                if (Utils.isNotNull(subscriptionAssociation.Subscription__c)) {
                    Subscriptions__c subscription = subscriptions.get(subscriptionAssociation.Subscription__c);
                    associationDetail.put('agentKey',subscription.AgentKey__c);
                    associationDetail.put('sysPrRoleID',Utils.decimalToString(subscription.PrimarySubNum__c));
                    associationDetail.put('isAgent','true');
                } else  {
                    Account brokerCodeAccount = brokerCodeAccounts.get(subscriptionAssociation.Broker_Code__c);
                    associationDetail.put('sysPrRoleID',Utils.splitByDigits(brokerCodeAccount.Name));
                    associationDetail.put('officeKey',brokerCodeAccount.officeKey__c);
                    
                }
                associationDetail.put('associationKey', associationAccounts.get(subscriptionAssociation.Association__c).officeKey__c);
            } 
            catch (Nullpointerexception npe) {}
            
            for (String roleName: roleNames)                
                roleListMappings.put(roleName,roleNameCornerstoneIds.get(roleName));
            
            String roleName = '';
            if (subscriptionAssociation.Primary__c)
                roleName = 'Association Member Primary';
            else
                roleName = 'Association Member';
       
            i++;
            relationshipMap.put(i,subscriptionAssociation);
            
            typesWebserviceQueueprocessorCrmMris.GenericRequestType grType;
            if (Boolean.valueOf(associationDetail.get('isAgent'))) {
                genericRequestTypes.add(SysPartyRoleProcessingUtility.buildCreateStruct(i,
                roleListMappings.get(roleName),associationDetail.get('associationKey'),associationDetail.get('agentKey'),associationDetail.get('sysPrRoleID'),null,null));    
            } 
            else if(Utils.isNotNull(associationDetail.get('officeKey'))) {
                genericRequestTypes.add(SysPartyRoleProcessingUtility.buildCreateStruct(i,
                roleListMappings.get(roleName),associationDetail.get('associationKey'),associationDetail.get('officeKey'),associationDetail.get('sysPrRoleID'),null,null));
            }
        }
         
        return genericRequestTypes;
            
    }
    
    
    @future (callout=true)
    global static void updateSubscriptionAssociation( Map<Id,String> newSubscriptionAssociationMap,Map<Id,String> oldSubscriptionAssociationMap) {
        Map<Integer,Related_Association__c> relationshipMap = new Map<Integer,Related_Association__c>();
        
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        genericRequestTypes = buildUpdateAssociationsStr(newSubscriptionAssociationMap,oldSubscriptionAssociationMap,relationshipMap,0); 
        
        if (genericRequestTypes == null)
          return;
        
        typesWebserviceQueueprocessorCrmMris.InputRequest ir = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        ir.command = QueueProcessorMappings.commandTypes.get('RULE21');
        ir.requests  = genericRequestTypes;
        callQP(relationshipMap,ir,false);
      
    }
    
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>  buildUpdateAssociationsStr(Map<Id,String> newSubscriptionAssociationJSONs,Map<Id,String> oldSubscriptionAssociationJSONs,
                                                                                                            Map<Integer,Related_Association__c> relationshipMap,Integer i){
      
        Map<Id,Related_Association__c> subscriptionAssociations = new Map<Id,Related_Association__c>();
        Map<Id,Set<Related_Association__c>> subscriptionIds = new Map<Id,Set<Related_Association__c>>();

        for (Id subscriptionAssociationID : newSubscriptionAssociationJSONs.keySet()){
            String newSubscriptionAssociationJSON = newSubscriptionAssociationJSONs.get(subscriptionAssociationID);
            String oldSubscriptionAssociationJSON = oldSubscriptionAssociationJSONs.get(subscriptionAssociationID);
            
            Related_Association__c newRelationshipAssociation = (Related_Association__c) System.JSON.deserialize(newSubscriptionAssociationJSON,sObject.class);
            Related_Association__c oldRelationshipAssociation = (Related_Association__c) System.JSON.deserialize(oldSubscriptionAssociationJSON,sObject.class);
            
            if ('Inactive'.equals(newRelationshipAssociation.Status__c) && (!''.equals(newRelationshipAssociation.SysPrRoleKey__c)) && (!'Inactive'.equals(oldRelationshipAssociation.Status__c))) {
                if (Utils.isNotNull(newRelationshipAssociation.Subscription__c)) {
                    if(!subscriptionIds.containsKey(newRelationshipAssociation.Subscription__c))
                        subscriptionIds.put(newRelationshipAssociation.Subscription__c, new Set<Related_Association__c>());
                
                subscriptionIds.get(newRelationshipAssociation.Subscription__c).add(newRelationshipAssociation); 
                } 
                else {
                    subscriptionAssociations.put(subscriptionAssociationID,newRelationshipAssociation);   
                }
            }            
        }
        
        for(Subscriptions__c subscription : [SELECT Id, agentKey__c,PrimarySubNum__c FROM Subscriptions__c WHERE Id IN :subscriptionIds.keyset()]){
            if (Utils.isNotNull(subscription.AgentKey__c)){
                for(Related_Association__c subscriptionAssociation : subscriptionIds.get(subscription.Id))
                    subscriptionAssociations.put(subscriptionAssociation.Id,subscriptionAssociation);
                
            }
        }
        
        if (subscriptionAssociations.keySet().size() == 0)
          return null;
        
        Map<String,String> roleListMappings = new  Map<String,String>();
        return buildUpdateAssociations(subscriptionAssociations,relationshipMap, i);      
    }
    
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>  buildUpdateAssociations(
     Map<Id,Related_Association__c> subscriptionAssociations, Map<Integer,Related_Association__c> relationshipMap,Integer i){
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Association Member Primary');
        roleNames.add('Association Member');

        List<String> subscriptionIds = new List<String>();
        List<String> brokerCodeAccountIds = new List<String>();
        List<String> associationAccountIds = new List<String>();
        
        Map<Id,Map<String,String>> associationDetails = new Map<Id,Map<String,String>>();
        
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        Map<ID,CornerstoneMappings__c> cornerstoneMappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        
        Map<String,String> roleNameCornerstoneIds = new Map<String, String>();
        for (Id cornerstoneId : cornerstoneMappings.keySet()){
            CornerstoneMappings__c cm = cornerstoneMappings.get(cornerstoneId);
            roleNameCornerstoneIds.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        for(Id subscriptionAssociationID : subscriptionAssociations.keySet()){
            Related_Association__c subscriptionAssociation = subscriptionAssociations.get(subscriptionAssociationID);
            
            Map<String,String> details = new Map<String,String>{'agentKey' => '', 
                                                                'associationKey' => '', 
                                                                'officeKey' => '', 
                                                                'sysPrRoleID' => '', 
                                                                'isAgent' => 'false'};
            associationDetails.put(subscriptionAssociation.Id,details);
            
            if(Utils.isNotNull(subscriptionAssociation.Subscription__c))
                subscriptionIds.add(subscriptionAssociation.Subscription__c);
            if(Utils.isNotNull(subscriptionAssociation.Broker_Code__c))
                brokerCodeAccountIds.add(subscriptionAssociation.Broker_Code__c);
            if(Utils.isNotNull(subscriptionAssociation.Association__c))
                associationAccountIds.add(subscriptionAssociation.Association__c);
            
        }
        
        Map<String,Subscriptions__c> subscriptions = new Map<String,Subscriptions__c>([SELECT Id, agentKey__c, PrimarySubNum__c FROM Subscriptions__c WHERE Id IN :subscriptionIds]);
        Map<String,Account> brokerCodeAccounts = new Map<String,Account>([SELECT Id, officeKey__c, Name FROM Account WHERE Id IN :brokerCodeAccountIds]);
        Map<String,Account> associationAccounts = new Map<String,Account>([SELECT Id, officeKey__c FROM Account WHERE Id IN :associationAccountIds]);
        
        for (Id subscriptionAssociationID : subscriptionAssociations.keySet()){
            Related_Association__c subscriptionAssociation = subscriptionAssociations.get(subscriptionAssociationID);
            Map<String, String> associationDetail = associationDetails.get(subscriptionAssociationID);
            
            try{
                if (Utils.isNotNull(subscriptionAssociation.Subscription__c)) {
                    Subscriptions__c subscription = subscriptions.get(subscriptionAssociation.Subscription__c);
                    associationDetail.put('agentKey',subscription.AgentKey__c);
                    associationDetail.put('isAgent','true');
                } else  {
                    Account brokerCodeAccount = brokerCodeAccounts.get(subscriptionAssociation.Broker_Code__c);
                    associationDetail.put('sysPrRoleID',Utils.splitByDigits(brokerCodeAccount.Name));
                    associationDetail.put('officeKey',brokerCodeAccount.officeKey__c);
                    
                }
                associationDetail.put('associationKey', associationAccounts.get(subscriptionAssociation.Association__c).officeKey__c);
            } 
            catch (Nullpointerexception npe) {}
                  
            i++;
            relationshipMap.put(i,subscriptionAssociation);
            
            typesWebserviceQueueprocessorCrmMris.GenericRequestType grType;
            if (Boolean.valueOf(associationDetail.get('isAgent'))) {
                genericRequestTypes.add(SysPartyRoleProcessingUtility.buildDeleteStruct(i,subscriptionAssociation.SysPrRoleKey__c,associationDetail.get('agentKey'),null));    
            } 
            else if(Utils.isNotNull(associationDetail.get('officeKey'))) {
                genericRequestTypes.add(SysPartyRoleProcessingUtility.buildDeleteStruct(i,subscriptionAssociation.SysPrRoleKey__c,associationDetail.get('officeKey'),null));
            }
        }
         
        return genericRequestTypes;
            
    }
    
    private static void callQP(Map<Integer,Related_Association__c> relationshipMap, typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest ,boolean isInsert) {
            
            QPRequest.sfdcMessageId = Utils.getRandomNumber();

            String status = 'Sent';
            String statusMessage = 'Success';
            Boolean hasFailedSFQP = false; 
            typesWebserviceQueueprocessorCrmMris.OutputResponse QPResponse;
            
            try { 
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                stub.inputHttpHeaders_x = new Map<String,String>();
                //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                QPResponse = stub.salesForceRequest(QPRequest );
                System.debug('QPResponseonse code: '+QPResponse.responseCode);
                if('FAIL'.equals(QPResponse.responseCode)) {
                    status = 'Failed';
                    statusMessage = QPResponse.responseDescription;
                }
            
            } catch (Exception ex){
                status = 'Failed';
                hasFailedSFQP = true;
                statusMessage = ex.getStackTraceString();
                System.debug(ex);
            }
            
            System.debug('QPResponse ---> ' +QPResponse);
            List<SFQPConnector__c> SFQPConnectors = new List<SFQPConnector__c>();
            List<Related_Association__c> subscriptionAssociations = new List<Related_Association__c>();
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType requestType : QPRequest.requests){
                
                SFQPConnector__c sf = new SFQPConnector__c();
                Integer sequenceNumber = Integer.valueOf(requestType.sequenceNumber);
                sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                sf.MessageSent__c = Json.serialize(requestType);
                sf.ObjectType__c = 'Related_Association__c';
                sf.SFMessageID__c = requestType.sysParty.uuid;
                sf.relatedid__c = relationshipMap.get(sequenceNumber).Id;
                if (hasFailedSFQP) {
                  sf.QPStatus__c = 'Failed-SFQP';
                } else  {
                  sf.QPStatus__c = status;
                }
                sf.QPMessage__c = statusMessage;
                SFQPConnectors.add(sf);
                
                Related_Association__c subscriptionAssociation = relationshipMap.get(sequenceNumber);
                if (isInsert) {
                  subscriptionAssociation.MDS_Status__c = status;
                  subscriptionAssociation.Start_date__c = Date.today();
                } else {
                  subscriptionAssociation.MDS_Status__c = status;
                  subscriptionAssociation.End_Date__c = Date.today();
                }
                subscriptionAssociations.add(subscriptionAssociation);
            }
            
            upsert SFQPConnectors;
            upsert subscriptionAssociations;
    }
}