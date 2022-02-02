trigger CaseBeforeInsertUpdate on Case (before insert, before update) {
    
    if(executionFlowUtility.DisableAllTriggers) return;
    
    if(trigger.isInsert) {
        CaseEntitlementManager entitlements = new CaseEntitlementManager();
        entitlements.AssignEntitlements(trigger.new);
    }
    
     
    
}