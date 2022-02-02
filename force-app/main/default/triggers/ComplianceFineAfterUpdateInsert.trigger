trigger ComplianceFineAfterUpdateInsert on Compliance_Fine__c (after insert, after update, after delete) {

   Set<String> vIds = new Set<String>();
   if (trigger.new != null) {
      for (Compliance_Fine__c compFine: trigger.new) {
         String vId = compFine.name.replaceAll('-.*','');
         if (!vIds.contains(vId)) vIds.add(vId);
      }
   }
   if (trigger.old != null) {
      for (Compliance_Fine__c compFine: trigger.old) {
         String vId = compFine.name.replaceAll('-.*','');
         if (!vIds.contains(vId)) vIds.add(vId);
      }
   }
   List<Compliance_Violation__c> cvLst = 
      new List<Compliance_Violation__c>([select id
         FROM Compliance_Violation__c 
         WHERE name in :vIds]);
   update cvLst;      
}