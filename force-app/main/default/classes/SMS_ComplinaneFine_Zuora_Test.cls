@istest(SeeAllData = true)
private class SMS_ComplinaneFine_Zuora_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;

    private static testMethod void doTestOne(){   
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        System.Debug('### sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];    
        
        Compliance_Appeal_Config__c config = new Compliance_Appeal_Config__c();
        config.Appeal_Timer__c = 20;
        config.mail_days1__c = 15;
        config.mail_days2__c = 20;
        config.mail_days3__c = 30;
        insert config;
        
        Compliance_Fine__c cf = new Compliance_Fine__c();
        cf.Name = '4323843-1';   
        cf.Subscription__c = subs[0].Id;
        cf.Subscription_ID__c = subs[0].Name;
        cf.Fine_Amount__c = 100;
        cf.Status__c = 'Pending';
        cf.QC_Fine_Code__c = 'CRDATA1';
        cf.Date_of_Fine__c = (System.now()).date();
        insert cf; 
        
        List<String> cfIds = new List<String> {cf.id}; 
        Database.executeBatch(new SMS_ComplinaneFine_Zuora(cfIds),5); 
        
        SMS_ZuoraMockCall.isSuccess = false;
        Database.executeBatch(new SMS_ComplinaneFine_Zuora(cfIds),5);
        
        Map<String, Boolean> zObjectsEmpty = new Map<String, Boolean>();
        zObjectsEmpty.put('Account', true);
        
        SMS_ZuoraMockDataGenerator.zObjectEmptyResult = zObjectsEmpty;
        Database.executeBatch(new SMS_ComplinaneFine_Zuora(cfIds),5); 
        
        zObjectsEmpty = new Map<String, Boolean>();
        zObjectsEmpty.put('Subscription', true);
        
        SMS_ZuoraMockDataGenerator.zObjectEmptyResult = zObjectsEmpty;
        Database.executeBatch(new SMS_ComplinaneFine_Zuora(cfIds),5);
        
        zObjectsEmpty = new Map<String, Boolean>();
        zObjectsEmpty.put('Product', true);
        
        SMS_ZuoraMockDataGenerator.zObjectEmptyResult = zObjectsEmpty;
        Database.executeBatch(new SMS_ComplinaneFine_Zuora(cfIds),5); 
                                                        
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
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }    
}