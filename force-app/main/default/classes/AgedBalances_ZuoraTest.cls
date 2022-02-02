@isTest(seealldata=true)
public class AgedBalances_ZuoraTest {
	private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    public static void createcustomSetting(){
        Aged_Balances__c age = new Aged_Balances__c();
        age.Name = 'Aged2';
        age.Zuora_Product_Id__c = '8ad08c0f7c3580da017c35e087603377';
        age.Zuora_Product_Rate_Plan_Charge_Id__c = '8ad08c0f7c3580da017c35e1d32440c3';
        age.Zuora_Product_Rate_Plan_Id__c = '8ad0965d7c358b11017c35e142985dae';
        insert age;
    }
    
        public static testMethod void doTestOne() {
        createcustomSetting();
        generateCornerstone();             
        createAccount('Residential','XYZABC123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Inactive';
        update subscription;   
        
        String zProductRatePlanId = '2cdft45236ehwrf3j2oi';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('zAgedInvoiceNumbers', 'INV00012345');
        preDefinedValues.put('CreditBalance', '150.25');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;      
        
        List<String> invIds = new List<String>{'INV00012345'};
		AgedBalances_Zuora agedBal = new AgedBalances_Zuora(invIds);
        
        
        agedBal.addToCreditBalance('invoiceId');
        agedBal.applyCreditBalance('invoiceId', 150.25);
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
        subscription.Subscription_Type__c = 'Personal Assistant';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}