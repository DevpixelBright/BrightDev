trigger LMS_UpdateRelationship on Relationship__c (after update) {
    /*
        This trigger handles the Cornerstone OnDemand process.
        Based on the matching criteria it call the appropriate class and method
    */
    
    for(Relationship__c newRelationship : trigger.new){
        Relationship__c oldRelationship = trigger.oldMap.get(newRelationship.Id);
        Subscriptions__c subscription = [SELECT Id,Status__c FROM Subscriptions__c WHERE Id = :newRelationship.Subscription__c];
       
        if(subscription.Status__c == 'Active' && (
           newRelationship.Relationship_Type__c == 'Broker Of Record' ||
           newRelationship.Relationship_Type__c == 'Office Manager' ||
           newRelationship.Relationship_Type__c == 'Authorized Signer'
           ) && (
           newRelationship.Broker_Office__c != oldRelationship.Broker_Office__c ||
           newRelationship.Subscription__c != oldRelationship.Subscription__c ||
           newRelationship.Status__c != oldRelationship.Status__c ||
           newRelationship.SysPrRoleKey__c != oldRelationship.SysPrRoleKey__c ||
           newRelationship.Resend_to_LMS_Flag__c != oldRelationship.Resend_to_LMS_Flag__c
        )){
            // Call COD to update Relationship.LMS Capture relationship update
            LMS_CornerStoneOnDemand.updateRelationship(newRelationship.Id);
        }
    }
}