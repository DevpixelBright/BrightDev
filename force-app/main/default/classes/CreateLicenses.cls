/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will create Relationship
**/
@RestResource(urlMapping='/CreateLicense/*')
global with sharing class CreateLicenses {
	
	 /**
    *  This method will create the relationships in salesforce
    *
    **/ 
    @HttpPost
    global static License doPost(License lic) {
    	
    	//Create License  
    	System.debug('License --> ' + lic); 
    	License__c license = new License__c();
    	license.Name = lic.LicenseNumber;
    	license.License_State__c = lic.License_State;
    	license.License_Expiration_Date__c = Date.valueOf(lic.License_Expiration_Date);
    	license.License_Type__c = lic.License_Type;
    	insert license;
    	lic.LicenseID = license.id;
    	if (!(null == lic.SFSubscriptionID || ''.equals(lic.SFSubscriptionID))) {
    		 Subscription_License__c subLic = new Subscription_License__c();
    		 subLic.License__c = license.id;
    		 subLic.Subscription__c = lic.SFSubscriptionID;
    		 subLic.Notes__c = lic.notes;
    		 insert subLic;
    		 lic.SubscriptionLicenseID = subLic.id;
    	}
    	
    	return lic;
    	
    }

}