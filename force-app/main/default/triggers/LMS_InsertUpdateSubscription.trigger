trigger LMS_InsertUpdateSubscription on Subscriptions__c (after update) {
    /*
        This trigger handles the Cornerstone OnDemand process.
        Based on the matching criteria it call the appropriate class and method
    */
    
    for(Subscriptions__c newSubscription : trigger.new){
        Subscriptions__c oldSubscription = trigger.oldMap.get(newSubscription.Id);
        
        if(newSubscription.Status__c == 'Active'){
            if(oldSubscription.Status__c == 'In Progress'){
                //Call COD to insert an user. LMS Subscription New
                LMS_CornerStoneOnDemand.insertUser(newSubscription.Id);
            }
            else if(newSubscription.Status__c != oldSubscription.Status__c){
               //Call COD to reactivate/update user.LMS Capture subscription reactivation 
               LMS_CornerStoneOnDemand.updateUser(newSubscription.Id);
            }
            else if(newSubscription.Status__c == oldSubscription.Status__c && (
                    newSubscription.Nickname__c != oldSubscription.Nickname__c ||
                    newSubscription.Subscription_Type__c != oldSubscription.Subscription_Type__c ||
                    newSubscription.QAS_Mailing_County__c != oldSubscription.QAS_Mailing_County__c ||
                    newSubscription.Related_Location_Broker_Office__c != oldSubscription.Related_Location_Broker_Office__c ||
                    newSubscription.Primary_Phone__c != oldSubscription.Primary_Phone__c ||
                    newSubscription.Private_Email__c != oldSubscription.Private_Email__c ||
                    newSubscription.State__c != oldSubscription.State__c ||
                    newSubscription.Contact_Last_Name__c != oldSubscription.Contact_Last_Name__c ||
                    newSubscription.Contact_Nickname__c != oldSubscription.Contact_Nickname__c ||
                    newSubscription.Resend_to_LMS_Flag__c != oldSubscription.Resend_to_LMS_Flag__c                 
                   )){
                //Call COD to update Active subscription. LMS Capture active subscription update
                LMS_CornerStoneOnDemand.updateUser(newSubscription.Id);
            }
        }
    }
}