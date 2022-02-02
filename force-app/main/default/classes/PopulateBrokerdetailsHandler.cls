public class PopulateBrokerdetailsHandler {
    public void findBOREmailId(List<MRIS_Application__c> applicationtype){
        Set<Id> accIDs = new Set<Id>();
        for(MRIS_Application__c m : applicationtype){
            accIDs.add(m.Company_Code__c);
        }
        List<Relationship__c> relationships = new List<Relationship__c>();
        relationships = [SELECT Id,Name,Relationship_Type__c, Relationship_End_Date__c,Subscription__r.Contact__r.FirstName, 
                         Subscription__r.Private_Email__c,Broker_Office__c, Subscription__r.Name, Subscription__c
                         FROM   Relationship__c 
                         WHERE    Relationship_Type__c = 'Broker Of Record'
                         AND Broker_Office__c IN: accIDs
                         AND    ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                        ];
        system.debug('**** relationships: ' +  relationships);
        Map<Id,string> rel= new Map<ID,string>();
        Map<Id,string> subrel = new Map<ID,string>();
        for(Relationship__c r : relationships){
           rel.put(r.Broker_Office__c, r.Subscription__r.Contact__r.FirstName);
           subrel.put(r.Broker_Office__c, r.Subscription__r.Name);
        }
        
        for(MRIS_Application__c m : applicationtype){
            m.Broker_Name__c = rel.get(m.Company_Code__c);
            m.BOR_SubscriptionID__c = subrel.get(m.Company_Code__c);
        }
    }
}