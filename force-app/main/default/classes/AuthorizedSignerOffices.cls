public Class AuthorizedSignerOffices {
    public Id recordId { get; set; }

    public List<Relationship__c> getRelationships() {
        List<Relationship__c> relationships = new List<Relationship__c>();
        List<Relationship__c> relationship = new List<Relationship__c>();
        relationship = [SELECT  Id, Subscription__c 
                         FROM    Relationship__c
                         WHERE   ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                         AND     Status__c = 'Active'
                         AND     Id = :recordId];
        if(relationship.Size() > 0) {
            String subscriberId = relationship[0].Subscription__c;
            relationships = [SELECT  Id, Subscription__c, Broker_Office__r.Name, Broker_Office__r.Account_Name__c 
                            FROM    Relationship__c
                            WHERE   ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                            AND     Status__c = 'Active'
                            AND     Subscription__c = :subscriberId];             
        }
        
        return relationships;    
    }   
}