@isTest
public class UpdateLicense_UnitTest {
  
      static testMethod void testDoPost() {
        
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
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.County__c ='Fairfax';
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
     	s.Name = 'test';
        s.Status__c = 'In Progress';
        s.Addl_Display_Name__c = 'xyz';
        s.Box__c = NULL;
        s.City__c = 'Herndon';
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
        s.Zip__c ='20002';
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.Contact_Type__c = 'Agent';
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.County__c = 'Fairfax';
        s.Contact__c = c.id;
        s.Related_Location_Broker_Office__c = a.id;
        insert s;
        
        
        Subscription_License__c subLicObj = new Subscription_License__c();
        subLicObj.License__c = l.Id;
        subLicObj.Subscription__c = s.id;
        insert subLicObj;
        
        License LicenseObj = new  License();
        LicenseObj.License_Expiration_Date = ''+Date.today();
        LicenseObj.License_State = 'VA';
        LicenseObj.License_Type = 'Broker';
        LicenseObj.LicenseID = l.id;
        LicenseObj.SubscriptionLicenseID = subLicObj.id;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/UpdateLicense';  
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
            
        UpdateLicense.doPost(LicenseObj);
        
    //  System.assert(result.result.contains('Success'));
      
 
  }

}