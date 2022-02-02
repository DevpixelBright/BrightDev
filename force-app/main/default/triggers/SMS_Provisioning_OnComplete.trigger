trigger SMS_Provisioning_OnComplete on SMS_Order__c (after update) {
    system.debug('*** trigger.new**'+trigger.new);
    for(SMS_Order__c order : trigger.new) {
        try{
             system.debug('*** inside trigger order.Status__c**'+order.Status__c); 
             if(order.Status__c == 'Completed' && trigger.oldMap.get(order.id).Status__c != 'Completed'){ 
                SMS_OrderOnCompletion orderCompletion = new SMS_OrderOnCompletion(order.id) ; 
                system.debug('*** Product Provisioning is Excecuted'); 
            }
        }
        catch(SMS_OrderOnCompletion.CustomException e){
            Subscriptions__c subscription = [SELECT Id,Name,
                                                    Contact__r.Id,
                                                    Related_Location_Broker_Office__r.Id
                                             FROM   Subscriptions__c
                                             WHERE  Id = :order.MRIS_Subscription_Id__c   
                                            ];
            //Create a Case
            Case c = new Case();
            c.AccountId = subscription.Related_Location_Broker_Office__r.Id;
            c.ContactId = subscription.Contact__r.Id;
            c.Description = e.getMessage();
            c.Subject = 'Product Provisioning Failure';
            c.Case_Reason__c = 'Wrong Data';
            c.Subscription_ID__c = subscription.Id;
            
            insert c;
            
            system.debug('*** Case:' + c);
            
        }
    }
}