public class TestingOutboundMessages {
    
    public Integer count { get; set; }
    
    public TestingOutboundMessages(){
        count = 0;
    }
    public void saveAccounts(){
        try{
            List<Account> accounts = new List<Account>();
            for(Integer i = 0 ; i < count; i++){ 
                Account mainAccount = new Account();
                mainAccount.name = 'OBM' + system.Math.random();
                mainAccount.type = 'Residential';
                mainAccount.Account_Name__c = 'OBM Account';
                mainAccount.City__c = 'Herndon';
                mainAccount.Zip__c = '20171';
                mainAccount.QAS_Mailing_County__c = 'Fairfax';
                mainAccount.County__c = 'Fairfax';
                mainAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
                accounts.add(mainAccount);
            }
            
            insert accounts;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,count + ' Accounts have been inserted.')); 
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
         
    }   
}