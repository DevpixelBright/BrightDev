public class SubscriptionsLateFeeWaiverRequestHelper {
    public void createCaseWhenNeeded(List<Subscriptions__c> Subscriptions){
        
        List<Case> casesToCreate = new List<Case>();
        
        for(Subscriptions__c sub:Subscriptions){
            if(sub.Date_Waived__c <> Null){
                Case caseToAdd = new Case();
            }
        }
    }
}