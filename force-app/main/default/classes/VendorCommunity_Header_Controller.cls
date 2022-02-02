public class VendorCommunity_Header_Controller {
     
    public String name { get; private set; }
    public String initials { get; private set; }
    public String primaryId { get; private set; }
    public Boolean hasPic { get; private set; }
    public String picUrl { get; private set; }
    public Boolean isBroker { get; private set; }
    public Boolean isTrendUser { get; set; }
    public Boolean isMrisUser { get; set; }
    public Boolean isBrightUser { get; set; }
    
    public VendorCommunity_Header_Controller() {
        name = 'Unknown User';
        primaryId = '';
        hasPic = false;
        picUrl = '';
        isBroker = false;
        isTrendUser = false;
        isMrisUser = false;
        isBrightUser = false;
        
        List<User> currentUser = [SELECT   FederationIdentifier, ContactId, Contact.Name 
                                    FROM     User 
                                    WHERE    Id = :Userinfo.getUserId()
                                    ];
               
        if (currentUser.size() == 0) return;
        
        
        hasPic = false;
        picUrl = Label.MRIS_PROFILE_PIC_URL + primaryId + '.jpg';
        
        List<Contact> contact = [SELECT  Id, Name, AccountId, Account.Name
                                    FROM    Contact
                                    WHERE   Id =: currentUser[0].ContactId
                                    ];
        
        if (contact.size() == 0) return;

        //name = contact[0].Account.Name;
        name = contact[0].Name.toUpperCase();
        name = name.trim();      
        List<String> parts = name.split(' ');
        system.debug('---parts-->'+parts);
        
        initials = parts[0].substring(0, 1) + parts[parts.size() - 1].substring(0, 1);
        
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}