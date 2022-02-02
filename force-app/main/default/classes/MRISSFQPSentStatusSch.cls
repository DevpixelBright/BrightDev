global with sharing class MRISSFQPSentStatusSch implements Schedulable{
    global void execute(SchedulableContext sc) {
         MRISSFQPSentStatus b = new MRISSFQPSentStatus(); 
        database.executebatch(b,1);
    }

}