public class Communities_Inactives {
    public static string primaryId;
    public static string url;
    public static string subscriptionId;
    public static Boolean isInactiveSub = false;
    public static PageReference pg;
    
    @AuraEnabled
    public Static string submitSubscription1(String url) {
        pg = new PageReference(url);
        subscriptionId =  pg.getParameters().get('id');
        try {
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid BRIGHT Subscription ID');
            
            List<User> correctUser = [
                SELECT  FederationIdentifier
                FROM    User
                WHERE   Id = :UserInfo.getUserId() AND
                FederationIdentifier = :subscriptionId
            ];
            
            if(correctUser.size() == 0) 
                throw new CustomException('Invalid user');
            
            primaryId = correctUser[0].FederationIdentifier;
            
            if(String.IsBlank(primaryId)) 
                throw new CustomException('Invalid Id');
            return primaryId;
        }catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static Subscriptions__c submitSubscription(String url) {
        try {
            Boolean isInactiveSub = false;
            submitSubscription1(url);
            List<Subscriptions__c> subs = [SELECT Id, 
                                           Contact__c,Status__c,
                                           Service_Jurisdiction__c,
                                           Billing_Jurisdiction__c,
                                           Name,SFDC_Application__r.Type__c,Contact_Type__c,
                                           Subscription_Type__c ,
                                           TREND_Login_Name__c                                                          
                                           FROM    Subscriptions__c 
                                           WHERE   Name = :primaryId];
            
            system.debug(subs);
            
            if(subs[0].Status__c == 'Inactive'){
                isInactiveSub = true;
                return subs[0];
            }else{
                throw new CustomException('Active Subscription');
            }
            
        }catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class CustomException extends Exception {}
}