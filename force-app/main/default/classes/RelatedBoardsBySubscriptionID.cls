/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the related boards information based on the subscriptionID (AgentKey) information.  
* If no subscriptionID (AgentKey) information is found, the salesforce returns a empty return structure 
**/
@RestResource(urlMapping='/GetRelatedBoardsBySubscriptionID/*')
global with sharing class RelatedBoardsBySubscriptionID {
    
    /**
    *  HTTP Get Method
    *
    **/
    
    @HTTPGet
    global static List<Related_Association__c> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String agentKey = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('agentKey ' + agentKey);
        List <Related_Association__c> ra = [Select r.SystemModstamp, r.Subscription__r.Zip__c, r.Subscription__r.Zip_4__c, 
            r.Subscription__r.Website__c, r.Subscription__r.VM_Ext__c, r.Subscription__r.Unit__c, 
            r.Subscription__r.Unit_Type__c, r.Subscription__r.Subscription_Type__c,
             r.Subscription__r.Street_Type__c, r.Subscription__r.Street_Number__c,
              r.Subscription__r.Street_Number_Suffix__c, r.Subscription__r.Street_Name__c,
               r.Subscription__r.Street_Direction__c, r.Subscription__r.Status__c,
                r.Subscription__r.Status_Change_Reason__c, r.Subscription__r.Status_Change_Fee__c, 
                r.Subscription__r.State__c, 
                r.Subscription__r.SFDC_Application__c, r.Subscription__r.Related_Location_Broker_Office__c, 
                r.Subscription__r.Public_Email__c, r.Subscription__r.PrismSubscriptionID__c, 
                r.Subscription__r.Primary__c, r.Subscription__r.Primary_Phone__c, r.Subscription__r.PrimarySubNum__c, 
                r.Subscription__r.Pager__c, r.Subscription__r.Mobile_Phone__c, r.Subscription__r.License__c, 
                r.Subscription__r.Home_Fax__c, r.Subscription__r.Fax__c, r.Subscription__r.Deleted__c,
                 r.Subscription__r.Date_Terminated__c, r.Subscription__r.Date_Reinstated__c, 
                 r.Subscription__r.Date_Joined__c, r.Subscription__r.Date_Billing_Begins__c, 
                 r.Subscription__r.County__c, r.Subscription__r.Country__c, 
                 r.Subscription__r.Copy_Address_to_Billing__c, r.Subscription__r.Contact_Type__c, 
                 r.Subscription__r.City__c, r.Subscription__r.Box__c, r.Subscription__r.Billing_Zip__c, 
                 r.Subscription__r.Billing_Zip_4__c, r.Subscription__r.Billing_Unit_Type__c, 
                 r.Subscription__r.Billing_Unit_Number__c, r.Subscription__r.Billing_Street_Type__c, 
                 r.Subscription__r.Billing_Street_Suffix__c, r.Subscription__r.Billing_Street_Number__c, 
                 r.Subscription__r.Billing_Street_Name__c, r.Subscription__r.Billing_Street_Direction__c, 
                 r.Subscription__r.Billing_State__c, r.Subscription__r.Billing_County__c, 
                 r.Subscription__r.Billing_Country__c, r.Subscription__r.Billing_City__c, 
                 r.Subscription__r.Billing_Box__c, r.Subscription__r.Billing_Addl_Display_Name__c, 
                 r.Subscription__r.Agent_Office_Phone__c, r.Subscription__r.AgentRealPingID__c, 
                 r.Subscription__r.AgentKey__c, r.Subscription__r.Addl_Display_Name__c, r.Subscription__r.Contact__c, 
                 r.Subscription__r.LastActivityDate, r.Subscription__r.SystemModstamp, r.Subscription__r.LastModifiedById, 
                 r.Subscription__r.LastModifiedDate, r.Subscription__r.CreatedById, r.Subscription__r.CreatedDate, 
                 r.Subscription__r.Name, r.Subscription__r.IsDeleted, r.Subscription__r.Id, r.Subscription__c, 
                 r.PrismRelBoardID__c, r.Primary__c, r.OwnerId, r.Notes__c, r.Name, r.LastModifiedDate, r.LastModifiedById, 
                 r.LastActivityDate, r.IsDeleted, r.Id, r.CreatedDate, r.CreatedById, r.Broker_Code__r.Zip__c, 
                 r.Broker_Code__r.Zip_4__c, r.Broker_Code__r.Unit__c, r.Broker_Code__r.Unit_Type__c, 
                 r.Broker_Code__r.Trading_As__c, r.Broker_Code__r.Street_Type__c, r.Broker_Code__r.Street_Number__c, 
                 r.Broker_Code__r.Street_Number_Suffix__c, r.Broker_Code__r.Street_Name__c, r.Broker_Code__r.Street_Direction__c, 
                 r.Broker_Code__r.Status__c, r.Broker_Code__r.State__c, r.Broker_Code__r.Shareholder_Board__c, 
                 r.Broker_Code__r.PrismCompanyOffice__c, r.Broker_Code__r.PrismCompanyCode__c, r.Broker_Code__r.PrismAddressID__c, 
                 r.Broker_Code__r.PrismAccountID__c, r.Broker_Code__r.PIN__c, r.Broker_Code__r.OfficeKey__c, r.Broker_Code__r.Num_Active_Subs__c, 
                 r.Broker_Code__r.Num_Active_Office_Sec_NC__c, r.Broker_Code__r.Date_Terminated__c, 
                 r.Broker_Code__r.Date_Joined__c, r.Broker_Code__r.County__c, r.Broker_Code__r.Country__c, 
                 r.Broker_Code__r.Copy_Address_to_Billing__c, r.Broker_Code__r.Company_Type__c, r.Broker_Code__r.City__c, 
                 r.Broker_Code__r.Box__c, r.Broker_Code__r.Billing_Zip__c, r.Broker_Code__r.Billing_Zip_4__c, 
                 r.Broker_Code__r.Billing_Unit_Type__c, r.Broker_Code__r.Billing_Unit_Number__c, r.Broker_Code__r.Billing_Street_Type__c,
                  r.Broker_Code__r.Billing_Street_Number__c, r.Broker_Code__r.Billing_Street_Number_Suffix__c,
                   r.Broker_Code__r.Billing_Street_Name__c, r.Broker_Code__r.Billing_Street_Direction__c, 
                   r.Broker_Code__r.Billing_State__c, r.Broker_Code__r.Billing_County__c, r.Broker_Code__r.Billing_Country__c,
                    r.Broker_Code__r.Billing_City__c, r.Broker_Code__r.Billing_Box__c, r.Broker_Code__r.Billing_Addl_Display_Name__c,
                     r.Broker_Code__r.Addl_Display_Name__c, r.Broker_Code__r.Account_Name__c, r.Broker_Code__r.JigsawCompanyId, 
                     r.Broker_Code__r.Jigsaw, r.Broker_Code__r.LastActivityDate, r.Broker_Code__r.SystemModstamp, r.Broker_Code__r.LastModifiedById, 
                     r.Broker_Code__r.LastModifiedDate, r.Broker_Code__r.CreatedById, r.Broker_Code__r.CreatedDate, r.Broker_Code__r.OwnerId, 
                     r.Broker_Code__r.Rating, r.Broker_Code__r.Description, r.Broker_Code__r.Website, r.Broker_Code__r.Fax,
                      r.Broker_Code__r.Phone, r.Broker_Code__r.BillingCountry, r.Broker_Code__r.BillingPostalCode, 
                      r.Broker_Code__r.BillingState, r.Broker_Code__r.BillingCity, r.Broker_Code__r.BillingStreet, 
                      r.Broker_Code__r.ParentId, r.Broker_Code__r.Type, r.Broker_Code__r.Name, r.Broker_Code__r.MasterRecordId, 
                      r.Broker_Code__r.IsDeleted, r.Broker_Code__r.Id, r.Broker_Code__c, r.Association__r.Zip__c, r.Association__r.Zip_4__c, 
                      r.Association__r.Unit__c, r.Association__r.Unit_Type__c, r.Association__r.Trading_As__c, r.Association__r.Street_Type__c, 
                      r.Association__r.Street_Number__c, r.Association__r.Street_Number_Suffix__c, r.Association__r.Street_Name__c, 
                      r.Association__r.Street_Direction__c, r.Association__r.Status__c, r.Association__r.State__c, r.Association__r.Shareholder_Board__c,
                       r.Association__r.PrismCompanyOffice__c, r.Association__r.PrismCompanyCode__c, r.Association__r.PrismAddressID__c, r.Association__r.PrismAccountID__c,
                        r.Association__r.PIN__c, r.Association__r.OfficeKey__c, r.Association__r.Num_Active_Subs__c, r.Association__r.Num_Active_Office_Sec_NC__c, 
                        r.Association__r.Date_Terminated__c, r.Association__r.Date_Joined__c, r.Association__r.County__c, 
                        r.Association__r.Country__c, r.Association__r.Copy_Address_to_Billing__c, r.Association__r.Company_Type__c,
                             r.Association__r.City__c, r.Association__r.Box__c, r.Association__r.Billing_Zip__c, r.Association__r.Billing_Zip_4__c, 
                             r.Association__r.Billing_Unit_Type__c, r.Association__r.Billing_Unit_Number__c, r.Association__r.Billing_Street_Type__c,
                              r.Association__r.Billing_Street_Number__c, r.Association__r.Billing_Street_Number_Suffix__c, 
                              r.Association__r.Billing_Street_Name__c, r.Association__r.Billing_Street_Direction__c, 
                              r.Association__r.Billing_State__c, r.Association__r.Billing_County__c, r.Association__r.Billing_Country__c,
                               r.Association__r.Billing_City__c, r.Association__r.Billing_Box__c, r.Association__r.Billing_Addl_Display_Name__c, 
                               r.Association__r.Addl_Display_Name__c, r.Association__r.Account_Name__c, r.Association__r.JigsawCompanyId, 
                               r.Association__r.Jigsaw, r.Association__r.LastActivityDate, r.Association__r.SystemModstamp,
                                r.Association__r.LastModifiedById, r.Association__r.LastModifiedDate, r.Association__r.CreatedById, 
                                r.Association__r.CreatedDate, r.Association__r.OwnerId, r.Association__r.Rating, r.Association__r.Description,
                                 r.Association__r.Website, r.Association__r.Fax, r.Association__r.Phone, r.Association__r.BillingCountry, 
                                 r.Association__r.BillingPostalCode, r.Association__r.BillingState, r.Association__r.BillingCity,
                                  r.Association__r.BillingStreet, r.Association__r.ParentId, r.Association__r.Type, r.Association__r.Name, 
                                  r.Association__r.MasterRecordId, r.Association__r.IsDeleted, r.Association__r.Id, r.Association__c, r.status__c 
                              From Related_Association__c r where r.Subscription__r.Name = :agentKey];
        
        return ra;
    }
    
    
    static testMethod void testDoGet() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        Account a = new Account();
        a.name = 'ADA1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
         a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.Street_Type__c = '';
        a.Billing_Street_Type__c = 'BLFS';
        a.QAS_Mailing_Street_Type__c ='test';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.Id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.County__c = 'Fairfax';
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
        //s.Name = '123456';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'New';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.Addl_Display_Name__c = 'xyz';
        s.Box__c = NULL;
        s.QAS_Mailing_Country__c = 'USA';
        s.QAS_Mailing_County__c = 'Fairfax';
        s.State__c = 'VA';
        s.QAS_Mailing_Street_Direction__c = 'N';
        s.Street_Name__c = 'First';
        s.Street_Number__c ='1275';
        s.Street_Number_Suffix__c = NULL;
        s.QAS_Mailing_Street_Type__c = 'ST';
        s.Unit__c = '1';
        s.QAS_Mailing_Unit_Type__c = 'SU';
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.Contact_Type__c = 'Broker';
        s.County__c = 'Fairfax';
        s.Contact__c = c.id;
        insert s;
        
        Related_Association__c raa = new Related_Association__c();
        
        raa.Subscription__c = s.id;
        insert raa;
        
        Subscriptions__c subtest = [SELECT name FROM Subscriptions__c WHERE id =: raa.Subscription__c LIMIT 1][0];
        System.debug('sub in related assoc?: ' + subtest);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetRelatedBoardsBySubscriptionID/' + subtest.name;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        List<Related_Association__c> ra = RelatedBoardsBySubscriptionID.doGet();
        
        System.debug('ra: ' + ra);
        
        System.assertEquals(1, ra.size());
      
 
  }

}