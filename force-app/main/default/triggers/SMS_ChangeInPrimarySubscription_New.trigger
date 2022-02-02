trigger SMS_ChangeInPrimarySubscription_New on Contact (after update) {
    List<String> primaryChangeContactIds = new List<String>();
    Set<String> subscriptionIds = new Set<String>();
    Map<String,String> primarySecondarySubNames = new Map<String,String>();
    Map<String,String> SubIdNames = new Map<String,String>();

    for (Contact newContact : trigger.new) {
                
        String primarySubId = newContact.Primary_Subscription__c;        
        String secondarySubId = trigger.oldMap.get(newContact.Id).Primary_Subscription__c;        
        
        if(String.IsNotBlank( primarySubId ) && String.IsNotBlank(secondarySubId) && (primarySubId != secondarySubId )) {
            system.debug('*** primarySubId : ' + primarySubId );
            system.debug('*** secondarySubId : ' + secondarySubId );
            
            primaryChangeContactIds.add(newContact.Id);
            subscriptionIds.add(primarySubId);
            subscriptionIds.add(secondarySubId);
                     
        }
        
    }

    for(Subscriptions__c subscription : [SELECT Id, Name, Primary__c FROM Subscriptions__c WHERE Id IN :subscriptionIds]){
        SubIdNames.put(subscription.Id, subscription.Name);
    }
    
    for(String contactId : primaryChangeContactIds){
        String primarySubId = trigger.newMap.get(contactId).Primary_Subscription__c;        
        String secondarySubId = trigger.oldMap.get(contactId).Primary_Subscription__c;
        
        String primarySubName = SubIdNames.get(primarySubId);
        String secondarySubName = SubIdNames.get(secondarySubId);
        
        primarySecondarySubNames.put(primarySubName,secondarySubName);
        if(primarySecondarySubNames.Size() == 10) {
            SMS_ChangeInPrimarySubscription_New.changePrimarySubscription(primarySecondarySubNames);
            primarySecondarySubNames = new Map<String,String>();
        }       
    }
    if(primarySecondarySubNames.Size() > 0)
        SMS_ChangeInPrimarySubscription_New.changePrimarySubscription(primarySecondarySubNames);
        
}