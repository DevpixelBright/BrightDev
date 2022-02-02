@isTest
public with sharing class CaseShadowObjTests {

    public static testmethod void TestCreateShadowCases() {
        TestDataFactory tdf = new TestDataFactory();
        tdf.TriggersOff();

        List<Case> cases = tdf.CreateCases(10);
        for(Case c : cases) {
            c.Shadow_Case__c = true;
        }
        insert cases;
        
        cases = [select Id, Shadow_Case__c, Subscription_Id__c, ContactId from Case];
        
        Test.startTest();
        
        CaseShadowObj.HandleCaseInsert(cases);
        
        Test.stopTest();
        
        List<Shadow_Case__c> shc = [select Id, Related_Case__c from Shadow_Case__c];
        System.debug('cases: ' + cases.size());
        System.debug('shadows: ' + shc.size());
        System.assertEquals(cases.size(), shc.size());
        
    }
    
    public static testmethod void TestClearShadowCaseFlag() {
        TestDataFactory tdf = new TestDataFactory();

        Group complianceOwner = [select Id from Group where Type = 'Queue' and Name = 'Compliance' limit 1];        
        
        List<Case> cases = tdf.CreateCases(10);
        for(Case c: cases) {
            c.OwnerId = complianceOwner.Id;
        }
        
        insert cases;
        
        cases = [select Id, OwnerId, Shadow_Case__c from Case];

        Id nonCompliance = UserInfo.getUserId();

        for(Case c : cases) {
            System.assertEquals(true, c.Shadow_Case__c);
            c.OwnerId = nonCompliance;
        }
        
        Test.startTest();
        
        update cases;
        
        Test.stopTest();
        
        List<Shadow_Case__c> shc = [select Id, Related_Case__c from Shadow_Case__c];
        System.assertEquals(0, shc.size());
    }
    
    
    public static testmethod void TestUpdateCaseContact() {
        TestDataFactory tdf = new TestDataFactory();
        tdf.TriggersOff();
        
        List<Account> accounts = tdf.CreateAccounts(1);
        insert accounts;
        
        List<Contact> contacts = tdf.CreateContacts(5, accounts);
        insert contacts;
        
        tdf.TriggersOn();
        
        List<Case> cases = tdf.CreateCases(contacts, 2);
        
        Group complianceOwner = [select Id from Group where Type = 'Queue' and Name = 'Compliance' limit 1];
        for(Case c: cases) {
            c.OwnerId = complianceOwner.Id;
        }

        insert cases;

        cases = [select Id, ContactId, Shadow_Case__c from Case];
        
        Contact newcontact = tdf.MakeContact(accounts.get(0));
        insert newcontact;
        
        for(Case c : cases) {
            c.ContactId = newcontact.Id;
        }
        
        Test.startTest();
        
        update cases;
        
        Test.stopTest();
        
        List<Shadow_Case__c> shadow_cases = [select Id, Contact__c, Related_Case__c from Shadow_Case__c];
        System.assert(shadow_cases.size() > 0);
        for(Shadow_Case__c shadow : shadow_cases) {
            System.debug('shadow contact: ' + shadow.Contact__c);
            System.assertEquals(newcontact.Id, shadow.Contact__c);
        }
    }
    
    public static testmethod void TestDeleteCaseRecords() {
        TestDataFactory tdf = new TestDataFactory();

        Group complianceOwner = [select Id from Group where Type = 'Queue' and Name = 'Compliance' limit 1];        
        
        List<Case> cases = tdf.CreateCases(10);
        for(Case c: cases) {
            c.OwnerId = complianceOwner.Id;
        }
        
        insert cases;
        
        cases = [select Id, OwnerId, Shadow_Case__c from Case];
        
        Test.startTest();
        
        delete cases;
        
        Test.stopTest();
        
        List<Shadow_Case__c> shc = [select Id, Related_Case__c from Shadow_Case__c];
        System.assertEquals(0, shc.size());
    }
}