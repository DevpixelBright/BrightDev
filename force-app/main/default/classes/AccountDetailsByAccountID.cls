/*******************************************************************************************************************
** Module Name   : AccountDetailsByAccountID
** Description   : HTTPGET RestFull Service This service will return all the account information based on the 
**					Acount ID (Office Code) information. If no AccountID (office code) information is found, 
**					the salesforce returns a empty return structure
** Throws        : N/A
** Calls         : N/A
** Test Class    : AccountDetailsByAccountID
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date      	  Author    WO#         Description of Action
** 1.0      2012-10-15     RMA       MRIS            Initial Version
*******************************************************************************************************************/
@RestResource(urlMapping='/GetAccountDetailsByAccountID/*')
global with sharing class AccountDetailsByAccountID {
    
    global class CcountDetailsByAccountID {
        Integer totalSize = 0;
        List<Account> acList = new List<Account>();
    }

    /**
    *  HTTP Get Method
    *
    **/
    @HTTPGet
    global static List<Account> doGet(){
    //global static CcountDetailsByAccountID doGet(){
        
        CcountDetailsByAccountID acctClass = new CcountDetailsByAccountID();
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('accountID ' + accountID);
        
        List<Account> aList = [Select a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type, 
                    a.Trading_As__c, a.SystemModstamp, a.Street_Type__c, a.Street_Number__c, a.Street_Number_Suffix__c, 
                    a.Street_Name__c, a.Street_Direction__c, a.Status__c, a.State__c, a.Shareholder_Board__c, a.Rating,
                    a.PrismCompanyOffice__c, a.PrismCompanyCode__c, a.PrismAddressID__c, a.PrismAccountID__c, a.Phone, 
                    a.ParentId, a.PIN__c, a.OwnerId, a.OfficeKey__c, a.Num_Active_Subs__c, a.Num_Active_Office_Sec_NC__c, 
                    a.Name, a.MasterRecordId, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.JigsawCompanyId,
                    a.Jigsaw, a.IsDeleted, a.IsCustomerPortal, a.Id, a.Fax, a.Description, a.Date_Terminated__c, 
                    a.Date_Joined__c, a.CreatedDate, a.CreatedById, a.County__c, a.Country__c, a.Copy_Address_to_Billing__c,
                    a.Company_Type__c, a.City__c, a.Box__c, a.Billing_Zip__c, a.Billing_Zip_4__c, a.Billing_Unit_Type__c, 
                    a.Billing_Unit_Number__c, a.Billing_Street_Type__c, a.Billing_Street_Number__c, a.Billing_Street_Number_Suffix__c, 
                    a.Billing_Street_Name__c, a.Billing_Street_Direction__c, a.Billing_State__c, a.Billing_County__c, a.Billing_Country__c,
                    a.Billing_City__c, a.Billing_Box__c, a.Billing_Addl_Display_Name__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, 
                    a.BillingCity, a.Addl_Display_Name__c, a.Account_Name__c From Account a where a.Name = :accountID];
                        
                    return aList;
                    
                    //acctClass.acList.addAll(aList);
                    
                    //return acctClass;
                        
    }
    
    static testMethod void testDoGet() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
         
        Account a = new Account();
        a.name = 'ABC1234';
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
        s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.County__c = 'Fairfax';
        s.Status__c = 'In Progress';
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
        s.Subscription_Type__c = 'Licensee';
        s.County__c = 'Fairfax';
        s.Contact__c = c.id;
        insert s;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetAccountDetailsByAccountID/123456';  
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
    
        List<Account> ra = AccountDetailsByAccountID.doGet();
        
        //CcountDetailsByAccountID actDetails = AccountDetailsByAccountID.doGet();
        
        //List<Account> ra = actDetails.aList;
        
        //System.assertEquals(0, ra.size());
      
 
  }
}