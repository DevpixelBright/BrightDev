public class RelationshipTriggerHandler{
    public static void validateUniqueResponsibleBroker(List<Relationship__c> lNewRelationship){
        
        Profile userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()];
        //if(userProfile.Name != 'MRIS Customer Community Login'){
            
            try {
                Set<String> sAccIds = new Set<String>();
                Set<String> states = new Set<String>();
                for(Relationship__c rel : lNewRelationship){
                    if(rel.Status__c == 'Active' && (rel.Relationship_End_Date__c >= System.today() || rel.Relationship_End_Date__c == null) && rel.Relationship_Type__c == 'Responsible Broker' && rel.State__c != null){
                        sAccIds.add(rel.Broker_Office__c);
                        states.add(rel.State__c);
                    }
                }
                
                System.debug(sAccIds);
                
                List<Relationship__c> lRel = [SELECT Id,Name, State__c, Broker_Office__c, Subscription__c, Subscription__r.Name  from Relationship__c WHERE Broker_Office__c IN: sAccIds AND State__c IN: states AND Status__c = 'Active' AND Relationship_Type__c = 'Responsible Broker' AND  ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= today )];
                
                for(Relationship__c rel : lNewRelationship){
                    for(Relationship__c oRel : lRel){
                        if(rel.Id != oRel.Id && (oRel.Broker_Office__c == rel.Broker_Office__c && oRel.State__c == rel.State__c)){
                            rel.addError(' A responsible broker is already assigned for '+ oRel.State__c +'  assigned to '+ oRel.Subscription__r.Name +'. There can be only one responsible broker per state within a brokerage.');
                        }
                    }
                }
            }
            
            catch(Exception e) {
                system.debug(e);
            }
       // }
    }
}