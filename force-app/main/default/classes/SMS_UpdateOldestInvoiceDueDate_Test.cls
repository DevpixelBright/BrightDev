@istest
private class SMS_UpdateOldestInvoiceDueDate_Test{
 
    private Static Account account;
	private Static Zuora__CustomerAccount__c billingAccount;
    
    private static testMethod void doTestOne(){    
		/* Generate test data */
        generateData();							// Map addresses with CornerstoneAddrUtility
        createAccount('Residential','XYZ124');	// Create a test personal account
        createBillingAccount(account.Id);		// Create a test billing account
		
        /* Test scenario for insert new record trigger condition */
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Zuora__Account__c = account.Id;
        zInvoice.Zuora__BillingAccount__c = billingAccount.Id;
        zInvoice.Zuora__Balance2__c = 100;
        insert zInvoice; 
        
        /* Test scenario for update record trigger condition */
        zInvoice.Zuora__Balance2__c = 80;
        update zInvoice;
        
    }
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
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
    private static void createBillingAccount(String zAccountId) {
        billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Zuora_Id__c = '2cttttt9014425f6c6472c80';
        billingAccount.Oldest_Invoice_Due__c = Date.today();
        billingAccount.Zuora__Account__c = zAccountId;
        insert billingAccount; 
    }           
}