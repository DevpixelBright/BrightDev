@istest

public class SMS_OrderBatch_Test{
   static testMethod void orderBatchTest()
   {
      SMS_Order__c order = new SMS_Order__c();
        order.Name = 'Order Id';
        order.Token__c = 'bqFyrhqraFfGAJ7dEY/atiM5RbV3fStmvjP00XKO6Oc=';
        order.Zuora_Account_Id__c = '2c92c0f9430459c20143070e03101551';
        //order.MRIS_Subscription_Id__c = s.id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = true;
        order.Private_Email__c = ''; 
           insert order;       
     
     
     String query = 'SELECT Id,Status__c FROM SMS_Order__c WHERE Token__c =  \'bqFyrhqraFfGAJ7dEY/atiM5RbV3fStmvjP00XKO6Oc=\'';              
     SMS_OrderBatch updateOrder = new SMS_OrderBatch(query);
     Database.executeBatch(updateOrder);
     
     
     
   }

}