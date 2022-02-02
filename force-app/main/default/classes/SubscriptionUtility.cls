/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return the subscription and contact information based on the license information.  
* If no license information is found, the salesforce returns a empty return structure
**/
global without sharing class SubscriptionUtility {

    /**
    *  The various subscription types, subscription role types, and cornerstone mappings
    *  are not at all one-to-one mappings.  There are variances in spelling and punctuation,
    *  and there are other minor differences.  As such, hash maps need to be created to
    *  make everything work out.
    **/
    public static String nullString = '0x00';
    public static Map<String, String> type2Role = new Map<String, String>();
    static {
        type2Role.put('Association Staff', 'Assoc Staff');
        type2Role.put('Broker Staff', 'Broker  Staff');
        type2Role.put('Personal Assistant', 'Personal Asst');
        type2Role.put('Personal Assistant to Appraiser', 'Personal Asst to Appraiser');
        type2Role.put('Licensed Appraiser/Non Realtor', 'Licensed Appraiser');
        type2Role.put('Licensee/Non Realtor', 'Licensee/Non-Realtor');
        type2Role.put('Government Agency', 'Govt Agency');
        type2Role.put('Government Agency - N/C', 'Govt Agency N/C');
        type2Role.put('Non-Subscribing Manager', 'Non Subscriber Mgr');
        type2Role.put('VT Vendor', 'Virtual Tour');
        type2Role.put('CURE', 'CURE Administrator');
        type2Role.put('MDS', 'MDS User Login');
        type2Role.put('RETS', 'RETS Customer');
        type2Role.put('RETS/MDS', 'RETS Advanced');
        type2Role.put('Office Secretary - NC', 'Office Secretary NC');
        type2Role.put('Realtor/Appraiser Non Shareholder', 'Realtor Appraiser/Non-Shareholder');
        type2Role.put('Realtor/Appraiser Shareholder', 'Realtor Appraiser/Shareholder');
        type2Role.put('Realtor/Non Shareholder', 'Realtor/NonShareholder');
    }
    
    public static Map<String, String> role2Mapping = new Map<String, String>();
    static {
        role2Mapping.put('Personal Asst', 'Personal Assistant');
        role2Mapping.put('Broker  Staff', 'Broker Staff');
        role2Mapping.put('Govt Agency', 'Government Agency');
        role2Mapping.put('Govt Agency N/C', 'Government Agency - N/C');
        role2Mapping.put('Licensed Appraiser', 'Licensed Appraiser/Non Realtor');
        role2Mapping.put('System MRIS', 'System-MRIS');
        role2Mapping.put('Appraiser/Shareholder', 'Realtor/Appraiser Shareholder');
        role2Mapping.put('Appraiser/Non-shareholder', 'Realtor/Appraiser Non Shareholder');
        role2Mapping.put('Personal Asst', 'Personal Assistant');
        role2Mapping.put('Personal Asst to Appraiser', 'Personal Assistant to Appraiser');
        role2Mapping.put('Realtor/NonShareholder', 'Realtor/Non Shareholder');
        role2Mapping.put('Broker of Record', 'Broker Of Record');
        role2Mapping.put('Non Subscriber Mgr', 'Non-Subscribing Manager');
        role2Mapping.put('Assoc Staff', 'Association Staff');
        role2Mapping.put('CIE 360 member', 'CIE360 Member');
        role2Mapping.put('Realtor Appraiser/Non-Shareholder', 'Realtor/Appraiser Non Shareholder');
        role2Mapping.put('Realtor Appraiser/Shareholder', 'Realtor/Appraiser Shareholder');
        role2Mapping.put('Licensee/Non-Realtor', 'Licensee/Non Realtor');
        role2Mapping.put('Virtual Tour', 'Virtual Tour Vendor');
        role2Mapping.put('Office Secretary NC', 'Office Secretary - NC');
        role2Mapping.put('Agent Tool V2', 'Agent Toolv2');
        role2Mapping.put('IDX Plus','IDX PLUS');
        role2Mapping.put('HDB.com','HDB.COM');
        role2Mapping.put('HometownAnnapolis.comV2','HOMETOWNANNAPOLIS.COMv2');
        role2Mapping.put('Broker Backofficev2', 'Broker Back Officev2');
        role2Mapping.put('Disable_MRIS_RETS_Functionality_Extensions','DISABLE_MRIS_RETS_FUNCTIONALITY_EXTENSIONS');
        role2Mapping.put('Ignore Localization Names', 'Ignore Localized Names');
        role2Mapping.put('INTERNATIONAL LISTING ADVERTISING EXCHANGE', 'INTERNATIONAL LISTING ADVERTISING                     EXCHANGE');
        role2Mapping.put('International newer listing newer advertising newer exchange', 'INTERNATIONAL LISTING ADVERTISING                     EXCHANGE');
        role2Mapping.put('Metadata Display MRIS Extension', 'Metadata Display MRIS Extensions');
        role2Mapping.put('National Advertising - AGGREGATOR - Homes.Com', 'National Advertising - AGGREGATOR                     - Homes.Com');
        role2Mapping.put('National Advertising - AGGREGATOR - Realtor.Com', 'National Advertising - AGGREGATOR                     - Realtor.Com');
        role2Mapping.put('Non-MLS', 'Non MLS');
        role2Mapping.put('Ocean Data', 'Ocean Data Sharing');
        role2Mapping.put('Other Committee Members', 'Other/Committee Members');
        role2Mapping.put('Patuxent Publishing - Newspaper Advertising', 'Patuxent Publishing - Newspaper                     Advertising');
        role2Mapping.put('Pulse Research, Inc. - Newspaper Advertising', 'Pulse Research, Inc. - Newspaper                     Advertising');
        role2Mapping.put('REALTORS  Property Resource', 'REALTORS PROPERTY RESOURCE');
        role2Mapping.put('Restricted Text', 'Restrict Tax');
        role2Mapping.put('Staged Object', 'STAGED_OBJECT');
        role2Mapping.put('property_history','PROPERTY_HISTORY');
        role2Mapping.put('Tax Historical Designation', 'TAX_HISTORICAL_DESIGNATION');
        role2Mapping.put('Term Disconnect', 'Term/Disconnect');
        role2Mapping.put('VAR - Housing - VA', 'VAR - Housing VA');
        role2Mapping.put('View Staged Object', 'ViewStagedObject');
        role2Mapping.put('WildFyre', 'WyldFyre');
    }


    /**
    *  This is a delegator method for processing the action and based on the action 
    *  call appropriate service method to send the information to salesforce
    *
    *  mrk (7/12/13) - methods added to check future thread state 
    *  and prevent multiple asynchronous calls.
    *
    **/
    global static void sendSubscriptionToQueueProcessor(String action, Map<Id,String> newSubscriptionJSONs, Map<Id,String> oldSubscriptionJSONs) {

       System.debug('Inside sendSubscriptionToQueueProcessor');
       if (!System.isFuture()) {
          sendSubscriptionToQueueProcessorFuture(action,newSubscriptionJSONs,oldSubscriptionJSONs);
       } else {
          sendSubscriptionToQueueProcessorOrig(action,newSubscriptionJSONs,oldSubscriptionJSONs);
       }
    }

    @future (callout=true)
    global static void sendSubscriptionToQueueProcessorFuture(String action, Map<Id,String> newSubscriptionJSONs, Map<Id,String> oldSubscriptionJSONs) {

       System.debug('Inside sendSubscriptionToQueueProcessorFuture');
       sendSubscriptionToQueueProcessorOrig(action,newSubscriptionJSONs,oldSubscriptionJSONs);
    }
    
    global static void sendSubscriptionToQueueProcessorOrig(String action, Map<Id,String> newSubscriptionJSONs, Map<Id,String> oldSubscriptionJSONs) {

       System.debug('Inside sendSubscriptionToQueueProcessorOrig');
       if ('INSERT'.equals(action)){
           processCreateSubscription(newSubscriptionJSONs);
           //check for primary
        } else if ('UPDATE'.equals(action)){
            processUpdateSubscription(newSubscriptionJSONs,oldSubscriptionJSONs, false);
        } else if ('FORCE UPDATE'.equals(action)){
            processUpdateSubscription(newSubscriptionJSONs,oldSubscriptionJSONs, true);
        }  else { 
            //throw an error message that this is an invalid type
            throw new MRISException('Error! Invalid action type "' + action + '" passed to SubscriptionUtility.  ' + 
            'Please correct this inorder to continue further',true);
        }                       
    }

    /**
    *
    **/
    global static void processCreateSubscription(Map<Id,String> newSubscriptionJSONs) {
        System.debug('*** Inside processCreateSubscription');
        System.debug('*** Subscription Count : ' + newSubscriptionJSONs.size());
        List<String> accountIds = new List<String>();
        List<String> contactIds = new List<String>();
        
        Map<String,Subscriptions__c> subscriptions = new Map<String,Subscriptions__c>();
        Map<String,Contact> contacts = new Map<String,Contact>();
        Map<String,Account> relatedOffices = new Map<String,Account>();
        
        Map<String,List<Relationship__c>> subIdRelationships = new Map<String,List<Relationship__c>>();
        Map<String,Map<String,Subscriptions__c>> contactIdSubscriptions = new Map<String,Map<String,Subscriptions__c>>();
        Map<String,Map<Id,Related_Association__c>> subIdSubscriptionAssociations = new Map<String,Map<Id,Related_Association__c>>();
        
        List<SFQPConnector__c> SFQPConnectors = new List<SFQPConnector__c>();
        Map<String,Map<String,Subscription_Role__c>> subIdRoleTypeSubscriptionRoles = new Map<String,Map<String,Subscription_Role__c>>();
        Map<String,Map<String,SFQPConnector__c>> subIdRoleTypeSFQPConnectors = new Map<String,Map<String,SFQPConnector__c>>();
        
        for (Id jsonString: newSubscriptionJSONs.keySet()){                    
            Subscriptions__c subscription = (Subscriptions__c) System.JSON.deserialize(newSubscriptionJSONs.get(jsonString),sObject.class);
            
            subscriptions.put(subscription.Id, subscription);
            accountIds.add(subscription.Related_Location_Broker_Office__c);
            contactIds.add(subscription.Contact__c);        
        }
        
        relatedOffices = new Map<String,Account>([SELECT a.Id, a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type, 
                        a.Trading_As__c,a.SystemModstamp, a.Street_Type__c, a.Street_Number__c, a.Street_Number_Suffix__c, a.Street_Name__c, 
                        a.Street_Direction__c, a.Status__c, a.State__c, a.SicDesc, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, 
                        a.ShippingCountry, a.ShippingCity, a.Shareholder_Board__c, a.QAS_Validation_Timestamp__c, a.QAS_Validation_Status__c, 
                        a.QAS_Validation_Footnote__c, a.QAS_Billing_Validation_Timestamp__c, a.QAS_Billing_Validation_Status__c, 
                        a.QAS_Billing_Validation_Footnote__c, a.PrismCompanyOffice__c, a.PrismCompanyCode__c,a.PrismAddressID__c, a.PrismAccountID__c, 
                        a.Phone, a.ParentId, a.PIN__c, a.OwnerId, a.OfficeKey__c, a.Num_Active_Subs__c, a.Num_Active_Office_Sec_NC__c, a.Name, a.NRDS_ID__c, 
                        a.MasterRecordId, a.MDS_Status__c, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.JigsawCompanyId, a.Jigsaw,a.IsDeleted, 
                        a.IsCustomerPortal, a.Import_Source__c, a.Import_ID__c, a.Full_Street_Address__c, a.Fax,a.Description, a.Date_Terminated__c, 
                        a.Date_Joined__c, a.DATELASTMODIFIED__c, a.DATEESTABLISHED__c, a.CreatedDate, a.CreatedById, a.Office_Email__c, a.County__c, 
                        a.Country__c, a.Copy_Address_to_Billing__c, a.Company_Type__c, a.City__c, a.CUSTOMERPOSTALCODE__c, a.CUSTOMEROFFICEPHONE__c, 
                        a.CUSTOMERFAX__c, a.CUSTOMEREMAIL__c, a.CUSTOMERADDRESSLINE2__c, a.CUSTOMERADDRESSLINE1__c, a.CUSTOMERADDRESSID__c, a.CS_Shareholder_ID__c,
                        a.CS_Office_Role_ID__c, a.CS_CompanyTypeRole_ID__c, a.CS_AccountTypeRole_ID__c, a.CONTACT1TITLE__c, a.CONTACT1OFFICEPHONE__c,
                        a.CONTACT1NAME__c, a.CONTACT1FAX__c, a.COMPANYID__c, a.BrokerAddress__c, a.Box__c, a.Billing_Zip__c, a.Billing_Zip_4__c, a.Billing_Unit_Type__c, 
                        a.Billing_Unit_Number__c, a.Billing_Street_Type__c, a.Billing_Street_Number__c, a.Billing_Street_Number_Suffix__c, a.Billing_Street_Name__c, 
                        a.Billing_Street_Direction__c, a.Billing_State__c, a.Billing_County__c, a.Billing_Country__c, a.Billing_City__c, a.Billing_Box__c,
                        a.Billing_Addl_Display_Name__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity,a.BROKEROFRECORDID__c, 
                        a.Addl_Display_Name__c, a.Account_Name__c, a.AccountSource FROM Account a WHERE a.Id IN :accountIds]);
                        
        contacts = new Map<String,Contact>([SELECT Id, Email FROM contact c WHERE Id IN :contactIds]);
        
        for(Subscriptions__c subscription : [SELECT Id, AgentKey__c, contact__c FROM Subscriptions__c WHERE Primary__c = true 
                                             AND    contact__c IN :contactIds AND Status__c = 'Active']){
            if(!contactIdSubscriptions.containskey(subscription.Contact__c))
                contactIdSubscriptions.put(subscription.Contact__c, new Map<String,Subscriptions__c>());
            
            contactIdSubscriptions.get(subscription.Contact__c).put(subscription.Id, subscription);     
        }
        
        for(Relationship__c relationship : [SELECT r.SystemModstamp,r.SysPrRoleKey__c, r.Subscription__c, r.Status__c, r.Relationship_Type__c, 
            r.Relationship_Start_Date__c, r.Relationship_End_Date__c, r.Related_Account__c, r.RecordTypeId, r.PrismRelationshipID__c, r.Personal_Assistant__c, 
            r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, 
            r.Import_Source__c, r.Import_ID__c, r.Id, r.Created_Source__c, r.CreatedDate, r.CreatedById, r.Contact__c, r.Broker_Office__c,
            r.Broker_Office__r.OfficeKey__c FROM Relationship__c r WHERE r.Subscription__c IN :subscriptions.keyset()]){
            
            if(!subIdRelationships.containskey(relationship.Subscription__c))
                subIdRelationships.put(relationship.Subscription__c, new List<Relationship__c>());
            
            subIdRelationships.get(relationship.Subscription__c).add(relationship);
        }
        
        for(Related_Association__c subscriptionAssociation : [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Start_Date__c, r.PrismRelBoardID__c, 
            r.Primary__c,r.OwnerId, r.Notes__c, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate,
            r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.End_Date__c, r.CreatedDate, r.CreatedById, r.Broker_Code__c,
            r.Association__c, r.Association_Name__c From Related_Association__c r WHERE r.Subscription__c IN :subscriptions.keyset()]){
            
            if(!subIdSubscriptionAssociations.containskey(subscriptionAssociation.Subscription__c))
                subIdSubscriptionAssociations.put(subscriptionAssociation.Subscription__c, new Map<Id,Related_Association__c>());
            
            subIdSubscriptionAssociations.get(subscriptionAssociation.Subscription__c).put(subscriptionAssociation.Id, subscriptionAssociation);
        }
        
        for(String subscriptionId : subscriptions.keyset()){
            Subscriptions__c subscription = subscriptions.get(subscriptionId);
            Account relatedOffice = relatedOffices.get(subscription.Related_Location_Broker_Office__c);
            Contact contact = contacts.get(subscription.Contact__c);    
            
            typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
            QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE18');
            
            if('RETS'.equals(relatedOffice.Type) || 'Virtual Tour Vendor'.equals(relatedOffice.Type) || 'MDS'.equals(relatedOffice.Type)
              || ('Vendor'.equals(subscription.Contact_Type__c) && (subscription.Subscription_Type__c.startsWith('RETS') 
              || 'MDS'.equals(subscription.Subscription_Type__c) && 'RETS/MDS'.equals(subscription.Subscription_Type__c)))) {
                
                System.debug('*** Account is MRISService of virtual tour vendor; exiting');
                
               // if('Active'.equals(subscription.Status__c))
               //    MRISServiceAccountProcessingUtility.processServiceAccounts(subscription, relatedOffice);
                return;
            }
            
            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = buildAgentStructureMessage(subscription,'CREATE',contact.Email);
            //Build Sysparty Roles
            Map<String,String> roleNames = new Map<String,String>();
            Map<String,Subscription_Role__c> subscriptionRoles = new Map<String,Subscription_Role__c>();          
            
            Subscription_Role__c typeRole = new Subscription_Role__c();
            
            typeRole.Role__c = type2Role.get(subscription.Subscription_Type__c);
            if(Utils.isNull(typeRole.Role__c))
                typeRole.Role__c = subscription.Subscription_Type__c;
            typeRole.Status__c = 'Active';
            typeRole.Subscription__c = subscription.Id;
            typeRole.Role_Start_Date__c = Date.today();
            if(Utils.isNull(role2Mapping.get(typeRole.Role__c))) {
                roleNames.put(typeRole.Role__c, relatedOffice.OfficeKey__c);
                subscriptionRoles.put(typeRole.Role__c, typeRole);
            } 
            else {
                roleNames.put(role2Mapping.get(typeRole.Role__c), relatedOffice.OfficeKey__c);
                subscriptionRoles.put(role2Mapping.get(typeRole.Role__c), typeRole);
            }
            
            Map<String,Subscriptions__c> allSubscriptions = new Map<String,Subscriptions__c>();
            if(contactIdSubscriptions.containskey(subscription.contact__c)){
                allSubscriptions = contactIdSubscriptions.get(subscription.contact__c);
                if(allSubscriptions.containskey(subscription.Id))
                    allSubscriptions.remove(subscription.Id);
            }
            
            List<Subscriptions__c> otherSubscriptions = new List<Subscriptions__c>();            
            otherSubscriptions.addAll(allSubscriptions.values());
            
            Subscription_Role__c statusRole = new Subscription_Role__c();
            
            if('Active'.equals(subscription.Status__c)) {
                if(otherSubscriptions.size() == 0) {
                    statusRole.Role__c = 'Status Active';
                    roleNames.put(statusRole.Role__c, relatedOffice.OfficeKey__c);
                } 
                else {
                    statusRole.Role__c = 'Status Duplicate';
                    if (otherSubscriptions.size() > 0)
                        roleNames.put(statusRole.Role__c, otherSubscriptions.get(0).AgentKey__C);
                    else
                        roleNames.put(statusRole.Role__c, '');
                }
            } 
            else {
                statusRole.Role__c = 'Status Inactive';
                roleNames.put(statusRole.Role__c, relatedOffice.OfficeKey__c);
            }

            statusRole.Status__c = 'Active';
            statusRole.Subscription__c = subscription.Id;
            statusRole.Role_Start_Date__c = Date.today();
            subscriptionRoles.put(statusRole.Role__c, statusRole);            
           
            for(String roleName : QueueProcessorMappings.getDefaultSubscriptionMap().get(subscription.Contact_Type__c).get(subscription.Subscription_Type__c)) {
                Subscription_Role__c role = new Subscription_Role__c();
                role.Role__c = roleName;
                role.Status__c = 'Active';
                role.Subscription__c = subscription.id;
                role.Role_Start_Date__c = Date.today();
                if(Utils.isNull(role2Mapping.get(roleName))) {
                    roleNames.put(roleName, relatedOffice.OfficeKey__c);
                    subscriptionRoles.put(roleName, role);
                } 
                else {
                    roleNames.put(role2Mapping.get(roleName), relatedOffice.OfficeKey__c);
                    subscriptionRoles.put(role2Mapping.get(roleName), role);
                }
            }
            
            Map<ID,CornerstoneMappings__c> cornerstoneMappings = QueueProcessorMappings.getCornerstoneMappings(roleNames.keySet());
            Map<String,String> tempRoleListMappings = new Map<String,String>();
            Map<String,String> roleListMappings = new Map<String,String>();  
            
            for (Id cornerstoneId : cornerstoneMappings.keySet()){
                    CornerstoneMappings__c cm = cornerstoneMappings.get(cornerstoneId);
                    tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
            }
        
            //Swap the maps to get the correct order
            for (String roleName : roleNames.keySet()){
                System.debug('*** roleName : ' + roleName);
                System.debug('*** tempRoleListMappings.get(roleName) : ' + tempRoleListMappings.get(roleName));
                roleListMappings.put(roleName,tempRoleListMappings.get(roleName));
            }
            
            Integer i = 2;
            String sysPrRoleID = Utils.decimalToString(subscription.PrimarySubNum__c);
            system.debug('*** sysPrRoleID : ' + sysPrRoleID);
            
            genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNames, cornerstoneMappings, roleListMappings, '', sysPrRoleID, i));
         
            //SubscriptionAssociationProcessingUtility  -- Association Relationships
            Map <Id,Related_Association__c> subscriptionAssociations = new Map<Id,Related_Association__c>();
            if(subIdSubscriptionAssociations.containskey(subscription.Id))
                subscriptionAssociations = subIdSubscriptionAssociations.get(subscription.Id);
            Map<Integer,Related_Association__c> relationshipMap = new Map<Integer,Related_Association__c>();
            Map<String,String> assRoleListMappings = new  Map<String,String>();
            
            genericRequestTypes.addAll(SubscriptionAssociationProcessingUtility.buildCreateAssociations(subscriptionAssociations, relationshipMap, assRoleListMappings, genericRequestTypes.size()));
            
             //Relationships
            List<Relationship__c> relationships = new List<Relationship__c>();
            if(subIdRelationships.containskey(subscription.Id))
                relationships = subIdRelationships.get(subscription.id);
            
            Map<String,String> relIDUUIDMap = new Map<String,String>();
            for (Relationship__c r : Relationships) {
                typesWebserviceQueueprocessorCrmMris.GenericRequestType genericRequestType = RelationshipProcessingUtility.createRelationship(r.Broker_Office__c,r.Subscription__c,
                                                                                             r.Broker_Office__r.OfficeKey__c,null,r.Relationship_Type__c,r.id,false,genericRequestTypes.size() + 1);
                relIDUUIDMap.put(genericRequestType.sysParty.uuid,r.id);
                genericRequestTypes.add(genericRequestType);
            }
            
            //Call QP and insert the messages 
            QPRequest.requests  = genericRequestTypes;
            QPRequest.sfdcMessageId = Utils.getRandomNumber();
            System.debug('*** QPRequest : ' + QPRequest);
            String status = 'Sent';
            String statusMessage = 'Success';
            typesWebserviceQueueprocessorCrmMris.OutputResponse QPResponse;
            boolean hasSFQPFailed = false;
            try {
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = null;
                try{
                    stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                }
                catch(CalloutException ex){
                    System.debug('!!!!!!!!!QP retry');
                    stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                }
                stub.inputHttpHeaders_x = new Map<String,String>();
                //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                QPResponse = stub.salesForceRequest(QPRequest);
                System.debug('*** response code : ' + QPResponse.responseCode);
                if('FAIL'.equals(QPResponse.responseCode)) {
                    status = 'Failed';
                    statusMessage = QPResponse.responseDescription;                        
                }
            } catch (Exception ex){
                status = 'Failed';
                hasSFQPFailed = true;
                statusMessage = ex.getMessage() + ' -- \r\n' + ex.getStackTraceString();
                System.debug('*** Exception : ' + ex);
            }
            System.debug('*** QPResponse : ' + QPResponse);
            if(!status.equals('Failed')){
                //insert subscriptionRoles.values();
                subIdRoleTypeSubscriptionRoles.put(subscriptionId,subscriptionRoles);
            }
            
            for (String s : assRoleListMappings.keySet()) {
                System.debug('assRoleListMappings ---> ' + assRoleListMappings);
            }
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType genericRequestType : genericRequestTypes){
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.MessageSent__c = Json.serialize(genericRequestType);
                
                if (hasSFQPFailed)
                    sf.QPStatus__c = 'Failed-SFQP'; 
                else
                    sf.QPStatus__c = status;
                
                sf.QPMessage__c = statusMessage;
                
                if (genericRequestType.agentResource== null || ''.equals(genericRequestType.agentResource.action)){ 
                    for(String rType : subscriptionRoles.keySet()) {
                        if(genericRequestType.sysParty.sysPRRoleKey != null && genericRequestType.sysParty.sysPRRoleKey.equals(roleListMappings.get(rType))) {
                            sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                            sf.ObjectType__c = 'Subscription_Role__c';
                            sf.SFMessageID__c = genericRequestType.sysParty.uuid;
                            //sf.relatedid__c = subscriptionRoles.get(rType).id;
                            system.debug('*** rType : ' + rType);
                            if(!subIdRoleTypeSFQPConnectors.containskey(subscription.Id))
                                subIdRoleTypeSFQPConnectors.put(subscription.Id,new Map<String,SFQPConnector__c>());
                            
                            subIdRoleTypeSFQPConnectors.get(subscription.Id).put(rType,sf);
                        } 
                    }
                    
                    //system.debug('*** subRoleSFQP.size() : ' + subIdRoleTypeSFQPConnectors.get(subscription.Id).size());

                    for (String s : assRoleListMappings.keySet()) {
                        System.debug('assRoleListMappings.get(genericRequestType.sysParty.sysPRRoleKey) ---> ' + assRoleListMappings.get(s));
                        if (genericRequestType.sysParty.sysPRRoleKey.equals(assRoleListMappings.get(s))) {
                            sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                            sf.ObjectType__c = 'Related_Association__c';
                            sf.SFMessageID__c = genericRequestType.sysParty.uuid;
                            Integer inte = Integer.valueOf(genericRequestType.sequenceNumber);
                            sf.relatedid__c = relationshipMap.get(inte).Id;
                            
                            SFQPConnectors.add(sf);
                        }
                    }

                    for (String s : relIDUUIDMap.keySet()) {
                        System.debug('relIDUUIDMap.keySet() ---> ' + s);
                        System.debug('relIDUUIDMap.get(genericRequestType.sysParty.uuid) ---> ' + relIDUUIDMap.get(s));
                        if (genericRequestType.sysParty.uuid.equals(s)) {
                            sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                            sf.ObjectType__c = 'Relationship__c';
                            sf.SFMessageID__c = genericRequestType.sysParty.uuid;
                            sf.relatedid__c = relIDUUIDMap.get(s);
                            
                            SFQPConnectors.add(sf);
                        }
                    }       
                } 
                else {
                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                    sf.relatedid__c = subscription.id;
                    sf.SFMessageID__c = genericRequestType.agentResource.uuid;
                    sf.ObjectType__c = 'Subscription';
                    
                    SFQPConnectors.add(sf);
                }   
                
                
            } //End of genericRequestType For loop
            
            system.debug('*** SFQPConnectors.size(): ' + SFQPConnectors.size());
            //upsert SFQPConnectors;
        }       
                
        for(String subscriptionId : subIdRoleTypeSubscriptionRoles.keyset()){
            insert subIdRoleTypeSubscriptionRoles.get(subscriptionId).values();
            
            Map<String,SFQPConnector__c> roleTypeSFQPConnectors = subIdRoleTypeSFQPConnectors.get(subscriptionId);
            for(String roleType : roleTypeSFQPConnectors.keyset()){
                system.debug('*** roleType  Name: ' + roleType);
                SFQPConnector__c sf = roleTypeSFQPConnectors.get(roleType);
                sf.relatedid__c = subIdRoleTypeSubscriptionRoles.get(subscriptionId).get(roleType).Id;
                SFQPConnectors.add(sf);
            }           
        }
                
        upsert SFQPConnectors;   
    }
    
    /**
    *
    **/
    global static void processUpdateSubscription(Map<Id,String> newSubscriptionJSONs,Map<Id,String> oldSubscriptionJSONs, boolean forceUpdate) {
        System.debug('*** Inside processUpdateSubscription');
        System.debug('*** New Subscription Count : ' + newSubscriptionJSONs.size());
        System.debug('*** Old Subscription Count : ' + oldSubscriptionJSONs.size());
        
        List<SFQPConnector__c> SFQPConnectors = new List<SFQPConnector__c>();
        Map<String,Map<String,Subscription_Role__c>> subIdRoleTypeSubscriptionRoles = new Map<String,Map<String,Subscription_Role__c>>();
        List<Subscription_Role__c> oldSubscriptionsRoles = new List<Subscription_Role__c>();
        List<Subscription_Role__c> agentSubscriptionsRoles = new List<Subscription_Role__c>();
        List<Relationship__c> relationships = new List<Relationship__c>();
        Map<String,Map<String,SFQPConnector__c>> subIdRoleTypeSFQPConnectors = new Map<String,Map<String,SFQPConnector__c>>();
                
        for (Id subscriptionId : newSubscriptionJSONs.keySet()){
            Map<String,String> roleNamesMap = new Map<String,String>();
            Map<String,Subscription_Role__c> subRoles = new Map<String,Subscription_Role__c>(); 
            Map<String,String> subRelationship = new Map<String,String>();
            List<Relationship__c> subRelationshipList = new List<Relationship__c>();
            Map<String,Subscription_Role__c> oldSubRoles = new Map<String,Subscription_Role__c>();
            
            Boolean removeAuthOffMgrRoles = false;
            Boolean removeRels = false;
            Subscription_Role__c agentRole;
            Map<String,String> oldRoleNamesMap = new Map<String,String>();
            boolean hasChanged = false;
            
            typesWebserviceQueueprocessorCrmMris.InputRequest QPRequest = new typesWebserviceQueueprocessorCrmMris.InputRequest();
            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  genericRequestTypes = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();

            //Deserialize JSON String to subscription object                    
            Subscriptions__c newSubscription = (Subscriptions__c) System.JSON.deserialize(newSubscriptionJSONs.get(subscriptionId),sObject.class);
            Subscriptions__c oldSubscription = (Subscriptions__c) System.JSON.deserialize(oldSubscriptionJSONs.get(subscriptionId),sObject.class);
            
            Account related = [SELECT
                    a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type, a.Trading_As__c, 
                    a.SystemModstamp, a.Street_Type__c, a.Street_Number__c, a.Street_Number_Suffix__c, a.Street_Name__c, 
                    a.Street_Direction__c, a.Status__c, a.State__c, a.SicDesc, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, 
                    a.ShippingCountry, a.ShippingCity, a.Shareholder_Board__c, a.QAS_Validation_Timestamp__c, a.QAS_Validation_Status__c, 
                    a.QAS_Validation_Footnote__c, a.QAS_Billing_Validation_Timestamp__c, a.QAS_Billing_Validation_Status__c, 
                    a.QAS_Billing_Validation_Footnote__c, a.PrismCompanyOffice__c, a.PrismCompanyCode__c, 
                    a.PrismAddressID__c, a.PrismAccountID__c, a.Phone, a.ParentId, a.PIN__c, a.OwnerId, a.OfficeKey__c, 
                    a.Num_Active_Subs__c, a.Num_Active_Office_Sec_NC__c, a.Name, a.NRDS_ID__c, a.MasterRecordId, 
                    a.MDS_Status__c, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.JigsawCompanyId, a.Jigsaw,
                    a.IsDeleted, a.IsCustomerPortal, a.Import_Source__c, a.Import_ID__c, a.Id, a.Full_Street_Address__c, a.Fax, 
                    a.Description, a.Date_Terminated__c, a.Date_Joined__c, a.DATELASTMODIFIED__c, a.DATEESTABLISHED__c, a.CreatedDate, 
                    a.CreatedById, a.Office_Email__c, a.County__c, a.Country__c, a.Copy_Address_to_Billing__c, a.Company_Type__c, a.City__c, a.CUSTOMERPOSTALCODE__c, 
                    a.CUSTOMEROFFICEPHONE__c, a.CUSTOMERFAX__c, a.CUSTOMEREMAIL__c, a.CUSTOMERADDRESSLINE2__c, a.CUSTOMERADDRESSLINE1__c, a.CUSTOMERADDRESSID__c, 
                    a.CS_Shareholder_ID__c, a.CS_Office_Role_ID__c, a.CS_CompanyTypeRole_ID__c, a.CS_AccountTypeRole_ID__c, a.CONTACT1TITLE__c, a.CONTACT1OFFICEPHONE__c,
                    a.CONTACT1NAME__c, a.CONTACT1FAX__c, a.COMPANYID__c, a.BrokerAddress__c, a.Box__c, a.Billing_Zip__c, a.Billing_Zip_4__c, a.Billing_Unit_Type__c, 
                    a.Billing_Unit_Number__c, a.Billing_Street_Type__c, a.Billing_Street_Number__c, a.Billing_Street_Number_Suffix__c, a.Billing_Street_Name__c, 
                    a.Billing_Street_Direction__c, a.Billing_State__c, a.Billing_County__c, a.Billing_Country__c, a.Billing_City__c, a.Billing_Box__c,
                    a.Billing_Addl_Display_Name__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, 
                    a.BROKEROFRECORDID__c, a.Addl_Display_Name__c, a.Account_Name__c, a.AccountSource   
            FROM Account a WHERE Id = :newSubscription.Related_Location_Broker_Office__c];
                        
           Boolean isService =(MRISServiceAccountProcessingUtility.serviceType(newSubscription.Subscription_type__c) || 
                             MRISServiceAccountProcessingUtility.serviceType(related.Type));

            Subscriptions__c primary;
            try {
                primary = [SELECT s.AgentKey__c FROM Subscriptions__C s
                           WHERE  s.Contact__c = :newSubscription.Contact__c and s.Primary__c = true 
                           LIMIT 1];
            } 
            catch (Queryexception ex) {}
            
             //determine if anything in subscription has changed
            if(forceUpdate
              ||(oldSubscription.NRDS_ID__c != newSubscription.NRDS_ID__c)
              ||(oldSubscription.Addl_Display_Name__c != newSubscription.Addl_Display_Name__c)
              ||(oldSubscription.Private_Email__c != newSubscription.Private_Email__c)
              ||(oldSubscription.Box__c != newSubscription.Box__c)
              ||(oldSubscription.Mobile_Phone__c != newSubscription.Mobile_Phone__c)
              ||(oldSubscription.City__c != newSubscription.City__c)
              ||(oldSubscription.Country__c != newSubscription.Country__c)
              ||(oldSubscription.County__c != newSubscription.County__c)
              ||(oldSubscription.Public_Email__c != newSubscription.Public_Email__c)
              ||(oldSubscription.Fax__c != newSubscription.Fax__c)
              ||(oldSubscription.Home_Fax__c != newSubscription.Home_Fax__c)
              ||(oldSubscription.Date_Joined__c != newSubscription.Date_Joined__c)
              ||(oldSubscription.Primary_Phone__c != newSubscription.Primary_Phone__c)
              ||(oldSubscription.Pager__c != newSubscription.Pager__c)
              ||(oldSubscription.Zip__c != newSubscription.Zip__c)
              ||(oldSubscription.Date_Reinstated__c != newSubscription.Date_Reinstated__c)
              ||(oldSubscription.State__c != newSubscription.State__c)
              ||(oldSubscription.Street_Type__c != newSubscription.Street_Type__c)
              ||(oldSubscription.Street_Direction__c != newSubscription.Street_Direction__c)
              ||(oldSubscription.Street_Name__c != newSubscription.Street_Name__c)
              ||(oldSubscription.Street_Number__c != newSubscription.Street_Number__c)
              ||(oldSubscription.Street_Number_Suffix__c != newSubscription.Street_Number_Suffix__c)
              ||(oldSubscription.Date_Terminated__c != newSubscription.Date_Terminated__c)
              ||(oldSubscription.Unit__c != newSubscription.Unit__c)
              ||(oldSubscription.VM_Ext__c != newSubscription.VM_Ext__c)
              ||(oldSubscription.Voicemail__c != newSubscription.Voicemail__c)
              ||(oldSubscription.Website__c != newSubscription.Website__c)
              ||(oldSubscription.Zip_4__c != newSubscription.Zip_4__c) 
              ||(oldSubscription.Date_Terminated__c != newSubscription.Date_Terminated__c)
              ) {
                System.debug('Has changed');
                hasChanged = true;
                QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE33');
                Contact contact = [select id, Email from contact c where id = :newSubscription.Contact__c limit 1];
                if(!isService) genericRequestTypes = buildAgentStructureMessage(newSubscription, 'UPDATE',contact.Email);
            }
            
            if(!newSubscription.Contact_Type__c.equals(oldSubscription.Contact_Type__c) || !newSubscription.Subscription_Type__c.equals(oldSubscription.Subscription_Type__c)) {
                System.debug('Type has changed');
                if(!hasChanged)
                    QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE25');
                
                if('Active'.equals(newSubscription.Status__c)) {
                    for(Subscription_Role__c sr :[SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                                 from Subscription_Role__c where Subscription__c = :newSubscription.id
                                                 and Role__c not in ('Agent','Login','System MRIS','System-MRIS','Office','RETS','Virtual Tour Vendor')
                                                 and Status__c='Active']) {
                        sr.Status__c = 'Inactive';
                        sr.Role_End_Date__c = Date.today();
                      
                        if(Utils.isNull(role2Mapping.get(sr.Role__c))) {
                            oldRoleNamesMap.put(sr.Role__c, sr.SysPrRoleKey__c);
                            oldSubRoles.put(sr.Role__c, sr);
                        } else {
                            oldRoleNamesMap.put(role2Mapping.get(sr.Role__c), sr.SysPrRoleKey__c);
                            oldSubRoles.put(role2Mapping.get(sr.Role__c), sr);
                        }
                    }                    
                    
                    Subscription_Role__c statusRole = new Subscription_Role__c();
                    if (newSubscription.Primary__c) {
                        statusRole.Role__c = 'Status Active';   
                    } else {
                        statusRole.Role__c = 'Status Duplicate';
                    }
                    
                    statusRole.Status__c = 'Active';
                    statusRole.Subscription__c = newSubscription.id;
                    statusRole.Role_Start_Date__c = Date.today();
                    roleNamesMap.put(statusRole.Role__c, related.OfficeKey__c);
                    subRoles.put(statusRole.Role__c, statusRole);                   
            
                    Subscription_Role__c typeRole = new Subscription_Role__c();
                    typeRole.Role__c = type2Role.get(newSubscription.Subscription_Type__c);
                    if(Utils.isNull(typeRole.Role__c))
                        typeRole.Role__c = newSubscription.Subscription_Type__c;
                    typeRole.Status__c = 'Active';
                    typeRole.Subscription__c = newSubscription.id;
                    typeRole.Role_Start_Date__c = Date.today();
                   
                    if(Utils.isNull(role2Mapping.get(typeRole.Role__c))) {
                        roleNamesMap.put(typeRole.Role__c, related.OfficeKey__c);
                        subRoles.put(typeRole.Role__c, typeRole);
                    } 
                    else {
                        roleNamesMap.put(role2Mapping.get(typeRole.Role__c), related.OfficeKey__c);
                        subRoles.put(role2Mapping.get(typeRole.Role__c), typeRole);
                    }
                    try {
                        for(String subRole : QueueProcessorMappings.getDefaultSubscriptionMap().get(newSubscription.Contact_Type__c).get(newSubscription.Subscription_Type__c)) {
                            if(subRole.equals('Agent')||subRole.equals('System MRIS')||subRole.equals('System-MRIS'))
                                continue;
                            Subscription_Role__c role = new Subscription_Role__c();
                            role.Role__c = subRole;
                            role.Status__c = 'Active';
                            role.Subscription__c = newSubscription.id;
                            role.Role_Start_Date__c = Date.today();
                           
                            if(Utils.isNull(role2Mapping.get(subRole))) {
                                roleNamesMap.put(subRole, related.OfficeKey__c);
                                subRoles.put(subRole, role);
                            } else {
                                roleNamesMap.put(role2Mapping.get(subRole), related.OfficeKey__c);
                                subRoles.put(role2Mapping.get(subRole), role);
                            }
                            
                        }
                    } catch (NullPointerException ex) {
                        System.debug(ex);
                    }
                    System.debug('newRoleMap ---> ' + roleNamesMap);
                } else {
                    System.debug('but subscription is inactive so not adding default roles.');
                }
            }
            
            if(newSubscription.Related_Location_Broker_Office__c != oldSubscription.Related_Location_Broker_Office__c) {
                System.debug('Office location has changed');
                
                Account aOldAc = [select officeKey__C from Account where id = :oldSubscription.Related_Location_Broker_Office__c LIMIT 1];
                if(!hasChanged)
                    QPRequest.command = QueueProcessorMappings.commandTypes.get('RULE22');

                if('Active'.equals(oldSubscription.Status__c)) {
                    agentRole = [Select Id, Role__c, Subscription__c, sysPrRoleKey__c From Subscription_Role__c 
                                 Where Role__c = 'Agent' and Status__c = 'Active' and Subscription__c = :newSubscription.id];
                    genericRequestTypes.add(SysPartyRoleProcessingUtility.buildUpdateStruct(genericRequestTypes.size()+1, agentRole.sysPrRoleKey__c, newSubscription.AgentKey__c, aOldAc.OfficeKey__c, 0));
                    agentRole.Role_End_Date__c = Date.today();
                    agentRole.Status__c = 'Inactive';
                 // oldSubRoles.put('Agent', oldAgent);
                 //oldRoleNamesMap.put('Agent', oldAgent.sysPrRoleKey__c);
                }
        
                if('Active'.equals(newSubscription.Status__c)) {
                    Subscription_Role__c newAgent = new Subscription_Role__c();
                    newAgent.Role__c = 'Agent';
                    newAgent.Status__c = 'Active';
                    newAgent.Subscription__c = newSubscription.id;
                    newAgent.Role_Start_Date__c = Date.today();
                    roleNamesMap.put('Agent', related.OfficeKey__c);
                    subRoles.put('Agent', newAgent);
                
                    for(Subscription_Role__c sr :[SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                                 from Subscription_Role__c where Subscription__c = :newSubscription.id
                                                 and Role__c not in ('Agent','Login','System MRIS','System-MRIS','Office','RETS','Virtual Tour Vendor')
                                                 and Status__c = 'Active']) {
                        sr.Status__c = 'Inactive';
                        sr.Role_End_Date__c = Date.today();
 
                        if(Utils.isNull(role2Mapping.get(sr.Role__c))) {
                           oldRoleNamesMap.put(sr.Role__c, sr.SysPrRoleKey__c);
                           oldSubRoles.put(sr.Role__c, sr);
                        } else {
                           oldRoleNamesMap.put(role2Mapping.get(sr.Role__c), sr.SysPrRoleKey__c);
                           oldSubRoles.put(role2Mapping.get(sr.Role__c), sr);
                        }
                    }
                    System.debug('oldRoleMap ---> ' + oldRoleNamesMap);
            
                    Subscription_Role__c typeRole = new Subscription_Role__c();
                    typeRole.Role__c = type2Role.get(newSubscription.Subscription_Type__c);
                    if(Utils.isNull(typeRole.Role__c)) {
                        typeRole.Role__c = newSubscription.Subscription_Type__c;
                    }
                    typeRole.Status__c = 'Active';
                    typeRole.Subscription__c = newSubscription.id;
                    typeRole.Role_Start_Date__c = Date.today();
                    if(Utils.isNull(role2Mapping.get(typeRole.Role__c))) {
                        roleNamesMap.put(typeRole.Role__c, related.OfficeKey__c);
                        subRoles.put(typeRole.Role__c, typeRole);
                    } else {
                        roleNamesMap.put(role2Mapping.get(typeRole.Role__c), related.OfficeKey__c);
                        subRoles.put(role2Mapping.get(typeRole.Role__c), typeRole);
                    }

                    for(String subRole :QueueProcessorMappings.getDefaultSubscriptionMap().get(newSubscription.Contact_Type__c).get(newSubscription.Subscription_Type__c)) {
                        if(subRole.equals('Agent')||subRole.equals('System MRIS')||subRole.equals('System-MRIS'))
                            continue;
                        Subscription_Role__c role = new Subscription_Role__c();
                        role.Role__c = subRole;
                        role.Status__c = 'Active';
                        role.Subscription__c = newSubscription.id;
                        role.Role_Start_Date__c = Date.today();
                        if(Utils.isNull(role2Mapping.get(subRole))) {
                            roleNamesMap.put(subRole, related.OfficeKey__c);
                            subRoles.put(subRole, role);
                        } else {
                            roleNamesMap.put(role2Mapping.get(subRole), related.OfficeKey__c);
                            subRoles.put(role2Mapping.get(subRole), role);
                        }
                    }
                    
                    Subscription_Role__c agrole = new Subscription_Role__c();
                    if (newSubscription.Primary__c) {
                        agrole.Role__c = 'Status Active';
                         roleNamesMap.put(agrole.Role__c, related.OfficeKey__c);
                    } else {
                        agrole.Role__c = 'Status Duplicate';
                        if (primary != null) {
                            roleNamesMap.put(agrole.Role__c, primary.AgentKey__c);
                        } else {
                            roleNamesMap.put(agrole.Role__c, '');
                        }
                    }
                        
                    agrole.Status__c = 'Active';
                    agrole.Subscription__c = newSubscription.id;
                    agrole.Role_Start_Date__c = Date.today();
                    if(Utils.isNull(role2Mapping.get(agrole.Role__c))) {
                       
                        subRoles.put(agrole.Role__c, agrole);
                    } else {
                        roleNamesMap.put(role2Mapping.get(agrole.Role__c), related.OfficeKey__c);
                        subRoles.put(role2Mapping.get(agrole.Role__c), agrole);
                    }
                    
                    
                    //Check if the agent moved to a new borkerage
                    Map<Id,Account> am = new Map<Id,Account>([Select id, ParentId, OfficeKey__c from Account where id in (:newSubscription.Related_Location_Broker_Office__c,:oldSubscription.Related_Location_Broker_Office__c)]);
                    Account aParentID = am.get(newSubscription.Related_Location_Broker_Office__c);
                    Account aOldParentID = am.get(oldSubscription.Related_Location_Broker_Office__c);
                    System.debug('aParentID.ParentId ----> ' + aParentID.ParentId);
                    System.debug('aOldParentID.ParentId ----> ' + aOldParentID.ParentId);
                    System.debug('aOldParentID.id ----> ' + aOldParentID.id);
                    System.debug('aParentID.id ----> ' + aParentID.id);
                   if (((aParentID.ParentId != aOldParentID.ParentID) && 
                      (aOldParentID.ParentId != aParentID.id) && 
                      (aOldParentID.id != aParentID.ParentId))
                   || (aParentID.ParentId == null && aOldParentID.ParentID == null)) {
                    //Get Authorized Signer and Office Manager Relationship
                        List <Relationship__c> rList = [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Status__c, r.Relationship_Type__c, r.Relationship_Start_Date__c,
                         r.Relationship_End_Date__c, r.Related_Account__c, r.RecordTypeId, r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c,
                          r.OwnerId, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id,
                           r.Created_Source__c, r.CreatedDate, r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.Status__c='Active' and 
                           r.MDS_Status__c='Success' and r.Relationship_Type__c in ('Authorized Signer','Office Manager') and r.Subscription__c = :newSubscription.id];
                           
                           for (Relationship__c r1 : rList) {
                                  typesWebserviceQueueprocessorCrmMris.GenericRequestType gtType = RelationshipProcessingUtility.deleteRelationship1(aOldParentID.OfficeKey__c,newSubscription.agentKey__c,
                                 r1.sysPrRoleKey__c,r1.id,r1.Relationship_Type__c,genericRequestTypes.size()+1);
                                 r1.Relationship_End_Date__c = Date.today();
                                 r1.Status__c = 'Inactive';
                                 subRelationship.put(gtType.sysParty.uuid,r1.id);
                                 subRelationshipList.add(r1);
                                 genericRequestTypes.add(gtType);
                           }
                           
                   }
                   
                   //Remove the existing roles
                   List <Relationship__c> rList = [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Status__c, r.Relationship_Type__c, r.Relationship_Start_Date__c,
                 r.Relationship_End_Date__c, r.Related_Account__c, r.RecordTypeId, r.PrismRelationshipID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__c,
                  r.OwnerId, r.Name, r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id,
                   r.Created_Source__c, r.CreatedDate, r.CreatedById, r.Contact__c, r.Broker_Office__c From Relationship__c r where r.Status__c='Active' and 
                   r.MDS_Status__c='Success' and r.Relationship_Type__c not in ('Authorized Signer','Office Manager') and r.Subscription__c = :newSubscription.id];
                   
                   for (Relationship__c r1 : rList) {
                         typesWebserviceQueueprocessorCrmMris.GenericRequestType gtType = RelationshipProcessingUtility.deleteRelationship1(aOldParentID.OfficeKey__c,newSubscription.agentKey__c,
                         r1.sysPrRoleKey__c,r1.id,r1.Relationship_Type__c,genericRequestTypes.size()+1);
                         r1.Relationship_End_Date__c = Date.today();
                         r1.Status__c = 'Inactive';
                         subRelationship.put(gtType.sysParty.uuid,r1.id);
                         subRelationshipList.add(r1);
                         genericRequestTypes.add(gtType);
                   }
                  
                    
                } else {
                    System.debug('but subscription is inactive so not adding default roles.');
                }
            }
            
            Boolean agentIsActivated = false;
            //Changing from Active to inactive
            if('Inactive'.equals(newSubscription.Status__c) 
            && 'Active'.equals(oldSubscription.Status__c)) {
                System.debug('Status changed from active to inactive');
                
                if(!hasChanged)
                    QPRequest.command = QueueProcessorMappings.CommandTypes.get('RULE27');
                if(!isService) {
                   Subscription_Role__c statusRole = new Subscription_Role__c();
                   statusRole.Role__c = 'Status Inactive';
                   statusRole.Status__c = 'Active';
                   statusRole.Subscription__c = newSubscription.id;
                   statusRole.Role_Start_Date__c = Date.today();
                   roleNamesMap.put(statusRole.Role__c, related.OfficeKey__c);
                   subRoles.put(statusRole.Role__c, statusRole);
                } 
                for(Subscription_Role__c sr :[SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                             from Subscription_Role__c
                                             where Subscription__c = :newSubscription.id
                                             and Role__c not in ('Agent','Login','System MRIS','System-MRIS','Office','RETS','Virtual Tour Vendor')
                                             and Status__c = 'Active']) {
                    sr.Status__c = 'Inactive';
                    sr.Role_End_Date__c = Date.today();
                    if(Utils.isNull(role2Mapping.get(sr.Role__c)) &&
                        !sr.role__C.equals(newSubscription.Subscription_Type__C)) {
                        
                        oldRoleNamesMap.put(sr.Role__c, sr.SysPrRoleKey__c);
                        oldSubRoles.put(sr.Role__c, sr);
                    } else if (role2Mapping.get(sr.Role__c) != null 
                                && (!role2Mapping.get(sr.Role__c).equals(newSubscription.Subscription_Type__C))){
                        oldRoleNamesMap.put(role2Mapping.get(sr.Role__c), sr.SysPrRoleKey__c);
                        oldSubRoles.put(role2Mapping.get(sr.Role__c), sr);
                    }
                }
                try{
                    agentRole = [SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c from Subscription_Role__c 
                                           where Subscription__c = :newSubscription.id 
                                           and Role__c in ('Agent','Login') and Status__c = 'Active'];
                    agentRole.Status__c = 'Inactive';
                    agentRole.Role_End_Date__c = Date.today();
                    if(isService)
                       genericRequestTypes.add(SysPartyRoleProcessingUtility.buildUpdateStruct(genericRequestTypes.size()+1, agentRole.SysPrRoleKey__c, 
                          newSubscription.AgentKey__c, '', 0));
                    else
                       genericRequestTypes.add(SysPartyRoleProcessingUtility.buildUpdateStruct(genericRequestTypes.size()+1, agentRole.SysPrRoleKey__c, 
                          newSubscription.AgentKey__c, related.OfficeKey__c, 0));

                } catch(QueryException e){
                     System.debug(e.getMessage());                    
                }
            } else if('Active'.equals(newSubscription.Status__c) 
                && 'Inactive'.equals(oldSubscription.Status__c)) {
                System.debug('Status changed from inactive to active');

               /* if(isService) {
                   MRISServiceAccountProcessingUtility.processServiceAccounts(newSubscription, related);
                   return;
                } */

                agentIsActivated = true;
                if(!hasChanged)
                    QPRequest.command = QueueProcessorMappings.CommandTypes.get('RULE28');
                    
                for(Subscription_Role__c sr :[SELECT Id, Subscription__c, Role__c, SysPrRoleKey__c
                                             from Subscription_Role__c where Subscription__c = :newSubscription.id
                                             and Role__c not in ('Agent','Login','System MRIS','System-MRIS','Office','RETS','Virtual Tour Vendor')
                                             and Status__c = 'Active']) {
                    sr.Status__c = 'Inactive';
                    sr.Role_End_Date__c = Date.today();
                    if(Utils.isNull(role2Mapping.get(sr.Role__c))) {
                        oldRoleNamesMap.put(sr.Role__c, sr.SysPrRoleKey__c);
                        oldSubRoles.put(sr.Role__c, sr);
                    } else {
                        oldRoleNamesMap.put(role2Mapping.get(sr.Role__c), sr.SysPrRoleKey__c);
                        oldSubRoles.put(role2Mapping.get(sr.Role__c), sr);
                    }
                }
                
                if(!isService) {
                   Subscription_Role__c statusRole = new Subscription_Role__c();
                   if(oldSubscription.Primary__c) {
                       statusRole.Role__c = 'Status Active';
                       roleNamesMap.put(statusRole.Role__c, related.OfficeKey__c);
                   } else {
                       statusRole.Role__c = 'Status Duplicate';
                       String primaryID = [SELECT Primary_Subscription_ID__c FROM 
                       Contact WHERE Id = :newSubscription.Contact__c].Primary_Subscription_ID__c;
                       if(Utils.isNull(primaryID))
                          System.debug('ERROR: No primary subscription for this contact');
                       if (primary != null) {
                          roleNamesMap.put(statusRole.Role__c, primary.AgentKey__c);
                       } else {
                          roleNamesMap.put(statusRole.Role__c, '');
                       }
                   }                
                   statusRole.Status__c = 'Active';
                   statusRole.Subscription__c = newSubscription.id;
                   statusRole.Role_Start_Date__c = Date.today();
                   subRoles.put(statusRole.Role__c, statusRole);
                }
            
                Subscription_Role__c typeRole = new Subscription_Role__c();
                typeRole.Role__c = type2Role.get(newSubscription.Subscription_Type__c);
                if(Utils.isNull(typeRole.Role__c)) {
                    typeRole.Role__c = newSubscription.Subscription_Type__c;
                }
                typeRole.Status__c = 'Active';
                typeRole.Subscription__c = newSubscription.id;
                typeRole.Role_Start_Date__c = Date.today();
                if(Utils.isNull(role2Mapping.get(typeRole.Role__c))) {
                    roleNamesMap.put(typeRole.Role__c, related.OfficeKey__c);
                    subRoles.put(typeRole.Role__c, typeRole);
                } else {
                    roleNamesMap.put(role2Mapping.get(typeRole.Role__c), related.OfficeKey__c);
                    subRoles.put(role2Mapping.get(typeRole.Role__c), typeRole);
                }
                
                //roleNamesMap.remove() subscription.Subscription_Type__c
            
                for(String subRole : QueueProcessorMappings.getDefaultSubscriptionMap().get(newSubscription.Contact_Type__c).get(newSubscription.Subscription_Type__c)) {
                    if(subRole.equals('System MRIS')||subRole.equals('System-MRIS'))
                       continue;
                    Subscription_Role__c role = new Subscription_Role__c();
                    role.Role__c = subRole;
                    role.Status__c = 'Active';
                    role.Subscription__c = newSubscription.id;
                    role.Role_Start_Date__c = Date.today();
                    if(Utils.isNull(role2Mapping.get(subRole))) {
                        subRoles.put(subRole, role);
                        roleNamesMap.put(subRole, related.OfficeKey__c);
                    } else {
                        subRoles.put(role2Mapping.get(subRole), role);
                        roleNamesMap.put(role2Mapping.get(subRole), related.OfficeKey__c);
                    }
                }
            }
            
            System.debug('subRoles --->' + subRoles);
            System.debug('subRelationship --->' + subRelationship);
            System.debug('subRelationshipList --->' + subRelationshipList);
            System.debug('newRoleMap ---> ' + roleNamesMap);
            System.debug('oldRoleNamesMap ---> ' + oldRoleNamesMap);
            
            Set<String> roleNames = new Set<String>();
            roleNames.addall(roleNamesMap.keySet());
            roleNames.addall(oldRoleNamesMap.keySet());
            Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
            Map<String,String> tempRoleListMappings = new Map<String,String>();
            Map<String,String> roleListMappings = new Map<String,String>();  
            
            for (Id i : mappings.keySet()){
                    CornerstoneMappings__c cm = mappings.get(i);
                    tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
            }
        
            //Swap the maps to get the correct order
            for (String s: roleNames){
                System.debug('s ---> ' + s);
                System.debug('tempRoleListMappings.get(s) ---> ' + tempRoleListMappings.get(s));
                roleListMappings.put(s,tempRoleListMappings.get(s));
            }
            
            Integer i = genericRequestTypes.size() + 1;
            genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processDeleteStructRoles(oldRoleNamesMap, newSubscription.AgentKey__c, related.OfficeKey__c,i));
            i = genericRequestTypes.size() + 1;
            String sysPrRoleID = Utils.decimalToString(newSubscription.PrimarySubNum__c);
           
            genericRequestTypes.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings,roleListMappings,
                newSubscription.AgentKey__c,sysPrRoleID,i));
         
            if (Utils.isNull(QPRequest.command)) {
                System.debug ('No command; Exiting -----');
                return;
            }
            
            //swap sequence numbers when agent is inactivated  because of the unexplained behaviour of the Cornerstone.. 
            if (agentIsActivated && !isService) {
                Subscription_Role__c scrc = [select SysPrRoleKey__c from Subscription_Role__c where Subscription__c = :newSubscription.id and Role__c = 'Status Inactive' and Status__c = 'Active' LIMIT 1];
                System.debug('Inside agentIsActivated');
                System.debug('scrc  ---> ' + scrc);
                for (integer op=1;op<genericRequestTypes.size();op++) {
                    
                    if (genericRequestTypes.get(op).sysParty != null && 'DELETE'.equals(genericRequestTypes.get(op).sysParty.action) && scrc.SysPrRoleKey__c.equals(genericRequestTypes.get(op).sysParty.sysPrKey)){
                        integer copop = genericRequestTypes.size() + 1;
                        genericRequestTypes.get(op).sequenceNumber = '' + copop;
                        op =  genericRequestTypes.size();
                    }
                }
            }            
            
            //Call QP and insert the messages 
            QPRequest.requests  = genericRequestTypes;
            QPRequest.sfdcMessageId = Utils.getRandomNumber();
            System.debug('QPRequest ---> ' + QPRequest);
            String status = 'Sent';
            String statusMessage = 'Success';
            boolean hasFailedSFQP = false;
            typesWebserviceQueueprocessorCrmMris.OutputResponse resp;
            try {
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = null;
                try{
                    stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                }
                catch(CalloutException ex){
                    System.debug('!!!!!!!!!QP retry');
                    stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                }
                stub.inputHttpHeaders_x = new Map<String,String>();
                //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                resp = stub.salesForceRequest(QPRequest);
                System.debug('response code: '+resp.responseCode);
                if('FAIL'.equals(resp.responseCode)) {
                    status = 'Failed';
                    statusMessage = resp.responseDescription;
                }
            } catch (Exception ex){
                status = 'Failed';
                statusMessage =  ex.getMessage() + ' -- \r\n' + ex.getStackTraceString();
                hasFailedSFQP = true;
                System.debug(ex);
            }
            System.debug('resp ---> ' +resp);
            if(!status.equals('Failed')) {
                subIdRoleTypeSubscriptionRoles.put(subscriptionId,subRoles);
                //upsert subRoles.values();
                
                relationships.addAll(subRelationshipList);
                //upsert subRelationshipList;
                
                oldSubscriptionsRoles.addAll(oldSubRoles.values());
                //upsert oldSubRoles.values();
                if (agentRole != null) {
                    agentSubscriptionsRoles.add(agentRole);
                    //upsert agentRole;
                }
            }
            System.debug('subRoles.values ---> ' + subRoles.values());
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : genericRequestTypes){
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.MessageSent__c = Json.serialize(gt);
                
                if (hasFailedSFQP)
                    sf.QPStatus__c = 'Failed-SFQP';
                else
                    sf.QPStatus__c = status;
                
                sf.QPMessage__c = statusMessage;
                
                if (gt.agentResource== null || ''.equals(gt.agentResource.action)){
                    System.debug('sf.MessageSent__c ----> ' + sf.MessageSent__c);
                    System.debug('gt.sysParty.sysPrKey ----> ' + gt.sysParty.sysPrKey);
                    System.debug('gt.sysParty.sysPRRoleKey ----> ' + gt.sysParty.sysPRRoleKey);
                    if(gt.sysParty.sysPrKey != null) {
                        if(agentRole != null && gt.sysParty.sysPrKey.equals(agentRole.sysPrRoleKey__c)) {
                           sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                            sf.ObjectType__c = 'Subscription_Role__c';
                            sf.SFMessageID__c = gt.sysParty.uuid;
                            sf.relatedid__c = agentRole.id;
                            
                            SFQPConnectors.add(sf);
                        } else {
                            for(String rType : oldRoleNamesMap.keySet()) {
                                if(gt.sysParty.sysPrKey.equals(oldRoleNamesMap.get(rType))) {
                                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                                    sf.ObjectType__c = 'Subscription_Role__c';
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    sf.relatedid__c = oldSubRoles.get(rType).id;
                                    
                                    SFQPConnectors.add(sf);
                                }
                            }
                            for(String rType : subRelationship.keySet()) {
                                
                                if(gt.sysParty.uuid.equals(rType)) {
                                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                                    sf.ObjectType__c = 'Relationship__c';
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    sf.relatedid__c = subRelationship.get(rType);
                                    
                                    SFQPConnectors.add(sf);
                                }
                            }
                        }
                    } else if(gt.sysParty.sysPRRoleKey != null) {
                            Map<String,SFQPConnector__c> subRoleSFQP = new Map<String,SFQPConnector__c>();
                            for(String rType : roleNamesMap.keySet()) {
                                //System.debug('roleListMappings.get('+rType+') ----> ' + roleListMappings.get(rType));
                                if(gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(rType))) {
                                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                                    sf.ObjectType__c = 'Subscription_Role__c';
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    //sf.relatedid__c = subRoles.get(rType).id;
                                    system.debug('*** rType : ' + rType);
                                    if(!subIdRoleTypeSFQPConnectors.containskey(newSubscription.Id))
                                        subIdRoleTypeSFQPConnectors.put(newSubscription.Id,new Map<String,SFQPConnector__c>());
                                    
                                    subIdRoleTypeSFQPConnectors.get(newSubscription.Id).put(rType,sf);
                                }
                            }
                            
                            for(String rType : subRelationship.keySet()) {
                                
                                if(gt.sysParty != null && gt.sysParty.uuid.equals(rType)) {
                                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                                    sf.ObjectType__c = 'Relationship__c';
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    sf.relatedid__c = subRelationship.get(rType);
                                    
                                    SFQPConnectors.add(sf);
                                }
                            }                        
                    }
                    
                    if(sf.ObjectType__c == null) {
                        System.debug('No SFQPConnector created for gt: ' + gt);
                    }   
                    
                } else {
                    sf.SFDC_Transaction_ID__c = '' + QPRequest.sfdcMessageId;
                    sf.relatedid__c = newSubscription.id;
                    sf.SFMessageID__c = gt.agentResource.uuid;
                    sf.ObjectType__c = 'Subscription';
                    
                    SFQPConnectors.add(sf);
                }                
                
            } //End of For loop
            //upsert sfconnectorList;
        }
        
        for(String subscriptionId : subIdRoleTypeSubscriptionRoles.keyset()){
            upsert subIdRoleTypeSubscriptionRoles.get(subscriptionId).values();
            
            if(subIdRoleTypeSFQPConnectors.keyset().contains(subscriptionId)){
                Map<String,SFQPConnector__c> roleTypeSFQPConnectors = new Map<String,SFQPConnector__c>();            
                roleTypeSFQPConnectors = subIdRoleTypeSFQPConnectors.get(subscriptionId);
                system.debug('*** roleTypeSFQPConnectors : ' + roleTypeSFQPConnectors );
                
                for(String roleType : roleTypeSFQPConnectors.keyset()){
                    system.debug('*** roleType  Name: ' + roleType);
                    SFQPConnector__c sf = roleTypeSFQPConnectors.get(roleType);
                    sf.relatedid__c = subIdRoleTypeSubscriptionRoles.get(subscriptionId).get(roleType).Id;
                    SFQPConnectors.add(sf);
                }
            }           
        }           
        
        upsert oldSubscriptionsRoles;
        upsert agentSubscriptionsRoles;      
        
        upsert relationships;
        upsert SFQPConnectors;
    }
    
    
    /**
    *
    **/
    private static list<typesWebserviceQueueprocessorCrmMris.GenericRequestType> buildAgentStructureMessage(Subscriptions__c subscription, String action,String privateEmail) {
        System.debug('Inside buildAgentStructureMessage');
        
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gtAgent = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        gtAgent.sequenceNumber = '001';
       
        gtAgent.agentResource = new typesWebserviceQueueprocessorCrmMris.AgentStructure();
        gtAgent.agentResource.action = action;
        if('UPDATE'.equals(action)) {
            gtAgent.agentResource.agentKey = subscription.AgentKey__c;
        }
           
        gtAgent.agentResource.agentID = subscription.Name;
        gtAgent.agentResource.agentUserName  = gtAgent.agentResource.agentID;
        if (Utils.isNotNull(subscription.NRDS_ID__c)) {
            gtAgent.agentResource.NRDSMemberID = subscription.NRDS_ID__c;
        } else {
            gtAgent.agentResource.NRDSMemberID = SubscriptionUtility.nullString;
        }
        
        if(Utils.isNotNull(subscription.Addl_Display_Name__c)) {
            gtAgent.agentResource.agentStreetAdditionalInfo = subscription.Addl_Display_Name__c;
        } else {
            gtAgent.agentResource.agentStreetAdditionalInfo = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Box__c)) {
            gtAgent.agentResource.agentBoxNumber = subscription.Box__c;
            } else {
            gtAgent.agentResource.agentBoxNumber = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Mobile_Phone__c)) 
            gtAgent.agentResource.agentCellPhone = subscription.Mobile_Phone__c.replaceAll('\\D','');

