/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will return all the subscription and contact information based on the Contact ID information. 
* If no contactID information is found, the salesforce returns a empty return structure 
**/
@RestResource(urlMapping='/GetContactAndSubscriberDetailsByContactID/*')
global with sharing class ContactAndSubscriberDetailsByContactID {

    /**
    *  HTTP Get Method
    *
    **/
    @HTTPGet
    global static List<Contact> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('ContactID ' + contactID);
        
        List<Contact> cList = [Select c.Zip__c, c.Zip_4__c, c.Website__c, c.Voicemail__c, c.VM_Ext__c, c.VIP__c, 
        c.Unit__c, c.Unit_Type__c, c.Title, c.TaleoContactID__c, c.SystemModstamp, c.Suffix__c, c.Street_Type__c, 
        c.Street_Number__c, c.Street_Number_Suffix__c, c.Street_Name__c, c.Street_Direction__c, c.Status__c, c.State__c,
         c.Salutation, c.ReportsToId, c.Public_Email__c, c.Professional_Designations__c, c.PrismContactID__c, 
         c.PrismAddressID__c, c.PrismAccountID__c, c.Primary_Subscription_ID__c, c.Primary_Contact__c, 
         c.PrimarySubIDRollup__c, c.Phone, c.PIN__c, c.OwnerId, c.OtherPhone, c.Nickname__c, c.Name, c.NRDS_ID__c, 
         c.MobilePhone, c.Middle_Name__c, c.MasterRecordId, c.LeadSource, c.LastName, c.LastModifiedDate, 
         c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.JigsawContactId, 
         c.Jigsaw, c.IsDeleted, c.Id, c.Home_Fax__c, c.FirstName, c.Fax, c.Extension__c, c.EmailBouncedReason, 
         c.EmailBouncedDate, c.Email, c.Disabilities__c, c.Description, c.Department, c.Date_Terminated__c, 
         c.Date_Joined__c, c.Date_Billing_Begins__c, c.CreatedDate, c.CreatedById, c.County__c, c.Country__c, 
         c.Copy_Address_to_Billing__c, c.City__c, c.Categories__c, c.Box__c, c.Billing_Zip__c, c.Billing_Zip_4__c, 
         c.Billing_Unit_Type__c, c.Billing_Unit_Number__c, c.Billing_Street_Type__c, c.Billing_Street_Number__c, 
         c.Billing_Street_Number_Suffix__c, c.Billing_Street_Name__c, c.Billing_Street_Direction__c, 
         c.Billing_State__c, c.Billing_County__c, c.Billing_Country__c, c.Billing_City__c, c.Billing_Box__c, 
         c.Billing_Addl_Display_Name__c, c.Agent_Office_Phone__c, c.Addl_Display_Name__c, c.AccountId, 
         (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
         LastActivityDate, Contact__c, Addl_Display_Name__c, AgentKey__c, AgentRealPingID__c, Agent_Office_Phone__c, 
         Billing_Addl_Display_Name__c, Billing_Box__c, Billing_City__c, Billing_Country__c, Billing_County__c, 
         Billing_State__c, Billing_Street_Direction__c, Billing_Street_Name__c, Billing_Street_Number__c, 
         Billing_Street_Suffix__c, Billing_Street_Type__c, Billing_Unit_Number__c, Billing_Unit_Type__c, 
         Billing_Zip_4__c, Billing_Zip__c, Box__c, City__c, Contact_Type__c, Copy_Address_to_Billing__c, Country__c,
          County__c, Date_Billing_Begins__c, Date_Joined__c, Date_Reinstated__c, Date_Terminated__c, Deleted__c, Fax__c,
           Home_Fax__c, License__c, Mobile_Phone__c, Pager__c, PrimarySubNum__c, Primary_Phone__c, Primary__c, 
           PrismSubscriptionID__c, Public_Email__c, Related_Location_Broker_Office__c, SFDC_Application__c, 
            State__c, Status_Change_Fee__c, Status_Change_Reason__c, Status__c, 
           Street_Direction__c, Street_Name__c, Street_Number_Suffix__c, Street_Number__c, 
        Street_Type__c, Subscription_Type__c, Unit_Type__c, Unit__c, VM_Ext__c, Website__c, Zip_4__c, Zip__c 
            From Subscriptions__r) From Contact c where c.id=:contactID];
        
        
        return cList;
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
        a.QAS_Mailing_County__c = 'Fairfax';
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
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetContactAndSubscriberDetailsByContactID/123456';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        List<Contact> ra = ContactAndSubscriberDetailsByContactID.doGet();
        
        
        System.assertEquals(0, ra.size());
      
 
  }
}