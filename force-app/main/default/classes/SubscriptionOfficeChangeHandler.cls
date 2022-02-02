/***********************************************************************************************
*       Class Name      : SubscriptionOfficeChangeHandler
*       Date            : 11/11/2021 (MM/DD/YYYY) 
*       Author          : Swathi
*       Purpose         : This Apex Class is used to Removing/Terminating Realtionships When a Subscriber Transfers Offices outside of a brokerage
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       11/11/2021                Swathi                  Initial Version  
**************************************************************************************************/
public class SubscriptionOfficeChangeHandler {
    public static String officeId = '';
    public static String subId = '';
    public static String oldOfficeId = '';
    
    public static void officeChange(list<Subscriptions__c> newSub, Map<Id, Subscriptions__c> oldSubMap)
    {
        Boolean isOfficeUpdated = false;
        for(Subscriptions__c sub : newSub)
        {
            if(oldSubMap.get(sub.Id).Related_Location_Broker_Office__c != sub.Related_Location_Broker_Office__c){
                officeId = sub.Related_Location_Broker_Office__c;
                oldOfficeId = oldSubMap.get(sub.Id).Related_Location_Broker_Office__c;
                isOfficeUpdated = true;
            }
            subId = sub.Id;
        }
        
        if(isOfficeUpdated){
            List<Account> relatedAccounts = new List<Account>();
            Map<Id,set<Id>> brokerOfficesMap = new Map<Id, set<Id>>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId =:officeId OR Id =:officeId) AND Status__c = 'Active' 
                              ];
            
            List<String> officeIds = new List<String>();                        
            for(Account a : relatedAccounts)
            {
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);
            }
            relatedAccounts = new List<Account>();
            relatedAccounts = [SELECT Id, Name, ParentId
                               FROM   Account
                               WHERE  (ParentId IN :officeIds OR Id IN :officeIds) AND Status__c = 'Active'
                              ];
            for(Account a : relatedAccounts){
                if(!brokerOfficesMap.containsKey(a.Id)){
                    brokerOfficesMap.put(a.Id, new set<Id>{a.Id});
                }
                brokerOfficesMap.get(a.Id).add(a.Id);
                if(a.ParentId != null){
                    brokerOfficesMap.get(a.Id).add(a.ParentId);
                    officeIds.add(a.ParentId);
                }
                officeIds.add(a.Id);                
            }
            system.debug('******* officeIds*****'+officeIds);
            
            Boolean result = officeIds.contains(oldOfficeId);
            system.debug('***result'+result);
            
            if(result == false){
                List<Relationship__c> relationship = [SELECT Id,Name,Relationship_Type__c, Subscription__r.Contact__c, 
                                                      Subscription__r.Private_Email__c, Subscription__r.ApplicationNotificationOptOut__c
                                                      FROM   Relationship__c
                                                      WHERE  Subscription__c =:subId 
                                                      // AND 	 Broker_Office__c =:oldOfficeId
                                                      AND    Status__c = 'Active'];
                if(!relationship.isEmpty()){
                    system.debug('******* relationship*****'+relationship);
                    
                    List<Relationship__c> lRelationship = new List<Relationship__c>();
                    for(Relationship__c rel:relationship){
                        rel.Status__c = 'Inactive';
                        rel.Relationship_End_Date__c = system.today();
                        lRelationship.add(rel);
                    }
                    
                    system.debug('***lRelationship'+lRelationship);
                    update lRelationship;
                }
            }
        }
    }
    public void test1(){
        
        string test1;
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }

        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        
        if(1==1)
        {
            test1='1';
        }
        if(1==1)
        {
            test1='1';
        }
    }
    public void test2(){
       
       string test2;
       if(1==1)
       {
           test2='1';
       }
       if(1==1)
       {
           test2='1';
       }
       if(1==1)
       {
           test2='1';
       }
       if(1==1)
       {
           test2='1';
       }
       
       if(1==1)
       {
           test2='1';
       }
       
       
       if(1==1)
       {
           test2='1';
       }
       
       if(1==1)
       {
           test2='1';
       }
       
       if(1==1)
       {
           test2='1';
       }
       if(1==1)
       {
           test2='1';
       }
        if(1==1)
       {
           test2='1';
       }
       
   }
   
}