@istest(SeeAllData=true)
public class SMS_GenericPaymentProcess_Test {
    
    private static SMS_Order__c order;
    private static SMS_OrderItem__c  orderItem;
    private static String token;
    
    /* Scenario: Test method to complete generic payment process with new payment method */
    public static testMethod void doTestOne() {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('ApplyDiscountTo', null);
            preDefinedValues.put('ChargeType', 'Recurring');
            preDefinedValues.put('ProductId', '2c92c0f93fd531f1013ff29cc48a55e2');
            preDefinedValues.put('ProductRatePlanId', '2c92c0f941ba98200141c7a64e7f394d');
            preDefinedValues.put('IsCore__c','True');
            SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;   
            
            /* Test data generation */
            createOrderWithSingleOrderItem();
            
            /* Create page reference */
            PageReference pageRef = Page.SMS_GenericPaymentProcess;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('token', token);  
            SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
            
            /* Method calls to complete generic payment process */
           
            controller.previewInvoice();
            controller.loadPreviewPage();
            controller.loadPaymentPage(); 
            controller.enterNewPaymentMethod(); 
            ApexPages.currentPage().getParameters().put('id', 'SDFDSF345345SDFDS');
            ApexPages.currentPage().getParameters().put('save', 'true'); 
            ApexPages.currentPage().getParameters().put('use_as_default', 'true');  
                      
            controller.chargeNewPaymentMethod();  
            controller.completeOrder(); 
            controller.updateAutoPayPaymentMethod(); 
            controller.generateBaselineInvoice();
            controller.confirmBaselineInvoice();
            controller.printReceipt();
        }
        
    }
     /* Scenario: To test complete generic payment process by selecting existing payment method */
    public static testMethod void doTestTwo() {
        
        /* Test data generation */
        createOrderWithSingleOrderItem();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('token', token);  
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
        
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('CreditCardExpirationMonth', '11');
        preDefinedValues.put('CreditCardExpirationYear', '2025');
        preDefinedValues.put('Status', 'Processed');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        /* Preview invoice */
        controller.previewInvoice();
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        preDefinedValues.put('Id', 'SDFDSF345345SDFDS');
        controller.loadPaymentPage(); 
        
        /* Load payment page and choose existing payment method */
        PageReference pageRef2 = Page.SMS_GenericPayment_HPM;
        Test.setCurrentPage(pageRef2);        
        
        controller.chooseExistingPaymentMethod();
        ApexPages.currentPage().getParameters().put('id', 'SDFDSF345345SDFDS');
        
        controller.selectPaymentMethod();
        ApexPages.currentPage().getParameters().put('use_as_default', 'true'); 
        controller.chargePayment(); 
        ApexPages.currentPage().getParameters().put('message', 'HostedPageFieldValidationError=HostedPageFieldValidationError<br>HostedPageFieldValidationError=HostedPageFieldValidationError<br>errorField_creditCardType=Card Type');
        controller.paymentMethodFailed();
        ApexPages.currentPage().getParameters().put('message', 'GatewayTransactionError=GatewayTransactionError<br>GatewayTransactionError=GatewayTransactionError');
        controller.paymentMethodFailed();
         ApexPages.currentPage().getParameters().put('message', 'Invalid_Security=Invalid_Security<br>Invalid_Security=Invalid_Security');
        controller.paymentMethodFailed();
        ApexPages.currentPage().getParameters().put('message', 'Invalid Card=Invalid Card<br>Invalid Card=Invalid Card');
        controller.paymentMethodFailed();
         ApexPages.currentPage().getParameters().put('message', 'Invalid Card=Invalid Card');
        controller.paymentMethodFailed();
       controller.markOrderAsCancelled();  
    }
    
    /* Scenario: To test generic payment process without passing token reference */
    public static testMethod void doTestThree() {
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('token', '');
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();   
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();           
    }    
    
    /* Scenario: To populate conflicting subscriptions */
    public static testMethod void doTestFour() {       
        
        /* Test data generation */        
        createOrderWithMultipleOrderItems();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ApplyDiscountTo', null);
        preDefinedValues.put('ChargeType', 'Recurring');
        preDefinedValues.put('ProductId', '2c92c0f841ba8ff60141c7888e5b68b4');
        preDefinedValues.put('ProductRatePlanId', '2c92c0f941ba98200141c7a64e7f394d');
        preDefinedValues.put('IsCore__c','True');
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        ApexPages.currentPage().getParameters().put('token', token);
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller(); 
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();             
    }       
    
    /* Scenario: To populate existing invoices */
    public static testMethod void doTestFive() {
        
        /* Test data generation */     
        createOrderWithoutOrderItems();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
         /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ApplyDiscountTo', null);
        preDefinedValues.put('ChargeType', 'Recurring');
        preDefinedValues.put('Balance', null);
        preDefinedValues.put('TaxAmount', '10');
        preDefinedValues.put('IsCore__c','True');
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        ApexPages.currentPage().getParameters().put('token', token);
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();            
    }
    
    public static testMethod void doTestSix() {
        
        /* Test data generation */     
        createOrderWithSingleOrderItem1();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
         /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ApplyDiscountTo', null);
        preDefinedValues.put('ChargeType', 'Recurring');
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        ApexPages.currentPage().getParameters().put('token', token);
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();   
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();           
    } 
    
    /* Scenario: To populate conflicting subscriptions */
    public static testMethod void doTestSeven() {       
        
        /* Test data generation */        
        createOrderWithMultipleOrderItems();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ApplyDiscountTo', null);
        preDefinedValues.put('ChargeType', 'Recurring');
        preDefinedValues.put('ProductId', '2c92c0f841ba8ff60141c7888e5b68b4');
        preDefinedValues.put('ProductRatePlanId', '2c92c0f941ba98200141c7a64e753df4');        
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        ApexPages.currentPage().getParameters().put('token', token);
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller(); 
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();             
    }  
    
    public static testMethod void doTestEight() {
        
        /* Test data generation */
        createOrderWithSingleOrderItem1();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('token', token);  
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
        
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('CreditCardExpirationMonth', '11');
        preDefinedValues.put('CreditCardExpirationYear', '2016');
        preDefinedValues.put('Status', 'Processed');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        
        
        /* Preview invoice */
        controller.previewInvoice();
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        preDefinedValues.put('Id', 'SDFDSF345345SDFDS');
        controller.loadPaymentPage(); 
        
        /* Load payment page and choose existing payment method */
        PageReference pageRef2 = Page.SMS_GenericPayment_HPM;
        Test.setCurrentPage(pageRef2);        
        
        controller.chooseExistingPaymentMethod();
        ApexPages.currentPage().getParameters().put('id', 'SDFDSF345345SDFDS');
        
        controller.selectPaymentMethod();
        ApexPages.currentPage().getParameters().put('use_as_default', 'true'); 
        controller.chargePayment(); 
        ApexPages.currentPage().getParameters().put('message', 'HostedPageFieldValidationError=HostedPageFieldValidationError<br>HostedPageFieldValidationError=HostedPageFieldValidationError<br>errorField_creditCardType=Card Type');
        controller.paymentMethodFailed();
        controller.markOrderAsCancelled();  
    }
       
   
    public static testMethod void doTestNine() {
             
        /* Test data generation */
        createOrderWithSingleOrderItem();
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('token', token);  
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
        
        /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
       preDefinedValues.put('CreditCardExpirationMonth', '11');
        preDefinedValues.put('CreditCardExpirationYear', '2025');
        preDefinedValues.put('Status', 'New');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        /* Preview invoice */
        controller.previewInvoice();
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        preDefinedValues.put('Id', 'SDFDSF345345SDFDS');
        controller.loadPaymentPage(); 
        
        /* Load payment page and choose existing payment method */
        PageReference pageRef2 = Page.SMS_GenericPayment_HPM;
        Test.setCurrentPage(pageRef2);        
        
        controller.chooseExistingPaymentMethod();
        controller.chargeNewPaymentMethod();  
        ApexPages.currentPage().getParameters().put('id', 'SDFDSF345345SDFDS');
        
        controller.selectPaymentMethod();
        ApexPages.currentPage().getParameters().put('use_as_default', 'true'); 
        controller.chargePayment(); 
        ApexPages.currentPage().getParameters().put('message', 'HostedPageFieldValidationError=HostedPageFieldValidationError<br>HostedPageFieldValidationError=HostedPageFieldValidationError<br>errorField_creditCardType=Card Type');
        controller.paymentMethodFailed();
        ApexPages.currentPage().getParameters().put('message', 'GatewayTransactionError=GatewayTransactionError<br>GatewayTransactionError=GatewayTransactionError');
        controller.paymentMethodFailed();
         ApexPages.currentPage().getParameters().put('message', 'Invalid_Security=Invalid_Security<br>Invalid_Security=Invalid_Security');
        controller.paymentMethodFailed();
        ApexPages.currentPage().getParameters().put('message', 'Invalid Card=Invalid Card<br>Invalid Card=Invalid Card');
        controller.paymentMethodFailed();
         ApexPages.currentPage().getParameters().put('message', 'Invalid Card=Invalid Card');
        controller.paymentMethodFailed();
       controller.markOrderAsCancelled();    
    } 
     public static testMethod void doTestTen() {
        
        /* Test data generation */     
        createOrderWithMultipleOrderItems();
        
        
        /* Create page reference */
        PageReference pageRef = Page.SMS_GenericPaymentProcess;
        Test.setCurrentPage(pageRef);
        
         /* Setting up predefined values to retrieve from zuora mock data generator */
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('ApplyDiscountTo', null);
        preDefinedValues.put('ChargeType', 'Recurring');
        preDefinedValues.put('CreditBalance', '100');
         preDefinedValues.put('Balance', '100');
        preDefinedValues.put('TaxAmount', '0.5');
         preDefinedValues.put('IsCore__c','True');
        SMS_ZuoraMockDataGenerator.zNumOfResults = 3;
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;        
        
        ApexPages.currentPage().getParameters().put('token', token);
        SMS_GenericPaymentProcess_Controller controller = new SMS_GenericPaymentProcess_Controller();  
         controller.previewInvoice();
        controller.chargeNewPaymentMethod();  
        controller.completeOrder(); 
        controller.updateAutoPayPaymentMethod(); 
        controller.generateBaselineInvoice();
        controller.confirmBaselineInvoice();
        controller.printReceipt();  
         
        
    }
    
    private static void createOrderWithSingleOrderItem1() {
    
        Subscriptions__c subscription = [SELECT Id, Name FROM Subscriptions__c LIMIT 1];   
    
        /* Create test data for SMS_Order__c */
        order = new SMS_Order__c();                
        order.Name = 'Order Id';
        order.Token__c = '';
        order.Zuora_Account_Id__c = '2c92c0f943dcac3d0143f8623e080192';
        order.MRIS_Subscription_Id__c = subscription.Id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = false;
        
        insert order;
           
        String salt = String.valueOf(order.id);
        String secretKey = 'secret_key';
        String algorithmName = 'HmacSHA256';
        
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
        token = EncodingUtil.base64Encode(hmacData);
        
        order.Token__c = token;
        order.Name = order.id;
        update order;
        
        /* Order Items test data */
        orderItem = new SMS_OrderItem__c();
        orderItem.Order_Id__c = order.Id;                  
        orderItem.Bundle_Id__c = '2c92c0f93fd531f1013ff29cc48a55e2';
        orderItem.Bundle_Name__c = 'Test';                                      
        orderItem.Zuora_Product_Id__c = '2c92c0f93fd531f1013ff29cc48a55e2' ;
        orderItem.Zuora_Product_Name__c = 'Core Service';   
        orderItem.OneTimeProductRatePlanId__c = '';
        orderItem.OneTimeProductRatePlanName__c = '';   
        orderItem.RecurringProductRatePlanId__c = '';
        orderItem.RecurringProductRatePlanName__c = '';   
        orderItem.DiscountProductRatePlanId__c = '2c92c0f841ba8ff60141c7888e5b68b4';
        orderItem.DiscountProductRatePlanName__c = 'Office Secretary - Quarterly ';    
        orderItem.TermDuration__c = 3;                              
        orderItem.IsCore__c = false;
         
        insert orderItem;    
    } 
    
    private static void createOrderWithSingleOrderItem() {
    
        Subscriptions__c subscription = [SELECT Id, Name FROM Subscriptions__c LIMIT 1];   
    
        /* Create test data for SMS_Order__c */
        order = new SMS_Order__c();                
        order.Name = 'Order Id';
        order.Token__c = '';
        order.Zuora_Account_Id__c = '2c92c0f943dcac3d0143f8623e080192';
        order.MRIS_Subscription_Id__c = subscription.Id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = false;
        
        insert order;
           
        String salt = String.valueOf(order.id);
        String secretKey = 'secret_key';
        String algorithmName = 'HmacSHA256';
        
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
        token = EncodingUtil.base64Encode(hmacData);
        
        order.Token__c = token;
        order.Name = order.id;
        update order;
        
        /* Order Items test data */
        orderItem = new SMS_OrderItem__c();
        orderItem.Order_Id__c = order.Id;                  
        orderItem.Bundle_Id__c = '';
        orderItem.Bundle_Name__c = '';                                      
        orderItem.Zuora_Product_Id__c = '2c92c0f93fd531f1013ff29cc48a55e2' ;
        orderItem.Zuora_Product_Name__c = 'Core Service';   
        orderItem.OneTimeProductRatePlanId__c = '2c92c0f84207d6a5014228845b2039b2';
        orderItem.OneTimeProductRatePlanName__c = 'New Subscriber';   
        orderItem.RecurringProductRatePlanId__c = '2c92c0f941ba98200141c7a64e7f394d';
        orderItem.RecurringProductRatePlanName__c = 'REALTOR Appraiser Shareholder - Quarterly';   
        orderItem.DiscountProductRatePlanId__c = '2c92c0f841ba8ff60141c7888e5b68b4';
        orderItem.DiscountProductRatePlanName__c = 'Office Secretary - Quarterly ';    
        orderItem.TermDuration__c = 3;                              
        orderItem.IsCore__c = true;
        orderItem.Service_Activation_Date__c = system.today();
        orderItem.Contract_Effective_Date__c = system.today();
         
         
        insert orderItem;    
    }
    private static void createOrderWithMultipleOrderItems() {
    
        Subscriptions__c subscription = [SELECT Id, Name FROM Subscriptions__c LIMIT 1];
    
        /* Insert data into order */
        order = new SMS_Order__c();                
        order.Name = 'Order Id';
        order.Token__c = '';
        order.Zuora_Account_Id__c = '2c92c0f943dcac3d0143f8623e080192';
        order.MRIS_Subscription_Id__c = subscription.Id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = false;
        
        insert order;
           
        String salt = String.valueOf(order.id);
        String secretKey = 'secret_key';
        String algorithmName = 'HmacSHA256';
        
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
        token = EncodingUtil.base64Encode(hmacData);
        
        order.Token__c = token;
        order.Name = order.id;
        update order;
        
        orderItem = new SMS_OrderItem__c();
        orderItem.Order_Id__c = order.Id;                  
        orderItem.Bundle_Id__c = '123';
        orderItem.Bundle_Name__c = 'Test';                                     
        orderItem.Zuora_Product_Id__c = '2c92c0f841ba8ff60141c7888e5b68b4' ;
        orderItem.Zuora_Product_Name__c = 'Core Service1';   
        orderItem.OneTimeProductRatePlanId__c = '';
        orderItem.OneTimeProductRatePlanName__c = '';   
        orderItem.RecurringProductRatePlanId__c = '2c92c0f941ba98200141c7a64e7f394d';
        orderItem.RecurringProductRatePlanName__c = 'REALTOR Appraiser Shareholder - Quarterly';   
        orderItem.DiscountProductRatePlanId__c = '';
        orderItem.DiscountProductRatePlanName__c = '';    
        orderItem.TermDuration__c = 3;                              
        orderItem.IsCore__c = true;
        orderItem.Service_Activation_Date__c = system.today();
        orderItem.Contract_Effective_Date__c = system.today();
         
        insert orderItem;  
        
        
        orderItem = new SMS_OrderItem__c();
        orderItem.Order_Id__c = order.Id;                  
        orderItem.Bundle_Id__c = '123';
        orderItem.Bundle_Name__c = 'Test';                                  
        orderItem.Zuora_Product_Id__c = '2c92c0f93fd531f1013ff29cc48a55e2' ;
        orderItem.Zuora_Product_Name__c = 'Core Service2';   
        orderItem.OneTimeProductRatePlanId__c = '';
        orderItem.OneTimeProductRatePlanName__c = '';   
        orderItem.RecurringProductRatePlanId__c = '2c92c0f841ba8ff60141c7888e5b68b4';
        orderItem.RecurringProductRatePlanName__c = 'Office Secretary - Quarterly';   
        orderItem.DiscountProductRatePlanId__c = '';
        orderItem.DiscountProductRatePlanName__c = '';    
        orderItem.TermDuration__c = 3;                              
        orderItem.IsCore__c = true;
        orderItem.Service_Activation_Date__c = system.today();
        orderItem.Contract_Effective_Date__c = system.today();
         
        insert orderItem;  
                 
    }    
    private static void createOrderWithoutOrderItems() {
    
        Subscriptions__c subscription = [SELECT Id, Name FROM Subscriptions__c LIMIT 1];
         
        /* Insert data into order */
        order = new SMS_Order__c();                
        order.Name = 'Order Id';
        order.Token__c = '';
        order.Zuora_Account_Id__c = '2c92c0f943dcac3d0143f8623e080192';
        order.MRIS_Subscription_Id__c = subscription.Id;
        order.Status__c = 'Active';
        order.Bypass_Payment__c = false;
        
        insert order;
           
        String salt = String.valueOf(order.id);
        String secretKey = 'secret_key';
        String algorithmName = 'HmacSHA256';
        
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));
        token = EncodingUtil.base64Encode(hmacData);
        
        order.Token__c = token;
        order.Name = order.id;
        update order;
                    
    }        
}