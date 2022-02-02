global without sharing class BORUtilityClass {
   
    public static List<Relationship__c> fetchBOR(List<String> brokerofficecode){
        List<Account> relatedAccounts = new List<Account>();     
        relatedAccounts = [SELECT Id, ParentId, Name
                           FROM   Account
                           WHERE  (ParentId = :brokerofficecode OR Id = :brokerofficecode) AND Status__c = 'Active' 
                          ];
        
        
        List<String> officeIds = new List<String>();                        
        for(Account a : relatedAccounts){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        system.debug('******* officeIds*****'+officeIds);
        List<Relationship__c> relationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                                              Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                                              FROM   Relationship__c 
                                              WHERE  (Broker_Office__c IN :officeIds OR Broker_Office__r.ParentId IN :officeIds)
                                              AND    Relationship_Type__c = 'Broker Of Record'
                                              AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                              AND    Subscription__r.ApplicationNotificationOptOut__c = false LIMIT 1
                                             ];
        system.debug('******* relationship*****'+relationship);
        return relationship;
        
    }
    
    public static List<Id> fetchActiveOfficesFromBrokerage(List<String> brokerofficecode){
        List<Account> relatedAccounts = new List<Account>();    
        Set<Id> officeIds = new Set<Id>();
        relatedAccounts = [SELECT Id, ParentId, Name FROM Account
                           WHERE  (ParentId = :brokerofficecode OR Id = :brokerofficecode) AND Status__c = 'Active' 
                          ];
        for(Account a : relatedAccounts){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        for(Account a : [SELECT Id, ParentId FROM Account WHERE (ParentId = :officeIds OR Id = :officeIds) AND Status__c = 'Active']){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        system.debug('******* officeIds*****'+officeIds);
        return new list<Id>(officeIds);
    }
    /*
    public static List<Id> fetchOfficesFromBrokerage(List<String> brokerofficecode){
        List<Account> relatedAccounts = new List<Account>();    
        Set<Id> officeIds = new Set<Id>();
        relatedAccounts = [SELECT Id, ParentId, Name FROM Account
                           WHERE  (ParentId = :brokerofficecode OR Id = :brokerofficecode) 
                          ];
        for(Account a : relatedAccounts){
            officeIds.add(a.Id);
            if(a.ParentId != null)
                officeIds.add(a.ParentId);
        }
        system.debug('******* officeIds*****'+officeIds);
        return new list<Id>(officeIds);
    }
    */
}