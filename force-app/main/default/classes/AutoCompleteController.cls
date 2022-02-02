public with sharing class AutoCompleteController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords){
        searchString = String.escapeSingleQuotes(searchString);
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        
        if(extendedWhereClause == null){
            extendedWhereClause = '';
        }
        
        String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getBrokerOffice(String searchKey) {
        List<Account> lAccounts = new List<Account>();
        if(searchKey != null && searchKey != ''){
            String searchText = '%'+ searchKey + '%';    
            lAccounts = [SELECT Id, Name, Type, Account_Name__c, City__c, State__c, Zip__c FROM Account WHERE (Account_Name__c LIKE :searchText OR Name LIKE :searchText) AND Status__c = 'Active' AND IsPersonAccount = false ORDER BY Account_Name__c ASC LIMIT 10];     
            return lAccounts;
        }
        return lAccounts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Subscriptions__c> getAgents(Account broker, String searchKey) {
        List<Subscriptions__c> lSub = new List<Subscriptions__c>();
        String searchText = '%'+ searchKey + '%'; 
        if(broker != null) {
            if(broker.Type == 'Appraiser') {
                lSub = [SELECT Id,Name, Contact__c, Contact__r.Name FROM Subscriptions__c WHERE Related_Location_Broker_Office__c= :broker.Id AND Contact_Type__c = 'Appraiser' AND Contact__r.Name LIKE :searchText AND Status__c = 'Active'];
            }
            else if(broker.Type == 'Residential' || broker.Type == 'Corporate') {
                Set<String> accType = new set<String> {'Agent', 'Broker'}; 
                lSub = [SELECT Id, Name, contact__r.Name FROM Subscriptions__c WHERE Related_Location_Broker_Office__c=:broker.Id AND Contact_Type__c IN :accType AND Status__c = 'Active' AND Contact__r.Name LIKE :searchText];
            }
        }
        return lSub;
    }    
}