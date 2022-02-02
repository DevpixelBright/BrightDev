public class MRISServiceAccountProcessingUtility {
    
    public static void processServiceAccounts( Subscriptions__c subscription,Account relatedOffice) {
        System.debug('processServiceAccounts!!!!!!');
        
        typesWebserviceQueueprocessorCrmMris.InputRequest ir = new typesWebserviceQueueprocessorCrmMris.InputRequest();
        List <typesWebserviceQueueprocessorCrmMris.GenericRequestType>  gtList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        gtList = AccountProcessingUtility.buildOfficeResourceMessage(relatedOffice, 'UPDATE');
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gtOffice = gtList.get(0);
        gtOffice.officeResource.officeUserName = subscription.Name;
        ir.command = QueueProcessorMappings.commandTypes.get('RULE34');
        
        ir.sfdcMessageId = Utils.getRandomNumber();
        Set <String> typeNameSet = new Set<String>();
        typeNameSet.add('Office');
        if(String.isEmpty(subscription.Status_Change_Reason__c)) typeNameSet.add('System-MRIS');
        typeNameSet.add('MRIS Vendor');
        typeNameSet.add('MDS User Login');
        typeNameSet.add('Login');
        typeNameSet.add('RETS Customer');
        
        Map<Id,CornerstoneMappings__c> qpMap = QueueProcessorMappings.getCornerstoneMappings(typeNameSet);
        Map<String,String> mappings = new Map<String,String>();
        Map<String,String> revMappings = new Map<String,String>();
        for (Id id : qpMap.keySet()){
            mappings.put(qpMap.get(id).TypeName__c,qpMap.get(id).CornerstoneID__c);
            revMappings.put(qpMap.get(id).CornerstoneID__c,qpMap.get(id).TypeName__c);
        }
        
        if ('Vendor'.equals(subscription.Contact_Type__c)) {
            Integer i = 2;
            //gtList.add(createRole(mappings.get('Office'),relatedOffice.OfficeKey__c,relatedOffice.Name,2));
            if(String.isEmpty(subscription.Status_Change_Reason__c)) 
               gtList.add(createRole(mappings.get('System-MRIS'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
            gtList.add(createRole(mappings.get('Login'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));

            if ('RETS'.equals(subscription.Subscription_Type__c)){
                gtList.add(createRole(mappings.get('RETS Customer'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
//                gtList.add(createRole(mappings.get('Login'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
            } else if ('MDS'.equals(subscription.Subscription_Type__c)){
                gtList.add(createRole(mappings.get('MDS User Login'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
            } else if ('RETS/MDS'.equals(subscription.Subscription_Type__c)){
                gtList.add(createRole(mappings.get('MDS User Login'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
//                gtList.add(createRole(mappings.get('Login'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));
                gtList.add(createRole(mappings.get('RETS Customer'),relatedOffice.OfficeKey__c,relatedOffice.Name,i++));                
            }
        }
        ir.requests  = gtList;
         String status = 'Sent';
            String statusMessage = 'Success';
            boolean hasFailedSFQP = false;
            typesWebserviceQueueprocessorCrmMris.OutputResponse resp;
            try {
                webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint stub = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint();
                stub.inputHttpHeaders_x = new Map<String,String>();
                //stub.inputHttpHeaders_x.put('Authorization','Basic d3NzZWM6d3NzZWM=');
                stub.timeout_x = Integer.valueOf(Label.MRIS_QP_CONN_TIMEOUT);
                stub.endpoint_x = Label.MRIS_QP_URL;
                
                resp = stub.salesForceRequest(ir);
                System.debug('response code: '+resp.responseCode);
                if('FAIL'.equals(resp.responseCode)) {
                    status = 'Failed';
                    statusMessage = resp.responseDescription;
                }
            
            } catch (Exception ex){
                status = 'Failed';
                hasFailedSFQP = true;
                statusMessage = ex.getStackTraceString();
                System.debug(ex);
            }
            
            Map<String, String> rolesMap = new Map<String,String>();
            if(!status.equals('Failed')) {
                List <Subscription_Role__c> sList = new List<Subscription_Role__c>();
                for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt: gtList) {
                    if (gt.sysParty != null) {
                        Subscription_Role__c s = new Subscription_Role__c();
                        s.Role_Start_Date__c = Date.today();
                        s.Role__c = revMappings.get(gt.sysParty.SysPrRoleKey);
                        s.Subscription__c =     subscription.id;
                        s.Status__c = 'Active';
                        sList.add(s);
                    }
                    
                    
                }
                
                upsert sList;
                for (Subscription_Role__C s:sList){
                    rolesMap.put(s.Role__c,s.id);
                }
                
                Contact c = [select c.id, c.Status__c from Contact c where c.id = :subscription.Contact__c limit 1];
                c.Status__c = 'Active';
                upsert c;
            }
            
            
            List<SFQPConnector__c> sfconnectorList = new List<SFQPConnector__c>();
            for (typesWebserviceQueueprocessorCrmMris.GenericRequestType gt : gtList){
                SFQPConnector__c sf = new SFQPConnector__c();
                sf.MessageSent__c = Json.serialize(gt);
                sf.SFDC_Transaction_ID__c = ''  + ir.sfdcMessageId;
                if (gt.sysParty!= null && !''.equals(gt.sysParty.action)){
                    System.debug('sf.MessageSent__c ----> ' + sf.MessageSent__c);
                    System.debug('gt.sysParty.sysPrKey ----> ' + gt.sysParty.sysPrKey);
                    System.debug('gt.sysParty.sysPRRoleKey ----> ' + gt.sysParty.sysPRRoleKey);
                    if(gt.sysParty.sysPRRoleKey != null) {
                        sf.ObjectType__c = 'Subscription_Role__c';
                        sf.SFMessageID__c = gt.sysParty.uuid;
                        sf.relatedid__c = rolesMap.get(revMappings.get(gt.sysParty.SysPrRoleKey));
                        if (hasFailedSFQP) {
                            sf.QPStatus__c = 'Failed-SFQP';
                        } else {
                            sf.QPStatus__c = status;
                        }
                        sf.QPMessage__c = statusMessage;
                        sfconnectorList.add(sf);    
                     } 
                    if(sf.ObjectType__c == null) {
                        System.debug('No SFQPConnector created for gt: ' + gt);
                    }   
                }  
                
            } //End of For loop
            System.debug('sfconnectorList ----> ' + sfconnectorList);
            upsert sfconnectorList;
    }

    public static boolean serviceType(String s) {
       return (String.isEmpty(s)) ? false : 
          Pattern.matches('.*(RETS|MDS|VT VENDOR|VIRTUAL TOUR VENDOR).*',s.toUpperCase());
    }

    private static typesWebserviceQueueprocessorCrmMris.GenericRequestType createRole(String roleName,String officeId,String officename, Integer i) {
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gtSysPartyRole = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        gtSysPartyRole.sysParty =  new typesWebserviceQueueprocessorCrmMris.SysPartyStructure();
        gtSysPartyRole.sequenceNumber = '' + i;
        gtSysPartyRole.sysParty.uuid = '' + Utils.getRandomNumber();
        gtSysPartyRole.sysParty.action = 'CREATE';
        gtSysPartyRole.sysParty.sysPrCurrent = '1';
        gtSysPartyRole.sysParty.sysPrStartDate   = Utils.convertDateTimeToISOFormat(DateTime.now());
        gtSysPartyRole.sysParty.sysPRPartyKey = officeId;
        gtSysPartyRole.sysParty.sysPRRoleKey = roleName;
        gtSysPartyRole.sysParty.sysPrRoleID = Utils.splitByDigits(officename);
        return gtSysPartyRole;
    }

}