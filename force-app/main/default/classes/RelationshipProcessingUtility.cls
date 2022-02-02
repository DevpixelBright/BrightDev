global without sharing class RelationshipProcessingUtility {
    
    private static List<Relationship__c> finalRelationships;
    private static List<SFQPConnector__c> finalSFQPConnector;

    
    @future (callout=true)
    global static void createRelationship(Map<Id,String> relationshipJSONs) {
        System.debug('Entered Callout');
        
        Map<String,Relationship__c> relationships = new Map<String,Relationship__c>();
        finalRelationships = new List<Relationship__c>();
        finalSFQPConnector = new List<SFQPConnector__c>();
        
        List<String> brokerOfficeIds = new List<String>();
        List<String> subscriptionIds = new List<String>();
        
        for (Id relationshipId : relationshipJSONs.keySet()) {
            String relationshipJSON = relationshipJSONs.get(relationshipId);           
            Relationship__c relationship = (Relationship__c)System.JSON.deserialize(relationshipJSON, sObject.class);
            relationships.put(relationship.Id,relationship);
            
            if(String.isNotBlank(relationship.Broker_Office__c))
                brokerOfficeIds.add(relationship.Broker_Office__c);
            
            if(String.isNotBlank(relationship.Subscription__c))         
                subscriptionIds.add(relationship.Subscription__c);
        }
        
        Map<Id, Account> brokerOfficeAccounts = new Map<Id, Account>([SELECT Id, OfficeKey__c, Company_Type__c 
                                                                      FROM   Account 
                                                                      WHERE  Id = :brokerOfficeIds 
                                                                      AND OfficeKey__c != null]);        
        
        Map<Id, Subscriptions__c> subscriptions = new Map<Id, Subscriptions__c>([SELECT Id, agentKey__c, Status__C 
                                                                                 FROM   Subscriptions__C 
                                                                                 WHERE  Id = :subscriptionIds AND agentKey__c != null]);     
        
        List<Relationship__c> updatedRelationships = new List<Relationship__c>();
        for (Id relationshipId : relationships.keySet()) {
            
            Relationship__c relationship = relationships.get(relationshipId);
            
            try {
                Account brokerOffice = brokerOfficeAccounts.get(relationship.Broker_Office__c);                           
                Subscriptions__c subscription = subscriptions.get(relationship.Subscription__c);
                                       
                if ('Broker Of Record'.equals(relationship.Relationship_Type__c)) {
                    
                    if ('Corporate Office'.equals(brokerOffice.Company_Type__c)) {                        
                        createCompanyRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id);
                    } 
                    else
                       createBrokerOfRecordRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id);                   
                } 
                else if ('Broker Office'.equals(relationship.Relationship_Type__c))
                    createBrokerRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id);
                else if('Office Manager'.equals(relationship.Relationship_Type__c))
                    createOfficeManagerRelationship(brokerOffice.id, subscription.id, brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id);
                else if('Authorized Signer'.equals(relationship.Relationship_Type__c))
                    createAuthSignerRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id,true);
                else
                    createRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.Relationship_Type__c,relationship.id,true,0);               
            } 
            catch (Exception qe){
                
            }
            
            relationship.Status__c = 'Active';
            if (null == relationship.Relationship_Start_Date__c) 
                relationship.Relationship_Start_Date__c = DateTime.now();
            
            updatedRelationships.add(relationship);
            
        }
        
        upsert finalSFQPConnector;
        upsert finalRelationships;
       
        upsert updatedRelationships;
    }
  
    @future (callout=true)
    global static void deleteRelationship(Map<Id, String> oldRelationshipJSONs) {
        //Process each relationship
             
        Map<String,Relationship__c> relationships = new Map<String,Relationship__c>();        
        List<String> brokerOfficeIds = new List<String>();
        List<String> subscriptionIds = new List<String>();
        
        finalRelationships = new List<Relationship__c>();
        finalSFQPConnector = new List<SFQPConnector__c>();

        for (Id relationshipId : oldRelationshipJSONs.keySet()) {
            String relationshipJSON = oldRelationshipJSONs.get(relationshipId);           
            Relationship__c relationship = (Relationship__c)System.JSON.deserialize(relationshipJSON, sObject.class);
            relationships.put(relationship.Id,relationship);
            
            if(String.isNotBlank(relationship.Broker_Office__c))
                brokerOfficeIds.add(relationship.Broker_Office__c);
            
            if(String.isNotBlank(relationship.Subscription__c))         
                subscriptionIds.add(relationship.Subscription__c);
        }
        
        Map<Id, Account> brokerOfficeAccounts = new Map<Id, Account>([SELECT Id, OfficeKey__c, Company_Type__c 
                                                                      FROM   Account 
                                                                      WHERE  Id = :brokerOfficeIds 
                                                                      AND OfficeKey__c != null]);        
        
        Map<Id, Subscriptions__c> subscriptions = new Map<Id, Subscriptions__c>([SELECT Id, agentKey__c, Status__C 
                                                                                 FROM   Subscriptions__C 
                                                                                 WHERE  Id = :subscriptionIds AND agentKey__c != null]);


        for (Id relationshipId : relationships.keySet()) {
            
            Relationship__c relationship = relationships.get(relationshipId);
            
            try {
                Account brokerOffice = brokerOfficeAccounts.get(relationship.Broker_Office__c);                           
                Subscriptions__c subscription = subscriptions.get(relationship.Subscription__c);
            
                if('Office Manager'.equals(relationship.Relationship_Type__c))
                    deleteOfficeManagerRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.sysPrRoleKey__c,relationship.id);
                else  if('Authorized Signer'.equals(relationship.Relationship_Type__c)) 
                    deleteAuthorizedSignerRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.sysPrRoleKey__c,relationship.id);
                else 
                    deleteRelationship(brokerOffice.id,subscription.id,brokerOffice.OfficeKey__c,subscription.AgentKey__c,relationship.sysPrRoleKey__c,relationship.id, relationship.Relationship_Type__c);
    
            } 
            catch (Exception qe){
                system.debug('*** Exception: ' + qe.getStackTraceString());
            }
        }
        
        upsert finalSFQPConnector;
        upsert finalRelationships;
    }
    
    private static void createBrokerRelationship(String officeID, String agentID, String officeKey, String agentKey, String typeName,String relationshipId){
       
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE6');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Broker Office');
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
          
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        String parentKey = null;
        String sysrole = '' + [SELECT PrimarySubNum__c FROM Subscriptions__c WHERE Id = :agentID LIMIT 1].PrimarySubNum__c;
        
        Integer i = 1;
        Map<String,String> roleNamesMap = new Map<String,String>();
        roleNamesMap.put(typeName,parentKey);
        
        Relationship__c relationship = [SELECT id, relationship_start_date__c from Relationship__c where id=:relationshipId limit 1];
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,agentKey,sysrole,i,relationship.Relationship_Start_Date__c));
        QPRequest.requests  = genericRequestTypes;
        
        Map<String, String> relationshipIds = new Map<String,String>();
        relationShipIds.put(roleListMappings.get('Broker Office'), relationshipId);
         //Call QP and insert the messages             
        callQP(officeID,  agentID,  officeKey, agentKey,  typeName, relationshipIds, QPRequest, true);                
    }
    
    private static void createCompanyRelationship(String officeID, String agentID, String officeKey,String agentKey, String typeName,String relationshipId){
        typeName = 'Company Office';
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE10');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Company Office');
        
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
    
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
    
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
    
        String parentKey = [SELECT OfficeKey__c FROM Account WHERE id = :officeID limit 1].OfficeKey__c;
        String sAccID = [SELECT Related_Location_Broker_Office__c FROM Subscriptions__c WHERE agentKey__c = :agentKey limit 1].Related_Location_Broker_Office__c;
        Account ac  =   [SELECT Name, OfficeKey__c FROM Account WHERE Id = :sAccID LIMIT 1];
        String sysrole = Utils.splitByDigits(ac.Name);
    
        Integer i = 1;
        Map<String,String> roleNamesMap = new Map<String,String>();
        roleNamesMap.put(typeName,parentKey);
        Relationship__c rel = [SELECT id, relationship_start_date__c FROM Relationship__c WHERE id=:relationshipId limit 1];
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,ac.OfficeKey__c,sysrole,i,rel.Relationship_Start_Date__c));
        QPRequest.requests  = genericRequestTypes;
        
        Map<String, String> relationshipIds = new Map<String,String>();
        relationShipIds.put(roleListMappings.get('Company Office'), relationshipId);
        //Call QP and insert the messages 
        callQP(officeID,  agentID,  officeKey, agentKey, typeName, relationshipIds, QPRequest, true);
                
    }
    
    private static void createBrokerOfRecordRelationship(String officeID, String agentID, String officeKey, String agentKey, String typeName, String relationshipId) {
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE6');
         
        Set<String> roleNames = new Set<String>();
        roleNames.add('Broker Of Record');
        boolean createBrokerRelationship = false;
        try {
            Relationship__C relationship = [SELECT id from Relationship__C where Broker_Office__c = :officeID and Relationship_Type__c = 'Broker Office' and Relationship_End_Date__c = null LIMIT 1];   
        } 
        catch (Queryexception ex){
             roleNames.add('Broker Office');
             createBrokerRelationship = true;            
        }        
        
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        String parentKey = officeKey;
        String sysrole = '' + [SELECT PrimarySubNum__c FROM Subscriptions__c WHERE Id = :agentID LIMIT 1].PrimarySubNum__c;
        
        Integer i = 1;
        Map<String,String> roleNamesMap = new Map<String,String>();
      
        System.debug('TypeName ----> ' + typeName);
        roleNamesMap.put(typeName,parentKey);
        Relationship__c relationship = [SELECT id, relationship_start_date__c from Relationship__c where id=:relationshipId limit 1];
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,agentKey,sysrole,i,relationship.relationship_start_date__c));
        QPRequest.requests  = genericRequestTypes;
        
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get('Broker Of Record'), relationshipId);
       
        callQP(officeID,  agentID,  officeKey, agentKey,  typeName, relationshipIds,QPRequest,true);
    }
   
    
    private static void createOfficeManagerRelationship(String officeID, String agentID, String officeKey, String agentKey, String typeName,String relationshipId){
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE8');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Office Manager');
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        String parentKey = officeKey;
        String sysrole = '' + [SELECT PrimarySubNum__c FROM Subscriptions__c WHERE Id = :agentID LIMIT 1].PrimarySubNum__c;
        
        Integer i = 1;
        Map<String,String> roleNamesMap = new Map<String,String>();
        roleNamesMap.put(typeName,parentKey);
        Relationship__c rel = [SELECT id, relationship_start_date__c from Relationship__c where id=:relationshipId limit 1];
        
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,agentKey,sysrole,i,rel.Relationship_Start_Date__c));
        
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get('Office Manager'), relationshipId);
        QPRequest.requests  = genericRequestTypes;
         //Call QP and insert the messages 
        callQP(officeID,  agentID,  officeKey, agentKey,  typeName, relationshipIds, QPRequest, true);
                
    }   
    
    private static void deleteOfficeManagerRelationship(String oldOfficeID, String agentID, String oldOfficeKey, String agentKey, String sysPRRole,String relationshipId){
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE14');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Office Manager');
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        Map<String,String> oldRoleNamesMap = new Map<String,String>();
        oldRoleNamesMap.put('Office Manager',sysPRRole);
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap,agentKey,oldOfficeKey, 1));
        QPRequest.requests  = genericRequestTypes;
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get('Office Manager'), relationshipId);
        
         //Call QP and insert the messages 
        callQP(oldOfficeID,  agentID,  oldOfficeKey, agentKey,  'Office Manager', relationshipIds, QPRequest, false);
                
    }
    
     private static void deleteAuthorizedSignerRelationship(String oldOfficeID, String agentID, String oldOfficeKey, String agentKey, String sysPRRole,String relationshipId){
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE27');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Authorized Signer');
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        Map<String,String> oldRoleNamesMap = new Map<String,String>();
        oldRoleNamesMap.put('Authorized Signer',sysPRRole);
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap,agentKey,oldOfficeKey, 1));
        QPRequest.requests  = genericRequestTypes;
        Map<String, String> relationshipIds = new Map<String, String>();        
        relationshipIds.put(roleListMappings.get('Authorized Signer'), relationshipId);
        
         //Call QP and insert the messages 
        callQP(oldOfficeID,  agentID,  oldOfficeKey, agentKey, 'Authorized Signer', relationshipIds, QPRequest, false);
                
    }
    
    public static typesWebserviceQueueprocessorCrmMris.GenericRequestType  deleteRelationship1(String oldOfficeKey, String agentKey, String sysPRRole,String relationshipId,String typeName, Integer i){
                
               
        typesWebserviceQueueprocessorCrmMris.GenericRequestType  genericRequestTypes  = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
      
        Set<String> roleNames = new Set<String>();
        roleNames.add(typeName);
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId: mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        Map<String,String> oldRoleNamesMap = new Map<String,String>();
        oldRoleNamesMap.put('Authorized Signer',sysPRRole);
        genericRequestTypes = SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap,agentKey,oldOfficeKey, i).get(0);
        
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get(typeName), relationshipId);
        
        return genericRequestTypes;
                
    }
    
    private static void deleteRelationship(String oldOfficeID, String agentID, String oldOfficeKey, String agentKey, String sysPRRole,String relationshipId,String typeName){
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE27');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add(typeName);
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        Map<String,String> oldRoleNamesMap = new Map<String,String>();
        oldRoleNamesMap.put(typeName,sysPRRole);
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap,agentKey,oldOfficeKey, 1));
        QPRequest.requests  = genericRequestTypes;
        
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get(typeName), relationshipId);
        
        //Call QP and insert the messages 
        callQP(oldOfficeID,  agentID,  oldOfficeKey, agentKey,  typeName, relationshipIds,QPRequest,false);
                
    }
    
    public static void createAuthSignerRelationship(String officeID, String agentID, String officeKey, String agentKey, String typeName,String relationshipId, boolean callQP){
                
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE9');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add('Authorized Signer');
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        String parentKey = officeKey;
        String sysrole = '' + [SELECT PrimarySubNum__c FROM Subscriptions__c WHERE Id = :agentID LIMIT 1].PrimarySubNum__c;
        
        Integer i = 1;
        Map<String,String> roleNamesMap = new Map<String,String>();
        roleNamesMap.put(typeName,parentKey);
        Relationship__c rel = [SELECT id, relationship_start_date__c from Relationship__c where id=:relationshipId limit 1];
        
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,agentKey,sysrole,i,rel.Relationship_Start_Date__c));
        QPRequest.requests  = genericRequestTypes;
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get('Authorized Signer'), relationshipId);
        
        //Call QP and insert the messages 
         if (callQP)
            callQP(officeID,  agentID,  officeKey, agentKey, typeName, relationshipIds, QPRequest, true);
                
    }
    
     public static typesWebserviceQueueprocessorCrmMris.GenericRequestType createRelationship(String officeID, String agentID, String officeKey,
            String agentKey, String typeName,String relationshipId,Boolean callQP, Integer pos){        
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE9');
        
        Set<String> roleNames = new Set<String>();
        roleNames.add(typeName);
        Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
        Map<String,String> tempRoleListMappings = new Map<String,String>();
        Map<String,String> roleListMappings = new Map<String,String>();  
            
        for (Id cornerstoneId : mappings.keySet()){
            CornerstoneMappings__c cm = mappings.get(cornerstoneId);
            tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
        }
        
        //Swap the maps to get the correct order
        for (String roleName : roleNames){
            System.debug('roleName ---> ' + roleName);
            System.debug('tempRoleListMappings.get(roleName) ---> ' + tempRoleListMappings.get(roleName));
            roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
        }
        
        String parentKey = officeKey;
        String sysrole='';
         if(typeName=='Business Authority')
         {sysrole = '' + [SELECT Subscription_Office__c from Relationship__c where id=:relationshipId limit 1].Subscription_Office__c;}
           else{
           sysrole = '' + [SELECT PrimarySubNum__c FROM Subscriptions__c WHERE Id = :agentID LIMIT 1].PrimarySubNum__c;
          }
        System.debug('sysrole ---> ' + sysrole);
        Integer i = 0;
        if (callQP)
            i = 1;
        else
            i = pos;
        
        Map<String,String> roleNamesMap = new Map<String,String>();
        roleNamesMap.put(typeName,parentKey);
        Relationship__c rel = [SELECT id, relationship_start_date__c from Relationship__c where id=:relationshipId limit 1];
        
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,agentKey,sysrole,i,rel.Relationship_Start_Date__c));
        QPRequest.requests  = genericRequestTypes;
        Map<String, String> relationshipIds = new Map<String, String>();
        relationshipIds.put(roleListMappings.get(typeName), relationshipId);
        System.debug('***'+'officeID: '+officeID+' agentID: '+agentID+' officeKey:'+officeKey + ' agentKey:'+ agentKey+' typeName:'+typeName);
        //Call QP and insert the messages 
        if (callQP)
          callQP(officeID,  agentID,  officeKey, agentKey,  typeName, relationshipIds, QPRequest, true);
         
         return genericRequestTypes.get(0);
                
    }
    
    
    private static void callQP(String officeID, String agentID, String officeKey,
            String agentKey, String typeName,Map<String, String> relationshipIds
            ,typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest, Boolean isInsert) {
          
        QPRequest.sfdcMessageId = Utils.getRandomNumber();
        System.debug('QPRequest ---> ' + QPRequest);
        String status = 'Sent';
        String statusMessage = 'Success';
        boolean hasFailedSFQP = false;
        typesWebserviceQueueprocessorCrmMris.OutputResponse QPResponse;
        System.debug('00011');
        try {
            webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
            stub.inputHttpHeaders_x = new Map<String,String>();
            //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
            stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
            stub.endpoint_x = Label.MRIS_QP_URL;
           
            QPResponse = stub.salesForceRequest(QPRequest);
            System.debug('response code: '+QPResponse.responseCode);
            if('FAIL'.equals(QPResponse.responseCode)) {
                status = 'Failed';
                statusMessage = QPResponse.responseDescription;
            }
        
        } 
        catch (Exception ex) {
            status = 'Failed';
            hasFailedSFQP = true;
            statusMessage = ex.getStackTraceString();
            System.debug(ex);
        }
        
        System.debug('QPResponse ---> ' +QPResponse);
        List<SFQPConnector__c> sfconnectorList = new List<SFQPConnector__c>();
        for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : QPRequest.requests){
            SFQPConnector__c sf = new SFQPConnector__c();
            sf.MessageSent__c = Json.serialize(gt);
            /*if ((!'DELETE'.equals(gt.sysParty.action)) && 
                    (relationshipIds.get(gt.sysParty.sysPRRoleKey) == null)) {
                //Only for BrokerOffice 
                Relationship__C brokerOfficeRelationship = new Relationship__C();
                brokerOfficeRelationship.Relationship_Type__c ='Broker Office';
                brokerOfficeRelationship.Broker_Office__c = officeID;
                brokerOfficeRelationship.Relationship_Start_Date__c = Date.today();
                brokerOfficeRelationship.Created_Source__c = 'QP';
                insert  brokerOfficeRelationship;
                relationshipIds.put(gt.sysParty.sysPRRoleKey, brokerOfficeRelationship.id);
            }*/
            sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
            sf.ObjectType__c = 'Relationship__c';
            sf.SFMessageID__c = gt.sysParty.uuid;
            sf.relatedid__c = relationshipIds.get(gt.sysParty.sysPRRoleKey);
            
            if (hasFailedSFQP)
                sf.QPStatus__c = 'Failed-SFQP';
            else
                sf.QPStatus__c = status;
            
            sf.QPMessage__c = statusMessage;
            //upsert sf;
            finalSFQPConnector.add(sf);
            
            String relid;
            for (String s12 : relationshipIds.keySet()) {
                relid = relationshipIds.get(s12);
            }
            
            Relationship__c r = [SELECT id,MDS_Status__c,Status__c ,Relationship_Start_Date__C,Relationship_End_Date__C from Relationship__c where id=:relid limit 1];
            if (isInsert) {
                r.MDS_Status__C = status;
                r.Status__c = 'Active';
                
                if (null == r.Relationship_Start_Date__c)
                    r.Relationship_Start_Date__C = DateTime.now();
            } 
            else 
                r.Relationship_End_Date__C = Date.today();
            
            //upsert r;
            finalRelationships.add(r);
            System.debug( 'r -----> ' + r);
        }
    }   
}