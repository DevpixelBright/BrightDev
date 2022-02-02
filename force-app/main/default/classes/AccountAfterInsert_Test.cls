@isTest
public class AccountAfterInsert_Test {
    
    static testMethod void testDoTest() {
        Account mainAccount = new Account();
        mainAccount.name = 'ADA1231';
        mainAccount.type = 'Residential';
        mainAccount.Account_Name__c = 'Main Account';
        mainAccount.City__c = 'Herndon';
        mainAccount.Zip__c = '20171';
        mainAccount.QAS_Mailing_County__c = 'Fairfax';
        mainAccount.County__c = 'Fairfax';
        mainAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert mainAccount;
        mainAccount.State__c = 'MD';
        mainAccount.OfficeKey__c = '12345';
        update mainAccount;
        mainAccount.Shareholder_Board__c = 'Yes';
        update mainAccount;
        system.assert(mainAccount.Shareholder_Board__c == 'Yes');
    }
}