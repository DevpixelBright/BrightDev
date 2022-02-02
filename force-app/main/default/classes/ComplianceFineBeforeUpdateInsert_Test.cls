@isTest
private class ComplianceFineBeforeUpdateInsert_Test {
   
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
        
        System.Debug('### sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];   
        
        Relationship__c relationshipOne = createRelationship(mainAccount.Id, relatedAccountOne.Id, 'Broker Of Record');
        insert relationshipOne;
        Relationship__c relationshipTwo = createRelationship(mainAccount.Id, relatedAccountTwo.Id, 'Office Manager'); 
        insert relationshipTwo;
        
        createComplianceAppealConfig();
        
        Compliance_Fine__c cf = new Compliance_Fine__c();
        cf.Name = '4323843-1';   
        cf.Subscription__c = subs[0].Id;
        cf.Subscription_ID__c = subs[0].Name;
        cf.Fine_Amount__c = 100;
        cf.Status__c = 'Pending';
        cf.QC_Fine_Code__c = 'CRDATA3000';
        cf.Bill_Now__c = true;
        insert cf;        
                                                        
    }
    
    private static testMethod void doTestTwo(){   
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
        
        System.Debug('### sub:' + subscription.Id + ',' + subscription.Name);
        
        List<Subscriptions__c> subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id];   
        
        Relationship__c relationshipOne = createRelationship(mainAccount.Id, relatedAccountOne.Id, 'Broker Of Record');
        insert relationshipOne;
        Relationship__c relationshipTwo = createRelationship(mainAccount.Id, relatedAccountTwo.Id, 'Office Manager'); 
        insert relationshipTwo;
        
        createComplianceAppealConfig();
        
        Compliance_Fine__c cf = new Compliance_Fine__c();
        cf.Name = '4323843-1';   
        cf.Subscription__c = subs[0].Id;
        cf.Subscription_ID__c = subs[0].Name;
        cf.Fine_Amount__c = 100;
        //cf.Status__c = 'Pending';
        cf.QC_Fine_Code__c = 'QCDATA1';
        cf.Date_of_Fine__c = System.today();
        insert cf; 
        
        cf.Bill_Now__c = true;
        update cf;       
                                                        
    }

    private static Account createAccount(String type,String name){
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
        //insert account; 
        
        return account;
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
        //insert contact; 
        
        return contact; 
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        //insert subscription; 
        
        return subscription;
    }
    
    private Static Relationship__c createRelationship(String accountId, String relatedAccountId, String type) {
    
        Relationship__c relationship = new Relationship__c();
        relationship.Relationship_Type__c = type;
        relationship.MDS_Status__c = 'Success';
        relationship.Broker_Office__c = accountId;
        relationship.Related_Account__c = relatedAccountId;
        //insert relationship; 
        
        return relationship;
    
    }
    
    private Static void createComplianceAppealConfig(){
        Compliance_Appeal_Config__c appealConfig = new Compliance_Appeal_Config__c();
        appealConfig.Appeal_Timer__c = 21;
        appealConfig.mail_days1__c = 7;
        appealConfig.mail_days2__c = 12;
        appealConfig.mail_days3__c = 18;
        appealConfig.Name = 'Test';
        insert appealConfig;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    }    
}