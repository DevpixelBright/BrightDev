public without sharing class ListingProtect_Controller extends Bootstrap_Controller
{
 
    public String Title { get { return System.Label.MRIS_LISTING_PROTECT_TITLE; } }
    public String Name { get; private set; }
    public String Office { get; private set; }
    public String Remarks { 
        get
        {
            if (OptChangeDisabled)
                return 'You will be able to change your participation on ' + Date.ValueOf(Original.Listing_Protect_UnLock_Date__c).format() + '.';
            else {               
                if (Original.Listing_Protect_Program__c)
                    return 'You can leave the MRIS ' + Title + ' by unchecking the Opt-In checkbox.';         
                else
                    return 'You are currently not participating in the MRIS ' + Title + '. Check the Opt-In checkbox to join the program.';
            }
        }
    }
    
    public String SubscriptionId { get; set; }
    public Boolean OptIn { get; set; }
    public Boolean Agreed { get; set; }
    public String Initials { get; set; }
    public String SubmitText { get { return SubmitDisabled ? 'Please agree at the bottom of the Terms of Use' : 'Save'; } }
    
    public Boolean Allowed { get; set; }
    public Boolean ContinueDisabled { get { return String.isBlank(SubscriptionId); } }
    public Boolean OptChangeDisabled { get { return Original != null && Original.Listing_Protect_UnLock_Date__c > system.Today(); } }
    public Boolean OptingIn { get { return Original != null && !Original.Listing_Protect_Program__c && OptIn; } }
    public Boolean OptingOut { get { return Original != null && Original.Listing_Protect_Program__c && !OptIn; } }
    public Boolean SubmitDisabled { get { return !Agreed || String.isBlank(Initials) || Initials.length() < 2; } }

    private Account Original { get; set; }   
        
    public ListingProtect_Controller() {
        super();

        User currentUser = [select id,Name,FederationIdentifier from User where id = :Userinfo.getUserId()];        
        SubscriptionId = currentUser.FederationIdentifier;        

        LoadDetails();
    }
    
    public void LoadDetails() {
        Allowed = GetSubscription();
    }

    public Boolean GetSubscription() {
        Original = null;
        
        Clear();
        
        if (String.isBlank(SubscriptionId))
            return false;
            
        try {
            Subscriptions__c subs = [
                SELECT  Contact__r.Name,
                        Related_Location_Broker_Office__r.Id,
                        Related_Location_Broker_Office__r.Name,
                        Related_Location_Broker_Office__r.Listing_Protect_Program__c,
                        Related_Location_Broker_Office__r.Listing_Protect_UnLock_Date__c,
                        (
                            SELECT  id 
                            FROM    Relationships__r
                            WHERE   Relationship_Type__c = 'Broker Of Record' AND
                                    (
                                        Relationship_End_Date__c = null OR 
                                        Relationship_End_Date__c >= TODAY
                                    )
                        )
                FROM    Subscriptions__c 
                WHERE   name = :SubscriptionId AND
                        Primary__c = true and
                        Related_Location_Broker_Office__r.Company_Type__c = 'Broker Office'
            ];

            if (subs.Relationships__r.size() == 0)
                return false;
                
            Original = subs.Related_Location_Broker_Office__r;
                    
            Name = subs.Contact__r.Name;
            Office = Original.Name;
            OptIn = Original.Listing_Protect_Program__c;
            
            return true;
        }
        catch(Exception e) { return false; }            
    }    

    public void Clear() {
        Agreed = false;
        Initials = null;
    }

    public void Submit() {
        if (SubmitDisabled)
            return;
            
        Account changeSet = new Account();
        
        changeSet.Id = Original.Id;
        changeSet.Listing_Protect_Program__c = OptIn;
        changeSet.BOR_Initials__c = Initials.toUpperCase();   
        
        update changeSet;
        
        GetSubscription();       
    }
    
    public void Cancel() {
        OptIn = Original.Listing_Protect_Program__c;
    }

    public void Refresh() {} 
}