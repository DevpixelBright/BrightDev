global without sharing class AccountProcessingUtility {

    public static Map<Id, Account> parentAccountsMap;
    public static Map<String, List<Relationship__c>> relationshipMap;
    public static Map<String, List<Relationship__c>> relatedAccountsMap;
    public static Map<String, List<Related_Association__c>> relatedAssociationMap;
    
    public static Map<String, String> statesCSMap;
    public static Map<String, String> streetTypesCSMap;
    public static Map<String, String> streetDirectionsCSMap;
    public static Map<String, String> countiesCSMap;
    public static Map<String, String> countriesCSMap;
    public static Map<String, String> unitTypesCSMap;
    public static Map<String, String> cityLongValuesCSMap;
    public static Map<String, String> countyLongValuesCSMap;
    public static Boolean isDirect = false;
    
    global static void sendAccountsToQueueProcessor(String action, Map<Id,String> newJsonAccountString, Map<Id,String> oldJsonAccountString) {
       isDirect = true;
       if (!System.isFuture()) {
          sendAccountsToQueueProcessorFuture(action, newJsonAccountString, oldJsonAccountString);
       } else {
          sendAccountsToQueueProcessorOrig(action, newJsonAccountString, oldJsonAccountString);
       }
    }
                                                    
    @future (callout=true)
    global static void sendAccountsToQueueProcessorFuture(String action, Map<Id,String> newJsonAccountString, Map<Id,String> oldJsonAccountString) {
       sendAccountsToQueueProcessorOrig(action, newJsonAccountString, oldJsonAccountString);
    }

    global static void sendAccountsToQueueProcessorOrig(String action, Map<Id,String> newJsonAccountString, Map<Id,String> oldJsonAccountString) {    

        getParentAccountsInformation(newJsonAccountString);
        getRelationshipInformation(newJsonAccountString);
        getRelatedAccountInformation(newJsonAccountString);
        getRelatedAssociationInformation(newJsonAccountString);
        
        Map<String, String> statesMap = new Map<String, String>();
        List<String> streetTypes = new List<String>();
        List<String> streetDirections = new List<String>();
        List<String> counties = new List<String>();
        List<String> countries = new List<String>();
        List<String> unitTypes = new List<String>();
        List<String> cityLongValues = new List<String>();
        List<String> countyLongValues = new List<String>();
        for (Id accountId: newJsonAccountString.keySet()) {
            Account account = (Account) System.JSON.deserialize(newJsonAccountString.get(accountId),sObject.class);
            if(String.isNotBlank(account.State__c))
                statesMap.put(account.State__c, account.Country__c);
            if(String.isNotBlank(account.Street_Type__c))
                streetTypes.add(account.Street_Type__c);
            if(String.isNotBlank(account.Street_Direction__c))
                streetDirections.add(account.Street_Direction__c);
            if(String.isNotBlank(account.County__c)&& String.isNotBlank(account.State__c) ){
                  counties.add(account.County__c);
                  countyLongValues.add(account.County__c+ '-' + account.State__c);}
            if(String.isNotBlank(account.Country__c))
                countries.add(account.Country__c);
            if(String.isNotBlank(account.Unit_Type__c))
                unitTypes.add(account.Unit_Type__c);
            if(String.isNotBlank(account.City__c) && String.isNotBlank(account.State__c) && String.isNotBlank(account.County__c))
                cityLongValues.add(account.City__c + '-' + account.County__c + '-' + account.State__c);
        }
        
        /* Get CS address utility values */
        statesCSMap = new Map<String, String>();
        streetTypesCSMap = new Map<String, String>();
        streetDirectionsCSMap = new Map<String, String>();
        countiesCSMap = new Map<String, String>();
        countriesCSMap = new Map<String, String>(); 
        unitTypesCSMap = new Map<String, String>();
        cityLongValuesCSMap = new Map<String, String>(); 
        countyLongValuesCSMap = new Map<String, String>(); 
        
        statesCSMap = AddressUtility.getCSState(statesMap, 'ACCOUNT');
        System.debug('**** statesMap:' + statesMap);
        System.debug('**** statesCSMap:' + statesCSMap);
                
        streetTypesCSMap = AddressUtility.getCSStreetType(streetTypes, 'ACCOUNT');
        System.debug('**** streetTypes:' + streetTypes);
        System.debug('**** streetTypesCSMap:' + streetTypesCSMap);
                
        streetDirectionsCSMap = AddressUtility.getCSStreetDirection(streetDirections, 'ACCOUNT');
        System.debug('**** streetDirections:' + streetDirections);
        System.debug('**** streetDirectionsCSMap :' + streetDirectionsCSMap);
                
        //countiesCSMap = AddressUtility.getCSCounty(counties, 'ACCOUNT');
        countyLongValuesCSMap  = AddressUtility.getCSCounty(countyLongValues, 'ACCOUNT');
        System.debug('**** counties:' + countyLongValues);
        System.debug('**** countiesCSMap:' + countyLongValuesCSMap);
                
        countriesCSMap = AddressUtility.getCSCountry(countries, 'ACCOUNT');
        System.debug('**** countries:' + countries);
        System.debug('**** countriesCSMap :' + countriesCSMap );
                
        unitTypesCSMap = AddressUtility.getCSStreetUnitTypes(unitTypes, 'ACCOUNT');       
        System.debug('**** unitTypes:' + unitTypes);
        System.debug('**** unitTypesCSMap :' + unitTypesCSMap );
        
        cityLongValuesCSMap = AddressUtility.getCSCityAll(cityLongValues, 'ACCOUNT');       
        System.debug('**** cityLongValues:' + cityLongValues);
        System.debug('**** cityLongValuesCSMap :' + cityLongValuesCSMap);        
        
        if('INSERT'.equals(action))
            processCreateForAccounts(newJsonAccountString);
        else if ('UPDATE'.equals(action))
            processUpdateForAccounts(newJsonAccountString,oldJsonAccountString);
        else  
            throw new MRISException('Error! Invalid action type "' + action + '" passed to AccountProcessingUtility.  ' + 'Please correct this in order to continue further',true);                  
       
    }  
    
    global static void processUpdateForAccounts(Map<Id,String> jsonStringList, Map<Id,String> oldJsonStringList) {
        System.debug('*** Inside processUpdateForAccounts');
        /* 
            Check what has changed.  Do an office update irrespecive 
            Update is slightly complex logic than other things
        */
        List<SFQPConnector__c> sfconnectorList = new List<SFQPConnector__c>();
        List<SObject> toDelete = new List<SObject>();
        for (ID accountID: jsonStringList.keySet()) {
            
            boolean hasChanged = false;           
            
            Map<String,String> roleNamesMap = new Map<String,String>();
            Map<String,String> oldRoleNamesMap = new Map<String,String>();          
            
            typesWebserviceQueueprocessorCrmMris.InputRequest ir = new typesWebserviceQueueprocessorCrmMris.InputRequest();
            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  gtList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
            
            Account account = (Account) System.JSON.deserialize(jsonStringList.get(accountID), sObject.class);
            Account oldAccount = (Account) System.JSON.deserialize(oldJsonStringList.get(accountID),sObject.class);
            System.debug('*** Account: ' + account.Name);
                       
            /* Determine anything on account has changed */
            if ((oldAccount.Account_Name__c != account.Account_Name__c)
                ||(oldAccount.Addl_Display_Name__c != account.Addl_Display_Name__c)
                ||(oldAccount.Billing_Addl_Display_Name__c != account.Billing_Addl_Display_Name__c)
                ||(oldAccount.Billing_Box__c != account.Billing_Box__c)
                ||(oldAccount.Billing_City__c != account.Billing_City__c)
                ||(oldAccount.Billing_Country__c != account.Billing_Country__c)
                ||(oldAccount.Billing_County__c != account.Billing_County__c)
                ||(oldAccount.Billing_State__c  != account.Billing_State__c)
                ||(oldAccount.Billing_Street_Direction__c != account.Billing_Street_Direction__c)
                ||(oldAccount.Billing_Street_Name__c != account.Billing_Street_Name__c)
                ||(oldAccount.Billing_Street_Number_Suffix__c != account.Billing_Street_Number_Suffix__c)
                ||(oldAccount.Billing_Unit_Number__c != account.Billing_Unit_Number__c)
                ||(oldAccount.Billing_Unit_Type__c != account.Billing_Unit_Type__c)
                ||(oldAccount.Billing_Zip_4__c != account.Billing_Zip_4__c)
                ||(oldAccount.Billing_Zip__c != account.Billing_Zip__c)
                ||(oldAccount.BillingCity != account.BillingCity)
                ||(oldAccount.BillingCountry != account.BillingCountry)
                ||(oldAccount.BillingPostalCode != account.BillingPostalCode)
                ||(oldAccount.BillingState != account.BillingState)
                ||(oldAccount.BillingStreet != account.BillingStreet)
                ||(oldAccount.Office_Email__c != account.Office_Email__c)
                ||(oldAccount.Box__c != account.Box__c)
                ||(oldAccount.BrokerAddress__c != account.BrokerAddress__c)
                ||(oldAccount.City__c != account.City__c)
                ||(oldAccount.CONTACT1FAX__c != account.CONTACT1FAX__c)
                ||(oldAccount.CONTACT1NAME__c != account.CONTACT1NAME__c)
                ||(oldAccount.CONTACT1OFFICEPHONE__c != account.CONTACT1OFFICEPHONE__c)
                ||(oldAccount.CONTACT1TITLE__c != account.CONTACT1TITLE__c)
                ||(oldAccount.Copy_Address_to_Billing__c != account.Copy_Address_to_Billing__c)
                ||(oldAccount.Country__c != account.Country__c)
                ||(oldAccount.County__c != account.County__c)
                ||(oldAccount.CUSTOMERADDRESSLINE1__c != account.CUSTOMERADDRESSLINE1__c)
                ||(oldAccount.CUSTOMERADDRESSLINE2__c != account.CUSTOMERADDRESSLINE2__c)
                ||(oldAccount.CUSTOMEREMAIL__c != account.CUSTOMEREMAIL__c)
                ||(oldAccount.CUSTOMERFAX__c != account.CUSTOMERFAX__c)
                ||(oldAccount.CUSTOMEROFFICEPHONE__c != account.CUSTOMEROFFICEPHONE__c)
                ||(oldAccount.CUSTOMERPOSTALCODE__c != account.CUSTOMERPOSTALCODE__c)
                ||(oldAccount.Date_Joined__c != account.Date_Joined__c)
                ||(oldAccount.Date_Terminated__c != account.Date_Terminated__c)               
                ||(oldAccount.Fax != account.Fax)
                ||(oldAccount.Full_Street_Address__c != account.Full_Street_Address__c)
                ||(oldAccount.Name != account.Name)
                ||(oldAccount.Phone != account.Phone)
                ||(oldAccount.PIN__c != account.PIN__c)
                ||(oldAccount.Zip_4__c != account.Zip_4__c)
                ||(oldAccount.Zip__c != account.Zip__c)
                ||(oldAccount.Unit__c != account.Unit__c)
                ||(oldAccount.Unit_Type__c != account.Unit_Type__c)
                ||(oldAccount.QAS_Mailing_Unit_Type__c != account.QAS_Mailing_Unit_Type__c)
                ||(oldAccount.Website != account.Website)
                ||(oldAccount.Trading_As__c != account.Trading_As__c)
                ||(oldAccount.TickerSymbol != account.TickerSymbol)
                ||(oldAccount.State__c != account.State__c)
                ||(oldAccount.Street_Type__c != account.Street_Type__c)
                ||(oldAccount.Street_Number_Suffix__c != account.Street_Number_Suffix__c)
                ||(oldAccount.Street_Number__c != account.Street_Number__c)
                ||(oldAccount.Street_Name__c != account.Street_Name__c)
                ||(oldAccount.Street_Direction__c != account.Street_Direction__c)
                ||(oldAccount.Status__c != account.Status__c)
                ||(oldAccount.State__c != account.State__c))
            {
                
                System.debug('*** Account has changed');
                hasChanged = true;
                ir.command = QueueProcessorMappings.commandTypes.get('RULE4');
                gtList = buildOfficeResourceMessage(account, 'UPDATE');
            }
             
            /* Determine if shareholder has changed */
            if(oldAccount.Shareholder_Board__c != account.Shareholder_Board__c) {
                System.debug('*** Shareholder has changed: ' + account.id);
                if(account.CS_Shareholder_ID__c != null && !'Yes'.equals(account.Shareholder_Board__c)) {
                    account.CS_Shareholder_ID__c = null;                
                    if (!(oldAccount.CS_Shareholder_ID__c == null) || (''.equals(oldAccount.CS_Shareholder_ID__c))) {
                        oldRoleNamesMap.put('Stockholder', '');
                        if(!hasChanged) 
                         ir.command = QueueProcessorMappings.commandTypes.get('RULE5');
                    }                     
                }
                else if('Yes'.equals(account.Shareholder_Board__c)) {
                    roleNamesMap.put('Stockholder', '');
                    if(!hasChanged) 
                        ir.command = QueueProcessorMappings.commandTypes.get('RULE5');                    
                }               
            }
            
            /* Determine if the account type has changed */
            if (oldAccount.Type != null && !oldAccount.Type.equals(account.Type)) {
                System.debug('*** Account type has changed: ' + account.id);
                /* Delete old roles .. End Date the old Office Role */
                if (!(oldAccount.CS_AccountTypeRole_ID__c == null || ''.equals(oldAccount.CS_AccountTypeRole_ID__c))) {
                    System.debug('*** Adding old Account type roles: ' + oldAccount.CS_AccountTypeRole_ID__c);
                    oldRoleNamesMap.put(oldAccount.Type, '');
                }
                roleNamesMap.put(account.Type, '');
                
                if (!hasChanged)
                    ir.command = QueueProcessorMappings.commandTypes.get('RULE5');    
            }
            
            /* Determine if the Company type has changed */
            if (oldAccount.Company_Type__c == null) 
                oldAccount.Company_Type__c = '';
            
            if (account.Company_Type__c == null) 
                account.Company_Type__c = '';
            
            boolean isCompanyOffice = false;
            if (!oldAccount.Company_Type__c.equals(account.Company_Type__c) && !'Corporate'.equals(account.type)) {
                System.debug('*** Company type has changed: ' + account.id);
                
                if(Utils.isNotNull(account.Company_Type__c)) {
                    /* Add new role */
                    System.debug('*** Adding new Account Company type roles.');
                    if (Utils.isNotNull(account.ParentId)) {
                        Account parentAccount = parentAccountsMap.get(account.parentid);                     
                        roleNamesMap.put(account.Company_Type__c, parentAccount.OfficeKey__c);                 
                    } 
                    else
                        roleNamesMap.put(account.Company_Type__c,'');   
                }
            
                if(Utils.isNotNull(oldAccount.Company_Type__c) && (null !=  oldAccount.CS_CompanyTypeRole_ID__c) && (!''.equals(oldAccount.CS_CompanyTypeRole_ID__c))) {
                    System.debug('*** Old Company type has changed: ' + oldAccount.CS_CompanyTypeRole_ID__c);
                    
                    /* Delete old role */
                    if ('Corporate Office'.equals(oldAccount.Company_Type__c)) 
                        oldRoleNamesMap.put('Corporate', '');
                    else 
                        oldRoleNamesMap.put(oldAccount.Company_Type__c, '');          
                }
                         
                if (!hasChanged)
                    ir.command = QueueProcessorMappings.commandTypes.get('RULE5');               
            }
        
            /* Determine if status has changed */
            if (!(oldAccount.Status__c.equals(account.status__C) || 'Incomplete'.equals(account.status__C))) {
                System.debug('*** Status has changed: ' + account.id);
                if('Active'.equals(oldAccount.Status__c) && 'Inactive'.equals(account.Status__c)) {
                    
                    oldRoleNamesMap.put('Office', '');
                    oldRoleNamesMap.put(account.Type, '');
                    account.CS_AccountTypeRole_ID__c = null;
                    account.Date_Terminated__c = Date.today();
                    
                    if(Utils.isNotNull(account.Company_Type__c) && account.Company_Type__c == 'Branch Office') {
                        ir.command = QueueProcessorMappings.commandTypes.get('RULE16');
                        
                        try {
                            Account broker = parentAccountsMap.get(account.parentid);
                            gtList.add(SysPartyRoleProcessingUtility.buildDeleteStruct(gtList.size()+1, account.CS_CompanyTypeRole_ID__c, account.OfficeKey__c, broker.OfficeKey__c));
                        }  catch (NullPointerException ex) {
                            gtList.add(SysPartyRoleProcessingUtility.buildDeleteStruct(gtList.size()+1, account.CS_CompanyTypeRole_ID__c, account.OfficeKey__c, null));
                        }
                        
                        account.CS_CompanyTypeRole_ID__c = null;
                    }
                    
                    if('Broker Office'.equals(account.Company_Type__c)) {
                        ir.command = QueueProcessorMappings.commandTypes.get('RULE15');
                        try {                  
                            Relationship__c rel = [SELECT id, 
                                                          SysPrRoleKey__c,
                                                          Subscription__c,
                                                          Broker_Office__c 
                                                   FROM Relationship__C 
                                                   WHERE Broker_Office__c = :account.id 
                                                   AND Relationship_Type__c = 'Broker Of Record' 
                                                   AND Relationship_End_Date__c = null LIMIT 1];
                            toDelete.add(rel);
                            
                            Account broker = [SELECT OfficeKey__c FROM Account WHERE id = :rel.Broker_Office__c];
                            Subscriptions__c sub = [SELECT AgentKey__c FROM Subscriptions__c WHERE id = :rel.Subscription__c];
                            gtList.add(SysPartyRoleProcessingUtility.buildDeleteStruct(gtList.size()+1, rel.SysPrRoleKey__c, sub.AgentKey__c, broker.OfficeKey__c));                               
                        } 
                        catch (QueryException ex) {
                        
                        }
                    }
                }
                else if('Inactive'.equals(oldAccount.Status__c) && 'Active'.equals(account.Status__c)) {
                    roleNamesMap.put('Office', '');
                    roleNamesMap.put(account.Type, '');
                    if ('Branch Office'.equals(account.Company_Type__c)) {
                        if (Utils.isNotNull(account.ParentId)) {
                            Account parentAccount = parentAccountsMap.get(account.parentid);
                            roleNamesMap.put(account.Company_Type__c,parentAccount.OfficeKey__c);  
                        } 
                        else
                            roleNamesMap.put(account.Company_Type__c,'');  
                    }
                    ir.command = QueueProcessorMappings.commandTypes.get('RULE17');
                }
            }
       
            Set<String> roleNames = new Set<String>();
            roleNames.addall(roleNamesMap.keySet());
            roleNames.addall(oldRoleNamesMap.keySet());
            
            Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
            Map<String,String> tempRoleListMappings = new Map<String,String>();
            Map<String,String> roleListMappings = new Map<String,String>();  
            
            for (Id i : mappings.keySet()) {
                CornerstoneMappings__c cm = mappings.get(i);
                tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
            }
        
            /* Swap the maps to get the correct order */
            for (String s: roleNames){
                System.debug('*** s: ' + s);
                System.debug('*** tempRoleListMappings.get(s): ' + tempRoleListMappings.get(s));
                roleListMappings.put(s,tempRoleListMappings.get(s));
            }
            
            Integer i = gtList.size() + 1;
            gtList.addAll(SysPartyRoleProcessingUtility.processUpdateRoles(roleNamesMap,oldRoleNamesMap,roleListMappings,account,oldAccount, i));
                       
            /* Exit if there are no rules set and there are no updates */
            System.debug('*** command:' + ir.command);
            if (Utils.isNull(ir.command) || gtList.isEmpty()) {
                System.debug ('*** Exiting ***');
                return;
            }
            
            ir.requests = gtList;
            ir.sfdcMessageid = Utils.getRandomNumber();
            System.debug('*** ir: ' + ir);
            
            String status = 'Sent'; 
            String statusMessage = 'Success';
            typesWebserviceQueueprocessorCrmMris.OutputResponse resp; 
            boolean hasFailedSFQP = false;            
            try {
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = null;
                stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                System.debug('*** Stub: '  + stub);
                
                stub.inputHttpHeaders_x = new Map<String,String>();
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                resp = stub.salesForceRequest(ir);
                System.debug('*** response code: ' + resp.responseCode);
                System.debug('*** response description: ' + resp.responseDescription);                
                if('FAIL'.equals(resp.responseCode)) {
                    status = 'Failed';
                    statusMessage = resp.responseDescription;
                }           
            } 
            catch (Exception ex) {
                status = 'Failed';
                hasFailedSFQP = true;
                statusMessage = ex.getStackTraceString();
                System.debug('***' + ex);
            }
            
            System.debug('*** resp: ' +resp);
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : gtList) {
                
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.MessageSent__c = Json.serialize(gt);
                sf.SFDC_Transaction_ID__c = '' + ir.sfdcMessageId;
                
                if (gt.officeResource == null || ''.equals(gt.officeResource.action)) {
                    System.debug('*** sf.MessageSent__c: ' + sf.MessageSent__c);
                    System.debug('*** gt.sysParty.sysPrKey: ' + gt.sysParty.sysPrKey);
                    System.debug('*** gt.sysParty.sysPRRoleKey: ' + gt.sysParty.sysPRRoleKey);
                    System.debug('*** roleListMappings.get(Office): ' +roleListMappings.get('Office'));
                    System.debug('*** roleListMappings.get(account.Company_Type__c): ' +roleListMappings.get(account.Company_Type__c));
                    System.debug('*** roleListMappings.get(Corporate): ' +roleListMappings.get('Corporate'));
                    System.debug('*** roleListMappings.get(account.type): ' +roleListMappings.get(account.type));
                    
                    if (gt.sysParty.sysPrKey != null && gt.sysParty.sysPrKey.equals(oldAccount.CS_Office_Role_ID__c)) {
                        sf.ObjectType__c = 'AccountRole';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPrKey != null &&  gt.sysParty.sysPrKey.equals(oldAccount.CS_Shareholder_ID__c)) {
                        sf.ObjectType__c = 'AccountStockholder';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPrKey != null &&  gt.sysParty.sysPrKey.equals(oldAccount.CS_AccountTypeRole_ID__c)) {                       
                        sf.ObjectType__c = 'AccountType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPrKey != null && gt.sysParty.sysPrKey.equals(oldAccount.CS_CompanyTypeRole_ID__c)) {                       
                        sf.ObjectType__c = 'AccountCompanyType';
                        sf.relatedid__c = account.id;                 
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    }  
                    else if (gt.sysParty.sysPRRoleKey != null && gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Office'))) {
                        sf.ObjectType__c = 'AccountRole';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey != null && gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Stockholder'))) {
                        sf.ObjectType__c = 'AccountStockholder';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey != null && gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(account.type))) {                      
                        sf.ObjectType__c = 'AccountType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey != null && gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(account.Company_Type__c))) {                 
                        sf.ObjectType__c = 'AccountCompanyType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey != null && gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Corporate'))) {   
                        sf.ObjectType__c = 'AccountCompanyType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey != null) {
                        sf.ObjectType__c = 'Relationship__c';
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else {
                        System.debug('*** No sfqpconnector created for gt: ' + gt);
                        continue;
                    }
                    
                } 
                else {
                    sf.relatedid__c = account.id;
                    sf.SFMessageID__c = gt.officeResource.uuid;
                    sf.ObjectType__c = 'Account';
                }   
                
                if (hasFailedSFQP) 
                    sf.QPStatus__c = 'Failed-SFQP';
                else 
                    sf.QPStatus__c = status;
                
                sf.QPMessage__c = statusMessage;
                sfconnectorList.add(sf);
            } 


        }
        delete toDelete;        
        upsert sfconnectorList;
    }
    
    
    /**
    *  This is a utility method that processes the insert operation to queue processor
    *
    */
    global static void processCreateForAccounts(Map<Id,String> jsonStringList) {
        System.debug('*** Inside processInsertForAccounts');
        List<SFQPConnector__c> sfconnectorList = new List<SFQPConnector__c>();
        for (Id jsonString: jsonStringList.keySet()) {

            typesWebserviceQueueprocessorCrmMris.InputRequest ir = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        
            Account account = (Account) System.JSON.deserialize(jsonStringList.get(jsonString),sObject.class);
            System.debug(account.Name);

            List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  gtList = buildOfficeResourceMessage(account, 'CREATE');
            
            /* Build Sysparty Roles */
            Map<String,String> roleNamesMap = new Map<String,String>();
            if('RETS'.equals(account.Type) 
            || 'Virtual Tour Vendor'.equals(account.Type) 
            || 'Vendor'.equals(account.Type) 
            || 'MDS'.equals(account.Type)) {
                ir.command = QueueProcessorMappings.commandTypes.get('RULE34');
                if ('RETS'.equals(account.Type)) 
                     roleNamesMap.put('RETS','');
                else if ('Vendor'.equals(account.Type)) 
                    roleNamesMap.put('Vendor','');
                else if ('Virtual Tour Vendor'.equals(account.Type)) 
                    roleNamesMap.put('Virtual Tour Vendor','');

                roleNamesMap.put('Office','');//Default Roles
            } 
            else {
                ir.command = QueueProcessorMappings.commandTypes.get('RULE1');
                roleNamesMap.put('Office',''); 
                
                /* See if there is a parent for the account.  Get the information to add to the parent key */
                if (Utils.isNotNull(account.ParentId)) {
                    try {                        
                        Account parentAccount = parentAccountsMap.get(account.parentid);
                        System.debug('*** parentAccount: ' + parentAccount);
                        
                        if(Utils.isNotNull(account.Company_Type__c) && !'Corporate'.equals(account.type)) {
                            if('Corporate Office'.equals(account.Company_Type__c))
                                roleNamesMap.put('Corporate', parentAccount.OfficeKey__c);
                            else
                                roleNamesMap.put(account.Company_Type__c,parentAccount.OfficeKey__c);
                        }
                    } 
                    catch (Queryexception ex) {
                        System.debug('*** Did not found parent account id  for the parent id: ' +  account.parentid);
                        roleNamesMap.put(account.Company_Type__c,''); //Default Roles without parent
                    }
                } 
                else {                
                    if(Utils.isNotNull(account.Company_Type__c) && !'Corporate'.equals(account.type)) {
                        if('Corporate Office'.equals(account.Company_Type__c))
                            roleNamesMap.put('Corporate', '');
                        else
                            roleNamesMap.put(account.Company_Type__c,'');
                    }
                }
                roleNamesMap.put(account.type,'');
                if(account.Shareholder_Board__c != null && account.Shareholder_Board__c.equals('Yes'))
                    roleNamesMap.put('Stockholder', '');
            }
            
            /*  This is assuming the related account field in the relationship points to the parent account
                Relationships where this is the child
            */
            Map<String,String> childRelIDs = new Map<String,String>();
            if(relationshipMap.get(account.Id) != null) {
                List <Relationship__c> relationshipList =  relationshipMap.get(account.Id);                               
                for (Relationship__c r : relationshipList) {
                    if(Utils.isNotNull(r.Related_Account__r.OfficeKey__c)) {
                        roleNamesMap.put(r.Relationship_Type__c,r.Related_Account__r.OfficeKey__c);
                        childRelIDs.put(r.Relationship_Type__c,r.id);
                    }
                }
                System.debug('*** RolesNamesMap: ' + roleNamesMap);
            }
            
            /* Relationships where this is the parent */
            Map<String,String> roleNamesMapParentRel = new Map<String,String>();
            Map<String,String> parentRelIDs = new Map<String,String>();
            if(relatedAccountsMap.get(account.Id) != null) {
                List <Relationship__c> relationshipList1 =  relatedAccountsMap.get(account.Id);                                                    
                for (Relationship__c r : relationshipList1)  {
                    roleNamesMapParentRel.put(r.Relationship_Type__c,'');
                    parentRelIDs.put(r.Relationship_Type__c,r.id);
                }
            }
            
            if(relatedAssociationMap.get(account.Id) != null) {
                List<Related_Association__c> raList = relatedAssociationMap.get(account.Id);
                for (Related_Association__c r : raList) {
                    if(Utils.isNotNull(r.Association__r.OfficeKey__c)) {
                        if (r.Primary__c) {
                            roleNamesMap.put('Association Member Primary', r.Association__r.OfficeKey__c);
                            childRelIDs.put('Association Member Primary', r.id);
                        } else {
                            roleNamesMap.put('Association Member', r.Association__r.OfficeKey__c);
                            childRelIDs.put('Association Member', r.id);
                        }
                        
                    }
                }
            }            
            System.debug('***' + roleNamesMapParentRel);
            
            Set<String> roleNames = new Set<String>();
            roleNames.addAll(roleNamesMap.keySet());
            roleNames.addAll(roleNamesMapParentRel.keySet());
            
            Map<ID,CornerstoneMappings__c> mappings = QueueProcessorMappings.getCornerstoneMappings(roleNames);
            Map<String,String> tempRoleListMappings = new Map<String,String>();
            Map<String,String> roleListMappings = new Map<String,String>();  
            
            for (Id i : mappings.keySet()) {
                CornerstoneMappings__c cm = mappings.get(i);
                tempRoleListMappings.put(cm.typeName__C,cm.CornerstoneID__c);
                System.debug('*** Mapping Type: ' + cm.typeName__C);
            }
        
            /* Swap the maps to get the correct order */
            for (String s: roleNames) {
                System.debug('*** s: ' + s);
                System.debug('*** tempRoleListMappings.get(s): ' + tempRoleListMappings.get(s));
                roleListMappings.put(s, tempRoleListMappings.get(s));
            }
            
            String sysRoleID = Utils.splitByDigits(account.Name);
            Integer i = 2;
            gtList.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMap,mappings, roleListMappings, '', sysRoleID, i));
            i = gtList.size() + 1;
            gtList.addAll(SysPartyRoleProcessingUtility.processCreateStructRoles(roleNamesMapParentRel, mappings, roleListMappings, '', sysRoleID, i));
         
            /* Call QP and insert the messages */ 
            ir.requests  = gtList;
            ir.sfdcMessageId = Utils.getRandomNumber();
            System.debug('*** ir: ' + ir);
            
            String status = 'Sent';
            String statusMessage = 'Success';
            typesWebserviceQueueprocessorCrmMris.OutputResponse resp;
            boolean hasFailedSFQP = false;            
            try {
                Integer counter = 0;
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = null;
                try{
                    stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                }
                catch(CalloutException ex){
                    if(counter < 3){
                        stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                    }
                    counter = counter + 1;
                }
                
                stub.inputHttpHeaders_x = new Map<String,String>();
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                resp = stub.salesForceRequest(ir);
                System.debug('response code: '+resp.responseCode);
                if('FAIL'.equals(resp.responseCode)) {
                    status = 'Failed';
                    hasFailedSFQP = true;
                    statusMessage = resp.responseDescription;
                }           
            } catch (Exception ex){
                status = 'Failed';
                statusMessage = ex.getStackTraceString();
                System.debug(ex);
            }
            System.debug('*** resp: ' +resp);
            
            
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : gtList) {
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.MessageSent__c = Json.serialize(gt);
                sf.SFDC_Transaction_ID__c = '' + ir.sfdcMessageId;
                if (gt.officeResource == null || ''.equals(gt.officeResource.action)) {
                    System.debug('*** sf.MessageSent__c: ' + sf.MessageSent__c);
                    System.debug('*** gt.sysParty.sysPRRoleKey: ' + gt.sysParty);
                    System.debug('*** roleListMappings.get(Office): ' +roleListMappings.get('Office'));
                    System.debug('*** roleListMappings.get(account.Company_Type__c): ' +roleListMappings.get(account.Company_Type__c));
                    System.debug('*** roleListMappings.get(account.type): ' +roleListMappings.get(account.type));
                    
                    if(Test.isRunningTest())
                        gt.sysParty.sysPRRoleKey = 'Office';
                    
                    if (gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Office'))) {
                        sf.ObjectType__c = 'AccountRole';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Stockholder'))) {
                        sf.ObjectType__c = 'AccountStockholder';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(account.type))) {   
                        sf.ObjectType__c = 'AccountType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(account.Company_Type__c))) {  
                        sf.ObjectType__c = 'AccountCompanyType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else if (gt.sysParty.sysPRRoleKey.equals(roleListMappings.get('Corporate'))) {
                        sf.ObjectType__c = 'AccountCompanyType';
                        sf.relatedid__c = account.id;
                        sf.SFMessageID__c = gt.sysParty.uuid;
                    } 
                    else {
                        if(gt.sysParty.sysPrParentPartyKey != null) {    //has parent, this is the child
                            for(String rType : childRelIDs.keySet()) {
                                System.debug('*** roleListMappings.get(' + rType + ') ----> ' + roleListMappings.get(rType));
                                if(gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(rType))) {
                                    if (('Association Member'.equals(rType)) || ('Association Member Primary'.equals(rType))) 
                                        sf.ObjectType__c = 'Related_Association__c';    
                                    else 
                                        sf.ObjectType__c = 'Relationship__c';   
           
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    sf.relatedid__c = childRelIDs.get(rType);
                                }
                            }
                        }
                        else {    //no parent, this is the parent
                            for(String rType : parentRelIDs.keySet()) {
                                System.debug('*** roleListMappings.get(' + rType + ') ----> ' + roleListMappings.get(rType));
                                if(gt.sysParty.sysPRRoleKey.equals(roleListMappings.get(rType))) {
                                    sf.ObjectType__c = 'Relationship__c';
                                    sf.SFMessageID__c = gt.sysParty.uuid;
                                    sf.relatedid__c = parentRelIDs.get(rType);
                                }
                            }
                        }
                    }
                    
                } 
                else {
                    sf.relatedid__c = account.id;
                    sf.SFMessageID__c = gt.officeResource.uuid;
                    sf.ObjectType__c = 'Account';
                }   
                
                if (hasFailedSFQP) 
                    sf.QPStatus__c = 'Failed-SFQP';
                else 
                    sf.QPStatus__c = status;
                
                sf.QPMessage__c = statusMessage;
                sfconnectorList.add(sf);
            } 
            
        }
        upsert sfconnectorList;
    }

    global static void getParentAccountsInformation(Map<Id,String> accountsJsonMap) {
        Set<String> parentAccountIds = new Set<String>();
        for(Id accountId : accountsJsonMap.keySet()) {
            Account a = (Account) System.JSON.deserialize(accountsJsonMap.get(accountId),sObject.class);
            if(String.isNotBlank(a.parentid))
                parentAccountIds.add(a.parentid);
        }
        
        parentAccountsMap = new Map<Id, Account>();
        if(parentAccountIds.Size() > 0) {
            Map<Id, Account> parentAccounts = new Map<Id, Account>([SELECT id, OfficeKey__c, Name, Account_Name__c, Company_Type__c from Account where id = :parentAccountIds]);    
            parentAccountsMap = parentAccounts;
        }
        system.debug('### parentAccountsMap :' + parentAccountsMap);      
    } 
    
    global static void getRelationshipInformation(Map<Id,String> accountsJsonMap) {
    
        List <Relationship__c> relationshipList =  [Select r.Relationship_Type__c,r.Related_Account__r.OfficeKey__c, 
                r.Related_Account__c, r.Broker_Office__c, r.id From Relationship__c r 
                Where  r.Broker_Office__c = :accountsJsonMap.keySet() and r.Relationship_End_Date__c = null];   
        
        relationshipMap = new Map<String, List<Relationship__c>>();
        if(relationshipList.Size() > 0) {
            for(Relationship__c relationShip : relationshipList) {
                if(relationshipMap.get(relationShip.Broker_Office__c) == null) {
                    List<Relationship__c> relList = new List<Relationship__c>{relationShip};
                    relationshipMap.put(relationShip.Broker_Office__c, relList);
                }
                else {
                    List<Relationship__c> relList1 = relationshipMap.get(relationShip.Broker_Office__c);
                    relList1.add(relationShip);
                    relationshipMap.put(relationShip.Broker_Office__c, relList1);
                }
            }
        }
        system.debug('### relationshipMap:' + relationshipMap);
    }
    
    global static void getRelatedAccountInformation(Map<Id,String> accountsJsonMap) {
    
        List <Relationship__c> relationshipList =  [Select r.Related_Account__r.OfficeKey__c, 
            r.Related_Account__c, r.Relationship_Type__c, r.id From Relationship__c r 
            Where  r.related_Account__c = :accountsJsonMap.keySet()
            and r.Relationship_End_Date__c = null]; 
        
        relatedAccountsMap = new Map<String, List<Relationship__c>>();
        if(relationshipList.Size() > 0) {
            for(Relationship__c relationShip : relationshipList) {
                if(relatedAccountsMap.get(relationShip.related_Account__c) == null) {
                    List<Relationship__c> relList = new List<Relationship__c>{relationShip};
                    relatedAccountsMap.put(relationShip.related_Account__c, relList);
                }
                else {
                    List<Relationship__c> relList1 = relatedAccountsMap.get(relationShip.related_Account__c);
                    relList1.add(relationShip);
                    relatedAccountsMap.put(relationShip.related_Account__c, relList1);
                }
            }
        }
        system.debug('### relatedAccountsMap :' + relatedAccountsMap);
    }
    
    global static void getRelatedAssociationInformation(Map<Id,String> accountsJsonMap) {
    
        List<Related_Association__c> raList = [Select r.SystemModstamp, r.SysPrRoleKey__c, r.Subscription__c, r.Status__c, r.Start_Date__c, 
            r.PrismRelBoardID__c, r.Primary__c, r.OwnerId, r.Notes__c, r.Name, 
            r.MDS_Status__c, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, 
            r.IsDeleted, r.Import_Source__c, r.Import_ID__c, r.Id, r.End_Date__c, r.CreatedDate, 
            r.CreatedById, r.Broker_Code__c, r.Association__c, r.Association_Name__c,r.Association__r.OfficeKey__c From Related_Association__c r 
            where r.Broker_code__c = :accountsJsonMap.keySet() and r.status__c != 'Inactive'];
        
        relatedAssociationMap = new Map<String, List<Related_Association__c>>();
        if(raList.Size() > 0) {
            for(Related_Association__c relatedAssociation : raList) {
                if(relatedAssociationMap.get(relatedAssociation.Broker_code__c) == null) {
                    List<Related_Association__c> relList = new List<Related_Association__c>{relatedAssociation};
                    relatedAssociationMap.put(relatedAssociation.Broker_code__c, relList);
                }
                else {
                    List<Related_Association__c> relList1 = relatedAssociationMap.get(relatedAssociation.Broker_code__c);
                    relList1.add(relatedAssociation);
                    relatedAssociationMap.put(relatedAssociation.Broker_code__c, relList1);
                }
            }
        }
        system.debug('### relatedAssociationMap :' + relatedAssociationMap);
    }   

    public static List <typesWebserviceQueueprocessorCrmMris.GenericRequestType> buildOfficeResourceMessage(Account account,String action){        
        System.debug('*** Inside buildCreateOfficeResourceMessage');
        
        /* Now map the required values to the wsdl */
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gtOffice = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        gtOffice.sequenceNumber = '001';  //Office is always the first record
        gtOffice.officeResource = new typesWebserviceQueueprocessorCrmMris.OfficeStructure();
        gtOffice.officeResource.action = action;
        
        if ('UPDATE'.equals(action))
            gtOffice.officeResource.officeKey = account.OfficeKey__c;
        
        gtOffice.officeResource.officeID = account.Name;
        gtOffice.officeResource.brokerID = account.Name;
        
        if(!isDirect) {
             /* Get CS address utility values */
            statesCSMap = new Map<String, String>();
            streetTypesCSMap = new Map<String, String>();
            streetDirectionsCSMap = new Map<String, String>();
            countiesCSMap = new Map<String, String>();
            countyLongValuesCSMap = new Map<String, String>();
            countriesCSMap = new Map<String, String>(); 
            unitTypesCSMap = new Map<String, String>();
            cityLongValuesCSMap = new Map<String, String>(); 
            
            Map<String, String> statesMap = new Map<String, String>();
            List<String> streetTypes = new List<String>();
            List<String> streetDirections = new List<String>();
            List<String> counties = new List<String>();
            List<String> countyLongValues = new List<String>();
            List<String> countries = new List<String>();
            List<String> unitTypes = new List<String>();
            List<String> cityLongValues = new List<String>();            
            
            if(String.isNotBlank(account.State__c))
                statesMap.put(account.State__c, account.Country__c);
            if(String.isNotBlank(account.Street_Type__c))
                streetTypes.add(account.Street_Type__c);
            if(String.isNotBlank(account.Street_Direction__c))
                streetDirections.add(account.Street_Direction__c);
            if(String.isNotBlank(account.County__c))
                counties.add(account.County__c);
            if(String.isNotBlank(account.Country__c))
                countries.add(account.Country__c);
            if(String.isNotBlank(account.Unit_Type__c))
                unitTypes.add(account.Unit_Type__c);
            if(String.isNotBlank(account.City__c) && String.isNotBlank(account.State__c) && String.isNotBlank(account.County__c))
                cityLongValues.add(account.City__c + '-' + account.County__c + '-' + account.State__c);            
            
            if(String.isNotBlank(account.State__c) && String.isNotBlank(account.County__c))
                countyLongValues.add(account.County__c + '-' + account.State__c);    
           
           
            statesCSMap = AddressUtility.getCSState(statesMap, 'ACCOUNT');
            System.debug('**** statesMap:' + statesMap);
            System.debug('**** statesCSMap:' + statesCSMap);
                    
            streetTypesCSMap = AddressUtility.getCSStreetType(streetTypes, 'ACCOUNT');
            System.debug('**** streetTypes:' + streetTypes);
            System.debug('**** streetTypesCSMap:' + streetTypesCSMap);
                    
            streetDirectionsCSMap = AddressUtility.getCSStreetDirection(streetDirections, 'ACCOUNT');
            System.debug('**** streetDirections:' + streetDirections);
            System.debug('**** streetDirectionsCSMap :' + streetDirectionsCSMap);
                    
            //countiesCSMap = AddressUtility.getCSCounty(counties, 'ACCOUNT');
            countyLongValuesCSMap = AddressUtility.getCSCounty(countyLongValues, 'ACCOUNT');
            //System.debug('**** counties:' + counties);
            //System.debug('**** countiesCSMap:' + countiesCSMap);
            
            System.debug('**** counties:' + countyLongValues);
            System.debug('**** countiesCSMap:' + countiesCSMap);
                    
            countriesCSMap = AddressUtility.getCSCountry(countries, 'ACCOUNT');
            System.debug('**** countries:' + countries);
            System.debug('**** countriesCSMap :' + countyLongValuesCSMap  );
                    
            unitTypesCSMap = AddressUtility.getCSStreetUnitTypes(unitTypes, 'ACCOUNT');       
            System.debug('**** unitTypes:' + unitTypes);
            System.debug('**** unitTypesCSMap :' + unitTypesCSMap );
            
            cityLongValuesCSMap = AddressUtility.getCSCityAll(cityLongValues, 'ACCOUNT');       
            System.debug('**** cityLongValues:' + cityLongValues);
            System.debug('**** cityLongValuesCSMap :' + cityLongValuesCSMap);          
        }

        if (Utils.isNotNull(account.Office_Email__c)) 
            gtOffice.officeResource.officeEmail =    account.Office_Email__c;
        else 
            gtOffice.officeResource.officeEmail =    SubscriptionUtility.nullString;

        if (Utils.isNotNull(account.Account_Name__c)) 
            gtOffice.officeResource.officeName =    account.Account_Name__c;
        else 
             gtOffice.officeResource.officeName = SubscriptionUtility.nullString;

        //Phone
        if (Utils.isNotNull(account.Phone)) {
            String newPhone = '';               
            for (integer i=0;i<account.Phone.length();i++){
                if ('0123456789'.contains(account.Phone.substring(i,i+1))) 
                    newPhone = newPhone + account.Phone.substring(i,i+1);
            }
            
            /* No need of any extension */
            if (newPhone.length() > 10) 
                newPhone = newPhone.substring(0,10);
            
            gtOffice.officeResource.officeOfficePhone = newPhone;
        } 
        else 
            gtOffice.officeResource.officeOfficePhone = SubscriptionUtility.nullString;

        //fax
        if (Utils.isNotNull(account.Fax)) {
            String newFax = '';               
            for (integer i=0;i<account.Fax.length();i++) {
                if ('0123456789'.contains(account.Fax.substring(i,i+1))) 
                    newFax = newFax + account.Fax.substring(i,i+1);
            }
            
            /* No need of any extension */
            if (newFax.length() > 10) 
                newFax = newFax.substring(0,10);
            
            gtOffice.officeResource.officeFax = newFax;
        } 
        else 
            gtOffice.officeResource.officeFax = SubscriptionUtility.nullString;
        
        //Pin
        if (Utils.isNotNull(account.PIN__c)) 
            gtOffice.officeResource.officeNationalID = account.PIN__c;
        else 
            gtOffice.officeResource.officeNationalID = SubscriptionUtility.nullString;
        
        //website
        if (Utils.isNotNull(account.Website)) 
            gtOffice.officeResource.officeWWW = account.Website;
        else 
             gtOffice.officeResource.officeWWW = SubscriptionUtility.nullString;
        
        //Trading as
        if (Utils.isNotNull(account.Trading_As__c)) 
            gtOffice.officeResource.officeTradingAs = account.Trading_As__c;
        else 
             gtOffice.officeResource.officeTradingAs = SubscriptionUtility.nullString;

        if (Utils.isNotNull(account.OfficeKey__c)) 
            gtOffice.officeResource.officeKey = account.OfficeKey__c;
        else
            gtOffice.officeResource.officeKey = SubscriptionUtility.nullString;
        
        if (Utils.isNotNull(account.Addl_Display_Name__c)) 
            gtOffice.officeResource.officeStreetAdditionalInfo = account.Addl_Display_Name__c;
        else
            gtOffice.officeResource.officeStreetAdditionalInfo = SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Box__c)) 
            gtOffice.officeResource.officeBoxNumber = account.Box__c;
        else 
            gtOffice.officeResource.officeBoxNumber = SubscriptionUtility.nullString;

        if(Utils.isNotNull(account.Street_Number__c)) 
            gtOffice.officeResource.officeStreetNumber = account.Street_Number__c; 
        else  
            gtOffice.officeResource.officeStreetNumber = SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Street_Name__c)) 
            gtOffice.officeResource.officeStreetName = account.Street_Name__c;
        else 
            gtOffice.officeResource.officeStreetName = 'NO STREET NAME';
         
        if(Utils.isNotNull(account.Street_Number_Suffix__c)) 
            gtOffice.officeResource.officeStreetSuffix = account.Street_Number_Suffix__c;
        else
            gtOffice.officeResource.officeStreetSuffix = SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Street_Type__c) && String.isNotBlank(streetTypesCSMap.get(account.Street_Type__c)))
            gtOffice.officeResource.officeStreetSuffix = streetTypesCSMap.get(account.Street_Type__c);
        else 
            gtOffice.officeResource.officeStreetSuffix = SubscriptionUtility.nullString;
        
        if (Utils.isNotNull(account.Street_Direction__c) && String.isNotBlank(streetDirectionsCSMap.get(account.Street_Direction__c)))     
            gtOffice.officeResource.officeStreetDirSuffix = streetDirectionsCSMap.get(account.Street_Direction__c);
        else 
            gtOffice.officeResource.officeStreetDirSuffix = SubscriptionUtility.nullString;
        
        if (Utils.isNotNull(account.State__c) && String.isNotBlank(statesCSMap.get(account.State__c))) 
            gtOffice.officeResource.officeState = statesCSMap.get(account.State__c);
        else
            gtOffice.officeResource.officeState = SubscriptionUtility.nullString;

        /*********************  replaced per: B-03924
        if(Utils.isNotNull(account.City__c)) 
            gtOffice.officeResource.officeCity = AddressUtility.getCSCity(account.City__c, 'ACCOUNT');
        else 
            gtOffice.officeResource.officeCity =SubscriptionUtility.nullString;
        ********************************************/
        
        if(Utils.isNotNull(account.City__c) && Utils.isNotNull(account.State__c) && Utils.isNotNull(account.County__c)) {           
            String lval = account.City__c + '-' + account.County__c + '-' + account.State__c;
            gtOffice.officeResource.officeCity = cityLongValuesCSMap.get(lval);
        } 
        else 
            gtOffice.officeResource.officeCity =SubscriptionUtility.nullString;
                
        if(Utils.isNotNull(account.Zip__c)) 
            gtOffice.officeResource.officePostalCode = account.Zip__c;
        else 
            gtOffice.officeResource.officePostalCode =SubscriptionUtility.nullString;

       // if(Utils.isNotNull(account.County__c) && String.isNotBlank(countiesCSMap.get(account.County__c)))
       //     gtOffice.officeResource.officeCounty = countiesCSMap.get(account.County__c);
      //  else
        //    gtOffice.officeResource.officeCounty =SubscriptionUtility.nullString;
            
        if(Utils.isNotNull(account.County__c) &&  Utils.isNotNull(account.State__c)){
            String lval = account.County__c + '-' + account.State__c;
            gtOffice.officeResource.officeCounty = countyLongValuesCSMap.get(lval);}
        else
            gtOffice.officeResource.officeCounty =SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Country__c) && String.isNotBlank(countriesCSMap.get(account.Country__c)))
            gtOffice.officeResource.officeCountry = countriesCSMap.get(account.Country__c);
        else 
            gtOffice.officeResource.officeCountry =SubscriptionUtility.nullString;
        
        //D-01329
        if(Utils.isNotNull(account.Unit_Type__c) && String.isNotBlank(unitTypesCSMap.get(account.Unit_Type__c)))
            gtOffice.officeResource.officeUnitDesignation = unitTypesCSMap.get(account.Unit_Type__c);
        else
            gtOffice.officeResource.officeUnitDesignation = SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Unit__c))
            gtOffice.officeResource.officeUnitNumber = account.Unit__c;
        else 
            gtOffice.officeResource.officeUnitNumber =SubscriptionUtility.nullString;
        
        if(Utils.isNotNull(account.Zip_4__c)) 
            gtOffice.officeResource.OfficeZip4 = account.Zip_4__c;
        else 
            gtOffice.officeResource.OfficeZip4 =SubscriptionUtility.nullString;

        gtOffice.officeResource.uuid = '' + Utils.getRandomNumber();
       
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType> gtList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        gtList.add(gtOffice);
        
        return gtList;       
    }
}