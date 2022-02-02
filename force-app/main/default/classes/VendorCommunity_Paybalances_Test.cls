@istest(SeeAllData = true)
public class VendorCommunity_Paybalances_Test {
    
    private Static Account account;
    private Static Contact contact;
    
    private static testMethod void doTestOne(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        generateTestData();       
        
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_Paybalances;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', account.Name);           
        
        VendorCommunity_Paybalances controller = new VendorCommunity_Paybalances();
        controller.initPaymentPortal();          
        
    }
    
    private static testMethod void doTestTwo(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        generateTestData();       
        
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_Paybalances;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', account.Name);           
        
        VendorCommunity_Paybalances controller = new VendorCommunity_Paybalances();
        controller.initPaymentPortal();
        controller.reloadBrokerages();     
    }
    
    private static testMethod void doTestThree(){
        SMS_ZuoraMockDataGenerator.zNumOfResults = 1; 
        SMS_ZuoraMockDataGenerator.isCore = 'true';
        
        generateTestData();       
        
        /* Create page reference */
        PageReference pageRef = Page.VendorCommunity_Paybalances;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', contact.id);
        
        VendorCommunity_Paybalances controller = new VendorCommunity_Paybalances();
        controller.initPaymentPortal();
        controller.reloadBrokerages();     
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