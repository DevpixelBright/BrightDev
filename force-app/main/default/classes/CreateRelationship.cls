/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will create Relationship
**/
@RestResource(urlMapping='/CreateRelationship/*')
global with sharing class CreateRelationship {
    
    /**
    *  This method will create the relationships in salesforce
    *
    **/
    @HttpPost
    global static Relationship doPost(Relationship rel) {
        system.debug('** Received Relation:'+ rel);
        //validate relationship type
        RelationshipUtility.createRelationship(rel);
        return rel;
    
    }
    
    @isTest
    static void testDoPost() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://cs10.salesforce.com/services/apexrest/CreateRelationship';  
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
         
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
        
        /*Account a1 = new Account();
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
        insert a1;
        
        Account a2 = new Account();
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
        insert a2;*/
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.AccountId = a.Id; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.County__c = 'Fairfax';
        insert c;
        
        Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.AccountId = a.Id; 
        c1.Salutation = 'Mr.';
        c1.City__c = 'Herndon';
        c1.Zip__c = '20171';
        c1.County__c = 'Fairfax';
        insert c1;
        
        Contact c2 = new Contact();
        c2.Email = 'email@something.com';
        c2.FirstName = 'Test';
        c2.LastName = 'Contact';
        c2.AccountId = a.Id; 
        c2.Salutation = 'Mr.';
        c2.City__c = 'Herndon';
        c2.Zip__c = '20171';
        c2.County__c = 'Fairfax';
        insert c2;
            
        Subscriptions__c sc = new Subscriptions__c();
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Status__c = 'In Progress';
        sc.Addl_Display_Name__c = 'xyz';
        sc.Box__c = NULL;
        sc.City__c = 'Herndon';
        sc.QAS_Mailing_Country__c = 'USA';
        sc.QAS_Mailing_County__c = 'Fairfax';
        sc.State__c = 'VA';
        sc.QAS_Mailing_Street_Direction__c = 'N';
        sc.Street_Name__c = 'First';
        sc.Street_Number__c ='1275';
        sc.Street_Number_Suffix__c = NULL;
        sc.QAS_Mailing_Street_Type__c = 'ST';
        sc.Unit__c = '1';
        sc.QAS_Mailing_Unit_Type__c = 'SU';
        sc.Zip__c ='20002';
        sc.Zip_4__c = NULL;
        sc.QAS_Mailing_POBox__c = NULL;
        sc.QAS_Mailing_Record_Type__c = NULL;
        sc.Copy_Address_to_Billing__c = true;
        sc.QAS_Mailing_Record_Type__c = 'P';
        sc.Subscription_Type__c = 'Licensee';
        sc.County__c = 'Fairfax';
        sc.Contact__c = c.id;
        insert sc;
        
        Subscriptions__c sc3 = new Subscriptions__c();
        sc3.Name = '1234541';
        sc3.Contact_Type__c = 'Agent';
        sc3.Status__c = 'In Progress';
        sc3.Addl_Display_Name__c = 'xyz';
        sc3.Box__c = NULL;
        sc3.City__c = 'Herndon';
        sc3.QAS_Mailing_Country__c = 'USA';
        sc3.QAS_Mailing_County__c = 'Fairfax';
        sc3.State__c = 'VA';
        sc3.QAS_Mailing_Street_Direction__c = 'N';
        sc3.Street_Name__c = 'First';
        sc3.Street_Number__c ='1275';
        sc3.Street_Number_Suffix__c = NULL;
        sc3.QAS_Mailing_Street_Type__c = 'ST';
        sc3.Unit__c = '1';
        sc3.QAS_Mailing_Unit_Type__c = 'SU';
        sc3.Zip__c ='20002';
        sc3.Zip_4__c = NULL;
        sc3.QAS_Mailing_POBox__c = NULL;
        sc3.QAS_Mailing_Record_Type__c = NULL;
        sc3.Copy_Address_to_Billing__c = true;
        sc3.QAS_Mailing_Record_Type__c = 'P';
        sc3.Subscription_Type__c = 'Licensee';
        sc3.County__c = 'Fairfax';
        sc3.Contact__c = c.id;
        insert sc3;
        
        Subscriptions__c sc1 = new Subscriptions__c();
        sc1.Name = '1234521';
        sc1.Contact_Type__c = 'Agent';
        sc1.Subscription_Type__c = 'Licensee';
        sc1.Related_Location_Broker_Office__c = a.id;
        sc1.Status__c = 'In Progress';
        sc1.Addl_Display_Name__c = 'xyz';
        sc1.Box__c = NULL;
        sc1.City__c = 'Herndon';
        sc1.QAS_Mailing_Country__c = 'USA';
        sc1.QAS_Mailing_County__c = 'Fairfax';
        sc1.State__c = 'VA';
        sc1.QAS_Mailing_Street_Direction__c = 'N';
        sc1.Street_Name__c = 'First';
        sc1.Street_Number__c ='1275';
        sc1.Street_Number_Suffix__c = NULL;
        sc1.QAS_Mailing_Street_Type__c = 'ST';
        sc1.Unit__c = '1';
        sc1.QAS_Mailing_Unit_Type__c = 'SU';
        sc1.Zip__c ='20002';
        sc1.Zip_4__c = NULL;
        sc1.QAS_Mailing_POBox__c = NULL;
        sc1.QAS_Mailing_Record_Type__c = NULL;
        sc1.Copy_Address_to_Billing__c = true;
        sc1.QAS_Mailing_Record_Type__c = 'P';
        sc1.Subscription_Type__c = 'Licensee';
        sc1.County__c = 'Fairfax';
        sc1.Contact__c = c.id;
        insert sc1;
        
        Subscriptions__c sc2 = new Subscriptions__c();
        sc2.Name = '1234531';
        sc2.Contact_Type__c = 'Agent';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.Related_Location_Broker_Office__c = a.id;
        sc2.Contact_Type__c = 'Agent';
        sc2.Status__c = 'In Progress';
        sc2.Addl_Display_Name__c = 'xyz';
        sc2.Box__c = NULL;
        sc2.City__c = 'Herndon';
        sc2.QAS_Mailing_Country__c = 'USA';
        sc2.QAS_Mailing_County__c = 'Fairfax';
        sc2.State__c = 'VA';
        sc2.QAS_Mailing_Street_Direction__c = 'N';
        sc2.Street_Name__c = 'First';
        sc2.Street_Number__c ='1275';
        sc2.Street_Number_Suffix__c = NULL;
        sc2.QAS_Mailing_Street_Type__c = 'ST';
        sc2.Unit__c = '1';
        sc2.QAS_Mailing_Unit_Type__c = 'SU';
        sc2.Zip__c ='20002';
        sc2.Zip_4__c = NULL;
        sc2.QAS_Mailing_POBox__c = NULL;
        sc2.QAS_Mailing_Record_Type__c = NULL;
        sc2.Copy_Address_to_Billing__c = true;
        sc2.QAS_Mailing_Record_Type__c = 'P';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.County__c = 'Fairfax';
        sc2.Contact__c = c.id;
        insert sc2;
        
        
        
        Relationship rel  = new Relationship();
        rel.RelationshipName = 'Invalid Relationship';
        System.assert(CreateRelationship.doPost(rel).message.contains('Invalid relationshipName'));
    
       
      
 
  }

}