/*******************************************************************************************************************
** Module Name   : AccountAndContactDetailsByContactID
** Description   : HTTPGET RestFull Service that gets the Account and contact details based on the Contact ID
** Throws        : N/A
** Calls         : N/A
** Test Class    : AccountAndContactDetailsByContactID
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date          Author    WO#         Description of Action
** 1.0      2012-10-15     RMA       MRIS            Initial Version
*******************************************************************************************************************/
@RestResource(urlMapping='/GetAccountAndContactDetailsByContactID/*')
global with sharing class AccountAndContactDetailsByContactID {
    
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
        
        List<Contact> cList = [Select c.Zip__c, c.Zip_4__c, c.Website__c, c.Voicemail__c, c.VM_Ext__c, 
        c.VIP__c, c.Unit__c, c.Unit_Type__c, c.Title, c.TaleoContactID__c, c.SystemModstamp, c.Suffix__c, 
        c.Street_Type__c, c.Street_Number__c, c.Street_Number_Suffix__c, c.Street_Name__c, c.Street_Direction__c,
         c.Status__c, c.State__c, c.Salutation, c.ReportsToId, c.Public_Email__c, c.Professional_Designations__c,
          c.PrismContactID__c, c.PrismAddressID__c, c.PrismAccountID__c, c.Primary_Subscription_ID__c, c.Primary_Contact__c,
           c.PrimarySubIDRollup__c, c.Phone, c.PIN__c, c.OwnerId, c.OtherPhone, c.Nickname__c, c.Name,
            c.NRDS_ID__c, c.MobilePhone, c.Middle_Name__c, c.MasterRecordId, c.LeadSource, c.LastName, 
            c.LastModifiedDate, c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, 
            c.JigsawContactId, c.Jigsaw, c.IsDeleted, c.Id, c.Home_Fax__c, c.FirstName, c.Fax, c.Extension__c, c.EmailBouncedReason,
             c.EmailBouncedDate, c.Email, c.Disabilities__c, c.Description, c.Department, c.Date_Terminated__c, c.Date_Joined__c,
              c.Date_Billing_Begins__c, c.CreatedDate, c.CreatedById, c.County__c, c.Country__c, c.Copy_Address_to_Billing__c, 
              c.City__c, c.Categories__c, c.Box__c, c.Billing_Zip__c, c.Billing_Zip_4__c, c.Billing_Unit_Type__c, c.Billing_Unit_Number__c,
               c.Billing_Street_Type__c, c.Billing_Street_Number__c, c.Billing_Street_Number_Suffix__c, c.Billing_Street_Name__c, c.Billing_Street_Direction__c,
                c.Billing_State__c, c.Billing_County__c, c.Billing_Country__c, c.Billing_City__c, c.Billing_Box__c, c.Billing_Addl_Display_Name__c, c.Agent_Office_Phone__c, 
                c.Addl_Display_Name__c, c.Account.Zip__c, c.Account.Zip_4__c, c.Account.Unit__c, c.Account.Unit_Type__c, c.Account.Trading_As__c, c.Account.Street_Type__c, c.Account.Street_Number__c, 
                c.Account.Street_Number_Suffix__c, c.Account.Street_Name__c, c.Account.Street_Direction__c, c.Account.Status__c, c.Account.State__c,
                 c.Account.Shareholder_Board__c, c.Account.PrismCompanyOffice__c, c.Account.PrismCompanyCode__c, c.Account.PrismAddressID__c, 
                 c.Account.PrismAccountID__c, c.Account.PIN__c, c.Account.OfficeKey__c, c.Account.Num_Active_Subs__c, c.Account.Num_Active_Office_Sec_NC__c, 
                 c.Account.Date_Terminated__c, c.Account.Date_Joined__c, c.Account.County__c, c.Account.Country__c, c.Account.Copy_Address_to_Billing__c, 
                 c.Account.Company_Type__c, c.Account.City__c, c.Account.Box__c, c.Account.Billing_Zip__c, c.Account.Billing_Zip_4__c, c.Account.Billing_Unit_Type__c, 
                 c.Account.Billing_Unit_Number__c, c.Account.Billing_Street_Type__c, c.Account.Billing_Street_Number__c, c.Account.Billing_Street_Number_Suffix__c, c.Account.Billing_Street_Name__c, 
                 c.Account.Billing_Street_Direction__c, c.Account.Billing_State__c, c.Account.Billing_County__c, c.Account.Billing_Country__c, c.Account.Billing_City__c, c.Account.Billing_Box__c, 
                 c.Account.Billing_Addl_Display_Name__c, c.Account.Addl_Display_Name__c, c.Account.Account_Name__c, c.Account.JigsawCompanyId, c.Account.Jigsaw, 
                 c.Account.IsCustomerPortal, c.Account.LastActivityDate, c.Account.SystemModstamp, c.Account.LastModifiedById, c.Account.LastModifiedDate,
                  c.Account.CreatedById, c.Account.CreatedDate, c.Account.OwnerId, c.Account.Rating, c.Account.Description, c.Account.Website, 
                  c.Account.Fax, c.Account.Phone, c.Account.BillingCountry, c.Account.BillingPostalCode, c.Account.BillingState, 
                  c.Account.BillingCity, c.Account.BillingStreet, c.Account.ParentId, c.Account.Type, c.Account.Name, c.Account.MasterRecordId, c.Account.IsDeleted, 
                  c.Account.Id, c.AccountId From Contact c where c.id=:contactID];
        
        
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
        a.Zip__c = '22182';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
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
        c.Zip__c = '22182';
        c.QAS_Mailing_County__c = 'Arlington';
        
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
        s.Status__c = 'In Progress';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '22182';
        s.County__c = 'Fairfax';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';

        insert s;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetAccountAndContactDetailsByContactID/123456';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    
        List<Contact> ra = AccountAndContactDetailsByContactID.doGet();
        
        
        System.assertEquals(0, ra.size());
      
 
  }
}