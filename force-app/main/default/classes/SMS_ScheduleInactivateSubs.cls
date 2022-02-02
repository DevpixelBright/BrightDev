global class SMS_ScheduleInactivateSubs implements Schedulable {
   
    private List<String> sSubscriptionIds;
   
    public SMS_ScheduleInactivateSubs(List<String> sfSubscriptionIds) {
        sSubscriptionIds = new List<String>();
        sSubscriptionIds.addAll(sfSubscriptionIds);
        system.debug('*** Schedule Class Constructors SubscriptionIds : ' + sSubscriptionIds);
        system.debug('*** Schedule Class Constructor');
    }
   
   global void execute(SchedulableContext sc) {
       system.debug('*** Schedule Class Execute SubscriptionIds : ' + sSubscriptionIds);
       Database.executeBatch(new SMS_InactivateSubs(sSubscriptionIds),5); 
       
       system.debug('*** Schedule Class Execute');
   }  
}