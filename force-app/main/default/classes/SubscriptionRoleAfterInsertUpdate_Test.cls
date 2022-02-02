@isTest
private class SubscriptionRoleAfterInsertUpdate_Test {
    
    private static testMethod void doTestOne(){   
        generateData();             
        Account mainAccount = createAccount('Residential','XYZ111'); 
        insert mainAccount;
        
        Account relatedAccountOne = createAccount('Association','XYZ121');
        insert  relatedAccountOne;
        
        Account relatedAccountTwo = createAccount('Association','XYZ122');
        insert relatedAccountTwo;
                    
        Contact contact = createContact(mainAccount.Id);
        insert contact;
                     
        Subscriptions__c subscription = createSubscription(mainAccount.Id, contact.Id);
        insert subscription;        
        
        System.Debug('*** sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];   
        
        Relationship__c relationshipOne = createRelationship(mainAccount.Id, relatedAccountOne.Id, 'Broker Of Record');
        insert relationshipOne;
        Relationship__c relationshipTwo = createRelationship(mainAccount.Id, relatedAccountTwo.Id, 'Office Manager'); 
        insert relationshipTwo;
        
        List<Subscription_Role__c> subRolelist = new List<Subscription_Role__c>();
        Subscription_Role__c subRole1 = createSubscriptionRole(subs[0].Id,'Applied Video');
        subRolelist.add(subRole1); 
        
        Subscription_Role__c subRole2 = createSubscriptionRole(subs[0].Id,'Agent');  
        subRolelist.add(subRole2); 
        
        Subscription_Role__c subRole3 = createSubscriptionRole(subs[0].Id,'System MRIS');  
        subRolelist.add(subRole3); 
        
        Subscription_Role__c subRole4 = createSubscriptionRole(subs[0].Id,'Edit');  
        subRolelist.add(subRole4); 
        
        Subscription_Role__c subRole5 = createSubscriptionRole(subs[0].Id,'Agent');  
        subRolelist.add(subRole5); 
        
        Subscription_Role__c subRole6 = createSubscriptionRole(subs[0].Id,'Search');  
        subRolelist.add(subRole6); 
        
        Subscription_Role__c subRole7 = createSubscriptionRole(subs[0].Id,'Lister');  
        subRolelist.add(subRole7); 
        
        insert subRolelist;
        
        for(Subscription_Role__c role : subRolelist)
            role.MDS_Status__c = 'Success';
        
        update subRolelist;
        
        for(Subscription_Role__c role : subRolelist)
            role.Status__c = 'Inactive';
        
        update subRolelist;        
        
        /*
        subRoleTwo.Status__c = 'Inactive';
        subRoleTwo.MDS_Status__c = 'Success'; 
        //update subRoleTwo;  
        
        subRoleTwo.Status__c = 'Active';
        subRoleTwo.MDS_Status__c = 'Success'; 
        //update subRoleTwo;         
        */                                                
    }

    private static Account createAccount(String type,String name){
        /*
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        */
        Account testAccount = new Account();
        testAccount.OfficeKey__c = 'ABCD1234';
        testAccount.Name = name;
        testAccount.Type = type;
        testAccount.Account_Name__c = 'Test Account';
        testAccount.Status__c = 'In Progress';
        testAccount.Phone = '2345678908';
        testAccount.Addl_Display_Name__c = 'xyz';
        testAccount.Box__c = NULL;
        testAccount.City__c = 'Herndon';
        testAccount.QAS_Mailing_Country__c = 'USA';
        testAccount.QAS_Mailing_County__c = 'Fairfax';
        testAccount.State__c = 'VA';
        testAccount.QAS_Mailing_Street_Direction__c = 'N';
        testAccount.Street_Name__c = 'First';
        testAccount.Street_Number__c ='1275';
        testAccount.Street_Number_Suffix__c = NULL;
        testAccount.QAS_Mailing_Street_Type__c = 'ST';
        testAccount.Unit__c = '1';
        testAccount.Zip__c ='20002';
        testAccount.Zip_4__c = NULL;
        testAccount.QAS_Mailing_POBox__c = '1234';
        testAccount.QAS_Mailing_Record_Type__c = NULL;
        testAccount.Copy_Address_to_Billing__c = true;
        testAccount.QAS_Mailing_Record_Type__c = 'P';        
        return testAccount;
    }
    
    private static Contact createContact(String accountId){
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        
        return contact; 
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = contactId;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123112';
        s.name = '123112';
        s.Related_Location_Broker_Office__c = accountId;
        s.Contact_Type__c = 'Agent';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'test@test.com';
        s.Addl_Display_Name__c = 'Test';
        s.QAS_Mailing_Country__c = 'USA';
        s.QAS_Mailing_County__c = 'Fairfax';
        s.State__c = 'VA';
        s.QAS_Mailing_Street_Direction__c = 'NORTH';
        s.Street_Name__c = 'First';
        s.Street_Number__c ='1275';
        s.Street_Number_Suffix__c = NULL;
        s.Unit__c = '1';
        s.QAS_Mailing_Unit_Type__c = 'SU';
        s.Zip__c ='20002';
        s.Zip_4__c = NULL;
        s.QAS_Mailing_POBox__c = NULL;
        s.QAS_Mailing_Record_Type__c = NULL;
        s.Copy_Address_to_Billing__c = true;
        s.QAS_Mailing_Record_Type__c = 'P';
        s.QAS_Billing_Record_Type__c = 'P';
        s.Primary__c = true;
        
        return s;
    }
    
    private Static Relationship__c createRelationship(String accountId, String relatedAccountId, String type) {
    
        Relationship__c relationship = new Relationship__c();
        relationship.Relationship_Type__c = type;
        relationship.MDS_Status__c = 'Success';
        relationship.Broker_Office__c = accountId;
        relationship.Related_Account__c = relatedAccountId;
        
        return relationship;
    
    }
    
    private Static Subscription_Role__c createSubscriptionRole(String subscriptionId, String role){
        Subscription_Role__c subRole = new Subscription_Role__c ();
        subRole.Role__c = role;
        subRole.Status__c = 'Active';
        subRole.sysPrRoleKey__c = '89752575777';
        subRole.Subscription__c = subscriptionId;
        
        return subRole;  
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }    
}