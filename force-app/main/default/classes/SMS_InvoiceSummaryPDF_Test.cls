@istest
private class SMS_InvoiceSummaryPDF_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;

    private static testMethod void doTestOne(){

        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);           
             
        
        subscription.Related_Location_Broker_Office__c = account.Id; 
        update subscription;         
        subscription.Status__c = 'Active';
        update subscription; 
        
        Id id = createBillingAccount(account.Id, account.Name, subscription.Name, 200); 
        System.Debug('### billingAccount : ' + billingAccount);
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Balance', '23');
        preDefinedValues.put('Status', 'Processed');
        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 2;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        

        SMS_InvoiceSummaryPDF obj = new SMS_InvoiceSummaryPDF();
        obj.recordId = id;
        String d = obj.getStatementDate();
        SMS_InvoiceSummaryPDF.AccountSummary a = obj.getInvoiceResult();
        
        SMS_InvoiceSummaryPDF.InvoiceItemAdjustment iia = new SMS_InvoiceSummaryPDF.InvoiceItemAdjustment();
        iia.Id = '345324534';
        iia.Amount = 10.2;
        iia.Comment = 'comment';
        iia.ReasonCode = 'code';
        iia.InvoiceNumber = 'INV0001';
        iia.InvoiceId = '3254dsrgfd';
        iia.ServiceStartDate = DateTime.Now();
        iia.ServiceEndDate = DateTime.Now();
        iia.Type = 'test'; 
        
        SMS_InvoiceSummaryPDF.CreditBalanceAdjustment cba = new SMS_InvoiceSummaryPDF.CreditBalanceAdjustment();
        cba.id = '4354354';
        cba.amount = 11.2;
        cba.invoiceNumber = 'INV0001';
        cba.invoiceId = 'fdgfd56546';
        cba.adjustmentDate = DateTime.Now();
        cba.comment = 'comment';
        cba.reasonCode = 'code';
        cba.type = 'type';
        
        SMS_InvoiceSummaryPDF.InvoiceItem ii = new SMS_InvoiceSummaryPDF.InvoiceItem();
        ii.id = '34543';
        ii.subscriptionName = 'S-00004';
        ii.subscriptionId = 'fdfsd4354';
        ii.serviceStartDate = '03/12/2015';
        ii.serviceEndDate = '03/12/2015';
        ii.chargeAmount = 34.5;
        ii.chargeDescription = 'test';
        ii.chargeName = 'test';
        ii.chargeId = 'sdgdfgf';
        ii.productName = 'test';
        ii.quantity = 2;
        ii.taxAmount = 10;
        ii.unitOfMeasure = 'test';
        ii.isRemoval = false;
        
        SMS_InvoiceSummaryPDF.Invoice i = new SMS_InvoiceSummaryPDF.Invoice();
        i.id = '23432';
        i.accountId = '32432';
        i.accountNumber = '34534';
        i.accountName = 'test';
        i.invoiceDate = DateTime.Now();
        i.invoiceNumber = 'INV00001';
        i.dueDate = '03/12/2015';
        i.invoiceTargetDate = DateTime.Now(); 
        i.amount = 200; 
        i.balance = 200;
        i.createdBy = 'sfdsfd';
        i.status = 'Active';
        i.invoiceItems = new List<SMS_InvoiceSummaryPDF.InvoiceItem> {ii};
        i.invoiceItemAdjustments = new List<SMS_InvoiceSummaryPDF.InvoiceItemAdjustment> {iia};
        i.creditBalanceAdjustments = new List<SMS_InvoiceSummaryPDF.CreditBalanceAdjustment> {cba};
        
        SMS_InvoiceSummaryPDF.AccountSummary asum = new SMS_InvoiceSummaryPDF.AccountSummary();
        asum.Id = '45654';
        asum.Name = 'test';
        asum.CreditBalance = 30; 
        asum.SubscriptionID = 'dsfd';
        asum.Balance = 20;
        asum.TotalInvoiceBalance = 20; 
        asum.AccountNumber = '4354';
        asum.invoices = new List<SMS_InvoiceSummaryPDF.Invoice> {i};         
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

        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static Id createBillingAccount(String accountId, String accountName, String subId, Decimal balance) {
       
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subId;
        billingAccount.Oldest_Invoice_Due__c = system.today().addDays(-5);
        billingAccount.Zuora__Balance__c = balance;
        billingAccount.Invoice_REST_Response__c = '{"TotalInvoiceBalance":920,"SubscriptionID":"3052634","Name":"SMS Test 27 - MAR ONE","invoices":[{"status":"Posted","invoiceTargetDate":"2015-03-26T22:20:03.000Z","invoiceNumber":"INV00002638","invoiceItems":[{"unitOfMeasure":null,"taxAmount":165.00,"subscriptionName":"A-S00001728","subscriptionId":null,"serviceStartDate":"03/25/2015","serviceEndDate":"06/24/2015","quantity":null,"productName":"Core Service","isRemoval":false,"id":"2c92c0f84c510073014c59ac44270e22","chargeName":"Quarterly Subscription Fee","chargeId":null,"chargeDescription":"Quarterly Subscription Fee","chargeAmount":165.00},{"unitOfMeasure":null,"taxAmount":295.00,"subscriptionName":"A-S00001728","subscriptionId":null,"serviceStartDate":"03/25/2015","serviceEndDate":"03/25/2015","quantity":null,"productName":"Core Service","isRemoval":false,"id":"2c92c0f84c510073014c59ac44270e23","chargeName":"Initial Fee","chargeId":null,"chargeDescription":"Initial Fee","chargeAmount":295.00}],"invoiceItemAdjustments":[],"invoiceDate":"2015-03-26T22:20:03.000Z","id":"2c92c0f84c510073014c59ac441e0e20","dueDate":"03/26/2015","creditBalanceAdjustments":[],"createdBy":"2c92c0f83fa14084013fba9191c56f9d","balance":920.00,"amount":920.00,"accountNumber":"3052634","accountName":"SMS Test 27 - MAR ONE","accountId":"2c92c0f84c5100b6014c59abefa653eb"}],"Id":"2c92c0f84c5100b6014c59abefa653eb","CreditBalance":0,"Balance":920,"AccountNumber":"3052634"}';
        insert billingAccount; 
        
        return billingAccount.Id;
    }     

}