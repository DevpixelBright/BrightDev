@istest(SeeAllData = true)
public class SMS_LateFeeWaiver_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;    

    private static testMethod void doTestOne() {
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ProductId', '2c92c0f941cc43f50141dcb56a3d24e6');
        preDefinedValues.put('ChargeAmount', '25');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        generateData();             
        createAccount('Residential','XYZ123');            
        createContact(account.Id);             
        createSubscription(account.Id, contact.Id);
        
        subscription.Related_Location_Broker_Office__c = account.Id; 
        subscription.Date_Waived__c = Date.today();
        update subscription;
        
        subscription.Status__c = 'Active';
        update subscription;
        
        try {
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        String invoiceItemQuery = 'SELECT Id,ChargeAmount,ChargeDate,InvoiceId,ProductName,ProductId FROM InvoiceItem WHERE Id = \'123\'';
        List<Zuora.zObject> zInvoiceItems = zUtilInstance.zquery(invoiceItemQuery);
        SMS_LateFeeWaiver.adjustLateFeeInvoice(zInvoiceItems[0], new Map<String, String> {(String)zInvoiceItems[0].getValue('InvoiceId') => 'testing'});
        }
        catch(Exception e) {
            
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
        subscription.State__c = 'VA';
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
}