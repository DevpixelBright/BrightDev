/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return the subscription and contact information based on the license information.  
* If no license information is found, the salesforce returns a empty return structure
**/
@RestResource(urlMapping='/GetSubscriberInformationByLicenseDetails/*')
global with sharing class SubscriberInformationByLicenseDetails {

    /**
    *  HTTP Get Method
    *
    **/ 
    @HTTPGet
    global static List<Subscription_License__c> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('uri ---> ' + req.params);
        
       
        Map <String,String> urlValues = req.params;
        String licenseId;
        String licenseNumber;
        String licenseState;
        String licenseType;
        
            licenseId = urlValues.get('id');
            licenseNumber = urlValues.get('number');
            licenseState = urlValues.get('state');
            licenseType = urlValues.get('type');
      
        Date todayDate = Date.today();
        System.debug('URI ' + RestContext.request.requestURI);
        System.debug('licenseId: ' + licenseId +  ' licenseNumber: ' + licenseNumber + ' licenseState: ' + licenseState + ' licenseType: '+ licenseType);
        List<Subscription_License__c> sRet = new List<Subscription_License__c>();
        if (null == licenseId || 'null'.equals(licenseId) || ''.equals(licenseId)) {
        sRet = [Select s.SystemModstamp,    s.Subscription__r.DATETERMINATED__c, s.Subscription__r.DATELASTMODIFIED__c, s.Subscription__r.DATEESTABLISHED__c, s.Subscription__r.CUSTOMERREFERENCE__c, s.Subscription__r.CUSTOMERPOSTALCODE__c, s.Subscription__r.CUSTOMERNAME__c, s.Subscription__r.CUSTOMERHOMEPHONE__c, s.Subscription__r.CUSTOMERCLASS__c, s.Subscription__r.CUSTOMERCELLPHONE__c, s.Subscription__r.CUSTOMERADDRESSLINE2__c, s.Subscription__r.CUSTOMERADDRESSLINE1__c, s.Subscription__r.CUSTOMERADDRESSID__c, s.Subscription__r.BILLINGCYCLE__c, s.Subscription__r.Import_ID__c, s.Subscription__r.Import_Source__c, s.Subscription__r.Zip__c, s.Subscription__r.Zip_4__c, s.Subscription__r.Website__c, s.Subscription__r.VM_Ext__c, s.Subscription__r.Unit__c, s.Subscription__r.Unit_Type__c, s.Subscription__r.Subscription_Type__c, s.Subscription__r.Street_Type__c, s.Subscription__r.Street_Number__c, s.Subscription__r.Street_Number_Suffix__c, s.Subscription__r.Street_Name__c, s.Subscription__r.Street_Direction__c, s.Subscription__r.Status__c, s.Subscription__r.Status_Change_Reason__c, s.Subscription__r.Status_Change_Fee__c, s.Subscription__r.State__c, s.Subscription__r.SF_Subscription_ID__c, s.Subscription__r.SFDC_Application__c, s.Subscription__r.Related_Location_Broker_Office__c, s.Subscription__r.Public_Email__c, s.Subscription__r.PrismSubscriptionID__c, s.Subscription__r.Primary__c, s.Subscription__r.Primary_Phone__c, s.Subscription__r.PrimarySubNum__c, s.Subscription__r.Pager__c, s.Subscription__r.Mobile_Phone__c, s.Subscription__r.License__c, s.Subscription__r.Home_Fax__c, s.Subscription__r.Fax__c, s.Subscription__r.Deleted__c, s.Subscription__r.Date_Terminated__c, s.Subscription__r.Date_Reinstated__c, s.Subscription__r.Date_Joined__c, s.Subscription__r.Date_Billing_Begins__c, s.Subscription__r.County__c, s.Subscription__r.Country__c, s.Subscription__r.Copy_Address_to_Billing__c, s.Subscription__r.Contact_Type__c, s.Subscription__r.City__c, s.Subscription__r.Box__c, s.Subscription__r.Billing_Zip__c, s.Subscription__r.Billing_Zip_4__c, s.Subscription__r.Billing_Unit_Type__c, s.Subscription__r.Billing_Unit_Number__c, s.Subscription__r.Billing_Street_Type__c, s.Subscription__r.Billing_Street_Suffix__c, s.Subscription__r.Billing_Street_Number__c, s.Subscription__r.Billing_Street_Name__c, s.Subscription__r.Billing_Street_Direction__c, s.Subscription__r.Billing_State__c, s.Subscription__r.Billing_County__c, s.Subscription__r.Billing_Country__c, s.Subscription__r.Billing_City__c, s.Subscription__r.Billing_Box__c, s.Subscription__r.Billing_Addl_Display_Name__c, s.Subscription__r.Agent_Office_Phone__c, s.Subscription__r.AgentRealPingID__c, s.Subscription__r.AgentKey__c, s.Subscription__r.Addl_Display_Name__c, s.Subscription__r.Contact__c,   s.Subscription__r.LastActivityDate, s.Subscription__r.SystemModstamp, s.Subscription__r.LastModifiedById, s.Subscription__r.LastModifiedDate, s.Subscription__r.CreatedById, s.Subscription__r.CreatedDate, s.Subscription__r.Name, s.Subscription__r.IsDeleted, s.Subscription__r.Id, s.Subscription__c, s.PrismRelLicenseID__c, s.OwnerId, s.Notes__c, s.Name, s.License__r.Import_ID__c, s.License__r.Import_Source__c, s.License__r.PrismLicenseID__c, s.License__r.License_Type__c, s.License__r.License_State__c, s.License__r.License_Expiration_Date__c, s.License__r.Contact__c,   s.License__r.LastActivityDate, s.License__r.SystemModstamp, s.License__r.LastModifiedById, s.License__r.LastModifiedDate, s.License__r.CreatedById, s.License__r.CreatedDate, s.License__r.Name, s.License__r.IsDeleted, s.License__r.OwnerId, s.License__r.Id, s.License__c, s.LastModifiedDate, s.LastModifiedById, s.LastActivityDate, s.IsDeleted, s.Import_Source__c, 
                s.Import_ID__c, s.Id, s.CreatedDate, s.CreatedById From Subscription_License__c s 
                 where   s.License__r.Upper_License__c=:licenseNumber and s.License__r.License_Type__c  = :licenseType 
                    and s.License__r.License_State__c=:licenseState 
                    and (s.License__r.License_Expiration_Date__c >= :todayDate or  s.License__r.License_Expiration_Date__c < :todayDate)];
        } else {
            sRet = [Select s.SystemModstamp,   s.Subscription__r.DATETERMINATED__c, s.Subscription__r.DATELASTMODIFIED__c, s.Subscription__r.DATEESTABLISHED__c, s.Subscription__r.CUSTOMERREFERENCE__c, s.Subscription__r.CUSTOMERPOSTALCODE__c, s.Subscription__r.CUSTOMERNAME__c, s.Subscription__r.CUSTOMERHOMEPHONE__c, s.Subscription__r.CUSTOMERCLASS__c, s.Subscription__r.CUSTOMERCELLPHONE__c, s.Subscription__r.CUSTOMERADDRESSLINE2__c, s.Subscription__r.CUSTOMERADDRESSLINE1__c, s.Subscription__r.CUSTOMERADDRESSID__c, s.Subscription__r.BILLINGCYCLE__c, s.Subscription__r.Import_ID__c, s.Subscription__r.Import_Source__c, s.Subscription__r.Zip__c, s.Subscription__r.Zip_4__c, s.Subscription__r.Website__c, s.Subscription__r.VM_Ext__c, s.Subscription__r.Unit__c, s.Subscription__r.Unit_Type__c, s.Subscription__r.Subscription_Type__c, s.Subscription__r.Street_Type__c, s.Subscription__r.Street_Number__c, s.Subscription__r.Street_Number_Suffix__c, s.Subscription__r.Street_Name__c, s.Subscription__r.Street_Direction__c, s.Subscription__r.Status__c, s.Subscription__r.Status_Change_Reason__c, s.Subscription__r.Status_Change_Fee__c, s.Subscription__r.State__c, s.Subscription__r.SF_Subscription_ID__c, s.Subscription__r.SFDC_Application__c, s.Subscription__r.Related_Location_Broker_Office__c, s.Subscription__r.Public_Email__c, s.Subscription__r.PrismSubscriptionID__c, s.Subscription__r.Primary__c, s.Subscription__r.Primary_Phone__c, s.Subscription__r.PrimarySubNum__c, s.Subscription__r.Pager__c, s.Subscription__r.Mobile_Phone__c, s.Subscription__r.License__c, s.Subscription__r.Home_Fax__c, s.Subscription__r.Fax__c, s.Subscription__r.Deleted__c, s.Subscription__r.Date_Terminated__c, s.Subscription__r.Date_Reinstated__c, s.Subscription__r.Date_Joined__c, s.Subscription__r.Date_Billing_Begins__c, s.Subscription__r.County__c, s.Subscription__r.Country__c, s.Subscription__r.Copy_Address_to_Billing__c, s.Subscription__r.Contact_Type__c, s.Subscription__r.City__c, s.Subscription__r.Box__c, s.Subscription__r.Billing_Zip__c, s.Subscription__r.Billing_Zip_4__c, s.Subscription__r.Billing_Unit_Type__c, s.Subscription__r.Billing_Unit_Number__c, s.Subscription__r.Billing_Street_Type__c, s.Subscription__r.Billing_Street_Suffix__c, s.Subscription__r.Billing_Street_Number__c, s.Subscription__r.Billing_Street_Name__c, s.Subscription__r.Billing_Street_Direction__c, s.Subscription__r.Billing_State__c, s.Subscription__r.Billing_County__c, s.Subscription__r.Billing_Country__c, s.Subscription__r.Billing_City__c, s.Subscription__r.Billing_Box__c, s.Subscription__r.Billing_Addl_Display_Name__c, s.Subscription__r.Agent_Office_Phone__c, s.Subscription__r.AgentRealPingID__c, s.Subscription__r.AgentKey__c, s.Subscription__r.Addl_Display_Name__c, s.Subscription__r.Contact__c,   s.Subscription__r.LastActivityDate, s.Subscription__r.SystemModstamp, s.Subscription__r.LastModifiedById, s.Subscription__r.LastModifiedDate, s.Subscription__r.CreatedById, s.Subscription__r.CreatedDate, s.Subscription__r.Name, s.Subscription__r.IsDeleted, s.Subscription__r.Id, s.Subscription__c, s.PrismRelLicenseID__c, s.OwnerId, s.Notes__c, s.Name, s.License__r.Import_ID__c, s.License__r.Import_Source__c, s.License__r.PrismLicenseID__c, s.License__r.License_Type__c, s.License__r.License_State__c, s.License__r.License_Expiration_Date__c, s.License__r.Contact__c,   s.License__r.LastActivityDate, s.License__r.SystemModstamp, s.License__r.LastModifiedById, s.License__r.LastModifiedDate, s.License__r.CreatedById, s.License__r.CreatedDate, s.License__r.Name, s.License__r.IsDeleted, s.License__r.OwnerId, s.License__r.Id, s.License__c, s.LastModifiedDate, s.LastModifiedById, s.LastActivityDate, s.IsDeleted, s.Import_Source__c, 
                s.Import_ID__c, s.Id, s.CreatedDate, s.CreatedById
                 From Subscription_License__c s 
                 where   s.License__r.id=:licenseId];
        } 
         
        return sRet;
    }
}