@isTest 
private class CornerstoneSync_Test{

    private static testMethod void doTestOne() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
               
            /* Test data generation */
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount();
            Contact c = createContact(a.Id);
            Subscriptions__c s = createSubscription(a.Id, c.Id, '123111');     

            List<Subscription_Role__c> subRoles = new List<Subscription_Role__c>();
            
            Subscription_Role__c subRole1 = createSubscriptionRole('Edit', 'Active', '89752575196', s.id);
            Subscription_Role__c subRole2 = createSubscriptionRole('Agent', 'Active', '89752575199', s.id);
            Subscription_Role__c subRole3 = createSubscriptionRole('Lister', 'Active', '', s.id);
            subRoles.add(subRole1);
            subRoles.add(subRole2);
            subRoles.add(subRole3);            
            insert subRoles;
            
            /* Set page reference and create apex standard controller */
            PageReference cornSync = Page.CornerstoneSync; 
            Test.setCurrentPage(cornSync);             
            
            ApexPages.currentPage().getParameters().put('id', s.Id);
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(subRoles);
            
            /* Subscription role class */
            CornerstoneSync.SRselect sSelect = new CornerstoneSync.SRselect();
            sSelect.sr = subRole1;
            sSelect.srSelected = true;
            sSelect.csStatus = '';
            
            List<CornerstoneSync.SRselect> sSelectList = new List<CornerstoneSync.SRselect>();
            sSelectList.add(sSelect);
            
            /* Cornerstone sync object*/
            CornerstoneSync obj = new CornerstoneSync(controller);
            try { 
                obj.loadSync(); 
                obj.loadPage();
            } 
            catch(Exception e) {}
            obj.loadCornerstone(subRoles, subRoles);  
            obj.loadSalesforce(subRoles, subRoles);
            obj.processSync();
            obj.linkRole(subRole1);
            obj.cancel();
            obj.submit();
            
            Test.stopTest();
        }
    }
      
    private static testMethod void doTestTwo() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
               
            /* Test data generation */
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount();
            Contact c = createContact(a.Id);
            Subscriptions__c s = createSubscription(a.Id, c.Id, '123111');     

            List<Subscription_Role__c> subRoles1 = new List<Subscription_Role__c>();
            List<Subscription_Role__c> subRoles2 = new List<Subscription_Role__c>();
            
            Subscription_Role__c subRole1 = createSubscriptionRole('Edit', 'Active', '89752575196', s.id);
            Subscription_Role__c subRole2 = createSubscriptionRole('Agent', 'Active', '89752575199', s.id);
            Subscription_Role__c subRole3 = createSubscriptionRole('Lister', 'Active', '', s.id);
            subRoles1.add(subRole1);
            subRoles1.add(subRole2);
            subRoles1.add(subRole3);            
            insert subRoles1;
            
            Subscription_Role__c subRole4 = createSubscriptionRole('Lister', 'Active', '89752575197', s.id);
            Subscription_Role__c subRole5 = createSubscriptionRole('Search', 'Active', '89752575198', s.id);
            subRoles2.add(subRole4);
            subRoles2.add(subRole5);
            insert subRoles2;
            
            /* Set page reference and create apex standard controller */
            PageReference cornSync = Page.CornerstoneSync; 
            Test.setCurrentPage(cornSync);             
            
            ApexPages.currentPage().getParameters().put('id', s.Id);
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(subRoles1);
            
            /* Subscription role class */
            CornerstoneSync.SRselect sSelect = new CornerstoneSync.SRselect();
            sSelect.sr = subRole1;
            sSelect.srSelected = true;
            sSelect.csStatus = '';
            
            List<CornerstoneSync.SRselect> sSelectList = new List<CornerstoneSync.SRselect>();
            sSelectList.add(sSelect);
            
            /* Cornerstone sync object*/
            CornerstoneSync obj = new CornerstoneSync(controller);
            try { 
                obj.loadSync(); 
                obj.loadPage();
            } 
            catch(Exception e) {}
            obj.loadCornerstone(subRoles2, subRoles1);  
            obj.loadSalesforce(subRoles1, subRoles2);
            
            obj.CSadd = sSelectList;
            obj.SFadd = sSelectList;
            obj.RLink = sSelectList;
            obj.processSync();
            
            /*
            obj.linkRole(subRole1);
            obj.cancel();
            obj.submit();
            */
            Test.stopTest();
        }
    }    
    
    private static Account createAccount() {
        Account a = new Account();
        a.name = 'ADA0001';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
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
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'test@test.com';
        s.Primary__c = true;
        insert s;
        
        return s;    
    }
    
    private static Subscription_Role__c createSubscriptionRole(String role, String status, String roleKey, String subId) {
        Subscription_Role__c subRole = new Subscription_Role__c ();
        subRole.Role__c = role;
        subRole.Status__c = status;
        subRole.sysPrRoleKey__c = roleKey;
        subRole.Subscription__c = subId;
  
        return subRole;   
    }       

}