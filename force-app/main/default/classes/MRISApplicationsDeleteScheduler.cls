global class MRISApplicationsDeleteScheduler implements Schedulable{
global void execute(SchedulableContext sc) {
      MRISApplicationsDeleteBatch b = new MRISApplicationsDeleteBatch(); 
      database.executebatch(b);
   }
   
   
   static testmethod void test() {
   Test.startTest();

    
   // Schedule the test job 
     

      String jobId = System.schedule('testMRISApplicationsDeleteScheduler',
      '0 0 9 * * ?', 
         new MRISApplicationsDeleteScheduler());
   // Get the information from the CronTrigger API object 
    

      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

   // Verify the expressions are the same 
    
      System.assertEquals( '0 0 9 * * ?', 
         ct.CronExpression);

   // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

  

   Test.stopTest();
   }
}