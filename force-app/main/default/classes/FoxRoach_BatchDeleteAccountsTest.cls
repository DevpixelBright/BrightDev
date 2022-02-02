@isTest
public class FoxRoach_BatchDeleteAccountsTest 
{
    @isTest
    static void testBatchDeleteAccounts()
    {
        //Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        FoxRoach_Account__c fAcc = new FoxRoach_Account__c(Name = 'Account Name');
        insert fAcc;
        
        Test.startTest();
        Database.executeBatch(new FoxRoach_BatchDeleteAccounts());
        Test.stopTest();
    }
}