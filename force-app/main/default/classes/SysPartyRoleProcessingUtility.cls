public without sharing class SysPartyRoleProcessingUtility {
    
    public static List<String> officeLinkedRoles = new List<String>();
    static {
        officeLinkedRoles.add('Stockholder');
    }
    public class UpdateDetails{
        String jsonStruct;
        //String 
        
    }
    
    
   
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> processUpdateRoles(Map<String,String> roleNamesMap, Map<String, String> oldRoleNamesMap, Map<String,String> roleListMappings,Account account, Account oldAccount,Integer i){
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> sysPartyStructList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        
        String parentKey = '', partyKey = oldAccount.OfficeKey__c, accountsysrole = '';
       
        accountsysrole = Utils.splitByDigits(account.Name);
      
        if(Utils.isNotNull(oldAccount.ParentId)) {
            Account parent = [SELECT Id, OfficeKey__c FROM Account WHERE Id = :oldAccount.ParentId];
            parentKey = parent.OfficeKey__c;
        }
        
        for(String role: oldRoleNamesMap.keySet()){
            String primaryKey = '';
            for (String r : officeLinkedRoles){     
                if ('Stockholder'.equals(role)){
                    primaryKey = oldAccount.CS_Shareholder_ID__c;
                    break;
                } else if ('Office'.equals(role)){
                    primaryKey = oldAccount.CS_Office_Role_ID__c;
                    break;
                } else if (oldAccount.Company_Type__c.equals(role)){
                    primaryKey = oldAccount.CS_CompanyTypeRole_ID__c;
                    break;
                } else if (oldAccount.Type.equals(role)){
                    primaryKey = oldAccount.CS_AccountTypeRole_ID__c;
                    break;
                }
            }
            if('Office'.equals(role)) {
                sysPartyStructList.add(buildUpdateStruct(i, primaryKey, partyKey, null, 0));
            } else {
                sysPartyStructList.add(buildDeleteStruct(i, primaryKey, partyKey, parentKey));
            }
            i++;
        }
        for(String role: roleNamesMap.keySet()){
            sysPartyStructList.add(buildCreateStruct(i, roleListMappings.get(role), roleNamesMap.get(role), account.OfficeKey__c,accountsysrole,null,null));
            i++;
        }
        return sysPartyStructList;
        
    }
    
    
    /**
    * This method will build create roles structure
    * @params roleNamesMap  - Map<String, String> Rolenames
    * @return List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> list of created roles
    *
    **/
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> processCreateStructRoles(Map<String,String> roleNamesMap,
    Map<ID,CornerstoneMappings__c> mappings,Map<String,String> roleListMappings,
    String partyKey, String sysRoleID, Integer i){
        return processCreateStructRoles( roleNamesMap,mappings, roleListMappings, 
        partyKey,  sysRoleID,  i,null);
    }
    
    
    /**
    * This method will build create roles structure
    * @params roleNamesMap  - Map<String, String> Rolenames
    * @return List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> list of created roles
    *
    **/
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> processCreateStructRoles(Map<String,String> roleNamesMap,
    Map<ID,CornerstoneMappings__c> mappings,Map<String,String> roleListMappings,
    String partyKey, String sysRoleID, Integer i, DateTime dt){
        //Get the roles for mappings
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> sysPartyStructList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        
        if(roleNamesMap.containsKey('Agent')) {    // Agent needs to be created first
            sysPartyStructList.add(buildCreateStruct(i, roleListMappings.get('Agent'), roleNamesMap.get('Agent'),partyKey,sysRoleID,null,dt));
            i++;
        }
        for (String role: roleNamesMap.keySet()){
            if('Agent'.equals(role)) {
                continue;
            }  else {
            	System.debug('role ------->' + role);
            	System.debug('partyKey ------->' + partyKey);
            	System.debug('sysRoleID ------->' + sysRoleID);
            	System.debug('roleListMappings.get(role) ------->' + roleListMappings.get(role));
            	System.debug('roleNamesMap.get(role) ------->' + roleNamesMap.get(role));
                sysPartyStructList.add(buildCreateStruct(i, roleListMappings.get(role), roleNamesMap.get(role),partyKey,sysRoleID,null,dt));
            }
            i++;
        }
        return sysPartyStructList;
    }
    
    /**
    * This method will build delete roles structure
    * @params roleNamesMap  - Map<String, String> Rolenames
    * @return List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> list of created roles
    *
    **/
    public static List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> processDeleteStructRoles(Map<String,String> roleNamesMap,String agentKey, String officeKey,Integer i){
        //Get the roles for mappings
        List<typesWebserviceQueueprocessorCrmMris.GenericRequestType> sysPartyStructList = new List<typesWebserviceQueueprocessorCrmMris.GenericRequestType>();
        
        for (String role: roleNamesMap.keySet()){
        
            sysPartyStructList.add(buildDeleteStruct(i, roleNamesMap.get(role), agentKey,officeKey));
            i++;
        }
        return sysPartyStructList;
    }
    
    
    /**
    *Build create structure
    *@params i Integer
    *@params roleName String
    *@params parentKey String
    *@return typesWebserviceQueueprocessorCrmMris.GenericRequestType
    **/
    public static typesWebserviceQueueprocessorCrmMris.GenericRequestType buildCreateStruct(Integer i, String primaryKey,
        String parentKey,String partyKey, String sysRoleID, String parentID, Datetime dt){
        System.debug('buildCreateStruct.primaryKey --> ' + primaryKey);
        System.debug('buildCreateStruct.parentKey --> ' + parentKey);
        System.debug('buildCreateStruct.sysRoleID --> ' + sysRoleID);
        System.debug('buildCreateStruct.partyKey --> ' + partyKey);
        System.debug('buildCreateStruct.parentID --> ' + parentID);
        System.debug('buildCreateStruct.dt --> ' + dt);
        
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gt = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        typesWebserviceQueueprocessorCrmMris.SysPartyStructure syspartyStruct = new typesWebserviceQueueprocessorCrmMris.SysPartyStructure();
        syspartyStruct.action = 'CREATE';
        syspartyStruct.sysPrCurrent = '1';
        if (dt == null) {
        	syspartyStruct.sysPrStartDate = Utils.convertDateTimeToISOFormat(DateTime.now());
        } else {
        	syspartyStruct.sysPrStartDate = Utils.convertDateTimeToISOFormat(dt);
        }
        syspartyStruct.sysPRRoleKey = primaryKey;
        if(Utils.isNotNull(partyKey)) {
            syspartyStruct.sysPRPartyKey = partyKey;
        }
        System.debug('SysRoleID ------>>>>> '  + sysRoleID);
        if (Utils.isNotNull(sysRoleID)) {
            syspartyStruct.sysPrRoleID = sysRoleID;
        }
        if(Utils.isNotNull(parentID)) {
            syspartyStruct.sysPRParentID = parentID;
        }
        
        syspartyStruct.uuid = '' + Utils.getRandomNumber();
        if ((null != parentKey ) && ('null' != parentKey) && ('' != parentKey)){
            syspartyStruct.sysPrParentPartyKey = parentKey;
        }
        gt.sequenceNumber = '' + i;
        gt.sysParty = syspartyStruct;
        return gt;
    }
    
    
    /**
    *Build update structure
    *@params i Integer
    *@params roleName String
    *@params parentKey String
    *@return typesWebserviceQueueprocessorCrmMris.GenericRequestType
    **/
    public static typesWebserviceQueueprocessorCrmMris.GenericRequestType buildUpdateStruct(Integer i, String primaryKey,
    String partyKey,String parentKey, Integer current){
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gt = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        typesWebserviceQueueprocessorCrmMris.SysPartyStructure syspartyStruct = new typesWebserviceQueueprocessorCrmMris.SysPartyStructure();
        syspartyStruct.action = 'UPDATE';
        if(current == 0) {
            syspartyStruct.sysPrCurrent = '0';
            syspartyStruct.sysPrEndDate = Utils.convertDateTimeToISOFormat(DateTime.now());
        } else {
            syspartyStruct.sysPrCurrent = '1';
            syspartyStruct.sysPrStartDate = Utils.convertDateTimeToISOFormat(DateTime.now());
        }
        syspartyStruct.sysPRPartyKey = partyKey;
        String sysRoleID = '';
        try {
        	sysRoleID = [SELECT Name from subscriptions__c where AgentKey__c = :partyKey limit 1].Name;
        } catch (Queryexception qex) {
        	sysRoleID = [SELECT Name from Account where OfficeKey__c = :partyKey limit 1].Name;
        }
        syspartyStruct.sysPRKey = primaryKey;
        syspartyStruct.sysPrRoleID = Utils.splitByDigits(sysRoleID);
         System.debug('SysRoleID Update ------>>>>> '  + sysRoleID);
        syspartyStruct.uuid = '' + Utils.getRandomNumber();
        if ((null != parentKey ) && ('null' != parentKey) && ('' != parentKey)){
            syspartyStruct.sysPrParentPartyKey = parentKey;
        }
        gt.sequenceNumber = '' + i;
        gt.sysParty = syspartyStruct;
        return gt;
    }
    
    
    /**
    *Build delete structure
    *@params i Integer
    *@params roleName String
    *@params parentKey String
    *@return typesWebserviceQueueprocessorCrmMris.GenericRequestType
    **/
    public static typesWebserviceQueueprocessorCrmMris.GenericRequestType buildDeleteStruct(Integer i, String primaryKey, String partyKey,String ParentPartyKey){
        typesWebserviceQueueprocessorCrmMris.GenericRequestType gt = new typesWebserviceQueueprocessorCrmMris.GenericRequestType();
        typesWebserviceQueueprocessorCrmMris.SysPartyStructure syspartyStruct = new typesWebserviceQueueprocessorCrmMris.SysPartyStructure();
        syspartyStruct.action = 'DELETE';
        syspartyStruct.sysPRKey = primaryKey;
        if(Utils.isNotNull(partyKey)) {
            syspartyStruct.sysPRPartyKey = partyKey;
        }
        if(Utils.isNotNull(ParentPartyKey)) {
            syspartyStruct.sysPRParentPartyKey = ParentPartyKey;
        }
        String sysRoleID = '';
        try {
        	sysRoleID = [SELECT Name from subscriptions__c where AgentKey__c = :partyKey limit 1].Name;
        } catch (Queryexception qex) {
        	sysRoleID = [SELECT Name from Account where OfficeKey__c = :partyKey limit 1].Name;
        }
       
        syspartyStruct.sysPrRoleID = Utils.splitByDigits(sysRoleID);
         System.debug('SysRoleID Delete ------>>>>> '  + sysRoleID);
        syspartyStruct.uuid = '' + Utils.getRandomNumber();
        gt.sequenceNumber = '' + i;
        gt.sysParty = syspartyStruct;
        System.debug('syspartyStruct -----<<<< ' + syspartyStruct);
        return gt;
    }
}