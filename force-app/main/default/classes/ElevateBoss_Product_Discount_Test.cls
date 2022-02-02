@isTest(seeAllData = true)
public class ElevateBoss_Product_Discount_Test {
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

        String zProductRatePlanId = '2cdft45236ehwrf3j2oi';
        EB_ProductOrder__c eboss1 = createEBossProduct(subscription.Id, zProductRatePlanId);
        eboss1.ProductStatus__c = 'New';
        update eboss1;
        ElevateBoss_Product_Discounts controller = new ElevateBoss_Product_Discounts();
        EB_ProductOrder__c e1 = [SELECT Id, Name, ProductStatus__c, ProductType__c, ZProductId__c, ZOneTimeRatePlanId__c, ZRecurringRatePlanId__c FROM EB_ProductOrder__c WHERE Id =: eboss1.Id];
        
        
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
        	ElevateBoss_Product_Discounts.applyDiscount(zDiscountRateplanId, zDiscountRateplanChargeId, eboss1.Id);    
        }catch(Exception ex){}
        try{
        	ElevateBoss_Product_Discounts.getProductRatePlans(eboss1.Id, 'New', 'Elevate BOSS by Bright MLS');
        }catch(Exception ex){}
        ElevateBoss_Product_Discounts.getNewProductAmendmentRequest(zDiscountRateplanId, zDiscountRateplanChargeId, '2020-02-13');
        
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
    
	private static EB_ProductOrder__c createEBossProduct(String subscriptionId, String zProductRatePlanId) {
        EB_ProductOrder__c ebossProduct = new EB_ProductOrder__c();
        ebossProduct.Subscription__c = subscriptionId;
        ebossProduct.ProductType__c = 'Elevate BOSS by Bright MLS';
        ebossProduct.ProductStatus__c = 'New';
        ebossProduct.ZRecurringRatePlanId__c = zProductRatePlanId;

        insert ebossProduct;
        
        return ebossProduct;
    }
}