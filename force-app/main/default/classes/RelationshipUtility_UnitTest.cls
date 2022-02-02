@isTest
public class RelationshipUtility_UnitTest {

    static testMethod void ForcreateRelationship() {
    
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    
    List<Account> accList = new  List<Account>();
    List<Contact> conList = new  List<Contact>();
    List<Subscriptions__c> subList = new  List<Subscriptions__c>();
    List<Relationship> relList = new  List<Relationship>();
    
        
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.County__c = 'Fairfax';
        accList.add(a);
        
        Account a1 = new Account();
        a1.name = 'ABC1235';
        a1.type = 'Association';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a1.County__c = 'Fairfax';
        a1.Zip__c = '20171';
        accList.add(a1);

        Account a2 = new Account();
        a2.name = 'ABC1236';
        a2.type = 'Association';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a2.County__c = 'Fairfax';
        accList.add(a2);
        
        insert accList;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.QAS_Mailing_County__c = 'Arlington';
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        conList.add(c);
        
        Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.Public_Email__c = 'email@something.com';
        c1.AccountId = a1.id; 
        c1.Salutation = 'Mr.';
        c1.City__c = 'Herndon';
        c1.QAS_Mailing_County__c = 'Arlington';
        c1.Zip__c = '20171';
        conList.add(c1);

        Contact c2 = new Contact();
        c2.Email = 'email@something.com';
        c2.FirstName = 'Test';
        c2.LastName = 'Contact';
        c2.Public_Email__c = 'email@something.com';
        c2.AccountId = a2.id; 
        c2.Salutation = 'Mr.';
        c2.City__c = 'Herndon';
        c2.QAS_Mailing_County__c = 'Arlington';
        c2.Zip__c = '20171';
        conList.add(c2);

        insert conList;
        
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
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact__c = c.id;
        sc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Contact_Type__c = 'Agent';
        subList.add(sc);
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
        sc3.Zip__c = '20171';
        sc3.County__c = 'Fairfax';
        sc3.Country__c = 'UNITED STATES';
        sc3.State__c = 'VA';
        sc3.Contact__c = c.id;
        sc3.Related_Location_Broker_Office__c = a.id;
        sc3.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc3.Contact_Type__c = 'Agent';
        subList.add(sc3);
*/
        Subscriptions__c sc1 = new Subscriptions__c();
        sc1.Name = '1234521';
        sc1.Contact_Type__c = 'Agent';
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
        sc1.Related_Location_Broker_Office__c = a.id;
        sc1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc1.Contact_Type__c = 'Agent';
        subList.add(sc1);
        
        Subscriptions__c sc2 = new Subscriptions__c();
        sc2.Name = '1234531';
        sc2.Contact_Type__c = 'Agent';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.Related_Location_Broker_Office__c = a2.id;
        sc2.Public_Email__c = 'email@something.com';
        sc2.Status__c = 'In Progress';
        sc2.Primary_Phone__c = '1231111643';
        sc2.Public_Email__c = 'email@something.com';
        sc2.Mobile_Phone__c = '1231112643';
        sc2.City__c = 'Herndon';
        sc2.Zip__c = '20171';
        sc2.County__c = 'Fairfax';
        sc2.Country__c = 'UNITED STATES';
        sc2.State__c = 'VA';
        sc2.Contact__c = c2.id;
        sc2.Related_Location_Broker_Office__c = a.id;
        sc2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc2.Contact_Type__c = 'Agent';
        // insert sc2;
        subList.add(sc2);
        insert subList;
        
        Relationship rel  = new Relationship();
        rel.RelationshipName = 'Invalid Relationship';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Invalid relationshipName'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Agent__c';
        rel.SFSubscriptionID = sc1.Id;
        rel.RelatedSFSubscriptionID = sc2.Id;
        rel.notes = 'This is a test';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));

        rel  = new Relationship();
        rel.RelationshipName = 'Related_Agent__c';
        rel.RelatedSFSubscriptionID = sc2.Id;
        rel.notes = 'This is a test';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFSubscriptionID & RelatedSFSubscriptionID is required'));

        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.SFAccountID = a.id;
        rel.RelationshipType = 'Branch Office';
        rel.RelatedSFAccountID = a1.id;
    //    System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
        
        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.RelationshipType = 'Branch Office';
        rel.RelatedSFAccountID = a1.id;
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFAccountID & RelationshipType is required'));

        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.SFAccountID = a.id;
        rel.RelationshipType = 'Branch Office';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Either SFSubscriptionID or RelatedSFAccountID is required.'));
/*        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAccountID = a2.id;
        //rel.Subscription__c = sc1.id;
        rel.notes = 'Test Notes';
        rel.SFAssociationId = a2.id;
        rel.RelationshipType = 'Association';
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
*/        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAssociationId = a2.id;
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));
/*        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFAssociationId = a2.id;
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        rel.Primary = 'adsfdasf';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Invalid Primary type.'));
*/        
        rel  = new Relationship();
        rel.RelationshipName = 'Related_Association__c';
        rel.SFSubscriptionID = sc1.id;
        rel.notes = 'Test Notes';
        rel.RelationshipType = 'Apprisar';
        rel.Primary = 'adsfdasf';
        System.debug(RelationshipUtility.createRelationship(rel).message);
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('SFAssociationId & RelationshipType is required'));
       
        rel  = new Relationship();
        rel.RelationshipName = 'Relationship__C';
        rel.SFSubscriptionID = sc1.Id;
        rel.RelatedSFSubscriptionID = sc2.Id;
        rel.notes = 'This is a test';
        rel.SFAccountID = a2.Id;
        rel.RelationshipType  = 'Personal Assitant';
        rel.RelatedSFAccountID = a2.Id;
        rel.RelationshipStartDateTime = ''+date.today();
        System.assert(RelationshipUtility.createRelationship(rel).message.contains('Success'));

         // for Update Relationship
                
        Related_Agent__c relAgObj = New  Related_Agent__c();
        relAgObj.Subscription__c = sc1.Id;
        relAgObj.Assistant_to__c = c2.id;
        relAgObj.Status__c = 'Active';
        relAgObj.Personal_Assistant_Sub_ID__c = sc2.Id;
        relAgObj.Personal_Assistant__c = c1.Id;
        insert relAgObj;
        
        Related_Association__c r1 = new Related_Association__c();
        r1.Broker_Code__c = a.id;
        r1.Primary__c = true;
        r1.Association__c = a2.id;   
       // r1.Status__c = 'Inactive';
        r1.Status__c = 'Active';
        insert r1;
        
        RelationshipUtility.updateRelationship(relAgObj.Id);
        RelationshipUtility.updateRelationship(r1.Id);        
    }
}