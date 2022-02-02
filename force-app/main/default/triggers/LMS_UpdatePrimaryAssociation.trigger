trigger LMS_UpdatePrimaryAssociation on Related_Association__c (after update) {
    /*
        This trigger handles the Cornerstone OnDemand process.
        Based on the matching criteria it call the appropriate class and method
    */
    
    for(Related_Association__c newAssociation : trigger.new){
        Related_Association__c oldAssociation = trigger.oldMap.get(newAssociation.Id);
        Subscriptions__c subscription = [SELECT Id,Status__c FROM Subscriptions__c WHERE Id = :newAssociation.Subscription__c];
        
        if((newAssociation.Primary__c && subscription.Status__c == 'Active') && (
            newAssociation.Primary__c != oldAssociation.Primary__c ||
            newAssociation.Subscription__c != oldAssociation.Subscription__c ||
            newAssociation.Association__c != oldAssociation.Association__c ||
            newAssociation.Status__c != oldAssociation.Status__c ||
            newAssociation.SysPrRoleKey__c != oldAssociation.SysPrRoleKey__c ||
            newAssociation.Resend_to_LMS_Flag__c != oldAssociation.Resend_to_LMS_Flag__c 
        )){
        
            //Call COD to update Association. LMS Capture primary association update
            LMS_CornerStoneOnDemand.updateAssociation(newAssociation.Id);
        }
    }
}