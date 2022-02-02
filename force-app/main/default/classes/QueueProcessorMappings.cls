global with sharing class QueueProcessorMappings {
    
    /**
    * This method is the utility method to return cornerstone mappings
    *
    **/
    global static Map<Id,CornerstoneMappings__c> getCornerstoneMappings(Set<String> typeNameList){
            return new Map<Id,CornerstoneMappings__c>([SELECT id, TypeName__c,CornerstoneID__c FROM CornerstoneMappings__c where TypeName__c in :typeNameList]);
        
    }
    
    
   
    private static Map<String,Map<String, List<String>>> defSubRole;
    global static  Map<String,Map<String, List<String>>> getDefaultSubscriptionMap() {
         if(defSubRole == null) {
             defSubRole = new Map<String,Map<String, List<String>>>();
         
             Map<String, List<String>> agentList = new Map<String, List<String>>();
             List<String> agentSubRoles = new List<String>();
             agentSubRoles.add('Agent');
             agentSubRoles.add('Edit');
             agentSubRoles.add('Lister');
             agentSubRoles.add('Search');
             agentSubRoles.add('System MRIS');
             agentList.put('Licensed Appraiser/Non Realtor', agentSubRoles);
             agentList.put('Broker Staff', agentSubRoles);
             agentList.put('Licensee', agentSubRoles);
             agentList.put('Licensee/Non Realtor', agentSubRoles);
             agentList.put('Office Secretary - NC', agentSubRoles);
             agentList.put('Personal Assistant', agentSubRoles);
             agentList.put('Realtor/Appraiser Non Shareholder', agentSubRoles);
             agentList.put('Realtor/Appraiser Shareholder', agentSubRoles);
             agentList.put('Realtor/Non Shareholder', agentSubRoles);
             agentList.put('Realtor/Shareholder', agentSubRoles);
             
             Map<String, List<String>> appraiserList = new Map<String, List<String>>();
             List<String> appraiserSubRoles = new List<String>();
             appraiserSubRoles.add('Agent');
             appraiserSubRoles.add('Search');
             appraiserSubRoles.add('System MRIS');
             appraiserList.put('Licensed Appraiser/Non Realtor', appraiserSubRoles);
             appraiserList.put('Licensee', appraiserSubRoles);
             appraiserList.put('Licensee/Non Realtor', appraiserSubRoles);
             appraiserList.put('Realtor/Appraiser Non Shareholder', appraiserSubRoles);
             appraiserList.put('Realtor/Appraiser Shareholder', appraiserSubRoles);
             appraiserList.put('Realtor/Non Shareholder', appraiserSubRoles);
             appraiserList.put('Realtor/Shareholder', appraiserSubRoles);

             
             Map<String, List<String>> assistantList = new Map<String, List<String>>();
             List<String> assistantSubRoles = new List<String>();
             assistantSubRoles.add('Agent');
             assistantSubRoles.add('Search');
             assistantSubRoles.add('Edit');
             assistantSubRoles.add('System MRIS');
             assistantList.put('Personal Assistant', assistantSubRoles);
             assistantList.put('Personal Assistant to Appraiser', assistantSubRoles);
             
             Map<String, List<String>> brokerList = new Map<String, List<String>>();
             List<String> brokerSubRoles = new List<String>();
             brokerSubRoles.add('Agent');
             brokerSubRoles.add('Edit');
             brokerSubRoles.add('Lister');
             brokerSubRoles.add('Search');
             brokerSubRoles.add('System MRIS');
             brokerList.put('Licensed Appraiser/Non Realtor', brokerSubRoles);
             brokerList.put('Licensee', brokerSubRoles);
             brokerList.put('Licensee/Non Realtor', brokerSubRoles);
             brokerList.put('Realtor/Appraiser Non Shareholder', brokerSubRoles);
             brokerList.put('Realtor/Appraiser Shareholder', brokerSubRoles);
             brokerList.put('Realtor/Non Shareholder', brokerSubRoles);
             brokerList.put('Realtor/Shareholder', brokerSubRoles);
             
             Map<String, List<String>> consultantList = new Map<String, List<String>>();
             List<String> consultantSubRoles = new List<String>();
             consultantSubRoles.add('Agent');
             consultantSubRoles.add('System MRIS');
             consultantList.put('MRIS Consultant', consultantSubRoles);
             
             Map<String, List<String>> govAgencyList = new Map<String, List<String>>();
             List<String> govAgencySubRoles = new List<String>();
             govAgencySubRoles.add('Agent');
             govAgencySubRoles.add('Search');
             govAgencySubRoles.add('System MRIS');
             govAgencyList.put('Government Agency', govAgencySubRoles);
             govAgencyList.put('Government Agency/PA - N/C', govAgencySubRoles);
             govAgencyList.put('Government Agency - N/C', govAgencySubRoles);
            
             Map<String, List<String>> officeMgrList = new Map<String, List<String>>();
             List<String> officeMgrSubRoles = new List<String>();
             officeMgrSubRoles.add('Agent');
             officeMgrSubRoles.add('Search');
             officeMgrSubRoles.add('Edit');
             officeMgrSubRoles.add('Lister');
             officeMgrSubRoles.add('System MRIS');
             officeMgrList.put('Association Staff', officeMgrSubRoles);
             officeMgrList.put('Broker Staff', officeMgrSubRoles);
             officeMgrList.put('Government Agency', officeMgrSubRoles);
             officeMgrList.put('Licensed Appraiser/Non Realtor', officeMgrSubRoles);
             officeMgrList.put('Licensee', officeMgrSubRoles);
             officeMgrList.put('Licensee/Non Realtor', officeMgrSubRoles);
             officeMgrList.put('Office Secretary', officeMgrSubRoles);
             officeMgrList.put('Office Secretary - NC', officeMgrSubRoles);
             officeMgrList.put('Realtor/Appraiser Non Shareholder', officeMgrSubRoles);
             officeMgrList.put('Realtor/Appraiser Shareholder', officeMgrSubRoles);
             officeMgrList.put('Realtor/Non Shareholder', officeMgrSubRoles);
             officeMgrList.put('Realtor/Shareholder', officeMgrSubRoles);

            
             Map<String, List<String>> staffList = new Map<String, List<String>>();
             List<String> staffSubRoles = new List<String>();
             staffSubRoles.add('Agent');
             staffSubRoles.add('Edit');
             staffSubRoles.add('Search');
             staffSubRoles.add('System MRIS');
             List<String> staffNSMSubRoles = new List<String>();
             staffNSMSubRoles.add('Agent');
             staffNSMSubRoles.add('System MRIS');
             
             List<String> staffASSubRoles = new List<String>();
             staffASSubRoles.add('Agent');
             staffASSubRoles.add('System MRIS');
              staffASSubRoles.add('Search');
             staffList.put('Association Staff', staffASSubRoles);
             List<String> staffBSSubRoles = new List<String>();
             staffBSSubRoles.addAll(staffSubRoles);
             staffBSSubRoles.remove(1);
             staffList.put('Broker Staff', staffBSSubRoles);
             staffList.put('Non-Subscribing Manager', staffNSMSubRoles);
             staffList.put('Office Secretary', staffSubRoles);
             staffList.put('Office Secretary - NC', staffSubRoles);
            
             Map<String, List<String>> vendorList = new Map<String, List<String>>();
             List<String> vendorSubRoles = new List<String>();
             vendorSubRoles.add('System MRIS');
             vendorSubRoles.add('Login');
              List<String> vendorVTSubRoles = new List<String>();
             vendorVTSubRoles.add('System MRIS');
             vendorVTSubRoles.add('Login');
             vendorList.put('VT Vendor', vendorVTSubRoles);
             vendorSubRoles.add('Agent');
             vendorSubRoles.add('MRIS Vendor');
             List<String> vendorMRISVendorSubRoles = new List<String>();
             vendorMRISVendorSubRoles.add('MRIS Vendor');
             vendorMRISVendorSubRoles.add('Agent');
             vendorMRISVendorSubRoles.add('Search');
             vendorMRISVendorSubRoles.add('System MRIS');
             vendorList.put('MRIS Vendor', vendorMRISVendorSubRoles);
             vendorSubRoles.add('MDS User Login');
             vendorList.put('MDS', vendorSubRoles);
             vendorSubRoles.add('Login');
             vendorSubRoles.add('RETS Customer');
             vendorList.put('RETS/MDS', vendorSubRoles);
             vendorSubRoles.remove(3);    // MDS User Login
             vendorList.put('RETS', vendorSubRoles);
            
             Map<String, List<String>> employeeList = new Map<String, List<String>>();
             List<String> employeeSubRoles = new List<String>();
             List<String> employeeSubRolesRTS = new List<String>();
             employeeSubRoles.add('Agent');
             employeeSubRoles.add('Edit');
             employeeSubRoles.add('Search');
             employeeSubRoles.add('System MRIS');
             //employeeSubRoles.add('Lister');
             employeeSubRoles.add('Super');
             employeeSubRolesRTS.add('Agent');
             employeeSubRolesRTS.add('Edit');
             employeeSubRolesRTS.add('Search');
             employeeSubRolesRTS.add('System MRIS');
             employeeSubRolesRTS.add('Lister');
             
             
             employeeList.put('Realtor/Shareholder', employeeSubRolesRTS);
             
             employeeList.put('MRIS Staff', employeeSubRoles);
             employeeList.put('MRIS Manager', employeeSubRoles);
             
             Map<String, List<String>> cureList = new Map<String, List<String>>();
             List<String> cureSubRoles = new List<String>();
             cureList.put('CURE', cureSubRoles);
             
             
             defSubRole.put('Agent', agentList);
             defSubRole.put('Appraiser', appraiserList);
             defSubRole.put('Assistant', assistantList);
             defSubRole.put('Broker', brokerList);
             defSubRole.put('Consultant', consultantList);
             defSubRole.put('Government Agency', govAgencyList);
             defSubRole.put('Office Manager', officeMgrList);
             defSubRole.put('Staff', staffList);
             defSubRole.put('Vendor', vendorList);
             defSubRole.put('Employee', employeeList);
             defSubRole.put('CURE', cureList);
         }
         
         return defSubRole;
    }
    
    
    global static Map<String,String> commandTypes = new Map<String,String>();
    static {
        commandTypes.put('RULE1','CR_ACNT');
        commandTypes.put('RULE2','CR_ACNT_RLS');
        commandTypes.put('RULE3','CR_STOCK_RLS');
        commandTypes.put('RULE4','UP_ACNT');
        commandTypes.put('RULE5','UP_BUSS_ACNT');
        commandTypes.put('RULE6','CR_BRKR_RCRD');
        commandTypes.put('RULE7','CR_BRKR_BRACNT');
        commandTypes.put('RULE8','CR_ACNT_MGR');
        commandTypes.put('RULE9','CR_AUTH_SIGN');
        commandTypes.put('RULE10','CR_BRKR_CACNT');
        commandTypes.put('RULE11','RM_BRKR_CACNT');
        commandTypes.put('RULE12','MV_BRKR_ACNT');
        commandTypes.put('RULE13','UP_OFFICE_MGR');
        commandTypes.put('RULE14','RM_OFFICE_MGR');
        commandTypes.put('RULE15','DE_BRANCH_ACNT');
        commandTypes.put('RULE16','DE_BRANCH_ACNT');
        commandTypes.put('RULE17','AC_BRANCH_ACNT');
        commandTypes.put('RULE18','CR_SUBS');
        commandTypes.put('RULE19','CR_PRM_SUB_ROLS');
        commandTypes.put('RULE20','CR_SEC_SUB_ROLS');
        commandTypes.put('RULE21','CR_ASN_SUB_RELS');
        commandTypes.put('RULE22','CR_AGT_TRNSFR');
        commandTypes.put('RULE23','UP_PRM_MEM_ASSN');
        commandTypes.put('RULE24','UP_SUB_MEM_ASSN');
        commandTypes.put('RULE25','UP_SUBS_TYPE');
        commandTypes.put('RULE26','CR_SUBS_ROLE');
        commandTypes.put('RULE27','DE_SUBS');
        commandTypes.put('RULE28','AC_SUBS');
        commandTypes.put('RULE29','DE_SUBS_ROLE');
        commandTypes.put('RULE30','UP_SUB_PRM_FLAG');
        commandTypes.put('RULE31','UP_PRM_DE_SUB');
        commandTypes.put('RULE32','CR_SUB_PRM_FLAG');
        commandTypes.put('RULE33','UP_SUBS');
        commandTypes.put('RULE34','CR_SRV_BSN_ACNT');
        commandTypes.put('RULE35','RM_AUTH_SIGNER');
        
        
    }

}