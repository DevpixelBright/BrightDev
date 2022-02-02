trigger CaseAfterInsertUpdate on Case (after insert, after update) {
    if(Trigger.isAfter ){ 
        if(executionFlowUtility.DisableAllTriggers) return;
        
        Case_Trigger_Flags__c flags = Case_Trigger_Flags__c.getInstance();
        
        if(!flags.Disable_Case_Shadow_Object__c) {
            CaseShadowObj.HandleCaseOperation(trigger.oldMap, trigger.newMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
        }
    }
}