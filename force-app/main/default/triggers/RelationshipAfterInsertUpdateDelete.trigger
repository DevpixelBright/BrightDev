trigger RelationshipAfterInsertUpdateDelete on Relationship__c (after insert, after update) {

    /* Exit trigger if records are inserted and/or updated by dataloader profile. */
    if (Utils.BypassValidationrules())
        return;
    
    /* Relationship associated subscriptions */
    Set<String> subscriptionIds = new Set<String>();
    for (Relationship__c r: Trigger.new) 
        subscriptionIds.add(r.Subscription__c);
    
    Map<Id, Subscriptions__c> subscriptionMap = new Map<Id, Subscriptions__c>([SELECT id, 
                                  status__c, 
                                  agentKey__C, 
                                  MDS_Status__C 
                           FROM Subscriptions__c 
                           WHERE id = :subscriptionIds 
                           AND agentKey__c != null 
                           AND MDS_Status__C = 'Success']);  
    
    /* Call the future method with the list of Relationship__c objects */
    Map<Id,String> newJsonAccountString = new Map<Id,String>();
    Map<Id,String> oldJsonAccountString = new Map<Id,String>();
         
    for (Relationship__c r: Trigger.new) {
        if(String.isNotBlank(r.Service_Jurisdiction__c) && r.Service_Jurisdiction__c != 'MRIS'){
            system.debug('Bypass if not MRIS: ' + r.Id);
            continue;    
        }
        List <Subscriptions__c> sList = new List<Subscriptions__c>();
        if(subscriptionMap.get(r.Subscription__c) != null)
            sList.add(subscriptionMap.get(r.Subscription__c)); 
        
        if (!'QP'.equals(r.Created_Source__c) && Trigger.isInsert && sList.size() > 0){
            try{
               // if(newJsonAccountString.size() == 5){
               //     RelationshipProcessingUtility.createRelationship(newJsonAccountString); 
                //    newJsonAccountString = new Map<Id,String>();
               // }
            }
            catch(AsyncException e){
                newJsonAccountString = new Map<Id,String>();
            }
            newJsonAccountString.put(r.id,JSON.serialize(r));
        } 
        else if(Trigger.isUpdate && 'Inactive'.equals(r.Status__c) && r.Relationship_End_Date__c == null && sList.size() > 0) {
            try{
                if(newJsonAccountString.size() == 5 && oldJsonAccountString.size() != 0){
                   // RelationshipProcessingUtility.deleteRelationship(newJsonAccountString); 
                    newJsonAccountString = new Map<Id,String>();
                    oldJsonAccountString = new Map<Id,String>();
                }
            }
            catch(AsyncException e){
                newJsonAccountString = new Map<Id,String>();
                oldJsonAccountString = new Map<Id,String>();
            }
            
            newJsonAccountString.put(r.id, JSON.serialize(r));
            oldJsonAccountString.put(r.id, JSON.serialize(Trigger.oldMap.get(r.id)));
        }
    }
    
    /*try {       
        if ((oldJsonAccountString.size() == 0) && (newJsonAccountString.size() > 0)) 
            RelationshipProcessingUtility.createRelationship(newJsonAccountString);       
        else if ((oldJsonAccountString.size() != 0) && (newJsonAccountString.size() > 0))          
            RelationshipProcessingUtility.deleteRelationship(newJsonAccountString);        
    } 
    catch(AsyncException e) {
    
    }*/
}