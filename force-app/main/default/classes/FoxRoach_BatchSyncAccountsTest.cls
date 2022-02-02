@isTest
public class FoxRoach_BatchSyncAccountsTest 
{
    @isTest
    static void testBatchSyncAccountsInActive()
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account accountIn = new Account();
        accountIn.Name = 'Test Office Name Inactive';
        accountIn.FoxRoach_OfficeID__c = '12346';
        accountIn.Type = 'Residential';
        accountIn.Account_Name__c = 'Test Account';
        accountIn.QAS_Mailing_County__c = 'Fairfax';
        accountIn.County__c = 'Fairfax';
        accountIn.City__c = 'Herndon';
        accountIn.Zip__c = '20171';
        accountIn.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        accountIn.State__c = 'VA';
        accountIn.Status__c = 'Inactive';
        insert accountIn; 
        
        
        
        Contact contactIn = new Contact();
        contactIn.Email = 'email@something2.com';
        contactIn.FirstName = 'Test Class 2';
        contactIn.LastName = 'Contact 2';
        contactIn.Public_Email__c = 'email@something2.com';
        contactIn.AccountId = accountIn.Id; 
        contactIn.Salutation = 'Mr.';
        contactIn.City__c = 'Herndon';
        contactIn.QAS_Mailing_County__c = 'Arlington';
        contactIn.Zip__c = '20171';
        contactIn.State__c = 'VA';
        insert contactIn;
        
        Subscriptions__c subscriptionIn = new  Subscriptions__c();
        subscriptionIn.Contact__c = contactIn.id;
        subscriptionIn.Subscription_Type__c = 'Realtor/Shareholder';
        subscriptionIn.Status__c = 'In Progress';
        subscriptionIn.City__c = 'Herndon';
        subscriptionIn.Zip__c = '20171';
        subscriptionIn.County__c = 'Fairfax';
        subscriptionIn.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscriptionIn.AgentKey__c = '123111';
        subscriptionIn.Name = '123111';
        subscriptionIn.County__c = 'Fairfax';
        subscriptionIn.Related_Location_Broker_Office__c = accountIn.id;
        subscriptionIn.Contact_Type__c = 'Agent';
        subscriptionIn.Private_Email__c = 'test1@test.com';
        subscriptionIn.FoxRoachID__c = '1123';
        insert subscriptionIn;
        
        Test.startTest();
        createFoxOfficeAccounts();
        Database.executeBatch(new FoxRoach_BatchSyncAccounts());
        
        accountIn.Status__c = 'Active';
        update accountIn;
        
        subscriptionIn.Status__c = 'Active';
        subscriptionIn.Contact_Type__c = 'Limited Public Records Only';
        update subscriptionIn;
        system.debug('After Active subscription---'+[Select Id, name, status__c from Subscriptions__c where id = :subscriptionIn.Id]);
        Database.executeBatch(new FoxRoach_BatchSyncAccounts());
        Test.stopTest();
    }
    @isTest
    static void testBatchSyncAccountsActive()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();

        Account account = new Account();
        account.Name = 'Test Office Name';
        account.FoxRoach_OfficeID__c = '12345';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        insert account;
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test1@test.com';
        subscription.FoxRoachID__c = '1122';
        insert subscription;
        
        
        Test.startTest();
        subscription.Status__c = 'Active';
        subscription.Contact_Type__c = 'Limited Public Records Only';
        update subscription;
        Database.executeBatch(new FoxRoach_BatchLoadOffices());
               
        Test.stopTest();
    }
    
    @isTest
    static void testBatchSyncAccountsActiveNotLimited()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();

        Account account = new Account();
        account.Name = 'Test Office Name';
        account.FoxRoach_OfficeID__c = '12345';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        insert account;
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test@test.com';
        subscription.FoxRoachID__c = '1122';
        insert subscription;
        
        
        Test.startTest();
        subscription.Status__c = 'Active';
        //subscription.Contact_Type__c = 'Limited Public Records Only';
        update subscription;
        Database.executeBatch(new FoxRoach_BatchLoadOffices());
               
        Test.stopTest();
    }
    
    static void createFoxOfficeAccounts()
    {
        list<FoxRoach_Office__c> newOffices = new list<FoxRoach_Office__c>();
        //Office InActive
        FoxRoach_Office__c officeInactive = new FoxRoach_Office__c();
        officeInactive.Name = 'Test Office Name Inactive';
        officeInactive.Office_Id__c = '12346';
        officeInactive.FranchiseCode__c = 'Franchise';
        
        officeInactive.Address1__c = 'Street -1';
        officeInactive.Address2__c = 'Lane-5';
        officeInactive.City__c = 'Newyork';
        officeInactive.StateOrProvince__c = 'NY';
        officeInactive.PostalCode__c = '4445';
        officeInactive.Country__c = 'USA';
        
        newOffices.add(officeInactive);
                       
        //Office not in SF
        FoxRoach_Office__c officeNotSf = new FoxRoach_Office__c();
        officeNotSf.Name = 'Test Office Name not in SF';
        officeNotSf.Office_Id__c = '12347';
        officeNotSf.FranchiseCode__c = 'Franchise';
        
        officeNotSf.Address1__c = 'Street -1';
        officeNotSf.Address2__c = 'Lane-5';
        officeNotSf.City__c = 'Newyork';
        officeNotSf.StateOrProvince__c = 'NY';
        officeNotSf.PostalCode__c = '4445';
        officeNotSf.Country__c = 'USA';
        
        newOffices.add(officeNotSf);
            
        insert newOffices;
        
        //Account From Inactive Office
        list<FoxRoach_Account__c> newAccounts = new list<FoxRoach_Account__c>();
        FoxRoach_Account__c newAcc1 = new FoxRoach_Account__c();
        newAcc1.Name = '1123';
        newAcc1.Address1__c = 'add-1';
        newAcc1.City__c = 'Newyork';
        newAcc1.Country__c = 'USA';
        newAcc1.State__c = 'NY';
        newAcc1.Zip__c = '12344';
        newAcc1.Office_Name__c = 'Test Office Name Inactive';
        newAcc1.Email__c = 'test@test2.com';
        newAcc1.FirstName__c = 'FName -1';
        newAcc1.FoxRoachID__c = '1123';
        newAcc1.LastName__c = 'last Name-1';
        newAcc1.Office__c = officeInactive.Id;
        newAcc1.PhoneNumber__c = '1234512345';
        newAccounts.add(newAcc1);
        
        //Account From Inactive Office
        FoxRoach_Account__c newAcc2 = new FoxRoach_Account__c();
        newAcc2.Name = '1124';
        newAcc2.Address1__c = 'add-1';
        newAcc2.City__c = 'Newyork';
        newAcc2.Country__c = 'USA';
        newAcc2.State__c = 'NY';
        newAcc2.Zip__c = '12344';
        newAcc2.Office_Name__c = 'Test Office Name Inactive';
        newAcc2.Email__c = 'test@test3.com';
        newAcc2.FirstName__c = 'FName -2';
        newAcc2.FoxRoachID__c = '1124';
        newAcc2.LastName__c = 'last Name-3';
        newAcc2.Office__c = officeNotSf.Id;
        newAcc2.PhoneNumber__c = '1234512345';
        newAccounts.add(newAcc2);
        
        insert newAccounts;
        
    }

}