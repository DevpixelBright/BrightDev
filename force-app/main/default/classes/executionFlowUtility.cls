public class executionFlowUtility {
   // Trigger control flags
   public static boolean subscriptionRoleAfterInsertUpdateFlag = false;
   public static boolean relationshipAfterInsertUpdateDeleteFlag = false;

   public static void setTriggers(boolean flag) {
      subscriptionRoleAfterInsertUpdateFlag = flag;
      relationshipAfterInsertUpdateDeleteFlag = flag;
   }

   public static void triggersOn() {
      setTriggers(false);
   }

   public static void triggersOff() {
      setTriggers(true);
   }

   // object level control flags
   public static boolean contactUpdate = true;
   public boolean getContactUpdate() { return contactUpdate; }
   public void setContactUpdate(boolean value) { contactUpdate = value; }

   public static boolean subscriptionUpdate = true;
   public boolean getSubscriptionUpdate() { return subscriptionUpdate; }
   public void setSubscriptionUpdate(boolean value) { subscriptionUpdate = value; }
     
   public static boolean accountUpdate= true;
   public boolean getAccountUpdate() { return accountUpdate; }
   public void setAccountUpdate(boolean value) { accountUpdate = value; }
   
   public static Boolean DisableAllTriggers {
    	get {
    		Bypass_Validation_rules__c bypass = Bypass_Validation_rules__c.getInstance();
    		return bypass.Disable_Validation_Rules__c;
    	}
    }
}