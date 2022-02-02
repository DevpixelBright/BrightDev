trigger UpdateContactStatus on Subscriptions__c (after insert, after update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

if (!executionFlowUtility.contactUpdate)return;
    executionFlowUtility.subscriptionUpdate= false;
    executionFlowUtility.contactUpdate= false;
    
    for(Subscriptions__c s : Trigger.new)
    {
        if(s.Primary__c)
        {
            Contact c = [SELECT id, Status__c FROM Contact WHERE id =: s.Contact__c];
            
            c.Status__c = s.Status__c;
            update(c);
        }
    }
    executionFlowUtility.subscriptionUpdate= true;
    executionFlowUtility.contactUpdate= true;
}