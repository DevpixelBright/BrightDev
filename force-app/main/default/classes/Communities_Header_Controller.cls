public class Communities_Header_Controller {
    
    public String name { get; private set; }
    public String initials { get; private set; }
    public String primaryId { get; private set; }
    public Boolean hasPic { get; private set; }
    public String picUrl { get; private set; }
    public Boolean isBroker { get; private set; }
    public Boolean isTrendUser { get; set; }
    public Boolean isMrisUser { get; set; }
    public Boolean isBrightUser { get; set; }
    public Boolean isActiveSubscription {get;set;}
    
    //public String email { get; private set; }
    //public String role { get; private set; }
    //public String association { get; private set; }
    //public String country { get; private set; }
    //public String acc { get; private set; }
    //public String accName { get; private set; }
    
    
    public Communities_Header_Controller() {
        name = 'Unknown User';
        primaryId = '';
        hasPic = false;
        picUrl = '';
        isBroker = false;
        isTrendUser = false;
        isMrisUser = false;
        isBrightUser = false;
        isActiveSubscription = false;
        
        List<User> currentUser = [
            SELECT   FederationIdentifier 
            FROM     User 
            WHERE    Id = :Userinfo.getUserId()
        ];
        
        if (currentUser.size() == 0) return;
        
        primaryId = currentUser[0].FederationIdentifier;
        
        if (String.IsBlank(primaryId)) return;
        
        //hasPic = true;
        Subscriptions__c sub = [select Private_Email__c, Subscription_Type__c, Country__c, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.Account_Name__c, BRIGHT_Agent_Key__c from Subscriptions__c where name = :primaryId ];
        if(sub.BRIGHT_Agent_Key__c == Null){
            hasPic = false;
        }
        //email = sub.Private_Email__c;
        //role = sub.Subscription_Type__c;
        //country = sub.Country__c;
        //acc = sub.Related_Location_Broker_Office__c;
        //accName = sub.Related_Location_Broker_Office__r.Account_Name__c;
        
        /* else {

String  v ='(SysMediaObjectKey EQ ' + sub.BRIGHT_Agent_Key__c +') AND (SysMediaType IN \'Agent Photo\')' ; 
List<String> rkey = new List<String>(SysAgentMedia_MDS.queryResourceKeys(EncodingUtil.urlEncode(v, 'UTF-8')));
if(rkey.isempty()) {
hasPic = false;
}
else {
Map<String, Map<String, String>> mapurl = SysAgentMedia_MDS.getSysAgentMediaDetails( 'SysMediaURL' , rkey);
Map<String, String> mp = mapurl.get(rkey[0]);
system.debug('== '+mp.get('SysMediaURL')); 
picUrl = mp.get('SysMediaURL');
if(picURL != null)
hasPic = true;
else
hasPic = false;     
}
}*/ 
        //picUrl = Label.MRIS_PROFILE_PIC_URL + primaryId + '.jpg';     
        
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
            Contact_Type__c,
            TREND_Login_Name__c                                                           
            FROM    Subscriptions__c 
            WHERE   Contact__c = :contact[0].Id 
            AND     Status__c = 'Active'
            
        ];
        
        if(subs.size() > 0){
            isActiveSubscription = true;
        }else{
            isActiveSubscription = false; 
        }
        Boolean isLimitedPublicRecords = false;
        for (Integer i = 0; i < subs.size(); i++) {
            if(subs[i].Contact_Type__c == 'Limited Public Records Only'){
                isBroker = false;
                isLimitedPublicRecords = true;
            }
            
            if(!isLimitedPublicRecords)
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