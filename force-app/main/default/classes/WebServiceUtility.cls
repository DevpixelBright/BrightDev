@RestResource(urlMapping='/UpdateRets/*')
global with sharing class WebServiceUtility {

    @HttpPost
    global static String updateRetsOrderToActive(String retsOrderId) {
        List<RETS_Product_Order__c> lRetsOrders = [SELECT id, name, status__c FROM RETS_Product_Order__c WHERE id =: retsOrderId];
        RETS_Product_Order__c retsOrder = new RETS_Product_Order__c();
        retsOrder.Id = retsOrderId;
        retsOrder.Status__c = 'Active';
        update retsOrder;
        return retsOrder.Id;
    }
}