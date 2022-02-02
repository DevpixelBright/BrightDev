trigger SubscriptionAfterInsertUpdate on Subscriptions__c (after insert, after update) {
    
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;

    // QAS required code
    //QAS_NA.CAAddressCorrection.ExecuteCAAsyncForTriggerConfigurationsOnly(trigger.new); 
    
    if(trigger.isUpdate)
        LT_ValidateListingRequests.validateSubscriptions(trigger.oldMap, trigger.newMap);
    
    List<Id> accountIds = new List<Id>();
    Map<Id,String> newInsertJsonSubscriptionString = new Map<Id,String>();
    Map<Id,String> oldUpdateJsonSubscriptionString = new Map<Id,String>();
    Map<Id,String> newUpdateJsonSubscriptionString = new Map<Id,String>();
    //Map<String,String> contactSubIds = new Map<String,String>();
    
    
    for(Subscriptions__c subscription : trigger.new){
        
        
        if(String.isNotBlank(subscription.Service_Jurisdiction__c) && subscription.Service_Jurisdiction__c != 'MRIS'){
            system.debug('Bypass if not MRIS: ' + subscription.Id);
            continue;    
        }
        
        accountIds.add(subscription.Related_Location_Broker_Office__c);
        
        //if(subscription.Primary__c) 
            // contactSubIds.put(subscription.Id,subscription.Contact__c);
        
        if(trigger.IsInsert){
            if(subscription.Status__c.equals('Active'))
                subscription.addError('ERROR! initial status cannot be Active');
            
            if(subscription.Status__c.equals('Inactive'))//This agent is not yet created in cornerstone.  So create a new one
                newInsertJsonSubscriptionString.put(subscription.Id,JSON.serialize(subscription));
        }        
        else if(trigger.IsUpdate){
            Subscriptions__c oldSubscription = trigger.oldMap.get(subscription.id);
            accountIds.add(oldSubscription.Related_Location_Broker_Office__c);           
            
            if((subscription.MDS_Status__c == null || subscription.MDS_Status__c.equals(oldSubscription.MDS_Status__c)) 
                && ('In Progress'.equals(oldSubscription.Status__c) || 'Incomplete'.equals(oldSubscription.Status__c)) 
                && ('Inactive'.equals(subscription.Status__c) || 'Active'.equals(subscription.Status__c))
                && Utils.isNull(subscription.AgentKey__c)){
                //This agent is not yet created in cornerstone.  So create a new one
                newInsertJsonSubscriptionString.put(subscription.Id,JSON.serialize(subscription));
            }
            else if((subscription.MDS_Status__c == null || subscription.MDS_Status__c.equals(oldSubscription.MDS_Status__c))
                     && Utils.isNotNull(subscription.AgentKey__c)){
                //Pure update
                newUpdateJsonSubscriptionString.put(subscription.id,JSON.serialize(subscription));
                oldUpdateJsonSubscriptionString.put(subscription.id,JSON.serialize(oldSubscription));
            }
        }
    } 
    
    if(Trigger.isUpdate){
        List<Id> subscriptionIds = new List<Id>();
        subscriptionIds.addAll(newInsertJsonSubscriptionString.keyset());
        subscriptionIds.addAll(newUpdateJsonSubscriptionString.keyset());
        
        if(subscriptionIds.size() > 0){
            for(Subscription_Role__c subRole :[SELECT Id, Subscription__c,Subscription__r.Name,Role__c, SysPrRoleKey__c FROM Subscription_Role__c 
                                               WHERE  Subscription__c IN :subscriptionIds
                                               AND    Status__c = 'Active' AND MDS_Status__c != '']) {
    
               //Maybe lines 69/70 need to be commented out ... MFD 1/16/2020
                if(String.isBlank(subRole.SysPrRoleKey__c))
                   Trigger.newMap.get(subRole.Subscription__c).adderror('ERROR! Subscription: ' + subRole.Subscription__r.Name + ' missing cornerstone SysPrRoleKey on role: ' + subRole.Role__c);
            } 
        }  
    }
    
     try{ 
        //Any kind of inserts will be handled here
        if (newInsertJsonSubscriptionString.size() > 0){
            Map<Id,String> tempJsonSubscriptionString = new Map<Id,String>();
            for(Id subscriptionId : newInsertJsonSubscriptionString.keyset()){
             //   if(tempJsonSubscriptionString.size() == 5){
              //      SubscriptionUtility.sendSubscriptionToQueueProcessor('INSERT', tempJsonSubscriptionString, null);
              //      tempJsonSubscriptionString = new Map<Id,String>();
              //  }
                
                tempJsonSubscriptionString.put(subscriptionId,newInsertJsonSubscriptionString.get(subscriptionId));                 
            } 
          //  if(tempJsonSubscriptionString.size() > 0)
          //      SubscriptionUtility.sendSubscriptionToQueueProcessor('INSERT', tempJsonSubscriptionString, null);                  
        }
        
        //Any kind of updates will be handled here
        if (newUpdateJsonSubscriptionString.size() > 0 && oldUpdateJsonSubscriptionString.size() > 0  && !System.isBatch()){
            Map<Id,String> tempOldJsonSubscriptionString = new Map<Id,String>();
            Map<Id,String> tempNewJsonSubscriptionString = new Map<Id,String>();
            for(Id subscriptionId : newUpdateJsonSubscriptionString.keyset()){
                if(tempOldJsonSubscriptionString.size() == 5){
                  //  SubscriptionUtility.sendSubscriptionToQueueProcessor('UPDATE', tempNewJsonSubscriptionString, tempOldJsonSubscriptionString);
                    tempOldJsonSubscriptionString = new Map<Id,String>();
                    tempNewJsonSubscriptionString = new Map<Id,String>();
                }
                
                tempOldJsonSubscriptionString.put(subscriptionId,oldUpdateJsonSubscriptionString.get(subscriptionId));
                tempNewJsonSubscriptionString.put(subscriptionId,newUpdateJsonSubscriptionString.get(subscriptionId));                 
            }  
            
           // if(tempOldJsonSubscriptionString.size() > 0)
           //     SubscriptionUtility.sendSubscriptionToQueueProcessor('UPDATE', tempNewJsonSubscriptionString, tempOldJsonSubscriptionString);

        }
        
    } 
    catch(AsyncException e) {
       Trigger.new[0].adderror(e.getMessage());
    } catch(Exception ex) {
       Trigger.new[0].adderror(ex.getMessage());
       throw ex;
    }
    

     if(Trigger.isAfter && Trigger.isUpdate){
            SubscriptionOfficeChangeHandler.officeChange(Trigger.New, Trigger.OldMap);
        }
   
      
}