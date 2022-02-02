public class SubLicenseTriggerHandler {
   /* public static void validateSubLicense(List<Subscription_License__c> lNewSubLicense) {
        Profile userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()];
        if(userProfile.Name != 'eProcess Profile'){
            
            try { 
                Set<String> states = new Set<String>();
                Set<String> subscriptions = new Set<String>();
                Set<String> ids = new Set<String>();
                for(Subscription_License__c Sub : lNewSubLicense){
                    states.add(Sub.License_State__c);
                    subscriptions.add(Sub.Subscription__c);
                    ids.add(Sub.Id);
                    
                }	
                
                Set<String> uniqueValues = new Set<String>();
                for(Subscription_License__c Sublicense : [SELECT Id, License_State__c, Subscription__c 
                                                          FROM   Subscription_License__c 
                                                          WHERE License_State__c IN :states 
                                                          AND Subscription__c = :subscriptions 
                                                          AND SoftDelete__c != 'Yes'
                                                          AND Id NOT IN : ids]){
                    uniqueValues.add(Sublicense.License_State__c.toLowerCase()+''+Sublicense.Subscription__c);                                      
                }
                for(Subscription_License__c Sublicense : lNewSubLicense ){
                   
                    if(uniqueValues.contains(Sublicense.License_State__c.toLowerCase()+''+Sublicense.Subscription__c)){
                        Sublicense.addError('A license for this state already exists.  Please validate the correct license by verifying it with Real Estate Commission for that state.');
                    }
                }
            }catch(Exception e) {
                system.debug(e);
            }
        }    
    }*/
}