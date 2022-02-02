@istest(seealldata = true)
private class SMS_SecondaryCredits_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount; 
    private Static Zuora__ZInvoice__c zInvoice;    
    
    private static testMethod void doTestOne() {
    
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        Subscriptions__c primarySub = createSubscription(account.Id, contact.Id, true, '1234');
        //Subscriptions__c secondarySub = createSubscription(account.Id, contact.Id, true, '4568');
        Subscriptions__c secondarySub = new  Subscriptions__c();
        secondarySub.Name = '45678';
        secondarySub.Contact__c = contact.id;
        secondarySub.Subscription_Type__c = 'Realtor/Shareholder';
        secondarySub.Status__c = 'In Progress';
        secondarySub.City__c = 'Alexandria';
        secondarySub.State__c = 'VA';
        secondarySub.Zip__c = '20171';
        secondarySub.County__c = 'Fairfax';
        secondarySub.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        secondarySub.AgentKey__c = '123111';
        secondarySub.name = '123111';
        secondarySub.County__c = 'Fairfax';
        secondarySub.Related_Location_Broker_Office__c = account.id;
        secondarySub.Contact_Type__c = 'Agent';
        secondarySub.Primary__c = false;
        insert secondarySub;
                
        Zuora__CustomerAccount__c billingAccount1 = createBillingAccount(account.Id, account.Name, primarySub.Id, 100);
        Zuora__CustomerAccount__c billingAccount2 = createBillingAccount(account.Id, account.Name, secondarySub.Id, 100);
        createzInvoice(billingAccount1.Id);
        createzInvoice(billingAccount2.Id);
                
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '45345wWseferr34sfdf');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        SMS_SecondaryCredits obj = new SMS_SecondaryCredits();
        List<SMS_SecondaryCredits.SecondaryCredit> scList = new List<SMS_SecondaryCredits.SecondaryCredit>();
        SMS_SecondaryCredits.SecondaryCredit obj2 = new SMS_SecondaryCredits.SecondaryCredit();
        obj2.primaryId = primarySub.Name;
        obj2.primaryStatus = 'Active';
        obj2.primaryContact = 'Test';
        obj2.secondaryId = secondarySub.Name;
        obj2.secondaryStatus = 'Active';
        obj2.secondaryContact = 'Test';
        obj2.zPrimaryAccountId = '45345wWseferr34sfdf';
        obj2.zSecondaryAccountId = '45345wWssdfr34sfdf';
        obj2.credits = 100;
        obj2.creditBalance = 0;
        obj2.invoiceBalance = 100;
        obj2.isValid = true;
        obj2.isSelected = true;
        obj2.isTransfered = false;
        obj2.isReceived = false;
        obj2.isConverted = false;
        obj2.zPrimaryInvoiceId = '34522sfdsfdsf534578';
        obj2.zSecondaryInvoiceId = '34573sfdsfdsf534578';
        obj2.notes = 'test';
        scList.add(obj2);
        
        String str = JSON.serialize(scList); 
        obj.secondaryCreditsJson = str;
        try {
            obj.test();
        }
        catch(Exception e) {
        
        }
        obj.processZInvoices();        
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
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, Boolean isPrimary, String name){
        subscription = new  Subscriptions__c();
        subscription.Name = name;
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Primary__c = isPrimary;
        subscription.Private_Email__c = 'test@test.com';
        subscription.Public_Email__c = 'test@test.com';
        insert subscription;
        
        return subscription;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static Zuora__CustomerAccount__c createBillingAccount(String accountId, String accountName, String subId, Decimal balance) {       
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '45345wWseferr34sfdf';
        billingAccount.SubscriptionID__c  = subId;
        billingAccount.Subscription__c = subId;
        billingAccount.Oldest_Invoice_Due__c = system.today().addDays(-5);
        billingAccount.Zuora__Balance__c = balance;
        billingAccount.Zuora__Credit_Balance__c = balance;
        insert billingAccount;
        
        return billingAccount;
    }
    
    private static void createzInvoice(String billingAccountId) {
        zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Zuora__Zuora_Id__c = '45345wWseferr34sfdf';
        zInvoice.Zuora__Balance2__c = -400;
        zInvoice.Zuora__TotalAmount__c = -400;
        zInvoice.Zuora__BillingAccount__c = billingAccountId;
        insert zInvoice;
    }
}