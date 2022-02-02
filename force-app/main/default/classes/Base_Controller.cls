public class Base_Controller {
    public Boolean debugMode { get; private set; }

    public String primaryId { get; private set; }
    public boolean isValidAndInActiveSubscription { get; private set; }
    public String requestedSubscriptionId { get; private set; } 

    public Base_Controller() {
        String debug = ApexPages.currentPage().getParameters().get('debug');
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);

        primaryId = '';

        List<User> correctUser = [
            SELECT  FederationIdentifier
            FROM    User
            WHERE   Id = :UserInfo.getUserId()
        ];

        if(correctUser.size() == 0) return;

        primaryId = correctUser[0].FederationIdentifier;

        if(String.IsBlank(primaryId)) return;

        List<Contact> contact = [
            SELECT  Id,
                    Name
            FROM    Contact
            WHERE   Id IN (
                        SELECT  Contact__c
                        FROM    Subscriptions__c 
                        WHERE   Name = :primaryId
                    )
        ];

        if (contact.size() == 0) return;

        List<Subscriptions__c> subs = [
            SELECT Name, (
                        SELECT  Id
                        FROM    Relationships__r
                        WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager') AND
                                (
                                    Relationship_End_Date__c = null OR 
                                    Relationship_End_Date__c >= TODAY
                                )
                    )
            FROM    Subscriptions__c 
            WHERE   Contact__c = :contact[0].Id AND
                    Status__c = 'InActive'
        ]; 

        requestedSubscriptionId = ApexPages.currentPage().getParameters().get('id');
        log('Requested Subscription Id: ' + requestedSubscriptionId);

        Boolean bypass = Boolean.valueOf(Label.MRIS_Communities_Bypass_Access_Control);
        
        if (bypass || String.isBlank(requestedSubscriptionId)) {
            isValidAndInActiveSubscription = true;
    
            log('Bypassing access control...');
            log('isValidAndInActiveSubscription: ' + isValidAndInActiveSubscription);
    
            return;
        }
        else
            isValidAndInActiveSubscription = false;


        for (Integer i = 0; i<subs.size(); i++) {
            log('Associated Subscriptiontion: ' + subs[i].Id + ' Name: ' + subs[i].Name);
            if (requestedSubscriptionId.equals(subs[i].Name)) {
                isValidAndInActiveSubscription = true;
            }
        }

        log('isValidAndInActiveSubscription: ' + isValidAndInActiveSubscription);
    }

    private void log(String message) {
        if (debugMode)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}