@istest
private class CaseLinkerBatch_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;

    private static testMethod void doTestOne(){
        
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id); 
        
        List<Case> caseList =  new List<case>();        
        
        Case ca = new Case();
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = contact.Id;
        ca.SuppliedEmail = 'test@test.com';
        caseList.add(ca);   
        
        Case ca1 = new Case();
        ca1.Origin = 'Email'; 
        ca1.Description='from unit test';
        ca1.Subject ='testing trigger';
        ca1.Status='New';
        ca1.SuppliedEmail = 'srinivas.rao@bltglobalventures.com';
        //ca1.SuppliedEmail = 'test@test.com';
        caseList.add(ca1); 
        
        CaseLinkerBatch caseLinkObj = new CaseLinkerBatch();
        caseLinkObj.process(caseList);                            
        
    }
    
    private static testMethod void doTestTwo(){
        
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id); 
        
        Subscriptions__c subscription2 = new  Subscriptions__c();
        subscription2.Contact__c = contact.id;
        subscription2.Subscription_Type__c = 'Realtor/Shareholder';
        subscription2.Status__c = 'In Progress';
        subscription2.City__c = 'Herndon';
        subscription2.Zip__c = '20171';
        subscription2.County__c = 'Fairfax';
        subscription2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription2.County__c = 'Fairfax';
        subscription2.Related_Location_Broker_Office__c = account.id;
        subscription2.Contact_Type__c = 'Agent';
        subscription2.Primary__c = false;
        subscription2.Public_Email__c = 'srinivas.rao@bltglobalventures.com';
        insert subscription2;         
        
        List<Case> caseList =  new List<case>();        
               
        Case ca = new Case();
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = contact.Id;
        ca.SuppliedEmail = 'test@test.com';
        caseList.add(ca);          
        
        Case ca1 = new Case();
        ca1.Origin = 'Email'; 
        ca1.Description='from unit test';
        ca1.Subject ='testing trigger';
        ca1.Status='New';
        ca1.SuppliedEmail = 'srinivas.rao@bltglobalventures.com';
        caseList.add(ca1); 
        
        CaseLinkerBatch caseLinkObj = new CaseLinkerBatch();
        caseLinkObj.process(caseList);                            
        
    }
    
    private static testMethod void doTestThree(){
 
        List<Case> caseList =  new List<case>();        
               
        Case ca1 = new Case();
        ca1.Origin = 'Email'; 
        ca1.Description='from unit test';
        ca1.Subject ='testing trigger';
        ca1.Status='New';
        ca1.SuppliedEmail = 'srinivas.rao@bltglobalventures.com';
        caseList.add(ca1); 
        
        CaseLinkerBatch caseLinkObj = new CaseLinkerBatch();
        caseLinkObj.process(caseList);        
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
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Primary__c = true;
        subscription.Public_Email__c = 'srinivas.rao@bltglobalventures.com';
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}