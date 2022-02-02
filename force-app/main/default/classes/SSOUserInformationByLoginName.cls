@RestResource(urlMapping='/GetSSOUserInformationByLoginName/*')
global with sharing class SSOUserInformationByLoginName{
    
    global class UserSSODetails {
        String recordFound;
        String message;
        String primarySubscriptionID;
        String primarySubscriptionRoleUpID;
        String isActive;
        String isSalesforceUser;
        String isPortalUser;
    }
    
    @HTTPGet
    global static UserSSODetails doGet(){
        UserSSODetails userSSODetail = new UserSSODetails();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String BRIGHT_LoginName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('Before decode BRIGHT_LoginName ' + BRIGHT_LoginName );
        
        BRIGHT_LoginName = EncodingUtil.urlDecode(BRIGHT_LoginName, 'UTF-8');
        System.debug('After decode BRIGHT_LoginName ' + BRIGHT_LoginName );
        
        try {
            /* Update Nov 14, 2018 by Casey Benko
             * -------
             * This web service is designed to take a Bright login name but has been modified to additionally
             * query for a TREND login name and Subscription ID, respectively, if a subsequent login is not found.
             * 
             * There is an assumption that a login name would be unique across the three
             */
           
            // initialize the subscription variable where the contact Id should be found
            Subscriptions__c s = NULL;
            
            // Query first by the BRIGHT Login
            List<Subscriptions__c> brightLoginSubs = [SELECT Contact__c  
                                  FROM   Subscriptions__c 
                                  WHERE  BRIGHT_LoginName__c = :BRIGHT_LoginName 
                                  AND    Status__c = 'Active' LIMIT 1
                                 ];
            
            // Set the non-empty result
            if(!brightLoginSubs.isEmpty()) {
                s = brightLoginSubs[0];
            } 
            
            // If the subscription is NULL, then query by TREND login
            if(s == NULL) {
                List<Subscriptions__c> trendLoginSubs = [SELECT Contact__c  
                                  FROM   Subscriptions__c 
                                  WHERE  TREND_Login_Name__c = :BRIGHT_LoginName 
                                  AND    Status__c = 'Active' LIMIT 1
                                 ];
                
                // Set the non-empty result
                if(!trendLoginSubs.isEmpty()) {
                    s = trendLoginSubs[0];
                }
            }
            
            // If the subscription is still NULL, then query by Subscription ID
            if(s == NULL) {
                // Not a list because we want to keep the existing exception handling
                Subscriptions__c sub = [SELECT Contact__c  
                                  FROM   Subscriptions__c 
                                  WHERE  Name = :BRIGHT_LoginName 
                                  AND    Status__c = 'Active' LIMIT 1
                                 ];
                // Will throw an exception if empty
                // Set the non-empty result
                s = sub;
            }
            
            Contact c = [SELECT Primary_Subscription_ID__c, PrimarySubIDRollup__c 
                         FROM   Contact 
                         WHERE  Id = :s.Contact__c
                        ];
            String str = Utils.decimalToString(c.PrimarySubIDRollup__c );
            
            User u = [Select IsActive, profileid, FederationIdentifier, ContactId 
                      FROM   User  
                      WHERE  FederationIdentifier = :str LIMIT 1
                     ];
            
            userSSODetail.recordFound = 'true';
            userSSODetail.primarySubscriptionID = c.Primary_Subscription_ID__c;
            userSSODetail.primarySubscriptionRoleUpID = str;
            
            if (u.IsActive)
                userSSODetail.isActive = 'true';
            else
                userSSODetail.isActive = 'false';
            
            userSSODetail.isPortalUser = str;
            
            Profile p = [SELECT Name, Id 
                         FROM   Profile 
                         WHERE  Name = 'Custom High Volume Portal User' LIMIT 1
                        ];
            if (p.id == u.profileid) { 
                userSSODetail.isPortalUser = 'true';
                userSSODetail.isSalesforceUser = 'false';
            }
            else{
                userSSODetail.isPortalUser = 'false';
                userSSODetail.isSalesforceUser = 'true';
            }
        } 
        catch (QueryException qex) {
            userSSODetail.message = 'User not found - Subscription';
            userSSODetail.recordFound = 'false';
        }
        return userSSODetail;
    }
}