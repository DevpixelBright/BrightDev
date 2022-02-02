trigger RelationshipAssociationAfterInsertUpdate on Related_Association__c (after insert, after update) {
    
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    //Call the future method with the list of Relationship__c objects
    Map<Id,String> newSubscriptionAssociationJSONs = new Map<Id,String>();
    Map<Id,String> oldSubscriptionAssociationJSONs = new Map<Id,String>();
    
    if(Trigger.isInsert){
        for (Related_Association__c subAssociation : Trigger.new){ 
            if(String.isNotBlank(subAssociation.Service_Jurisdiction__c) && subAssociation.Service_Jurisdiction__c != 'MRIS'){
                system.debug('Bypass if not MRIS: ' + subAssociation.Id);
                continue;    
            }     
            // if (newSubscriptionAssociationJSONs.size() == 5){
            //     SubscriptionAssociationProcessingUtility.createSubscriptionAssociation(newSubscriptionAssociationJSONs);
            //     newSubscriptionAssociationJSONs = new Map<Id,String>();
            // }
            newSubscriptionAssociationJSONs.put(subAssociation.Id,JSON.serialize(subAssociation));        
        }
        
        //if (newSubscriptionAssociationJSONs.size() > 0) 
        //    SubscriptionAssociationProcessingUtility.createSubscriptionAssociation(newSubscriptionAssociationJSONs);
    }
    
    if (Trigger.isUpdate) {
        for (Related_Association__c subAssociation : Trigger.old){
            if(String.isNotBlank(subAssociation.Service_Jurisdiction__c) && subAssociation.Service_Jurisdiction__c != 'MRIS'){
                system.debug('Bypass if not MRIS: ' + subAssociation.Id);
                continue;    
            }         
            if (('Inactive'.equals(Trigger.newMap.get(subAssociation.id).Status__c)) && 'Active'.equals(subAssociation.Status__c) && subAssociation.End_Date__c == null) {
                //  if (oldSubscriptionAssociationJSONs.size() == 5){
                //      SubscriptionAssociationProcessingUtility.updateSubscriptionAssociation(newSubscriptionAssociationJSONs,oldSubscriptionAssociationJSONs);
                //     newSubscriptionAssociationJSONs = new Map<Id,String>();
                //     oldSubscriptionAssociationJSONs = new Map<Id,String>();
                // }
                
                oldSubscriptionAssociationJSONs.put(subAssociation.Id,JSON.serialize(subAssociation));   
                newSubscriptionAssociationJSONs.put(subAssociation.Id,JSON.serialize(Trigger.newMap.get(subAssociation.Id)));
            }
        }
        
        // if (oldSubscriptionAssociationJSONs.keySet().size() > 0) 
        //     SubscriptionAssociationProcessingUtility.updateSubscriptionAssociation(newSubscriptionAssociationJSONs,oldSubscriptionAssociationJSONs);  
        
    }
    /*Set<Id> subIds = new Set<Id>();
Map<Id, Subscriptions__c> mSubs = new Map<Id, Subscriptions__c>();

if(Trigger.isInsert && Trigger.isUpdate){
for(Related_Association__c assc : Trigger.new){
if(assc.Subscription__c != null)
subIds.add(assc.Subscription__c);    
}

if(!subIds.isEmpty()){
mSubs = new Map<Id, Subscriptions__c>([SELECT Id, status__c,(SELECT id, name, start_date__c FROM Related_Association__r WHERE Status__c = 'Active') FROM Subscriptions__c where Id IN: subIds]);
}
mSubs
}*/
    
    
}