/**
* @author: smilligan@rainamker-llc.com
* @date:  2012-05-16
* Scheduler to run MRISApplicationVerintBatch class
**/
global class MRISApplicationVerintBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
      MRISApplicationVerintBatch b = new MRISApplicationVerintBatch(); 
      database.executebatch(b); 
    }
    
    static testmethod void testVerintBatch(){
          
       Test.startTest();
      String jobId = System.schedule('testVerintBatch','0 0 9 * * ?', new MRISApplicationVerintBatchScheduler());
   // Get the information from the CronTrigger API object 
    
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];

     //Verify the expressions are the same 
    
      System.assertEquals( '0 0 9 * * ?',ct.CronExpression);

   // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

       Test.stopTest();       
    }
   
}