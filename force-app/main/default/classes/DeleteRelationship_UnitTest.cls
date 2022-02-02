/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DeleteRelationship_UnitTest {
    static Related_Agent__c mockRecords(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
/*
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.County__c = 'Fairfax';
        a.Zip__c = '20171';
        insert a;
*/        
        Account a1 = new Account();
        a1.name = 'ABC1235';
        a1.type = 'Association';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.County__c = 'Fairfax';
        a1.Zip__c = '20171';
        insert a1;
        
        Account a2 = new Account();
        a2.name = 'ABC1236';
        a2.type = 'Association';
        a2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Zip__c = '20171';
        insert a2;
/*        
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
*/        
        Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.Public_Email__c = 'email@something.com';
        c1.AccountId = a1.id; 
        c1.Salutation = 'Mr.';
        c1.QAS_Mailing_County__c = 'Arlington';
        c1.City__c = 'Herndon';
        c1.Zip__c = '20171';        
        insert c1;
        
        Contact c2 = new Contact();
        c2.Email = 'email@something.com';
        c2.FirstName = 'Test';
        c2.LastName = 'Contact';
        c2.Public_Email__c = 'email@something.com';
        c2.AccountId = a2.id; 
        c2.Salutation = 'Mr.';
        c2.QAS_Mailing_County__c = 'Arlington';
        c2.City__c = 'Herndon';
        c2.Zip__c = '20171';
        insert c2;
/*            
        Subscriptions__c sc = new Subscriptions__c();
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Subscription_Type__c = 'Licensee';
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Public_Email__c = 'email@something.com';
        sc.Status__c = 'In Progress';
        sc.Primary_Phone__c = '1231111643';
        sc.Public_Email__c = 'email@something.com';
        sc.Mobile_Phone__c = '1231112643';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20171';
        sc.County__c = 'Fairfax';
        sc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact__c = c.id;
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Contact_Type__c = 'Agent';
        insert sc;
*/      
/*  
        Subscriptions__c sc3 = new Subscriptions__c();
        sc3.Name = '1234541';
        sc3.Contact_Type__c = 'Agent';
        sc3.Subscription_Type__c = 'Licensee';
        sc3.Related_Location_Broker_Office__c = a.id;
        sc3.Public_Email__c = 'email@something.com';
        sc3.Status__c = 'In Progress';
        sc3.Primary_Phone__c = '1231111643';
        sc3.Public_Email__c = 'email@something.com';
        sc3.Mobile_Phone__c = '1231112643';
        sc3.City__c = 'Herndon';
        sc3.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc3.Zip__c = '20171';
        sc3.Country__c = 'UNITED STATES';
        sc3.State__c = 'VA';
        sc3.Contact__c = c.id;
        sc3.County__c = 'Fairfax';
        sc3.Related_Location_Broker_Office__c = a.id;
        sc3.Contact_Type__c = 'Agent';
        insert sc3;
*/        
        Subscriptions__c sc1 = new Subscriptions__c();
        sc1.Name = '1234521';
        sc1.Contact_Type__c = 'Agent';
        sc1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc1.Subscription_Type__c = 'Licensee';
        sc1.Related_Location_Broker_Office__c = a1.id;
        sc1.Public_Email__c = 'email@something.com';
        sc1.Status__c = 'In Progress';
        sc1.Primary_Phone__c = '1231111643';
        sc1.Public_Email__c = 'email@something.com';
        sc1.Mobile_Phone__c = '1231112643';
        sc1.City__c = 'Herndon';
        sc1.Zip__c = '20171';
        sc1.County__c = 'Fairfax';
        sc1.Country__c = 'UNITED STATES';
        sc1.State__c = 'VA';
        sc1.Contact__c = c1.id;
        sc1.Contact_Type__c = 'Agent';
        insert sc1;
        
        Subscriptions__c sc2 = new Subscriptions__c();
        sc2.Name = '1234531';
        sc2.Contact_Type__c = 'Agent';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.Related_Location_Broker_Office__c = a2.id;
        sc2.Public_Email__c = 'email@something.com';
        sc2.Status__c = 'In Progress';
        sc2.Primary_Phone__c = '1231111643';
        sc2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc2.Public_Email__c = 'email@something.com';
        sc2.Mobile_Phone__c = '1231112643';
        sc2.City__c = 'Herndon';
        sc2.Zip__c = '20171';
        sc2.County__c = 'Fairfax';
        sc2.Country__c = 'UNITED STATES';
        sc2.State__c = 'VA';
        sc2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc2.Contact__c = c2.id;
        sc2.Contact_Type__c = 'Agent';
        insert sc2;
        
        Related_Agent__c relAgObj = New  Related_Agent__c();
        relAgObj.Subscription__c = sc1.Id;
        relAgObj.Assistant_to__c = c2.id;
        relAgObj.Status__c = 'Active';
        relAgObj.Personal_Assistant_Sub_ID__c = sc2.Id;
        relAgObj.Personal_Assistant__c = c1.Id;
        insert relAgObj;

        return relAgObj;
    }
    
    static testMethod void deleteRelationship_unitTest() {
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            Related_Agent__c ra  = mockRecords();
            req.addParameter('Id', ra.id);

            req.requestURI = 'https://cs10.salesforce.com/services/apexrest/DeleteRelationship/'+ra.id;  
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            DeleteRelationship.doDelete();
            System.assertNotEquals(null,ra);
        Test.stopTest();        
    }
}