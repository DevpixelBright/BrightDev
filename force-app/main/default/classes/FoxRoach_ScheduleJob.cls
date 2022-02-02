public class FoxRoach_ScheduleJob implements Schedulable 
{
   public void execute(SchedulableContext SC) 
   {
      Database.executeBatch(new FoxRoach_BatchLoadOffices());
   }
}