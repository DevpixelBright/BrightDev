public class PopulateOfficeDetailsHandler {
    public void findBOREmailId(){
        Set<Id> accIDs = new Set<Id>();
        List<Relationship__c> relationships = new List<Relationship__c>();
        relationships = [SELECT Id,Name,Relationship_Type__c, Relationship_End_Date__c,Subscription__r.Contact__r.FirstName, 
                         Subscription__r.Private_Email__c,Broker_Office__c
                         FROM   Relationship__c 
                         WHERE    Relationship_Type__c = 'Broker Of Record'
                         AND Broker_Office__c IN: accIDs
                         AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                        ];
    }
    
}