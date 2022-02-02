trigger SFQPConnectorBeforeInsertUpdate on SFQPConnector__c (before insert, before update) {
  
//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    //Process records
    try {
        SFQPConnectorUtility.process(Trigger.newMap, Trigger.oldMap,Trigger.new);
    } catch (Exception ex) {
        System.debug(ex);
    }
   
}