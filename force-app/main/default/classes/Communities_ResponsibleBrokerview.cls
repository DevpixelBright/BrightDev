public class Communities_ResponsibleBrokerview {
    public Boolean hasBOR { get; set; }
    public String subscriptionId { get; set; }
    public List<Account> offices { get; set; }
    public Map<Id, Subscription_License__c> subcriberMap{get; set;}
    public List<Id> subscriberIds = new List<Id>();
    public Map<String,List<Account>> mAccountState{get;set;}
    
    
    
    public Communities_ResponsibleBrokerview(){
        Map<String,List<Account>> mAccountState = new Map<String,List<Account>>();
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
        if (String.IsBlank(subscriptionId))
            throw new CustomException('Invalid BRIGHT Subcription ID: No Subscription ID found ' );   
        
        List<Relationship__c> relationships = new List<Relationship__c>();
        relationships = [SELECT  Id, 
                         Status__c,
                         Relationship_Type__c, 
                         Broker_Office__c,
                         Broker_Office__r.ParentId,
                         Broker_Office__r.Name,
                         Subscription__r.Name, 
                         Subscription__r.Contact__r.Name  
                         FROM    Relationship__c
                         WHERE   Relationship_Type__c = 'Broker Of Record'
                         AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                         AND    Status__c = 'Active'
                         AND     Subscription__r.Name  = : subscriptionId]; 
        System.debug('****' + relationships);              
        
        if(relationships.Size() == 0)
            throw new CustomException('You do not have permission to access this page');
        else{
            hasBOR = true;
        }
        
        if(relationships.size() > 0) {               
            List<String> parentIds = new List<String>();
            
            if(String.IsNotBlank(relationships[0].Broker_Office__r.ParentId))
                parentIds.add(relationships[0].Broker_Office__r.ParentId);            
            
            if(String.IsNotBlank(relationships[0].Broker_Office__c))
                parentIds.add(relationships[0].Broker_Office__c);       
            
            offices = new List<Account>(); 
            offices = [SELECT Id, 
                       Name,
                       State__c
                       FROM   Account
                       WHERE  (ParentId IN :parentIds OR Id IN :parentIds)
                       AND    Status__c = 'Active'];
            
            
            for(Account oAccount : offices) {
                if(!mAccountState.containsKey(oAccount.State__c)){
                    mAccountState.put(oAccount.State__c,new List<Account>());
                }
                mAccountState.get(oAccount.State__c).add(oAccount);
                
            }
            
            if(offices.Size() > 0) {
                subcriberMap = new Map<Id, Subscription_License__c> ([SELECT Id, License_Name__c, License_Type__c, Subscription__r.Contact_Type__c, 
                                                                      Subscription__r.Subscription_Type__c, Subscription__r.Related_Location_Broker_Office__c,
                                                                      Subscription__r.Related_Location_Broker_Office__r.Name, Subscription__r.Name,Subscription__c,License_Contact_Name__c 
                                                                      FROM Subscription_License__c
                                                                      WHERE Subscription__r.Status__c = 'Active'
                                                                      AND License__r.License_Type__c = 'Broker' 
                                                                      AND SoftDelete__c != 'Yes'                                                                     
                                                                      AND Subscription__r.Contact_Type__c IN ('Agent', 'Broker', 'Office Manager')
                                                                      AND Subscription__r.Subscription_Type__c IN ('Realtor/Shareholder', 'Realtor/Non Shareholder', 'Licensee/Non Realtor')
                                                                      AND Subscription__r.Related_Location_Broker_Office__c IN :offices]);
            }
        }
    }
    public class CustomException extends Exception {}
    
}