public class Communities_StatementBase_Controller {
    
    public Boolean isTrendUser { get; set; }
    public Boolean isMrisUser { get; set; }
    
    public Communities_StatementBase_Controller() {
        
        isTrendUser = false;
        isMrisUser = false;
        
        List<User> currentUser = [
            SELECT   FederationIdentifier 
            FROM     User 
            WHERE    Id = :Userinfo.getUserId()
        ];
               
        if (currentUser.size() == 0) return;

        String primaryId = currentUser[0].FederationIdentifier;
        
        if (String.IsBlank(primaryId)) return;

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
            SELECT  Id, Name,
                    Service_Jurisdiction__c,
                    Billing_Jurisdiction__c,
                     TREND_Login_Name__c                                                           
            FROM    Subscriptions__c 
            WHERE   Contact__c = :contact[0].Id AND
                    Status__c = 'Active'
        ];
        
        for (Integer i = 0; i < subs.size(); i++) {
            if(String.isNotBlank(subs[i].Service_Jurisdiction__c) && subs[i].Service_Jurisdiction__c.equals('TREND'))
                isTrendUser = true;
            
            if(String.isBlank(subs[i].Service_Jurisdiction__c) || subs[i].Service_Jurisdiction__c.equals('MRIS'))
                isMrisUser = true;
                          
        }
    }
    
    public class CustomException extends Exception {}
}