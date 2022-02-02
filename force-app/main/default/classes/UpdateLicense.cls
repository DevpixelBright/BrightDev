/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will update license
**/
@RestResource(urlMapping='/UpdateLicense/*')
global with sharing class UpdateLicense {
    
     /**
    *  This method will create the relationships in salesforce
    *
    **/ 
    @HttpPost
    global static License doPost(License lic) {
        
        //Update License  
        System.debug('License --> ' + lic); 
        License__C license = [Select l.SystemModstamp, l.PrismLicenseID__c, l.OwnerId, l.Name, l.License_Type__c, l.License_State__c, 
                    l.License_Expiration_Date__c, 
                        l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.IsDeleted, l.Import_Source__c,
                         l.Import_ID__c, l.Id, l.CreatedDate, l.CreatedById, l.Contact__c From License__c l where l.id=:lic.LicenseID limit 1 ];
        
        
        license.Name = lic.LicenseNumber;
        license.License_State__c = lic.License_State;
        license.License_Expiration_Date__c = Date.valueOf(lic.License_Expiration_Date);
        license.License_Type__c = lic.License_Type;
        upsert license;
        
        if (!(null == lic.SubscriptionLicenseID || ''.equals(lic.SubscriptionLicenseID))) {
            
             Subscription_License__c subLic = [Select s.SystemModstamp, s.Subscription__c, s.Subscription_ID__c, s.PrismRelLicenseID__c, s.OwnerId, s.Notes__c, s.Name, s.License__r.Import_Source__c, s.License__r.Import_ID__c, s.License__r.Contact__c, s.License__r.PrismLicenseID__c, s.License__r.License_Type__c, s.License__r.License_State__c, s.License__r.License_Expiration_Date__c, s.License__r.LastActivityDate, s.License__r.SystemModstamp, s.License__r.LastModifiedById, s.License__r.LastModifiedDate, s.License__r.CreatedById, s.License__r.CreatedDate, s.License__r.Name, s.License__r.IsDeleted, s.License__r.OwnerId, s.License__r.Id, s.License__c,
                                             s.License_Type__c, s.License_State__c, s.License_Expiration_Date__c, s.LastModifiedDate, 
                                             s.LastModifiedById, s.LastActivityDate, s.IsDeleted, s.Import_Source__c, s.Import_ID__c, 
                                             s.Id, s.CreatedDate, s.CreatedById From Subscription_License__c s where s.id = :lic.SubscriptionLicenseID limit 1];
             subLic.License__c = license.id;
             //subLic.Subscription__c = lic.SFSubscriptionID;
             subLic.Notes__c = lic.notes;
             upsert subLic;
            
        }
        
        return lic;
        
    }

}