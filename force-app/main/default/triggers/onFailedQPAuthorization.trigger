trigger onFailedQPAuthorization on SFQPConnector__c (after insert, before update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    //Error Processing
    try {
        if (Trigger.isInsert) {
            SFQPFailuresProcessingUtility.processQPMessages(Trigger.new);
        } else {
            List<SFQPConnector__c> sList = new List<SFQPConnector__c>();
            for (SFQPConnector__c s : Trigger.new) {
                SFQPConnector__c SOLD = Trigger.oldMap.get(s.id);
                System.debug('SOLD.QPStatus__c ------>' + SOLD.QPStatus__c);
                System.debug('s.QPStatus__c ---> ' + s.QPStatus__c);
                if (!s.QPStatus__c.equals(SOLD.QPStatus__c)) {
                    sList.add(s);
                }
            }
            SFQPFailuresProcessingUtility.processQPMessages(sList);
        }
    } catch (Exception ex) {
        System.debug(ex);    
    }
}