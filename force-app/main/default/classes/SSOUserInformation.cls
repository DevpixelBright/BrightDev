/**
* @author: klanka@rainamker-llc.com
* @date:  2012-09-06
* This service will return all the account information based on the Acount ID (Office Code) information.  
* If no AccountID (office code) information is found, the salesforce returns a empty return structure 
**/
@RestResource(urlMapping='/GetSSOUserInformation/*')
global with sharing class SSOUserInformation {
	
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
    	UserSSODetails usd = new UserSSODetails();
    	RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String SubscriptionID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('SubscriptionID ' + SubscriptionID);
        try {
        	Subscriptions__c s = [SELECT Contact__c  from Subscriptions__c where name=:SubscriptionID  and status__C = 'Active' LIMIT 1];
        	Contact c = [Select c.Primary_Subscription_ID__c, c.PrimarySubIDRollup__c From Contact c where c.id=:s.Contact__c];
        	String str = Utils.decimalToString(c.PrimarySubIDRollup__c );
        	User u = [Select u.IsActive, u.profileid, u.FederationIdentifier, u.ContactId From User u where u.FederationIdentifier = :str LIMIT 1];
        	usd.recordFound = 'true';
        	usd.primarySubscriptionID = c.Primary_Subscription_ID__c;
        	usd.primarySubscriptionRoleUpID = str;
        	if (u.IsActive) {
        		usd.isActive = 'true';} else {
        			usd.isActive = 'false';}
        	usd.isPortalUser = str;
        	Profile p = [Select p.Name, p.Id From Profile p where name = 'Custom High Volume Portal User' limit 1];
        	if (p.id == u.profileid) { 
	    		usd.isPortalUser = 'true';
	    		usd.isSalesforceUser = 'false';
    		}else{
        		usd.isPortalUser = 'false';
        		usd.isSalesforceUser = 'true';
        	}
        } catch (QueryException qex) {
        	usd.message = 'User not found - Subscription';
        	usd.recordFound = 'false';}
	return usd;}}