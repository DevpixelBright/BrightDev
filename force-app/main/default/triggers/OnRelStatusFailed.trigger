trigger OnRelStatusFailed on Relationship__c (after insert, after update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    List<Relationship__c> relationships = new List<Relationship__c>();

    for(Relationship__c relationship : Trigger.new){
        if(Trigger.isUpdate){
            if(relationship.MDS_Status__c == 'Failed' && Trigger.oldMap.get(relationship.Id).MDS_Status__c != 'Failed')
                relationships.add(relationship);
        }
        else if(Trigger.isInsert){
            if(relationship.MDS_Status__c == 'Failed')
                relationships.add(relationship);                
        }
    }
    
    if(relationships.size() > 0)
        CreateCaseOnFailed.createCaseForRel(relationships);    
}