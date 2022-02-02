/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the subscription and contact information based on the subscriptionID  (AgentKey)
* information.  If no subscriptionID (AgentKey) information is found, the salesforce returns a empty return structure 
**/
@RestResource(urlMapping='/GetSubscriberDetailsBySubscriptionID/*')
global with sharing class SubscriberDetailsBySubscriptionID {
    
    global class SubscriberDetailsBySubscription {
        global Integer totalSize;
        global List<Subscriptions__c> subscriptionDetails;
        global List<Subscription_License__c> licenseDetails;
        
    }
    
    /**
    *  HTTP Get Method
    *
    **/
    
    @HTTPGet 
    global static List<Subscriptions__c> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String agentKey = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('agentKey ' + agentKey);
        List <Subscriptions__c> sc = [Select s.Zip__c, s.Zip_4__c, s.Website__c, s.VM_Ext__c, s.Unit__c, 
                                        s.Unit_Type__c, s.NRDS_ID__c, s.SystemModstamp, s.Subscription_Type__c, 
                                        s.Street_Type__c, s.Street_Number__c, s.Street_Number_Suffix__c, 
                                        s.Street_Name__c, s.Street_Direction__c, s.Status__c, s.Status_Change_Reason__c, 
                                        s.Status_Change_Fee__c, s.State__c, s.SFDC_Application__c, 
                                        s.Related_Location_Broker_Office__c, s.Public_Email__c, s.PrismSubscriptionID__c, 
                                        s.Primary__c, s.Primary_Phone__c, s.PrimarySubNum__c, s.Pager__c, s.Name, 
                                        s.Mobile_Phone__c, s.Private_Email__c,s.License__c, s.LastModifiedDate, s.LastModifiedById, 
                                        s.LastActivityDate, s.IsDeleted, s.Id, s.Home_Fax__c, s.Fax__c, s.Deleted__c, 
                                        s.Date_Terminated__c, s.Date_Reinstated__c, s.Date_Joined__c, s.Date_Billing_Begins__c, 
                                        s.CreatedDate, s.CreatedById, s.County__c, s.Country__c, s.Copy_Address_to_Billing__c, 
                                        s.Contact__r.PrimarySubIDRollup__c, s.Contact__r.Date_Terminated__c, s.Contact__r.Date_Joined__c, 
                                        s.Contact__r.Date_Billing_Begins__c, s.Contact__r.Zip__c, s.Contact__r.Zip_4__c, s.Contact__r.Website__c, 
                                        s.Contact__r.Voicemail__c, s.Contact__r.VM_Ext__c, s.Contact__r.VIP__c, s.Contact__r.Unit__c, 
                                        s.Contact__r.Unit_Type__c, s.Contact__r.TaleoContactID__c, s.Contact__r.Suffix__c, s.Contact__r.Street_Type__c, 
                                        s.Contact__r.Street_Number__c, s.Contact__r.Street_Number_Suffix__c, s.Contact__r.Street_Name__c, 
                                        s.Contact__r.Street_Direction__c, s.Contact__r.Status__c, s.Contact__r.State__c, s.Contact__r.Public_Email__c,
                                        s.Contact__r.Professional_Designations__c, s.Contact__r.PrismContactID__c, s.Contact__r.PrismAddressID__c, 
                                        s.Contact__r.PrismAccountID__c, s.Contact__r.Primary_Subscription_ID__c, s.Contact__r.Primary_Contact__c, 
                                        s.Contact__r.PIN__c, s.Contact__r.Nickname__c, s.Contact__r.NRDS_ID__c, s.Contact__r.Middle_Name__c, 
                                        s.Contact__r.Home_Fax__c, s.Contact__r.Extension__c, s.Contact__r.Disabilities__c, s.Contact__r.County__c,
                                        s.Contact__r.Country__c, s.Contact__r.Copy_Address_to_Billing__c, s.Contact__r.City__c, 
                                        s.Contact__r.Categories__c, s.Contact__r.Box__c, s.Contact__r.Billing_Zip__c, s.Contact__r.Billing_Zip_4__c,
                                        s.Contact__r.Billing_Unit_Type__c, s.Contact__r.Billing_Unit_Number__c, s.Contact__r.Billing_Street_Type__c,
                                        s.Contact__r.Billing_Street_Number__c, s.Contact__r.Billing_Street_Number_Suffix__c, 
                                        s.Contact__r.Billing_Street_Name__c, s.Contact__r.Billing_Street_Direction__c, s.Contact__r.Billing_State__c,
                                        s.Contact__r.Billing_County__c, s.Contact__r.Billing_Country__c, s.Contact__r.Billing_City__c, 
                                        s.Contact__r.Billing_Box__c, s.Contact__r.Billing_Addl_Display_Name__c, s.Contact__r.Agent_Office_Phone__c, 
                                        s.Contact__r.Addl_Display_Name__c, s.Contact__r.JigsawContactId, s.Contact__r.Jigsaw, s.Contact__r.EmailBouncedDate, 
                                        s.Contact__r.EmailBouncedReason, s.Contact__r.LastCUUpdateDate, s.Contact__r.LastCURequestDate, s.Contact__r.LastActivityDate, 
                                        s.Contact__r.SystemModstamp, s.Contact__r.LastModifiedById, s.Contact__r.LastModifiedDate, s.Contact__r.CreatedById, 
                                        s.Contact__r.CreatedDate, s.Contact__r.OwnerId, s.Contact__r.Description, s.Contact__r.LeadSource, s.Contact__r.Department, 
                                        s.Contact__r.Title, s.Contact__r.Email, s.Contact__r.ReportsToId, s.Contact__r.OtherPhone, s.Contact__r.MobilePhone, 
                                        s.Contact__r.Fax, s.Contact__r.Phone, s.Contact__r.Name, s.Contact__r.Salutation, s.Contact__r.FirstName, s.Contact__r.LastName, 
                                        s.Contact__r.AccountId, s.Contact__r.MasterRecordId, s.Contact__r.IsDeleted, s.Contact__r.Id, s.Contact__c, s.Contact_Type__c,
                                        s.City__c, s.Box__c, s.Billing_Zip__c, s.Billing_Zip_4__c, s.Billing_Unit_Type__c, s.Billing_Unit_Number__c, s.Billing_Street_Type__c, 
                                        s.Billing_Street_Suffix__c, s.Billing_Street_Number__c, s.Billing_Street_Name__c, s.Billing_Street_Direction__c, 
                                        s.Billing_State__c, s.Billing_County__c, s.Billing_Country__c, s.Billing_City__c, s.Billing_Box__c, 
                                        s.Billing_Addl_Display_Name__c, s.Agent_Office_Phone__c, s.AgentRealPingID__c, s.AgentKey__c, 
                                        s.Addl_Display_Name__c,(Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,
                                         LastModifiedById, SystemModstamp, LastActivityDate, License__c, Notes__c, 
                                        PrismRelLicenseID__c, Subscription__c, Import_ID__c, Import_Source__c, License_State__c, 
                                        License_Expiration_Date__c, License_Type__c,License_Name__c, Subscription_ID__c From Subscription_Licenses__r) From Subscriptions__c s where s.Name = :agentKey];
        
        return sc;
    }
    static testMethod void testDoGet() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.Zip__c = '20171';
        a.County__c = 'Fairfax';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.QAS_Mailing_County__c = 'Arlington'; 
        c.Zip__c = '20171';
        
        insert c;
       
       License__c l = new License__c();
        l.Name = '123456';
        l.License_Expiration_Date__c = Date.today();
        l.License_State__c = 'VA';
        l.License_Type__c = 'Broker';
        //l.IsDeleted = false;
        l.Contact__c = c.id;
        insert l;
        
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'New';
       // s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '1234';
        s.Name = '1234';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES'; 
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        insert s;
        
        Subscription_License__c sl = new Subscription_License__c();
        sl.Subscription__c = s.id;
        sl.License__c = l.id;
        insert sl;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs9.salesforce.com/services/apexrest/GetSubscriberDetailsBySubscriptionID/1234';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
       SubscriberDetailsBySubscriptionID.doGet();
        
        
       // System.assertEquals(1, subResult.totalSize);
      
        
        
    }
}