public class Communities_Brokerage_Old {

    public Boolean isTrendUser { get; set;}
    public Boolean isBOR { get; set;}
    public Boolean isAS { get; set; }
    public Boolean isOM { get; set; }
    public Communities_Brokerage_Old() {
        try {
            isBOR = false;
            isAS = false;
            isOM = false;
            
            List<User> currentUser = [
                SELECT   FederationIdentifier, Name
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()
            ];
                   
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
           system.debug('************* currentUser[0].FederationIdentifier ******** '+currentUser[0].FederationIdentifier);
            String subscriptionId = currentUser[0].FederationIdentifier;
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Federated ID found >> ' + currentUser);
            
            isTrendUser = false;    
            List<Subscriptions__c> subscription = [SELECT Id, 
                                                           Name, 
                                                           Contact__c, 
                                                           Service_Jurisdiction__c, 
                                                           Contact__r.Service_Jurisdiction__c
                                                    FROM   Subscriptions__c
                                                    WHERE Name =: subscriptionId];
            system.debug('******************** subscription list ***********'+subscription);
            if(subscription.Size() != 1)
                throw new CustomException('Invalid MRIS Subscription ID: Multiple subscriptions found >> ' + currentUser);
                 
            if(String.isNotBlank(subscription[0].Service_Jurisdiction__c) && subscription[0].Service_Jurisdiction__c.equals('TREND'))
                isTrendUser = true;
            
            for(Relationship__c r : [SELECT  Id, 
                                             Relationship_Type__c  
                                     FROM    Relationship__c
                                     WHERE   Relationship_Type__c IN ('Broker Of Record','Authorized Signer')
                                     AND     (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                                     AND     Subscription_ID__c = :subscriptionId]){
                system.debug('*** Relationship_Type__c  :' + r.Relationship_Type__c  );
                if(r.Relationship_Type__c  == 'Broker Of Record')
                    isBOR = true;
                else if(r.Relationship_Type__c  == 'Authorized Signer') 
                    isAS = true;
                else if(r.Relationship_Type__c == 'Office Manager')
                    isOM = true;
            }  
            system.debug('*** isBOR :' + isBOR ); 
            system.debug('*** isAS :' + isAS ); 
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));   
        }          
    }
    
    public class CustomException extends Exception {}
}