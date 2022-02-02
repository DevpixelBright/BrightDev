@isTest(seealldata=true)
private class Communities_SOA_Controller_Test{
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    
    public static testMethod void doTestOne() {
        
        generateCornerstone();             
        createAccount('Residential','XYZABC123');                   
        createContact(account.Id);                          
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;         
        
              
            /* Visual force page reference */  
            PageReference pageRef = Page.Communities_SOA;
            Test.setCurrentPage(pageRef);
            
            Map<String, String> preDefinedValues = new Map<String, String>();
            preDefinedValues.put('Id', 'ADFADASd24323');
            SMS_ZuoraMockDataGenerator.preDefinedValues = preDefinedValues;
            
            /* Set subscription id parameter */
            ApexPages.currentPage().getParameters().put('id', subscription.Name);
            ApexPages.currentPage().getParameters().put('invoiceId', 'ADFADASd24323');
            ApexPages.currentPage().getParameters().put('paymentId', 'ADFADASd24323');
            ApexPages.currentPage().getParameters().put('yearOption', '2014');
            
            Communities_SOA_Controller controller = new Communities_SOA_Controller();
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
            Communities_SOA_Controller controller = new Communities_SOA_Controller();
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
        subscription.name = '123111';
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