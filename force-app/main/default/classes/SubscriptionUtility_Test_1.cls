@isTest
public class SubscriptionUtility_Test_1 {
  
    public Static Account account;
    public Static Contact contact;
    public Static Subscriptions__c subscription;  
  
    public static testMethod void doTestOne() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        
            Test.startTest(); 
            try {
            
                CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
                cau.addAddrs();    
                
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
                
                Subscriptions__c s = new  Subscriptions__c();
                s.Name = 'Test Subscription';
                s.Contact__c = c.id;
                s.Subscription_Type__c = 'Realtor/Shareholder';
                s.Status__c = 'In Progress';
                s.City__c = 'Herndon';
                s.Zip__c = '20171';
                s.County__c = 'Fairfax';
                s.AgentKey__c = '123111';
                s.name = '123111';
                s.Related_Location_Broker_Office__c = a.id;
                s.Contact_Type__c = 'Agent';
                s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                s.County__c = 'Fairfax';
                s.Public_Email__c = 'test@test.com';
                insert s;
                     
                Map<Id,String> newJsonAccountString = new Map<Id,String>();
                Map<Id,String> oldJsonAccountString = new Map<Id,String>();        
                
                newJsonAccountString.put(s.id,JSON.serialize(s));
                SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('INSERT', newJsonAccountString,null);
                
                Test.stopTest();
                s.Status__c = 'Active';
                update s;
                
                newJsonAccountString = new Map<Id,String>();
                     
                newJsonAccountString.put(s.id,JSON.serialize(s));
                SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('INSERT', newJsonAccountString, null);
                
            }
            catch(Exception e) {
        
            }
            
            
        } 
    }
    
    public static testMethod void doTestTwo() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest();
             
            try {
                CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
                cau.addAddrs();    
        
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
                
                Account a1 = new Account();
                a1.name = 'ADA0002';
                a1.type = 'Residential';
                a1.Account_Name__c = 'Test Account';
                a1.City__c = 'Herndon';
                a1.Zip__c = '20171';
                a1.QAS_Mailing_County__c = 'Fairfax';
                a1.County__c = 'Fairfax';
                a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                insert a1;        
                
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
                
                Subscriptions__c s = new  Subscriptions__c();
                s.Name = 'Test Subscription';
                s.Contact__c = c.id;
                s.Subscription_Type__c = 'Realtor/Shareholder';
                s.Status__c = 'In Progress';
                s.City__c = 'Herndon';
                s.Zip__c = '20171';
                s.County__c = 'Fairfax';
                s.AgentKey__c = '123111';
                s.name = '123111';
                s.Related_Location_Broker_Office__c = a.id;
                s.Contact_Type__c = 'Agent';
                s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                s.County__c = 'Fairfax';
                s.Public_Email__c = 'test@test.com';
                insert s;
                
                Subscription_Role__c subRole = new Subscription_Role__c();
                subRole.Subscription__c = s.Id;
                subRole.Role__c = 'Search';
                subRole.Status__c = 'Active';
                insert subRole;           
               
                Map<Id,String> newJsonAccountString = new Map<Id,String>();
                Map<Id,String> oldJsonAccountString = new Map<Id,String>();          
               
                oldJsonAccountString.put(s.id,JSON.serialize(s));
                
                s.Related_Location_Broker_Office__c = a1.id;
                s.Contact_Type__c = 'Broker';
                s.Public_Email__c = 'test1@test.com';
                s.Status__c = 'Active';
                update s;        
                     
                newJsonAccountString.put(s.id,JSON.serialize(s));
                Test.stopTest();
                
                SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('UPDATE', newJsonAccountString, oldJsonAccountString);
            }
            catch (DMLException e) {
            
            }
            catch(Exception e) {
            
            }
            
            
        } 
    }    
    /*
    private static testMethod void doTestThree() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            try {
                CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
                cau.addAddrs();    
                
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
                
                Account a1 = new Account();
                a1.name = 'ADA0002';
                a1.type = 'Residential';
                a1.Account_Name__c = 'Test Account';
                a1.City__c = 'Herndon';
                a1.Zip__c = '20171';
                a1.QAS_Mailing_County__c = 'Fairfax';
                a1.County__c = 'Fairfax';
                a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                insert a1;        
                
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
                
                Subscriptions__c s = new  Subscriptions__c();
                s.Name = 'Test Subscription';
                s.Contact__c = c.id;
                s.Subscription_Type__c = 'Realtor/Shareholder';
                s.Status__c = 'In Progress';
                s.City__c = 'Herndon';
                s.Zip__c = '20171';
                s.County__c = 'Fairfax';
                s.AgentKey__c = '123111';
                s.name = '123111';
                s.Related_Location_Broker_Office__c = a.id;
                s.Contact_Type__c = 'Agent';
                s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                s.County__c = 'Fairfax';
                s.Public_Email__c = 'test@test.com';
                insert s;
                
                s.Status__c = 'Active';
                update s; 
                
                Subscription_Role__c subRole = new Subscription_Role__c();
                subRole.Subscription__c = s.Id;
                subRole.Role__c = 'Search';
                subRole.Status__c = 'Active';
                insert subRole;               
               
                Map<Id,String> newJsonAccountString = new Map<Id,String>();
                Map<Id,String> oldJsonAccountString = new Map<Id,String>();          
               
                //oldJsonAccountString.put(s.id,JSON.serialize(s));
        
                s.Status__c = 'InActive';
                s.Status_Change_Reason__c = 'Terminated';
                update s;        
                     
                //newJsonAccountString.put(s.id,JSON.serialize(s));
                
                
                //SubscriptionUtility.sendSubscriptionToQueueProcessorOrig('UPDATE', newJsonAccountString, oldJsonAccountString);
            }
            catch(Exception e) {
            
            }        
            Test.stopTest();
        } 
    }
    */ 
    
   private static testMethod void doTestFour() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
        try {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        Account a = new Account();
        a.name = 'ADA0001';
        a.type = 'Residential';
        //a.type = 'RETS';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert a;
        
        Account a1 = new Account();
        a1.name = 'ADA0002';
        a1.type = 'Residential';
        //a.type = 'RETS';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.Zip__c = '20171';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.County__c = 'Fairfax';
        a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert a1;        
        
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
        
        Subscriptions__c s = new  Subscriptions__c();
        s.Name = 'Test Subscription';
        s.Contact__c = c.id;
        s.Subscription_Type__c = 'Realtor/Shareholder';
        s.Status__c = 'In Progress';
        s.City__c = 'Herndon';
        s.Zip__c = '20171';
        s.County__c = 'Fairfax';
        s.AgentKey__c = '123111';
        s.name = '123111';
        s.Related_Location_Broker_Office__c = a.id;
        s.Contact_Type__c = 'Agent';
        s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s.County__c = 'Fairfax';
        s.Public_Email__c = 'test@test.com';
        insert s;
        
        s.Status__c = 'Active';
        update s; 
        
        s.Status__c = 'InActive';
        s.Status_Change_Reason__c = 'Terminated'; 
        update s;        
        
        Subscription_Role__c subRole = new Subscription_Role__c();
        subRole.Subscription__c = s.Id;
        subRole.Role__c = 'Status Inactive';
        subRole.Status__c = 'Active';
        insert subRole;               
       
        Map<Id,String> newJsonAccountString = new Map<Id,String>();
        Map<Id,String> oldJsonAccountString = new Map<Id,String>();          
       
        oldJsonAccountString.put(s.id,JSON.serialize(s));

        s.Status__c = 'Active';
        s.Status_Change_Reason__c = 'Reinstate';
        s.Status_Change_Fee__c = 'No Charge';        

        update s;        
             
        newJsonAccountString.put(s.id,JSON.serialize(s));
        Test.stopTest();
        
        SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('UPDATE', newJsonAccountString, oldJsonAccountString);
        }
        catch(Exception e) {
        
        }        
        
        } 
    }
    
    private static testMethod void doTestFive() { 
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
        try {
        generateData();             
        createAccount('RETS','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        Map<Id,String> newJsonAccountString = new Map<Id,String>();      
        
        subscription.Status__c = 'Active';
        update subscription;
             
        newJsonAccountString.put(subscription.id,JSON.serialize(subscription));
        SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('INSERT', newJsonAccountString, null);         
        }         
        catch(Exception e) {
        
        }   
        Test.stopTest();
        }      
    }
    
    private static testMethod void doTestSix() { 
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
        try {
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        Map<Id,String> newJsonAccountString = new Map<Id,String>();      
        
        subscription.Status__c = 'Active';
        update subscription;
             Test.stopTest();
        newJsonAccountString.put(subscription.id,JSON.serialize(subscription));
        SubscriptionUtility_New.sendSubscriptionToQueueProcessorOrig('INSERT', newJsonAccountString, null);         
        }         
        catch(Exception e) {
        
        }  
        
        }       
    }    
    
    private static void createAccount(String type,String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
    }
    
    private static void createContact(String accountId){
        contact = new Contact();
        contact.Email = 'email@something.com';
        //contact.FirstName = 'Test Class';
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
    }
    
    private Static void createSubscription(String accountId, String contactId){       
        subscription = new  Subscriptions__c();
        subscription.Name = 'Test Subscription';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.State__c = 'VA';
        subscription.County__c = 'Fairfax';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.County__c = 'Fairfax';
        subscription.Public_Email__c = 'test@test.com';
        subscription.NRDS_ID__c = 'test';
        subscription.Addl_Display_Name__c = 'test';
        subscription.Box__c = 'test';
        subscription.Mobile_Phone__c = '9032902323';
        subscription.Private_Email__c = 'test@test.com';
        subscription.Fax__c = '9032902323';
        subscription.Home_Fax__c = '9032902323';
        subscription.Primary_Phone__c = '9032902323';
        subscription.Agent_Office_Phone__c = '9032902323';
        subscription.Pager__c = '9032902323';
        //subscription.Street_Direction__c = 'N, NORTH';
        subscription.Street_Name__c = 'test';
        subscription.Street_Number__c = 'test';
        //subscription.Street_Type__c = 'SPRING, SPG';
        subscription.Unit__c = 'test';
        subscription.VM_Ext__c = 'test';
        subscription.Voicemail__c = '9032902323';
        subscription.Website__c = 'www.test.com';
        subscription.Zip_4__c = '2222';
        
        insert subscription;         
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }                   
}