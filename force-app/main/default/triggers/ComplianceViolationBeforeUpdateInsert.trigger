trigger ComplianceViolationBeforeUpdateInsert on Compliance_Violation__c (before insert, before update) {

   Set<String> subIds = new Set<String>();
   for (Compliance_Violation__c cv: trigger.new) {
      subIds.add(cv.Subscription_ID__c);
   }
   Map<String, Subscriptions__c> subs = new Map<String, Subscriptions__c>();
   for (Subscriptions__c s1 : [Select Name,id,Related_Location_Broker_Office__c,contact__c, Private_Email__c
                               FROM Subscriptions__c WHERE Name in :subIds]) {
      subs.put(s1.name, s1);
   }

   for (Compliance_Violation__c cv: trigger.new) {
      if(subs.get(cv.Subscription_ID__c) != null) {
         cv.Subscription__c = subs.get(cv.Subscription_ID__c).id;
         cv.Private_Email__c = subs.get(cv.Subscription_ID__c).Private_Email__c;
      }
   }
}