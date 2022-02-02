trigger SMS_PremiumProductsReinstatement on SMS_Order__c (after update) {
    
    for(SMS_Order__c order : trigger.new) {        
         if(order.IsEzJoinApplication__c && order.Status__c == 'Completed' && trigger.oldMap.get(order.id).Status__c != 'Completed') 
             SMS_OnActivationWorkflow.createSubscription([SELECT Name FROM Subscriptions__c WHERE id  = :order.MRIS_Subscription_Id__c].Name,true);      
    }
}