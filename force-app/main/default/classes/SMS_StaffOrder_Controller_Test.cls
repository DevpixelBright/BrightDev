@istest(SeeAllData = true)
private class SMS_StaffOrder_Controller_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static Relationship__c relationship;

    private static testMethod void doTestOne(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
                
        subscription.Status__c = 'Active';
        update subscription;  
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'CloudCMA');
        preDefinedValues.put('ChargeType', 'OneTime');
        preDefinedValues.put('Id', '2ed984orkerlj');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;     
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_StaffOrder_Preview;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);  
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        SMS_StaffOrder_Controller controller = new SMS_StaffOrder_Controller();  
        SMS_StaffOrder_Controller.CartItem cartItem = new SMS_StaffOrder_Controller.CartItem(); 
        controller.cartItems = new List<SMS_StaffOrder_Controller.CartItem>();      
        controller.zProductId = '2mnsklfj728496fe';
        controller.zRecurringProductRatePlanId = '2ed984orkerlj';      
        controller.populateProductRatePlans(); 
        controller.addToCart(); 
        controller.confirm();
         
        cartItem.check = true; 
        controller.cartItems.add(cartItem);
        controller.removeFromCart();
        controller.cancel();   
    }
    
    private static testMethod void doTestTwo(){   
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_StaffOrder_Preview;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        SMS_StaffOrder_Controller controller = new SMS_StaffOrder_Controller();          
          
    }
    
    private static testMethod void doTestThree(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
               
        subscription.Status__c = 'Active';
        update subscription; 
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'CloudCMA');
        preDefinedValues.put('Id', '2mnsklfj728496fe');
        preDefinedValues.put('BillingPeriod', 'Two Years');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;         
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_StaffOrder_Preview;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);  
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        SMS_StaffOrder_Controller controller = new SMS_StaffOrder_Controller();
        SMS_StaffOrder_Controller.CartItem cartItem = new SMS_StaffOrder_Controller.CartItem(); 
        controller.cartItems = new List<SMS_StaffOrder_Controller.CartItem>();             
        controller.zProductId = '2mnsklfj728496fe';
        controller.zRecurringProductRatePlanId = '2ed984orkerlj';        
        controller.populateProductRatePlans(); 
        controller.addToCart(); 
        controller.confirm();
        controller.removeFromCart();
        controller.cancel();   
    }
    
    private static testMethod void doTestFour(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
          subscription.Service_Jurisdiction__c='MRIS';
             
        subscription.Status__c = 'Active';
        update subscription; 
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_StaffOrder_Preview;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);  
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', null);
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        SMS_StaffOrder_Controller controller = new SMS_StaffOrder_Controller(); 
        SMS_StaffOrder_Controller.CartItem cartItem = new SMS_StaffOrder_Controller.CartItem(); 
        controller.validateCartItem(cartItem);
        controller.confirm();
          
    }
    
    private static testMethod void doTestFive(){
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
               
        subscription.Status__c = 'Active';
        
        
        update subscription; 
        
        createRelationship(account.Id, contact.Id, subscription.Id);
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_StaffOrder_Preview;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subscription.Id);  
        ApexPages.currentPage().getParameters().put('iframeDomain', 'https://mrisonboarding.cs9.force.com'); 
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Name', 'Promotions');
        preDefinedValues.put('Id', '2mnsklfj728496fe');
        preDefinedValues.put('BillingPeriod', 'Two Years');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        SMS_StaffOrder_Controller controller = new SMS_StaffOrder_Controller(); 
        //SMS_StaffOrder_Controller.CartItem cartItem = new SMS_StaffOrder_Controller.CartItem(); 
        //controller.validateCartItem(cartItem);
        //controller.confirm();
          
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
        //account.Primary_Service_Jurisdiction__c = 'BRIGHT';
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
        
        subscription.Service_Jurisdiction__c = ' MRIS';
        
       // subscription.Service_jurisdiction__c='MRIS';
        //;
       // 
        
        
   
         insert subscription; 
        
    }
    private static void  meth(){
       
       //string  Zuora_Product_Name__c ,orderitem;
   
       subscription.Service_Jurisdiction__c='TREND';
       subscription.Service_Jurisdiction__c='BRIGHT';
     // orderitem.Zuora_Product_Name__c='Xactsite';
   }
        //subscription.Private_Email__c =  'abc@test.com';
       
    
    
    private Static void createRelationship(String accountId, String contactId, String subscriptionId){
        relationship = new  Relationship__c();
        //realtionship.Name = '12345678';
        relationship.Contact__c = contact.id;
        relationship.Broker_Office__c = account.id;
        relationship.Relationship_Type__c = 'Broker of Record';
        relationship.Subscription__c = subscriptionId;
        insert relationship;
    }
   
    
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }    

}