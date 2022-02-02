public class AccountController {
    
    @AuraEnabled
    public static list<Account> fetchAccountData(){
        return [SELECT Id, Name, Type, AccountNumber, Phone, Description, Date_Joined__c, Status__c FROM Account LIMIT 1000];
    }
}