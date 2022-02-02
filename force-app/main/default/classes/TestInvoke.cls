public class TestInvoke {

    @InvocableMethod(label='InactivateSuspendedSubscriptions')
    public static void getAccountNames(List<Subscriptions__c> subs) {
        for(Subscriptions__c oSub : subs)
	        SMS_InactivateSubs_Future.inactivateSubscription(oSub.Name);
    }

}