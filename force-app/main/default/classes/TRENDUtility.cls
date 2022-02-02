public class TRENDUtility{
    
    public static List<Subscriptions__c> processSubscriptions(List<Subscriptions__c> subscriptions){        
        List<Subscriptions__c> updatedSubscriptions = new List<Subscriptions__c>();
        for(Subscriptions__c subscription : subscriptions){
            Contact c = [SELECT Id, Name, (SELECT Id, Status__c FROM Subscriptions__r) FROM Contact WHERE Id = :Subscription.contact__c];
            system.debug('*** Contact: ' + c);
            system.debug('*** c.Subscriptions__r: ' + c.Subscriptions__r[0].Status__c);
            if(c.Subscriptions__r.size() == 1){  
               subscription.Primary__c = true;
               subscription.AgentKey__c = String.valueOf(Math.random());
               updatedSubscriptions.add(subscription);
            } 
            
            if(subscription.Status__c == 'Active' && subscription.TREND_Agent_Code__c == null)
                subscription.TREND_Agent_Code__c = subscription.Name;
                 
        }
        
        return updatedSubscriptions;         
    }
    
    public static void processRelationships(List<Relationship__c> relationships){
        for(Relationship__c relationship : relationships){
            if(relationship.Status__c == 'Active' && relationship.Relationship_Start_Date__c == null)
                relationship.Relationship_Start_Date__c = DateTime.now();
            else if(relationship.Status__c == 'Inactive' && relationship.Relationship_End_Date__c == null)
                relationship.Relationship_End_Date__c = system.today();
        }   
    }

}