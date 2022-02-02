@istest(SeeAllData = true)
private class VendorCommunity_PaymentMethods_Test{
        
    private Static Account account;
    private Static Contact contact;    
    private static testMethod void doTestOne(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 2; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
      
        generateTestData();       
                
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_PaymentMethods;
        Test.setCurrentPage(pageRef);
        
        String pmid = 'ewruw82758yuwehr';        
        ApexPages.currentPage().getParameters().put('id', account.Name);
        ApexPages.currentPage().getParameters().put('pmId', pmid);
        ApexPages.currentPage().getParameters().put('paymentOption', 'Direct Debit');              
        
        /*
        SMS_HPM_Settings__c hpmSetting = new SMS_HPM_Settings__c();
        hpmSetting.Name = 'MyACHPaymentMethods';
        hpmSetting.Page_ID__c = '4536546';
        hpmSetting.Tenant_ID__c = '4536546';
        hpmSetting.API_Security_Key__c = '4536546';
        insert hpmSetting;*/
        
        VendorCommunity_PaymentMethods controller = new VendorCommunity_PaymentMethods();
        controller.paymentSetting = 'Direct Debit';
        controller.initPaymentMethodPortal();
        
        VendorCommunity_PaymentMethods.PaymentMethod paymentMethod = new VendorCommunity_PaymentMethods.PaymentMethod();
        paymentMethod.Id = pmid;        
        
        VendorCommunity_PaymentMethods.PaymentMethodData paymentMethodData = new VendorCommunity_PaymentMethods.PaymentMethodData();
        paymentMethodData.PaymentMethods = new List<VendorCommunity_PaymentMethods.PaymentMethod> {paymentMethod};
        
        controller.Payment = paymentMethodData;
        controller.reloadPaymentMethods();
        controller.initHPM();
        controller.reloadHPM();
        controller.removeHPM();
        controller.clearDefaultPaymentMethod(); 
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod();          
        controller.updatePaymentMethod(); 
        controller.updateACHPaymentMethod();
        controller.deletePaymentMethod();   
    }
    
    private static testMethod void doTestTwo(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
       
        generateTestData();       
        
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_PaymentMethods;
        Test.setCurrentPage(pageRef);
        
        VendorCommunity_PaymentMethods controller = new VendorCommunity_PaymentMethods();
        controller.initPaymentMethodPortal();
        SMS_ZuoraMockCall.isSuccess = false;
        controller.updatePaymentMethod();              
             
    }
    
    private static testMethod void doTestThree(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
       
        generateTestData();       
        
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_PaymentMethods;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('paymentOption', 'Credit Card'); 
        
        String pmid = 'ewruw82758yuwehr';        
        ApexPages.currentPage().getParameters().put('id', account.Name);       
        ApexPages.currentPage().getParameters().put('pmId', pmid);
        
        VendorCommunity_PaymentMethods controller = new VendorCommunity_PaymentMethods();
        controller.initPaymentMethodPortal(); 
        
        VendorCommunity_PaymentMethods.LegacyACH legacyACH = new VendorCommunity_PaymentMethods.LegacyACH();
        legacyACH.Id = pmid;
        VendorCommunity_PaymentMethods.PaymentMethodData paymentMethodData = new VendorCommunity_PaymentMethods.PaymentMethodData();
        paymentMethodData.LegacyACHs = new List<VendorCommunity_PaymentMethods.LegacyACH> {legacyACH};       
        SMS_ZuoraMockCall.isSuccess = false;
        controller.reloadPaymentMethods();        
        controller.initHPM();
        controller.reloadHPM();
        controller.removeHPM();
        controller.clearDefaultPaymentMethod(); 
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod(); 
        controller.deletePaymentMethod(); 
        controller.updatePaymentMethod();
        controller.updateACHPaymentMethod();    
    }
    
    private static testMethod void doTestFour() {
        VendorCommunity_PaymentMethods controller = new VendorCommunity_PaymentMethods();
        controller.initHPM();
        controller.clearDefaultPaymentMethod();
        controller.updateACHPaymentMethod();
        controller.setDefaultPaymentMethod();
        controller.removeDefaultPaymentMethod();    
    }
    
    private Static void generateTestData(){
        generateCornerstone();             
        createAccount('RETS','XYZ123');
        account.Status__c = 'Active';
        update account;
        
        createContact(account.Id);
        contact.Status__c = 'Active';
        update contact;
        
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
        account.Status__c = 'In Progress';
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
        contact.Status__c = 'In Progress';
        insert contact;  
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}