trigger CaseLinker on Case (before insert, after insert) {
    
//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;
    
    // update Cure contact on Case
    if(trigger.isInsert){
        if(trigger.isBefore){
            //Process in bulk
            CaseLinkerBatch cb = new CaseLinkerBatch();
            cb.Process(trigger.new);
            
            CureCaseContact.linkCureContactwithCase(trigger.new);
        }
        else
            CureCaseContact.handleFailureCases(trigger.new);
    }
    
}