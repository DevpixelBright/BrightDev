global class SMS_DataArchive_Batch implements Database.Batchable<String>,Database.AllowsCallouts,Database.Stateful{
    
    private Integer parentRecordsCount;
    private Integer childRecordsCount;
    private List<String> recordIds;
    private String objectName;
    private List<SMS_DataArchive_FilterCriteria__c> filterCriteria;
    private String configId; 
    
    private String filterCriteriaId;
    private String historyId;
    private Integer batchSize;
    public Integer archiveRecordCount; 
    
    public SMS_DataArchive_Batch(String fcId, String historyId){
        recordIds = new List<String>();
        filterCriteriaId = fcId;
        this.historyId = historyId;
        filterCriteria = new List<SMS_DataArchive_FilterCriteria__c>();
        archiveRecordCount = getRecordCount(45000);
    }
    
    global Iterable<String> start(Database.BatchableContext BC){
        parentRecordsCount = 0;
        childRecordsCount = 0;
        
        return new SMS_CallIterableString(recordIds);
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope){
        batchSize = scope.size();
        SMS_DataArchive.response res = SMS_DataArchive.archiveData(objectName, configId, scope, historyId);
        parentRecordsCount = res.parentRecordsArchived + parentRecordsCount;
        childRecordsCount = res.childRecordsArchived + childRecordsCount;
        
        SMS_DataArchive_History__c history = new SMS_DataArchive_History__c();
        history = [SELECT Id, Status__c, Status_Reason__c, Record_Count__c, RecordsArchived__c, RecordsFailed__c,
                          Child_Records_Archived__c, Child_Records_Failed__c, Child_Records_Total__c, 
                          Parent_Records_Archived__c, Parent_Records_Failed__c, Parent_Records_Total__c 
                   FROM   SMS_DataArchive_History__c  
                   WHERE  Id = :historyId
                  ];
        if(history.Status__c != 'Failed')
            history.Status__c = res.status;
        
        if(res.status == 'Failed')
            history.Status_Reason__c = history.Status_Reason__c + '\n' + res.statusMessage;              
            
        
        history.Record_Count__c = history.Record_Count__c + res.parentRecordsTotal + res.childRecordsTotal;
        history.RecordsArchived__c = history.RecordsArchived__c + res.parentRecordsArchived + res.childRecordsArchived;
        history.RecordsFailed__c = history.RecordsFailed__c + res.parentRecordsFailed + res.childRecordsFailed;
        
        history.Child_Records_Archived__c = history.Child_Records_Archived__c + res.childRecordsArchived;
        history.Child_Records_Failed__c = history.Child_Records_Failed__c + res.childRecordsFailed;
        history.Child_Records_Total__c = history.Child_Records_Total__c + res.childRecordsTotal;
        
        history.Parent_Records_Archived__c = history.Parent_Records_Archived__c + res.parentRecordsArchived;
        history.Parent_Records_Failed__c = history.Parent_Records_Failed__c + res.parentRecordsFailed;
        history.Parent_Records_Total__c = history.Parent_Records_Total__c + res.parentRecordsTotal;
        
        update history;
    }
    
    global void finish(Database.BatchableContext BC){    
        
        if(getRecordCount(1) > 0){
           SMS_DataArchive_Batch archiveBatch = new SMS_DataArchive_Batch(filterCriteria[0].Id, historyId);
           system.debug('*** archiveBatch.archiveRecordCount : ' + archiveBatch.archiveRecordCount);
           system.debug('*** archiveRecordCount : ' + archiveRecordCount);
           if(archiveBatch.archiveRecordCount == archiveRecordCount && archiveBatch.archiveRecordCount!= 45000 && archiveRecordCount!= 45000)
               sendEmail();
           else
               Database.executeBatch(archiveBatch, batchSize);
        }
        else
            sendEmail();
    } 
    
    private Integer getRecordCount(Integer limitSize){
        recordIds = new List<String>();
        filterCriteria = new List<SMS_DataArchive_FilterCriteria__c>();
        filterCriteria = [SELECT Id, Name, ObjectName__c, Query__c,
                                 ScheduleJobId__c, SMS_DataArchive_Configurations__c,
                                 SMS_DataArchive_Configurations__r.ParentField__c 
                         FROM    SMS_DataArchive_FilterCriteria__c
                         WHERE   Id = :filterCriteriaId
                        ];
                            
        system.debug('*** filterCriteria :' + filterCriteria );
                
        configId = filterCriteria[0].SMS_DataArchive_Configurations__c;
        objectName = filterCriteria[0].ObjectName__c;
        String query = filterCriteria[0].Query__c;
        String parentField = filterCriteria[0].SMS_DataArchive_Configurations__r.ParentField__c;
        
        List<sObject> records = new List<sObject>();
        String soqlQuery = query + ' AND ' + parentField + ' != null LIMIT ' + String.valueOf(limitSize);
            
        system.debug('*** soqlQuery: ' + soqlQuery);
        records = database.query(soqlQuery);
        for(sObject obj : records)
            recordIds.add(obj.Id);
            
        return recordIds.size();
    } 
    
    private void sendEmail(){
        SMS_DataArchive_History__c history = new SMS_DataArchive_History__c();
        history = [SELECT Id, Status__c, Status_Reason__c, Record_Count__c, RecordsArchived__c, RecordsFailed__c,
                          Child_Records_Archived__c, Child_Records_Failed__c, Child_Records_Total__c, 
                          Parent_Records_Archived__c, Parent_Records_Failed__c, Parent_Records_Total__c 
                   FROM   SMS_DataArchive_History__c  
                   WHERE  Id = :historyId
                  ];
                  
        String emailBody = 'Status = ' + history.Status__c + '\n';
        emailBody = emailBody + 'Total Record Count = ' + history.Record_Count__c + '\n';
        emailBody = emailBody + 'Archived Records Count = ' + history.RecordsArchived__c + '\n';
        emailBody = emailBody + 'Failed Records Count = ' + history.RecordsFailed__c + '\n';
        
        emailBody = emailBody + 'Parent Records Total = ' + history.Parent_Records_Total__c  + '\n';
        emailBody = emailBody + 'Parent Records Archived = ' + history.Parent_Records_Archived__c + '\n';
        emailBody = emailBody + 'Parent Records Failed = ' + history.Parent_Records_Failed__c + '\n';
        
        emailBody = emailBody + 'Child Records Total = ' + history.Child_Records_Total__c + '\n';
        emailBody = emailBody + 'Child Records Archived = ' + history.Child_Records_Archived__c + '\n';
        emailBody = emailBody + 'Child Records Failed = ' + history.Child_Records_Failed__c + '\n';
             
        List<String> emailAddresses = new List<String>();
        for(SMS_DataArchive_Emails__c emailIds : SMS_DataArchive_Emails__c.getall().values())
            emailAddresses.add(emailIds.Name);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = emailAddresses;
        String subject ='Data Archive Status';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(emailBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
    }
     
}