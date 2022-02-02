public without sharing class Communities_OfficeRoster {
    
    public String subscriptionId {get;set;}
    public String relationshipType { get; set; }
    public String contactName { get; set; }
    public String officeId { get; set; } 
    public String statusSelected { get; set; }
    public Map<String,String> officeIds { get; set; }
    
    transient public List<SubscriptionDetails> activeSubscriptions { get; set; }
    transient public List<SubscriptionDetails> inactiveSubscriptions { get; set; }
    
    public Integer activeSubsCount { get; set; }
    public Integer inactiveSubsCount { get; set; }
    public String terminateString { get; set; }
    
    public Communities_OfficeRoster() {
        try {
            List<User> currentUser = [
                SELECT   FederationIdentifier, Name
                FROM     User 
                WHERE    Id = :Userinfo.getUserId()];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
            
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: Subscription does not exist');   
            
            List<String> parentIds = new List<String>();
            Map<String,String> asOffices = new Map<String,String>();
            Map<String,String> omOffices = new Map<String,String>();
            Boolean isBOR = false;
            advSerchStr = '';
            
            for(Relationship__c relationship : [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,Broker_Office__r.Name,
                                                Subscription__r.Name, Subscription__r.Contact__r.Name  
                                                FROM    Relationship__c
                                                WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                                                AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                AND     Subscription_ID__c = :subscriptionId]){
                                                    
                                                    if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                                                        parentIds.add(relationship.Broker_Office__r.ParentId);            
                                                    
                                                    if(String.IsNotBlank(relationship.Broker_Office__c))
                                                        parentIds.add(relationship.Broker_Office__c);
                                                    
                                                    if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                                                        isBOR = true;
                                                        
                                                        relationshipType = relationship.Relationship_Type__c;
                                                        contactName = relationship.Subscription__r.Contact__r.Name;
                                                        officeId = relationship.Broker_Office__c;  
                                                        
                                                    } 
                                                    else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                                                        asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                                                    }
                                                    else if(relationship.Relationship_Type__c == 'Office Manager'){
                                                        omOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                                                    }
                                                }
            
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new Map<String,String>(asOffices);
                    relationshipType = 'Authorized Signer';
                    contactName = currentUser[0].Name;
                }
                else if(omOffices.size() > 0){
                    officeIds = new Map<String,String>(omOffices);
                    relationshipType = 'Office Manager';
                    contactName = currentUser[0].Name;
                }
                currentUser.clear();
                
            }
            else{
                
                officeIds = new Map<String,String>();
                
                for(Account a : [SELECT Id, Name
                                 FROM   Account
                                 WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active'])
                    officeIds.put(a.Id, a.Name);
            }
            
            /* Load all subscriptions on page load */
            officeId = 'All';
            statusSelected = 'Active';
            subscriptions();
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }  
    }
    
    public void subscriptions() {
        try{
            
            activeSubsCount = 0;
            inactiveSubsCount = 0;
            
            Set<String> selectedOffices = new Set<String>();
            if(officeId == 'All')
                selectedOffices = officeIds.keyset();
            else if(officeId == 'None')
                selectedOffices = new Set<String>();    
            else if(officeId != null && String.isNotBlank(officeId)){
                selectedOffices.addAll(officeId.split(','));
                if(selectedOffices.Size() == 0)
                    selectedOffices.add(officeId);     
            }        
            activeSubscriptions = new List<SubscriptionDetails>();        
            
            if(selectedOffices.Size() > 0) {            
                List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                subscriptions = returnSubscriptions(null, null);
                buildSubscriptions(subscriptions);
                subscriptions.clear();
                
                activeSubsCount = [SELECT COUNT() FROM Subscriptions__c
                                   WHERE  Status__c = 'Active'
                                   AND    Related_Location_Broker_Office__c IN :selectedOffices];
                inactiveSubsCount = [SELECT COUNT() FROM Subscriptions__c
                                     WHERE  Status__c = 'Inactive'
                                     AND    Related_Location_Broker_Office__c IN :selectedOffices And Date_Terminated__c >= LAST_N_MONTHS:18];                       
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }
    }
    
    public void buildSubscriptions(list<Subscriptions__c> subscriptions){
        activeSubscriptions = new List<SubscriptionDetails>();
        for(Subscriptions__c subscription : subscriptions){	
            SubscriptionDetails sd = new SubscriptionDetails();
            sd.subscriptionId = subscription.Id;
            sd.subscriptionName = subscription.Name;
            sd.contactName = subscription.Contact__r.Name;
            sd.type = subscription.Contact_Type__c;
            sd.subType = subscription.Subscription_Type__c;
            sd.status = subscription.Status__c;
            sd.licenseNumber = '';
            sd.licenseState = '';
            sd.associationAffiliation = '';
            sd.officeId = subscription.Related_Location_Broker_Office__r.Name;
            sd.statusChangeReason = subscription.Status_Change_Reason__c;
            sd.dateTerminated = subscription.Date_Terminated__c;
            sd.contactId = subscription.Contact__c;
            
            /* Subscription license */
            if(subscription.Subscription_Licenses__r.Size() > 0) {
                sd.licenseNumber = subscription.Subscription_Licenses__r[0].License__r.Name;
                sd.licenseState = subscription.Subscription_Licenses__r[0].License__r.License_State__c;
                sd.licenseExpiration = subscription.Subscription_Licenses__r[0].License__r.License_Expiration_Date__c;                
            } 
            
            /* Subscription association */
            if(subscription.Related_Association__r.Size() > 0) {
                sd.associationAffiliation = subscription.Related_Association__r[0].Association_Name__c;
            }
            
            /* Team Information*/
            sd.isTeamLead = 'No';
            //Team Subscription Id and Team member Subscription Id matchs then make teams as 'Team Lead'
            if(subscription.Team_Members__r.Size() > 0) {
                //sd.isTeamLead = 'Team Member';
                for(Team_Members__c tm : subscription.Team_Members__r)
                {
                    sd.TeamName = tm.Team_Name__r.Team_Name__c;
                    if(tm.Subscription_ID__c == tm.Team_Name__r.Subscription_ID__c){
                        sd.isTeamLead = 'Yes';
                    }
                }
                /*
                if(subscription.Team_Members__r[0].Subscription_ID__c == subscription.Team_Members__r[0].Team_Name__r.Subscription_ID__c){
                    sd.isTeamLead = 'Yes';
                }
				*/
            }
            activeSubscriptions.add(sd);
        }
        subscriptions.clear();
    }
    
    public list<Subscriptions__c> returnSubscriptions( string advSerchStr, string[] selSubs){
        
        Set<String> selectedOffices = new Set<String>();
        if(officeId == 'All')
            selectedOffices = officeIds.keyset();
        else if(officeId == 'None')
            selectedOffices = new Set<String>();    
        else if(officeId != null && String.isNotBlank(officeId)){
            selectedOffices.addAll(officeId.split(','));
            if(selectedOffices.Size() == 0)
                selectedOffices.add(officeId);     
        }
        System.debug('***' + selectedOffices);
        
        string query = 'SELECT Id, Name, Contact__r.Name, Date_Terminated__c, Status_Change_Reason__c, Subscription_Type__c, Contact_Type__c, Contact__c, Status__c, Related_Location_Broker_Office__r.Name,';
        query += '(SELECT Id, Name, License__r.License_State__c, License__r.License_Expiration_Date__c, License__r.License_Type__c, License__r.Name FROM   Subscription_Licenses__r),';
        query += '(SELECT Id, Name, Association_Name__c FROM Related_Association__r WHERE Primary__c = true AND (End_Date__c = null OR End_Date__c >= today)),';
        query += '(SELECT Subscription_ID__c, Team_Name__r.Subscription_ID__c, Team_Name__r.Team_Name__c FROM Team_Members__r WHERE Status_of_team__c = \'Active\' AND Status_of_Team_Member__c = \'Active\') ';
        query += 'FROM Subscriptions__c WHERE';
        
        if(selectedOffices != null )
            query += ' Status__c = :statusSelected AND Related_Location_Broker_Office__c IN :selectedOffices ';                         
        
        if(statusSelected.toLowerCase() == 'inactive')
            query += ' And Date_Terminated__c >= LAST_N_MONTHS:18';
        
        if(advSerchStr != null && advSerchStr != ''){
            query += ' And ( (Name like \'%'+advSerchStr+'%\' )';
            query += ' Or (Contact__r.Name like \'%'+advSerchStr+'%\' )';
            query += ' Or (Contact_Type__c like \'%'+advSerchStr+'%\' )';
            query += ' Or (Subscription_Type__c like \'%'+advSerchStr+'%\' )';
            query += ' Or (Status__c like \'%'+advSerchStr+'%\' )';
            query += ' Or (Related_Location_Broker_Office__r.Name like \'%'+advSerchStr+'%\' ) )';
        }
        
        if(selSubs != null && !selSubs.isEmpty()){
            query += ' And Id IN : selSubs';
        }
        
        query += ' order by name asc limit 4000';
        
        list<Subscriptions__c> subscriptions = Database.query(query);
        return subscriptions;
    }
    
    public string advSerchStr {get; set;}
    public void advSearchResults(){
        try{
            Set<String> selectedOffices = new Set<String>();
            if(officeId == 'All')
                selectedOffices = officeIds.keyset();
            else if(officeId == 'None')
                selectedOffices = new Set<String>();    
            else if(officeId != null && String.isNotBlank(officeId)){
                selectedOffices.addAll(officeId.split(','));
                if(selectedOffices.Size() == 0)
                    selectedOffices.add(officeId);     
            }
            
            if(advSerchStr != null && advSerchStr != ''){
                
                List<Subscriptions__c> subscriptions = returnSubscriptions(advSerchStr, null);
                buildSubscriptions(subscriptions);
                subscriptions.clear();
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }
    }
    
    public string selTermSubs {get; set;}
    
    public void getTerminaterSubs(){
        try{
            if(selTermSubs != null && selTermSubs != ''){
                string[] selSubs = selTermSubs.split(',');
                if(selSubs != null){
                    List<Subscriptions__c> subscriptions = returnSubscriptions(null, selSubs);
                    buildSubscriptions(subscriptions);
                    subscriptions.clear();
                }
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }
    }
    
    
    
    public void terminateSubscribers() {
        try {
            List<subscriberData> subscribers = (List<subscriberData>) JSON.Deserialize(terminateString, List<subscriberData>.class);
            if(subscribers.Size() > 0) {
                Map<String, String> subscribersMap = new Map<String, String>();
                Map<String, String> subscribersOfficeMap = new Map<String, String>();
                for(subscriberData subscriber : subscribers) {
                    subscribersMap.put(subscriber.Id, subscriber.ChangeReason); 
                    subscribersOfficeMap.put(subscriber.Id, subscriber.TransferredTo);    
                }
                List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                List<Note> notes = new List<Note>();
                
                subscriptions = [SELECT Id,Name, Status__c, Status_Change_Reason__c, Date_Terminated__c, Service_Jurisdiction__c 
                                 FROM   Subscriptions__c 
                                 WHERE  Id IN :subscribersMap.keySet()];
                for(Subscriptions__c subscription: subscriptions) {
                    subscription.Status__c = 'Inactive';
                    subscription.Status_Change_Reason__c =  'Broker Requested';
                    subscription.Date_Terminated__c = Date.Today();
                    Note n = new Note();
                    n.Title = Userinfo.getName() + ' has terminated the subscriber on ' + DateTime.now().format();
                    n.Body = 'Reason for Termination: ' + subscribersMap.get(subscription.Id);
                    if(subscribersOfficeMap.get(subscription.Id) != null && String.isNotBlank(subscribersOfficeMap.get(subscription.Id)))
                        n.Body += ', Transferred To Office:' + subscribersOfficeMap.get(subscription.Id);     
                    n.ParentId = subscription.Id;
                    notes.add(n);
                }

                update subscriptions;
                insert notes;

                subscriptions();  
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }         
    }
    
    @RemoteAction
    public static String terminateSubscribers1(String terminateString1) {
        try {
            List<subscriberData> subscribers = (List<subscriberData>) JSON.Deserialize(terminateString1, List<subscriberData>.class);
            if(subscribers.Size() > 0) {
                Map<String, String> subscribersMap = new Map<String, String>();
                Map<String, String> subscribersOfficeMap = new Map<String, String>();
                for(subscriberData subscriber : subscribers) {
                    subscribersMap.put(subscriber.Id, subscriber.ChangeReason); 
                    subscribersOfficeMap.put(subscriber.Id, subscriber.TransferredTo);    
                }
                List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                List<Note> notes = new List<Note>();
                List<Id> subscriptionIds = new List<String>(); //New Line: BRIG-3642 changes added by Mounika
                subscriptions = [SELECT Id, Status__c, Status_Change_Reason__c, Date_Terminated__c, Service_Jurisdiction__c 
                                 FROM   Subscriptions__c 
                                 WHERE  Id IN :subscribersMap.keySet()];
                for(Subscriptions__c subscription: subscriptions) {
                    subscription.Status__c = 'Inactive';
                    subscription.Status_Change_Reason__c =  'Broker Requested'; 
                    subscription.Date_Terminated__c = Date.Today();
                    Note n = new Note();
                    n.Title = Userinfo.getName() + ' has terminated the subscriber on ' + DateTime.now().format(); //'Terminated';
                    n.Body = 'Reason for Termination: ' + subscribersMap.get(subscription.Id);
                    if(subscribersOfficeMap.get(subscription.Id) != null && String.isNotBlank(subscribersOfficeMap.get(subscription.Id)))
                        n.Body += ', Transferred To Office:' + subscribersOfficeMap.get(subscription.Id);     
                    n.ParentId = subscription.Id;
                    notes.add(n);
                    subscriptionIds.add(subscription.Id); //New Line: BRIG-3642 changes added by Mounika
                }
                update subscriptions;
                insert notes;
                
                //New Block: BRIG-3642 changes added by Mounika
                if(subscriptionIds.Size() > 0) {
                    List<Relationship__c> relations = [SELECT Id, Status__c, Relationship_End_Date__c FROM Relationship__c WHERE Subscription__c IN: subscriptionIds AND Status__c = 'Active'];
                    if(relations.Size() > 0) {
                        for(Relationship__c rel : relations) {
                            rel.Status__c = 'Inactive';
                            rel.Relationship_End_Date__c = Date.today();
                        }
                        system.debug('********relations********'+relations);
                        update relations;
                        system.debug('********relationsssssssss********'+relations);
                    }
                }                
                
                return 'Success';
            }
        }
        catch(Exception e) {
            return e.getMessage();              
        }
        
        return null;         
    }
    
    public class subscriberData {
        public String Id { get; set; }
        public String ChangeReason { get; set; } 
        public String TransferredTo { get; set; }        
    } 
    
    public Class SubscriptionDetails {
        public String subscriptionId { get; set; }
        public String subscriptionName { get; set; }
        public String contactName { get; set; }
        public String contactId { get; set; }
        public String type { get; set; }
        public String subType { get; set; }
        public String status { get; set; }
        public String licenseNumber { get; set; }
        public String licenseState { get; set; }
        public Date licenseExpiration { get; set; }
        public String associationAffiliation { get; set; }
        public String officeId { get; set; }
        public String statusChangeReason { get; set; }
        public Date dateTerminated { get; set; }
        public String isTeamLead { get; set; }
        public String TeamName { get; set; }
    } 
    
    public class CustomException extends Exception {}
}