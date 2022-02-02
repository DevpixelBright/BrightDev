public class SMS_CreditBalance_Controller {
    
    public List<zAccountDetails> zAccts { get; set; }
    public String zAccountsList { get; set; } 
    public String zAccountsSelected { get; set; } 
    public String zAccountsCompleted { get; set; }
    public String zAccountsFailed { get; set; }

    public SMS_CreditBalance_Controller() { 
        zAccountsCompleted = '';
        zAccountsFailed = '';
        zAccts = new List<zAccountDetails>();
        try {
            SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
            
            String zQuery = 'SELECT Id, Name, Balance, CreditBalance, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE ParentId != null '; 
            
            if (!Test.isRunningTest())
                zQuery += 'AND TotalInvoiceBalance > 0 AND CreditBalance > 0';
                  
            List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zQuery);
            if(zAccounts.Size() > 0) {
                for(Zuora.zObject zAccount : zAccounts) {
                    zAccountDetails zAcctDetail = new zAccountDetails();
                    zAcctDetail.accountId = (String)zAccount.getValue('Id');
                    zAcctDetail.accountName = (String)zAccount.getValue('Name');
                    zAcctDetail.balance = (Decimal)zAccount.getValue('Balance');
                    zAcctDetail.CreditBalance = (Decimal)zAccount.getValue('CreditBalance');
                    zAcctDetail.TotalInvoiceBalance = (Decimal)zAccount.getValue('TotalInvoiceBalance');
                    zAcctDetail.Subscription = (String)zAccount.getValue('SubscriptionID__c');
                    zAcctDetail.selected = false; 
                    zAccts.add(zAcctDetail);
                }
            } 
            zAccountsList = JSON.serialize(zAccts);     
        
        }
        catch(Exception e) {
        
        } 
         
    }
    
    public void queryzAccounts() {
  
    }
    
    public pagereference applyCreditBalance() {
        System.debug('***' + (String)zAccountsSelected);
        List<String> zAccountIds = zAccountsSelected.split(',');
        
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
        for(String zAccountId : zAccountIds) {
            String accountQuery = 'SELECT Id, Balance, CreditBalance, TotalInvoiceBalance, SubscriptionID__c FROM Account WHERE ';
            
             if (!Test.isRunningTest()) 
                accountQuery += 'Id = \'' + zAccountId + '\' AND TotalInvoiceBalance > 0 AND CreditBalance > 0';
            else
                accountQuery += 'Id = \'' + zAccountId + '\''; 
            
            List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
            zAccounts = zUtilInstance.zquery(accountQuery); 
            system.debug('*** zAccounts.size(): ' + zAccounts.size());
            
            if(zAccounts.size() == 1){
                Double totalInvoiceAmount = (Double)zAccounts[0].getValue('TotalInvoiceBalance');
                Double creditBalance = (Double)zAccounts[0].getValue('CreditBalance');
                system.debug('*** creditBalance: ' + creditBalance);
                
                String invoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount FROM Invoice WHERE ';
                
                if (!Test.isRunningTest())
                    invoiceQuery += 'AccountId = \'' + zAccountId + '\' AND Balance > 0';
                else
                    invoiceQuery += 'AccountId = \'' + zAccountId + '\''; 
                
                List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
                zInvoices = zUtilInstance.zquery(invoiceQuery);
                
                List<Zuora.zObject> zCBAdjustments = new List<Zuora.zObject>();
                for(Zuora.zObject zInvoice : zInvoices) {        
                    if(creditBalance > 0){
                        
                        String zInvoiceId = (String)zInvoice.getValue('Id');
                        Double invoiceAmount = (Double)zInvoice.getValue('Amount');
                        Double invoiceBalance = (Double)zInvoice.getValue('Balance');
                        
                        system.debug('*** invoiceAmount: ' + invoiceAmount);
                        system.debug('*** invoiceBalance: ' + invoiceBalance);
                        
                        Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
                        adjustment.setValue('SourceTransactionId', zInvoiceId);
                        adjustment.setValue('Type', 'Decrease');
                        
                        if(invoiceBalance <= creditBalance){
                            adjustment.setValue('Amount', invoiceBalance); 
                            system.debug('*** Invoice Balance is applied');
                            creditBalance = creditBalance - invoiceBalance;
                        }
                        else{
                            adjustment.setValue('Amount', creditBalance);
                            system.debug('*** Credit Balance is applied');
                            creditBalance = creditBalance - creditBalance;
                        }
                        zCBAdjustments.add(adjustment);                
                        system.debug('*** creditBalance: ' + creditBalance);
                    }
                }        
                
                if(zCBAdjustments.size() > 0){
                    List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zcreate(zCBAdjustments); 
                    for (Zuora.zApi.SaveResult result : zSaveResultList) {
                        if (result.Success) 
                            zAccountsCompleted += zAccountId + ',';
                        else {
                            System.debug('*** result' + zSaveResultList);
                            zAccountsFailed += zAccountId + ',';
                        }
                    }
                }
            }
            else
              zAccountsFailed += zAccountId + ',';  
        }  
 
        return null;
    }
    
    public void convertNegativeInvoices(){
        // Converts negative invoice balances to credit balances
        SMS_ZuoraUtil zUtilInstance = new SMS_ZuoraUtil();
        Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin(); 
        List<Zuora.zObject> zCBAdjustments = new List<Zuora.zObject>();            
           
       String zInvoiceQuery = 'SELECT Id,AccountId,Amount,Balance,PaymentAmount FROM Invoice WHERE Balance < 0 AND Status = \'Posted\'';           
        List<Zuora.zObject> zInvoices = new List<Zuora.zObject>();
        zInvoices = zUtilInstance.zquery(zInvoiceQuery);
        for(Zuora.zObject zInvoice : zInvoices){
            system.debug('zInvoice:' +  zInvoice);
            String zInvoiceId = (String)zInvoice.getValue('Id');
            Decimal balance = (Decimal)zInvoice.getValue('Balance');
            if(balance < 0){
                String type = 'Increase';        
                Zuora.zObject adjustment = new Zuora.zObject('CreditBalanceAdjustment');
                adjustment.setValue('SourceTransactionId', zInvoiceId);
                adjustment.setValue('Type', type);
                adjustment.setValue('Amount', -balance);
                zCBAdjustments.add(adjustment);
                
            }
            if(zCBAdjustments.size() == 50){
                List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zcreate(zCBAdjustments); 
                system.debug('*** CreditBalance : ' + zSaveResultList );
                zCBAdjustments = new List<Zuora.zObject>();
            }  
        }
        if(zCBAdjustments.size() > 0){
            List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zcreate(zCBAdjustments); 
            system.debug('*** CreditBalance : ' + zSaveResultList );
            zCBAdjustments = new List<Zuora.zObject>();
        }
        
    }
    
    public class zAccountDetails{
        public String accountId { get; set;}
        public String accountName { get; set;}
        public Double balance { get; set;}
        public Double CreditBalance { get; set;}
        public Double TotalInvoiceBalance { get; set;}
        public String Subscription { get; set;}
        public Boolean selected { get; set; }
    }    

}