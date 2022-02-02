@isTest
public class FoxRoach_BatchLoadOfficesTest 
{
    @isTest
    static void testBatchLoadOffices()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        Test.startTest();
        Database.executeBatch(new FoxRoach_BatchLoadOffices());
        Test.stopTest();
    }

}