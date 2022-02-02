trigger SMS_ChangeInPrimarySubscription on Contact (after update) {
    for (Contact newContact : trigger.new) {
                
        String primarySubId = newContact.Primary_Subscription__c;        
        String secondarySubId = trigger.oldMap.get(newContact.Id).Primary_Subscription__c;
        
        
        if(String.IsNotBlank( primarySubId ) && String.IsNotBlank(secondarySubId) && (primarySubId != secondarySubId )) {
            system.debug('*** primarySubId : ' + primarySubId );
            system.debug('*** secondarySubId : ' + secondarySubId );
            
           
            Subscriptions__c primarySub = [SELECT Id, Name, Primary__c FROM Subscriptions__c WHERE Id = :primarySubId];     
            String primarySubName = primarySub .Name;
            Subscriptions__c secondarySub = [SELECT Id, Name, Primary__c FROM Subscriptions__c WHERE Id = :secondarySubId];
            String secondarySubName = secondarySub.Name;                 
               
            system.debug('*** primarySubName : ' + primarySubName );
            system.debug('*** secondarySubName : ' + secondarySubName );
            
            SMS_ChangeInPrimarySubscription.changePrimarySubscription(primarySubName , secondarySubName );  
         
        }
        
        /*
        Subscriptions__c oldSubscription = [SELECT Id, Name FROM Subscriptions__c WHERE Id = :trigger.oldMap.get(newContact.Id).Primary_Subscription__c];     
        System.Debug('*** aaa subscription - ' + oldSubscription.Name);
        Subscriptions__c newSubscription = [SELECT Id, Name FROM Subscriptions__c WHERE Id = :newContact.Primary_Subscription__c];     
        System.Debug('*** aaa subscription - ' + newSubscription.Name);

        */
    }
}