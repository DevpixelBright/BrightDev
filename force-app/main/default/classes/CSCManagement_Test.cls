@isTest(seealldata = true)
public class CSCManagement_Test {
    
    private static testMethod void doTestOne() {
        generateData();
        String managerId= [Select Id, ManagerId FROM User WHERE Id = :userInfo.getUserId()].ManagerId;
        List<RecordType> businessRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Business Account']; 
        Account a1 = createAccount('Residential','XYZ124',businessRecordType[0].Id);
        Contact c1 = createContact(a1.Id); 
        Contact c2 = createContact(a1.Id); 
        Opportunity opp1 = createOpportunity(a1.Id);
        Opportunity opp2 = createOpportunity(a1.Id);
        createAccountShare(a1.Id, managerId);
        a1.QAS_Mailing_County__c = 'Morgan';
        
        update a1;
        
       // CSCManagement.updateOwner(a1.Id);
    }
    
    private static testMethod void doTestTwo(){
        List<AccountShare> accountShares = new List<AccountShare>();
        accountShares = [SELECT AccountId,Id,RowCause,UserOrGroupId, UserOrGroup.Name 
                             FROM AccountShare 
                             WHERE RowCause IN ('Territory') LIMIT 5];
        List<String> accountIds = new List<String>();
        for(AccountShare accs : accountShares){
                accountIds.add(accs.AccountId);                
            }
        CSCManagement.updateOwner(accountIds);
    }
    
    private static Account createAccount(String type, String name,String recordtypeid) {
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        account.RecordTypeId = recordtypeid;
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId) {
        Contact contact = new Contact();
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
        
        return contact;
    }
    private static Opportunity createOpportunity(String accountId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId; 
        opp.name = 'test opp';
        opp.StageName ='Generate Opportunity';
        opp.CloseDate=system.today();
        insert opp;
        
        return opp;
    }
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    private static void createAccountShare(String accountId,String managerId) {
        AccountShare accShare = new AccountShare();   
        accShare.AccountId = accountId;
        accShare.UserOrGroupId = managerId;
        accShare.AccountAccessLevel = 'EDIT';
        accShare.RowCause = 'Territory';
    }
}