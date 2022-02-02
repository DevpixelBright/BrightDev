@isTest 
private class MdsRoles_Test{

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
            
            s.Name = '123111';
            upsert s; 
                        
            String response = '<?xml version="1.0" encoding="UTF-8"?><response><PartyRole><SysPrKey>12345678</SysPrKey><SysPrRoleID>123111</SysPrRoleID><SysPrRoleName>Agent</SysPrRoleName><SysPrStartDate>2014-06-30T17:49:00</SysPrStartDate><SysPrEndDate></SysPrEndDate><SysPrCurrent>1</SysPrCurrent></PartyRole></response>';
            List<Subscription_Role__c> roles = MdsRoles.parseMDSroles(response);
            
            try { MdsRoles.rolesBySubId('123111'); }
            catch(Exception e) {}           
            try{
                MdsRoles.rolesByOfficeKey('123456');
            }
            catch(Exception e) {}
            try{
                MdsRoles.rolesByAgentKey('123456');
            }
            catch(Exception e) {}                          
            
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
}