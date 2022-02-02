global class ContactProcessingUtlity {
    
    // mrk (7/12/13) - methods added to check future thread state 
    //                 and prevent multiple asynchronous calls.

    global static void changePrimaryFlag(String oldSubscriptionsID, String newSubscriptionsID) {
       if (!System.isFuture()) {
          changePrimaryFlagFuture(oldSubscriptionsID,newSubscriptionsID);
       } else {
          changePrimaryFlagOrig(oldSubscriptionsID,newSubscriptionsID);
       }
    }
    @future (callout=true)
    global static void changePrimaryFlagFuture(String oldSubscriptionsID, String newSubscriptionsID) {
       changePrimaryFlagOrig(oldSubscriptionsID,newSubscriptionsID);
    }

    global static void changePrimaryFlagOrig(String oldSubscriptionsID, String newSubscriptionsID) { 
        Map<Id,Subscriptions__C> subscriptions = new Map<Id,Subscriptions__C>([SELECT Id,Primary__c,PrimarySubNum__c,AgentKey__c,
                                                                                      Related_Location_Broker_Office__r.OfficeKey__c, 
                                                                                      Related_Location_Broker_Office__c,name, contact__C 
                                                                               FROM   Subscriptions__C 
                                                                               WHERE  Id IN (:oldSubscriptionsID,:newSubscriptionsID)]);
        Map<String,String> oldRoleNames = new Map<String,String>();
        Map<String,String> roleNamesMap = new Map<String,String>();
        Map<String,Subscription_Role__c> subscriptionRoles = new Map<String,Subscription_Role__c>();
        Map<String,Subscription_Role__c> oldSubscriptionRoles = new Map<String,Subscription_Role__c>();
        
        typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        
        Subscriptions__C oldSubscription = subscriptions.get(oldSubscriptionsID);
        Subscriptions__C newSubscription = subscriptions.get(newSubscriptionsID);
        
        List <Subscription_Role__c> oldStatusSusbcriptionRoles = [SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                                                  FROM   Subscription_Role__c 
                                                                  WHERE  Subscription__c = :oldSubscription.id
                                                                  AND    Role__c in ('Status Duplicate','Status Active') 
                                                                  AND    status__c = 'Active'];    // not Status Waived
                                                       
        List <Subscription_Role__c> oldStatusDuplicateSusbcriptionRoles = [SELECT Id, Subscription__c,Subscription__r.agentKey__c, Role__c, SysPrRoleKey__c
                                                                           FROM   Subscription_Role__c 
                                                                           WHERE  Subscription__r.contact__c = :oldSubscription.contact__c
                                                                           AND    Role__c in ('Status Duplicate') 
                                                                           AND    status__c = 'Active' 
                                                                           AND    Subscription__c NOT IN (:oldSubscription.id,:newsubscription.id)];    // not Status Waived
        
        System.debug('oldStatusSusbcriptionRoles ----> ' + oldStatusSusbcriptionRoles);                                                 
        for (Subscription_Role__c oldStatusRole : oldStatusSusbcriptionRoles) {
            System.debug('Old Status Role 1---> ' + oldStatusRole.Role__c);
            oldRoleNames.put(oldStatusRole.Role__c, oldStatusRole.SysPrRoleKey__c);
            oldStatusRole.Status__c = 'Inactive';
            oldStatusRole.Role_End_Date__c = Date.today();
            oldSubscriptionRoles.put(oldStatusRole.Role__c, oldStatusRole);
        }
         
        oldStatusSusbcriptionRoles = [SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                      FROM   Subscription_Role__c 
                                      WHERE  Subscription__c = :newsubscription.id
                                      AND    Role__c IN ('Status Duplicate','Status Active') 
                                      AND status__c = 'Active'];    // not Status Waived
                                      
        for (Subscription_Role__c oldStatusRole : oldStatusSusbcriptionRoles) {
            System.debug('Old Status Role 2---> ' + oldStatusRole.Role__c);
            oldRoleNames.put(oldStatusRole.Role__c, oldStatusRole.SysPrRoleKey__c);
            oldStatusRole.Status__c = 'Inactive';
            oldStatusRole.Role_End_Date__c = Date.today();
            oldSubscriptionRoles.put(oldStatusRole.Role__c, oldStatusRole);
        }
                
        Subscription_Role__c statusRole = new Subscription_Role__c();
        statusRole.Role__c = 'Status Active';
        roleNamesMap.put('Status Active', newSubscription.Related_Location_Broker_Office__r.OfficeKey__c);
        
        statusRole.Status__c = 'Active';
        statusRole.Subscription__c = newSubscription.id;
        statusRole.Role_Start_Date__c = Date.today();
        subscriptionRoles.put(statusRole.Role__c, statusRole);
        
        Subscription_Role__c statusRole1 = new Subscription_Role__c();
        statusRole1.Role__c = 'Status Duplicate';
        roleNamesMap.put('Status Duplicate', (newSubscription.agentKey__c));
        statusRole1.Status__c = 'Active';
        statusRole1.Subscription__c = oldSubscription.id;
        statusRole1.Role_Start_Date__c = Date.today();
        subscriptionRoles.put(statusRole1.Role__c, statusRole1);
        
        System.debug('subscriptionRoles --->' + subscriptionRoles);
        System.debug('newRoleMap ---> ' + roleNamesMap);
        System.debug('oldRoleNames ---> ' + oldRoleNames);
        
        Set<String> roleNames = new Set<String>();
        roleNames.addall(roleNamesMap.keySet());
        roleNames.addall(oldRoleNames.keySet());
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
        
        Integer i = 0;        
       
        for (String s: roleNamesMap.keySet()) {

            i = genericRequestTypes.size() + 1;
            String sysPrRoleID;
            Map<String,String> newMap = new Map<String,String>();
            Map<String,String> newRoleListMappings = new Map<String,String>();
            newRoleListMappings.put(s,roleListMappings.get(s));
            newMap.put(s,roleNamesMap.get(s));
            
            System.debug('newMap ---> ' + newMap);
            System.debug('newRoleListMappings ---> ' + newRoleListMappings);
            if ('Status Duplicate'.equals(s)) {
                sysPrRoleID = Utils.decimalToString(oldsubscription.PrimarySubNum__c);
                genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(newMap,mappings,roleListMappings,oldsubscription.AgentKey__c,sysPrRoleID,i));
            } 
            else {
                sysPrRoleID = Utils.decimalToString(newsubscription.PrimarySubNum__c);
                genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(newMap,mappings,roleListMappings,newsubscription.AgentKey__c,sysPrRoleID,i));
            }
        }
       
        i = genericRequestTypes.size() + 1;
        genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNames,oldSubscription.AgentKey__c,oldSubscription.Related_Location_Broker_Office__r.OfficeKey__c,i));
        System.debug('genericRequestTypes.size()---->' + genericRequestTypes.size());
       
        Map<String, Subscription_Role__c> duplicateSubscriptionRoles = new Map<String,Subscription_Role__c>();
        List<Subscription_Role__c> dupdelSubRoles = new List<Subscription_Role__c>();
        
        for (Subscription_Role__c subscriptionRole : oldStatusDuplicateSusbcriptionRoles) {
            Subscriptions__c subscription = [SELECT Id,Primary__C,PrimarySubNum__c,AgentKey__c,Related_Location_Broker_Office__r.OfficeKey__c, 
                                                    Related_Location_Broker_Office__c,name, contact__C 
                                             FROM   Subscriptions__C 
                                             WHERE  Id = :subscriptionRole.Subscription__c limit 1];
            String s = rolenamesMap.get('Status Duplicate');

            subscriptionRole.Status__c = 'Inactive';
            subscriptionRole.Role_End_Date__c = Date.today();
            dupdelSubRoles.add(subscriptionRole); 
            
            Map<String,String> oldRoleNames1 = new Map<String,String>();
            oldRoleNames1.put('Status Duplicate',subscriptionRole.SysPrRoleKey__c);
            
            i = genericRequestTypes.size() + 1;
            genericRequestTypes.add(SysPartyRoleProcessingUtility.buildDeleteStruct(i,subscriptionRole.SysPrRoleKey__c,
                                                                       oldSubscription.Related_Location_Broker_Office__r.OfficeKey__c,
                                                                       oldSubscription.Related_Location_Broker_Office__r.OfficeKey__c));

            String sysPrRoleID = Utils.decimalToString(subscription.PrimarySubNum__c);
            i = genericRequestTypes.size() + 1;
            
            Map<String,String> newMap1 = new Map<String,String>();
            Map<String,String> newRoleListMappings1 = new Map<String,String>();
            newRoleListMappings1.put(s,roleListMappings.get(s));
            newMap1.put('Status Duplicate',roleNamesMap.get(s));
            System.debug('newMap ---> ' + newMap1);
            System.debug('newRoleListMappings ---> ' + newRoleListMappings1);

            typesWebserviceQueueprocessorCrmMris.GenericRequestType gt = SysPartyRoleProcessingUtility.buildCreateStruct(i,
                                                    '50000016003',
                                                    newsubscription.agentKey__c,
                                                    subscriptionRole.Subscription__r.agentKey__c,
                                                    sysPrRoleID,
                                                    null,
                                                    null);
            genericRequestTypes.add(gt);
                                                
            Subscription_Role__c statusRole2 = new Subscription_Role__c();
            statusRole2.Role__c = 'Status Duplicate';
            statusRole2.Status__c = 'Active';
            statusRole2.Subscription__c = subscriptionRole.subscription__c;
            statusRole2.Role_Start_Date__c = Date.today();
            String unID  = (String) gt.sysParty.uuid;
            duplicateSubscriptionRoles.put(unID,statusRole2);

        }
        System.debug('duplicateSubscriptionRoles ---->  ' + duplicateSubscriptionRoles);
        System.debug('dupdelSubRoles ---->  ' + dupdelSubRoles);
        QPRequest.command = QueueProcessorMappings.CommandTypes.get('RULE30');
        if (Utils.isNull(QPRequest.command)) {
            System.debug ('No command; Exiting -----');
            return;
        }
     
        //Call QP and insert the messages 
        QPRequest.requests  = genericRequestTypes;
        QPRequest.sfdcMessageId = Utils.getRandomNumber();
        System.debug('QPRequest ---> ' + QPRequest);
        String status = 'Sent';
        String statusMessage = 'Success';
        typesWebserviceQueueprocessorCrmMris.OutputResponse QPResponse;
        boolean hasFailedSFQP = false;
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
            statusMessage = ex.getStackTraceString();
            hasFailedSFQP = true;
            System.debug(ex);
        }
        System.debug('QPResponse ---> ' + QPResponse);
        if(!status.equals('Failed')) {
            upsert subscriptionRoles.values();
            upsert oldSubscriptionRoles.values();
            upsert dupdelSubRoles;
            upsert duplicateSubscriptionRoles.values();            
        }
        
        System.debug('subscriptionRoles.values ---> ' + subscriptionRoles.values());
        List<SFQPConnector__c> SFQPConnectors = new List<SFQPConnector__c>();
        for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : genericRequestTypes){
            SFQPConnector__c sf = new SFQPConnector__c();
            sf.MessageSent__c = Json.serialize(gt);
            sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
            System.debug('sf.MessageSent__c ----> ' + sf.MessageSent__c);
            System.debug('gt.sysParty.sysPrKey ----> ' + gt.sysParty.sysPrKey);
            System.debug('gt.sysParty.sysPRRoleKey ----> ' + gt.sysParty.sysPRRoleKey);
            
            if(gt.sysParty.sysPrKey != null) {
                for(String rType : oldRoleNames.keySet()){
                    System.debug('rType---->' + rType);
                    System.debug('rType.get---->' + oldRoleNames.get(rType));
                    if(gt.sysParty.sysPrKey.equals(oldRoleNames.get(rType))){
                        sf.ObjectType__c = 'Subscription_Role__c';
                        sf.SFMessageID__c = gt.sysParty.uuid;
                        sf.relatedid__c = oldSubscriptionRoles.get(rType).id;
                    }
                    if(sf.ObjectType__c == null)
                        System.debug('No SFQPConnector created for gt: ' + gt);
                }
            } 
            else {
                for(String roleType : roleNamesMap.keySet()) {
                    System.debug('roleType---->' + roleType);
                    if(roleListMappings.get(roleType) != null  &&
                    gt.sysParty.sysPRRoleKey != null && 
                    gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(roleType))) {
                        sf.ObjectType__c = 'Subscription_Role__c';
                        sf.SFMessageID__c = gt.sysParty.uuid;
                        sf.relatedid__c = subscriptionRoles.get(roleType).id;
                    }
                }

                System.debug('gt.sysParty.uuid----->' + gt.sysParty.uuid);
                if (duplicateSubscriptionRoles.get(gt.sysParty.uuid) != null) {
                    System.debug('gt.sysParty.uuid---->' + gt.sysParty.uuid);
                    sf.ObjectType__c = 'Subscription_Role__c';
                    sf.SFMessageID__c = gt.sysParty.uuid;
                    sf.relatedid__c = duplicateSubscriptionRoles.get(gt.sysParty.uuid).id;
                }
            }
            if (hasFailedSFQP)
                sf.QPStatus__c = 'Failed-SFQP';
            else
                sf.QPStatus__c = status;
            
            sf.QPMessage__c = statusMessage;
            SFQPConnectors.add(sf);
        } //End of For loop
        
        System.debug('SFQPConnectors---->' + SFQPConnectors);
        List<SFQPConnector__c> newSFQPConnectors = new List<SFQPConnector__c>();
        for (SFQPConnector__c sfConnector : SFQPConnectors) {
            if (sfConnector.relatedid__C != null)
                newSFQPConnectors.add(sfConnector);
        }
        upsert newSFQPConnectors;                                               
    }
}