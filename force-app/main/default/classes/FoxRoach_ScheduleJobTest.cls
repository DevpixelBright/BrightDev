@isTest
public class FoxRoach_ScheduleJobTest 
{
    @isTest
    static void testFoxroachScheduleJob()
    {
        Test.setMock(HttpCalloutMock.class, new MockFoxRoachHttpResponseGenerator());
        String CRON_EXP = '0 0 0 3 9 ? '+(System.today().year()+1);
        system.debug('--CRON_EXP--'+CRON_EXP);
        Test.startTest();
        String jobId = System.schedule('testScheduledApex',
                                       CRON_EXP, 
                                       new FoxRoach_ScheduleJob());
        Test.stopTest();
    }
}