/*********************replaced per: B-03924
        if(Utils.isNotNull(subscription.City__c)) {
            gtAgent.agentResource.agentCity = AddressUtility.getCSCity(subscription.City__c, 'SUBSCRIPTION');
            } else {
            gtAgent.agentResource.agentCity = SubscriptionUtility.nullString;
        }
******************************************/
        if(Utils.isNotNull(subscription.City__c) &&
           Utils.isNotNull(subscription.County__c) &&
           Utils.isNotNull(subscription.State__c)) {
            
            String lval = subscription.City__c + '-' + subscription.County__c + '-' + subscription.State__c;
           
            //gtAgent.agentResource.agentCity =
            // AddressUtility.getCSCityAll(subscription.City__c, subscription.County__c, subscription.State__c, 'SUBSCRIPTION');
            //Elena's change - added next two lines - that is it--  April 21
           Map<String, String> cityMap = AddressUtility.getCSCityAll(new List<String> {lval}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentCity = cityMap.get(lval); 
           //Elena end of changes april 21
            } else {
            gtAgent.agentResource.agentCity = SubscriptionUtility.nullString;
        }
       /* if(Utils.isNotNull(subscription.Country__c)) {
            Map<String,String> csCountries = AddressUtility.getCSCountry(new List<String>{subscription.Country__c}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentCountry = csCountries.get(subscription.Country__c);
            } else {
            gtAgent.agentResource.agentCountry = SubscriptionUtility.nullString;
        } */
        
        //EM changes to counties...8-8-2016
        // if(Utils.isNotNull(subscription.County__c){
        if(Utils.isNotNull(subscription.County__c)&&
           Utils.isNotNull(subscription.State__c)) {
           String lvalc = subscription.County__c + '-' + subscription.State__c;
           
            //Map<String,String> csCounties = AddressUtility.getCSCounty(new List<String>{subscription.County__c}, 'SUBSCRIPTION');
            //gtAgent.agentResource.agentCounty = csCounties.get(subscription.County__c);
            
            Map<String,String> csCounties = AddressUtility.getCSCounty(new List<String>{lvalc}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentCounty = csCounties.get(lvalc);            
            } else {
            gtAgent.agentResource.agentCounty = SubscriptionUtility.nullString;
        }
        //end of changes
        if(Utils.isNotNull(subscription.Public_Email__c)) {
            gtAgent.agentResource.agentEmail = subscription.Public_Email__c;
            } else {
            gtAgent.agentResource.agentEmail = SubscriptionUtility.nullString;
        }
       if (Utils.isNotNull(subscription.Private_Email__c)) {
            gtAgent.agentResource.agentPrivateEmail = subscription.Private_Email__c;
       } else {
            gtAgent.agentResource.agentPrivateEmail = SubscriptionUtility.nullString;
        }
        
        if(Utils.isNotNull(subscription.Fax__c)) {
            gtAgent.agentResource.agentFax = subscription.Fax__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentFax = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Home_Fax__c)) {
            gtAgent.agentResource.agentFaxHome = subscription.Home_Fax__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentFaxHome = SubscriptionUtility.nullString;
        }
       if (null != subscription.Date_Joined__c) {
            gtAgent.agentResource.agentJoinDate = subscription.Date_Joined__c.format();
       } 
        if(Utils.isNotNull(subscription.Primary_Phone__c)) {
            gtAgent.agentResource.agentHomePhone = subscription.Primary_Phone__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentHomePhone = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Agent_Office_Phone__c)) {
            gtAgent.agentResource.agentOfficePhone = subscription.Agent_Office_Phone__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentOfficePhone = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Pager__c)) {
            gtAgent.agentResource.agentPager = subscription.Pager__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentPager = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Zip__c)) {
            gtAgent.agentResource.agentPostalCode = subscription.Zip__c;
            } else {
            gtAgent.agentResource.agentPostalCode = SubscriptionUtility.nullString;
        }
        
        if (null != subscription.Date_Reinstated__c){ 
            gtAgent.agentResource.agentReinstatementDate = subscription.Date_Reinstated__c.format();
        } 
        if(Utils.isNotNull(subscription.State__c)) {
            Map<String,String> csStates = AddressUtility.getCSState(new Map<String,String>{subscription.State__c => subscription.Country__c}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentState  = csStates.get(subscription.State__c);
         } else {
            gtAgent.agentResource.agentState = SubscriptionUtility.nullString;
        }
       
       /* if(Utils.isNotNull(subscription.Street_Number_Suffix__c)) {
            gtAgent.agentResource.agentStreetAdditionalInfo = subscription.Street_Number_Suffix__c;
        }  else {
            gtAgent.agentResource.agentStreetAdditionalInfo = SubscriptionUtility.nullString;
        }*/
        if(Utils.isNotNull(subscription.Street_Direction__c)) {
            Map<String,String> csStreetDirections = AddressUtility.getCSStreetDirection(new List<String>{subscription.Street_Direction__c}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentStreetDirSuffix = csStreetDirections.get(subscription.Street_Direction__c);
        } else {
            gtAgent.agentResource.agentStreetDirSuffix = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Street_Name__c)) {
            gtAgent.agentResource.agentStreetName = subscription.Street_Name__c;
        }
        else {
            gtAgent.agentResource.agentStreetName = 'NO STREET NAME';
        }
        if(Utils.isNotNull(subscription.Street_Number__c)) {
            gtAgent.agentResource.agentStreetNumber = getNumberFromMixString(subscription.Street_Number__c);
        } else {
            gtAgent.agentResource.agentStreetNumber = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Street_Type__c)) {
            Map<String,String> csStreetSuffixes = AddressUtility.getCSStreetType(new List<String>{subscription.Street_Type__c}, 'SUBSCRIPTION');
            gtAgent.agentResource.agentStreetSuffix = csStreetSuffixes.get(subscription.Street_Type__c);
            
        } else {
            gtAgent.agentResource.agentStreetSuffix = SubscriptionUtility.nullString;
        }
        if (null != subscription.Date_Terminated__c) {
            gtAgent.agentResource.agentTerminationDate = subscription.Date_Terminated__c.format();
        }
        if(Utils.isNotNull(subscription.Unit__c)) {
            //gtAgent.agentResource.agentUnitNumber = AddressUtility.getCSStreetUnitTypes(subscription.Unit_Type__c, 'SUBSCRIPTION');
            gtAgent.agentResource.agentUnitNumber = subscription.Unit__c;
         } else {
            gtAgent.agentResource.agentUnitNumber = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.VM_Ext__c)) {
            gtAgent.agentResource.agentVoiceMailExt = subscription.VM_Ext__c;
            } else {
            gtAgent.agentResource.agentVoiceMailExt = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Voicemail__c)) {
            gtAgent.agentResource.agentVoiceMailNum = subscription.Voicemail__c.replaceAll('\\D','');
            } else {
            gtAgent.agentResource.agentVoiceMailNum = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Website__c)) {
            gtAgent.agentResource.agentWWW = subscription.Website__c;
        } else {
            gtAgent.agentResource.agentWWW = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(subscription.Zip_4__c)) {
            gtAgent.agentResource.agentZip4 = subscription.Zip_4__c;
        } else {
            gtAgent.agentResource.agentZip4 = SubscriptionUtility.nullString;
        }
        Contact contact = [SELECT id, Birthdate, Professional_Designations__c, FirstName, LastName, Salutation, 
                            Middle_Name__c, Suffix__c, Nickname__c, Name
                            from Contact where id = :subscription.Contact__c];
                                        
        if(contact.Birthdate != null)
            gtAgent.agentResource.agentBirthDate = contact.Birthdate.format();
            
        if(Utils.isNotNull(contact.Professional_Designations__c)) {
            gtAgent.agentResource.agentDesignations = contact.Professional_Designations__c.replaceAll(';',',');
            //gtAgent.agentResource.agentDesignations = contact.Professional_Designations__c;
        }
        else {
            gtAgent.agentResource.agentDesignations = SubscriptionUtility.nullString;
        } 
        if(Utils.isNotNull(contact.FirstName)) {
            gtAgent.agentResource.agentFirstName = contact.FirstName;
        } else {
            gtAgent.agentResource.agentFirstName = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(contact.LastName)) {
            gtAgent.agentResource.agentLastName = contact.LastName;
        } else {
            gtAgent.agentResource.agentLastName = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(contact.Salutation)) {
            if ('Dr.'.equals(contact.Salutation)) {
                gtAgent.agentResource.agentSalutation = '10000000407';
            } else if ('Miss'.equals(contact.Salutation)) {
                gtAgent.agentResource.agentSalutation = '10030442388';
            } else if ('Mr.'.equals(contact.Salutation)) {
                gtAgent.agentResource.agentSalutation = '10000000409';
            } else if ('Ms.'.equals(contact.Salutation)) {
                gtAgent.agentResource.agentSalutation = '10000000411';
            } else if ('Mrs.'.equals(contact.Salutation)) {
                gtAgent.agentResource.agentSalutation = '10000000410';
            }
            
        } else {
            gtAgent.agentResource.agentSalutation = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(contact.Middle_Name__c)) {
            gtAgent.agentResource.agentMiddleName = contact.Middle_Name__c;
            if (contact.Middle_Name__c.length() > 0)
                gtAgent.agentResource.agentMiddleInitial = contact.Middle_Name__c.substring(0,1);
        } else {
            gtAgent.agentResource.agentMiddleName = SubscriptionUtility.nullString;
            gtAgent.agentResource.agentMiddleInitial = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(contact.Nickname__c))  {
            gtAgent.agentResource.agentNickName = contact.Nickname__c;
        } else {
            gtAgent.agentResource.agentNickName = SubscriptionUtility.nullString;
        }
        if(Utils.isNotNull(contact.Suffix__c)) {
            gtAgent.agentResource.agentNameSuffix = contact.Suffix__c;
        } else {
            gtAgent.agentResource.agentNameSuffix = SubscriptionUtility.nullString;
        }
            
        Account relatedLocation = [SELECT id, OfficeKey__c, Name, Account_Name__c from Account 
                                        where id = :subscription.Related_Location_Broker_Office__c];
        gtAgent.agentResource.officeKey = relatedLocation.OfficeKey__c;
        
        gtAgent.agentResource.uuid = ''+Utils.getRandomNumber();
        
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> gtList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        gtList.add(gtAgent);
        return gtList;
    }
    
    /*
        @Description: Method to convert mix string to Number.(US) 
    */
    private static String getNumberFromMixString(String mixString){
        if(null != mixString && mixString.trim() != ''){
            for(String numb:mixString.splitByCharacterType()){ 
                if(numb.isNumeric()){
                    return numb;
                }
            }
        }
        return null;
    }
}