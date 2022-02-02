public class SubscriptionTriggerHandler {

    public static void inactivateRetsProductOrder(Map<id,Subscriptions__c> mSubscriptions){
        Set<Id> subIds = new Set<Id>();
        for(Subscriptions__c oSub : mSubscriptions.values()){
            if(oSub.status__c == 'Inactive' && oSub.Status_Change_Reason__c == 'Terminated'){
                subIds.add(oSub.id);    
            }
        }
        List<RETS_Product_Order__c> lRETSOrder = [SELECT id, status__c, Status_Reason__c FROM RETS_Product_Order__c WHERE status__c =: 'Active' AND Agent__c IN: subIds];
        for(RETS_Product_Order__c oRETS : lRETSOrder){
            oRETS.status__c = 'Inactive';
            oRETS.Status_Reason__c = 'Subscriber Terminated';
        }
        
        if(!lRETSOrder.isEmpty()){
            update lRETSOrder;
        }
    }
}