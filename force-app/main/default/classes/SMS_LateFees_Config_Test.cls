@istest(seealldata=true)
public class SMS_LateFees_Config_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
   
    /* Test Scenario to test late fee assessment config page with success amend result */
    public static testMethod void doTestOne() {
 		
        /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);           

        subscription.Related_Location_Broker_Office__c = account.Id; 
        update subscription;         
        subscription.Status__c = 'Active';
        update subscription; 
        
        createBillingAccount(account.Id, account.Name, subscription.Name, subscription.Id); 
        
        Zuora__Subscription__c zSub = new Zuora__Subscription__c();
        zSub.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c81';
        zSub.Zuora__CustomerAccount__c = billingAccount.Id;
        zSub.IsCore__c = 'true';
        zSub.Zuora__TermStartDate__c = Date.today().addDays(-20);
        zSub.Zuora__TermEndDate__c = Date.today().addDays(10);
        insert zSub;
    
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2cttttt9014425f6c6472c80');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;         
 
        /* Create page reference */
        PageReference pageRef = Page.SMS_LateFees_Config;
        Test.setCurrentPageReference(pageRef); 
        
        SMS_LateFees_Config controller = new SMS_LateFees_Config();
        controller.editSetting();        

        List<SelectOption> hour = controller.Hour;
        List<SelectOption> minute = controller.Minute;
        List<SelectOption> meridiem = controller.Meridiem;        
        
        /* Saving settings with two different meridians */
        controller.isActive = true;
        controller.scheduleHour = '9';
        controller.scheduleMinute = '0';
        controller.scheduleMeridiem = 'PM';
        controller.saveSetting();
        
        controller.isActive = true;
        controller.scheduleHour = '12';
        controller.scheduleMinute = '0';
        controller.scheduleMeridiem = 'AM';
        controller.saveSetting();        
        
        /* Edit and save configuration for a particular day */
        SMS_Late_Fees_Config__c lateFee = [SELECT Id, Day_of_Week__c FROM SMS_Late_Fees_Config__c WHERE Day_of_Week__c = 'Friday' ];
           
        controller.editConfigId = lateFee.Id;
        controller.editConfig();
        controller.cancel();
        controller.editConfig();
        controller.saveConfig();
        
        /* Manual late fee assessment with failed ammendment result */
        controller.maximumAccounts = '10';
        controller.amount = '50';
        controller.days = '10';
        controller.runLateFeesAssessment();
        
		/* Test manual late fee assessment with null values */
        controller.maximumAccounts = '';
        controller.amount = '';
        controller.days = '';
        controller.runLateFeesAssessment();        
    }
    
    /* Test Scenario to test late fee assessment config page with failed amend result */
	public static testMethod void doTestTwo() {
 		
        /* Test data generation */
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);           

        subscription.Related_Location_Broker_Office__c = account.Id; 
        update subscription;         
        subscription.Status__c = 'Active';
        update subscription; 
        
        createBillingAccount(account.Id, account.Name, subscription.Name, subscription.Id); 
        
        Zuora__Subscription__c zSub = new Zuora__Subscription__c();
        zSub.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c81';
        zSub.Zuora__CustomerAccount__c = billingAccount.Id;
        zSub.IsCore__c = 'true';
        zSub.Zuora__TermStartDate__c = Date.today().addDays(-20);
        zSub.Zuora__TermEndDate__c = Date.today().addDays(10);
        insert zSub;
    
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', '2cttttt9014425f6c6472c80');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;         
 
        /* Create page reference */
        PageReference pageRef = Page.SMS_LateFees_Config;
        Test.setCurrentPageReference(pageRef); 
        
        SMS_LateFees_Config controller = new SMS_LateFees_Config();
                
        /*Manual late fee assessment with success ammendment result */ 
        SMS_ZuoraMockCall.isSuccess = false;
        controller.maximumAccounts = '10';
        controller.amount = '50';
        controller.days = '10';
        controller.runLateFeesAssessment();         
       
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
    
    private static void createBillingAccount(String accountId, String accountName, String subName, String subId) {
       
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subName;
        billingAccount.Subscription__c = subId;
        billingAccount.Oldest_Invoice_Due__c = Date.today().addDays(-20);
        billingAccount.LateFees_ChargeDate__c = Date.today().addDays(-20);
        insert billingAccount; 
    }         

}