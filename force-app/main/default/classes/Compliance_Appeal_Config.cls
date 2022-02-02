/**
*    This class is the controller for the custom object:
*    Compliance_Appeal_Config__c
**/

public with sharing class Compliance_Appeal_Config {
   public Integer aTimer{get;set;}
   public Integer mDay1{get;set;}
   public Integer mDay2{get;set;}
   public Integer mDay3{get;set;}
   public Compliance_Appeal_Config__c ca{get;set;}

   public Boolean isEdit { get; set; }
   
   /*
    * constructor for ComplianceAppealCFGx class
    */
   public Compliance_Appeal_Config() {
      initVals();
   }
   void initVals() {
      ca = [select id,Appeal_Timer__c,mail_days1__c,mail_days2__c,mail_days3__c 
            from Compliance_Appeal_Config__c limit 1];
      setPgVals();
   }
   
   void setPgVals() {
      aTimer = (Integer)ca.Appeal_Timer__c;
      mDay1 = (Integer)ca.mail_days1__c;
      mDay2 = (Integer)ca.mail_days2__c;
      mDay3 = (Integer)ca.mail_days3__c;
   }
   
   // method to change the Appeal timer -- number of days
   Boolean setVals() {
      // if changed, apply the new values
      if (ca.Appeal_Timer__c != aTimer || ca.mail_days1__c != mDay1 ||
          ca.mail_days2__c != mDay2 || ca.mail_days3__c != mDay3) {
/*         
         if (ca.Appeal_Timer__c < 20) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 'Bill days must be greater than 20.'));
            return false;
         }
*/
         
         if (ca.mail_days1__c >= ca.Appeal_Timer__c ||
             ca.mail_days2__c >= ca.Appeal_Timer__c ||
             ca.mail_days3__c >= ca.Appeal_Timer__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 'Mail days must be less than Bill day.'));
            return false;
         }

         update ca;
         setPgVals();
         
         // reset billdate on pending fines
         List<Compliance_Fine__c> cfl = 
            [select id from Compliance_Fine__c where status__c = 'Pending'];
         update cfl;
      }
      return true;
   }

   public PageReference editConfig() {
      isEdit = true;
      return null;
  }

   /*
    * submit button pressed - save case
    */
   public PageReference submit() {
      if (!setVals()) return System.currentPageReference();
      isEdit = false;
      return null;
   }
   public PageReference cancel() {
      isEdit = false;
      initVals();
      return null;
   }
}