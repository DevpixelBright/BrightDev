@isTest
public class FoxRoach_CalloutTest 
{
    @isTest
    static void testOffices()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        
        Test.startTest();
        FoxRoach_Callout.foxRoachCallout('','/offices','GET');        
        Test.stopTest();
    }
    @isTest
    static void testAccounts()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        Test.startTest();
        FoxRoach_Callout.foxRoachCallout('','/accounts','');
        Test.stopTest();
    }
    
    @isTest
    static void testOfficeAccounts()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        Test.startTest();
        FoxRoach_Callout.foxRoachCallout('{"officeID":"12345"}','/account/search','POST');
        Test.stopTest();
    }

}