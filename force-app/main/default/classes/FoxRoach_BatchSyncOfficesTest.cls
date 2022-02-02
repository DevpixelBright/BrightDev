@isTest
public class FoxRoach_BatchSyncOfficesTest 
{
    @isTest
    static void testBatchSyncOffices()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account account = new Account();
        account.Name = 'Test Office Name';
        account.FoxRoach_OfficeID__c = '12345';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        insert account; 
        
        Test.startTest();
        Database.executeBatch(new FoxRoach_BatchLoadOffices());
        Test.stopTest();
    }

}