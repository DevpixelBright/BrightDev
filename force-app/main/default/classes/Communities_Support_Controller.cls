public class Communities_Support_Controller {

    public String serviceJurisdiction { get; set; }
    
    public Communities_Support_Controller() {
        List<User> currentUser = [
            SELECT   FederationIdentifier 
            FROM     User 
            WHERE    Id = :Userinfo.getUserId()];
               
        if (currentUser.size() == 0) return;

        String primaryId = currentUser[0].FederationIdentifier;
        
        if (String.IsBlank(primaryId)) return; 
        
        List<Subscriptions__c> subscription = [SELECT Id, Name, Service_Jurisdiction__c FROM Subscriptions__c WHERE Name =:primaryId];
        if(subscription.Size() != 1) return;
        serviceJurisdiction = subscription[0].Service_Jurisdiction__c;           
    }

}