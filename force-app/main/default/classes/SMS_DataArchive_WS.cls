@RestResource(urlMapping='/DataArchive/*')
global with sharing Class SMS_DataArchive_WS {
    @HttpPost
    global static void dataArchive(List<String> recordIds) {    
      System.debug('recordIds Size:' + recordIds.Size());
      if(recordIds.size() > 0) {
          Map<String,List<String>> objNameIds = new Map<String,List<String>>();
          List<SMS_DataArchive_Days__c> archiveSettings = SMS_DataArchive_Days__c.getAll().values();
          for(SMS_DataArchive_Days__c setting : archiveSettings){              
                 objNameIds.put(setting.Name, new List<String>());
          }
          
          for(String recordId : recordIds){
              String objectName = String.valueOf(Id.valueOf(recordId).getSObjectType());
              if(objNameIds.keyset().contains(objectName))
                 objNameIds.get(objectName).add(recordId);
          }
          System.debug('***' + objNameIds);
          Integer i = 5;
          
          for(String objName : objNameIds.keyset()){
              SMS_DataArchive_Delete deleteBatch = new SMS_DataArchive_Delete(objName, objNameIds.get(objName));
              
              if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5) 
                Database.executeBatch(deleteBatch,100); 
              else {
                String jobName = 'SMS_DataArchive_Delete - ' + String.ValueOf(Datetime.now());
                String cronID = System.scheduleBatch(deleteBatch, jobName, 10 + i, 100);
                i = i + 10;
             }
          }
      }      
    }   
}