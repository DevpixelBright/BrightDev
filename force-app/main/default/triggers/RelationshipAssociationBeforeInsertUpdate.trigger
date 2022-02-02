trigger RelationshipAssociationBeforeInsertUpdate on Related_Association__c (before insert, before update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    if(Trigger.isInsert) {
        for(Related_Association__c ra : Trigger.new) {
            ra.Start_Date__c = Date.today();
            ra.Status__c = 'Active';
        }
    }
}