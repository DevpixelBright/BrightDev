public class Communities_OfficeRoster_Export {
    
    public String officeId { get; set; } 
    public Map<String,String> officeIds { get; set; }
    public List<String> status { get; set; }
    public List<SubscriptionDetails> activeSubscriptions { get; set; }
    
    public Communities_OfficeRoster_Export() {
        try {
            status = new List<String>();
            List<User> currentUser = [SELECT   FederationIdentifier, Name 
                                      FROM     User 
                                      WHERE    Id = :Userinfo.getUserId()
                                     ];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 
            
            //String subscriptionId = currentUser[0].FederationIdentifier;
            String subscriptionId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Federated ID found >> ' + currentUser);
            
            if(ApexPages.currentpage().getparameters().get('Status') != null)
                status.add(ApexPages.currentpage().getparameters().get('Status')); 
            else {
                status.add('Active');
                status.add('Inactive');
            } 
            system.debug('**************** subscriptionId ******************'+subscriptionId);
            
            
            List<String> parentIds = new List<String>();
            Map<String,String> asOffices = new Map<String,String>();
            Map<String,String> omOffices = new Map<String,String>();
            Boolean isBOR = false;
            
            for(Relationship__c relationship : [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,Broker_Office__r.Name,
                                                Subscription__r.Name, Subscription__r.Contact__r.Name  
                                                FROM    Relationship__c
                                                WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                                                AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                                AND     Subscription_ID__c = :subscriptionId
                                               ]){
                                                   system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                                                   system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                                                   
                                                   if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                                                       parentIds.add(relationship.Broker_Office__r.ParentId);            
                                                   
                                                   if(String.IsNotBlank(relationship.Broker_Office__c))
                                                       parentIds.add(relationship.Broker_Office__c);
                                                   
                                                   if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                                                       isBOR = true;
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
                }
                else if(omOffices.size() > 0){
                    officeIds = new Map<String,String>(omOffices);
                }
            } 
            else{
                
                officeIds = new Map<String,String>();
                
                for(Account a : [SELECT Id, Name
                                 FROM   Account
                                 WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                ])
                    officeIds.put(a.Id, a.Name);
            }
            
            /* Load all subscriptions on page load */
            
            officeId = 'All';                  
            getSubscriptions();
            asOffices.clear();
            omOffices.clear();
            parentIds.clear();
        } 
        
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));              
        }  
    }
    
    public void getSubscriptions() {
        activeSubscriptions = new List<SubscriptionDetails>(); 
        System.debug('*** officeId:' + officeId);
        
        Set<String> selectedOffices = new Set<String>();
        if(officeId == 'All')
            selectedOffices = officeIds.keyset();
        else
            selectedOffices.add(officeId);     
        
        system.debug('---selectedOffices--->'+selectedOffices);
        system.debug('---Status--->'+Status);
        string query = 'SELECT Id,Name, Contact__r.Name,contact__c,Subscription_Type__c, Contact_Type__c, Date_Terminated__c, Status_Change_Reason__c,';
        query += 'Status__c, License__r.Name,License__r.License_State__c, License__r.License_Expiration_Date__c,Primary_Subscription_Association__r.Association_Name__c,Related_Location_Broker_Office__r.Name,';
        query += '(SELECT Id,Name, License__r.License_State__c,License__r.License_Expiration_Date__c,License__r.License_Type__c,License__r.Name FROM Subscription_Licenses__r),';
        query += '(SELECT Id,Name,Association_Name__c FROM Related_Association__r WHERE Subscription_IsPrimary__c = true),'; 
        query += '(SELECT Subscription_ID__c, Team_Name__r.Subscription_ID__c, Team_Name__r.Team_Name__c FROM Team_Members__r WHERE Status_of_team__c = \'Active\' AND Status_of_Team_Member__c = \'Active\') '; 
        query += ' FROM   Subscriptions__c '; 
        query += ' WHERE  Related_Location_Broker_Office__c IN :selectedOffices AND Status__c IN :Status '; 
        if(Status.contains('Inactive')){
            query += ' AND Date_Terminated__c >= LAST_N_MONTHS:18 '; 
        }                                     
        query += ' order by name asc limit 10000'; 
        system.debug('query---'+query);
        for(Subscriptions__c subscription : Database.query(query)) {
            // contactIdLicenses.put(subscription.Contact__c, new License__c());
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
            sd.TeamName = '';
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
            }
            activeSubscriptions.add(sd);
        }
        selectedOffices.clear();
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