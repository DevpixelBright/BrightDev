trigger RelationshipBeforeInsertUpdate on Relationship__c (before insert, before update) {
  /*  
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    System.debug('Trigger.isInsert ---> ' +Trigger.isInsert);
    if(Trigger.isBefore ){
        if ( Trigger.isInsert) {
            for (Relationship__c r : Trigger.new) {
                r.status__c = 'Active';
                System.debug('Tr.status__c ---> ' +r.status__c);           
            } 
            //The below  line is commented for SAL-2291
            RelationshipTriggerHandler.validateUniqueResponsibleBroker(Trigger.new); //unique responsible broker under a Office and State Combination
        }
        
        if(Trigger.isUpdate){
             //The below  lines is commented for SAL-2291
            RelationshipTriggerHandler.validateUniqueResponsibleBroker(Trigger.new);//unique responsible broker under a Office and State Combination
        }
        
        
        List<Relationship__c> trendRelationships = new List<Relationship__c>();
        List<Relationship__c> brightRelationships = new List<Relationship__c>();
        for(Relationship__c r : trigger.new){
            if(r.Service_Jurisdiction__c == 'TREND'){
                trendRelationships.add(r);
            }else if(r.Service_Jurisdiction__c == 'BRIGHT'){
                brightRelationships.add(r);
            }
        }   
        if(trendRelationships.size() > 0){
            TRENDUtility.processRelationships(trendRelationships);
        }
        if(brightRelationships.size()>0){
            BRIGHTUtility.processRelationships(brightRelationships);
        }
    }
    
    //below did as part of SAL-966
    
    Map<String, String> subscriptionBORIds = new Map<String, String>();
    Map<String, String> OfficeIdBORIds = new Map<String, String>();
    
    if(trigger.isInsert || trigger.isUpdate){
        for (Relationship__c r : Trigger.new) {
            if(r.Relationship_Type__c == 'Broker Of Record' && r.Status__c == 'Active' &&
               (r.Relationship_End_Date__c == null || r.Relationship_End_Date__c > system.today() )){
                   if(subscriptionBORIds.keyset().contains(r.Subscription__c))
                        r.addError('Found duplicate Broker of Record for subscription id: ' + r.Subscription_ID__c);
                   else
                      subscriptionBORIds.put(r.Subscription__c, r.Name);
                   
                   if(OfficeIdBORIds.keyset().contains(r.Subscription__c))
                       r.addError('Found duplicate Broker of Record for Office id: ' + r.Broker_Office_Code__c);
                   else
                      OfficeIdBORIds.put(r.Broker_Office__c, r.Name);                   
               }
        }
    }
    
    
    
    System.debug('subscriptionBORIds---> ' +subscriptionBORIds);
    System.debug('OfficeIdBORIds---> ' +OfficeIdBORIds);
    
    if(subscriptionBORIds.size() > 0 || OfficeIdBORIds.size() > 0){
        Set<String> OfficeAndParents = new Set<String>();
        
                for(Account a : [SELECT Id, Name, ParentId, Parent.ParentId
                             FROM   Account
                             WHERE  (ParentId IN :OfficeIdBORIds.keySet() OR Id IN :OfficeIdBORIds.keySet()) AND Status__c = 'Active'])
            {
                OfficeAndParents.add(a.Id);
                if(a.ParentId != null)
                    OfficeAndParents.add(a.ParentId);
                if(a.parent.ParentId != null)
                    OfficeAndParents.add(a.Parent.ParentId);
            }
            
            System.debug('OfficeAndParents---> ' +OfficeAndParents);
            
           for( Subscriptions__c sub : [SELECT Id, Name, Related_Location_Broker_Office__c,
                                         Related_Location_Broker_Office__r.ParentId 
                                         FROM Subscriptions__c
                                         WHERE Id in: subscriptionBORIds.keySet()])
            {
                if(sub.Related_Location_Broker_Office__c != null)
                    OfficeAndParents.add(sub.Related_Location_Broker_Office__c);
                if(sub.Related_Location_Broker_Office__r.ParentId != null)
                    OfficeAndParents.add(sub.Related_Location_Broker_Office__r.ParentId);
                
            }   
   
            
          if(OfficeAndParents.size() > 0 || subscriptionBORIds.size() > 0 ){
                
              map<string, Relationship__c> subOfficeRelationMap = new map<string, Relationship__c>();
              set<string> dupCheckIds = new set<string>();
              
              list<Relationship__c> relList = [SELECT  Id, Name, Relationship_Type__c, Broker_Office__c, Broker_Office__r.Name,
                                               Subscription__c, Subscription__r.Name
                                               FROM    Relationship__c
                                               WHERE   Relationship_Type__c IN ('Broker Of Record')
                                               AND     Status__c = 'Active'
                                               AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= today )
                                               AND     (Broker_Office__c IN : OfficeAndParents
                                                        OR     Subscription__c IN : subscriptionBORIds.keySet())
                                               ];
          
              system.debug('---relList--->:'+relList.size()+'--'+relList);
              if(relList != null && relList.size() > 0)
              {
                   for(Relationship__c rel: relList){
                       if(trigger.isInsert)
                           trigger.new[0].addError('Active BOR already exists for the Account '+rel.Broker_Office__r.Name+' with Subscription Id '+rel.Subscription__r.Name);
                       else if(trigger.isUpdate && relList.size() > 1 ){
                           //trigger.new[0].addError(relList[0].Name+' is Existing Broker of Record');
                           system.debug(trigger.newMap);
                           trigger.newMap.get(rel.Id).addError('Active BOR already exists for the Account '+rel.Broker_Office__r.Name+' with Subscription Id '+rel.Subscription__r.Name);
                       }
                   }
               }
   
          }
        
    }*/
}