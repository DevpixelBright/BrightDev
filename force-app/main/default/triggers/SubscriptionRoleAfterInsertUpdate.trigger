trigger SubscriptionRoleAfterInsertUpdate on Subscription_Role__c (after insert,after update) {

    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    //Call the future method with the list of Relationship__c objects
    Map<Id,String> newSubscriptionRoleJSONs = new Map<Id,String>();
    Map<Id,String> oldSubscriptionRoleJSONs = new Map<Id,String>();    
    
    for (Subscription_Role__c subRole : Trigger.new){
        if(String.isNotBlank(subRole.Service_Jurisdiction__c) && subRole.Service_Jurisdiction__c != 'MRIS'){
            system.debug('Bypass if not MRIS: ' + subRole.Id);
            continue;    
        }
        
        if (Trigger.isInsert && subRole.Role_Start_Date__c == null && subRole.MDS_Status__c == null){
           /* try{
                if(newSubscriptionRoleJSONs.size() == 5){
                    SubscriptionRoleProcessingUtility.createSubscriptionRole(newSubscriptionRoleJSONs);
                    newSubscriptionRoleJSONs = new Map<Id,String>();    
                }
            }
            catch(AsyncException e){
                newSubscriptionRoleJSONs = new Map<Id,String>();
            } */
            newSubscriptionRoleJSONs.put(subRole.id,JSON.serialize(subRole)); 
            
        }
        else if(Trigger.isUpdate && 'Inactive'.equals(subRole.Status__c) && 'Success'.equals(subRole.MDS_Status__c) && subRole.Role_End_Date__c == null) {
            try{
                if(newSubscriptionRoleJSONs.size() == 5 && oldSubscriptionRoleJSONs.size() != 0){
                    SubscriptionRoleProcessingUtility.deleteSubscriptionRole(newSubscriptionRoleJSONs);
                    newSubscriptionRoleJSONs = new Map<Id,String>();
                    oldSubscriptionRoleJSONs = new Map<Id,String>();    
                }
            }
            catch(AsyncException e){
                newSubscriptionRoleJSONs = new Map<Id,String>();
                oldSubscriptionRoleJSONs = new Map<Id,String>();
            }            
            
            newSubscriptionRoleJSONs.put(subRole.id, JSON.serialize(subRole));
            oldSubscriptionRoleJSONs.put(subRole.id, JSON.serialize(Trigger.oldMap.get(subRole.id)));
        }
    }
    
    System.debug('oldSubscriptionRoleJSONs.keySet().size() ---> ' + oldSubscriptionRoleJSONs.keySet().size());
    System.debug('newSubscriptionRoleJSONs.keySet().size() ---> ' + newSubscriptionRoleJSONs.keySet().size());
    
    try {    
        if ((oldSubscriptionRoleJSONs.keySet().size() == 0) && (newSubscriptionRoleJSONs.keySet().size() > 0))
            SubscriptionRoleProcessingUtility.createSubscriptionRole(newSubscriptionRoleJSONs);
        else if ((oldSubscriptionRoleJSONs.keySet().size() != 0) && (newSubscriptionRoleJSONs.keySet().size() > 0))
            SubscriptionRoleProcessingUtility.deleteSubscriptionRole(newSubscriptionRoleJSONs);

    } 
    catch(AsyncException e){}
}