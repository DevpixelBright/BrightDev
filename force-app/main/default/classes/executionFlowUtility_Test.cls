@istest
private class executionFlowUtility_Test{

    private static testMethod void doTestOne(){   

        executionFlowUtility.triggersOn();
        executionFlowUtility.triggersOff();
        
        executionFlowUtility obj = new executionFlowUtility();
        obj.setContactUpdate(true);
        obj.getContactUpdate();
        obj.setSubscriptionUpdate(true);
        obj.getSubscriptionUpdate();
        obj.setAccountUpdate(true);
        obj.getAccountUpdate();
        
        Boolean test = executionFlowUtility.DisableAllTriggers;
    }

}