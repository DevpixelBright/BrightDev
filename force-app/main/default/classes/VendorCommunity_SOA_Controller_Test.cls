@isTest(seealldata=true)
public class VendorCommunity_SOA_Controller_Test {
    
    private Static Account account;
    private Static Contact contact;
    
    public static testMethod void doTestOne() {
        
        generateCornerstone();             
        createAccount('RETS','XYZ123');
        account.Status__c = 'Active';
        update account;
        createContact(account.Id);
        contact.Status__c = 'Active';
        update contact;
        
        
        /* Visual force page reference */  
        PageReference pageRef = Page.VendorCommunity_SOA;
        Test.setCurrentPage(pageRef);
        
        Map<String, String> preDefinedValues = new Map<String, String>();
        preDefinedValues.put('Id', 'ADFADASd24323');
        SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', account.Name);
        ApexPages.currentPage().getParameters().put('invoiceId', 'ADFADASd24323');
        ApexPages.currentPage().getParameters().put('paymentId', 'ADFADASd24323');
        ApexPages.currentPage().getParameters().put('yearOption', '2014');
        
        VendorCommunity_SOA_Controller controller = new VendorCommunity_SOA_Controller();
        List<Integer> years = controller.yearOptions;
        controller.setYearFilter();
        controller.initSOAPortal();
        controller.getSOAInvoiceSummary();
        controller.getSOAPaymentSummary();
        controller.getSOAPDF();
        controller.getInvoicePDF();
        
    }
    
    public static testMethod void doTestTwo() {
        
        try {
            PageReference pageRef = Page.Communities_SOA;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('paymentId', 'ADFADASd24323');
            VendorCommunity_SOA_Controller controller = new VendorCommunity_SOA_Controller();
            controller.initSOAPortal();
            controller.getSOAPaymentSummary();
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
        account.status__c =  'In Progress';
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
        contact.status__c = 'In Progress';
        insert contact;  
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    
}