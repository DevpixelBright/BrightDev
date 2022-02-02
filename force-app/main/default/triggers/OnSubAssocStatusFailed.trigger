trigger OnSubAssocStatusFailed on Related_Association__c (after insert, after update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    List<Related_Association__c> subscriptionAssociations = new List<Related_Association__c>();

    for(Related_Association__c subscriptionAssociation : Trigger.new){
            if(Trigger.isUpdate){
                if(subscriptionAssociation.MDS_Status__c == 'Failed' && Trigger.oldMap.get(subscriptionAssociation.Id).MDS_Status__c != 'Failed')
                    subscriptionAssociations.add(subscriptionAssociation);
            }
            else if(Trigger.isInsert){
                if(subscriptionAssociation.MDS_Status__c == 'Failed')
                    subscriptionAssociations.add(subscriptionAssociation);
            }
    }
    
    if(subscriptionAssociations.size() > 0)
        CreateCaseOnFailed.createCaseForSubAssc(subscriptionAssociations);
}