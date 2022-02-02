@isTest(seealldata=true)
private class SubscriptionRoleProcessingUtility_Test{

    private static testMethod void doTestOne() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
               
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount('Residential');
            Contact c = createContact(a.Id);
            Subscriptions__c s = createSubscription(a.Id, c.Id, '123111');     

            Subscription_Role__c subRole = new Subscription_Role__c();
            subRole.Subscription__c = s.Id;
            subRole.Role__c = 'Status Active';
            subRole.Status__c = 'Active';
            insert subRole;             
            
            Map<Id,String> subscriptionRoleMap = new Map<Id,String>();
            subscriptionRoleMap.put(subRole.id,JSON.serialize(subRole));            
            SubscriptionRoleProcessingUtility_New.createSubscriptionRole(subscriptionRoleMap);
            SubscriptionRoleProcessingUtility_New.deleteSubscriptionRole(subscriptionRoleMap);
            
            subRole.MDS_Status__c = 'Success';
            subRole.Status__c = 'Active';
            update subRole; 
            
            Test.stopTest();
        }
    }
    
    private static testMethod void doTestTwo() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest();     
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount('RETS');
            Contact c = createContact(a.Id);
            Subscriptions__c s = createSubscription(a.Id, c.Id, '123111'); 
            
            Subscription_Role__c subRole = new Subscription_Role__c();
            subRole.Subscription__c = s.Id;
            subRole.Role__c = 'REALTORS  Property Resource';
            subRole.Status__c = 'Active';
            insert subRole; 
            
            
            Map<Id,String> subscriptionRoleMap = new Map<Id,String>();
            subscriptionRoleMap.put(subRole.id,JSON.serialize(subRole));            
            SubscriptionRoleProcessingUtility_New.createSubscriptionRole(subscriptionRoleMap); 
            
            Test.stopTest();
        }                            
    }
    
    private static testMethod void doTestThree() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
               
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount('Residential');
            Contact c = createContact(a.Id);
            Subscriptions__c s = createSubscription(a.Id, c.Id, '123111');     

            List<Subscription_Role__c> subRoles = new List<Subscription_Role__c>();
            
            subRoles.add(createSubscriptionRole('Status Active', s.Id));
            subRoles.add(createSubscriptionRole('Agent', s.Id));
            subRoles.add(createSubscriptionRole('System MRIS', s.Id));
            subRoles.add(createSubscriptionRole('Search', s.Id));
            subRoles.add(createSubscriptionRole('Edit', s.Id));
            subRoles.add(createSubscriptionRole('Personal Asst', s.Id));
            subRoles.add(createSubscriptionRole('Lister', s.Id));
            
            insert subRoles;             
            
            subRoles[0].MDS_Status__c = 'Success';
            subRoles[0].Status__c = 'Inactive';
            subRoles[1].MDS_Status__c = 'Success';
            subRoles[1].Status__c = 'Inactive';
            subRoles[2].MDS_Status__c = 'Success';
            subRoles[2].Status__c = 'Inactive';
            subRoles[3].MDS_Status__c = 'Success';
            subRoles[3].Status__c = 'Inactive';
            subRoles[4].MDS_Status__c = 'Success';
            subRoles[4].Status__c = 'Inactive';
            subRoles[5].MDS_Status__c = 'Success';
            subRoles[5].Status__c = 'Inactive';
            subRoles[6].MDS_Status__c = 'Success';
            subRoles[6].Status__c = 'Inactive';
            
            update subRoles; 
            
            Test.stopTest();
        }
    }

    private static Account createAccount(String type) {
        Account a = new Account();
        a.name = 'ADA0001';
        a.type = type;
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a.Street_Number__c = '6824';
        a.Street_Name__c = 'Dean';
        a.Zip__c = '22101';
        a.State__c = 'VA';
        a.Country__c = 'USA';
        a.Phone = '5559991234';
        insert a;    
        
        return a;
    }
    
    private static Contact createContact(String accountId){
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Middle_Name__c = 'test';
        contact.Nickname__c = 'test';
        contact.Suffix__c = 'JR.';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Ms.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact; 
        
        return contact; 
    } 
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String name){  
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = contactId;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = name;
        s.name = name;
        s.Related_Location_Broker_Office__c = accountId;
        s.Contact_Type__c = 'Agent';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.QAS_Billing_Street_Type__c = 'ACRES, ACRES';
        s.Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'test@test.com';
        s.Primary__c = true;
        insert s;
        
        return s;    
    } 
    
    private Static Subscription_Role__c createSubscriptionRole(String roleName, String subscriptionId){    
        Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = subscriptionId;
        subRole.Role__c = roleName;
        subRole.Status__c = 'Active';
        
        return subRole;
    }
}