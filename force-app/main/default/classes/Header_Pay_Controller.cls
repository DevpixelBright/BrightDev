public class Header_Pay_Controller {
    
    public String name { get; private set; }
    public String initials { get; private set; }
    public String primaryId { get; private set; }
    public Boolean hasPic { get; private set; }
    public String picUrl { get; private set; }
    public Boolean isBroker { get; private set; }
    public Boolean isTrendUser { get; set; }
    public Boolean isMrisUser { get; set; }
    public Boolean isBrightUser { get; set; }
    
    public Header_Pay_Controller() {
        name = 'Unknown User';
        primaryId = '';
        hasPic = false;
        picUrl = '';
        isBroker = false;
        isTrendUser = false;
        isMrisUser = false;
        isBrightUser = false;
        
        List<User> currentUser = [
            SELECT   FederationIdentifier 
            FROM     User 
            WHERE    Id = :Userinfo.getUserId()
        ];
               
        if (currentUser.size() == 0) return;

        primaryId = currentUser[0].FederationIdentifier;
        
        if (String.IsBlank(primaryId)) return;
        
        hasPic = true;
        picUrl = Label.MRIS_PROFILE_PIC_URL + primaryId + '.jpg';       

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

        name = contact[0].Name;
        name = name.trim();

        List<String> parts = name.split(' ');

        initials = parts[0].substring(0, 1) + parts[parts.size() - 1].substring(0, 1);
        
        List<Subscriptions__c> subs = [
            SELECT  (
                        SELECT  Id 
                        FROM    Relationships__r
                        WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager') AND
                                (
                                    Relationship_End_Date__c = null OR 
                                    Relationship_End_Date__c >= TODAY
                                )
                    ),
                    Service_Jurisdiction__c,
                    Billing_Jurisdiction__c,
                    Name,
                    TREND_Login_Name__c                                                           
            FROM    Subscriptions__c 
            WHERE   Contact__c = :contact[0].Id AND
                    Status__c = 'InActive'
        ];
        
        for (Integer i = 0; i < subs.size(); i++) {
            System.debug('***sub rel:' + subs[i].Relationships__r);
            isBroker = isBroker || subs[i].Relationships__r.size() > 0;
 
            if(String.isNotBlank(subs[i].Service_Jurisdiction__c) && subs[i].Service_Jurisdiction__c.equals('TREND'))
                isTrendUser = true;
                
            if(String.isNotBlank(subs[i].Service_Jurisdiction__c) && subs[i].Service_Jurisdiction__c.equals('BRIGHT'))
                isBrightUser = true;                
            
            if(String.isBlank(subs[i].Service_Jurisdiction__c) || subs[i].Service_Jurisdiction__c.equals('MRIS'))
                isMrisUser = true;
                          
        }
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}