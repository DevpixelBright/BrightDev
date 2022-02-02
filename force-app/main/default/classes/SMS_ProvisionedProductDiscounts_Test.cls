@isTest(seeAllData = true)
public class SMS_ProvisionedProductDiscounts_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Zuora__CustomerAccount__c billingAccount;
    
    private static testMethod void doTestOne(){    
        SMS_ZuoraMockDataGenerator.zNumOfResults = 0; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update  subscription;
        
        /* String zProductRatePlanId = '2cdft45236ehwrf3j2oi';
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ProductRatePlanId', zProductRatePlanId);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;      
        createProvisionProduct(subscription.Name, zProductRatePlanId);*/
        
        //SMS_ZuoraMockDataGenerator.emptyResult = true;
        String zProductRatePlanId = '2cdft45236ehwrf3j2oi';
        SMS_Provisioned_Product__c prov1 = createProvisionProduct(subscription.Id, zProductRatePlanId);
        prov1.Provisioned_Status__c = 'Provisioned';
        update prov1;
        SMS_Provisioned_Product_Discounts controller = new SMS_Provisioned_Product_Discounts();
        SMS_Provisioned_Product__c p1 = [SELECT Id, Name, MRIS_Subscription_Id__c, Provisioned_Status__c, Product_Sub_Type__c, Product_Type__c, Zuora_Product_Id__c, Zuora_Product_Rate_Plan_Id__c FROM SMS_Provisioned_Product__c WHERE Id =: prov1.Id];
        
        
       // PROV_MockDataGenerator.isSuccess = true;
        String zDiscountRateplanId = '2cdft45236ehwrf3j2op';
        String zDiscountRateplanChargeId = '2cdft45236ehwrui3j2l';
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('SubscriptionID__c', subscription.Name);
        preDefinedValues.put('Id', '254dksjfhsdkj');
        preDefinedValues.put('Status', 'Processed');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues; 
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1;
        SMS_ZuoraMockCall.isSuccess = true;
        try{
        	SMS_Provisioned_Product_Discounts.applyDiscount(zDiscountRateplanId, zDiscountRateplanChargeId, prov1.Id);    
        }catch(Exception ex){}
        try{
        	SMS_Provisioned_Product_Discounts.getProductRatePlans(prov1.Id, 'Provisioned', 'Authentisign');
        }catch(Exception ex){}
        SMS_Provisioned_Product_Discounts.getNewProductAmendmentRequest(zDiscountRateplanId, zDiscountRateplanChargeId, '2020-02-13');
        
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
        subscription.State__c = 'VA';
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
    
    private static void createBillingAccount(String accountId, String accountName, String subId, Decimal balance) {
       
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = accountId;
        billingAccount.Name = accountName;
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.SubscriptionID__c  = subId;
        billingAccount.Oldest_Invoice_Due__c = system.today().addDays(-5);
        billingAccount.Zuora__Balance__c = balance;
        insert billingAccount; 
    }
    
	private static SMS_Provisioned_Product__c createProvisionProduct(String subscriptionId, String zProductRatePlanId) {
        SMS_Provisioned_Product__c provisionProduct = new SMS_Provisioned_Product__c();
        provisionProduct.MRIS_Subscription_Id__c = subscriptionId;
        provisionProduct.Product_Type__c = 'Authentisign';
        provisionProduct.Product_Sub_Type__c = 'Authentisign';
        provisionProduct.Product_Status__c = 'New';
        provisionProduct.Provisioned_Status__c = 'Pending Provisioned';
        provisionProduct.RealPing_Id__c = '20586';
        provisionProduct.Zuora_Product_Rate_Plan_Id__c = zProductRatePlanId;

        insert provisionProduct;
        
        return provisionProduct;
    }
}