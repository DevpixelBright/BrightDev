@isTest
public class SMS_DataArchive_Schedule_Test {
    
    public static testMethod void doTestOne() {
    
        /* Custom setting */
        SMS_DataArchive_Days__c daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Case';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 2;
        daSettings.Retry_Times__c = 3;
        insert daSettings;
        
        daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Task';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 2;
        daSettings.Retry_Times__c = 3;
        insert daSettings;  
        
        List<Case> casesList = new List<Case>();
        for (Integer i=0; i<10; i++) {
            Case c = new Case();
            c.Origin = 'MRIS Connect';
            c.Subject = 'Submission of MRIS Connect Case'; 
            casesList.add(c);      
        }     
        insert casesList;
        
        /* Data archive schedule class calling */
        Datetime currentTime = system.now().addMinutes(1);
        String day = string.valueOf(currentTime.day());
        String month = string.valueOf(currentTime.month());
        String hour = string.valueOf(currentTime.hour());
        String minute = string.valueOf(currentTime.minute());
        String second = string.valueOf(currentTime.second());
        String year = string.valueOf(currentTime.year());

        String strJobName = 'DataArchive -' + String.ValueOf(Math.random());
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        SMS_DataArchive_Schedule sz = new SMS_DataArchive_Schedule();
        String jobID = system.schedule(strJobName, strSchedule , sz);
                      
    }
    
    public static testMethod void doTestTwo() {
        
        /* Custom setting */
        SMS_DataArchive_Days__c daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Case';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 2;
        daSettings.Retry_Times__c = 3;
        insert daSettings; 
        
        List<Case> casesList = new List<Case>();
        for (Integer i=0; i<10; i++) {
            Case c = new Case();
            c.Origin = 'MRIS Connect';
            c.Subject = 'Submission of MRIS Connect Case'; 
            casesList.add(c);      
        }     
        insert casesList;
        
        List<sObject> recordsList =  new List<sObject>();
        recordsList = Database.query( 'SELECT Id, Archive_Date__c, Archive_Retry__c, MRIS_Subscription_Id__c FROM Case' );
        SMS_DataArchive archiveBatch = new SMS_DataArchive('Case', recordsList); 
        Database.executeBatch(archiveBatch,100);                   
    }
    
    public static testMethod void doTestThree() {
        
        /* Custom setting */
        SMS_DataArchive_Days__c daSettings = new SMS_DataArchive_Days__c();
        daSettings.Name = 'Task';
        daSettings.Archive_Days__c = 1;
        daSettings.Retry_Days__c = 0;
        daSettings.Retry_Times__c = 3;
        insert daSettings; 
        
        List<Task> tasksList = new List<Task>();
        for (Integer i=0; i<10; i++) {
            Task t = new Task();
            t.Subject='Sample Task';
            t.Status='In Progress';
            t.Archive_Date__c = date.valueOf(system.today());
            t.Archive_Retry__c = 2;
            tasksList.add(t);      
        }     
        insert tasksList;
        
        List<sObject> recordsList =  new List<sObject>();
        recordsList = Database.query( 'SELECT Id, Archive_Date__c, Archive_Retry__c, MRIS_Subscription_Id__c FROM Task' );
        SMS_DataArchive archiveBatch = new SMS_DataArchive('Task', recordsList); 
        Database.executeBatch(archiveBatch,100);                   
    }
        
}