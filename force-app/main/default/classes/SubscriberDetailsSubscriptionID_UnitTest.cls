@isTest
public class SubscriberDetailsSubscriptionID_UnitTest {
  
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
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert a;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.Salutation = 'Mr.';
        c.QAS_Mailing_County__c = 'Arlington';
        c.City__c = 'Herndon';
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
        s.Status__c = 'In Progress';
        s.License__c = l.id;
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
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
    
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/GetSubscriberDetailsBySubscriptionID/'+s.AgentKey__c;  
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
            
        SubscriberDetailsBySubscriptionID.doGet();
        // for upprer class
        SubscriberDetailsBySubscriptionID.SubscriberDetailsBySubscription subscriberDetailsObj = new SubscriberDetailsBySubscriptionID.SubscriberDetailsBySubscription(); 

    //  System.assert(contains('Success'),);
  }

}