/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the Related Agent information based on the subscriptionID (AgentKey) information.  
* If no subscriptionID (AgentKey) information is found,  salesforce returns an empty return structure 
**/
@RestResource(urlMapping='/GetRelatedAgentBySubscriptionID/*')
global with sharing class RelatedAgentBySubscriptionID {

    /**
    *  HTTP Get Method
    *
    **/
    @HTTPGet
    global static List<Related_Agent__c> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String agentKey = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('agentKey ' + agentKey);
        List <Related_Agent__c> ra = [Select r.SystemModstamp, r.Subscription__r.Zip__c, r.Subscription__r.Zip_4__c, r.Subscription__r.Website__c, r.Subscription__r.VM_Ext__c, r.Subscription__r.Unit__c, r.Subscription__r.Unit_Type__c, r.Subscription__r.Subscription_Type__c, 
r.Subscription__r.Street_Type__c, r.Subscription__r.Street_Number__c, r.Subscription__r.Street_Number_Suffix__c, r.Subscription__r.Street_Name__c, r.Subscription__r.Street_Direction__c, r.Subscription__r.Status__c, 
r.Subscription__r.Status_Change_Reason__c, r.Subscription__r.Status_Change_Fee__c, r.Subscription__r.State__c, r.Subscription__r.SFDC_Application__c, r.Subscription__r.Related_Location_Broker_Office__c, 
r.Subscription__r.Public_Email__c, r.Subscription__r.PrismSubscriptionID__c, r.Subscription__r.Primary__c, r.Subscription__r.Primary_Phone__c, r.Subscription__r.PrimarySubNum__c, r.Subscription__r.Pager__c, r.Subscription__r.Mobile_Phone__c, 
r.Subscription__r.License__c, r.Subscription__r.Home_Fax__c, r.Subscription__r.Fax__c, r.Subscription__r.Deleted__c, r.Subscription__r.Date_Terminated__c, r.Subscription__r.Date_Reinstated__c, r.Subscription__r.Date_Joined__c, 
r.Subscription__r.Date_Billing_Begins__c, r.Subscription__r.County__c, r.Subscription__r.Country__c, r.Subscription__r.Copy_Address_to_Billing__c, r.Subscription__r.Contact_Type__c, r.Subscription__r.City__c, r.Subscription__r.Box__c, 
r.Subscription__r.Billing_Zip__c, r.Subscription__r.Billing_Zip_4__c, r.Subscription__r.Billing_Unit_Type__c, r.Subscription__r.Billing_Unit_Number__c, r.Subscription__r.Billing_Street_Type__c, r.Subscription__r.Billing_Street_Suffix__c, 
r.Subscription__r.Billing_Street_Number__c, r.Subscription__r.Billing_Street_Name__c, r.Subscription__r.Billing_Street_Direction__c, r.Subscription__r.Billing_State__c, r.Subscription__r.Billing_County__c, r.Subscription__r.Billing_Country__c, 
r.Subscription__r.Billing_City__c, r.Subscription__r.Billing_Box__c, r.Subscription__r.Billing_Addl_Display_Name__c, r.Subscription__r.Agent_Office_Phone__c, r.Subscription__r.AgentRealPingID__c, r.Subscription__r.AgentKey__c, 
r.Subscription__r.Addl_Display_Name__c, r.Subscription__r.Contact__c, r.Subscription__r.LastActivityDate, r.Subscription__r.SystemModstamp, r.Subscription__r.LastModifiedById, r.Subscription__r.LastModifiedDate, r.Subscription__r.CreatedById, 
r.Subscription__r.CreatedDate, r.Subscription__r.Name, r.Subscription__r.IsDeleted, r.Subscription__r.Id, r.Subscription__c, r.Subscription_Type__c, r.PrismRelatedAgentID__c, r.Personal_Assistant__c, r.Personal_Assistant_Sub_ID__r.Zip__c, 
r.Personal_Assistant_Sub_ID__r.Zip_4__c, r.Personal_Assistant_Sub_ID__r.Website__c, r.Personal_Assistant_Sub_ID__r.VM_Ext__c, r.Personal_Assistant_Sub_ID__r.Unit__c, r.Personal_Assistant_Sub_ID__r.Unit_Type__c, 
r.Personal_Assistant_Sub_ID__r.Subscription_Type__c, r.Personal_Assistant_Sub_ID__r.Street_Type__c, r.Personal_Assistant_Sub_ID__r.Street_Number__c, r.Personal_Assistant_Sub_ID__r.Street_Number_Suffix__c, 
r.Personal_Assistant_Sub_ID__r.Street_Name__c, r.Personal_Assistant_Sub_ID__r.Street_Direction__c, r.Personal_Assistant_Sub_ID__r.Status__c, r.Personal_Assistant_Sub_ID__r.Status_Change_Reason__c, 
r.Personal_Assistant_Sub_ID__r.Status_Change_Fee__c, r.Personal_Assistant_Sub_ID__r.State__c,  r.Personal_Assistant_Sub_ID__r.SFDC_Application__c, 
r.Personal_Assistant_Sub_ID__r.Related_Location_Broker_Office__c, r.Personal_Assistant_Sub_ID__r.Public_Email__c, r.Personal_Assistant_Sub_ID__r.PrismSubscriptionID__c, r.Personal_Assistant_Sub_ID__r.Primary__c, 
r.Personal_Assistant_Sub_ID__r.Primary_Phone__c, r.Personal_Assistant_Sub_ID__r.PrimarySubNum__c, r.Personal_Assistant_Sub_ID__r.Pager__c, r.Personal_Assistant_Sub_ID__r.Mobile_Phone__c, r.Personal_Assistant_Sub_ID__r.License__c, 
r.Personal_Assistant_Sub_ID__r.Home_Fax__c, r.Personal_Assistant_Sub_ID__r.Fax__c, r.Personal_Assistant_Sub_ID__r.Deleted__c, r.Personal_Assistant_Sub_ID__r.Date_Terminated__c, r.Personal_Assistant_Sub_ID__r.Date_Reinstated__c, 
r.Personal_Assistant_Sub_ID__r.Date_Joined__c, r.Personal_Assistant_Sub_ID__r.Date_Billing_Begins__c, r.Personal_Assistant_Sub_ID__r.County__c, r.Personal_Assistant_Sub_ID__r.Country__c, 
r.Personal_Assistant_Sub_ID__r.Copy_Address_to_Billing__c, r.Personal_Assistant_Sub_ID__r.Contact_Type__c, r.Personal_Assistant_Sub_ID__r.City__c, r.Personal_Assistant_Sub_ID__r.Box__c, r.Personal_Assistant_Sub_ID__r.Billing_Zip__c, 
r.Personal_Assistant_Sub_ID__r.Billing_Zip_4__c, r.Personal_Assistant_Sub_ID__r.Billing_Unit_Type__c, r.Personal_Assistant_Sub_ID__r.Billing_Unit_Number__c, r.Personal_Assistant_Sub_ID__r.Billing_Street_Type__c, 
r.Personal_Assistant_Sub_ID__r.Billing_Street_Suffix__c, r.Personal_Assistant_Sub_ID__r.Billing_Street_Number__c, r.Personal_Assistant_Sub_ID__r.Billing_Street_Name__c, r.Personal_Assistant_Sub_ID__r.Billing_Street_Direction__c, 
r.Personal_Assistant_Sub_ID__r.Billing_State__c, r.Personal_Assistant_Sub_ID__r.Billing_County__c, r.Personal_Assistant_Sub_ID__r.Billing_Country__c, r.Personal_Assistant_Sub_ID__r.Billing_City__c, r.Personal_Assistant_Sub_ID__r.Billing_Box__c, 
r.Personal_Assistant_Sub_ID__r.Billing_Addl_Display_Name__c, r.Personal_Assistant_Sub_ID__r.Agent_Office_Phone__c, r.Personal_Assistant_Sub_ID__r.AgentRealPingID__c, r.Personal_Assistant_Sub_ID__r.AgentKey__c, 
r.Personal_Assistant_Sub_ID__r.Addl_Display_Name__c, r.Personal_Assistant_Sub_ID__r.Contact__c, r.Personal_Assistant_Sub_ID__r.LastActivityDate, r.Personal_Assistant_Sub_ID__r.SystemModstamp, r.Personal_Assistant_Sub_ID__r.LastModifiedById, 
r.Personal_Assistant_Sub_ID__r.LastModifiedDate, r.Personal_Assistant_Sub_ID__r.CreatedById, r.Personal_Assistant_Sub_ID__r.CreatedDate, r.Personal_Assistant_Sub_ID__r.Name, r.Personal_Assistant_Sub_ID__r.IsDeleted, 
r.Personal_Assistant_Sub_ID__r.Id, r.Personal_Assistant_Sub_ID__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, r.LastModifiedById, r.LastActivityDate, r.IsDeleted, r.Id, r.CreatedDate, r.CreatedById, r.Contact__c, r.Assistant_to__c From Related_Agent__c r where r.Subscription__r.Name=:agentKey];

    return ra;
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
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        insert s;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetRelatedAgentBySubscriptionID/123456';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        List<Related_Agent__c> ra = RelatedAgentBySubscriptionID.doGet();
        
        
        System.assertEquals(0, ra.size());
      
 
  }
}