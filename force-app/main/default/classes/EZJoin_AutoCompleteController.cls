/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Class contains auto complete related methods for EZJOIN application
*
* SAL-1703, SAL-1704, SAL - 1705
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BLT India.
* @modifiedBy     Srini
* @version        1.0
* @created        2020-04-07
* @modified       2020-04-09
* @modified       2020-04-24: SAL - 2118, 1722: Reinstement logic added in 'getBrokerOffice' method.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class EZJoin_AutoCompleteController {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return matching broker codes based on search input
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    searchKey			Input serch keyword that user entered in Broker Code input
    * @param    applicationType		MRIS application type seleted
    * @return   List				Lis of accounts matching to that search keyword
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */      
    @AuraEnabled(cacheable=true)
    public static List<Account> getBrokerOffice(String searchKey, String applicationType, String subscriptionType) {
        List<Account> lAccounts = new List<Account>();
        if(searchKey != null && searchKey != '') {
            List<String> accTypes = new List<String> {'Residential', 'Commercial'};
            if(applicationType == 'PersonalAssistant') {
                accTypes.add('Appraiser');
            }
            
            /* SAL - 2118, 1722: Logic added for reinstement to select broker code based on subscription type */
            if(subscriptionType != '' && subscriptionType == 'Personal Assistant to Appraiser') {
                accTypes = new List<String> {'Appraiser'};
            }
            else if(subscriptionType != '' && (subscriptionType == 'Personal Assistant' || subscriptionType == 'Office Secretary')) {
                accTypes = new List<String> {'Residential', 'Commercial'};
            }
            
            String searchText = '%'+ searchKey + '%';    
            lAccounts = [SELECT Id, Name, Type, Account_Name__c, City__c, State__c, Zip__c, County__c FROM Account 
                         WHERE (Account_Name__c LIKE :searchText OR Name LIKE :searchText) 
                         AND (Primary_Service_Jurisdiction__c = 'BRIGHT' OR  Secondary_Service_Jurisdiction__c = 'BRIGHT') 
                         AND Status__c = 'Active' AND Type IN :accTypes 
                         AND IsPersonAccount = false ORDER BY Name ASC LIMIT 10];     
            return lAccounts;
        }
        return lAccounts;
    }
    
    //SAL-2969
    @AuraEnabled
    public static List<Account> getBrokerIds(String searchKey) {
        List<Account> lAccounts = new List<Account>();
        if(String.isNotBlank(searchKey)) {
            List<String> accTypes = new List<String> {'Residential', 'Commercial'};            
            String searchText = '%'+ searchKey + '%';  
            
            lAccounts = [SELECT Id, Name, Type, Account_Name__c, City__c, State__c, Zip__c, County__c 
                         FROM   Account 
                         WHERE  (Account_Name__c LIKE :searchText OR Name LIKE :searchText) 
                         AND 	(Primary_Service_Jurisdiction__c = 'BRIGHT' OR  Secondary_Service_Jurisdiction__c = 'BRIGHT') 
                         AND 	Status__c = 'Active' 
                         AND 	Type IN :accTypes 
                         AND 	IsPersonAccount = false 
                         ORDER BY Name ASC LIMIT 10];     
            return lAccounts;
        }
        return lAccounts;
    }
    
     @AuraEnabled
    public static List<Account> getAllAssociations(String searchKey) {
        List<Account> lAccounts = new List<Account>();
        if(String.isNotBlank(searchKey)) {
            String searchText = '%'+ searchKey + '%';   
            
            lAccounts = [SELECT Id, Name, Type, Account_Name__c, City__c, State__c, Zip__c, County__c 
                         FROM 	Account 
                         WHERE  (Account_Name__c LIKE :searchText OR Name LIKE :searchText) 
                         AND 	Status__c = 'Active' 
                         AND 	Type = 'Association' 
                         AND	IsPersonAccount = false 
                         ORDER BY Account_Name__c ASC LIMIT 10];     
            return lAccounts;
        }
        return lAccounts;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return matching agents based on search input
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    broker				Broker code under this agents will query.
    * @param    searchKey			Input serch keyword that user entered in Agents input
    * @param   	selectedAgents		List of already agents selected and skip these in query
    * @return	List				List of subscriptions or agents matching to search input
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */    
    @AuraEnabled(cacheable=true)
    public static List<Subscriptions__c> getAgents(Account broker, String searchKey, List<String> selectedAgents) {
        List<Subscriptions__c> lSub = new List<Subscriptions__c>();
        if(broker != null) {
            String searchText = '%'+ searchKey + '%';
            if(broker.Type == 'Appraiser') {
                lSub = [SELECT Id, Name, Contact__c, Contact__r.Name FROM Subscriptions__c WHERE Id NOT IN :selectedAgents AND Related_Location_Broker_Office__c= :broker.Id AND Contact_Type__c = 'Appraiser' AND (Contact__r.Name LIKE :searchText OR Name LIKE :searchText) AND Status__c = 'Active' LIMIT 10];
            }
            else if(broker.Type == 'Residential' || broker.Type == 'Commercial') {
                Set<String> accType = new set<String> {'Agent', 'Broker', 'Office Manager'}; 
                lSub = [SELECT Id, Name, contact__r.Name FROM Subscriptions__c WHERE Id NOT IN :selectedAgents AND Related_Location_Broker_Office__c=:broker.Id AND Contact_Type__c IN :accType AND Status__c = 'Active' AND (Contact__r.Name LIKE :searchText OR Name LIKE :searchText) LIMIT 10];
            }
        }
        return lSub;
    }    
}