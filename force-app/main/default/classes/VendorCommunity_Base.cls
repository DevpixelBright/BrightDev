public class VendorCommunity_Base {
 
    public Boolean debugMode { get; private set; }

    public String primaryId { get; private set; }
    public boolean isValidAndActiveSubscription { get; private set; }
    public String requestedSubscriptionId { get; private set; } 
    
        public PageReference forwardToStartPage() {
        if (UserInfo.getUserType().equals('Guest')) {
             return new PageReference(Label.Vendor_Communities_URL + 'login');
         }
         return null;
     }

    public VendorCommunity_Base() {
        String debug = ApexPages.currentPage().getParameters().get('debug');
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug); 
        

        primaryId = '';
        system.debug('---debugMode 14 ---'+debugMode);
        List<User> correctUser = [ SELECT  FederationIdentifier, contactId, Contact.Name
                                    FROM    User
                                    WHERE   Id = :UserInfo.getUserId()
                                    ];
        
        system.debug('---correctUser-'+correctUser+'---primaryId-->'+primaryId);

        if(correctUser.size() == 0) return;
                //primaryId = correctUser[0].FederationIdentifier;
               //if(String.IsBlank(primaryId)) return;
        
        if(correctUser[0].ContactId == null) return;
        
        List<Contact> contact = [SELECT  Id, Name
                                FROM    Contact
                                WHERE   Id =: correctUser[0].ContactId 
                                And Status__c = 'Active' 
                                And Account.Status__c = 'Active'
                                /*IN (
                                     SELECT  Contact__c
                                    FROM    Subscriptions__c 
                                     WHERE   Name = :primaryId
                                 )*/
                                ];
        
        if (contact.size() == 0) return;
        system.debug('---check 39 ---'+contact);
        
        isValidAndActiveSubscription = true;
        debugMode = true;
        
        
    }

    private void log(String message) {
        if (debugMode)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}