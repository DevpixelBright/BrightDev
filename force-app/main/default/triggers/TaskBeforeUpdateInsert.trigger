trigger TaskBeforeUpdateInsert on Task (before insert, before update, after insert, after update) {

   /*
    *   D-02273 - make compliance activity match BLT format
    */
   if(trigger.isBefore){
       Id tId = [ SELECT id FROM User where Name = 'MRIS Admin' limit 1 ].id;
       if (tId == null) {
          tId = [ SELECT id FROM User where Name = 'Admin User' limit 1 ].id;
       }
    
       for(Task t1 : trigger.new){
           system.debug('*** Task Id: ' + t1.Subject);
          if(t1.Subject.equals('Email: Courtesy notice about outstanding fines')) {
             t1.OwnerId = tId;
             t1.whoid = null;
          }
       }
   }
   else{
       for(Task t1 : trigger.new){
           system.debug('*** Task Id: ' + t1.Id + '---' + t1.Subject);
           }
   }
}